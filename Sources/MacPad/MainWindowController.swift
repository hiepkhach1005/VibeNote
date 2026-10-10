import AppKit

final class MainWindowController: NSWindowController, NSWindowDelegate, NSToolbarDelegate, NSSearchFieldDelegate, NSMenuItemValidation {
    private let store = DocumentStore()
    private let sessionStore = SessionStore()
    private let textSettingsStore = TextSettingsStore()
    private var textSettings = TextSettingsStore().load()
    private let tabViewController = NSTabViewController()
    private let tabStrip = TabStripView()
    private var editors: [EditorViewController] = []
    private var pinnedDocumentIDs = Set<UUID>()
    private let statusLine = NSTextField(labelWithString: "Ln 1, Col 1")
    private let statusSelection = NSTextField(labelWithString: "")
    private let statusEncoding = NSTextField(labelWithString: "UTF-8")
    private let statusEOL = NSTextField(labelWithString: "Unix (LF)")
    private let statusLanguage = NSTextField(labelWithString: "Normal Text")
    private let statusDisk = NSTextField(labelWithString: "")
    private let statusFile = NSTextField(labelWithString: "Untitled")
    private let searchField = NSSearchField()
    private var findPanelController: FindPanelController?
    private var lineNumbersVisible = true
    private var pendingSessionSave: DispatchWorkItem?
    private var externalFileTimer: Timer?
    private var textSettingsWindowController: TextSettingsWindowController?
    private var isTerminatingFromWindowClose = false
    private var toolbarTooltipController: ToolbarTooltipController?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1100, height: 720),
            // Keep the document content below the unified toolbar. This is
            // important for the visible Notepad++-style tab row: fullSizeContentView
            // would let the toolbar cover the first 36pt of the editor shell.
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        self.init(window: window)
    }

    override init(window: NSWindow?) {
        super.init(window: window)
        window?.delegate = self
        window?.isReleasedWhenClosed = false
        window?.isRestorable = false
        window?.restorationClass = nil
        window?.title = "MacPad"
        window?.center()
        window?.minSize = NSSize(width: 600, height: 400)
        configureWindow()
        restoreSession()
        if editors.isEmpty { addNewDocument() }
        externalFileTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkExternalFileChanges), userInfo: nil, repeats: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        externalFileTimer?.invalidate()
    }

    func windowDidBecomeKey(_ notification: Notification) {
        focusSelectedEditor()
    }

    private func configureWindow() {
        guard let window else { return }

        let toolbar = NSToolbar(identifier: "MacPadToolbar")
        toolbar.delegate = self
        toolbar.allowsUserCustomization = true
        // Keep the toolbar compact like a native macOS editor. The action
        // name remains available through each item's hover tooltip and in
        // the toolbar customization palette.
        toolbar.displayMode = .iconOnly
        window.acceptsMouseMovedEvents = true
        toolbarTooltipController = ToolbarTooltipController(window: window, toolbar: toolbar)
        window.toolbar = toolbar
        window.toolbarStyle = .unified

        tabViewController.tabStyle = .unspecified
        tabViewController.tabView.tabViewType = .noTabsNoBorder
        tabViewController.view.translatesAutoresizingMaskIntoConstraints = false

        let tabChrome = NSVisualEffectView()
        tabChrome.material = .headerView
        tabChrome.blendingMode = .withinWindow
        tabChrome.state = .followsWindowActiveState
        tabChrome.wantsLayer = true
        tabChrome.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.82).cgColor
        tabChrome.layer?.zPosition = 10
        tabChrome.translatesAutoresizingMaskIntoConstraints = false
        tabStrip.translatesAutoresizingMaskIntoConstraints = false
        tabChrome.addSubview(tabStrip)

        let statusBar = NSVisualEffectView()
        statusBar.material = .headerView
        statusBar.blendingMode = .withinWindow
        statusBar.state = .followsWindowActiveState
        statusBar.translatesAutoresizingMaskIntoConstraints = false

        let statusStack = NSStackView(views: [statusFile, statusLine, statusSelection, statusEncoding, statusEOL, statusLanguage, statusDisk])
        statusStack.orientation = .horizontal
        statusStack.alignment = .centerY
        statusStack.spacing = 14
        statusStack.edgeInsets = NSEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        statusBar.addSubview(statusStack)

        let root = FileDropView()
        root.onDropFiles = { [weak self] urls in
            self?.open(urls: urls)
        }
        root.addSubview(tabViewController.view)
        root.addSubview(tabChrome, positioned: .above, relativeTo: tabViewController.view)
        root.addSubview(statusBar, positioned: .above, relativeTo: tabViewController.view)
        NSLayoutConstraint.activate([
            tabChrome.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            tabChrome.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            tabChrome.topAnchor.constraint(equalTo: root.topAnchor),
            tabChrome.heightAnchor.constraint(equalToConstant: 36),
            tabStrip.leadingAnchor.constraint(equalTo: tabChrome.leadingAnchor),
            tabStrip.trailingAnchor.constraint(equalTo: tabChrome.trailingAnchor),
            tabStrip.topAnchor.constraint(equalTo: tabChrome.topAnchor),
            tabStrip.bottomAnchor.constraint(equalTo: tabChrome.bottomAnchor),
            tabViewController.view.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            tabViewController.view.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            tabViewController.view.topAnchor.constraint(equalTo: tabChrome.bottomAnchor),
            tabViewController.view.bottomAnchor.constraint(equalTo: statusBar.topAnchor),
            statusBar.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            statusBar.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            statusBar.heightAnchor.constraint(equalToConstant: 28),
            statusStack.leadingAnchor.constraint(equalTo: statusBar.leadingAnchor),
            statusStack.trailingAnchor.constraint(equalTo: statusBar.trailingAnchor),
            statusStack.topAnchor.constraint(equalTo: statusBar.topAnchor),
            statusStack.bottomAnchor.constraint(equalTo: statusBar.bottomAnchor)
        ])
        window.contentView = root

        [statusFile, statusLine, statusSelection, statusEncoding, statusEOL, statusLanguage, statusDisk].forEach {
            $0.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            $0.textColor = .secondaryLabelColor
        }
        statusFile.setContentHuggingPriority(.defaultLow, for: .horizontal)
        statusLine.setContentHuggingPriority(.required, for: .horizontal)
        statusSelection.setContentHuggingPriority(.required, for: .horizontal)
        statusEncoding.setContentHuggingPriority(.required, for: .horizontal)
        statusEOL.setContentHuggingPriority(.required, for: .horizontal)
        statusLanguage.setContentHuggingPriority(.required, for: .horizontal)
        statusDisk.setContentHuggingPriority(.required, for: .horizontal)
        statusDisk.textColor = .systemOrange

        tabStrip.onSelect = { [weak self] index in
            self?.selectTab(at: index)
        }
        tabStrip.onAction = { [weak self] action in
            self?.handleTabAction(action)
        }
    }

    @objc func newDocument() {
        addNewDocument()
    }

    private func addNewDocument() {
        add(document: EditorDocument())
    }

    private func add(document: EditorDocument) {
        let editor = EditorViewController(document: document)
        editor.updateTextSettings(textSettings)
        editor.onDocumentChange = { [weak self] editor in
            self?.updateTab(for: editor)
            self?.updateStatus(for: editor)
            self?.scheduleSessionSave()
        }
        editor.onSelectionChange = { [weak self] editor in
            self?.updateStatus(for: editor)
            self?.scheduleSessionSave()
        }
        editor.onOpenDroppedFiles = { [weak self] urls in
            self?.open(urls: urls)
        }
        editors.append(editor)
        let tab = NSTabViewItem(viewController: editor)
        tab.label = document.title
        tab.identifier = document.id
        tabViewController.addTabViewItem(tab)
        tabViewController.selectedTabViewItemIndex = editors.count - 1
        refreshTabStrip()
        updateStatus(for: editor)
        scheduleSessionSave()
        DispatchQueue.main.async { [weak self, weak editor] in
            guard let self, let editor, self.selectedEditor === editor else { return }
            editor.focus()
        }
    }

    private func restoreSession() {
        guard let session = sessionStore.load() else { return }

        for persisted in session.documents {
            let url = persisted.path.map(URL.init(fileURLWithPath:))
            let encoding = sessionStore.encoding(from: persisted.encoding)
            let lineEnding = DocumentLineEnding(rawValue: persisted.lineEnding) ?? .lf
            let language = LanguageID(rawValue: persisted.language) ?? LanguageRegistry.detect(for: url)
            // The recovery session is authoritative at launch. This preserves
            // the exact text visible when MacPad closed, including unsaved edits
            // and files whose on-disk contents changed while the app was away.
            // The regular external-change monitor can still notify the user
            // after the restored tab is active.
            add(document: EditorDocument(
                url: url,
                content: persisted.content,
                encoding: encoding,
                isModified: persisted.isModified,
                lineEnding: lineEnding,
                hasBOM: persisted.hasBOM,
                language: language,
                fileSnapshot: url.flatMap(store.snapshot(for:))
            ))
        }

        if !editors.isEmpty {
            let selectedIndex = min(max(session.selectedIndex, 0), editors.count - 1)
            tabViewController.selectedTabViewItemIndex = selectedIndex
            if let selectedEditor { updateStatus(for: selectedEditor) }
        }
    }

    func persistSession() {
        pendingSessionSave?.cancel()
        sessionStore.save(documents: editors.map(\.document), selectedIndex: max(tabViewController.selectedTabViewItemIndex, 0))
    }

    private func scheduleSessionSave() {
        pendingSessionSave?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.persistSession()
        }
        pendingSessionSave = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    @objc func openDocument() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.begin { [weak self] response in
            guard response == .OK, let self else { return }
            self.open(urls: panel.urls)
        }
    }

    func open(urls: [URL]) {
        for url in urls {
            if let existingIndex = editors.firstIndex(where: {
                $0.document.url?.standardizedFileURL == url.standardizedFileURL
            }) {
                selectTab(at: existingIndex)
                continue
            }

            do {
                let document = try store.load(from: url)
                add(document: document)
            } catch {
                showError(error)
            }
        }
    }

    @objc func saveDocument() {
        guard let editor = selectedEditor else { return }
        if editor.document.url == nil {
            saveDocumentAs()
            return
        }
        save(editor: editor, to: editor.document.url)
    }

    @objc func saveDocumentAs() {
        guard let editor = selectedEditor else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = editor.document.displayName == "Untitled" ? "Untitled.txt" : editor.document.displayName
        panel.begin { [weak self, weak editor] response in
            guard response == .OK, let self, let editor, let url = panel.url else { return }
            self.save(editor: editor, to: url)
        }
    }

    @objc func saveCopyDocumentAs() {
        guard let editor = selectedEditor else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = editor.document.displayName == "Untitled" ? "Untitled Copy.txt" : editor.document.displayName
        panel.begin { [weak self, weak editor] response in
            guard response == .OK, let self, let editor, let url = panel.url else { return }
            do {
                try self.store.save(editor.document, to: url)
            } catch {
                self.showError(error)
            }
        }
    }

    @objc func saveAllDocuments() {
        for editor in editors where editor.document.isModified || editor.document.url == nil {
            if editor.document.url == nil {
                tabViewController.selectedTabViewItemIndex = editors.firstIndex(of: editor) ?? 0
                saveDocumentAs()
            } else {
                save(editor: editor, to: editor.document.url)
            }
        }
    }

    private func save(editor: EditorViewController, to url: URL?) {
        do {
            try store.save(editor.document, to: url)
            if let url { editor.document.url = url }
            editor.document.isModified = false
            editor.document.fileSnapshot = editor.document.url.flatMap(store.snapshot(for:))
            editor.document.hasExternalChange = false
            updateTab(for: editor)
            updateStatus(for: editor)
        } catch {
            showError(error)
        }
    }

    @objc func closeDocument() {
        guard let editor = selectedEditor else { return }
        guard confirmClose(editor: editor) else { return }
        remove(editor: editor)
    }

    @objc func reloadDocument() {
        guard let editor = selectedEditor, editor.document.url != nil else { return }
        reload(editor: editor, askBeforeDiscardingChanges: editor.document.isModified)
    }

    private func reload(editor: EditorViewController, askBeforeDiscardingChanges: Bool) {
        guard let url = editor.document.url else { return }

        if askBeforeDiscardingChanges {
            let alert = NSAlert()
            alert.messageText = "Discard local changes and reload?"
            alert.informativeText = editor.document.displayName
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Reload")
            alert.addButton(withTitle: "Cancel")
            guard alert.runModal() == .alertFirstButtonReturn else { return }
        }

        do {
            let freshDocument = try store.load(from: url)
            editor.document.content = freshDocument.content
            editor.document.encoding = freshDocument.encoding
            editor.document.lineEnding = freshDocument.lineEnding
            editor.document.hasBOM = freshDocument.hasBOM
            editor.document.fileSnapshot = freshDocument.fileSnapshot
            editor.document.isModified = false
            editor.document.hasExternalChange = false
            editor.replaceContent(freshDocument.content)
            updateStatus(for: editor)
            scheduleSessionSave()
        } catch {
            showError(error)
        }
    }

    @objc private func checkExternalFileChanges() {
        for editor in editors {
            guard let url = editor.document.url else { continue }
            let currentSnapshot = store.snapshot(for: url)
            guard editor.document.fileSnapshot != currentSnapshot else {
                if currentSnapshot != nil { editor.document.hasExternalChange = false }
                continue
            }
            guard !editor.document.hasExternalChange else { continue }

            editor.document.hasExternalChange = true
            presentExternalChangePrompt(for: editor, snapshot: currentSnapshot)
        }
    }

    private func presentExternalChangePrompt(for editor: EditorViewController, snapshot: FileSnapshot?) {
        let alert = NSAlert()
        alert.messageText = "File changed outside MacPad"
        alert.informativeText = "\(editor.document.displayName) was changed by another application."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reload")
        alert.addButton(withTitle: "Keep Local")

        if alert.runModal() == .alertFirstButtonReturn {
            reload(editor: editor, askBeforeDiscardingChanges: false)
        } else {
            editor.document.fileSnapshot = snapshot
            editor.document.hasExternalChange = false
            updateStatus(for: editor)
            scheduleSessionSave()
        }
    }

    @objc func closeAllDocuments() {
        guard confirmCloseAll() else { return }
        editors.removeAll()
        tabViewController.tabViewItems.forEach { tabViewController.removeTabViewItem($0) }
        pinnedDocumentIDs.removeAll()
        addNewDocument()
    }

    func confirmCloseAll() -> Bool {
        for editor in editors where !confirmClose(editor: editor) {
            return false
        }
        return true
    }

    private func confirmClose(editor: EditorViewController) -> Bool {
        guard editor.document.isModified else { return true }
        let alert = NSAlert()
        alert.messageText = "Lưu thay đổi trước khi đóng?"
        alert.informativeText = editor.document.displayName
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Discard")
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            if editor.document.url == nil {
                let panel = NSSavePanel()
                panel.nameFieldStringValue = "Untitled.txt"
                guard panel.runModal() == .OK, let url = panel.url else { return false }
                save(editor: editor, to: url)
            } else {
                save(editor: editor, to: editor.document.url)
            }
            return !editor.document.isModified
        case .alertThirdButtonReturn:
            return true
        default:
            return false
        }
    }

    private func remove(editor: EditorViewController) {
        guard let index = editors.firstIndex(of: editor), index < tabViewController.tabViewItems.count else { return }
        let item = tabViewController.tabViewItems[index]
        tabViewController.removeTabViewItem(item)
        editors.remove(at: index)
        pinnedDocumentIDs.remove(editor.document.id)
        if editors.isEmpty { addNewDocument() }
        refreshTabStrip()
        if let selectedEditor { updateStatus(for: selectedEditor) }
    }

    private func refreshTabStrip() {
        let items = editors.map { editor in
            TabStripItem(
                title: editor.document.title,
                toolTip: editor.document.url?.path ?? editor.document.displayName,
                isModified: editor.document.isModified,
                isPinned: pinnedDocumentIDs.contains(editor.document.id)
            )
        }
        tabStrip.update(items: items, selectedIndex: tabViewController.selectedTabViewItemIndex)
    }

    private func selectTab(at index: Int) {
        guard index >= 0, index < tabViewController.tabViewItems.count else { return }
        tabViewController.selectedTabViewItemIndex = index
        if let selectedEditor { updateStatus(for: selectedEditor) }
        selectedEditor?.focus()
    }

    private func handleTabAction(_ action: TabStripAction) {
        switch action {
        case .close(let index):
            closeEditor(at: index)
        case .save(let index):
            guard index < editors.count else { return }
            save(editor: editors[index], to: editors[index].document.url)
        case .togglePin(let index):
            guard index < editors.count else { return }
            let id = editors[index].document.id
            if pinnedDocumentIDs.contains(id) {
                pinnedDocumentIDs.remove(id)
            } else {
                pinnedDocumentIDs.insert(id)
            }
            refreshTabStrip()
            scheduleSessionSave()
        case .closeOthers(let index):
            let indexes = editors.indices.filter { $0 != index }.sorted(by: >)
            closeEditors(at: indexes)
        case .closeLeft(let index):
            closeEditors(at: editors.indices.filter { $0 < index }.sorted(by: >))
        case .closeRight(let index):
            closeEditors(at: editors.indices.filter { $0 > index }.sorted(by: >))
        case .closeUnchanged:
            closeEditors(at: editors.indices.filter { !editors[$0].document.isModified }.sorted(by: >), confirmUnchanged: false)
        }
    }

    private func closeEditor(at index: Int) {
        guard index >= 0, index < editors.count else { return }
        if confirmClose(editor: editors[index]) {
            remove(editor: editors[index])
        }
    }

    private func closeEditors(at indexes: [Int], confirmUnchanged: Bool = true) {
        for index in indexes {
            guard index >= 0, index < editors.count else { continue }
            let editor = editors[index]
            if !confirmUnchanged || confirmClose(editor: editor) {
                remove(editor: editor)
            } else {
                break
            }
        }
    }

    @objc func focusSearch() {
        showFindPanel()
    }

    @objc func showFindPanel() {
        if findPanelController == nil {
            findPanelController = FindPanelController { [weak self] action in
                self?.handleFindPanelAction(action)
            }
        }
        findPanelController?.showWindow(self)
        findPanelController?.focusFindField()
    }

    @objc func findNext() {
        guard let query = searchField.stringValue.isEmpty ? nil : searchField.stringValue,
              let editor = selectedEditor else { return }
        _ = editor.selectNextMatch(query)
    }

    @objc func findPrevious() {
        guard let query = searchField.stringValue.isEmpty ? nil : searchField.stringValue,
              let editor = selectedEditor else { return }
        _ = editor.selectPreviousMatch(query)
    }

    @objc func nextTab() {
        guard !editors.isEmpty else { return }
        let current = tabViewController.selectedTabViewItemIndex
        selectTab(at: (current + 1) % editors.count)
    }

    @objc func previousTab() {
        guard !editors.isEmpty else { return }
        let current = tabViewController.selectedTabViewItemIndex
        selectTab(at: (current - 1 + editors.count) % editors.count)
    }

    @objc func cutSelection() { selectedEditor?.textView.cut(nil) }
    @objc func copySelection() { selectedEditor?.textView.copy(nil) }
    @objc func pasteSelection() { selectedEditor?.textView.paste(nil) }

    private func handleFindPanelAction(_ action: FindPanelAction) {
        guard let editor = selectedEditor else { return }

        do {
            switch action {
            case .findNext(let query, let options):
                guard editor.selectMatch(query: query, options: options, forward: true) else { NSSound.beep(); return }
            case .findPrevious(let query, let options):
                guard editor.selectMatch(query: query, options: options, forward: false) else { NSSound.beep(); return }
            case .replace(let query, let replacement, let options):
                let replaced = try editor.replaceCurrentMatch(query: query, replacement: replacement, options: options)
                if !replaced { _ = editor.selectMatch(query: query, options: options, forward: true) }
            case .replaceAll(let query, let replacement, let options):
                let count = try editor.replaceAll(query: query, replacement: replacement, options: options)
                showMessage("Replace All", "Replaced \(count) match\(count == 1 ? "" : "es") in \(editor.document.displayName).")
            case .count(let query, let options):
                let count = try editor.matchCount(query: query, options: options)
                showMessage("Count", "Found \(count) match\(count == 1 ? "" : "es") in \(editor.document.displayName).")
            }
        } catch {
            showError(error)
        }
    }

    @objc func undo() {
        selectedEditor?.textView.undoManager?.undo()
    }

    @objc func redo() {
        selectedEditor?.textView.undoManager?.redo()
    }

    @objc func goToLine() {
        let alert = NSAlert()
        alert.messageText = "Go to Line"
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 220, height: 24))
        field.placeholderString = "Line number"
        alert.accessoryView = field
        alert.addButton(withTitle: "Go")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn,
              let line = Int(field.stringValue), line > 0,
              let editor = selectedEditor else { return }
        let text = editor.textView.string as NSString
        var currentLine = 1
        var index = 0
        while currentLine < line && index < text.length {
            let next = text.range(of: "\n", options: [], range: NSRange(location: index, length: text.length - index))
            if next.location == NSNotFound { break }
            currentLine += 1
            index = next.location + 1
        }
        editor.textView.setSelectedRange(NSRange(location: min(index, text.length), length: 0))
        editor.textView.scrollRangeToVisible(editor.textView.selectedRange())
    }

    @objc func zoomIn() {
        updateGlobalFontSize(textSettings.fontSize + 1)
    }

    @objc func zoomOut() {
        updateGlobalFontSize(textSettings.fontSize - 1)
    }

    @objc func resetZoom() {
        updateGlobalFontSize(13)
    }

    private func updateGlobalFontSize(_ size: Double) {
        var updatedSettings = textSettings
        updatedSettings.fontSize = min(max(size, 8), 48)
        applyTextSettings(updatedSettings)
    }

    @objc func toggleLineNumbers() {
        lineNumbersVisible.toggle()
        editors.forEach { $0.setLineNumbersVisible(lineNumbersVisible) }
    }

    @objc func toggleWordWrap() {
        selectedEditor?.toggleWordWrap()
    }

    @objc func toggleSmartHighlighting() {
        let enabled = !(selectedEditor?.smartHighlightingEnabled ?? true)
        editors.forEach { $0.smartHighlightingEnabled = enabled }
    }

    @objc func duplicateLine() { selectedEditor?.duplicateCurrentLine() }
    @objc func deleteLine() { selectedEditor?.deleteCurrentLine() }
    @objc func moveLineUp() { selectedEditor?.moveCurrentLineUp() }
    @objc func moveLineDown() { selectedEditor?.moveCurrentLineDown() }
    @objc func joinLines() { selectedEditor?.joinSelectedLines() }
    @objc func splitLine() { selectedEditor?.splitLineAtCursor() }
    @objc func trimTrailingWhitespace() { selectedEditor?.trimTrailingWhitespace() }
    @objc func uppercaseSelection() { selectedEditor?.transformSelection { $0.uppercased() } }
    @objc func lowercaseSelection() { selectedEditor?.transformSelection { $0.lowercased() } }

    @objc func setEncodingUTF8() { updateEncoding(.utf8, hasBOM: false) }
    @objc func setEncodingUTF8BOM() { updateEncoding(.utf8, hasBOM: true) }
    @objc func setEncodingUTF16LE() { updateEncoding(.utf16LittleEndian, hasBOM: true) }
    @objc func setEncodingUTF16BE() { updateEncoding(.utf16BigEndian, hasBOM: true) }
    @objc func setLineEndingLF() { updateLineEnding(.lf) }
    @objc func setLineEndingCRLF() { updateLineEnding(.crlf) }
    @objc func setLineEndingCR() { updateLineEnding(.cr) }

    @objc func setLanguagePlainText() { updateLanguage(.plainText) }
    @objc func setLanguageSwift() { updateLanguage(.swift) }
    @objc func setLanguagePython() { updateLanguage(.python) }
    @objc func setLanguageJavaScript() { updateLanguage(.javascript) }
    @objc func setLanguageJSON() { updateLanguage(.json) }
    @objc func setLanguageHTML() { updateLanguage(.html) }
    @objc func setLanguageCSS() { updateLanguage(.css) }
    @objc func setLanguageShell() { updateLanguage(.shell) }
    @objc func setLanguageMarkdown() { updateLanguage(.markdown) }
    @objc func setLanguageC() { updateLanguage(.c) }
    @objc func setLanguageCPP() { updateLanguage(.cpp) }
    @objc func setLanguageSQL() { updateLanguage(.sql) }

    private func updateEncoding(_ encoding: String.Encoding, hasBOM: Bool) {
        guard let editor = selectedEditor else { return }
        editor.document.encoding = encoding
        editor.document.hasBOM = hasBOM
        editor.document.isModified = true
        updateStatus(for: editor)
        scheduleSessionSave()
    }

    private func updateLineEnding(_ lineEnding: DocumentLineEnding) {
        guard let editor = selectedEditor else { return }
        editor.document.lineEnding = lineEnding
        editor.document.isModified = true
        updateStatus(for: editor)
        scheduleSessionSave()
    }

    private func updateLanguage(_ language: LanguageID) {
        guard let editor = selectedEditor else { return }
        editor.setLanguage(language)
        updateStatus(for: editor)
        scheduleSessionSave()
    }

    @objc func printDocument() {
        selectedEditor?.textView.printView(nil)
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MacPad"
        alert.informativeText = "Native macOS text editor\nEarly development build"
        alert.runModal()
    }

    @objc func showPreferences() {
        if let controller = textSettingsWindowController {
            controller.showWindow(self)
            controller.window?.makeKeyAndOrderFront(nil)
            return
        }

        let controller = TextSettingsWindowController(settings: textSettings)
        controller.onChange = { [weak self] settings in
            self?.applyTextSettings(settings)
        }
        controller.onDismiss = { [weak self] in
            self?.focusSelectedEditor()
        }
        textSettingsWindowController = controller
        controller.showWindow(self)
        controller.window?.center()
    }

    private func applyTextSettings(_ settings: TextSettings) {
        textSettings = settings
        textSettingsStore.save(settings)
        editors.forEach { $0.updateTextSettings(settings) }
    }

    private func focusSelectedEditor() {
        window?.makeKeyAndOrderFront(nil)
        selectedEditor?.focus()
    }

    @objc func showHelp() {
        let alert = NSAlert()
        alert.messageText = "MacPad Help"
        alert.informativeText = "Use File > Open to edit a file, or create a new tab with Command-N."
        alert.runModal()
    }

    private var selectedEditor: EditorViewController? {
        tabViewController.tabView.selectedTabViewItem?.viewController as? EditorViewController
    }

    private func updateTab(for editor: EditorViewController) {
        guard let index = editors.firstIndex(of: editor), index < tabViewController.tabViewItems.count else { return }
        tabViewController.tabViewItems[index].label = editor.document.title
        window?.title = "\(editor.document.title) — MacPad"
        refreshTabStrip()
    }

    private func updateStatus(for editor: EditorViewController) {
        let status = editor.status()
        statusFile.stringValue = editor.document.title
        statusLine.stringValue = "Ln \(status.line), Col \(status.column)"
        statusSelection.stringValue = status.selectionLength > 0 ? "Sel \(status.selectionLength)" : ""
        statusEncoding.stringValue = editor.document.hasBOM ? "\(encodingName(editor.document.encoding)) BOM" : encodingName(editor.document.encoding)
        statusEOL.stringValue = editor.document.lineEnding.displayName
        statusLanguage.stringValue = editor.document.language.displayName
        statusDisk.stringValue = editor.document.hasExternalChange ? "Changed on disk" : ""
        updateTab(for: editor)
    }

    private func encodingName(_ encoding: String.Encoding) -> String {
        switch encoding {
        case .utf8: return "UTF-8"
        case .utf16: return "UTF-16"
        case .utf16LittleEndian: return "UTF-16 LE"
        case .utf16BigEndian: return "UTF-16 BE"
        case .utf32LittleEndian: return "UTF-32 LE"
        case .utf32BigEndian: return "UTF-32 BE"
        case .ascii: return "ASCII"
        default: return "Encoding"
        }
    }

    private func showError(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }

    private func showMessage(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(toggleSmartHighlighting) {
            menuItem.state = (selectedEditor?.smartHighlightingEnabled ?? true) ? .on : .off
        }
        return true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Closing the main window is a session checkpoint, not a destructive
        // document close. Preserve every tab, including unsaved Untitled notes,
        // then terminate so reopening MacPad starts from the same session.
        persistSession()
        guard !isTerminatingFromWindowClose else { return true }
        isTerminatingFromWindowClose = true
        NSApp.terminate(nil)
        return false
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .newDocument, .openDocument, .saveDocument, .saveAllDocuments, .closeDocument, .printDocument,
            .undo, .redo, .cut, .copy, .paste,
            .findPanel, .findReplace, .zoomOut, .zoomReset, .zoomIn, .toggleWordWrap, .toggleLineNumbers,
            .flexibleSpace, .search
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .flexibleSpace,
            .newDocument, .openDocument, .saveDocument, .saveAllDocuments, .closeDocument, .printDocument,
            .undo, .redo, .cut, .copy, .paste,
            .findPanel, .findReplace, .zoomOut, .zoomReset, .zoomIn, .toggleWordWrap
        ]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .newDocument:
            return toolbarItem(identifier: itemIdentifier, label: "New", image: NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: "New document"), action: #selector(newDocument))
        case .openDocument:
            return toolbarItem(identifier: itemIdentifier, label: "Open", image: NSImage(systemSymbolName: "folder", accessibilityDescription: "Open document"), action: #selector(openDocument))
        case .saveDocument:
            return toolbarItem(identifier: itemIdentifier, label: "Save", image: NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: "Save document"), action: #selector(saveDocument))
        case .saveAllDocuments:
            return toolbarItem(identifier: itemIdentifier, label: "Save All", image: NSImage(systemSymbolName: "square.and.arrow.down.on.square", accessibilityDescription: "Save all documents"), action: #selector(saveAllDocuments))
        case .closeDocument:
            return toolbarItem(identifier: itemIdentifier, label: "Close", image: NSImage(systemSymbolName: "xmark.square", accessibilityDescription: "Close document"), action: #selector(closeDocument))
        case .printDocument:
            return toolbarItem(identifier: itemIdentifier, label: "Print", image: NSImage(systemSymbolName: "printer", accessibilityDescription: "Print document"), action: #selector(printDocument))
        case .undo:
            return toolbarItem(identifier: itemIdentifier, label: "Undo", image: NSImage(systemSymbolName: "arrow.uturn.backward", accessibilityDescription: "Undo"), action: #selector(undo))
        case .redo:
            return toolbarItem(identifier: itemIdentifier, label: "Redo", image: NSImage(systemSymbolName: "arrow.uturn.forward", accessibilityDescription: "Redo"), action: #selector(redo))
        case .cut:
            return toolbarItem(identifier: itemIdentifier, label: "Cut", image: NSImage(systemSymbolName: "scissors", accessibilityDescription: "Cut"), action: #selector(cutSelection))
        case .copy:
            return toolbarItem(identifier: itemIdentifier, label: "Copy", image: NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy"), action: #selector(copySelection))
        case .paste:
            return toolbarItem(identifier: itemIdentifier, label: "Paste", image: NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Paste"), action: #selector(pasteSelection))
        case .findPanel:
            return toolbarItem(identifier: itemIdentifier, label: "Search", image: NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "Search"), action: #selector(showFindPanel))
        case .findReplace:
            return toolbarItem(identifier: itemIdentifier, label: "Find & Replace", image: NSImage(systemSymbolName: "text.magnifyingglass", accessibilityDescription: "Find and replace"), action: #selector(showFindPanel))
        case .zoomOut:
            return toolbarItem(identifier: itemIdentifier, label: "Zoom Out", image: NSImage(systemSymbolName: "minus.magnifyingglass", accessibilityDescription: "Zoom out"), action: #selector(zoomOut))
        case .zoomReset:
            return toolbarItem(identifier: itemIdentifier, label: "Reset Zoom", image: NSImage(systemSymbolName: "1.magnifyingglass", accessibilityDescription: "Reset zoom"), action: #selector(resetZoom))
        case .zoomIn:
            return toolbarItem(identifier: itemIdentifier, label: "Zoom In", image: NSImage(systemSymbolName: "plus.magnifyingglass", accessibilityDescription: "Zoom in"), action: #selector(zoomIn))
        case .toggleWordWrap:
            return toolbarItem(identifier: itemIdentifier, label: "Word Wrap", image: NSImage(systemSymbolName: "text.word.spacing", accessibilityDescription: "Toggle word wrap"), action: #selector(toggleWordWrap))
        case .toggleLineNumbers:
            return toolbarItem(identifier: itemIdentifier, label: "Line Numbers", image: NSImage(systemSymbolName: "list.number", accessibilityDescription: "Toggle line numbers"), action: #selector(toggleLineNumbers))
        case .search:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            searchField.placeholderString = "Find"
            searchField.target = self
            searchField.action = #selector(findNext)
            searchField.delegate = self
            searchField.widthAnchor.constraint(equalToConstant: 220).isActive = true
            item.view = searchField
            item.label = "Find"
            item.paletteLabel = "Find"
            return item
        default:
            return nil
        }
    }

    private func toolbarItem(identifier: NSToolbarItem.Identifier, label: String, image: NSImage?, action: Selector) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: identifier)
        item.label = label
        item.paletteLabel = label
        // The custom tooltip controller provides a shorter hover delay.
        // Keep the label for accessibility and toolbar customization.
        item.toolTip = nil
        item.image = image
        item.target = self
        item.action = action

        if let image {
            let button = NSButton(image: image, target: self, action: action)
            button.bezelStyle = .toolbar
            button.setButtonType(.momentaryPushIn)
            button.isBordered = true
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
            button.toolTip = nil
            button.setAccessibilityLabel(label)
            button.setAccessibilityHelp("Click to \(label.lowercased())")
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 32).isActive = true
            item.view = button
        }
        return item
    }

    func controlTextDidChange(_ obj: Notification) {
        findNext()
    }
}

private extension NSToolbarItem.Identifier {
    static let newDocument = NSToolbarItem.Identifier("new-document")
    static let openDocument = NSToolbarItem.Identifier("open-document")
    static let saveDocument = NSToolbarItem.Identifier("save-document")
    static let saveAllDocuments = NSToolbarItem.Identifier("save-all-documents")
    static let closeDocument = NSToolbarItem.Identifier("close-document")
    static let printDocument = NSToolbarItem.Identifier("print-document")
    static let undo = NSToolbarItem.Identifier("undo")
    static let redo = NSToolbarItem.Identifier("redo")
    static let cut = NSToolbarItem.Identifier("cut")
    static let copy = NSToolbarItem.Identifier("copy")
    static let paste = NSToolbarItem.Identifier("paste")
    static let findPanel = NSToolbarItem.Identifier("find-panel")
    static let findReplace = NSToolbarItem.Identifier("find-replace")
    static let zoomOut = NSToolbarItem.Identifier("zoom-out")
    static let zoomReset = NSToolbarItem.Identifier("zoom-reset")
    static let zoomIn = NSToolbarItem.Identifier("zoom-in")
    static let toggleWordWrap = NSToolbarItem.Identifier("toggle-word-wrap")
    static let toggleLineNumbers = NSToolbarItem.Identifier("toggle-line-numbers")
    static let search = NSToolbarItem.Identifier("search")
}
