# Changelog

## Unreleased - 2026-08-17

- Added initial native macOS editor shell.
- Added tabs, basic file operations, line numbers, status bar, search and zoom.
- Added project documentation and feature tracking.
- Verified debug and release builds.
- Added full built-in parity tracking against the official Notepad++ repository/manual.
- Added persistent master/resume prompts and project-local backend/frontend skills.
- Added Liquid Glass placement rules and familiar Notepad++ layout guidance.
- Consolidated backend/frontend skills into `macpad-editor` and added dedicated `macpad-liquid-glass` skill.
- Added reload-from-disk and external file-change detection with safe conflict handling.

## Unreleased - 2026-08-18

- Added explicit encoding, BOM and LF/CRLF/CR handling with session persistence and status visibility.
- Added native Find and Replace with normal, extended and regular-expression modes, replacement and count.
- Added familiar line editing commands and word-wrap toggle.
- Added restrained native material treatment to status chrome; editor content remains opaque.
- Added common-language menu/detection and lightweight native syntax highlighting.

## Unreleased - 2026-08-19

- Enforced a single MacPad application instance for the packaged app.
- Added same-window multi-document tabs with selected/modified/pinned state, close buttons, horizontal scrolling and tab context actions.
- Added Next/Previous Tab commands and placed the custom tab row above the native editor content.
- Corrected unified-toolbar window layout so the tab row is visible even when only one document is open; visually verified one-tab and three-tab windows.

## Unreleased - 2026-08-21

- Added Notepad++-style Smart Highlighting for every occurrence of the selected token, with a View toggle and non-destructive AppKit overlay.
- Added stronger dynamic Light/Dark editor and syntax colors plus explicit native selection contrast.
- Added native Text Settings with persisted font family, font size, editor/syntax color wells and MacPad System, Dracula, Nord, Solarized, One Dark and Custom themes; changes apply to all open tabs.
- Added explicit Light and Dark themes, with a clean white Light editor/gutter and a stable dark editor surface.
- Increased default text contrast, made Markdown headings and language keywords visually prominent, brightened Smart Highlighting, fixed sRGB HEX color conversion and migrated existing low-contrast System settings.
- Added automatic contrast repair so white-on-white foreground and syntax colors are replaced with readable colors for the active editor background; repaired palettes are persisted and synchronized back to Text Settings.

## Unreleased - 2026-08-22

- Fixed invisible text, caret and selection caused by an oversized line-number ruler overlay.
- Rebuilt line numbers as a constrained, scroll-synchronized 46pt gutter beside the native text editor.
- Normalized native text-view/container setup and explicit theme typing attributes.
- Fixed intermittent release launches with no window by retaining the AppKit application delegate for the run-loop lifetime.
- Added native Finder drag/drop over the editor, tabs and window chrome; dropped files open as deduplicated tabs in the existing MacPad window regardless of filename extension.
- Fixed dropped Finder files being inserted as path strings by recognizing both modern file URLs and legacy filename pasteboard payloads before `NSTextView` fallback handling.
- Added middle-click close to document tabs, including the tab title and close-button area, with existing unsaved-change protection.
- Corrected middle-click tab closing to use AppKit's `otherMouseDown` event and cover the entire tab cell, including padding.
- Main-window close and app quit now save an automatic recovery checkpoint and exit without Save/Discard/Cancel; reopening restores the exact tabs and contents. Individual tab close remains protected.
- Made the toolbar icon-only with hover tooltips and constrained long tab titles with full-path hover tooltips.
- Right-aligned the toolbar actions, added fast native hover labels, and exposed the Find and Replace popup through dedicated Search and Find & Replace toolbar icons plus Cmd+F.
