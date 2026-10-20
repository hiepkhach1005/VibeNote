import XCTest
import AppKit
@testable import VibeNote

final class VibeNoteTests: XCTestCase {
    func testNewDocumentDefaults() {
        let document = EditorDocument()

        XCTAssertNil(document.url)
        XCTAssertEqual(document.content, "")
        XCTAssertEqual(document.encoding, .utf8)
        XCTAssertFalse(document.isModified)
        XCTAssertEqual(document.displayName, "Untitled")
        XCTAssertEqual(document.lineEnding, .lf)
        XCTAssertFalse(document.hasBOM)
    }

    func testDocumentTitleShowsModifiedState() {
        let document = EditorDocument(content: "Hello")
        XCTAssertEqual(document.title, "Untitled")

        document.isModified = true

        XCTAssertEqual(document.title, "Untitled *")
    }

    func testDocumentStoreCapturesFileSnapshot() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vibenote-snapshot-test-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }

        let document = EditorDocument(content: "hello")
        let store = DocumentStore()
        try store.save(document, to: url)

        let loaded = try store.load(from: url)

        XCTAssertEqual(loaded.content, "hello")
        XCTAssertNotNil(loaded.fileSnapshot)
    }

    func testPersistedSessionRoundTripPreservesUnsavedNoteAndSelectedTab() throws {
        let session = PersistedSession(
            documents: [
                PersistedDocument(
                    path: nil,
                    content: "unsaved note\nsecond line",
                    encoding: "utf8",
                    isModified: true,
                    lineEnding: DocumentLineEnding.crlf.rawValue,
                    hasBOM: false,
                    language: LanguageID.markdown.rawValue
                )
            ],
            selectedIndex: 0
        )

        let restored = try JSONDecoder().decode(
            PersistedSession.self,
            from: JSONEncoder().encode(session)
        )

        XCTAssertEqual(restored.documents.first?.content, "unsaved note\nsecond line")
        XCTAssertTrue(restored.documents.first?.isModified == true)
        XCTAssertEqual(restored.documents.first?.lineEnding, DocumentLineEnding.crlf.rawValue)
        XCTAssertEqual(restored.documents.first?.language, LanguageID.markdown.rawValue)
        XCTAssertEqual(restored.selectedIndex, 0)
    }

    func testDocumentStorePreservesCRLFAndBOM() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vibenote-eol-test-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }

        let document = EditorDocument(content: "one\ntwo", encoding: .utf8, lineEnding: .crlf, hasBOM: true)
        let store = DocumentStore()
        try store.save(document, to: url)

        let raw = try Data(contentsOf: url)
        XCTAssertEqual(Array(raw.prefix(3)), [0xEF, 0xBB, 0xBF])
        XCTAssertTrue(raw.dropFirst(3).contains(0x0D))

        let loaded = try store.load(from: url)
        XCTAssertEqual(loaded.content, "one\ntwo")
        XCTAssertEqual(loaded.lineEnding, .crlf)
        XCTAssertTrue(loaded.hasBOM)
    }

    func testFileDropPayloadAcceptsExtensionlessFilesAndDeduplicatesURLs() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vibenote-drop-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("dropped text".utf8).write(to: url)

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("VibeNoteDropTest-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.writeObjects([url as NSURL, url as NSURL])

        XCTAssertEqual(FileDropPayload.fileURLs(from: pasteboard), [url.standardizedFileURL])
    }

    func testFileDropPayloadRejectsDirectories() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vibenote-drop-directory-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: url) }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("VibeNoteDropTest-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.writeObjects([url as NSURL])

        XCTAssertTrue(FileDropPayload.fileURLs(from: pasteboard).isEmpty)
    }

    func testFileDropPayloadReadsLegacyFinderFileNames() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vibenote-legacy-drop-\(UUID().uuidString).txt")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("legacy Finder payload".utf8).write(to: url)

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("VibeNoteLegacyDropTest-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setPropertyList([url.path], forType: FileDropPayload.legacyFileNamesType)

        XCTAssertTrue(FileDropPayload.containsFileRepresentation(pasteboard))
        XCTAssertEqual(FileDropPayload.fileURLs(from: pasteboard), [url.standardizedFileURL])
    }

    func testFileDropPayloadDoesNotTreatPlainDraggedTextAsAFile() throws {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("VibeNoteTextDropTest-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setString("/tmp/example.txt", forType: .string)

        XCTAssertFalse(FileDropPayload.containsFileRepresentation(pasteboard))
        XCTAssertTrue(FileDropPayload.fileURLs(from: pasteboard).isEmpty)
    }

    func testFileDropPayloadCanReadVSCodePlainPathDuringExternalDrag() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vibenote-vscode-drop-\(UUID().uuidString).swift")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("let value = 1".utf8).write(to: url)

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("VibeNoteVSCodeDropTest-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setString(url.path, forType: .string)

        XCTAssertTrue(FileDropPayload.fileURLs(from: pasteboard).isEmpty)
        XCTAssertEqual(
            FileDropPayload.fileURLs(from: pasteboard, includePlainTextPaths: true),
            [url.standardizedFileURL]
        )
    }

    func testSearchEngineSupportsModesAndReplacement() throws {
        let normal = try SearchEngine.matches(in: "Alpha alpha alphabet", query: "alpha", options: SearchOptions())
        XCTAssertEqual(normal.count, 3)

        let wholeWord = try SearchEngine.matches(in: "Alpha alpha alphabet", query: "alpha", options: SearchOptions(wholeWord: true))
        XCTAssertEqual(wholeWord.count, 2)

        let extended = try SearchEngine.matches(in: "one\ntwo", query: "one\\ntwo", options: SearchOptions(mode: .extended, caseSensitive: true))
        XCTAssertEqual(extended.count, 1)

        let regex = try SearchEngine.replacing(in: "a1 a2", query: "a(\\d)", replacement: "b$1", options: SearchOptions(mode: .regex, caseSensitive: true))
        XCTAssertEqual(regex.text, "b1 b2")
        XCTAssertEqual(regex.count, 2)
    }

    func testSearchEngineRejectsInvalidRegex() {
        XCTAssertThrowsError(try SearchEngine.matches(in: "text", query: "[", options: SearchOptions(mode: .regex)))
    }

    func testOccurrenceHighlighterFindsSelectedTokenOccurrences() {
        let text = "Alpha alpha alphabet alpha"
        let ranges = OccurrenceHighlighter.ranges(
            in: text,
            selectedRange: NSRange(location: 0, length: 5),
            matchCase: false,
            wholeWord: true
        )

        XCTAssertEqual(ranges.count, 3)
        XCTAssertEqual(ranges.map { (text as NSString).substring(with: $0) }, ["Alpha", "alpha", "alpha"])
    }

    func testLanguageRegistryDetectsCommonSourceFiles() {
        XCTAssertEqual(LanguageRegistry.detect(for: URL(fileURLWithPath: "/tmp/example.swift")), .swift)
        XCTAssertEqual(LanguageRegistry.detect(for: URL(fileURLWithPath: "/tmp/example.py")), .python)
        XCTAssertEqual(LanguageRegistry.detect(for: URL(fileURLWithPath: "/tmp/example.unknown")), .plainText)
    }

    func testTextSettingsApplyDraculaTheme() {
        var settings = TextSettings()

        settings.applyTheme(.dracula)

        XCTAssertEqual(settings.theme, .dracula)
        XCTAssertEqual(settings.lightPalette.background, "#282A36")
        XCTAssertEqual(settings.darkPalette.foreground, "#F8F8F2")
        XCTAssertEqual(settings.lightPalette.selection, "#44475A")
    }

    func testTextSettingsRoundTripPreservesFontAndPalette() throws {
        var settings = TextSettings(fontFamily: "SF Mono", fontSize: 16, theme: .custom)
        settings.setColor(NSColor(vibeNoteHex: "#123456"), for: .foreground, appearance: NSApp?.effectiveAppearance)

        let data = try JSONEncoder().encode(settings)
        let restored = try JSONDecoder().decode(TextSettings.self, from: data)

        XCTAssertEqual(restored.fontFamily, "SF Mono")
        XCTAssertEqual(restored.fontSize, 16)
        XCTAssertEqual(restored.theme, .custom)
        XCTAssertEqual(restored.lightPalette.foreground, "#123456")
    }

    func testTextColorHexRoundTrip() {
        XCTAssertEqual(NSColor(vibeNoteHex: "#282A36").vibeNoteHex, "#282A36")
    }

    func testTextSettingsDefaultPaletteIsHighContrast() {
        let settings = TextSettings()

        XCTAssertEqual(settings.fontSize, 14)
        XCTAssertEqual(settings.lightPalette.foreground, "#111827")
        XCTAssertEqual(settings.lightPalette.keyword, "#1D4ED8")
        XCTAssertEqual(settings.lightPalette.occurrence, "#FACC15")
    }

    func testExplicitLightAndDarkThemesUseStableEditorSurfaces() {
        var settings = TextSettings()

        settings.applyTheme(.light)
        XCTAssertEqual(settings.theme, .light)
        XCTAssertEqual(settings.lightPalette.background, "#FFFFFF")
        XCTAssertEqual(settings.darkPalette.background, "#FFFFFF")

        settings.applyTheme(.dark)
        XCTAssertEqual(settings.theme, .dark)
        XCTAssertEqual(settings.lightPalette.background, "#171A21")
        XCTAssertEqual(settings.darkPalette.background, "#171A21")
    }

    func testTextSettingsRepairsWhiteTextOnWhiteBackground() {
        var palette = TextPalette.light
        palette.foreground = "#FFFFFF"

        palette.ensureReadableContrast()

        XCTAssertEqual(palette.foreground, "#111827")
        XCTAssertGreaterThan(NSColor(vibeNoteHex: palette.foreground).contrastRatio(with: NSColor(vibeNoteHex: palette.background)), 4.5)
    }
}
