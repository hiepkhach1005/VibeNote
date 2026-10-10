import AppKit

enum FileDropPayload {
    static let legacyFileNamesType = NSPasteboard.PasteboardType("NSFilenamesPboardType")

    static func containsFileRepresentation(_ pasteboard: NSPasteboard) -> Bool {
        pasteboard.availableType(from: [.fileURL, legacyFileNamesType]) != nil
    }

    static func fileURLs(from pasteboard: NSPasteboard, includePlainTextPaths: Bool = false) -> [URL] {
        var candidates: [URL] = []

        for item in pasteboard.pasteboardItems ?? [] {
            guard let value = item.string(forType: .fileURL),
                  let url = URL(string: value) else { continue }
            candidates.append(url)
        }

        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
        ]
        let objects = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: options
        ) ?? []
        candidates.append(contentsOf: objects.compactMap { object in
            if let url = object as? URL { return url }
            if let url = object as? NSURL { return url as URL }
            return nil
        })

        if let paths = pasteboard.propertyList(forType: legacyFileNamesType) as? [String] {
            candidates.append(contentsOf: paths.map(URL.init(fileURLWithPath:)))
        }

        if candidates.isEmpty,
           containsFileRepresentation(pasteboard),
           let value = pasteboard.string(forType: .fileURL),
           let url = URL(string: value) {
            candidates.append(url)
        }

        if candidates.isEmpty, includePlainTextPaths,
           let text = pasteboard.string(forType: .string) {
            candidates.append(contentsOf: fileURLs(fromPlainText: text))
        }

        var seen = Set<URL>()
        return candidates.compactMap { candidate in
            let url = candidate.standardizedFileURL
            guard url.isFileURL,
                  isFile(url),
                  seen.insert(url).inserted else { return nil }
            return url
        }
    }

    private static func isFile(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return false
        }
        return !isDirectory.boolValue
    }

    private static func fileURLs(fromPlainText text: String) -> [URL] {
        text.components(separatedBy: .newlines).compactMap { line in
            let value = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else { return nil }
            if let url = URL(string: value), url.isFileURL {
                return url
            }
            guard value.hasPrefix("/") else { return nil }
            return URL(fileURLWithPath: value)
        }
    }
}

/// A native drop destination used by the window shell and editor surface.
/// It accepts files regardless of extension and leaves non-file drag behavior
/// to AppKit (including normal text dragging inside NSTextView).
class FileDropView: NSView {
    var onDropFiles: (([URL]) -> Void)?

    private var isDropTarget = false {
        didSet {
            guard oldValue != isDropTarget else { return }
            needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL, FileDropPayload.legacyFileNamesType, .string])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL, FileDropPayload.legacyFileNamesType, .string])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        updateDropState(using: sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        updateDropState(using: sender)
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDropTarget = false
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        !droppedFileURLs(from: sender).isEmpty
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = droppedFileURLs(from: sender)
        guard !urls.isEmpty else { return false }
        onDropFiles?(urls)
        return true
    }

    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        isDropTarget = false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard isDropTarget else { return }

        NSColor.controlAccentColor.withAlphaComponent(0.9).setStroke()
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 5, dy: 5), xRadius: 10, yRadius: 10)
        path.lineWidth = 3
        path.stroke()
    }

    private func updateDropState(using sender: NSDraggingInfo) -> NSDragOperation {
        let acceptsFiles = !droppedFileURLs(from: sender).isEmpty
        isDropTarget = acceptsFiles
        return acceptsFiles ? .copy : []
    }

    private func droppedFileURLs(from sender: NSDraggingInfo) -> [URL] {
        let isInternalTextDrag = sender.draggingSource is NSTextView
        return FileDropPayload.fileURLs(
            from: sender.draggingPasteboard,
            includePlainTextPaths: !isInternalTextDrag
        )
    }
}

final class FileDropTextView: NSTextView {
    var onDropFiles: (([URL]) -> Void)?

    override var acceptableDragTypes: [NSPasteboard.PasteboardType] {
        Array(Set(super.acceptableDragTypes + [.fileURL, FileDropPayload.legacyFileNamesType, .string]))
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let urls = droppedFileURLs(from: sender)
        guard !urls.isEmpty else {
            return super.draggingEntered(sender)
        }
        return .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        let urls = droppedFileURLs(from: sender)
        guard !urls.isEmpty else {
            return super.draggingUpdated(sender)
        }
        return .copy
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = droppedFileURLs(from: sender)
        guard !urls.isEmpty else {
            return super.prepareForDragOperation(sender)
        }
        return true
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = droppedFileURLs(from: sender)
        guard !urls.isEmpty else {
            return super.performDragOperation(sender)
        }
        onDropFiles?(urls)
        return true
    }

    override func readSelection(from pasteboard: NSPasteboard, type: NSPasteboard.PasteboardType) -> Bool {
        guard FileDropPayload.containsFileRepresentation(pasteboard) else {
            return super.readSelection(from: pasteboard, type: type)
        }
        let urls = FileDropPayload.fileURLs(from: pasteboard)
        guard !urls.isEmpty else { return false }
        onDropFiles?(urls)
        return true
    }

    private func droppedFileURLs(from sender: NSDraggingInfo) -> [URL] {
        let isInternalTextDrag = sender.draggingSource is NSTextView
        return FileDropPayload.fileURLs(
            from: sender.draggingPasteboard,
            includePlainTextPaths: !isInternalTextDrag
        )
    }
}
