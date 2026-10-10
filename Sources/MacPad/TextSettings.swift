import AppKit

enum TextColorRole: CaseIterable, Hashable {
    case foreground
    case background
    case selection
    case occurrence
    case comment
    case string
    case number
    case keyword
    case heading

    var displayName: String {
        switch self {
        case .foreground: return "Text"
        case .background: return "Editor Background"
        case .selection: return "Selection"
        case .occurrence: return "Smart Highlighting"
        case .comment: return "Comments"
        case .string: return "Strings"
        case .number: return "Numbers"
        case .keyword: return "Keywords"
        case .heading: return "Headings"
        }
    }
}

struct TextStyleColors {
    let foreground: NSColor
    let background: NSColor
    let selection: NSColor
    let occurrence: NSColor
    let comment: NSColor
    let string: NSColor
    let number: NSColor
    let keyword: NSColor
    let heading: NSColor
}

struct TextPalette: Codable, Equatable {
    var foreground: String
    var background: String
    var selection: String
    var occurrence: String
    var comment: String
    var string: String
    var number: String
    var keyword: String
    var heading: String

    func styleColors() -> TextStyleColors {
        let backgroundColor = NSColor(macPadHex: background)
        let fallbackForeground = readableFallback(for: backgroundColor)
        return TextStyleColors(
            foreground: readableTextColor(NSColor(macPadHex: foreground), on: backgroundColor, fallback: fallbackForeground),
            background: backgroundColor,
            selection: NSColor(macPadHex: selection),
            occurrence: NSColor(macPadHex: occurrence).withAlphaComponent(0.58),
            comment: readableTextColor(NSColor(macPadHex: comment), on: backgroundColor, fallback: fallbackForeground),
            string: readableTextColor(NSColor(macPadHex: string), on: backgroundColor, fallback: fallbackForeground),
            number: readableTextColor(NSColor(macPadHex: number), on: backgroundColor, fallback: fallbackForeground),
            keyword: readableTextColor(NSColor(macPadHex: keyword), on: backgroundColor, fallback: fallbackForeground),
            heading: readableTextColor(NSColor(macPadHex: heading), on: backgroundColor, fallback: fallbackForeground)
        )
    }

    mutating func ensureReadableContrast() {
        let backgroundColor = NSColor(macPadHex: background)
        let fallbackForeground = readableFallback(for: backgroundColor)
        foreground = readableTextColor(NSColor(macPadHex: foreground), on: backgroundColor, fallback: fallbackForeground).macPadHex
        comment = readableTextColor(NSColor(macPadHex: comment), on: backgroundColor, fallback: fallbackForeground).macPadHex
        string = readableTextColor(NSColor(macPadHex: string), on: backgroundColor, fallback: fallbackForeground).macPadHex
        number = readableTextColor(NSColor(macPadHex: number), on: backgroundColor, fallback: fallbackForeground).macPadHex
        keyword = readableTextColor(NSColor(macPadHex: keyword), on: backgroundColor, fallback: fallbackForeground).macPadHex
        heading = readableTextColor(NSColor(macPadHex: heading), on: backgroundColor, fallback: fallbackForeground).macPadHex
    }

    func color(for role: TextColorRole) -> NSColor {
        switch role {
        case .foreground: return NSColor(macPadHex: foreground)
        case .background: return NSColor(macPadHex: background)
        case .selection: return NSColor(macPadHex: selection)
        case .occurrence: return NSColor(macPadHex: occurrence)
        case .comment: return NSColor(macPadHex: comment)
        case .string: return NSColor(macPadHex: string)
        case .number: return NSColor(macPadHex: number)
        case .keyword: return NSColor(macPadHex: keyword)
        case .heading: return NSColor(macPadHex: heading)
        }
    }

    mutating func setColor(_ color: NSColor, for role: TextColorRole) {
        let hex = color.macPadHex
        switch role {
        case .foreground: foreground = hex
        case .background: background = hex
        case .selection: selection = hex
        case .occurrence: occurrence = hex
        case .comment: comment = hex
        case .string: string = hex
        case .number: number = hex
        case .keyword: keyword = hex
        case .heading: heading = hex
        }
        ensureReadableContrast()
    }

    static let systemLight = TextPalette(
        foreground: "#111827",
        background: "#FFFFFF",
        selection: "#BFD3FF",
        occurrence: "#FACC15",
        comment: "#166534",
        string: "#B42318",
        number: "#B54708",
        keyword: "#1D4ED8",
        heading: "#6D28D9"
    )

    static let systemDark = TextPalette(
        foreground: "#F9FAFB",
        background: "#181A20",
        selection: "#2F5DA8",
        occurrence: "#FACC15",
        comment: "#86EFAC",
        string: "#FF8A80",
        number: "#FFB454",
        keyword: "#93C5FD",
        heading: "#D8B4FE"
    )

    // Explicit Light/Dark presets intentionally use the same clean editor
    // surfaces in both appearances. MacPad System remains adaptive.
    static let light = TextPalette(
        foreground: "#111827",
        background: "#FFFFFF",
        selection: "#C7D2FE",
        occurrence: "#FDE047",
        comment: "#166534",
        string: "#B42318",
        number: "#B54708",
        keyword: "#1D4ED8",
        heading: "#6D28D9"
    )

    static let dark = TextPalette(
        foreground: "#F8FAFC",
        background: "#171A21",
        selection: "#334C73",
        occurrence: "#EAB308",
        comment: "#86EFAC",
        string: "#FDA4AF",
        number: "#FDBA74",
        keyword: "#93C5FD",
        heading: "#D8B4FE"
    )

    static let dracula = TextPalette(
        foreground: "#F8F8F2",
        background: "#282A36",
        selection: "#44475A",
        occurrence: "#6272A4",
        comment: "#6272A4",
        string: "#50FA7B",
        number: "#FFB86C",
        keyword: "#BD93F9",
        heading: "#8BE9FD"
    )

    static let nord = TextPalette(
        foreground: "#D8DEE9",
        background: "#2E3440",
        selection: "#434C5E",
        occurrence: "#4C566A",
        comment: "#A3BE8C",
        string: "#A3BE8C",
        number: "#D08770",
        keyword: "#81A1C1",
        heading: "#88C0D0"
    )

    static let solarizedLight = TextPalette(
        foreground: "#657B83",
        background: "#FDF6E3",
        selection: "#EEE8D5",
        occurrence: "#B58900",
        comment: "#93A1A1",
        string: "#2AA198",
        number: "#CB4B16",
        keyword: "#859900",
        heading: "#6C71C4"
    )

    static let solarizedDark = TextPalette(
        foreground: "#839496",
        background: "#002B36",
        selection: "#073642",
        occurrence: "#B58900",
        comment: "#586E75",
        string: "#2AA198",
        number: "#CB4B16",
        keyword: "#859900",
        heading: "#6C71C4"
    )

    static let oneDark = TextPalette(
        foreground: "#ABB2BF",
        background: "#282C34",
        selection: "#3E4451",
        occurrence: "#5C6370",
        comment: "#5C6370",
        string: "#98C379",
        number: "#D19A66",
        keyword: "#C678DD",
        heading: "#61AFEF"
    )
}

private func readableTextColor(_ color: NSColor, on background: NSColor, fallback: NSColor) -> NSColor {
    color.contrastRatio(with: background) >= 4.5 ? color : fallback
}

private func readableFallback(for background: NSColor) -> NSColor {
    let dark = NSColor(macPadHex: "#111827")
    let light = NSColor(macPadHex: "#F8FAFC")
    return dark.contrastRatio(with: background) >= light.contrastRatio(with: background) ? dark : light
}

enum TextThemeID: String, CaseIterable, Codable {
    case system
    case light
    case dark
    case dracula
    case nord
    case solarized
    case oneDark
    case custom

    var displayName: String {
        switch self {
        case .system: return "MacPad System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .dracula: return "Dracula"
        case .nord: return "Nord"
        case .solarized: return "Solarized"
        case .oneDark: return "One Dark"
        case .custom: return "Custom"
        }
    }

    var palettes: (light: TextPalette, dark: TextPalette)? {
        switch self {
        case .system:
            return (.systemLight, .systemDark)
        case .light:
            return (.light, .light)
        case .dark:
            return (.dark, .dark)
        case .dracula:
            return (.dracula, .dracula)
        case .nord:
            return (.nord, .nord)
        case .solarized:
            return (.solarizedLight, .solarizedDark)
        case .oneDark:
            return (.oneDark, .oneDark)
        case .custom:
            return nil
        }
    }
}

struct TextSettings: Codable, Equatable {
    var fontFamily: String
    var fontSize: Double
    var theme: TextThemeID
    var lightPalette: TextPalette
    var darkPalette: TextPalette

    init(
        fontFamily: String = "Menlo",
        fontSize: Double = 14,
        theme: TextThemeID = .system,
        lightPalette: TextPalette = .systemLight,
        darkPalette: TextPalette = .systemDark
    ) {
        self.fontFamily = fontFamily
        self.fontSize = min(max(fontSize, 8), 48)
        self.theme = theme
        self.lightPalette = lightPalette
        self.darkPalette = darkPalette
    }

    private enum CodingKeys: String, CodingKey {
        case fontFamily, fontSize, theme, lightPalette, darkPalette
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            fontFamily: try container.decodeIfPresent(String.self, forKey: .fontFamily) ?? "Menlo",
            fontSize: try container.decodeIfPresent(Double.self, forKey: .fontSize) ?? 14,
            theme: try container.decodeIfPresent(TextThemeID.self, forKey: .theme) ?? .system,
            lightPalette: try container.decodeIfPresent(TextPalette.self, forKey: .lightPalette) ?? .systemLight,
            darkPalette: try container.decodeIfPresent(TextPalette.self, forKey: .darkPalette) ?? .systemDark
        )
    }

    func font() -> NSFont {
        if fontFamily == "System Monospaced" {
            return NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
        return NSFont(name: fontFamily, size: fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }

    func palette(for appearance: NSAppearance?) -> TextPalette {
        let isDark = appearance?.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        return isDark ? darkPalette : lightPalette
    }

    func styleColors(for appearance: NSAppearance?) -> TextStyleColors {
        palette(for: appearance).styleColors()
    }

    mutating func applyTheme(_ theme: TextThemeID) {
        guard let palettes = theme.palettes else {
            self.theme = .custom
            return
        }
        self.theme = theme
        lightPalette = palettes.light
        darkPalette = palettes.dark
        lightPalette.ensureReadableContrast()
        darkPalette.ensureReadableContrast()
    }

    mutating func setColor(_ color: NSColor, for role: TextColorRole, appearance: NSAppearance?) {
        let isDark = appearance?.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        if isDark {
            darkPalette.setColor(color, for: role)
        } else {
            lightPalette.setColor(color, for: role)
        }
        theme = .custom
        lightPalette.ensureReadableContrast()
        darkPalette.ensureReadableContrast()
    }
}

final class TextSettingsStore {
    private let defaults = UserDefaults.standard
    private let key = "MacPad.TextSettings.v1"

    func load() -> TextSettings {
        guard let data = defaults.data(forKey: key),
              var settings = try? JSONDecoder().decode(TextSettings.self, from: data) else {
            return TextSettings()
        }

        // Migrate the first low-contrast System palette so existing installs
        // receive the readability fix without overwriting a user's Custom theme.
        let legacyLight = TextPalette(
            foreground: "#1F2328", background: "#FFFFFF", selection: "#BBD7FF",
            occurrence: "#FFE08A", comment: "#216E39", string: "#A61B12",
            number: "#A15C00", keyword: "#0A3D91", heading: "#6D28A9"
        )
        let legacyDark = TextPalette(
            foreground: "#F5F5F7", background: "#1E1E1E", selection: "#4C5D8A",
            occurrence: "#8C6A16", comment: "#75D38B", string: "#FF8178",
            number: "#FFB454", keyword: "#83B7FF", heading: "#D0A9FF"
        )
        if settings.theme == .system,
           settings.lightPalette == legacyLight,
           settings.darkPalette == legacyDark {
            settings.lightPalette = .systemLight
            settings.darkPalette = .systemDark
            if settings.fontSize == 13 {
                settings.fontSize = 14
            }
        }

        let beforeContrastFix = settings
        settings.lightPalette.ensureReadableContrast()
        settings.darkPalette.ensureReadableContrast()
        if settings != beforeContrastFix {
            save(settings)
        }
        return settings
    }

    func save(_ settings: TextSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}

extension NSColor {
    convenience init(macPadHex: String, alpha: CGFloat = 1) {
        let value = macPadHex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: value)
        var rgb: UInt64 = 0
        guard value.count == 6, scanner.scanHexInt64(&rgb) else {
            self.init(calibratedWhite: 0.5, alpha: alpha)
            return
        }
        self.init(
            srgbRed: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: alpha
        )
    }

    var macPadHex: String {
        guard let rgb = usingColorSpace(.sRGB) ?? usingColorSpace(.deviceRGB) else { return "#808080" }
        let red = Int((rgb.redComponent * 255).rounded())
        let green = Int((rgb.greenComponent * 255).rounded())
        let blue = Int((rgb.blueComponent * 255).rounded())
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    var relativeLuminance: CGFloat {
        guard let rgb = usingColorSpace(.sRGB) else { return 0.5 }

        func linearize(_ value: CGFloat) -> CGFloat {
            value <= 0.03928
                ? value / 12.92
                : CGFloat(pow(Double((value + 0.055) / 1.055), 2.4))
        }

        return (0.2126 * linearize(rgb.redComponent))
            + (0.7152 * linearize(rgb.greenComponent))
            + (0.0722 * linearize(rgb.blueComponent))
    }

    func contrastRatio(with other: NSColor) -> CGFloat {
        let brighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (brighter + 0.05) / (darker + 0.05)
    }
}
