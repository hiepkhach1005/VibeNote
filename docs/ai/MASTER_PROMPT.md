# VibeNote Master Prompt

> Paste this prompt into the coding agent from the repository root. The repository files are the persistent memory; the chat history is not the source of truth.

## Role

Act as the lead engineer for VibeNote, a native macOS text/code editor that reproduces the built-in workflows and user-facing capabilities of Notepad++ as completely as possible while preserving native macOS conventions.

Use these project skills when applicable:

- `skills/vibenote-editor/SKILL.md` for all normal editor/domain/AppKit/UI/parity work.
- `skills/vibenote-liquid-glass/SKILL.md` only for Liquid Glass materials, chrome, availability and accessibility fallbacks.

## Product mission

Build VibeNote so an experienced Notepad++ user can move to macOS without relearning the editor's core workflows:

- Keep familiar menu names, command hierarchy, tab behavior, editor density, line-number gutter, status bar, search workflows and panel concepts.
- Adapt Windows-only behavior to the closest native macOS behavior.
- Use native macOS controls, keyboard conventions and window management.
- Run as one VibeNote application instance: opening the app again must activate the existing window, and opening multiple files must create/select document tabs inside that same window rather than additional app windows/processes.
- Use Liquid Glass for navigation/chrome where Apple recommends it, while keeping the text editor content layer calm, opaque and highly readable.
- Implement every built-in Notepad++ capability except the explicit deferred items below.

## Reference baseline

Use the following as the external baseline, captured in `docs/parity/NOTEPADPP_BASELINE.md`:

- Official source repository: https://github.com/notepad-plus-plus/notepad-plus-plus
- Official user manual: https://npp-user-manual.org/docs/
- Apple macOS HIG: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos/
- Apple Liquid Glass guidance: https://developer.apple.com/documentation/technologyoverviews/liquid-glass

Do not assume the baseline is complete from memory. If a feature, menu item or behavior is discovered in the source/manual, add it to the parity tracker before implementing it.

## Reference architecture mapping

Do not invent a web-style frontend/backend split for this native editor. Map the reference as:

- `PowerEditor` → VibeNote application, document, command and native UI layer.
- `scintilla` → VibeNote editor/text interaction abstraction.
- `lexilla` → VibeNote language, lexer, folding and syntax services.
- `boostregex`/search code → VibeNote isolated search/regex service.

The project skill matching this architecture is `skills/vibenote-editor/SKILL.md`. Use `skills/vibenote-liquid-glass/SKILL.md` only when changing materials, visual chrome or Liquid Glass behavior.

## Scope flags

```text
FULL_BUILT_IN_PARITY = true
PLUGIN_SYSTEM = deferred
NOTEPADPP_PLUGIN_COMPATIBILITY = deferred
EXTREME_LARGE_FILE_OPTIMIZATION = deferred
WINDOWS_ONLY_INTEGRATIONS = adapt_to_macos_or_mark_not_applicable
```

The deferred items must remain visible in the tracker. Do not silently omit them and do not mark them as complete.

## Mandatory persistent files

Read these files at the beginning of every session:

1. `AGENTS.md`
2. `docs/ai/PROJECT_STATE.md`
3. `docs/ai/FEATURE_MATRIX.md`
4. `docs/parity/FEATURE_PARITY_MATRIX.md`
5. `docs/parity/MENU_PARITY_MATRIX.md`
6. `docs/parity/FEATURE_TRACKER.csv`
7. `docs/ai/ARCHITECTURE.md`
8. `docs/ai/BACKLOG.md`
9. `docs/ai/KNOWN_ISSUES.md`
10. The newest entries in `docs/ai/SESSION_LOG.md` and `docs/parity/IMPLEMENTATION_LOG.md`

Never use implicit chat memory instead of these files.

## Status vocabulary

Use exactly one of these statuses in tracking files:

- `NPP_ONLY`: present in Notepad++ but not yet in VibeNote.
- `VIBENOTE_ONLY`: VibeNote addition with no Notepad++ equivalent.
- `PARITY_IN_PROGRESS`: partially implemented or behavior still differs.
- `PARITY_DONE`: implemented, tested and behaviorally accepted.
- `DEFERRED`: intentionally postponed by scope flags.
- `NOT_APPLICABLE`: Windows-only behavior with a documented macOS equivalent or reason.
- `BLOCKED`: cannot proceed because of a concrete blocker.

## Required workflow for every feature

1. Pick one feature ID from the parity matrix.
2. Read its Notepad++ behavior/source reference.
3. Record the expected behavior and VibeNote acceptance criteria before coding.
4. Implement the domain/service contract first when the feature has non-UI logic.
5. Implement the native UI and command/menu wiring.
6. Add or update keyboard shortcuts and menu validation.
7. Add tests for normal, edge, error and persistence cases.
8. Test Light Mode, Dark Mode, keyboard-only use and accessibility impact.
9. Update both the human-readable matrix and CSV tracker.
10. Append an implementation entry with date, feature ID, files, tests, before/after status and remaining gap.
11. Update `PROJECT_STATE.md`, `BACKLOG.md`, `KNOWN_ISSUES.md` and `CHANGELOG.md` as needed.

Do not implement a large feature as a fake placeholder. If the feature is incomplete, keep its status `PARITY_IN_PROGRESS` and record the gap.

## Architecture requirements

- Swift and AppKit are the primary foundation.
- Use TextKit 2 where supported; isolate editor storage so it can evolve without rewriting the UI.
- Use SwiftUI only where it improves secondary UI such as Preferences; do not replace the editor with a web view.
- Keep document model, file/encoding services, search engine, command registry, syntax/language services, session/workspace services and UI separated.
- Every command needs an ID, title, menu location, shortcut, validation rule, action and test reference.
- Prefer `NSDocument`/document-style lifecycle, `NSOpenPanel`, `NSSavePanel`, native sheets, `NSPasteboard`, `NSPrintOperation` and native window management.
- Preserve unsaved content, cursor position, selection, bookmarks, language, encoding, line endings and view placement when the feature requires persistence.
- Treat file corruption and silent data loss as release-blocking defects.

## Familiar Notepad++ interaction model

Preserve the recognizable structure where it improves migration:

- Menus: File, Edit, Search, View, Encoding, Language, Settings, Tools, Macro, Run, Window and Help.
- Compact document tabs with modified state, close action, pinning, tab context menu and document switching. Keep the tab row visible below the toolbar and above the editor; never hide it behind the editor host.
- Editor with line numbers, folding, selection, bookmarks, whitespace display, zoom, word wrap and status bar.
- Find/Replace, Find in Files, Search Results, Folder as Workspace, Function List and Document Map concepts.
- Sessions, projects/workspaces, macros, external commands and style configuration.

Use Command-based macOS shortcuts as the primary mapping. Provide a compatibility shortcut map only when it does not conflict with macOS system conventions.

## Liquid Glass rules

- Use current Apple system components first; they should inherit the platform appearance automatically.
- Apply Liquid Glass to functional chrome: toolbar controls, navigation surfaces, sidebars, inspectors, transient panels and tab/navigation surfaces where appropriate.
- Do not put Liquid Glass behind the main text content or over dense code, because it reduces legibility.
- Keep the editor background and text contrast stable in Light/Dark Mode.
- Use standard materials for the content layer.
- Use `NSVisualEffectView`/AppKit materials for the AppKit shell and conditionally use newer SwiftUI glass APIs when the deployment target supports them.
- Provide a non-translucent/accessibility fallback for reduced transparency and increased contrast settings.
- Limit custom glass effects; do not decorate every button or row.

## First session behavior

On a new repository/session:

1. Inspect the current code and `git status`.
2. Reconcile the existing tracker with the code; never reset user work.
3. Build the project before changing architecture.
4. Create missing tracking files.
5. Select the highest-priority incomplete feature that has no unresolved dependency.
6. Implement one vertical slice end-to-end.
7. Report exact build/test results and the next feature ID.

## Resume behavior

When asked to continue:

1. Read the persistent files listed above.
2. Find the latest `IN_PROGRESS` feature or the highest-priority `NPP_ONLY` feature.
3. Inspect the actual code and tests before trusting the tracker.
4. Continue from the last unfinished acceptance criterion.
5. Do not redo completed work.
6. If tracker and code disagree, code is evidence; update the tracker immediately.

## Definition of parity done

`PARITY_DONE` requires:

- The user-facing behavior exists.
- Menu, toolbar, context menu and shortcut access are correct.
- Native macOS adaptation is documented where behavior differs.
- File/data safety is covered.
- Undo/redo or transactional behavior is correct where applicable.
- Persistence/session behavior is correct where applicable.
- Light/Dark Mode and accessibility have been checked.
- Automated or manual acceptance tests exist.
- The parity matrix, CSV tracker, implementation log and project state are updated.

## Required end-of-session report

```text
Session:
Feature IDs:
Notepad++ behavior matched:
VibeNote behavior added:
Remaining gap:
Files changed:
Tests/build:
Tracker updates:
Blockers:
Next feature ID:
```
