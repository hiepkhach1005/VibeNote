import AppKit

enum LanguageID: String, CaseIterable, Codable {
    case plainText
    case swift
    case python
    case javascript
    case json
    case html
    case css
    case shell
    case markdown
    case c
    case cpp
    case sql

    var displayName: String {
        switch self {
        case .plainText: return "Normal Text"
        case .swift: return "Swift"
        case .python: return "Python"
        case .javascript: return "JavaScript"
        case .json: return "JSON"
        case .html: return "HTML"
        case .css: return "CSS"
        case .shell: return "Shell Script"
        case .markdown: return "Markdown"
        case .c: return "C"
        case .cpp: return "C++"
        case .sql: return "SQL"
        }
    }

    var fileExtensions: Set<String> {
        switch self {
        case .plainText: return []
        case .swift: return ["swift"]
        case .python: return ["py", "pyw"]
        case .javascript: return ["js", "jsx", "ts", "tsx"]
        case .json: return ["json", "jsonc"]
        case .html: return ["html", "htm", "xhtml"]
        case .css: return ["css", "scss"]
        case .shell: return ["sh", "bash", "zsh", "fish"]
        case .markdown: return ["md", "markdown"]
        case .c: return ["c", "h"]
        case .cpp: return ["cc", "cpp", "cxx", "hpp"]
        case .sql: return ["sql"]
        }
    }
}

enum LanguageRegistry {
    static func detect(for url: URL?) -> LanguageID {
        guard let url else { return .plainText }
        let ext = url.pathExtension.lowercased()
        return LanguageID.allCases.first(where: { $0.fileExtensions.contains(ext) }) ?? .plainText
    }
}

struct SyntaxHighlighter {
    static func apply(to textStorage: NSTextStorage, language: LanguageID, font: NSFont, colors: TextStyleColors) {
        let text = textStorage.string as NSString
        let fullRange = NSRange(location: 0, length: text.length)
        let boldFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        let italicFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
        textStorage.beginEditing()
        textStorage.setAttributes([.foregroundColor: colors.foreground, .font: font], range: fullRange)

        guard language != .plainText, text.length > 0 else {
            textStorage.endEditing()
            return
        }

        for rule in commentRules(for: language, colors: colors, font: font, boldFont: boldFont, italicFont: italicFont) {
            add(pattern: rule.pattern, color: rule.color, font: rule.font, to: textStorage, text: text as String)
        }
        add(pattern: "(?:\\\"(?:\\\\.|[^\\\"\\\\])*\\\"|'(?:\\\\.|[^'\\\\])*')", color: colors.string, to: textStorage, text: text as String)
        if language == .javascript {
            add(pattern: "`(?:\\\\.|[^`\\\\])*`", color: colors.string, to: textStorage, text: text as String)
        }
        add(pattern: "\\b(?:[0-9]+(?:\\.[0-9]+)?)\\b", color: colors.number, to: textStorage, text: text as String)
        add(pattern: keywordPattern(for: language), color: colors.keyword, font: boldFont, to: textStorage, text: text as String)
        textStorage.endEditing()
    }

    private static func add(pattern: String, color: NSColor, font: NSFont? = nil, to storage: NSTextStorage, text: String) {
        guard let expression = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else { return }
        let range = NSRange(location: 0, length: (text as NSString).length)
        for match in expression.matches(in: text, options: [], range: range) {
            var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
            if let font {
                attributes[.font] = font
            }
            storage.addAttributes(attributes, range: match.range)
        }
    }

    private static func commentRules(
        for language: LanguageID,
        colors: TextStyleColors,
        font: NSFont,
        boldFont: NSFont,
        italicFont: NSFont
    ) -> [(pattern: String, color: NSColor, font: NSFont?)] {
        switch language {
        case .python, .shell:
            return [("#[^\\n]*", colors.comment, italicFont)]
        case .html:
            return [("<!--[\\s\\S]*?-->", colors.comment, italicFont)]
        case .sql:
            return [
                ("--[^\\n]*", colors.comment, italicFont),
                ("/\\*[\\s\\S]*?\\*/", colors.comment, italicFont)
            ]
        case .markdown:
            return [
                ("^\\s{0,3}#{1,6}[^\\n]*", colors.heading, boldFont),
                ("`[^`]*`", colors.string, font)
            ]
        case .swift, .javascript, .json, .css, .c, .cpp:
            return [
                ("//[^\\n]*", colors.comment, italicFont),
                ("/\\*[\\s\\S]*?\\*/", colors.comment, italicFont)
            ]
        case .plainText:
            return []
        }
    }

    private static func keywordPattern(for language: LanguageID) -> String {
        let keywords: [String]
        switch language {
        case .swift:
            keywords = ["actor", "async", "await", "class", "enum", "extension", "func", "if", "import", "in", "let", "protocol", "return", "struct", "var", "where", "while"]
        case .python:
            keywords = ["and", "as", "class", "def", "elif", "else", "False", "for", "from", "if", "import", "in", "None", "not", "or", "return", "True", "while", "with"]
        case .javascript:
            keywords = ["async", "await", "class", "const", "else", "export", "for", "function", "if", "import", "let", "new", "return", "this", "throw", "try", "var", "while"]
        case .json:
            keywords = ["true", "false", "null"]
        case .html:
            keywords = ["DOCTYPE", "html", "head", "body", "div", "span", "script", "style"]
        case .css:
            keywords = ["@media", "@import", "display", "flex", "grid", "position", "color", "margin", "padding"]
        case .shell:
            keywords = ["case", "do", "done", "elif", "else", "esac", "fi", "for", "function", "if", "in", "then", "while"]
        case .markdown, .plainText:
            keywords = []
        case .c, .cpp:
            keywords = ["auto", "bool", "break", "case", "class", "const", "else", "for", "if", "include", "int", "namespace", "new", "return", "struct", "using", "void", "while"]
        case .sql:
            keywords = ["ALTER", "CREATE", "DELETE", "FROM", "INSERT", "JOIN", "ORDER", "SELECT", "TABLE", "UPDATE", "VALUES", "WHERE"]
        }
        guard !keywords.isEmpty else { return "(?!)" }
        return "\\b(?:" + keywords.map(NSRegularExpression.escapedPattern).joined(separator: "|") + ")\\b"
    }
}
