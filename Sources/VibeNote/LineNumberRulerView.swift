import AppKit

final class LineNumberRulerView: NSView {
    weak var textView: NSTextView?
    override var isFlipped: Bool { true }

    init(textView: NSTextView) {
        self.textView = textView
        super.init(frame: .zero)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let textView else { return }

        textView.backgroundColor.setFill()
        dirtyRect.fill()

        let text = textView.string as NSString
        guard let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }
        let visibleRect = textView.visibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        var glyphIndex = glyphRange.location
        let endGlyphIndex = NSMaxRange(glyphRange)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.labelColor.withAlphaComponent(0.72)
        ]

        while glyphIndex < endGlyphIndex {
            var lineGlyphRange = NSRange(location: 0, length: 0)
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineGlyphRange)
            let characterIndex = min(layoutManager.characterIndexForGlyph(at: glyphIndex), text.length)
            let prefix = text.substring(to: characterIndex)
            let lineNumber = prefix.reduce(into: 1) { result, character in
                if character == "\n" { result += 1 }
            }

            let line = "\(lineNumber)" as NSString
            let size = line.size(withAttributes: attributes)
            let y = lineRect.minY
                + textView.textContainerInset.height
                - visibleRect.minY
                + (lineRect.height - size.height) / 2
            let x = bounds.width - size.width - 8
            line.draw(at: NSPoint(x: x, y: y), withAttributes: attributes)

            let nextGlyphIndex = NSMaxRange(lineGlyphRange)
            if nextGlyphIndex <= glyphIndex {
                glyphIndex += 1
            } else {
                glyphIndex = nextGlyphIndex
            }
        }
    }
}
