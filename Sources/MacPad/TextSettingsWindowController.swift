import AppKit

final class TextSettingsWindowController: NSWindowController, NSWindowDelegate {
    var onChange: ((TextSettings) -> Void)?
    var onDismiss: (() -> Void)?

    private var settings: TextSettings
    private let themePopup = NSPopUpButton()
    private let fontPopup = NSPopUpButton()
    private let sizeField = NSTextField()
    private let sizeStepper = NSStepper()
    private var colorWells: [TextColorRole: NSColorWell] = [:]

    init(settings: TextSettings) {
        self.settings = settings
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 660, height: 720),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Text Settings"
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        buildInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildInterface() {
        guard let window else { return }

        let root = NSView()
        root.wantsLayer = true
        window.contentView = root

        let header = NSVisualEffectView()
        header.material = .headerView
        header.blendingMode = .withinWindow
        header.state = .followsWindowActiveState
        header.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(header)

        let title = NSTextField(labelWithString: "Text Appearance")
        title.font = NSFont.systemFont(ofSize: 20, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)

        let subtitle = NSTextField(labelWithString: "Choose the editor font, size, colors and syntax theme.")
        subtitle.textColor = .secondaryLabelColor
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(subtitle)

        let body = NSStackView()
        body.orientation = .vertical
        body.alignment = .leading
        body.spacing = 10
        body.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(body)

        themePopup.target = self
        themePopup.action = #selector(themeChanged(_:))
        themePopup.addItems(withTitles: TextThemeID.allCases.map(\.displayName))
        body.addArrangedSubview(row(label: "Theme", control: themePopup))

        fontPopup.target = self
        fontPopup.action = #selector(fontChanged(_:))
        fontPopup.addItems(withTitles: fontFamilyNames())
        body.addArrangedSubview(row(label: "Font", control: fontPopup))

        sizeField.alignment = .right
        let sizeFormatter = NumberFormatter()
        sizeFormatter.minimum = 8
        sizeFormatter.maximum = 48
        sizeField.formatter = sizeFormatter
        sizeField.widthAnchor.constraint(equalToConstant: 72).isActive = true
        sizeField.target = self
        sizeField.action = #selector(sizeChanged(_:))

        sizeStepper.minValue = 8
        sizeStepper.maxValue = 48
        sizeStepper.increment = 1
        sizeStepper.widthAnchor.constraint(equalToConstant: 24).isActive = true
        sizeStepper.target = self
        sizeStepper.action = #selector(sizeChanged(_:))
        let sizeControls = NSStackView(views: [sizeField, sizeStepper])
        sizeControls.orientation = .horizontal
        sizeControls.spacing = 6
        body.addArrangedSubview(row(label: "Font Size", control: sizeControls))

        body.addArrangedSubview(separator())
        body.addArrangedSubview(sectionLabel("Editor Colors"))
        for role in TextColorRole.allCases {
            let well = NSColorWell()
            well.target = self
            well.action = #selector(colorChanged(_:))
            well.widthAnchor.constraint(equalToConstant: 62).isActive = true
            well.setAccessibilityLabel(role.displayName)
            colorWells[role] = well
            body.addArrangedSubview(row(label: role.displayName, control: well))
        }

        body.addArrangedSubview(separator())
        let reset = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetSettings))
        reset.bezelStyle = .rounded
        let done = NSButton(title: "Done", target: self, action: #selector(closeSettings))
        done.bezelStyle = .rounded
        done.keyEquivalent = "\r"
        let buttons = NSStackView(views: [reset, NSView(), done])
        buttons.orientation = .horizontal
        buttons.spacing = 10
        buttons.distribution = .fill
        buttons.widthAnchor.constraint(equalToConstant: 620).isActive = true
        body.addArrangedSubview(buttons)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            header.topAnchor.constraint(equalTo: root.topAnchor),
            header.heightAnchor.constraint(equalToConstant: 78),
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            title.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            body.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 22),
            body.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -18),
            body.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            body.bottomAnchor.constraint(lessThanOrEqualTo: root.bottomAnchor, constant: -18)
        ])

        reloadControls()
    }

    private func row(label: String, control: NSView) -> NSStackView {
        let labelField = NSTextField(labelWithString: label)
        labelField.widthAnchor.constraint(equalToConstant: 155).isActive = true
        labelField.setContentHuggingPriority(.required, for: .horizontal)
        control.setContentHuggingPriority(.required, for: .horizontal)

        let row = NSStackView(views: [labelField, control])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 12
        row.widthAnchor.constraint(equalToConstant: 620).isActive = true
        return row
    }

    private func sectionLabel(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabelColor
        return label
    }

    private func separator() -> NSBox {
        let box = NSBox()
        box.boxType = .separator
        box.widthAnchor.constraint(equalToConstant: 620).isActive = true
        return box
    }

    private func fontFamilyNames() -> [String] {
        let preferred = ["System Monospaced", "Menlo", "SF Mono", "Monaco", "Courier New"]
        let available = NSFontManager.shared.availableFontFamilies.sorted()
        var names = preferred
        names.append(contentsOf: available.filter { !names.contains($0) })
        return names
    }

    private func reloadControls() {
        themePopup.selectItem(withTitle: settings.theme.displayName)
        if fontPopup.item(withTitle: settings.fontFamily) == nil {
            fontPopup.insertItem(withTitle: settings.fontFamily, at: 0)
        }
        fontPopup.selectItem(withTitle: settings.fontFamily)
        sizeField.doubleValue = settings.fontSize
        sizeStepper.doubleValue = settings.fontSize

        let palette = settings.palette(for: window?.effectiveAppearance)
        for role in TextColorRole.allCases {
            colorWells[role]?.color = palette.color(for: role)
        }
    }

    @objc private func themeChanged(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem,
              let theme = TextThemeID.allCases.first(where: { $0.displayName == title }) else { return }
        settings.applyTheme(theme)
        reloadControls()
        onChange?(settings)
    }

    @objc private func fontChanged(_ sender: NSPopUpButton) {
        guard let fontFamily = sender.titleOfSelectedItem else { return }
        settings.fontFamily = fontFamily
        onChange?(settings)
    }

    @objc private func sizeChanged(_ sender: Any) {
        let value = sender is NSStepper ? sizeStepper.doubleValue : sizeField.doubleValue
        let clamped = min(max(value, 8), 48)
        settings.fontSize = clamped
        sizeField.doubleValue = clamped
        sizeStepper.doubleValue = clamped
        onChange?(settings)
    }

    @objc private func colorChanged(_ sender: NSColorWell) {
        guard let role = colorWells.first(where: { $0.value === sender })?.key else { return }
        settings.setColor(sender.color, for: role, appearance: window?.effectiveAppearance)
        themePopup.selectItem(withTitle: TextThemeID.custom.displayName)
        reloadControls()
        onChange?(settings)
    }

    @objc private func resetSettings() {
        settings = TextSettings()
        reloadControls()
        onChange?(settings)
    }

    @objc private func closeSettings() {
        window?.performClose(nil)
    }

    func windowWillClose(_ notification: Notification) {
        onDismiss?()
    }
}
