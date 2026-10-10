import AppKit

enum AppCommands {
    static func installMenu(target: AnyObject) {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "MacPad")
        let aboutItem = appMenu.addItem(withTitle: "About MacPad", action: #selector(MainWindowController.showAbout), keyEquivalent: "")
        aboutItem.target = target
        appMenu.addItem(.separator())
        let preferencesItem = appMenu.addItem(withTitle: "Preferences…", action: #selector(MainWindowController.showPreferences), keyEquivalent: ",")
        preferencesItem.target = target
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide MacPad", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Quit MacPad", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let fileItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(item("New", action: #selector(MainWindowController.newDocument), key: "n", target: target))
        fileMenu.addItem(item("Open…", action: #selector(MainWindowController.openDocument), key: "o", target: target))
        fileMenu.addItem(item("Save", action: #selector(MainWindowController.saveDocument), key: "s", target: target))
        fileMenu.addItem(item("Save As…", action: #selector(MainWindowController.saveDocumentAs), key: "s", modifiers: [.command, .shift], target: target))
        fileMenu.addItem(item("Save a Copy As…", action: #selector(MainWindowController.saveCopyDocumentAs), key: "", target: target))
        fileMenu.addItem(item("Save All", action: #selector(MainWindowController.saveAllDocuments), key: "", target: target))
        fileMenu.addItem(item("Reload from Disk", action: #selector(MainWindowController.reloadDocument), key: "r", modifiers: [.command, .option], target: target))
        fileMenu.addItem(.separator())
        fileMenu.addItem(item("Close", action: #selector(MainWindowController.closeDocument), key: "w", target: target))
        fileMenu.addItem(item("Close All", action: #selector(MainWindowController.closeAllDocuments), key: "w", modifiers: [.command, .shift], target: target))
        fileMenu.addItem(.separator())
        fileMenu.addItem(item("Print…", action: #selector(MainWindowController.printDocument), key: "p", modifiers: [.command, .shift], target: target))
        fileItem.submenu = fileMenu
        mainMenu.addItem(fileItem)

        let editItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(item("Undo", action: #selector(MainWindowController.undo), key: "z", target: target))
        editMenu.addItem(item("Redo", action: #selector(MainWindowController.redo), key: "z", modifiers: [.command, .shift], target: target))
        editMenu.addItem(.separator())
        editMenu.addItem(item("Cut", action: #selector(NSText.cut(_:)), key: "x"))
        editMenu.addItem(item("Copy", action: #selector(NSText.copy(_:)), key: "c"))
        editMenu.addItem(item("Paste", action: #selector(NSText.paste(_:)), key: "v"))
        editMenu.addItem(item("Select All", action: #selector(NSText.selectAll(_:)), key: "a"))
        editMenu.addItem(.separator())
        editMenu.addItem(item("Duplicate Line", action: #selector(MainWindowController.duplicateLine), key: "d", modifiers: [.command, .shift], target: target))
        editMenu.addItem(item("Delete Line", action: #selector(MainWindowController.deleteLine), key: "k", modifiers: [.command, .shift], target: target))
        editMenu.addItem(item("Move Line Up", action: #selector(MainWindowController.moveLineUp), key: "", target: target))
        editMenu.addItem(item("Move Line Down", action: #selector(MainWindowController.moveLineDown), key: "", target: target))
        editMenu.addItem(item("Join Lines", action: #selector(MainWindowController.joinLines), key: "j", modifiers: [.command, .option], target: target))
        editMenu.addItem(item("Split Line", action: #selector(MainWindowController.splitLine), key: "return", modifiers: [.command, .option], target: target))
        editMenu.addItem(item("Trim Trailing Whitespace", action: #selector(MainWindowController.trimTrailingWhitespace), key: "", target: target))
        editMenu.addItem(item("Uppercase Selection", action: #selector(MainWindowController.uppercaseSelection), key: "u", modifiers: [.command, .option], target: target))
        editMenu.addItem(item("Lowercase Selection", action: #selector(MainWindowController.lowercaseSelection), key: "l", modifiers: [.command, .option], target: target))
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)

        let searchItem = NSMenuItem()
        let searchMenu = NSMenu(title: "Search")
        searchMenu.addItem(item("Find…", action: #selector(MainWindowController.focusSearch), key: "f", target: target))
        searchMenu.addItem(item("Find and Replace…", action: #selector(MainWindowController.showFindPanel), key: "f", modifiers: [.command, .option], target: target))
        searchMenu.addItem(item("Find Next", action: #selector(MainWindowController.findNext), key: "g", target: target))
        searchMenu.addItem(item("Find Previous", action: #selector(MainWindowController.findPrevious), key: "g", modifiers: [.command, .shift], target: target))
        searchMenu.addItem(item("Go to Line…", action: #selector(MainWindowController.goToLine), key: "l", modifiers: [.command, .option], target: target))
        searchItem.submenu = searchMenu
        mainMenu.addItem(searchItem)

        let viewItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(item("Zoom In", action: #selector(MainWindowController.zoomIn), key: "+", modifiers: [.command], target: target))
        viewMenu.addItem(item("Zoom Out", action: #selector(MainWindowController.zoomOut), key: "-", modifiers: [.command], target: target))
        viewMenu.addItem(item("Reset Zoom", action: #selector(MainWindowController.resetZoom), key: "0", modifiers: [.command], target: target))
        viewMenu.addItem(.separator())
        viewMenu.addItem(item("Toggle Line Numbers", action: #selector(MainWindowController.toggleLineNumbers), key: "", target: target))
        viewMenu.addItem(item("Toggle Word Wrap", action: #selector(MainWindowController.toggleWordWrap), key: "w", modifiers: [.command, .option], target: target))
        viewMenu.addItem(item("Smart Highlighting", action: #selector(MainWindowController.toggleSmartHighlighting), key: "h", modifiers: [.command, .option], target: target))
        viewItem.submenu = viewMenu
        mainMenu.addItem(viewItem)

        let encodingItem = NSMenuItem()
        let encodingMenu = NSMenu(title: "Encoding")
        encodingMenu.addItem(item("UTF-8", action: #selector(MainWindowController.setEncodingUTF8), key: "", target: target))
        encodingMenu.addItem(item("UTF-8 with BOM", action: #selector(MainWindowController.setEncodingUTF8BOM), key: "", target: target))
        encodingMenu.addItem(item("UTF-16 LE", action: #selector(MainWindowController.setEncodingUTF16LE), key: "", target: target))
        encodingMenu.addItem(item("UTF-16 BE", action: #selector(MainWindowController.setEncodingUTF16BE), key: "", target: target))
        encodingMenu.addItem(.separator())
        encodingMenu.addItem(item("Convert to LF", action: #selector(MainWindowController.setLineEndingLF), key: "", target: target))
        encodingMenu.addItem(item("Convert to CRLF", action: #selector(MainWindowController.setLineEndingCRLF), key: "", target: target))
        encodingMenu.addItem(item("Convert to CR", action: #selector(MainWindowController.setLineEndingCR), key: "", target: target))
        encodingItem.submenu = encodingMenu
        mainMenu.addItem(encodingItem)

        let languageItem = NSMenuItem()
        let languageMenu = NSMenu(title: "Language")
        languageMenu.addItem(item("Normal Text", action: #selector(MainWindowController.setLanguagePlainText), key: "", target: target))
        languageMenu.addItem(.separator())
        languageMenu.addItem(item("Swift", action: #selector(MainWindowController.setLanguageSwift), key: "", target: target))
        languageMenu.addItem(item("Python", action: #selector(MainWindowController.setLanguagePython), key: "", target: target))
        languageMenu.addItem(item("JavaScript", action: #selector(MainWindowController.setLanguageJavaScript), key: "", target: target))
        languageMenu.addItem(item("JSON", action: #selector(MainWindowController.setLanguageJSON), key: "", target: target))
        languageMenu.addItem(item("HTML", action: #selector(MainWindowController.setLanguageHTML), key: "", target: target))
        languageMenu.addItem(item("CSS", action: #selector(MainWindowController.setLanguageCSS), key: "", target: target))
        languageMenu.addItem(item("Shell Script", action: #selector(MainWindowController.setLanguageShell), key: "", target: target))
        languageMenu.addItem(item("Markdown", action: #selector(MainWindowController.setLanguageMarkdown), key: "", target: target))
        languageMenu.addItem(item("C", action: #selector(MainWindowController.setLanguageC), key: "", target: target))
        languageMenu.addItem(item("C++", action: #selector(MainWindowController.setLanguageCPP), key: "", target: target))
        languageMenu.addItem(item("SQL", action: #selector(MainWindowController.setLanguageSQL), key: "", target: target))
        languageItem.submenu = languageMenu
        mainMenu.addItem(languageItem)

        let windowItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(item("Next Tab", action: #selector(MainWindowController.nextTab), key: "]", modifiers: [.command, .shift], target: target))
        windowMenu.addItem(item("Previous Tab", action: #selector(MainWindowController.previousTab), key: "[", modifiers: [.command, .shift], target: target))
        windowMenu.addItem(.separator())
        windowMenu.addItem(item("Minimize", action: #selector(NSWindow.performMiniaturize(_:)), key: "m"))
        windowMenu.addItem(item("Zoom", action: #selector(NSWindow.performZoom(_:)), key: ""))
        windowItem.submenu = windowMenu
        mainMenu.addItem(windowItem)

        let helpItem = NSMenuItem()
        let helpMenu = NSMenu(title: "Help")
        let helpAction = helpMenu.addItem(withTitle: "MacPad Help", action: #selector(MainWindowController.showHelp), keyEquivalent: "?")
        helpAction.target = target
        helpItem.submenu = helpMenu
        mainMenu.addItem(helpItem)

        NSApp.mainMenu = mainMenu
        _ = target
    }

    private static func item(_ title: String, action: Selector, key: String, modifiers: NSEvent.ModifierFlags = [.command], target: AnyObject? = nil) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        menuItem.keyEquivalentModifierMask = modifiers
        menuItem.target = target
        return menuItem
    }
}
