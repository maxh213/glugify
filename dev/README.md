# Development Tools

This directory contains development tools for the glugify library that are not part of the public API and are excluded from the published package.

## Benchmarking Tools

### Running Benchmarks

To run the performance benchmarks, use:

```bash
gleam run -m benchmark_runner
```

This will execute a comprehensive benchmark suite testing various input types and configurations using gleamy_bench.

### Benchmark Components

- `performance.gleam` - Core benchmarking functions and string builder utilities
- `benchmark_runner.gleam` - Standalone benchmark runner
- `benchmark_integration_test.gleam` - Integration checks for various benchmark scenarios (compiled with the dev tools, not run by `gleam test`)

### Available Benchmark Functions

- `run_performance_suite()` - Runs comprehensive benchmarks across different input types
- `print_performance_report()` - Prints formatted benchmark results to console
- `benchmark_function_with_inputs()` - Benchmarks custom functions with specific inputs
- `benchmark_multiple_functions()` - Compares performance of multiple functions

### String Builder Utilities

The dev module also includes string building utilities built on Gleam's
`StringTree` for efficient concatenation:

- `new_string_builder()` - Creates a new string builder
- `append_to_builder()` - Efficiently appends text to a builder
- `builder_to_string()` - Converts a builder to the final string

## Transliteration Table Codegen

`src/glugify/internal/char_maps.gleam` is generated. The source of truth
is the TSV files in `dev/char_data/` (`grapheme<TAB>replacement`, `#`
comment lines pass through, blank lines break up pattern groups, and
`U+XXXX` graphemes are emitted as `\u{XXXX}` escapes). After editing the
data, regenerate with:

```bash
python3 dev/tools/generate_char_maps.py
gleam format src
```

To add a new script (e.g. CJK pinyin), add a TSV file and register it in
`TABLES` in the generator.
