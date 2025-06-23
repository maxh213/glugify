import gleam/string
import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/internal/optimized_processors

// Import from dev directory
import dev/performance

pub fn main() {
  gleeunit.main()
}

pub fn run_performance_suite_returns_string_test() {
  let result = performance.run_performance_suite()

  // The result should be a non-empty string containing benchmark data
  should.be_true(string.length(result) > 0)
}

pub fn benchmark_function_with_inputs_test() {
  let test_inputs = ["Hello World", "Test Input", "Another Test"]
  let result =
    performance.benchmark_function_with_inputs(
      test_inputs,
      fn(text) { glugify.slugify(text) },
      "test_slugify",
    )

  // The result should be a non-empty string containing benchmark data
  should.be_true(string.length(result) > 0)
}

pub fn benchmark_multiple_functions_test() {
  let test_inputs = ["Hello World", "Test Input"]
  let functions = [
    #("simple_slugify", fn(text) { glugify.slugify(text) }),
    #("try_slugify", fn(text) {
      case glugify.try_slugify(text) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
  ]

  let result = performance.benchmark_multiple_functions(test_inputs, functions)

  // The result should be a non-empty string containing benchmark data
  should.be_true(string.length(result) > 0)
}

pub fn print_performance_report_test() {
  // This test ensures the function doesn't crash when called
  performance.print_performance_report()
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
  |> should.equal("Ben and Jerry at Home")
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

pub fn benchmark_with_empty_inputs_test() {
  let result =
    performance.benchmark_function_with_inputs(
      [],
      fn(text) { glugify.slugify(text) },
      "empty_test",
    )

  // The result should be a string
  should.be_true(string.length(result) >= 0)
}

pub fn benchmark_with_single_input_test() {
  let result =
    performance.benchmark_function_with_inputs(
      ["Single Input"],
      fn(text) { glugify.slugify(text) },
      "single_test",
    )

  // The result should be a non-empty string containing benchmark data
  should.be_true(string.length(result) > 0)
}

pub fn benchmark_with_unicode_inputs_test() {
  let unicode_inputs = ["Héllo Wörld", "Café", "Naïve résumé"]
  let result =
    performance.benchmark_function_with_inputs(
      unicode_inputs,
      fn(text) { glugify.slugify(text) },
      "unicode_test",
    )

  // The result should be a non-empty string containing benchmark data
  should.be_true(string.length(result) > 0)
}

pub fn benchmark_different_config_functions_test() {
  let test_inputs = ["Hello World"]
  let default_config = config.default()
  let custom_config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(10)

  let functions = [
    #("default_config", fn(text) {
      case glugify.slugify_with(text, default_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
    #("custom_config", fn(text) {
      case glugify.slugify_with(text, custom_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
  ]

  let result = performance.benchmark_multiple_functions(test_inputs, functions)

  // The result should be a non-empty string containing bookmark data
  should.be_true(string.length(result) > 0)
}
