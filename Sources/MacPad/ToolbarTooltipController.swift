import AppKit

/// Provides a short, native-looking tooltip for toolbar actions.
/// AppKit's NSToolbar tooltip delay is not configurable, so this controller
/// uses the toolbar's own item views and shows the same label after a brief
/// 0.18 second hover.
final class ToolbarTooltipController {
    private weak var window: NSWindow?
    private weak var toolbar: NSToolbar?
    private var eventMonitor: Any?
    private var pendingShow: DispatchWorkItem?
    private var panel: NSPanel?
    private var pendingLabel: String?
    private var pendingScreenPoint = NSPoint.zero

    init(window: NSWindow, toolbar: NSToolbar) {
        self.window = window
        self.toolbar = toolbar
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseMoved(event)
            return event
        }
    }

    deinit {
        pendingShow?.cancel()
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        panel?.orderOut(nil)
    }

    private func handleMouseMoved(_ event: NSEvent) {
        guard let window, event.window === window,
              let label = toolbarLabel(at: event.locationInWindow),
              !label.isEmpty else {
            clear()
            return
        }

        let screenPoint = window.convertToScreen(NSRect(origin: event.locationInWindow, size: .zero)).origin
        guard pendingLabel != label || pendingScreenPoint != screenPoint else { return }

        pendingShow?.cancel()
        panel?.orderOut(nil)
        pendingLabel = label
        pendingScreenPoint = screenPoint

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.pendingLabel == label else { return }
            self.show(label: label, near: screenPoint)
        }
        pendingShow = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: workItem)
    }

    private func toolbarLabel(at point: NSPoint) -> String? {
        guard let window, let toolbar else { return nil }

        for item in toolbar.visibleItems ?? [] {
            guard let view = item.view,
                  view.window === window,
                  !item.label.isEmpty else { continue }
            let localPoint = view.convert(point, from: nil)
            if view.bounds.contains(localPoint) {
                return item.label
            }
        }
        return nil
    }

    private func clear() {
        pendingShow?.cancel()
        pendingShow = nil
        pendingLabel = nil
        panel?.orderOut(nil)
    }

    private func show(label: String, near screenPoint: NSPoint) {
        let text = NSTextField(labelWithString: label)
        text.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        text.textColor = .labelColor
        text.alignment = .center
        text.wantsLayer = true
        text.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.96).cgColor
        text.layer?.cornerRadius = 6

        let size = NSSize(width: text.fittingSize.width + 18, height: 28)
        let tooltipPanel = panel ?? NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel = tooltipPanel
        tooltipPanel.contentView = text
        tooltipPanel.setContentSize(size)
        tooltipPanel.isOpaque = false
        tooltipPanel.backgroundColor = .clear
        tooltipPanel.hasShadow = true
        tooltipPanel.level = .statusBar
        tooltipPanel.ignoresMouseEvents = true

        let screen = NSScreen.screens.first(where: { $0.frame.contains(screenPoint) }) ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        var origin = NSPoint(x: screenPoint.x + 10, y: screenPoint.y - size.height - 8)
        origin.x = min(max(origin.x, visibleFrame.minX + 4), visibleFrame.maxX - size.width - 4)
        origin.y = min(max(origin.y, visibleFrame.minY + 4), visibleFrame.maxY - size.height - 4)
        tooltipPanel.setFrameOrigin(origin)
        tooltipPanel.orderFrontRegardless()
    }
}
