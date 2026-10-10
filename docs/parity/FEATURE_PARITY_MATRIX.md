# Feature Parity Matrix

Statuses: `NPP_ONLY`, `MACPAD_ONLY`, `PARITY_IN_PROGRESS`, `PARITY_DONE`, `DEFERRED`, `NOT_APPLICABLE`, `BLOCKED`.

| ID | Category | Notepad++ capability | MacPad status | MacPad capability/current implementation | Remaining gap / acceptance test |
|---|---|---|---|---|---|
| FILE-001 | File | New document | PARITY_DONE | New tab creates an untitled document | Add template/language variants |
| FILE-002 | File | Open one or many files | PARITY_DONE | Native Open panel supports multiple files, routes into the existing MacPad instance and deduplicates already-open URLs | Add recent-file integration |
| FILE-003 | File | Save | PARITY_DONE | Native atomic save writes selected document with tracked encoding/BOM/EOL | Add loss-warning and file type policy |
| FILE-004 | File | Save As | PARITY_DONE | Native Save panel writes a new path | Add file type/extension policy |
| FILE-005 | File | Save a Copy As | PARITY_DONE | Native Save a Copy As writes a copy without changing the active document URL/state | Add copy conflict confirmation |
| FILE-006 | File | Save All | PARITY_IN_PROGRESS | Basic Save All exists | Handle multiple untitled documents and report per-file result |
| FILE-007 | File | Close and unsaved confirmation | PARITY_IN_PROGRESS | Closing an individual tab keeps the Save/Cancel/Discard sheet; closing the MacPad window/app checkpoints recovery and exits without a prompt | Add multi-document close reporting and recovery UI |
| FILE-008 | File | Close multiple tabs | PARITY_IN_PROGRESS | Close All plus tab context actions for unchanged, except-current and left/right groups | Add bulk confirmation/reporting and pinned-tab policy |
| FILE-009 | File | Reload from disk | PARITY_DONE | File menu and Command-Option-R reload selected document with confirmation | Add cursor/selection restoration |
| FILE-010 | File | External change monitoring | PARITY_DONE | Polls file snapshot and offers Reload/Keep Local | Replace polling with event stream later if needed |
| FILE-011 | File | Read-only mode | NPP_ONLY | Not implemented | Disable editing and show state in status bar |
| FILE-012 | File | Print/print preview | PARITY_IN_PROGRESS | Native print action exists | Add print layout and page settings |
| FILE-013 | File | Recent files/reopen closed | NPP_ONLY | Not implemented | Use NSDocumentController/native recent menu |
| FILE-014 | File | Autosave/recovery | PARITY_IN_PROGRESS | JSON recovery session is updated while editing and synchronously on window/app close; launch restores every tab's exact persisted content and selection | Add named sessions, crash markers and user-facing recovery UI |
| FILE-015 | File | Drag/drop and Open With | PARITY_IN_PROGRESS | Finder file URLs/legacy filename lists and VS Code Explorer plain-path drags open as deduplicated tabs from the editor, tab area or window chrome; file paths are never inserted into editor text; bundle document types support Open With | Restart onto the rebuilt binary and complete interactive Finder/VS Code/Open With acceptance; add sandbox security scopes if distribution becomes sandboxed |
| EDIT-001 | Editing | Undo/redo | PARITY_DONE | NSTextView undo manager routed through commands | Add command validation tests |
| EDIT-002 | Editing | Cut/copy/paste/select all | PARITY_DONE | Native text actions | Add paste-without-formatting |
| EDIT-003 | Editing | Word wrap and zoom | PARITY_DONE | Word wrap and zoom controls exist | Persist per-document settings |
| EDIT-004 | Editing | Line duplicate/delete/move | PARITY_IN_PROGRESS | Native menu actions implement duplicate/delete/move with editor undo path | Complete multi-line selection semantics and command validation |
| EDIT-005 | Editing | Join/split lines | PARITY_IN_PROGRESS | Join selected/current line range and Split Line command use native edit | Add selection-aware split behavior and edge-case tests |
| EDIT-006 | Editing | Sort/remove duplicate lines | NPP_ONLY | Not implemented | Add stable and case-aware variants |
| EDIT-007 | Editing | Trim whitespace | PARITY_IN_PROGRESS | Removes trailing spaces/tabs for selected lines or document | Add preview/report and undo acceptance tests |
| EDIT-008 | Editing | Tabs/spaces conversion | NPP_ONLY | Not implemented | Preserve indentation semantics |
| EDIT-009 | Editing | Indent/unindent | NPP_ONLY | Native basic text editing only | Add smart indentation and selection behavior |
| EDIT-010 | Editing | Column/block selection | NPP_ONLY | Not implemented | Add rectangular selection model |
| EDIT-011 | Editing | Multi-editing/multi-caret | NPP_ONLY | Not implemented | Add multi-range editing and status counts |
| EDIT-012 | Editing | Bookmarks | NPP_ONLY | Not implemented | Add gutter state, navigation and persistence |
| EDIT-013 | Editing | Comment/uncomment | NPP_ONLY | Not implemented | Language-aware command |
| EDIT-014 | Editing | Case conversion/date-time | PARITY_IN_PROGRESS | Uppercase/lowercase selection commands | Add date/time insertion and command tests |
| EDIT-015 | Editing | Brace matching/auto-close | NPP_ONLY | Not implemented | Add language-aware matching |
| EDIT-016 | Editing | Insert/overwrite mode | NPP_ONLY | Not implemented | Add status bar toggle |
| SEARCH-001 | Search | Find next/previous | PARITY_IN_PROGRESS | Toolbar plus native find panel navigation with wrap and options | Persist toolbar options and add keyboard acceptance tests |
| SEARCH-002 | Search | Find panel | PARITY_IN_PROGRESS | Native Find and Replace popup with normal/extended/regex, case, whole-word and wrap controls; opened by Search and Find & Replace toolbar icons or the Search menu | Add selection scope and panel state persistence |
| SEARCH-003 | Search | Replace/replace all | PARITY_IN_PROGRESS | Replace current match and replace-all with count and editor edit transaction | Add replace confirmation/preview and broader undo tests |
| SEARCH-004 | Search | Normal/extended/regex modes | PARITY_IN_PROGRESS | Isolated Foundation search engine with invalid-regex errors and capture replacement | Add full Notepad++ escape compatibility |
| SEARCH-005 | Search | Find in Files | NPP_ONLY | Not implemented | Directory, filters, excludes and cancellation |
| SEARCH-006 | Search | Replace in Files | NPP_ONLY | Not implemented | Confirm bulk changes and create undo/report |
| SEARCH-007 | Search | Search Results panel | NPP_ONLY | Not implemented | Click result opens file/line |
| SEARCH-008 | Search | Count/mark all matches | PARITY_IN_PROGRESS | Find panel Count plus Notepad++-style Smart Highlighting for every occurrence of the selected token, using a non-destructive background overlay and a View toggle | Add persistent Style All Occurrences/mark styles and Search Results integration |
| SEARCH-009 | Search | Go to line/position | PARITY_IN_PROGRESS | Go to line dialog exists | Add column/byte/selection semantics |
| VIEW-001 | View | Tab bar and tab context menu | PARITY_IN_PROGRESS | One MacPad window always shows a visible AppKit tab strip, including the single-document case, with selected/modified/pinned state, close buttons, middle-click close, capped/truncated long titles and full-name hover tooltips | Add drag reorder, tab colors, lock state and full visual acceptance on Light/Dark Mode |
| VIEW-002 | View | Document switcher/MRU | PARITY_IN_PROGRESS | Next/Previous Tab commands and single-instance activation are available; files opened while MacPad is running stay in the same app | Add a dedicated keyboard MRU/document switcher |
| VIEW-003 | View | Split/dual view | NPP_ONLY | Not implemented | Move/clone and synchronized scrolling |
| VIEW-004 | View | Document list | NPP_ONLY | Not implemented | Sidebar/panel with sorting |
| VIEW-005 | View | Folder as Workspace | NPP_ONLY | Not implemented | Native folder tree and file actions |
| VIEW-006 | View | Project panels | NPP_ONLY | Not implemented | Project membership independent of folders |
| VIEW-007 | View | Document Map | NPP_ONLY | Not implemented | Minimap/document map panel |
| VIEW-008 | View | Function List | NPP_ONLY | Not implemented | Language-aware symbol extraction |
| VIEW-009 | View | Search Results panel | NPP_ONLY | Not implemented | Dockable/closable result surface |
| VIEW-010 | View | Tail/monitoring mode | NPP_ONLY | Not implemented | Watch external file changes safely |
| VIEW-011 | View | Invisible characters/guides | NPP_ONLY | Not implemented | Tabs, spaces, EOL and indentation guides |
| VIEW-012 | View | Full screen/distraction free | NPP_ONLY | Not implemented | Native full screen plus editor-only mode |
| VIEW-013 | View | Toolbar/status/sidebar visibility | PARITY_IN_PROGRESS | Native customizable icon-only toolbar aligned to the right with fast hover labels, plus Liquid Glass tab/status chrome and one-window multi-document layout | Add persisted visibility preferences and sidebar surfaces |
| ENCODING-001 | Encoding | Detect encoding | PARITY_IN_PROGRESS | Detects UTF-8/16/32 BOM and common Foundation encodings; records BOM | Add ambiguity/loss warning UI |
| ENCODING-002 | Encoding | UTF-8/BOM/UTF-16 | PARITY_IN_PROGRESS | Encoding menu changes UTF-8/BOM/UTF-16 state and persists it | Add conversion preview and more legacy encodings |
| ENCODING-003 | Encoding | Legacy code pages | NPP_ONLY | Not implemented | Add supported macOS mapping and warnings |
| ENCODING-004 | Encoding | CRLF/LF/CR conversion | PARITY_IN_PROGRESS | Detects, normalizes in memory and saves as LF/CRLF/CR from Encoding menu | Add mixed-EOL warning and conversion tests |
| LANGUAGE-001 | Language | Built-in language selection | PARITY_IN_PROGRESS | Language menu and persisted registry for common source/document types | Expand complete Notepad++ language registry and auto-detection rules |
| LANGUAGE-002 | Language | Syntax highlighting | PARITY_IN_PROGRESS | Native NSTextStorage highlighting for common comments, strings, numbers and keywords driven by a high-contrast persisted Light/Dark text palette; Markdown headings/keywords are emphasized | Add lexer-accurate tokenization, per-language styles and coverage matrix |
| LANGUAGE-003 | Language | Folding | NPP_ONLY | Not implemented | Code/comment folding |
| LANGUAGE-004 | Language | Auto-completion | NPP_ONLY | Not implemented | Word/keyword/document completions |
| LANGUAGE-005 | Language | User Defined Language | NPP_ONLY | Not implemented | Custom keywords/comments/operators/styles |
| LANGUAGE-006 | Language | Function/symbol parsing | NPP_ONLY | Not implemented | Function List integration |
| SETTINGS-001 | Settings | Preferences | PARITY_IN_PROGRESS | Native Text Settings window persists editor font family, size, text/background/selection/smart-highlight colors and syntax colors across all tabs | Add complete Preferences sections, import/export, accessibility audit and per-language scopes |
| SETTINGS-002 | Settings | Shortcut Mapper | NPP_ONLY | Not implemented | Command registry-backed customization |
| SETTINGS-003 | Settings | Style Configurator/themes | PARITY_IN_PROGRESS | Text Settings provides persisted MacPad System, Light, Dark, Dracula, Nord, Solarized, One Dark and Custom palettes; Light uses a clean white editor surface and Dark uses a stable dark surface | Add full Notepad++-style per-language Style Configurator and theme import/export |
| SETTINGS-004 | Settings | Toolbar customization | PARITY_IN_PROGRESS | Native customization enabled | Map all supported commands |
| SETTINGS-005 | Settings | Localization | NPP_ONLY | Not implemented | English/Vietnamese string catalog |
| SETTINGS-006 | Settings | Import/export settings | NPP_ONLY | Not implemented | Versioned settings schema |
| MACRO-001 | Macro | Record/playback macros | NPP_ONLY | Not implemented | Action recording, persistence and safety |
| MACRO-002 | Macro | Run macro multiple times | NPP_ONLY | Not implemented | Bounded repeat and cancellation |
| RUN-001 | Run | External commands | NPP_ONLY | Not implemented | macOS shell command runner with confirmation |
| TOOLS-001 | Tools | File hashes/checksums | NPP_ONLY | Not implemented | SHA-256 minimum, output panel |
| PLATFORM-001 | Platform | Native macOS menu/window/accessibility | PARITY_IN_PROGRESS | AppKit window/menu foundation with one application instance, native toolbar, visible tab row and editor host | Complete HIG, VoiceOver and keyboard audit |
| PLATFORM-002 | Platform | Liquid Glass chrome | PARITY_IN_PROGRESS | Native unified toolbar plus header material tab/status chrome; editor remains opaque and readable | Add tab/search/sidebar material review on target macOS versions |
| DEFER-001 | Deferred | Plugin system | DEFERRED | Explicitly out of current scope | Revisit via scope flag |
| DEFER-002 | Deferred | Notepad++ plugin compatibility | DEFERRED | Explicitly out of current scope | Requires separate compatibility architecture |
| DEFER-003 | Deferred | Extreme performance optimization | DEFERRED | Basic correctness first | Add benchmark phase later |
