---
name: vibenote-liquid-glass
description: Design, implement and review Liquid Glass for VibeNote's native macOS chrome, including toolbars, tabs, sidebars, inspectors, transient search surfaces, accessibility fallbacks and SDK availability. Use when a task changes materials, translucency, glass effects, window chrome or visual hierarchy; do not use for ordinary editor/domain work.
---

# VibeNote Liquid Glass

Apply Liquid Glass deliberately to VibeNote's functional chrome while keeping the text/code content layer stable and readable. This is a focused visual/platform skill, not the general editor skill.

## Mandatory rules

- Prefer standard AppKit/SwiftUI components; they inherit platform behavior automatically.
- Use Liquid Glass for controls and navigation: toolbar, sidebar, tab/navigation surfaces, inspectors and transient action/search surfaces.
- Do not apply Liquid Glass behind the main code/text editor or dense content panels.
- Use standard materials and system colors for the editor content layer.
- Keep text contrast, selection visibility and caret visibility stable.
- Limit custom glass effects; do not turn every button, row or label into glass.
- Support reduced transparency, increased contrast, Light Mode and Dark Mode.
- Preserve keyboard focus, VoiceOver labels and native menu access.

## API strategy

- AppKit shell: use `NSToolbar`, `NSSplitView`, system tabs, `NSVisualEffectView`, vibrancy and system colors first.
- Use SwiftUI `glassEffect`/`GlassEffectContainer` only when the deployment SDK and target OS support them.
- Gate newer APIs with availability checks.
- Provide an opaque/native-material fallback for older macOS versions and accessibility settings.
- Do not raise the minimum macOS version only to add decoration without a documented product decision.

## Review workflow

1. Identify the functional surface and its content underneath.
2. Decide whether glass, standard material or opaque content is appropriate.
3. Implement the smallest native component.
4. Test over light, dark and visually rich backgrounds.
5. Test small/large windows, full screen, reduced transparency and increased contrast.
6. Verify keyboard focus, VoiceOver, contrast and code readability.
7. Record the decision in `docs/design/SCREENS.md` or `docs/ai/DECISIONS.md` when it changes architecture.

## References

Read [references/apple-guidance.md](references/apple-guidance.md) for the concise Apple rules used by this project. Read [references/vibenote-surfaces.md](references/vibenote-surfaces.md) to choose glass versus standard material for each editor surface.
