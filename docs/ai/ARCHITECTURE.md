# Architecture

## Current structure

```text
Sources/MacPad/
├── AppDelegate.swift
├── AppCommands.swift
├── DocumentModel.swift
├── EditorViewController.swift
├── FileDropView.swift
├── FindPanelController.swift
├── LanguageServices.swift
├── LineNumberRulerView.swift
├── MainWindowController.swift
├── SearchEngine.swift
└── SessionStore.swift
├── ToolbarTooltipController.swift
```

## Layers

- `AppDelegate`: application lifecycle and document opening from macOS.
- `AppCommands`: native menu bar command definitions.
- `MainWindowController`: window, tabs, toolbar, status bar and document routing.
- `DocumentModel`: document identity, URL, encoding/BOM, normalized content, EOL and modified state.
- `EditorViewController`: AppKit text editor and editor-level actions.
- `FileDropView`: native Finder drag payload decoding and drop destinations for the window/editor surfaces.
- `SearchEngine`: normal, extended and regex matching/replacement isolated from AppKit.
- `FindPanelController`: native Find/Replace panel and search options.
- `ToolbarTooltipController`: short-delay native tooltip surface for icon-only toolbar actions.
- `LanguageServices`: common-language registry and TextKit attribute-based highlighting boundary.
- `LineNumberRulerView`: line-number gutter attached to the text scroll view.
- `SessionStore`: JSON-backed recovery of open documents, unsaved content and selected tab.

## Planned boundaries

- `DocumentStore`: file loading/saving, encoding detection, BOM handling, EOL conversion and file snapshots.
- `MainWindowController` file monitor: periodic snapshot checks with safe Reload/Keep Local prompts.
- `CommandRegistry`: command IDs, shortcuts, validation and invocation.
- `SyntaxHighlighting`: language registry, tokens and styles.
- `SessionStore`: sessions, recovery and window state.
- `WorkspaceService`: folder/workspace/project navigation.
- `PreferencesStore`: user settings and themes.

## Parity process

- The canonical built-in feature comparison is `docs/parity/FEATURE_PARITY_MATRIX.md`.
- Menu/command placement is tracked in `docs/parity/MENU_PARITY_MATRIX.md`.
- `docs/parity/FEATURE_TRACKER.csv` is the machine-readable status mirror.
- Every feature slice appends to `docs/parity/IMPLEMENTATION_LOG.md`.

## Initial design decisions

- AppKit is the primary UI framework because the editor depends heavily on native text interaction and macOS menu/window behavior.
- Swift Package Manager is used initially so the project builds from the command line and opens directly in Xcode.
- The first slice uses `NSTextView`; TextKit 2 integration and custom storage remain planned work.
