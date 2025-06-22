import gleam/int
import gleam/io
import gleam/list
import gleam/string_tree
import glugify
import glugify/config

pub type BenchmarkResult {
  BenchmarkResult(
    name: String,
    operations: Int,
    total_time_ms: Int,
    ops_per_second: Int,
    avg_time_per_op_microseconds: Int,
  )
}

pub fn benchmark_slugify(input: String, iterations: Int) -> BenchmarkResult {
  let start_time = get_time_microseconds()

  benchmark_slugify_loop(input, iterations, 0)

  let end_time = get_time_microseconds()
  let total_time_microseconds = end_time - start_time
  let total_time_ms = total_time_microseconds / 1000
  let avg_time_per_op = total_time_microseconds / iterations
  let ops_per_second = case total_time_ms {
    0 -> iterations * 1000
    _ -> { iterations * 1000 } / total_time_ms
  }

  BenchmarkResult(
    name: "slugify",
    operations: iterations,
    total_time_ms: total_time_ms,
    ops_per_second: ops_per_second,
    avg_time_per_op_microseconds: avg_time_per_op,
  )
}

fn benchmark_slugify_loop(input: String, remaining: Int, _acc: Int) -> Nil {
  case remaining {
    0 -> Nil
    _ -> {
      let _ = glugify.slugify(input)
      benchmark_slugify_loop(input, remaining - 1, 0)
    }
  }
}

pub fn benchmark_slugify_with_config(
  input: String,
  config: config.Config,
  iterations: Int,
) -> BenchmarkResult {
  let start_time = get_time_microseconds()

  benchmark_slugify_with_config_loop(input, config, iterations, 0)

  let end_time = get_time_microseconds()
  let total_time_microseconds = end_time - start_time
  let total_time_ms = total_time_microseconds / 1000
  let avg_time_per_op = total_time_microseconds / iterations
  let ops_per_second = case total_time_ms {
    0 -> iterations * 1000
    _ -> { iterations * 1000 } / total_time_ms
  }

  BenchmarkResult(
    name: "slugify_with_config",
    operations: iterations,
    total_time_ms: total_time_ms,
    ops_per_second: ops_per_second,
    avg_time_per_op_microseconds: avg_time_per_op,
  )
}

fn benchmark_slugify_with_config_loop(
  input: String,
  config: config.Config,
  remaining: Int,
  _acc: Int,
) -> Nil {
  case remaining {
    0 -> Nil
    _ -> {
      let _ = glugify.slugify_with(input, config)
      benchmark_slugify_with_config_loop(input, config, remaining - 1, 0)
    }
  }
}

pub fn run_performance_suite() -> List(BenchmarkResult) {
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

  let iterations = 100

  [
    benchmark_slugify(simple_text, iterations),
    benchmark_slugify(unicode_text, iterations),
    benchmark_slugify(long_text, iterations),
    benchmark_slugify(complex_text, iterations),
    benchmark_slugify_with_config(simple_text, custom_config, iterations),
    benchmark_slugify_with_config(unicode_text, custom_config, iterations),
    benchmark_slugify_with_config(long_text, custom_config, iterations),
    benchmark_slugify_with_config(complex_text, custom_config, iterations),
  ]
}

pub fn print_benchmark_result(result: BenchmarkResult) -> Nil {
  io.println(
    "Benchmark: "
    <> result.name
    <> " | Operations: "
    <> int.to_string(result.operations)
    <> " | Total Time: "
    <> int.to_string(result.total_time_ms)
    <> "ms"
    <> " | Ops/sec: "
    <> int.to_string(result.ops_per_second)
    <> " | Avg: "
    <> int.to_string(result.avg_time_per_op_microseconds)
    <> "μs",
  )
}

pub fn print_performance_report() -> Nil {
  io.println("=== Glugify Performance Benchmark Report ===")
  io.println("")

  let results = run_performance_suite()
  list.each(results, print_benchmark_result)

  io.println("")
  io.println("=== Performance Summary ===")
  let total_ops =
    list.fold(results, 0, fn(acc, result) { acc + result.operations })
  let avg_ops_per_second = case list.length(results) {
    0 -> 0
    len -> {
      let total_ops_per_second =
        list.fold(results, 0, fn(acc, result) { acc + result.ops_per_second })
      total_ops_per_second / len
    }
  }

  io.println("Total operations executed: " <> int.to_string(total_ops))
  io.println(
    "Average operations per second: " <> int.to_string(avg_ops_per_second),
  )
}

pub type OptimizedStringBuilder {
  OptimizedStringBuilder(tree: string_tree.StringTree)
}

pub fn new_string_builder() -> OptimizedStringBuilder {
  OptimizedStringBuilder(tree: string_tree.new())
}

pub fn append_to_builder(
  builder: OptimizedStringBuilder,
  text: String,
) -> OptimizedStringBuilder {
  OptimizedStringBuilder(tree: string_tree.append(builder.tree, text))
}

pub fn builder_to_string(builder: OptimizedStringBuilder) -> String {
  string_tree.to_string(builder.tree)
}

@external(erlang, "erlang", "system_time")
@external(javascript, "./glugify_ffi.mjs", "get_time_microseconds")
fn get_time_microseconds() -> Int
