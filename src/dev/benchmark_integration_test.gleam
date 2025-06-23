import dev/performance
import gleam/string
import gleeunit
import gleeunit/should
import glugify
import glugify/config

pub fn main() {
  gleeunit.main()
}

pub fn benchmark_runner_executes_without_error_test() {
  performance.print_performance_report()
}

pub fn string_builder_handles_empty_strings_test() {
  let builder = performance.new_string_builder()
  performance.builder_to_string(builder) |> should.equal("")
}

pub fn string_builder_handles_single_append_test() {
  let builder =
    performance.new_string_builder()
    |> performance.append_to_builder("single")

  performance.builder_to_string(builder) |> should.equal("single")
}

pub fn string_builder_handles_multiple_empty_appends_test() {
  let builder =
    performance.new_string_builder()
    |> performance.append_to_builder("")
    |> performance.append_to_builder("")
    |> performance.append_to_builder("")

  performance.builder_to_string(builder) |> should.equal("")
}

pub fn string_builder_handles_mixed_content_test() {
  let builder =
    performance.new_string_builder()
    |> performance.append_to_builder("Hello")
    |> performance.append_to_builder("")
    |> performance.append_to_builder("World")
    |> performance.append_to_builder(" ")
    |> performance.append_to_builder("Test")

  performance.builder_to_string(builder) |> should.equal("HelloWorld Test")
}

pub fn benchmark_with_special_characters_test() {
  let special_inputs = ["@#$%^&*()", "Hello@World", "Test#123"]
  let result =
    performance.benchmark_function_with_inputs(
      special_inputs,
      fn(text) { glugify.slugify(text) },
      "special_chars_test",
    )

  should.be_true(string.length(result) > 0)
}

pub fn benchmark_with_very_long_strings_test() {
  let long_input = string.repeat("Very Long String Content ", 50)
  let result =
    performance.benchmark_function_with_inputs(
      [long_input],
      fn(text) { glugify.slugify(text) },
      "long_string_test",
    )

  should.be_true(string.length(result) > 0)
}

pub fn benchmark_error_handling_functions_test() {
  let test_inputs = ["Valid Input", "", "Another Valid Input"]
  let functions = [
    #("try_slugify", fn(text) {
      case glugify.try_slugify(text) {
        Ok(slug) -> slug
        Error(_) -> "ERROR"
      }
    }),
    #("simple_slugify", fn(text) { glugify.slugify(text) }),
  ]

  let result = performance.benchmark_multiple_functions(test_inputs, functions)
  should.be_true(string.length(result) > 0)
}

pub fn benchmark_with_different_separators_test() {
  let test_inputs = ["Hello World Test"]
  let dash_config = config.default() |> config.with_separator("-")
  let underscore_config = config.default() |> config.with_separator("_")
  let dot_config = config.default() |> config.with_separator(".")

  let functions = [
    #("dash_separator", fn(text) {
      case glugify.slugify_with(text, dash_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
    #("underscore_separator", fn(text) {
      case glugify.slugify_with(text, underscore_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
    #("dot_separator", fn(text) {
      case glugify.slugify_with(text, dot_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
  ]

  let result = performance.benchmark_multiple_functions(test_inputs, functions)
  should.be_true(string.length(result) > 0)
}

pub fn benchmark_with_max_length_configurations_test() {
  let test_inputs = ["This is a very long title that should be truncated"]
  let short_config = config.default() |> config.with_max_length(10)
  let medium_config = config.default() |> config.with_max_length(25)
  let long_config = config.default() |> config.with_max_length(50)

  let functions = [
    #("short_max_length", fn(text) {
      case glugify.slugify_with(text, short_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
    #("medium_max_length", fn(text) {
      case glugify.slugify_with(text, medium_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
    #("long_max_length", fn(text) {
      case glugify.slugify_with(text, long_config) {
        Ok(slug) -> slug
        Error(_) -> ""
      }
    }),
  ]

  let result = performance.benchmark_multiple_functions(test_inputs, functions)
  should.be_true(string.length(result) > 0)
}
