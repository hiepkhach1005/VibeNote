import Foundation

enum OccurrenceHighlighter {
    static func ranges(
        in text: String,
        selectedRange: NSRange,
        matchCase: Bool = false,
        wholeWord: Bool = false
    ) -> [NSRange] {
        let nsText = text as NSString
        guard selectedRange.location >= 0,
              selectedRange.length > 0,
              NSMaxRange(selectedRange) <= nsText.length else {
            return []
        }

        let token = nsText.substring(with: selectedRange)
        guard !token.isEmpty else { return [] }

        let options = SearchOptions(
            mode: .normal,
            caseSensitive: matchCase,
            wholeWord: wholeWord,
            wrapAround: true
        )
        return (try? SearchEngine.matches(in: text, query: token, options: options)) ?? []
    }
}
