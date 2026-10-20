# Notepad++ ↔ VibeNote Parity Tracking

This directory is the working source of truth for feature parity.

## Files

- `NOTEPADPP_BASELINE.md`: reference repository, manual and audit rules.
- `FEATURE_PARITY_MATRIX.md`: human-readable detailed comparison.
- `MENU_PARITY_MATRIX.md`: command/menu mapping between Notepad++ and VibeNote.
- `FEATURE_TRACKER.csv`: machine-readable tracker for AI and scripts.
- `IMPLEMENTATION_LOG.md`: append-only implementation history by feature ID.

## Status rules

- A feature is not complete because a button exists.
- `PARITY_DONE` means behavior, error cases, persistence, shortcut and tests are covered.
- If VibeNote intentionally behaves differently because of macOS, use `NOT_APPLICABLE` or `PARITY_DONE` with a documented adaptation.
- Keep deferred functionality visible.
