# glugify Library Development TODO

This TODO list provides a comprehensive roadmap for implementing the glugify slugification library for Gleam, following the implementation plan outlined in brief.md.

## v1.0.12
- [x] update the error handling readme section to reflect the reality of the code

## v1.0.13
- [x] double check the readme section using wordboundaries matches the reality of the tests and code

## v1.0.14
- [x] Update the benchmarking code so that it runs using gleamy_bench

## {Version after Next Version}
- [ ] Benchmarking code shouldn't be apart of the public API / Package, move it under /dev so it isn't included when gleam/publish is run

## Development Guidelines

Each task should be completed following these principles:
- Write comprehensive tests before implementation (TDD approach)
- Ensure all code is type-safe and leverages Gleam's strengths
- Follow functional programming principles with pure functions
- Keep functions small (d10 lines) and modules focused (d200 lines)
- Run `gleam format`, `gleam check`, and `gleam test` after each implementation
- Update this TODO.md to reflect completed tasks
