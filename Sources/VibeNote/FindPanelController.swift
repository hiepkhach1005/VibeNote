import AppKit

enum FindPanelAction {
    case findNext(query: String, options: SearchOptions)
    case findPrevious(query: String, options: SearchOptions)
    case replace(query: String, replacement: String, options: SearchOptions)
    case replaceAll(query: String, replacement: String, options: SearchOptions)
    case count(query: String, options: SearchOptions)
}

final class FindPanelController: NSWindowController, NSTextFieldDelegate {
    private let findField = NSSearchField()
    private let replacementField = NSTextField()
    private let modePopup = NSPopUpButton()
    private let caseSensitiveButton = NSButton(checkboxWithTitle: "Match case", target: nil, action: nil)
    private let wholeWordButton = NSButton(checkboxWithTitle: "Whole word", target: nil, action: nil)
    private let wrapAroundButton = NSButton(checkboxWithTitle: "Wrap around", target: nil, action: nil)
    private let onAction: (FindPanelAction) -> Void

    init(onAction: @escaping (FindPanelAction) -> Void) {
        self.onAction = onAction
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 220),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        super.init(window: panel)
        panel.title = "Find and Replace"
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = false
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func focusFindField() {
        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(findField)
        findField.selectText(nil)
    }

    private func configure() {
        guard let contentView = window?.contentView else { return }

        findField.placeholderString = "Find"
        findField.setAccessibilityLabel("Find text")
        replacementField.placeholderString = "Replace with"
        replacementField.setAccessibilityLabel("Replacement text")
        modePopup.addItems(withTitles: SearchMode.allCases.map(\.displayName))
        modePopup.selectItem(at: 0)
        wrapAroundButton.state = .on

        let findRow = row(label: "Find:", control: findField)
        let replaceRow = row(label: "Replace:", control: replacementField)
        let modeRow = row(label: "Mode:", control: modePopup)

        let options = NSStackView(views: [caseSensitiveButton, wholeWordButton, wrapAroundButton])
        options.orientation = .horizontal
        options.spacing = 12

        let findNext = button("Find Next", action: #selector(findNext))
        let findPrevious = button("Find Previous", action: #selector(findPrevious))
        let replace = button("Replace", action: #selector(replace))
        let replaceAll = button("Replace All", action: #selector(replaceAll))
        let count = button("Count", action: #selector(count))
        let buttons = NSStackView(views: [findPrevious, findNext, replace, replaceAll, count])
        buttons.orientation = .horizontal
        buttons.alignment = .centerY
        buttons.distribution = .fillEqually
        buttons.spacing = 8

        let stack = NSStackView(views: [findRow, replaceRow, modeRow, options, buttons])
        stack.orientation = .vertical
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            findField.widthAnchor.constraint(greaterThanOrEqualToConstant: 260),
            replacementField.widthAnchor.constraint(greaterThanOrEqualToConstant: 260)
        ])
    }

    private func row(label: String, control: NSView) -> NSStackView {
        let labelField = NSTextField(labelWithString: label)
        labelField.alignment = .right
        labelField.setContentHuggingPriority(.required, for: .horizontal)
        labelField.widthAnchor.constraint(equalToConstant: 66).isActive = true
        let row = NSStackView(views: [labelField, control])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 8
        return row
    }

    private func button(_ title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    private func options() -> SearchOptions {
        SearchOptions(
            mode: SearchMode.allCases[modePopup.indexOfSelectedItem],
            caseSensitive: caseSensitiveButton.state == .on,
            wholeWord: wholeWordButton.state == .on,
            wrapAround: wrapAroundButton.state == .on
        )
    }

    private var query: String { findField.stringValue }
    private var replacement: String { replacementField.stringValue }

    @objc private func findNext() {
        onAction(.findNext(query: query, options: options()))
    }

    @objc private func findPrevious() {
        onAction(.findPrevious(query: query, options: options()))
    }

    @objc private func replace() {
        onAction(.replace(query: query, replacement: replacement, options: options()))
    }

    @objc private func replaceAll() {
        onAction(.replaceAll(query: query, replacement: replacement, options: options()))
    }

    @objc private func count() {
        onAction(.count(query: query, options: options()))
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            findNext()
            return true
        }
        return false
    }
}
