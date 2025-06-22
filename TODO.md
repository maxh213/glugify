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
- [x] Add versioning and changelog.md adhering to "The format is based on Keep a Changelog (https://keepachangelog.com/en/1.0.0/), and this project adheres to Semantic Versioning (https://semver.org/spec/v2.0.0.html)."

### Quality Assurance
- [x] Test cross-platform compatibility (Erlang and JavaScript targets)
- [x] Add property-based testing for comprehensive edge case coverage
- [x] Add tests for each readme example and check they work as expected
- [x] Review the entire codebase for adherence to Gleam best practices and idioms e.g. piping etc. 
- [x] Review the entire codebase for code which doesn't follow the brief or code which isn't production safe / ready 
- [x] Add the results of the performance benchmarks to the readme.md
- [x] Make sure all functions are properly documented for hex so that it can automatically generate documentation
- [x] move this to the main branch, push it, and tag it with a new version number and update the changelog.md

## v1.0.1
- [x] Make it so unicode.gleam doesn't have it's own char_map, utilise the internal char_maps.gleam instead

## v1.0.3
- [x] Run through all the codebase and inspect the tests to check for something that looks like it was added so the AI developer could reward hack their way around a bug. Make sure all the expectations in the tests are inline with the brief. Think deeply about the brief and what this project is trying to achieve.

## v1.0.4
- [x] Fixed multi-character separator bug where separators like "--" were incorrectly filtered out by the `remove_invalid_chars` function

## v1.0.5
- [x] Run through all the codebase and inspect the tests to check for something that looks like it was added so the AI developer could reward hack their way around a bug. Make sure all the expectations in the tests are inline with the brief. Think deeply about the brief and what this project is trying to achieve.

## v1.0.6
- [x] Run through all the codebase and inspect the tests to check for something that looks like it was added so the AI developer could reward hack their way around a bug. Make sure all the expectations in the tests are inline with the brief. Think deeply about the brief and what this project is trying to achieve.

## v1.0.7
- [x] - Add impodencey testing to the tests e.g. test a function returns the same value if called multiple times but on subsequent calls it's fed the previous output.

## v1.0.8
- [x] Run through all the codebase and inspect the tests to check for something that looks like it was added so the AI developer could reward hack their way around a bug. Make sure all the expectations in the tests are inline with the brief. Think deeply about the brief and what this project is trying to achieve.

## v1.0.9
- [x] Add comprehensive tier 2 API error handling tests for all error types that can actually be triggered

## v1.0.10
- [x] Evaluate and either implement or remove unused `TooLong` error type - currently defined in `errors.gleam` but never triggered in the codebase
- [x] Evaluate and either implement or remove unused `InvalidInput` error type - currently defined in `errors.gleam` but never triggered in the codebase
- [x] Consider adding input length validation if `TooLong` should be implemented, or remove the error type and update documentation - REMOVED: Library correctly handles long input through truncation
- [x] Consider adding input validation for malicious/invalid characters if `InvalidInput` should be implemented, or remove the error type and update documentation - REMOVED: Library processes all input rather than rejecting it

## v1.0.11
- [ ] Run through all the codebase and inspect the tests to check for something that looks like it was added so the AI developer could reward hack their way around a bug. Make sure all the expectations in the tests are inline with the brief. Think deeply about the brief and what this project is trying to achieve.


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