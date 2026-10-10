import Foundation

struct PersistedDocument: Codable {
    let path: String?
    let content: String
    let encoding: String
    let isModified: Bool
    let lineEnding: String
    let hasBOM: Bool
    let language: String

    private enum CodingKeys: String, CodingKey {
        case path, content, encoding, isModified, lineEnding, hasBOM, language
    }

    init(path: String?, content: String, encoding: String, isModified: Bool, lineEnding: String = DocumentLineEnding.lf.rawValue, hasBOM: Bool = false, language: String = LanguageID.plainText.rawValue) {
        self.path = path
        self.content = content
        self.encoding = encoding
        self.isModified = isModified
        self.lineEnding = lineEnding
        self.hasBOM = hasBOM
        self.language = language
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decodeIfPresent(String.self, forKey: .path)
        content = try container.decode(String.self, forKey: .content)
        encoding = try container.decode(String.self, forKey: .encoding)
        isModified = try container.decode(Bool.self, forKey: .isModified)
        lineEnding = try container.decodeIfPresent(String.self, forKey: .lineEnding) ?? DocumentLineEnding.lf.rawValue
        hasBOM = try container.decodeIfPresent(Bool.self, forKey: .hasBOM) ?? false
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? LanguageID.plainText.rawValue
    }
}

struct PersistedSession: Codable {
    let documents: [PersistedDocument]
    let selectedIndex: Int
}

final class SessionStore {
    private let fileManager = FileManager.default

    private var sessionURL: URL {
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return applicationSupport
            .appendingPathComponent("MacPad", isDirectory: true)
            .appendingPathComponent("session.json")
    }

    func load() -> PersistedSession? {
        guard let data = try? Data(contentsOf: sessionURL) else { return nil }
        return try? JSONDecoder().decode(PersistedSession.self, from: data)
    }

    func save(documents: [EditorDocument], selectedIndex: Int) {
        let persisted = documents.map { document in
            PersistedDocument(
                path: document.url?.path,
                content: document.content,
                encoding: encodingIdentifier(document.encoding),
                isModified: document.isModified,
                lineEnding: document.lineEnding.rawValue,
                hasBOM: document.hasBOM,
                language: document.language.rawValue
            )
        }
        let session = PersistedSession(documents: persisted, selectedIndex: selectedIndex)

        guard let data = try? JSONEncoder().encode(session) else { return }
        let directory = sessionURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: sessionURL, options: .atomic)
    }

    func encoding(from identifier: String) -> String.Encoding {
        switch identifier {
        case "utf8": return .utf8
        case "utf16": return .utf16
        case "utf16LE": return .utf16LittleEndian
        case "utf16BE": return .utf16BigEndian
        case "utf32LE": return .utf32LittleEndian
        case "utf32BE": return .utf32BigEndian
        case "ascii": return .ascii
        default: return .utf8
        }
    }

    private func encodingIdentifier(_ encoding: String.Encoding) -> String {
        switch encoding {
        case .utf8: return "utf8"
        case .utf16: return "utf16"
        case .utf16LittleEndian: return "utf16LE"
        case .utf16BigEndian: return "utf16BE"
        case .utf32LittleEndian: return "utf32LE"
        case .utf32BigEndian: return "utf32BE"
        case .ascii: return "ascii"
        default: return "utf8"
        }
    }
}
