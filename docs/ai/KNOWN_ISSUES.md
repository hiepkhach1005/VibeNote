# Known Issues

- The initial project is a Swift Package executable, not yet a signed `.app` distribution bundle.
- The generated `.app` is an unsigned development bundle; signing and notarization remain release work.
- The packaged app is intentionally single-instance: LaunchServices/Finder open events route into the existing window, while a direct second executable launch cannot yet forward arbitrary command-line file paths.
- Native file drop now accepts Finder URL/legacy filename representations and VS Code Explorer plain absolute paths, rejects folders and blocks `NSTextView` at both drag and `readSelection` layers from inserting a dropped file path as text. The currently running PID predates the rebuilt binary and must be restarted before interactive acceptance; future sandboxed builds require security-scoped URLs.
- The document tab strip now stays in the one window above the editor and supports close/save/pin/close-group actions plus Chrome-style middle-click close across the tab cell; drag reorder, tab colors, lock state and MRU switching remain.
- Toolbar controls are now right-aligned icon-only buttons with a short-delay hover label; long tab titles are capped and expose their full path on hover. Persisted toolbar visibility and complete accessibility review remain.
- Encoding support now has an explicit encoding/BOM/EOL model and menu, but ambiguous/lossy conversions and legacy code pages still need warnings.
- Find/Replace now supports a native popup reachable from both toolbar search actions and the Search menu, with normal/extended/regex modes, replace-all, count and selected-token Smart Highlighting; persistent Style All Occurrences/mark styles, Find in Files and Search Results remain.
- Line transforms currently operate through the editor text storage; multi-line selection semantics, split lines and richer undo acceptance still need coverage.
- Language support currently provides a small registry and lightweight high-contrast token coloring with emphasized headings/keywords; it is not yet a full Lexilla-equivalent lexer/folding/completion system.
- Text Settings now controls the global editor font, size, palette and System/Light/Dark/common themes across all tabs; per-language style scopes, settings import/export and the full Notepad++ Style Configurator remain.
- Text contrast is guarded at runtime and on persistence; a complete Light/Dark accessibility and color-role audit is still pending.
- The line-number gutter no longer overlays editor content; large-document gutter calculation is still linear and belongs to later performance work.
- Settings and tab focus is now restored to the selected editor after dismissal/selection; full keyboard-only and VoiceOver acceptance remains pending.
- Closing the main window or quitting MacPad now saves a single automatic recovery session and exits without a save dialog; named sessions, crash markers and a recovery UI are still planned. Individual tab close continues to protect modified notes with confirmation.
- Full TextKit 2/custom storage integration is planned, not complete.
- Automated XCTest cannot run in the current environment because only `/Library/Developer/CommandLineTools` is selected; install/select full Xcode to run `swift test`.
- External file monitoring currently uses a two-second snapshot poll; native event-driven monitoring is a later refinement.
