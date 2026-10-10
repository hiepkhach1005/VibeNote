# Test Plan

## Current automated checks

- Package compiles with `swift build`.
- Unit tests cover pure document/encoding behavior as those services are added.

## Manual checks

- Launch app and create a new document.
- Open a UTF-8 text file.
- Edit and save a file.
- Save As to a new path.
- Open several files and switch tabs.
- Middle-click the tab title, close-button area and padding area; verify the clicked tab closes like Chrome and a modified tab shows Save/Cancel/Discard before closing.
- Type content into multiple tabs, including an unsaved Untitled note, click the red window close button and verify there is no save dialog, the app exits, and reopening MacPad restores the same tabs, content, modified state and selected tab.
- Drag one extensionless text file and then several mixed text/source files from Finder onto both the editor and tab row; verify each opens once in the same window and folders are ignored.
- Search for text and select the next match.
- Zoom editor in/out/reset.
- Toggle Light/Dark Mode.
- Confirm status bar line/column values.
- Confirm the toolbar shows icons only and all action icons are aligned to the right; hover an icon and verify its label appears quickly, then hover a truncated long filename and verify its full path appears.
- Click the Search and Find & Replace toolbar icons and verify both open the native Find and Replace popup with Find, Replace with, mode, options, Find Next/Previous, Replace, Replace All and Count controls; confirm Cmd+F opens the same popup.

## Planned regression areas

- Unsaved changes and recovery.
- Encoding and line endings.
- Regex search/replace.
- Split views.
- Syntax highlighting.
- Accessibility and keyboard-only operation.
