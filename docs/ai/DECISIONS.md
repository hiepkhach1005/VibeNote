# Architecture Decisions

## ADR-001 - Native AppKit foundation

- Date: 2026-08-17
- Status: Accepted
- Context: The product must feel like a real macOS editor with native menus, windows, text input and accessibility.
- Decision: Use Swift and AppKit for the primary application and editor UI. SwiftUI may be introduced for secondary settings screens when it improves maintainability.
- Consequence: The project gets native behavior and broad AppKit compatibility, while some UI requires more explicit controller code.

## ADR-002 - Swift Package Manager foundation

- Date: 2026-08-17
- Status: Accepted
- Context: The repository is empty and must be buildable from the command line.
- Decision: Start as an executable Swift package and add app-bundle/signing configuration during release preparation.
- Consequence: `swift build` works early; distribution configuration is a later phase.

## ADR-003 - Feature parity without plugins

- Date: 2026-08-17
- Status: Accepted
- Context: The requested first scope excludes the Plugin System and deep performance work.
- Decision: Track those categories as DEFERRED and implement the remaining built-in editor workflows incrementally.
- Consequence: No Notepad++ plugin compatibility is promised in the first major release.

## ADR-004 - Consolidated project skill architecture

- Date: 2026-08-17
- Status: Accepted
- Context: The reference repository is organized around application/editor/lexer/search responsibilities, not a web frontend/backend split. Two small project skills duplicated workflow and tracker guidance.
- Decision: Remove `vibenote-backend` and `vibenote-frontend`. Use `vibenote-editor` for normal product work and `vibenote-liquid-glass` for the specialized visual platform rules.
- Consequence: Fewer project skills, clearer triggering, and a dedicated place for Liquid Glass availability/accessibility guidance.
