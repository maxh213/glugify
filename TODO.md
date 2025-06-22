# glugify Library Development TODO

This TODO list provides a comprehensive roadmap for implementing the glugify slugification library for Gleam, following the implementation plan outlined in brief.md.

## Phase 1: Core Foundation (High Priority)

### Project Setup
- [x] create project setup according to the brief.md architecture

### Core API Implementation
- [x] Implement Tier 1 API: simple slugify(text: String) -> String function
- [x] Create error types in src/glugify/errors.gleam module
- [x] Implement Tier 2 API: try_slugify(text: String) -> Result(String, SlugifyError)
- [x] Create Config type in src/glugify/config.gleam with all configuration options
- [x] Implement Tier 3 API: slugify_with(text: String, config: Config) -> Result(String, SlugifyError)

### Testing Foundation
- [x] Create comprehensive test suite covering positive, negative, and edge cases

## Phase 2: Core Processing (Medium Priority)

### Internal Modules
- [x] Create basic ASCII character mapping tables in src/glugify/internal/char_maps.gleam
- [x] Implement core processing pipeline functions in src/glugify/internal/processors.gleam
- [x] Add input validation functions in src/glugify/internal/validators.gleam
- [x] Implement Unicode handling and transliteration in src/glugify/unicode.gleam

## Phase 3: Advanced Features (Low Priority)

### Extended Functionality
- [x] Add transformations module for functional composition pattern
- [x] Implement advanced features: stop words, custom replacements, word boundary truncation
- [x] Add performance optimizations and benchmarking
- [x] Add a consise and humble readme with examples of usage to make it easy for developers to understand and use the library
- [ ] Add versioning and changelog.md adhering to "The format is based on Keep a Changelog (https://keepachangelog.com/en/1.0.0/), and this project adheres to Semantic Versioning (https://semver.org/spec/v2.0.0.html)."

### Quality Assurance
- [ ] Test cross-platform compatibility (Erlang and JavaScript targets)
- [ ] Add property-based testing for comprehensive edge case coverage

## Development Guidelines

Each task should be completed following these principles:
- Write comprehensive tests before implementation (TDD approach)
- Ensure all code is type-safe and leverages Gleam's strengths
- Follow functional programming principles with pure functions
- Keep functions small (d10 lines) and modules focused (d200 lines)
- Run `gleam format`, `gleam check`, and `gleam test` after each implementation
- Update this TODO.md to reflect completed tasks

## Expected Deliverables

The completed library should provide:
1. Three-tier API (simple, error-aware, configurable)
2. Comprehensive Unicode support with transliteration
3. Configurable options for various use cases
4. Robust error handling following Gleam patterns
5. Full test coverage including edge cases
6. Documentation and usage examples