# Implementation Log

Append one entry for every feature slice. Never delete previous entries.

## 2026-08-17 - Initial native foundation

- Feature IDs: FILE-001, FILE-002, FILE-003, FILE-004, FILE-007, FILE-014, EDIT-001, SEARCH-001, PLATFORM-001
- Notepad++ behavior matched: basic document lifecycle, tabs, modified state, editor selection/search and status information.
- VibeNote behavior added: AppKit window/menu/toolbar, native tabs, JSON recovery session, macOS app bundle and original icon.
- Remaining gap: most built-in editing, search, view, encoding, language, settings, macro and tools features.
- Verification: `swift build`, `swift build -c release`, `./scripts/build-app.sh` passed.

## Entry template

```text
Date:
Feature IDs:
Notepad++ reference:
Expected behavior:
VibeNote behavior added:
Files changed:
Tests/build:
Before status:
After status:
Remaining gap:
Next feature ID:
```

## 2026-08-18 - Encoding, search and familiar editor commands

- Feature IDs: ENCODING-001, ENCODING-002, ENCODING-004, EDIT-004, EDIT-005, EDIT-007, EDIT-014, SEARCH-001, SEARCH-002, SEARCH-003, SEARCH-004, SEARCH-008, PLATFORM-002
- Notepad++ reference: official user-interface/manual parity baseline and the repository's PowerEditor/scintilla/regex responsibility split.
- Expected behavior: explicit encoding/EOL controls, find/replace modes and common line transforms accessible from familiar menus.
- VibeNote behavior added: document encoding/BOM/EOL model and persistence; native Find/Replace panel; normal/extended/regex matching; replace-all/count; duplicate/delete/move/join/trim/case commands; word wrap; header material status chrome.
- Files changed: `DocumentModel.swift`, `SessionStore.swift`, `SearchEngine.swift`, `FindPanelController.swift`, `EditorViewController.swift`, `MainWindowController.swift`, `AppCommands.swift`, tests and parity/AI tracking files.
- Tests/build: `swift build` PASS; XCTest cases added; `swift test` BLOCKED by active Command Line Tools without XCTest.
- Before status: encoding controls and full Find/Replace were absent; line transforms were NPP_ONLY; Liquid Glass chrome was not implemented.
- After status: all listed slices are `PARITY_IN_PROGRESS` because warnings, full selection semantics, file search, result panels and broader acceptance remain.
- Remaining gap: legacy code pages, conversion warnings, Find in Files/Search Results/mark-all, split lines, multi-line transform semantics and full command validation.
- Next feature ID: SEARCH-005 / SEARCH-007, then LANGUAGE-001.

## 2026-08-18 - Save a Copy As and Split Line follow-up

- Feature IDs: FILE-005, EDIT-005
- VibeNote behavior added: Save a Copy As writes an atomic copy without changing the active document identity; Split Line inserts a native undoable line break at the cursor.
- Tests/build: source slice included in the release/package verification; focused XCTest coverage remains blocked by the current Command Line Tools environment.
- Remaining gap: copy conflict confirmation and richer selection-aware split semantics.

## 2026-08-18 - Common language registry and highlighting

- Feature IDs: LANGUAGE-001, LANGUAGE-002
- VibeNote behavior added: extension-aware language detection, Language menu, session persistence and lightweight native token coloring for common languages.
- Files changed: `LanguageServices.swift`, `DocumentModel.swift`, `SessionStore.swift`, `EditorViewController.swift`, `MainWindowController.swift`, `AppCommands.swift` and trackers.
- Tests/build: `swift build` PASS; manual visual validation remains needed across Light/Dark Mode.
- Remaining gap: complete lexer coverage, folding, completion, UDL and style configuration.

## 2026-08-19 - Single VibeNote instance and document tab strip

- Feature IDs: FILE-002, FILE-008, VIEW-001, VIEW-002, VIEW-013, PLATFORM-001, PLATFORM-002.
- Notepad++ reference: official User Interface behavior for the tab bar, close button, pinning and tab context menu; macOS adaptation keeps all documents in one application window.
- Expected behavior: launching VibeNote repeatedly activates the existing app; opening several files creates/selects tabs in that same window; the tab row stays visible between toolbar and editor.
- VibeNote behavior added: bundle-level `LSMultipleInstancesProhibited`, explicit running-application activation guard, duplicate URL detection, AppKit tab strip with selected/modified/pinned state, close buttons, horizontal scrolling, Save/Pin/Close-group context actions, Next/Previous Tab commands and native `NSTabViewController` content below the tab chrome.
- Files changed: `Sources/VibeNote/SingleInstanceCoordinator.swift`, `Sources/VibeNote/main.swift`, `Sources/VibeNote/AppDelegate.swift`, `Sources/VibeNote/MainWindowController.swift`, `Sources/VibeNote/TabStripView.swift`, `scripts/build-app.sh`, parity and AI tracking files.
- Tests/build: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; packaged smoke run confirmed one VibeNote process while opening multiple files and debug output confirmed multiple editor/tab records.
- Before status: custom tab state was present but the tab row could be obscured by the tab controller's managed view, and repeated launches could appear as multiple app entries.
- After status: one-window/multi-tab architecture is implemented; parity remains `PARITY_IN_PROGRESS` pending drag reorder, tab colors/lock, MRU switcher, full accessibility audit and visual Light/Dark acceptance.
- Remaining gap: direct command-line launches of a second binary do not forward arbitrary argv file paths; LaunchServices/Finder open events are routed to the existing instance.
- Next feature ID: VIEW-003 / VIEW-002 MRU, then SEARCH-005 / SEARCH-007.

## 2026-08-19 - Visible tab row layout correction

- Feature IDs: VIEW-001, VIEW-013, PLATFORM-001, PLATFORM-002.
- Problem: the tab model existed, but `fullSizeContentView` allowed the unified toolbar to cover the first 36pt of the custom tab chrome, so users could not see tabs reliably.
- Fix: use the standard window content layout below the toolbar and keep a dedicated 36pt Liquid Glass/header-material tab row above the native `NSTabViewController` editor host.
- Acceptance: one-document window visibly shows an `Untitled` tab; opening `README.md` and `AGENTS.md` visibly shows all three tabs in one row, with the selected tab highlighted and close buttons present.
- Files changed: `Sources/VibeNote/MainWindowController.swift`, parity trackers and AI history.
- Verification: visual window capture passed for the one-tab and multi-tab cases; `swift build` and `./scripts/build-app.sh` passed.
- Remaining gap: drag reorder, tab colors, lock state, MRU switcher and full accessibility/appearance matrix remain.

## 2026-08-21 - Smart Highlighting and editor contrast

- Feature IDs: SEARCH-008, LANGUAGE-002, PLATFORM-001.
- Notepad++ reference: official Preferences > Highlighting behavior: selecting a token colors all matching pieces of text; the Smart Highlighting style is a background-only overlay. The official source uses an editor indicator for this visual layer.
- Expected behavior: selecting text highlights every occurrence while preserving document content, syntax colors and native selection; disabling the feature removes the overlay.
- VibeNote behavior added: `OccurrenceHighlighter` derives UTF-16 ranges through the shared search engine; `EditorViewController` applies/removes temporary `NSLayoutManager` background attributes on selection, edits, language changes and zoom; View > Smart Highlighting toggles it across all open tabs. Syntax/base/selection colors now use stronger dynamic Light/Dark values.
- Files changed: `Sources/VibeNote/OccurrenceHighlighter.swift`, `Sources/VibeNote/EditorViewController.swift`, `Sources/VibeNote/LanguageServices.swift`, `Sources/VibeNote/AppCommands.swift`, `Sources/VibeNote/MainWindowController.swift`, tests and parity/AI tracking files.
- Tests/build: `swift build` PASS; occurrence range XCTest added; `swift test` remains environment-blocked by missing XCTest in the active Command Line Tools.
- Before status: selected text did not highlight matching occurrences and syntax colors relied on low-contrast system accent colors.
- After status: automatic selected-token highlighting and an accessible app-wide toggle are implemented; persistent Style All Occurrences/mark styles, Find in Files and Search Results remain.
- Next feature ID: SEARCH-007/SEARCH-005, then EDIT-010 column selection.

## 2026-08-21 - Text Settings and theme palettes

- Feature IDs: SETTINGS-001, SETTINGS-003, LANGUAGE-002, PLATFORM-002.
- Notepad++ reference: official Preferences/Style Configurator behavior and the official Dracula palette specification: [Dracula color palette](https://draculatheme.com/contribute).
- Expected behavior: users can configure editor font family, size, foreground/background/selection colors and syntax colors, choose a familiar theme, and keep the choice across launches and tabs.
- VibeNote behavior added: `TextSettings` stores a versioned Codable model; `TextSettingsStore` persists it in UserDefaults; `TextSettingsWindowController` provides native AppKit popups, color wells and live updates; `EditorViewController` and `SyntaxHighlighter` consume the palette for all open tabs.
- Theme presets: VibeNote System, Dracula, Nord, Solarized, One Dark and Custom. Dracula uses the official foreground/background/selection semantic palette.
- Liquid Glass decision: the settings header uses native `.headerView` material while the code/text editing surface stays opaque and high contrast.
- Tests/build: `swift build` PASS; settings/theme XCTest coverage added; `swift test` remains blocked because the active developer directory is Command Line Tools without XCTest.
- Before status: SETTINGS-001 was a placeholder and SETTINGS-003 was not implemented.
- After status: global text appearance and theme presets are implemented; status remains `PARITY_IN_PROGRESS` pending per-language styles, import/export and accessibility acceptance.
- Remaining gap: complete Notepad++-style per-language Style Configurator and theme/settings import/export.
- Next feature ID: SETTINGS-003 per-language scopes, then SEARCH-005/SEARCH-007.

## 2026-08-21 - High-contrast editor correction

- Feature IDs: LANGUAGE-002, SETTINGS-001, SETTINGS-003, PLATFORM-002.
- Expected behavior: default editor content must remain immediately legible in Light Mode, with enough semantic color and weight to scan headings, comments, strings, numbers and keywords.
- VibeNote behavior added: replaced the restrained System palette with high-contrast Light/Dark values; made Markdown headings and keywords bold, comments italic, occurrence highlighting brighter, and the default font 14pt; set the text view to opaque explicit-color rendering; migrated legacy System settings.
- Color correctness: `NSColor` HEX parsing/serialization now uses sRGB, preventing saved theme values from shifting during color-space conversion.
- Files changed: `Sources/VibeNote/TextSettings.swift`, `Sources/VibeNote/LanguageServices.swift`, `Sources/VibeNote/EditorViewController.swift`, `Sources/VibeNote/LineNumberRulerView.swift`, tests and parity/AI tracking files.
- Tests/build: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; high-contrast palette and HEX round-trip XCTest cases added; `swift test` remains blocked by missing XCTest in the active Command Line Tools environment.
- Before status: Light Mode body and token colors looked washed out in the packaged app.
- After status: System settings migrate to a stronger palette and syntax carries deliberate weight/color emphasis; full appearance/accessibility matrix remains pending.

## 2026-08-21 - Explicit Light and Dark themes

- Feature IDs: SETTINGS-001, SETTINGS-003, PLATFORM-002.
- Expected behavior: users can choose an explicit Light or Dark editor surface instead of following the macOS appearance, with the gutter matching the editor background.
- VibeNote behavior added: `TextThemeID.light` and `.dark` are available in the native Text Settings popup; Light uses `#FFFFFF` for editor and gutter surfaces, Dark uses `#171A21`; `LineNumberRulerView` now paints from the active editor background rather than a translucent window background.
- Before status: only adaptive VibeNote System and named syntax themes were available; the gutter could appear gray against a white editor.
- After status: explicit Light/Dark choices are persisted through the existing settings store and applied to every tab; parity remains `PARITY_IN_PROGRESS` pending per-language scopes and full appearance/accessibility acceptance.
- Tests/build: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; explicit Light/Dark XCTest coverage added; `swift test` remains blocked by missing XCTest in the active Command Line Tools environment.

## 2026-08-21 - Editor focus recovery

- Feature IDs: SETTINGS-001, VIEW-001, PLATFORM-001.
- Problem: after interacting with Text Settings or the tab strip, keyboard events could remain owned by the settings/chrome surface, making the editor appear non-editable.
- Fix: added `EditorViewController.focus()`, explicit `NSTextView.isSelectable = true`, focus restoration on tab selection and a Settings window delegate callback that returns key status and first responder to the selected editor.
- Acceptance: disposable Untitled tab accepted keyboard input after opening the packaged app; the probe tab was discarded and no user file was changed.
- Tests/build: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; `swift test` remains blocked by missing XCTest in the active Command Line Tools environment.

## 2026-08-21 - Automatic text contrast repair

- Feature IDs: SETTINGS-001, SETTINGS-003, LANGUAGE-002, PLATFORM-001.
- Expected behavior: active text and syntax colors remain readable against the active editor surface; selecting or loading white text on a light surface must not make input invisible.
- VibeNote behavior added: `TextPalette` validates foreground/comment/string/number/keyword/heading colors against the background, chooses a readable dark/light fallback when contrast is insufficient, and normalizes both persisted palettes on load and every settings mutation. The editor consumes guarded colors directly, while the Settings window reloads color wells after normalization.
- Before status: a saved or custom white foreground could remain white on the Light/white background.
- After status: Light produces dark readable body/token text, Dark produces light readable body/token text, and invalid low-contrast legacy/custom values are repaired and persisted.
- Tests/build: `swift build` PASS; `swift build -c release` PASS; `./scripts/build-app.sh` PASS; white-on-white contrast XCTest coverage added; `swift test` remains blocked by missing XCTest in the active Command Line Tools environment.

## 2026-08-22 - Editor text and gutter rendering repair

- Feature IDs: SETTINGS-001, SETTINGS-003, LANGUAGE-002, PLATFORM-001.
- Before status: document text existed and accepted edits, but an unconstrained line-number `NSRulerView` painted over the editor, hiding text, caret and selection.
- VibeNote behavior added: line numbers render in a dedicated fixed-width AppKit gutter next to the native editor scroll view and redraw with scrolling; theme foreground and background remain explicit and readable.
- Acceptance: Dracula text and line numbers are visible simultaneously in the packaged app, with keyboard input and caret feedback intact.
- Tests/build: `swift build` PASS; `./scripts/build-app.sh` PASS; `swift test` remains environment-blocked by missing XCTest.
## 2026-08-22 - Native Finder file drop

- Feature ID: FILE-015.
- Notepad++ behavior matched: dropping one or many files onto the application opens them as documents without creating a separate application instance.
- VibeNote adaptation: AppKit drop destinations cover the editor and outer window shell, accept regular files regardless of extension, reject directories, deduplicate URLs and route loading/errors through the existing `MainWindowController.open(urls:)` path.
- Data safety: dropping a file never replaces the selected tab or unsaved text; each new file gets its own tab, already-open files are selected, and unreadable files use the existing native error alert.
- Files: `FileDropView.swift`, `EditorViewController.swift`, `MainWindowController.swift`, tests and tracking documents.
- Tests: drop-payload coverage added for extensionless files, duplicate URLs and directory rejection. `swift build` PASS; `swift test` BLOCKED because XCTest is unavailable in the selected Command Line Tools environment.
- Before status: `NPP_ONLY`.
- After status: `PARITY_IN_PROGRESS` pending interactive packaged-app Finder drag/drop/Open With acceptance and future sandbox security-scope work.

## 2026-08-22 - FILE-015 Finder payload compatibility correction

- Acceptance failure: a file dropped directly over `NSTextView` could be inserted as a filesystem path instead of opening as a tab.
- Root cause: Finder pasteboards are not guaranteed to bridge through the single `[NSURL]` decoding path; the empty result allowed AppKit's normal string-drop implementation to run.
- Correction: `FileDropPayload` now merges `public.file-url` pasteboard items, URL pasteboard-reading objects and legacy `NSFilenamesPboardType` paths, then validates/deduplicates regular files.
- Safety rule: when a pasteboard advertises a file representation, `FileDropTextView` either opens validated files or rejects the drop; it never delegates that payload to text insertion. Non-file text dragging remains native.
- Tests/build: modern/legacy/plain-text regression cases added; `swift build` PASS; `swift test` remains blocked by missing XCTest.
- Status remains `PARITY_IN_PROGRESS` until the rebuilt packaged app passes interactive Finder and Open With acceptance.

## 2026-08-22 - FILE-015 VS Code payload and stale-runtime hardening

- Evidence: the reported app process started before the corrected executable timestamp, so previous acceptance used stale code still resident in memory.
- VS Code adaptation: external plain-text payloads that consist of existing absolute file paths are interpreted as files during drag only; normal paste and internal text dragging remain editor text operations.
- AppKit hardening: file handling now covers `acceptableDragTypes`, drag enter/update/prepare/perform and `readSelection(from:type:)`, preventing the lower-level selection reader from inserting paths.
- Build/test status remains `PARITY_IN_PROGRESS` until the user restarts the packaged app and validates Finder plus VS Code drags.
- Verification: debug and release packaging PASS; XCTest execution remains environment-blocked.

## 2026-08-22 - VIEW-001 middle-click tab close

- Expected behavior: middle-clicking a document tab closes that tab, matching the familiar Notepad++ tab workflow.
- VibeNote behavior added: `TabTitleButton` handles AppKit button 2 events on both the tab title and close-button area and emits the existing `.close(index)` action.
- Data safety: closing uses the existing `confirmClose(editor:)` path, so modified documents cannot be discarded accidentally; closing the last tab creates a new Untitled tab as before.
- Files changed: `Sources/VibeNote/TabStripView.swift`, parity/AI tracking files and manual test plan.
- Verification: `swift build` PASS; `swift test` remains blocked by missing XCTest; packaged interactive middle-click acceptance remains pending after restart.

## 2026-08-22 - VIEW-001 middle-click event correction

- User clarification: the intended behavior is Chrome-style middle-click anywhere on a tab, not a separate close-button interaction.
- Root cause: AppKit sends mouse button 2 through `otherMouseDown`, so the initial `mouseDown` override did not receive the event.
- Fix: `TabTitleButton` and the new `TabCellView` override `otherMouseDown`, close the clicked index and cover title, close-button and padding hit areas.
- Data safety: the action remains `.close(index)` and therefore uses the existing Save/Cancel/Discard confirmation for modified documents.
- Verification: `swift build` PASS; `swift test` remains blocked by missing XCTest; manual packaged-app middle-click acceptance remains pending after restart.
- Status remains `PARITY_IN_PROGRESS` because tab reorder/colors/lock and full accessibility acceptance are still outstanding.

## 2026-08-22 - FILE-007/FILE-014 automatic close recovery

- Expected behavior: closing the main editor window/app should not interrupt with a save dialog; the next launch should restore all open documents and unsaved note text.
- VibeNote behavior added: `windowShouldClose` synchronously saves the JSON recovery session, requests application termination and avoids `confirmCloseAll`; `applicationShouldTerminate` checkpoints again and terminates immediately.
- Recovery behavior: `MainWindowController.restoreSession()` now reconstructs every persisted tab from session content, including files that were not marked modified, preserving URL, modified state, encoding/BOM, EOL, language and selected tab.
- Safety boundary: this no-prompt behavior applies to main-window/app termination only. Closing an individual tab still asks before discarding modified content.
- Recovery location: `~/Library/Application Support/VibeNote/session.json`, written atomically by `SessionStore`.
- Tests/build: session JSON round-trip coverage added; `swift build` PASS; `swift test` remains blocked by missing XCTest.
- Status: FILE-007 and FILE-014 remain `PARITY_IN_PROGRESS` pending crash markers, named sessions and user-facing recovery UI.

## 2026-08-22 - VIEW-001/VIEW-013 compact chrome and tab tooltips

- Expected behavior: native toolbar actions should use compact icons with labels available on hover; long document names must not make the tab row unusably wide while remaining discoverable.
- VibeNote behavior added: `NSToolbar.displayMode = .iconOnly`, existing item labels/tooltips are retained, tab cells are capped at 240pt, titles use tail truncation and full file paths remain available through tab tooltips.
- Files changed: `Sources/VibeNote/MainWindowController.swift`, `Sources/VibeNote/TabStripView.swift`, test plan and parity/AI tracking files.
- Verification: `swift build` PASS; `swift test` remains blocked by missing XCTest; packaged visual hover acceptance remains pending.

## 2026-08-22 - SEARCH-002/VIEW-013 toolbar alignment and popup access

- Expected behavior: keep the toolbar icon-only and familiar, align its action group to the right, reveal labels quickly on hover, and make Search/Replace immediately discoverable.
- VibeNote behavior added: a leading flexible space right-aligns the default toolbar actions; dedicated Search and Find & Replace icons open the native Find and Replace popup; Cmd+F uses the same popup route.
- Hover behavior: `ToolbarTooltipController` observes toolbar item views and shows the item label after an approximately 0.18 second delay without changing the compact icon-only presentation.
- Data/accessibility: toolbar labels remain on `NSToolbarItem`, custom buttons retain accessibility labels/help, and long tab names retain full-path hover tooltips.
- Files changed: `Sources/VibeNote/MainWindowController.swift`, `Sources/VibeNote/ToolbarTooltipController.swift`, parity/AI tracking files and manual test plan.
- Verification: `swift build` PASS; `./scripts/build-app.sh` PASS; `plutil -lint` PASS. `swift test` remains blocked because XCTest is unavailable; packaged visual/click acceptance remains pending after a full restart.
