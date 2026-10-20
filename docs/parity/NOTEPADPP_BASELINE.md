# Notepad++ Baseline

## Primary references

- Official repository: https://github.com/notepad-plus-plus/notepad-plus-plus
- Official manual: https://npp-user-manual.org/docs/
- Repository license: https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/LICENSE

The official repository currently exposes the main Windows application under `PowerEditor` and includes `scintilla`, `lexilla` and `boostregex` components. These are reference points for behavior and feature discovery, not a license to copy implementation into VibeNote without a deliberate licensing review.

## Audit procedure

When a feature is missing from the matrix:

1. Inspect the current official manual menu/feature section.
2. Inspect the official source repository location if behavior is unclear.
3. Add a tracker row before implementation.
4. Record the source URL or repository path in the evidence column.
5. Define the closest native macOS adaptation.
6. Add acceptance criteria and test coverage.

## Scope interpretation

VibeNote targets complete built-in user-facing parity. Plugin loading, Notepad++ plugin compatibility, Windows Registry/shell integration and extreme performance engineering remain explicitly deferred unless the project scope changes.

## Legal and identity boundary

- Do not ship the Notepad++ name, logo, icon or copied branding.
- Do not copy source code or assets into VibeNote without a licensing decision.
- Preserve familiar information architecture and behavior, but use VibeNote branding and native macOS controls.
- Track any reused third-party grammar/library and its license.
