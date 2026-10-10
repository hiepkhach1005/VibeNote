# Feature Matrix

Detailed parity tracking is maintained in [docs/parity/FEATURE_PARITY_MATRIX.md](../parity/FEATURE_PARITY_MATRIX.md), [docs/parity/MENU_PARITY_MATRIX.md](../parity/MENU_PARITY_MATRIX.md) and [docs/parity/FEATURE_TRACKER.csv](../parity/FEATURE_TRACKER.csv). This file remains the high-level project view.

Legend: `[x] DONE`, `[~] IN_PROGRESS`, `[ ] TODO`, `[-] DEFERRED`, `[!] BLOCKED`

## Foundation

- [x] Native macOS app process
- [x] AppKit window
- [x] Native menu bar
- [x] Native toolbar
- [x] Light/Dark appearance
- [x] Multiple tabs in one MacPad application instance
- [x] New/Open/Save/Save As/Close
- [x] Basic status bar
- [x] Line-number gutter
- [x] Find next
- [x] Zoom in/out/reset
- [ ] App bundle and signing configuration
- [~] Original icon set (generated development `.icns`; final brand review pending)

## File management

- [x] New document
- [x] Open one or more files
- [x] Save
- [x] Save As
- [x] Save a Copy
- [x] Save All
- [ ] Recent files
- [ ] Reopen closed document
- [~] Close all/close unchanged/close except current; middle-click anywhere on a tab closes the clicked tab
- [x] Unsaved-change confirmation
- [x] Reload from disk
- [x] External file change detection
- [ ] Read-only mode
- [~] Autosave and recovery (automatic close checkpoint restores exact tabs/content)
- [ ] Print and print preview
- [~] Drag and drop one or many files into the editor/window to open them as tabs (native drop path implemented; packaged-app interaction acceptance pending)
- [ ] Open With integration

## Editing

- [x] Undo/redo through NSTextView
- [x] Cut/copy/paste/select all
- [x] Word wrap
- [x] Zoom
- [~] Line operations (duplicate/delete/move/join/split/trim; richer selection semantics pending)
- [ ] Column selection
- [ ] Multi-caret editing
- [ ] Bookmarks
- [ ] Indent/unindent
- [ ] Tabs/spaces conversion
- [ ] Comment/uncomment
- [~] Case conversion (uppercase/lowercase selection)
- [ ] Invisible characters
- [ ] Indentation guides
- [ ] Bracket matching
- [ ] Overwrite mode

## Search

- [x] Find next
- [x] Find previous
- [~] Find/Replace popup panel opened by Search and Find & Replace toolbar actions
- [~] Replace
- [~] Replace all
- [~] Normal/extended/regex modes
- [~] Smart Highlighting for all occurrences of selected text
- [ ] Find in files
- [ ] Replace in files
- [ ] Search results panel
- [ ] Search history
- [ ] Search result bookmarks
- [~] Go to line/position

## Encoding and EOL

- [x] UTF-8 read/write
- [x] Basic Foundation encoding detection
- [x] UTF-8 BOM control
- [~] UTF-16/UTF-32
- [ ] Legacy encoding selection
- [x] EOL detection
- [x] EOL conversion
- [ ] Lossy conversion warning

## Language tooling

- [~] Language registry
- [~] Automatic language detection
- [~] Syntax highlighting with persisted Light/Dark text and token colors
- [ ] Code/comment folding
- [ ] Function list
- [ ] Auto-completion
- [ ] User Defined Language
- [~] Style Configurator (global text settings and presets; per-language scopes pending)
- [~] Themes (MacPad System, Light, Dark, Dracula, Nord, Solarized, One Dark and Custom)

## Views and workflow

- [ ] Split views
- [ ] Clone/move documents
- [ ] Document list panel
- [ ] Document map
- [ ] Folder as Workspace
- [ ] Project panels
- [~] Sessions (recovery session implemented; named sessions planned)
- [ ] Monitoring/tail mode
- [ ] Distraction-free mode
- [ ] Restore window layout

## Automation and tools

- [ ] Macro recording/playback
- [ ] External commands
- [ ] Command output panel
- [ ] SHA-256/hash tools
- [ ] Shortcut Mapper
- [ ] Toolbar customization
- [ ] Import/export settings
- [ ] Localization

## Explicitly deferred

- [-] Plugin system
- [-] Notepad++ plugin compatibility
- [-] Deep performance optimization for extreme file sizes
