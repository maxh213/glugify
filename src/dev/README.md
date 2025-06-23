# Development Tools

This directory contains development tools for the glugify library that are not part of the public API and are excluded from the published package.

## Benchmarking Tools

### Running Benchmarks

To run the performance benchmarks, use:

```bash
gleam run -m dev/benchmark_runner
```

This will execute a comprehensive benchmark suite testing various input types and configurations using gleamy_bench.

### Benchmark Components

- `performance.gleam` - Core benchmarking functions and string builder utilities
- `benchmark_runner.gleam` - Standalone benchmark runner
- `performance_test.gleam` - Unit tests for benchmarking functions
- `benchmark_integration_test.gleam` - Integration tests for various benchmark scenarios

### Available Benchmark Functions

- `run_performance_suite()` - Runs comprehensive benchmarks across different input types
- `print_performance_report()` - Prints formatted benchmark results to console
- `benchmark_function_with_inputs()` - Benchmarks custom functions with specific inputs
- `benchmark_multiple_functions()` - Compares performance of multiple functions

### String Builder Utilities

The dev module also includes optimized string building utilities:

- `new_string_builder()` - Creates new optimized string builder
- `append_to_builder()` - Efficiently appends text to builder
- `builder_to_string()` - Converts builder to final string

These utilities use Gleam's `StringTree` for efficient string concatenation without quadratic time complexity.

## Testing

The development tools include comprehensive tests. Run them with:

```bash
gleam test
```

All tests in this directory are part of the overall test suite but the code they test is not included in the published package.