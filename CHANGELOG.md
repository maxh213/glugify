# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/username/glugify/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/username/glugify/releases/tag/v1.0.0
[0.1.0]: https://github.com/username/glugify/releases/tag/v0.1.0