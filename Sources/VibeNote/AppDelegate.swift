import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindowController: MainWindowController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        mainWindowController = MainWindowController()
        AppCommands.installMenu(target: mainWindowController)
        presentMainWindow()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        mainWindowController.open(urls: urls)
        presentMainWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        presentMainWindow()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        mainWindowController.persistSession()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // The recovery session is the source of truth for unsaved notes when
        // the user quits the app. Never block termination with a save dialog.
        mainWindowController.persistSession()
        return .terminateNow
    }

    private func presentMainWindow() {
        guard let window = mainWindowController.window else { return }

        // Development builds can otherwise remain attached to a previous Space
        // after repeated `open`/`open -n` launches. Keep the editor reachable in
        // the active Space while retaining normal macOS window behavior.
        window.collectionBehavior.insert(.moveToActiveSpace)
        window.collectionBehavior.insert(.fullScreenAuxiliary)
        mainWindowController.showWindow(nil)
        if window.isMiniaturized {
            window.deminiaturize(nil)
        }

        if let visibleFrame = NSScreen.main?.visibleFrame,
           (window.frame.width < 600 || window.frame.height < 400 || !window.frame.intersects(visibleFrame)) {
            let size = NSSize(width: 1100, height: 720)
            let origin = NSPoint(
                x: visibleFrame.midX - size.width / 2,
                y: visibleFrame.midY - size.height / 2
            )
            window.setFrame(NSRect(origin: origin, size: size), display: true)
        }
        window.setIsVisible(true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.main.async { [weak window] in
            guard let window, let visibleFrame = NSScreen.main?.visibleFrame else { return }
            guard window.frame.width < 600 || window.frame.height < 400 || !window.frame.intersects(visibleFrame) else { return }
            let size = NSSize(width: 1100, height: 720)
            window.setFrame(
                NSRect(
                    x: visibleFrame.midX - size.width / 2,
                    y: visibleFrame.midY - size.height / 2,
                    width: size.width,
                    height: size.height
                ),
                display: true
            )
            window.makeKeyAndOrderFront(nil)
        }
    }
}
