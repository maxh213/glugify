# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.5] - 2025-06-22

### Fixed
- Fixed word boundary truncation bug where `truncate_slug` was hard-coded to use "-" separator instead of respecting the configured separator
- Fixed Unicode character handling in `apply_separators` function where accented characters were being replaced with separators even when `allow_unicode=True`
- Corrected "reward hacking" test expectations that masked implementation bugs:
  - `tier_3_configurable_api_test` now correctly expects word boundary truncation to work
  - `unicode_handling_preserve_test` now correctly expects Unicode characters to be preserved when `allow_unicode=True`
  - `slugify_with_allow_unicode_test` now correctly expects Chinese characters to be preserved
  - Fixed several other tests with incorrect expectations that hid real implementation issues

### Changed
- Modified `apply_separators` function to respect `allow_unicode` configuration when determining whether to preserve or replace characters
- Updated `truncate_slug` function signature to accept and use the configured separator instead of hard-coded "-"
- Enhanced `find_last_separator` implementation to properly handle multi-character separators using string slicing

## [1.0.4] - 2025-06-22

### Fixed
- Fixed multi-character separator bug where separators like "--" were incorrectly filtered out by the `remove_invalid_chars` function
- Multi-character separators now work correctly (e.g., "--", "___", "-_-")
- Added comprehensive tests for various multi-character separator configurations

## [1.0.3] - 2025-06-22

### Fixed
- Fixed tautological tests in `cross_platform_test.gleam` that provided no real validation
- Improved property-based tests to properly handle edge cases instead of masking potential issues
- Added documentation comments in tests identifying current implementation limitations

### Documented
- Multi-character separator bug: separators like "--" get filtered out by `remove_invalid_chars` function
- Word boundary truncation not working as intended - truncates at character boundary instead
- All test expectations now accurately reflect actual implementation behavior

## [1.0.2] - 2025-06-22

### Fixed
- Fixed double space issue in custom replacements where replacing symbols like "&" with " and " would create double spaces (e.g., "Ben & Jerry" → "Ben  and  Jerry")
- Added whitespace normalization to `optimized_apply_custom_replacements` function
- Fixed performance test that was incorrectly expecting double spaces instead of properly normalized single spaces

## [1.0.1] - 2025-06-22

### Changed
- Refactored `unicode.gleam` to use centralized character mappings from `char_maps.gleam` instead of duplicating the mapping tables, improving maintainability and reducing code duplication

## [1.0.0] - 2025-06-22

### Added
- Three-tier API architecture with `slugify/1`, `try_slugify/1`, and `slugify_with/2` functions
- Comprehensive Unicode support with transliteration to ASCII
- Configurable options including separator, case handling, length limits, and word boundary truncation
- Advanced features: stop words filtering, custom character replacements, and Unicode preservation
- Robust error handling with explicit `SlugifyError` types
- Functional composition pattern with transformation pipelines
- Internal modules for character mapping, validation, and processing
- Cross-platform compatibility for Erlang and JavaScript targets
- Comprehensive test suite covering positive, negative, and edge cases
- Performance optimizations with single-pass processing and character lookup tables
- Complete documentation with usage examples and API reference

### Security
- Input validation to prevent malicious input processing
- Safe Unicode handling without external dependencies

## [0.1.0] - Initial Development

### Added
- Project structure and basic scaffolding
- Core slugification logic foundation
- Initial test framework setup

[Unreleased]: https://github.com/anima-international/glugify/compare/v1.0.5...HEAD
[1.0.5]: https://github.com/anima-international/glugify/releases/tag/v1.0.5
[1.0.4]: https://github.com/anima-international/glugify/releases/tag/v1.0.4
[1.0.3]: https://github.com/anima-international/glugify/releases/tag/v1.0.3
[1.0.2]: https://github.com/anima-international/glugify/releases/tag/v1.0.2
[1.0.1]: https://github.com/anima-international/glugify/releases/tag/v1.0.1
[1.0.0]: https://github.com/anima-international/glugify/releases/tag/v1.0.0
[0.1.0]: https://github.com/anima-international/glugify/releases/tag/v0.1.0