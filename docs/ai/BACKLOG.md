# Backlog

## P0 - Current release foundation

- [~] Add unsaved-change confirmation before closing an individual tab; window/app close now checkpoints and exits without a prompt.
- [~] Add autosave/recovery session (automatic close checkpoint and exact tab restore implemented; crash marker/UI pending).
- [~] Add robust encoding and line-ending service (model, BOM, LF/CRLF/CR menu; warnings pending).
- [~] Add Save All and close-multiple-tabs commands.
- [~] Add full find/replace panel (native popup is available from menu and toolbar Search/Find & Replace actions; file search and result panel pending).
- [~] Add Notepad++-style Smart Highlighting for the selected token (automatic occurrence overlay is available; persistent Style All Occurrences remains).
- [~] Add unit tests for document loading and saving (tests added; XCTest blocked by active Command Line Tools).
- [~] Enforce one MacPad application instance with a visible multi-document tab strip (middle-click close is implemented; drag reorder, colors, lock and MRU remain).
- [~] Keep toolbar compact with right-aligned icon-only controls, fast hover labels and full-name tooltips for long tab titles.
- [~] Accept one or many files dragged from Finder anywhere over MacPad and route them into existing tabs (implementation complete; packaged-app Finder/Open With acceptance pending).

## P1 - Editor functionality

- [ ] Column/block selection.
- [ ] Multi-caret editing.
- [ ] Bookmarks.
- [~] Line operations (duplicate/delete/move/join/split/trim/case conversion; full selection semantics pending).
- [ ] Invisible characters and indentation guides.
- [ ] Split views and clone/move document.
- [ ] Keyboard MRU document switcher and tab drag reorder/colors/lock state.
- [ ] Search in files and replace in files.
- [ ] Search results panel.
- [ ] Function list and document map.

## P1 - Language tooling

- [~] Language registry (common source/document types are available; complete registry pending).
- [~] Syntax highlighting (native basic token colors are available; lexer-accurate highlighting pending).
- [ ] Code/comment folding.
- [ ] Auto-completion.
- [ ] User Defined Language editor.
- [~] Style Configurator and themes (global font, size, editor/syntax colors and common presets implemented; per-language scopes and import/export pending).

## P2 - Workflow and customization

- [ ] Sessions, workspaces and project panels.
- [ ] Macro recording and playback.
- [ ] External commands with confirmation.
- [ ] Hash/checksum tools.
- [ ] Shortcut Mapper.
- [ ] Toolbar customization.
- [ ] Localization.
- [ ] Accessibility audit.
- [ ] Print and print preview.

## Deferred

- [ ] Plugin system.
- [ ] Notepad++ plugin compatibility.
- [ ] Extreme large-file optimization and benchmarking.
