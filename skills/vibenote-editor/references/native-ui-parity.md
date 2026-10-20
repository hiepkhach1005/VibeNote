# Native UI Parity

Keep the recognizable Notepad++ information architecture:

- Menu order: File, Edit, Search, View, Encoding, Language, Settings, Tools, Macro, Run, Window, Help.
- Main window: title/toolbar, compact tabs, optional workspace/panel area, editor with gutter and status bar.
- Panels: Document List, Folder as Workspace, Function List, Document Map, Search Results and Output.
- Preserve names and concepts so migration is predictable.
- Adapt shortcuts to Command-based macOS conventions.
- Use AppKit windows, sheets, menus, toolbar items, `NSSplitView`, native colors and accessibility.
- Use the `$vibenote-liquid-glass` skill for materials; do not duplicate its rules here.
