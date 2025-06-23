import gleam/int
import gleam/io
import gleam/list
import gleam/string_tree
import gleamy/bench
import glugify
import glugify/config

/// Runs a comprehensive performance benchmark suite using gleamy_bench.
/// 
/// Tests various input types and configurations:
/// - Simple text
/// - Unicode text with emojis
/// - Long text (200+ characters)
/// - Complex text with mixed case and symbols
/// - Both default and custom configurations
/// 
/// Uses gleamy_bench to provide accurate performance measurements
/// with proper warmup periods and statistical analysis.
pub fn run_performance_suite() -> String {
  let simple_text = "Hello World"
  let unicode_text = "Héllo Wörld with émojis 🎉"
  let long_text =
    "This is a very long text that needs to be processed and slugified to test performance with longer strings that might be more representative of real world usage patterns"
  let complex_text =
    "A Mix of UPPER & lower case, with spéciàl chãractërs, numbers 123, and symbols @#$%^&*()"

  let custom_config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(20)
    |> config.with_word_boundary(True)

  let benchmark_results =
    bench.run(
      [
        bench.Input("simple_text", simple_text),
        bench.Input("unicode_text", unicode_text),
        bench.Input("long_text", long_text),
        bench.Input("complex_text", complex_text),
      ],
      [
        bench.Function("slugify", fn(text) { glugify.slugify(text) }),
        bench.Function("slugify_with_custom_config", fn(text) {
          case glugify.slugify_with(text, custom_config) {
            Ok(slug) -> slug
            Error(_) -> ""
          }
        }),
      ],
      [bench.Duration(100), bench.Warmup(10)],
    )

  benchmark_results
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
}

/// Prints a complete performance report to the console.
/// 
/// This function executes all benchmarks using gleamy_bench and displays:
/// - Detailed benchmark results with statistical analysis
/// - Operations per second (IPS) for each test case
/// - Minimum execution times
/// - 99th percentile performance metrics
/// 
/// The benchmarks compare the simple `slugify` function against
/// `slugify_with` using custom configurations across various input types.
pub fn print_performance_report() -> Nil {
  io.println(
    "=== Glugify Performance Benchmark Report (using gleamy_bench) ===",
  )
  io.println("")

  let results = run_performance_suite()
  io.println(results)

  io.println("")
  io.println("=== Benchmark Details ===")
  io.println("Duration: 100ms per test")
  io.println("Warmup: 10ms per test")
  io.println(
    "Statistics: IPS (iterations per second), Min (minimum time), P99 (99th percentile)",
  )
}

/// Benchmarks a specific function with custom inputs using gleamy_bench.
/// 
/// This function provides a flexible way to benchmark any slugification
/// function with custom test inputs and configurations.
/// 
/// ## Examples
/// 
/// ```gleam
/// let custom_inputs = ["Hello World", "Test Input", "Spéciàl Chãractërs"]
/// let results = benchmark_function_with_inputs(
///   custom_inputs, 
///   fn(text) { glugify.slugify(text) },
///   "custom_slugify_test"
/// )
/// ```
pub fn benchmark_function_with_inputs(
  inputs: List(String),
  function: fn(String) -> String,
  function_name: String,
) -> String {
  let benchmark_inputs =
    list.index_map(inputs, fn(input, index) {
      bench.Input("input_" <> int.to_string(index), input)
    })

  bench.run(benchmark_inputs, [bench.Function(function_name, function)], [
    bench.Duration(100),
    bench.Warmup(10),
  ])
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
}

/// Benchmarks multiple slugification functions against the same inputs.
/// 
/// Useful for comparing the performance of different configurations
/// or different versions of slugification functions.
/// 
/// ## Examples
/// 
/// ```gleam
/// let test_inputs = ["Hello World", "Test Input"]
/// let functions = [
///   #("simple_slugify", fn(text) { glugify.slugify(text) }),
///   #("try_slugify", fn(text) { 
///     case glugify.try_slugify(text) {
///       Ok(slug) -> slug
///       Error(_) -> ""
///     }
///   })
/// ]
/// let results = benchmark_multiple_functions(test_inputs, functions)
/// ```
pub fn benchmark_multiple_functions(
  inputs: List(String),
  functions: List(#(String, fn(String) -> String)),
) -> String {
  let benchmark_inputs =
    list.index_map(inputs, fn(input, index) {
      bench.Input("input_" <> int.to_string(index), input)
    })

  let benchmark_functions =
    list.map(functions, fn(func_pair) {
      let #(name, func) = func_pair
      bench.Function(name, func)
    })

  bench.run(benchmark_inputs, benchmark_functions, [
    bench.Duration(100),
    bench.Warmup(10),
  ])
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
}

/// An optimized string builder that uses string trees for efficient concatenation.
/// 
/// This type wraps Gleam's `StringTree` to provide an efficient way to build
/// strings through multiple append operations without quadratic time complexity.
/// 
/// Note: This is kept for backward compatibility with the existing API.
pub type OptimizedStringBuilder {
  OptimizedStringBuilder(tree: string_tree.StringTree)
}

/// Creates a new empty string builder.
/// 
/// ## Examples
/// 
/// ```gleam
/// let builder = new_string_builder()
/// ```
pub fn new_string_builder() -> OptimizedStringBuilder {
  OptimizedStringBuilder(tree: string_tree.new())
}

/// Appends text to the string builder.
/// 
/// This operation is efficient and doesn't require copying the entire
/// string like regular string concatenation would.
/// 
/// ## Examples
/// 
/// ```gleam
/// new_string_builder()
/// |> append_to_builder("hello")
/// |> append_to_builder(" ")
/// |> append_to_builder("world")
/// ```
pub fn append_to_builder(
  builder: OptimizedStringBuilder,
  text: String,
) -> OptimizedStringBuilder {
  OptimizedStringBuilder(tree: string_tree.append(builder.tree, text))
}

/// Converts the string builder to a final string.
/// 
/// This operation finalizes the string building process and returns
/// the concatenated result as a regular string.
/// 
/// ## Examples
/// 
/// ```gleam
/// new_string_builder()
/// |> append_to_builder("hello")
/// |> append_to_builder(" world")
/// |> builder_to_string()
/// // -> "hello world"
/// ```
pub fn builder_to_string(builder: OptimizedStringBuilder) -> String {
  string_tree.to_string(builder.tree)
}
