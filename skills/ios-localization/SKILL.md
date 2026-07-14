---
name: ios-localization
description: >-
  iOS localization with String Catalog (.xcstrings) and type-safe enum pattern.
  Covers feature-based catalogs, pluralization, string interpolation, and SPM package
  localization. Use when adding localization, creating .xcstrings files, localizing UI
  strings, or user mentions "String Catalog", "xcstrings", "localization",
  "pluralization", "multi-language", or "translations".
user-invocable: true
when_to_use: |
  When adding localization, creating .xcstrings files, or localizing UI strings. When the user mentions "String Catalog", "xcstrings", "localization", "L10n", "pluralization", "multi-language", or "translations".
---

## Overview

Use String Catalog (`.xcstrings`) for all user-facing strings. Create type-safe access via a localization enum with nested feature enums. Each feature gets its own `.xcstrings` file. Use `String(localized:table:)` with explicit table names for feature-specific strings.

> **Project-specific settings**: Before applying this skill, check `CLAUDE.md` for:
> - Supported languages (which languages to add to each catalog)
> - Localization enum name (commonly `L10n`, `Strings`, `S`)
> - Key naming convention (`SCREAMING_SNAKE_CASE`, `camelCase`, etc.)
> - Enum file location (`Core/Extensions/`, `Utilities/`, etc.)

## Instructions

1. **Create String Catalog** — Xcode → File → New → String Catalog → `[FeatureName].xcstrings` in `Resources/`
2. **Add languages** — select the catalog, Inspector → Localizations → click `+` to add each supported language (see CLAUDE.md for the language list)
3. **Add keys** — use the project's key naming convention (see CLAUDE.md)
4. **Create localization enum** — e.g., `enum L10n {}` with nested enums per feature, each with a `private static let table`
5. **Reference in Views** — use the enum instead of hardcoded strings
6. **Add pluralization** — use `String(localized: "KEY \(count)", table: table)` with plural variations in the catalog

## Rules

### Key Naming

- Follow the convention defined in CLAUDE.md. Common conventions:
  - `SCREAMING_SNAKE_CASE`: `FEATURE_CONTEXT_IDENTIFIER`
  - Key structure: `[Feature]_[Context]_[Identifier]`
- Context prefixes: `SCREEN_`, `SECTION_`, `BUTTON_`, `LABEL_`, `PLACEHOLDER_`, `EMPTY_`, `ERROR_`, `ALERT_`, `A11Y_`, `COMMON_`
- Be consistent — never mix naming conventions within a project

### Localization Enum Structure

- Top-level enum (name per CLAUDE.md, e.g., `enum L10n {}`) in `Core/Extensions/`
- Common strings in a `Common` nested enum (uses default `Localizable.xcstrings`)
- Feature strings in `FeatureName` nested enum with `private static let table = "FeatureName"`
- Each feature enum has nested context enums: `Screen`, `Button`, `Label`, `Placeholder`, `Empty`, `Error`, `Alert`
- Pluralization functions: `static func itemCount(_ count: Int) -> String { String(localized: "ITEM_COUNT \(count)", table: table) }`
- Interpolation functions: `static func ratingValue(_ value: Double) -> String { String(localized: "RATING \(value)", table: table) }`

### App vs Package Localization

- **Main app**: uses default bundle, reference with `table: "FeatureName"`
- **Swift Package**: uses `bundle: #bundle` (or `.atURL(Bundle.module.bundleURL)` for older package formats)
- Package strings go in `Sources/[Package]/Resources/[Package].xcstrings`

### String Catalog Files

- `Localizable.xcstrings` — Common strings (OK, Cancel, Retry, generic errors)
- `[FeatureName].xcstrings` — One per feature with feature-specific keys
- Add all supported languages to each catalog
- Use the visual editor for plural variations and interpolation placeholders

### Pluralization

- Use string interpolation for the count: `String(localized: "KEY \(count)", table: table)`
- In the catalog, add variations: `zero`, `one`, `other` for each language
- For complex plurals, use positional format specifiers: `%1$@`, `%2$lld`

### Testing

- Add preview variants with `.environment(\.locale, Locale(identifier: "[locale]"))` for each supported language
- Test pseudo-localization in Xcode scheme: "Double-Length Pseudolanguage"
- Test VoiceOver with Accessibility Inspector

## Verification Checklist

- [ ] All user-facing strings use the localization enum — no hardcoded strings
- [ ] Keys follow the project's naming convention (see CLAUDE.md)
- [ ] Feature-specific strings use `table:` parameter
- [ ] Pluralization uses String Catalog plural variations (not manual if/else)
- [ ] Package strings use correct bundle reference
- [ ] Separate `.xcstrings` per feature in `Resources/`
- [ ] All supported languages have entries for every key
- [ ] Previews test multiple locales
- [ ] Accessibility labels use `A11Y_` prefixed keys

## Common Mistakes

- **Hardcoded strings** → Every user-facing string must go through the localization enum
- **Missing `table:` parameter** → Feature-specific keys without `table:` resolve against `Localizable.xcstrings`
- **Missing `bundle:` in packages** → Package strings fail to resolve without explicit bundle
- **Inconsistent key naming** → Stick to one convention — no mixing styles
- **Manual pluralization** → Use String Catalog plurals instead of `count == 1 ? "singular" : "plural"`

## References

- `${CLAUDE_SKILL_DIR}/references/examples.md` — Full localization enum, String Catalog examples, pluralization, package localization
