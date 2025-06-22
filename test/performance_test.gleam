import gleam/list
import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/internal/optimized_processors
import glugify/performance

pub fn main() {
  gleeunit.main()
}

pub fn benchmark_basic_slugify_test() {
  let result = performance.benchmark_slugify("Hello World", 100)

  result.name |> should.equal("slugify")
  result.operations |> should.equal(100)
  should.be_true(result.total_time_ms >= 0)
  should.be_true(result.ops_per_second >= 0)
  should.be_true(result.avg_time_per_op_microseconds >= 0)
}

pub fn benchmark_with_config_test() {
  let custom_config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(10)

  let result =
    performance.benchmark_slugify_with_config(
      "Hello World Test",
      custom_config,
      50,
    )

  result.name |> should.equal("slugify_with_config")
  result.operations |> should.equal(50)
  should.be_true(result.total_time_ms >= 0)
  should.be_true(result.ops_per_second >= 0)
  should.be_true(result.avg_time_per_op_microseconds >= 0)
}

pub fn performance_suite_returns_results_test() {
  let results = performance.run_performance_suite()

  list.length(results) |> should.equal(8)

  list.each(results, fn(result) {
    should.be_true(result.operations >= 0)
    should.be_true(result.total_time_ms >= 0)
    should.be_true(result.ops_per_second >= 0)
    should.be_true(result.avg_time_per_op_microseconds >= 0)
  })
}

pub fn string_builder_optimization_test() {
  let builder =
    performance.new_string_builder()
    |> performance.append_to_builder("Hello")
    |> performance.append_to_builder(" ")
    |> performance.append_to_builder("World")

  performance.builder_to_string(builder) |> should.equal("Hello World")
}

pub fn optimized_normalize_whitespace_test() {
  optimized_processors.optimized_normalize_whitespace("  Hello    World  ")
  |> should.be_ok()
  |> should.equal(" Hello World ")

  optimized_processors.optimized_normalize_whitespace("No   extra   spaces")
  |> should.be_ok()
  |> should.equal("No extra spaces")

  optimized_processors.optimized_normalize_whitespace("Tab\t\tand\nnewline")
  |> should.be_ok()
  |> should.equal("Tab and newline")
}

pub fn optimized_apply_separators_test() {
  let config = config.default() |> config.with_separator("-")

  optimized_processors.optimized_apply_separators("Hello World!", config)
  |> should.be_ok()
  |> should.equal("Hello-World")

  let no_sep_config = config.default() |> config.with_separator("")
  optimized_processors.optimized_apply_separators("Hello World!", no_sep_config)
  |> should.be_ok()
  |> should.equal("HelloWorld")
}

pub fn optimized_remove_invalid_chars_test() {
  let config =
    config.default()
    |> config.with_separator("-")
    |> config.with_allow_unicode(False)

  optimized_processors.optimized_remove_invalid_chars("Hello-World@#$", config)
  |> should.be_ok()
  |> should.equal("Hello-World")

  let unicode_config =
    config.default()
    |> config.with_separator("-")
    |> config.with_allow_unicode(True)

  optimized_processors.optimized_remove_invalid_chars(
    "Hello-Wörld",
    unicode_config,
  )
  |> should.be_ok()
  |> should.equal("Hello-Wörld")
}

pub fn optimized_custom_replacements_test() {
  let replacements = [#("&", " and "), #("@", " at ")]

  optimized_processors.optimized_apply_custom_replacements(
    "Ben & Jerry @ Home",
    replacements,
  )
  |> should.be_ok()
  |> should.equal("Ben  and  Jerry  at  Home")
}

pub fn batch_process_with_tree_test() {
  let config =
    config.default()
    |> config.with_separator("-")
    |> config.with_lowercase(True)

  optimized_processors.batch_process_with_tree("Hello World Test", config)
  |> should.be_ok()
  |> should.equal("hello-world-test")
}

pub fn performance_comparison_test() {
  let test_input = "This is a test string with various characters & symbols!"
  let iterations = 100

  let standard_result = performance.benchmark_slugify(test_input, iterations)
  let config_result =
    performance.benchmark_slugify_with_config(
      test_input,
      config.default(),
      iterations,
    )

  standard_result.operations |> should.equal(iterations)
  config_result.operations |> should.equal(iterations)

  // Both should produce same result
  glugify.slugify(test_input)
  |> should.equal(case glugify.slugify_with(test_input, config.default()) {
    Ok(result) -> result
    Error(_) -> ""
  })
}

pub fn edge_case_performance_test() {
  let empty_result = performance.benchmark_slugify("", 50)
  let very_long_result =
    performance.benchmark_slugify(
      "This is an extremely long string that contains many words",
      50,
    )

  empty_result.operations |> should.equal(50)
  very_long_result.operations |> should.equal(50)

  // Should handle edge cases without crashing
  should.be_true(empty_result.total_time_ms >= 0)
  should.be_true(very_long_result.total_time_ms >= 0)
}
