# Session Log

## 2026-08-17 - Initial project bootstrap

- Repository was empty and had no Git metadata.
- Created Swift Package Manager AppKit foundation.
- Created persistent AI project documentation.
- Implemented the first native editor vertical slice.
- `swift build`: PASS.
- `swift build -c release`: PASS.
- `swift test`: BLOCKED by missing XCTest in the active Command Line Tools environment.
- Initialized Git repository with branch `main`; no commit was created.
- Added previous-match search, routed undo/redo through the selected editor, and added save/discard confirmation for modified documents.
- Added JSON-backed document recovery/session restore and a native `.app` packaging script.
- Added automatic `.icns` generation from the original vector logo.
- Fixed packaged-app launch by adding an explicit AppKit application entry point; verified one window is created after `open dist/MacPad.app`.
- Added parity master prompt, resume prompt, Notepad++ baseline, detailed feature/menu matrices, CSV tracker and append-only parity implementation log.
- Added and populated `macpad-editor` and `macpad-liquid-glass` project skills.
- Skill validator was attempted but is blocked by missing Python `yaml` module in the current environment; manual checks found no template TODOs in the completed skills.
- Re-ran debug and release builds after the final source changes: PASS.
- Audited the official Notepad++ repository structure: `PowerEditor`, `scintilla`, `lexilla` and regex are better conceptual boundaries than a web-style BE/FE split.
- Removed project-local `macpad-backend` and `macpad-frontend` skills.
- Added consolidated `macpad-editor` skill and focused `macpad-liquid-glass` skill.
- Validated both skill metadata with Ruby YAML parsing, confirmed no stale BE/FE references outside historical logs, and re-ran `swift build`: PASS.
- Implemented FILE-009 reload-from-disk and FILE-010 external file-change detection with safe Reload/Keep Local prompts.
- Added `FileSnapshot`, corrected modified-tab title rendering, added reload menu command and snapshot unit coverage.
- Re-ran `swift build` after the feature slice: PASS.
- Next: implement ENCODING-002/ENCODING-004 encoding and EOL controls.

## 2026-08-18 - Encoding, search and familiar editor commands

- Feature IDs: ENCODING-001, ENCODING-002, ENCODING-004, EDIT-004, EDIT-005, EDIT-007, EDIT-014, SEARCH-001, SEARCH-002, SEARCH-003, SEARCH-004, SEARCH-008, PLATFORM-002.
- Reconciled the tracker with the source before continuing; the previously added reload/external-change slice remains intact.
- Added explicit UTF-8/UTF-8 BOM/UTF-16 state, UTF-32 detection, line-ending detection/normalization and LF/CRLF/CR serialization.
- Persisted encoding, BOM and EOL choices in session recovery.
- Added native Find and Replace panel with normal, extended and regex modes, case sensitivity, whole-word, wrap-around, replace, replace-all and count.
- Added line duplicate/delete/move/join/trim/case commands and word-wrap toggle.
- Added native header material status chrome; the editor content remains opaque for readability and accessibility.
- Added unit coverage for EOL/BOM persistence and search modes/replacement/invalid regex.
- `swift build`: PASS. `swift test`: BLOCKED because active developer directory is Command Line Tools and XCTest is unavailable.
- Next: complete selection-safe transforms and Find in Files/Search Results, then language registry/highlighting.

## 2026-08-18 - Language registry and native highlighting

- Feature IDs: LANGUAGE-001, LANGUAGE-002.
- Added common language selection (Swift, Python, JavaScript, JSON, HTML, CSS, Shell, Markdown, C/C++, SQL), extension detection and session persistence.
- Added a native NSTextStorage highlighter for comments, strings, numbers and common keywords without putting any material behind editor content.
- `swift build`: PASS.
- Status remains `PARITY_IN_PROGRESS`: full Notepad++/Lexilla language coverage, folding, completion, UDL and style configuration are still pending.
- Next: implement robust encoding/EOL handling and the full Find/Replace panel.

## 2026-08-19 - Single-instance multi-tab continuation

- Continued the requested Notepad++-familiar workflow: one MacPad application instance, many documents as tabs in that same window.
- Added `SingleInstanceCoordinator`, `LSMultipleInstancesProhibited`, duplicate URL detection and AppKit open-event routing.
- Reworked the tab surface into an explicit horizontally scrollable AppKit tab strip above the native `NSTabViewController` editor host.
- Tab actions currently include select, close, save, pin/unpin, close all but this, close left/right and close unchanged; Next/Previous Tab commands are wired.
- `swift build`: PASS; `swift build -c release`: PASS; `./scripts/build-app.sh`: PASS.
- Packaged smoke verification: repeated open commands kept one MacPad process; debug run confirmed multiple editor/tab records. Full visual Light/Dark and accessibility acceptance remains pending when the desktop session is unlocked.
- Updated parity matrix, CSV tracker, menu matrix, implementation log, project state, backlog, known issues and changelog.

## 2026-08-19 - Tab visibility correction

- User reported that the tab section was still invisible, including when only one file was open.
- Root cause: `.fullSizeContentView` placed the custom tab chrome under the unified toolbar.
- Removed that window style, kept the native header-material tab chrome below the toolbar, and forced the selected editor host to relayout after tab selection.
- Visual acceptance passed: one file shows `Untitled`; opening `README.md` and `AGENTS.md` shows three tabs in the same window with selection highlight and close buttons.
- `swift build`: PASS; `./scripts/build-app.sh`: PASS.

## 2026-08-21 - Smart Highlighting and editor contrast

- Audited the current AppKit editor against the official Notepad++ manual/source. The missing behavior was Smart Highlighting: selected text had no occurrence overlay, while Notepad++ highlights matching pieces using a background-only indicator.
- Added `OccurrenceHighlighter` with UTF-16-safe ranges, automatic updates on selection/edit/language/zoom and a View > Smart Highlighting toggle shared by all document tabs.
- Replaced faint system syntax colors with deliberate dynamic Light/Dark semantic colors and made native selection colors explicit for contrast.
- Added unit coverage for case-insensitive whole-word occurrence matching.
- `swift build`: PASS. `swift test`: still BLOCKED by the active Command Line Tools environment without XCTest.
- Remaining: manually verify Light/Dark screenshots in the packaged app, then implement persistent Style All Occurrences/mark styles, Search Results and Find in Files.

## 2026-08-21 - Text Settings and theme palettes

- Feature IDs: SETTINGS-001, SETTINGS-003, LANGUAGE-002, PLATFORM-002.
- User request: add font family, font size, text-related color settings and commonly used editor themes such as Dracula.
- MacPad behavior added: native Text Settings window with live font family/size changes, editor foreground/background/selection/smart-highlighting colors, comment/string/number/keyword/heading colors, and MacPad System, Dracula, Nord, Solarized, One Dark and Custom presets.
- Settings are versioned through `TextSettingsStore` and persisted in UserDefaults; one settings value is applied to every open editor tab.
- Liquid Glass scope: header material is used only for the Text Settings window chrome; the editor/text surface remains opaque for readability.
- Files changed: `Sources/MacPad/TextSettings.swift`, `Sources/MacPad/TextSettingsWindowController.swift`, `Sources/MacPad/MainWindowController.swift`, `Sources/MacPad/EditorViewController.swift`, `Sources/MacPad/LanguageServices.swift`, tests and parity/AI tracking files.
- Tests/build: `swift build` PASS; `swift test` remains blocked by the active Command Line Tools environment without XCTest; packaged app verification remains next.
- Before status: Preferences was a placeholder and syntax colors were fixed in code.
- After status: global text appearance is configurable and persisted; parity remains `PARITY_IN_PROGRESS` because per-language Style Configurator scopes, import/export and full accessibility review remain.
- Next feature ID: SETTINGS-003 per-language scopes, then SEARCH-005/SEARCH-007.

## 2026-08-21 - High-contrast editor correction

- Feature IDs: LANGUAGE-002, SETTINGS-001, SETTINGS-003, PLATFORM-002.
- User feedback: editor text and syntax colors remained too pale and difficult to scan in the Light appearance.
- Diagnosis: the initial System palette was too restrained for dense editor content, existing installs retained the old palette, and HEX colors were converted through a non-sRGB path.
- Fix: changed the System palette to high-contrast semantic colors, raised the default font size to 14, emphasized Markdown headings and language keywords with bold fonts, used italic semantic comments, brightened occurrence highlighting, converted HEX through sRGB and migrated the old System defaults without touching Custom themes.
- Verification: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; packaged app remained one process. `swift test` remains blocked because XCTest is unavailable in the active Command Line Tools environment.
- Remaining: validate contrast in a full Light/Dark matrix on a normal interactive desktop session and continue per-language Style Configurator work.

## 2026-08-21 - Explicit Light and Dark themes

- Feature IDs: SETTINGS-001, SETTINGS-003, PLATFORM-002.
- User request: add explicit Light/Dark text themes and make the Light editor background clean white instead of gray.
- MacPad behavior added: Text Settings now lists `Light` and `Dark` separately from adaptive `MacPad System`; Light pins a white editor and gutter surface, while Dark pins a dark editor and gutter surface.
- Files changed: `Sources/MacPad/TextSettings.swift`, `Sources/MacPad/LineNumberRulerView.swift`, tests and parity/AI tracking files.
- Verification: `swift build`, `swift build -c release` and `./scripts/build-app.sh` PASS; explicit Light/Dark unit coverage was added. `swift test` remains blocked by the active Command Line Tools environment without XCTest.
- Remaining: full appearance/accessibility matrix and per-language style scopes.

## 2026-08-21 - Automatic text contrast repair

- Feature IDs: SETTINGS-001, SETTINGS-003, LANGUAGE-002, PLATFORM-001.
- User feedback: text appeared white on a white/light editor background, making the editor look empty and preventing visible typing feedback.
- Diagnosis: a persisted or custom palette could contain a foreground/token color with insufficient contrast against its selected editor background; applying the color directly allowed white-on-white to survive.
- Fix: added contrast-ratio validation for foreground and syntax roles, a background-aware dark/light fallback, normalization on settings load/theme/color changes, and live style application. Settings color wells reload after normalization so the UI reflects the effective palette.
- Verification: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; white-on-white normalization XCTest coverage added. `swift test` remains blocked because XCTest is unavailable in the active Command Line Tools environment.
- Remaining: full Light/Dark accessibility matrix and per-language Style Configurator scopes.

## 2026-08-21 - Editor focus recovery

- Feature IDs: SETTINGS-001, VIEW-001, PLATFORM-001.
- User feedback: typing stopped working after the theme/settings update.
- Diagnosis: Settings and tab chrome could retain first responder instead of returning keyboard focus to the editor.
- Fix: `EditorViewController` now exposes a native focus method; the text view explicitly remains selectable; view appearance, tab selection and Settings dismissal restore the selected editor as first responder.
- Verification: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; a disposable Untitled tab accepted `focus-probe` keyboard input and was discarded without touching user files.

## 2026-08-22 - Invisible text root-cause fix

- Feature IDs: SETTINGS-001, SETTINGS-003, LANGUAGE-002, PLATFORM-001.
- User feedback: input changed line/column state but neither text, caret nor selection was visible, including with a high-contrast Dracula foreground.
- Root cause: `LineNumberRulerView` was an `NSRulerView` initialized without its owning scroll view; its drawing surface expanded over the complete editor and painted the theme background above the text view.
- Fix: replaced the native ruler attachment with a constrained 46pt AppKit gutter beside `NSTextView.scrollableTextView()`, synchronized gutter redraw with scroll bounds, normalized the text-container lifecycle and matched editor appearance to the selected light/dark surface.
- Acceptance: packaged app visibly rendered the restored two-line probe with line numbers enabled; toggling line numbers no longer covers the editor.
- Verification: `swift build` PASS; release app packaging PASS; `swift test` remains blocked because XCTest is unavailable with the active Command Line Tools developer directory.
- Release follow-up: retained `AppDelegate` for the complete `NSApplication.run()` lifetime so optimized builds cannot remain alive without creating a window.
## 2026-08-22 - Finder drag/drop file opening

- Feature ID: FILE-015.
- Added native file drop handling to the main window shell and `NSTextView` surface so one or many Finder files open as tabs in the same MacPad window.
- Files are accepted independently of extension, duplicate URLs select the existing tab, directories are ignored and files that cannot be read continue through the existing safe load error path.
- Added payload tests for extensionless files, deduplication and directory rejection.
- `swift build`: PASS. `swift test`: BLOCKED because the active Command Line Tools environment does not provide XCTest.
- Remaining: packaged-app interactive Finder drag/drop and Open With acceptance, then mark FILE-015 complete if successful.

## 2026-08-22 - Finder drop path-insertion regression fix

- Feature ID: FILE-015.
- User acceptance found that dropping a file over the editor inserted its filesystem path instead of opening the content in a tab.
- Root cause: the pasteboard decoder only accepted one bridged NSURL representation; when Finder supplied another modern/legacy representation, `FileDropTextView` delegated to `NSTextView`'s default string-drop behavior.
- Fix: decode per-item `public.file-url`, bridged URL objects and `NSFilenamesPboardType`; register both file types and never invoke the text fallback when a file representation is present.
- Plain dragged text still follows normal editor behavior, while dropped files route exclusively to `MainWindowController.open(urls:)`.
- `swift build`: PASS. Added regression tests for modern URLs, legacy Finder filenames and plain dragged text. `swift test`: still blocked because XCTest is unavailable.

## 2026-08-22 - VS Code drag compatibility and runtime verification

- Feature ID: FILE-015.
- Screenshot acceptance still showed path insertion from both Finder and VS Code.
- Runtime evidence: active MacPad PID 3356 started at 17:46:40 while the corrected packaged executable was built at 18:02:14, confirming the test was running an older in-memory binary.
- Additional hardening: external plain absolute-path payloads from VS Code Explorer are resolved only during drag operations; plain path paste remains text. `acceptableDragTypes`, `performDragOperation` and `readSelection(from:type:)` now all prevent file payloads from reaching text insertion.
- Root window/chrome and editor surfaces share the same Finder/VS Code path decoder.
- Verification: `swift build` PASS and `./scripts/build-app.sh` PASS. `swift test` remains blocked solely by missing XCTest in the selected Command Line Tools environment.

## 2026-08-22 - Middle-click tab close

- Feature ID: VIEW-001.
- Added AppKit middle-click handling to the tab title and close-button controls.
- The event routes through `MainWindowController.closeEditor(at:)`, preserving Save/Cancel/Discard confirmation for modified documents and creating a replacement Untitled tab if the final tab is closed.
- `swift build`: PASS. Manual acceptance remains to be performed on the rebuilt packaged app; `swift test` remains blocked because XCTest is unavailable.

## 2026-08-22 - Correct Chrome-style middle-click event

- Feature ID: VIEW-001.
- User clarified that the desired interaction is exactly Chrome-style middle-click anywhere on the tab to close it.
- Root cause: the first implementation overrode `mouseDown`, but AppKit dispatches mouse button 2 through `otherMouseDown`.
- Fix: `TabTitleButton` and `TabCellView` now handle `otherMouseDown` with button number 2, covering the title, close-button area and tab padding while retaining the existing close confirmation flow.
- `swift build`: PASS. Packaged interactive acceptance remains pending after restarting the app.

## 2026-08-22 - Automatic close checkpoint and session restore

- Feature IDs: FILE-007, FILE-014.
- User requested Chrome/Notepad++-style close behavior for the main MacPad window: no save dialog, automatic temporary recovery and exact restoration on next launch.
- Main-window `windowShouldClose` now calls `persistSession()`, requests app termination and returns without showing a document-save alert. `applicationShouldTerminate` also checkpoints and returns `.terminateNow` for Cmd-Q/other app termination paths.
- Session restoration now treats the persisted JSON session as authoritative for every tab, not only modified/Untitled tabs, preserving exact content, encoding, EOL, language, modified state and selected tab.
- Individual tab close actions still use Save/Cancel/Discard to protect a note closed intentionally.
- `swift build`: PASS. `swift test`: BLOCKED because the active Command Line Tools environment has no XCTest.

## 2026-08-22 - Compact toolbar and long-tab tooltips

- Feature IDs: VIEW-001, VIEW-013.
- Toolbar now uses AppKit `.iconOnly`; each toolbar item retains its label as a hover tooltip and customization-palette label.
- Tab cells cap their width at 240pt, use tail truncation for long names and keep the complete file path in the hover tooltip.
- `swift build`: PASS. `swift test`: remains blocked because XCTest is unavailable in the active Command Line Tools environment.

## 2026-08-22 - Right-aligned toolbar and Search/Replace popup access

- Feature IDs: SEARCH-002, VIEW-013.
- Added a leading flexible toolbar space so the default icon-only action set is aligned to the right while remaining customizable.
- Added Search and Find & Replace toolbar icons; both open the existing native Find and Replace popup, and Cmd+F now opens that popup instead of focusing the hidden optional search-field item.
- Added `ToolbarTooltipController` with an approximately 0.18 second hover delay for action labels; full tab-path hover tooltips remain available for truncated filenames.
- Corrected toolbar button accessibility help interpolation while retaining labels for VoiceOver and customization.
- `swift build`: PASS; `./scripts/build-app.sh`: PASS; `plutil -lint`: PASS. `swift test` remains blocked because XCTest is unavailable in the active Command Line Tools environment. Packaged visual and click acceptance remains pending after a full app restart.

## 2026-10-10 — Prepare public GitHub source publication

- Refreshed the root README with the product workflow, implemented features, source-build steps, and development-preview limitations.
- Added ignore rules for local metadata, build outputs, generated SARIF reports, signing material, environment files, and private configuration.
- Ran Gitleaks against the Git candidate file snapshot and reviewed findings; no actual credentials were identified.
- Checked README relative links and image references. Application behavior was not changed and app build/test suites were not run for this documentation/publication task.
- Git commits use the account's GitHub noreply address.
