# Menu and Command Parity Matrix

The menu order remains familiar to Notepad++ users, while command shortcuts follow macOS conventions.

| Menu | Notepad++ role | MacPad target | Status |
|---|---|---|---|
| File | New/open/save/close/reload/print/session-related file operations | Native macOS document commands and sheets | PARITY_IN_PROGRESS |
| Edit | Text editing, line operations, case/indent transforms | Native NSTextView commands plus line/case transforms | PARITY_IN_PROGRESS |
| Search | Find, Replace, Find in Files, bookmarks, Go To and Smart Highlighting/Mark All | Search and Find & Replace toolbar icons open the native Find/Replace popup; menu also exposes navigation and selected-token Smart Highlighting | PARITY_IN_PROGRESS |
| View | Tabs, panels, zoom, whitespace, split views, distraction-free | One-window AppKit tab strip, toolbar, Liquid Glass status/tab chrome, zoom, line numbers and word wrap | PARITY_IN_PROGRESS |
| Encoding | Detect, convert and save encoding/EOL | Encoding menu, document model and status bar | PARITY_IN_PROGRESS |
| Language | Built-in languages, UDL, highlighting and folding | Common-language registry and native syntax highlighting | PARITY_IN_PROGRESS |
| Settings | Preferences, shortcut mapper, style configurator | Native Text Settings window for font family, size, editor/syntax colors and theme presets; broader Preferences remain planned | PARITY_IN_PROGRESS |
| Tools | Hashes and built-in utilities | CryptoKit/CommonCrypto-backed tools | NPP_ONLY |
| Macro | Record, save and replay editing actions | Macro service over command registry | NPP_ONLY |
| Run | External command execution | Explicitly confirmed macOS shell runner | NPP_ONLY |
| Window | Open documents, tab ordering and window actions | Native single-window document tabs, Next/Previous Tab commands and app activation | PARITY_IN_PROGRESS |
| Help | Help, about, updates and diagnostics | Native Help/About; update strategy later | PARITY_IN_PROGRESS |
| MacPad application menu | macOS-required application commands | About, Preferences, Hide, Quit | PARITY_DONE |
| Plugins | Plugin manager and plugin commands | Deferred by current scope | DEFERRED |
