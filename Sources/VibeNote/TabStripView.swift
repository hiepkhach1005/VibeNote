import AppKit

struct TabStripItem {
    let title: String
    let toolTip: String
    let isModified: Bool
    let isPinned: Bool
}

enum TabStripAction {
    case close(Int)
    case closeOthers(Int)
    case closeLeft(Int)
    case closeRight(Int)
    case closeUnchanged(Int)
    case togglePin(Int)
    case save(Int)
}

private final class TabTitleButton: NSButton {
    var onMiddleClick: (() -> Void)?

    override func otherMouseDown(with event: NSEvent) {
        if event.buttonNumber == 2 {
            onMiddleClick?()
            return
        }
        super.otherMouseDown(with: event)
    }
}

private final class TabCellView: NSView {
    var onMiddleClick: (() -> Void)?

    override func otherMouseDown(with event: NSEvent) {
        if event.buttonNumber == 2 {
            onMiddleClick?()
            return
        }
        super.otherMouseDown(with: event)
    }
}

/// A compact, familiar document tab row hosted in the window chrome.
///
/// The cells are laid out explicitly instead of relying on nested stack-view
/// intrinsic-size negotiation. That keeps the row stable inside an AppKit
/// scroll view when the window is resized or many documents are open.
final class TabStripView: NSView {
    var onSelect: ((Int) -> Void)?
    var onAction: ((TabStripAction) -> Void)?

    private let scrollView = NSScrollView()
    private let documentContainer = NSView()
    private var items: [TabStripItem] = []
    private var selectedIndex = 0
    private var contentWidth: CGFloat = 0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        let width = max(bounds.width, contentWidth)
        let height = max(bounds.height, 36)
        documentContainer.frame = NSRect(x: 0, y: 0, width: width, height: height)
    }

    func update(items: [TabStripItem], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex

        documentContainer.subviews.forEach { $0.removeFromSuperview() }

        var x: CGFloat = 8
        for (index, item) in items.enumerated() {
            let cell = makeCell(item: item, index: index, isSelected: index == selectedIndex)
            let titleWidth = cell.subviews.compactMap { $0 as? NSButton }
                .first(where: { $0.tag == index })?.fittingSize.width ?? 80
            let cellWidth = min(max(112, titleWidth + 48), 240)
            cell.frame = NSRect(x: x, y: 3, width: cellWidth, height: 30)
            let buttons = cell.subviews.compactMap { $0 as? NSButton }
            if buttons.count >= 2 {
                buttons[0].frame.size.width = max(50, cellWidth - 36)
                buttons[1].frame = NSRect(x: cellWidth - 24, y: 6, width: 18, height: 18)
            }
            documentContainer.addSubview(cell)
            x += cellWidth + 3
        }

        contentWidth = max(bounds.width, x + 5)
        needsLayout = true
        layoutSubtreeIfNeeded()
    }

    private func configure() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.18).cgColor

        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        documentContainer.wantsLayer = true
        documentContainer.layer?.backgroundColor = NSColor.clear.cgColor
        documentContainer.frame = bounds
        scrollView.documentView = documentContainer

        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func makeCell(item: TabStripItem, index: Int, isSelected: Bool) -> NSView {
        let container = TabCellView()
        container.onMiddleClick = { [weak self] in
            self?.onAction?(.close(index))
        }
        container.wantsLayer = true
        container.layer?.cornerRadius = 7
        container.layer?.backgroundColor = isSelected
            ? NSColor.selectedControlColor.withAlphaComponent(0.24).cgColor
            : NSColor.clear.cgColor
        container.toolTip = item.toolTip

        let modifiedPrefix = item.isModified ? "* " : ""
        let pinnedPrefix = item.isPinned ? "● " : ""
        let title = TabTitleButton(
            title: modifiedPrefix + pinnedPrefix + item.title,
            target: self,
            action: #selector(selectTab(_:))
        )
        title.tag = index
        title.onMiddleClick = { [weak self] in
            self?.onAction?(.close(index))
        }
        title.bezelStyle = .texturedRounded
        title.isBordered = false
        title.font = NSFont.systemFont(ofSize: 12, weight: isSelected ? .semibold : .regular)
        title.contentTintColor = isSelected ? .controlAccentColor : .labelColor
        title.alignment = .left
        title.toolTip = item.toolTip
        title.setAccessibilityHelp("Middle-click to close this tab")
        title.cell?.lineBreakMode = .byTruncatingTail
        title.cell?.usesSingleLineMode = true
        title.menu = contextMenu(for: index)
        title.sizeToFit()
        title.frame = NSRect(x: 8, y: 3, width: max(72, title.fittingSize.width), height: 24)

        let closeImage = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close tab") ?? NSImage()
        let close = TabTitleButton(image: closeImage, target: self, action: #selector(closeTab(_:)))
        close.tag = index
        close.onMiddleClick = { [weak self] in
            self?.onAction?(.close(index))
        }
        close.bezelStyle = .texturedRounded
        close.isBordered = false
        close.contentTintColor = .secondaryLabelColor
        close.setButtonType(.momentaryPushIn)
        close.toolTip = "Close \(item.title)"
        close.imageScaling = .scaleProportionallyDown
        close.frame = NSRect(x: 0, y: 6, width: 18, height: 18)
        close.autoresizingMask = [.minXMargin]

        container.addSubview(title)
        container.addSubview(close)
        close.frame.origin.x = max(0, container.bounds.width - close.frame.width - 5)
        return container
    }

    private func contextMenu(for index: Int) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(menuItem("Close", action: #selector(closeFromMenu(_:)), index: index, enabled: true))
        menu.addItem(menuItem("Save", action: #selector(saveFromMenu(_:)), index: index, enabled: items[index].isModified))
        menu.addItem(.separator())
        menu.addItem(menuItem(items[index].isPinned ? "Unpin" : "Pin", action: #selector(togglePinFromMenu(_:)), index: index, enabled: true))
        menu.addItem(.separator())
        menu.addItem(menuItem("Close All But This", action: #selector(closeOthersFromMenu(_:)), index: index, enabled: items.count > 1))
        menu.addItem(menuItem("Close All to the Left", action: #selector(closeLeftFromMenu(_:)), index: index, enabled: index > 0))
        menu.addItem(menuItem("Close All to the Right", action: #selector(closeRightFromMenu(_:)), index: index, enabled: index < items.count - 1))
        menu.addItem(menuItem("Close All Unchanged", action: #selector(closeUnchangedFromMenu(_:)), index: index, enabled: items.contains(where: { !$0.isModified })))
        return menu
    }

    private func menuItem(_ title: String, action: Selector, index: Int, enabled: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.representedObject = index
        item.isEnabled = enabled
        return item
    }

    private func index(from sender: Any?) -> Int? {
        if let button = sender as? NSButton { return button.tag }
        if let item = sender as? NSMenuItem { return item.representedObject as? Int }
        return nil
    }

    @objc private func selectTab(_ sender: NSButton) { onSelect?(sender.tag) }
    @objc private func closeTab(_ sender: NSButton) { onAction?(.close(sender.tag)) }
    @objc private func closeFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.close(index)) } }
    @objc private func saveFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.save(index)) } }
    @objc private func togglePinFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.togglePin(index)) } }
    @objc private func closeOthersFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.closeOthers(index)) } }
    @objc private func closeLeftFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.closeLeft(index)) } }
    @objc private func closeRightFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.closeRight(index)) } }
    @objc private func closeUnchangedFromMenu(_ sender: NSMenuItem) { if let index = index(from: sender) { onAction?(.closeUnchanged(index)) } }
}
