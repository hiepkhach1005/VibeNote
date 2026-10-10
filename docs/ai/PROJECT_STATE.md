# Project State

- Last updated: 2026-08-22
- Product: MacPad
- Platform: macOS 13+
- Stack: Swift, AppKit, Swift Package Manager
- Current phase: Phase 1 - Native app shell and document workflow
- Overall status: IN_PROGRESS

## Completed in current session

- Initialized Swift Package executable.
- Added native AppKit application shell.
- Added native menu bar and toolbar.
- Added multiple document tabs.
- Added new/open/save/save as/close workflow.
- Added UTF-8 and basic automatic encoding support.
- Added line numbers and status bar.
- Added find-next search field.
- Added find previous, undo/redo routing and unsaved-change confirmation.
- Added session persistence and recovery for open/unsaved documents.
- Added reload-from-disk and external file-change detection with Reload/Keep Local confirmation.
- Added a development `.app` packaging script.
- Added an explicit AppKit `NSApplication.run()` entry point so the packaged app creates its window correctly.
- Added a complete Notepad++-to-MacPad parity baseline and menu tracker.
- Replaced the oversized backend/frontend split with a focused `macpad-editor` skill.
- Added a separate `macpad-liquid-glass` skill for platform-specific materials and fallbacks.
- Added a persistent master prompt and resume prompt for parity-focused vibe coding.
- Added zoom controls.
- Added original app icon generation, vector logo and brand direction.
- Added persistent AI project documentation.
- Added explicit encoding/BOM/EOL document state, session persistence and Encoding menu controls.
- Added native Find and Replace panel with normal, extended and regex search, replacement and count.
- Added line duplicate/delete/move/join/trim/case commands and word-wrap toggle.
- Applied native header material to status chrome while keeping the editor content opaque.
- Added unit coverage for BOM/EOL persistence and SearchEngine behavior.
- Added common-language registry, persisted language selection and native TextKit syntax highlighting for comments, strings, numbers and keywords.
- Added one-application-instance enforcement for the packaged MacPad app.
- Added a visible AppKit document tab strip with selected/modified/pinned state, close buttons, scrolling and close-group context actions.
- Added same-window routing/deduplication for files opened while MacPad is already running and placed the custom tab chrome above the native `NSTabViewController` editor host.
- Corrected the window content layout so the visible tab row is below the unified toolbar; verified both one-tab and multi-tab windows visually.
- Added Notepad++-style Smart Highlighting: selecting a token highlights every matching occurrence through temporary AppKit layout attributes without changing document text or syntax attributes.
- Added a View > Smart Highlighting toggle and stronger dynamic Light/Dark editor, syntax and occurrence-highlight colors.
- Added a native Text Settings window with persisted font family, font size, editor colors, syntax colors and System/Light/Dark/Dracula/Nord/Solarized/One Dark/Custom themes; changes apply live to every open tab.
- Added explicit Light and Dark presets; Light uses a clean white editor and matching gutter, while Dark uses a stable dark editor surface.
- Strengthened editor readability with a high-contrast System palette, emphasized syntax fonts, brighter occurrence highlighting, sRGB color conversion and migration of the original low-contrast defaults.
- Added automatic contrast repair for stored and custom palettes so white text cannot remain on a light editor background; normalized colors are persisted and reflected back in the Settings color wells.
- Restored editor keyboard focus after Settings dismissal and tab changes; verified typing in a disposable Untitled tab without modifying user files.
- Fixed invisible editor text by replacing the oversized `NSRulerView` overlay with a constrained 46pt line-number gutter beside the native scroll view; verified visible typing with Dracula and line numbers enabled.
- Added native Finder drag/drop across the editor and window chrome; one or many extensionless/text/source files route through the existing deduplicated same-window tab opening flow, while folders are rejected.
- Corrected Finder drop decoding to recognize both modern file URLs and legacy filename lists; file payloads can no longer fall through to `NSTextView` and insert their filesystem path into document content.
- Added VS Code Explorer compatibility for external plain-path drag payloads and a lower-level `NSTextView.readSelection` guard; runtime inspection showed the user's active MacPad process started before the corrected binary was built.
- Added native middle-click close behavior to tab title and close-button controls, routed through the existing unsaved-change confirmation flow.
- Corrected the middle-click implementation to use AppKit `otherMouseDown` (the actual event for mouse button 2) and included the tab cell's padding area, matching Chrome-style close behavior across the whole tab.
- Changed main-window close and app termination to synchronously checkpoint the automatic recovery session and exit without a save dialog; startup now restores the exact persisted content for every tab, including saved-file tabs and unsaved notes.
- Changed the native toolbar to icon-only display with hover tooltips and capped tab title widths at 240pt with truncation plus full-path hover tooltips for long filenames.
- Right-aligned the default toolbar actions behind a leading flexible space, added dedicated Search and Find & Replace toolbar icons, and routed both plus Cmd+F to the native Find and Replace popup.
- Added a short-delay native toolbar hover-label controller so icon names appear after approximately 0.18 seconds without restoring text labels to the toolbar.

## Current task

Continue the next parity slice: complete selection-safe editor transforms/search options and deepen language lexer coverage.

## Next recommended tasks

1. Add conversion warnings, mixed-EOL handling and more legacy encoding mappings.
2. Finish SEARCH-001 through SEARCH-008: selection scope, persistent Style All Occurrences, Find in Files and Search Results.
3. Finish EDIT-004/005/007/014 with split-line, multi-line selection semantics and undo tests.
4. Implement VIEW-003 split/dual editor views and document list panels.
5. Deepen LANGUAGE-001/LANGUAGE-002 with complete registry, lexer accuracy, styles and folding.
6. Add tab drag reorder, tab colors/lock state and a keyboard MRU document switcher.
7. Expand Text Settings into per-language Style Configurator scopes and versioned import/export.

## Deferred

- Plugin system and Notepad++ plugin compatibility.
- Deep performance optimization and extreme large-file benchmarking.
- Windows-specific shell integration.

## Latest verification

- `swift build`: PASS.
- `swift build` after FILE-009/FILE-010: PASS.
- `swift build -c release`: PASS.
- `./scripts/build-app.sh`: PASS; generated unsigned development `dist/MacPad.app` with `MacPad.icns`.
- Launch smoke check: PASS; repeated packaged `open` calls reported one MacPad process, and multiple file-open events produced multiple editor/tab records in that process.
- Tab UI acceptance: PASS for one visible `Untitled` tab and multiple visible tabs (`Untitled`, `README.md`, `AGENTS.md`) in one window.
- Smart Highlighting implementation: `OccurrenceHighlighter` unit coverage added; manual Light/Dark packaged-app acceptance remains to be run.
- `swift test`: BLOCKED because the active developer directory is Command Line Tools and XCTest is unavailable; full Xcode is required.
- Current `swift build`: PASS after encoding/EOL, Find/Replace, editor command and chrome updates.
- Current `swift build`: PASS after Text Settings, theme presets and settings-driven syntax colors.
- Current `swift build`: PASS after FILE-015 native file-drop routing; drop-payload unit coverage was added but `swift test` remains blocked by missing XCTest.
- Current `swift build`: PASS after the FILE-015 path-insertion regression fix; modern URL, legacy Finder filename and plain-text separation tests were added.
- Release packaging: PASS after Finder/VS Code drag hardening; active pre-build process still requires a full quit/relaunch to load it.
- Current `swift build`: PASS after VIEW-001 middle-click tab close support.
- Current `swift build`: PASS after correcting VIEW-001 to AppKit `otherMouseDown`.
- Current `swift build`: PASS after FILE-007/FILE-014 close-without-prompt recovery changes; `swift test` remains blocked by missing XCTest.
- Current `swift build`: PASS after VIEW-001/VIEW-013 compact toolbar and long-tab-title presentation changes.
- Current `swift build`: PASS after right-aligned icon-only toolbar, fast hover labels and Search/Find & Replace popup toolbar actions.
- `./scripts/build-app.sh`: PASS; generated unsigned development [MacPad.app](../../dist/MacPad.app) with the updated toolbar and popup actions. `plutil -lint`: PASS.
- Current `swift build`: PASS after high-contrast palette, syntax emphasis and sRGB color conversion fixes.
- Current `swift build`: PASS after explicit Light/Dark themes and matching editor/gutter backgrounds.
- `swift build -c release`: PASS; `./scripts/build-app.sh`: PASS after explicit Light/Dark theme slice.
- Focus smoke check: PASS; a disposable Untitled tab accepted keyboard input and was discarded afterward.
- Contrast guard check: PASS in the source/runtime path; Light uses dark readable text, Dark uses light readable text, and legacy/custom low-contrast palettes are repaired on load and save.
- Visible-text acceptance: PASS in packaged Dracula theme with line numbers enabled; typed content, caret and gutter are visible together.

## 2026-10-10 — Prepare public GitHub source publication

- Refreshed the root README with the product workflow, implemented features, source-build steps, and development-preview limitations.
- Added ignore rules for local metadata, build outputs, generated SARIF reports, signing material, environment files, and private configuration.
- Ran Gitleaks against the Git candidate file snapshot and reviewed findings; no actual credentials were identified.
- Checked README relative links and image references. Application behavior was not changed and app build/test suites were not run for this documentation/publication task.
- Git commits use the account's GitHub noreply address.
