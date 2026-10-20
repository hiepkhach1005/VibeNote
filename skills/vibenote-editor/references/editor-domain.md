# Editor Domain Invariants

- Document identity is stable independent of URL.
- A failed save leaves the previous file intact.
- Encoding and EOL are document properties, not labels rendered only by UI.
- Read-only documents reject mutations at the command boundary.
- Cursor, selection and bookmark ranges must be remapped or invalidated deliberately after transforms.
- Search requests explicitly contain mode, case, whole-word, direction, wrap, selection scope and file filters.
- Invalid regex is a visible error, never a silent empty result.
- Commands have stable ID, title, menu location, shortcut, validation rule, action and test reference.
