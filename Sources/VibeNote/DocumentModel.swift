import Foundation

enum DocumentLineEnding: String, CaseIterable, Codable {
    case lf
    case crlf
    case cr
    case mixed

    var displayName: String {
        switch self {
        case .lf: return "Unix (LF)"
        case .crlf: return "Windows (CR LF)"
        case .cr: return "Classic Mac (CR)"
        case .mixed: return "Mixed"
        }
    }

    var sequence: String {
        switch self {
        case .lf, .mixed: return "\n"
        case .crlf: return "\r\n"
        case .cr: return "\r"
        }
    }

    static func detect(in text: String) -> DocumentLineEnding {
        var lf = 0
        var crlf = 0
        var cr = 0
        let characters = Array(text)

        for index in characters.indices {
            guard characters[index] == "\n" || characters[index] == "\r" else { continue }
            if characters[index] == "\r" {
                if characters.indices.contains(index + 1), characters[index + 1] == "\n" {
                    crlf += 1
                } else {
                    cr += 1
                }
            } else if index == characters.startIndex || characters[characters.index(before: index)] != "\r" {
                lf += 1
            }
        }

        let kinds = [lf > 0, crlf > 0, cr > 0].filter { $0 }.count
        if kinds > 1 { return .mixed }
        if crlf > 0 { return .crlf }
        if cr > 0 { return .cr }
        return .lf
    }

    static func normalize(_ text: String) -> String {
        text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
    }

    func applying(to normalizedText: String) -> String {
        guard self != .lf, self != .mixed else { return normalizedText }
        return normalizedText.replacingOccurrences(of: "\n", with: sequence)
    }
}

final class EditorDocument {
    let id = UUID()
    var url: URL?
    var encoding: String.Encoding
    var content: String
    var isModified: Bool
    var lineEnding: DocumentLineEnding
    var hasBOM: Bool
    var language: LanguageID
    var fileSnapshot: FileSnapshot?
    var hasExternalChange = false

    init(url: URL? = nil, content: String = "", encoding: String.Encoding = .utf8, isModified: Bool = false, lineEnding: DocumentLineEnding = .lf, hasBOM: Bool = false, language: LanguageID? = nil, fileSnapshot: FileSnapshot? = nil) {
        self.url = url
        self.content = content
        self.encoding = encoding
        self.isModified = isModified
        self.lineEnding = lineEnding
        self.hasBOM = hasBOM
        self.language = language ?? LanguageRegistry.detect(for: url)
        self.fileSnapshot = fileSnapshot
    }

    var displayName: String {
        url?.lastPathComponent ?? "Untitled"
    }

    var title: String {
        isModified ? "\(displayName) *" : displayName
    }
}

struct FileSnapshot: Equatable {
    let byteSize: UInt64
    let modificationDate: Date
}

enum DocumentStoreError: LocalizedError {
    case unableToRead(URL)
    case unableToWrite(URL)

    var errorDescription: String? {
        switch self {
        case .unableToRead(let url): return "Không thể đọc file: \(url.path)"
        case .unableToWrite(let url): return "Không thể ghi file: \(url.path)"
        }
    }
}

struct DocumentStore {
    func load(from url: URL) throws -> EditorDocument {
        do {
            let data = try Data(contentsOf: url)
            guard let decoded = decode(data) else { throw DocumentStoreError.unableToRead(url) }
            let lineEnding = DocumentLineEnding.detect(in: decoded.text)
            let normalized = DocumentLineEnding.normalize(decoded.text)
            return EditorDocument(url: url, content: normalized, encoding: decoded.encoding, lineEnding: lineEnding, hasBOM: decoded.hasBOM, language: LanguageRegistry.detect(for: url), fileSnapshot: snapshot(for: url))
        } catch let error as DocumentStoreError {
            throw error
        } catch {
            throw DocumentStoreError.unableToRead(url)
        }
    }

    func save(_ document: EditorDocument, to url: URL? = nil) throws {
        let destination = url ?? document.url
        guard let destination else {
            throw DocumentStoreError.unableToWrite(URL(fileURLWithPath: "Untitled"))
        }

        let normalized = DocumentLineEnding.normalize(document.content)
        let serialized = document.lineEnding.applying(to: normalized)
        guard var data = serialized.data(using: document.encoding) else {
            throw DocumentStoreError.unableToWrite(destination)
        }
        if document.hasBOM, let bom = bomData(for: document.encoding) {
            data = bom + data
        }

        do {
            try data.write(to: destination, options: .atomic)
        } catch {
            throw DocumentStoreError.unableToWrite(destination)
        }
    }

    func snapshot(for url: URL) -> FileSnapshot? {
        let keys: Set<URLResourceKey> = [.fileSizeKey, .contentModificationDateKey]
        guard let values = try? url.resourceValues(forKeys: keys),
              let size = values.fileSize,
              let modificationDate = values.contentModificationDate else { return nil }
        return FileSnapshot(byteSize: UInt64(size), modificationDate: modificationDate)
    }

    private func decode(_ data: Data) -> (text: String, encoding: String.Encoding, hasBOM: Bool)? {
        let bomCandidates: [(bytes: [UInt8], encoding: String.Encoding)] = [
            ([0xEF, 0xBB, 0xBF], .utf8),
            ([0xFF, 0xFE, 0x00, 0x00], .utf32LittleEndian),
            ([0x00, 0x00, 0xFE, 0xFF], .utf32BigEndian),
            ([0xFF, 0xFE], .utf16LittleEndian),
            ([0xFE, 0xFF], .utf16BigEndian)
        ]

        for candidate in bomCandidates where data.starts(with: candidate.bytes) {
            let payload = data.dropFirst(candidate.bytes.count)
            if let text = String(data: payload, encoding: candidate.encoding) {
                return (text, candidate.encoding, true)
            }
        }

        let candidates: [String.Encoding] = [.utf8, .utf16LittleEndian, .utf16BigEndian, .utf32LittleEndian, .utf32BigEndian, .ascii, .isoLatin1, .macOSRoman]
        for encoding in candidates {
            if let text = String(data: data, encoding: encoding) {
                return (text, encoding, false)
            }
        }
        return nil
    }

    private func bomData(for encoding: String.Encoding) -> Data? {
        switch encoding {
        case .utf8: return Data([0xEF, 0xBB, 0xBF])
        case .utf16LittleEndian: return Data([0xFF, 0xFE])
        case .utf16BigEndian: return Data([0xFE, 0xFF])
        case .utf32LittleEndian: return Data([0xFF, 0xFE, 0x00, 0x00])
        case .utf32BigEndian: return Data([0x00, 0x00, 0xFE, 0xFF])
        default: return nil
        }
    }
}
