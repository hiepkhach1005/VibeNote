import AppKit

private final class VibeNoteAppearanceView: FileDropView {
    var onAppearanceChange: (() -> Void)?

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        onAppearanceChange?()
    }
}

final class EditorViewController: NSViewController, NSTextViewDelegate {
    let document: EditorDocument
    private let scrollView: NSScrollView
    let textView: FileDropTextView
    private var lineNumberRuler: LineNumberRulerView!
    private var lineNumberWidthConstraint: NSLayoutConstraint!
    private var isReplacingContent = false
    private var wordWrapEnabled = true
    private var highlightedOccurrenceRanges: [NSRange] = []
    private(set) var textSettings = TextSettings()

    var smartHighlightingEnabled = true {
        didSet { updateSmartHighlighting() }
    }

    var onDocumentChange: ((EditorViewController) -> Void)?
    var onSelectionChange: ((EditorViewController) -> Void)?
    var onOpenDroppedFiles: (([URL]) -> Void)?

    init(document: EditorDocument) {
        let scrollView = FileDropTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? FileDropTextView else {
            fatalError("NSTextView.scrollableTextView() did not provide an NSTextView")
        }
        self.document = document
        self.scrollView = scrollView
        self.textView = textView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        let editorView = VibeNoteAppearanceView()
        editorView.onAppearanceChange = { [weak self] in
            self?.applyTextSettings()
        }
        editorView.onDropFiles = { [weak self] urls in
            self?.onOpenDroppedFiles?(urls)
        }
        view = editorView

        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.alphaValue = 1
        textView.drawsBackground = true
        textView.usesAdaptiveColorMappingForDarkAppearance = false
        textView.usesFindPanel = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.delegate = self
        textView.registerForDraggedTypes([.fileURL, FileDropPayload.legacyFileNamesType])
        textView.onDropFiles = { [weak self] urls in
            self?.onOpenDroppedFiles?(urls)
        }

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        lineNumberRuler = LineNumberRulerView(textView: textView)
        lineNumberRuler.translatesAutoresizingMaskIntoConstraints = false
        lineNumberWidthConstraint = lineNumberRuler.widthAnchor.constraint(equalToConstant: 46)
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewBoundsDidChange),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )

        view.addSubview(lineNumberRuler)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            lineNumberRuler.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineNumberRuler.topAnchor.constraint(equalTo: view.topAnchor),
            lineNumberRuler.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lineNumberWidthConstraint,
            scrollView.leadingAnchor.constraint(equalTo: lineNumberRuler.trailingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        textView.string = document.content
        configureTextContainer()
        applyTextSettings()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        configureTextContainer()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        focus()
    }

    func focus() {
        guard let window = textView.window else { return }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textView)
    }

    func textDidChange(_ notification: Notification) {
        guard !isReplacingContent else { return }
        document.content = textView.string
        document.isModified = true
        applySyntaxHighlighting()
        applyTypingAttributes()
        updateSmartHighlighting()
        lineNumberRuler.needsDisplay = true
        onDocumentChange?(self)
    }

    func replaceContent(_ content: String, markModified: Bool = false) {
        isReplacingContent = true
        textView.string = content
        isReplacingContent = false
        document.content = content
        document.isModified = markModified
        textView.setSelectedRange(NSRange(location: 0, length: 0))
        applySyntaxHighlighting()
        applyTypingAttributes()
        updateSmartHighlighting()
        lineNumberRuler.needsDisplay = true
        onDocumentChange?(self)
        onSelectionChange?(self)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        updateSmartHighlighting()
        onSelectionChange?(self)
    }

    func selectNextMatch(_ query: String) -> Bool {
        selectMatch(query: query, options: SearchOptions(), forward: true)
    }

    func selectPreviousMatch(_ query: String) -> Bool {
        selectMatch(query: query, options: SearchOptions(), forward: false)
    }

    func selectMatch(query: String, options: SearchOptions, forward: Bool) -> Bool {
        do {
            let ranges = try SearchEngine.matches(in: textView.string, query: query, options: options)
            guard !ranges.isEmpty else { return false }

            let selection = textView.selectedRange()
            let result: NSRange?
            if forward {
                let start = NSMaxRange(selection)
                result = ranges.first(where: { $0.location >= start }) ?? (options.wrapAround ? ranges.first : nil)
            } else {
                let end = selection.location
                result = ranges.last(where: { NSMaxRange($0) <= end }) ?? (options.wrapAround ? ranges.last : nil)
            }

            guard let result else { return false }
            textView.setSelectedRange(result)
            textView.scrollRangeToVisible(result)
            return true
        } catch {
            return false
        }
    }

    func replaceCurrentMatch(query: String, replacement: String, options: SearchOptions) throws -> Bool {
        let ranges = try SearchEngine.matches(in: textView.string, query: query, options: options)
        let selection = textView.selectedRange()
        guard ranges.contains(where: { $0 == selection }) else { return false }
        applyTextEdit(in: selection, replacement: replacement, selectedRange: NSRange(location: selection.location, length: (replacement as NSString).length))
        return true
    }

    @discardableResult
    func replaceAll(query: String, replacement: String, options: SearchOptions) throws -> Int {
        let result = try SearchEngine.replacing(in: textView.string, query: query, replacement: replacement, options: options)
        guard result.count > 0 else { return 0 }
        applyTextEdit(in: NSRange(location: 0, length: (textView.string as NSString).length), replacement: result.text, selectedRange: NSRange(location: 0, length: 0))
        return result.count
    }

    func matchCount(query: String, options: SearchOptions) throws -> Int {
        try SearchEngine.matches(in: textView.string, query: query, options: options).count
    }

    func toggleWordWrap() {
        wordWrapEnabled.toggle()
        scrollView.hasHorizontalScroller = !wordWrapEnabled
        configureTextContainer()
        textView.invalidateIntrinsicContentSize()
        view.layoutSubtreeIfNeeded()
    }

    func setLanguage(_ language: LanguageID) {
        document.language = language
        applySyntaxHighlighting()
        updateSmartHighlighting()
        onDocumentChange?(self)
    }

    func duplicateCurrentLine() {
        let range = lineRange(for: textView.selectedRange())
        guard range.length > 0 else { return }
        let line = (textView.string as NSString).substring(with: range)
        let insertion = line.hasSuffix("\n") ? line : "\n" + line
        applyTextEdit(in: NSRange(location: NSMaxRange(range), length: 0), replacement: insertion, selectedRange: NSRange(location: NSMaxRange(range), length: 0))
    }

    func deleteCurrentLine() {
        let text = textView.string as NSString
        let range = lineRange(for: textView.selectedRange())
        guard range.length > 0 || text.length > 0 else { return }
        if NSMaxRange(range) < text.length {
            applyTextEdit(in: range, replacement: "", selectedRange: NSRange(location: min(range.location, text.length), length: 0))
        } else if range.location > 0 {
            applyTextEdit(in: NSRange(location: range.location - 1, length: range.length + 1), replacement: "", selectedRange: NSRange(location: range.location - 1, length: 0))
        } else {
            applyTextEdit(in: range, replacement: "", selectedRange: NSRange(location: 0, length: 0))
        }
    }

    func moveCurrentLineUp() {
        let text = textView.string as NSString
        let current = lineRange(for: textView.selectedRange())
        guard current.location > 0 else { return }
        let previous = lineRange(at: current.location - 1)
        let previousText = text.substring(with: previous).trimmingCharacters(in: .newlines)
        let currentText = text.substring(with: current).trimmingCharacters(in: .newlines)
        let hasTerminator = text.substring(with: NSRange(location: previous.location, length: NSMaxRange(current) - previous.location)).hasSuffix("\n")
        let replacement = currentText + "\n" + previousText + (hasTerminator ? "\n" : "")
        let selected = NSRange(location: previous.location, length: (currentText as NSString).length)
        applyTextEdit(in: NSRange(location: previous.location, length: NSMaxRange(current) - previous.location), replacement: replacement, selectedRange: selected)
    }

    func moveCurrentLineDown() {
        let text = textView.string as NSString
        let current = lineRange(for: textView.selectedRange())
        guard NSMaxRange(current) < text.length else { return }
        let next = lineRange(at: NSMaxRange(current))
        let currentText = text.substring(with: current).trimmingCharacters(in: .newlines)
        let nextText = text.substring(with: next).trimmingCharacters(in: .newlines)
        let hasTerminator = text.substring(with: NSRange(location: current.location, length: NSMaxRange(next) - current.location)).hasSuffix("\n")
        let replacement = nextText + "\n" + currentText + (hasTerminator ? "\n" : "")
        let selected = NSRange(location: current.location + (nextText as NSString).length + 1, length: (currentText as NSString).length)
        applyTextEdit(in: NSRange(location: current.location, length: NSMaxRange(next) - current.location), replacement: replacement, selectedRange: selected)
    }

    func joinSelectedLines() {
        let range = lineRange(for: textView.selectedRange())
        guard range.length > 0 else { return }
        let lineText = (textView.string as NSString).substring(with: range)
        let joined = lineText.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\r", with: " ")
        applyTextEdit(in: range, replacement: joined, selectedRange: NSRange(location: range.location, length: (joined as NSString).length))
    }

    func splitLineAtCursor() {
        let location = textView.selectedRange().location
        applyTextEdit(in: NSRange(location: location, length: 0), replacement: "\n", selectedRange: NSRange(location: location + 1, length: 0))
    }

    func trimTrailingWhitespace() {
        let text = textView.string as NSString
        let target = textView.selectedRange().length > 0 ? lineRange(for: textView.selectedRange()) : NSRange(location: 0, length: text.length)
        guard let expression = try? NSRegularExpression(pattern: "[ \\t]+(?=\\n|$)") else { return }
        let ranges = expression.matches(in: text as String, options: [], range: target).map(\.range)
        for range in ranges.reversed() {
            applyTextEdit(in: range, replacement: "", selectedRange: NSRange(location: range.location, length: 0))
        }
    }

    func transformSelection(_ transform: (String) -> String) {
        let range = textView.selectedRange()
        guard range.length > 0 else { return }
        let selected = (textView.string as NSString).substring(with: range)
        let transformed = transform(selected)
        applyTextEdit(in: range, replacement: transformed, selectedRange: NSRange(location: range.location, length: (transformed as NSString).length))
    }

    private func lineRange(for selection: NSRange) -> NSRange {
        let text = textView.string as NSString
        guard text.length > 0 else { return NSRange(location: 0, length: 0) }
        let start = lineRange(at: min(selection.location, text.length)).location
        let endLocation = selection.length > 0 ? min(max(selection.location, NSMaxRange(selection) - 1), text.length) : min(selection.location, text.length)
        let end = NSMaxRange(lineRange(at: endLocation))
        return NSRange(location: start, length: max(0, end - start))
    }

    private func lineRange(at location: Int) -> NSRange {
        let text = textView.string as NSString
        let clamped = min(max(location, 0), text.length)
        var start = 0
        var end = 0
        var contentsEnd = 0
        text.getLineStart(&start, end: &end, contentsEnd: &contentsEnd, for: NSRange(location: clamped, length: 0))
        return NSRange(location: start, length: end - start)
    }

    private func applyTextEdit(in range: NSRange, replacement: String, selectedRange: NSRange) {
        guard textView.shouldChangeText(in: range, replacementString: replacement) else { return }
        isReplacingContent = true
        textView.textStorage?.replaceCharacters(in: range, with: replacement)
        textView.didChangeText()
        isReplacingContent = false
        document.content = textView.string
        document.isModified = true
        applyTypingAttributes()
        textView.setSelectedRange(NSRange(location: min(selectedRange.location, (textView.string as NSString).length), length: min(selectedRange.length, max(0, (textView.string as NSString).length - selectedRange.location))))
        updateSmartHighlighting()
        lineNumberRuler.needsDisplay = true
        onDocumentChange?(self)
        onSelectionChange?(self)
    }

    func setFontSize(_ size: CGFloat) {
        let clampedSize = min(max(size, 8), 48)
        var updatedSettings = textSettings
        updatedSettings.fontSize = Double(clampedSize)
        updateTextSettings(updatedSettings)
        lineNumberRuler.needsDisplay = true
    }

    func currentFontSize() -> CGFloat {
        CGFloat(textSettings.fontSize)
    }

    func updateTextSettings(_ settings: TextSettings) {
        textSettings = settings
        applyTextSettings()
    }

    func setLineNumbersVisible(_ visible: Bool) {
        lineNumberRuler.isHidden = !visible
        lineNumberWidthConstraint.constant = visible ? 46 : 0
        view.layoutSubtreeIfNeeded()
        configureTextContainer()
    }

    @objc private func scrollViewBoundsDidChange(_ notification: Notification) {
        lineNumberRuler.needsDisplay = true
    }

    private func applySyntaxHighlighting() {
        guard isViewLoaded, let textStorage = textView.textStorage else { return }
        SyntaxHighlighter.apply(
            to: textStorage,
            language: document.language,
            font: textView.font ?? textSettings.font(),
            colors: textSettings.styleColors(for: textView.effectiveAppearance)
        )
    }

    private func applyTextSettings() {
        guard isViewLoaded else { return }
        let colors = textSettings.styleColors(for: textView.effectiveAppearance)
        let font = textSettings.font()
        let foreground = colors.foreground.withAlphaComponent(1)
        let background = colors.background.withAlphaComponent(1)

        // The app chrome follows macOS, while editor themes may intentionally
        // use the opposite appearance (for example Dracula in Light Mode).
        // Give AppKit the appearance that matches the editor surface so it
        // does not adapt light glyphs as if they were drawn on a light canvas.
        textView.appearance = NSAppearance(
            named: background.relativeLuminance < 0.5 ? .darkAqua : .aqua
        )
        lineNumberRuler?.appearance = textView.appearance

        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.font = font
        textView.textColor = foreground
        textView.backgroundColor = background
        textView.insertionPointColor = foreground
        applyTypingAttributes(font: font, foreground: foreground)
        textView.selectedTextAttributes = [
            .backgroundColor: colors.selection,
            .foregroundColor: foreground
        ]
        applySyntaxHighlighting()
        updateSmartHighlighting()
        if let layoutManager = textView.layoutManager,
           let textStorage = textView.textStorage,
           let textContainer = textView.textContainer {
            let fullRange = NSRange(location: 0, length: textStorage.length)
            if fullRange.length > 0 {
                layoutManager.invalidateDisplay(forCharacterRange: fullRange)
                layoutManager.ensureLayout(for: textContainer)
            }
        }
        textView.needsDisplay = true
    }

    private func applyTypingAttributes() {
        let colors = textSettings.styleColors(for: textView.effectiveAppearance)
        applyTypingAttributes(
            font: textSettings.font(),
            foreground: colors.foreground.withAlphaComponent(1)
        )
    }

    private func applyTypingAttributes(font: NSFont, foreground: NSColor) {
        // NSTextView can keep an old typing dictionary after a theme change.
        // Setting textColor alone does not reliably replace that dictionary,
        // so new characters could inherit an invisible white/transparent color.
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: foreground
        ]
    }

    private func configureTextContainer() {
        guard isViewLoaded, let textContainer = textView.textContainer else { return }

        let viewport = scrollView.contentSize
        let availableWidth = max(viewport.width, 1)
        let availableHeight = max(viewport.height, 1)

        textView.isHorizontallyResizable = !wordWrapEnabled
        textView.autoresizingMask = wordWrapEnabled ? [.width] : []
        textContainer.widthTracksTextView = wordWrapEnabled
        textContainer.heightTracksTextView = false
        textContainer.containerSize = NSSize(
            width: wordWrapEnabled ? availableWidth : CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        var frame = textView.frame
        frame.size.width = wordWrapEnabled ? availableWidth : max(frame.width, availableWidth)
        frame.size.height = max(frame.height, availableHeight)
        textView.frame = frame

        if let layoutManager = textView.layoutManager {
            layoutManager.ensureLayout(for: textContainer)
        }
        textView.needsDisplay = true
        lineNumberRuler?.needsDisplay = true
    }


    private func updateSmartHighlighting() {
        guard isViewLoaded, let layoutManager = textView.layoutManager else { return }

        let textRange = NSRange(location: 0, length: (textView.string as NSString).length)
        for previousRange in highlightedOccurrenceRanges {
            let clippedRange = NSIntersectionRange(previousRange, textRange)
            if clippedRange.length > 0 {
                layoutManager.removeTemporaryAttribute(.backgroundColor, forCharacterRange: clippedRange)
            }
        }
        highlightedOccurrenceRanges.removeAll(keepingCapacity: true)

        guard smartHighlightingEnabled else {
            textView.needsDisplay = true
            return
        }

        let ranges = OccurrenceHighlighter.ranges(
            in: textView.string,
            selectedRange: textView.selectedRange()
        )
        for range in ranges {
            layoutManager.addTemporaryAttribute(
                .backgroundColor,
                value: textSettings.styleColors(for: textView.effectiveAppearance).occurrence,
                forCharacterRange: range
            )
        }
        highlightedOccurrenceRanges = ranges
        textView.needsDisplay = true
    }

    func status() -> (line: Int, column: Int, selectionLength: Int) {
        let string = textView.string as NSString
        let location = min(textView.selectedRange().location, string.length)
        let prefix = string.substring(to: location) as NSString
        let line = prefix.components(separatedBy: "\n").count
        let lastBreak = prefix.range(of: "\n", options: .backwards)
        let lineStart = lastBreak.location == NSNotFound ? 0 : lastBreak.location + 1
        let column = location - lineStart + 1
        return (line, column, textView.selectedRange().length)
    }
}
