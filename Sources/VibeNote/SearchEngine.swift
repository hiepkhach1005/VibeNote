import Foundation

enum SearchMode: String, CaseIterable {
    case normal
    case extended
    case regex

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .extended: return "Extended (\\n, \\t)"
        case .regex: return "Regular expression"
        }
    }
}

struct SearchOptions {
    var mode: SearchMode = .normal
    var caseSensitive = false
    var wholeWord = false
    var wrapAround = true
}

enum SearchEngineError: LocalizedError {
    case emptyQuery
    case invalidRegularExpression(String)

    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Enter a search term."
        case .invalidRegularExpression(let message):
            return "Invalid regular expression: \(message)"
        }
    }
}

struct SearchEngine {
    static func matches(in text: String, query: String, options: SearchOptions) throws -> [NSRange] {
        guard !query.isEmpty else { throw SearchEngineError.emptyQuery }

        switch options.mode {
        case .normal, .extended:
            let needle = options.mode == .extended ? decodeExtended(query) : query
            return literalMatches(in: text, query: needle, options: options)
        case .regex:
            let expression: NSRegularExpression
            do {
                var flags: NSRegularExpression.Options = []
                if !options.caseSensitive { flags.insert(.caseInsensitive) }
                expression = try NSRegularExpression(pattern: query, options: flags)
            } catch {
                throw SearchEngineError.invalidRegularExpression(error.localizedDescription)
            }

            let fullRange = NSRange(location: 0, length: (text as NSString).length)
            return expression.matches(in: text, options: [], range: fullRange)
                .map(\.range)
                .filter { !options.wholeWord || isWholeWord(in: text, range: $0) }
        }
    }

    static func replacing(in text: String, query: String, replacement: String, options: SearchOptions) throws -> (text: String, count: Int) {
        let ranges = try matches(in: text, query: query, options: options)
        guard !ranges.isEmpty else { return (text, 0) }

        var result = text
        for range in ranges.reversed() {
            let replacementText: String
            if options.mode == .regex {
                do {
                    let expression = try NSRegularExpression(pattern: query, options: options.caseSensitive ? [] : [.caseInsensitive])
                    guard let match = expression.firstMatch(in: text, options: [], range: range) else { continue }
                    replacementText = expression.replacementString(for: match, in: text, offset: 0, template: replacement)
                } catch {
                    throw SearchEngineError.invalidRegularExpression(error.localizedDescription)
                }
            } else {
                replacementText = replacement
            }
            result = (result as NSString).replacingCharacters(in: range, with: replacementText)
        }
        return (result, ranges.count)
    }

    private static func literalMatches(in text: String, query: String, options: SearchOptions) -> [NSRange] {
        guard !query.isEmpty else { return [] }
        let nsText = text as NSString
        let searchOptions: NSString.CompareOptions = options.caseSensitive ? [] : [.caseInsensitive]
        var ranges: [NSRange] = []
        var location = 0
        while location <= nsText.length - query.utf16.count {
            let searchRange = NSRange(location: location, length: nsText.length - location)
            let range = nsText.range(of: query, options: searchOptions, range: searchRange)
            guard range.location != NSNotFound else { break }
            if !options.wholeWord || isWholeWord(in: text, range: range) {
                ranges.append(range)
            }
            location = max(NSMaxRange(range), location + 1)
        }
        return ranges
    }

    private static func isWholeWord(in text: String, range: NSRange) -> Bool {
        let nsText = text as NSString
        let before = range.location > 0 ? nsText.substring(with: NSRange(location: range.location - 1, length: 1)) : ""
        let afterLocation = NSMaxRange(range)
        let after = afterLocation < nsText.length ? nsText.substring(with: NSRange(location: afterLocation, length: 1)) : ""
        return !isWordCharacter(before) && !isWordCharacter(after)
    }

    private static func isWordCharacter(_ value: String) -> Bool {
        guard let scalar = value.unicodeScalars.first else { return false }
        return scalar == "_" || CharacterSet.alphanumerics.contains(scalar)
    }

    private static func decodeExtended(_ query: String) -> String {
        var result = ""
        var iterator = query.makeIterator()
        while let character = iterator.next() {
            guard character == "\\" else {
                result.append(character)
                continue
            }
            guard let escaped = iterator.next() else {
                result.append("\\")
                continue
            }
            switch escaped {
            case "n": result.append("\n")
            case "r": result.append("\r")
            case "t": result.append("\t")
            case "0": result.append("\0")
            case "\\": result.append("\\")
            default:
                result.append("\\")
                result.append(escaped)
            }
        }
        return result
    }
}
