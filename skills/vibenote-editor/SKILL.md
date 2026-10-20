---
name: vibenote-editor
description: Build and maintain the complete native VibeNote editor and Notepad++ built-in parity workflow, including document core, AppKit UI, menus, tabs, editing, search, encoding, syntax, workspaces, sessions, macros, commands, accessibility and tracking. Use for any VibeNote feature or refactor unless the task is specifically about Liquid Glass material implementation.
---

# VibeNote Editor

Use this as the single project skill for normal VibeNote work. It covers the product surface and its domain/UI boundary without pretending the project has a web-style frontend/backend split.

## Reference architecture

Model the project after the useful responsibility boundaries visible in Notepad++:

- Application/document/UI behavior → `PowerEditor`-like VibeNote application layer.
- Text editor core → Scintilla-like editor abstraction, implemented with AppKit/TextKit 2 or an explicitly chosen editor engine.
- Syntax/language services → Lexilla-like language registry and lexer boundary.
- Regex/search → isolated search engine.
- Persistence/files → document, encoding, EOL, recovery and workspace services.

Use Swift and AppKit as the primary native foundation. Use SwiftUI only for secondary UI when appropriate. Never use Electron, React or a webview for the editor.

## Required workflow

1. Read `AGENTS.md`, `docs/ai/MASTER_PROMPT.md`, `docs/ai/PROJECT_STATE.md`, `docs/parity/FEATURE_PARITY_MATRIX.md`, `docs/parity/MENU_PARITY_MATRIX.md`, `docs/parity/FEATURE_TRACKER.csv`, `docs/ai/ARCHITECTURE.md` and the latest implementation logs.
2. Select one feature ID and inspect its Notepad++ evidence.
3. Define expected behavior, macOS adaptation, data-safety rules and acceptance tests.
4. Inspect existing code and preserve user changes.
5. Implement one end-to-end vertical slice: model/service, command, menu/UI, state, errors and tests.
6. Validate Light/Dark Mode, keyboard-only access and accessibility.
7. Update all trackers and append the implementation log.

## Parity rules

- Preserve familiar menu order and command concepts: File, Edit, Search, View, Encoding, Language, Settings, Tools, Macro, Run, Window and Help.
- Match Notepad++ behavior where it is useful; document every intentional macOS adaptation.
- Use stable feature and command IDs.
- Do not mark `PARITY_DONE` until behavior, options, error cases, persistence, shortcuts and tests are covered.
- Keep Plugin System, Notepad++ plugin compatibility and extreme performance optimization explicitly `DEFERRED`.
- Do not copy Notepad++ source code, logo, name or branding without a licensing decision.

## Core boundaries

- Document model/store: identity, URL, content, modified/read-only state, atomic save, encoding and EOL.
- Editor core: selection, edits, undo, line operations, bookmarks, multi-caret and folding contracts.
- Search engine: find/replace, normal/extended/regex modes, file search and result navigation.
- Language services: language registry, syntax highlighting, folding, completion and Function List.
- Workspace/session services: tabs, windows, recovery, sessions, folder workspace and projects.
- Command registry: IDs, menu placement, shortcuts, validation, undo policy and tests.
- Native UI: AppKit windows, toolbar, tabs, sidebars, panels, sheets, status bar and accessibility.

Keep core logic independent from views. UI surfaces consume commands/services instead of duplicating behavior.

## Safety and quality

- Never silently corrupt or overwrite user files.
- Save atomically and preserve the previous file until success.
- Treat encoding/EOL conversion as explicit operations with loss warnings.
- Make bulk replacements transactional and undoable where feasible.
- Add tests for success, invalid input, cancellation, persistence and recovery.
- Use system colors, native controls and keyboard conventions.
- Use the separate `$vibenote-liquid-glass` skill whenever implementing or reviewing Liquid Glass.

## Tracking contract

After every feature slice update:

- `docs/parity/FEATURE_PARITY_MATRIX.md`
- `docs/parity/FEATURE_TRACKER.csv`
- `docs/parity/MENU_PARITY_MATRIX.md` when commands/menus change
- `docs/parity/IMPLEMENTATION_LOG.md`
- `docs/ai/PROJECT_STATE.md`
- `docs/ai/BACKLOG.md` and `docs/ai/KNOWN_ISSUES.md` when needed

Use only these statuses: `NPP_ONLY`, `VIBENOTE_ONLY`, `PARITY_IN_PROGRESS`, `PARITY_DONE`, `DEFERRED`, `NOT_APPLICABLE`, `BLOCKED`.

## References

Read [references/editor-domain.md](references/editor-domain.md) for data/service invariants. Read [references/native-ui-parity.md](references/native-ui-parity.md) for AppKit layout and familiar Notepad++ surfaces. Read [references/parity-workflow.md](references/parity-workflow.md) for evidence and tracker updates.
