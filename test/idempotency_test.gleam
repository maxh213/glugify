import gleam/string
import gleeunit/should
import glugify
import glugify/config

// IDEMPOTENCY TESTS
// These tests verify that slugification functions are idempotent:
// f(f(x)) = f(x) for all valid inputs

pub fn simple_slugify_idempotency_test() {
  let input = "Hello, World!"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_accents_test() {
  let input = "Café résumé naïve"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_symbols_test() {
  let input = "Price: $25.99 @ store"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_numbers_test() {
  let input = "Version 2.0.1"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_mixed_case_test() {
  let input = "CamelCase String"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_whitespace_test() {
  let input = "  Hello    World  "
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_punctuation_test() {
  let input = "Hello, World! How are you?"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_with_unicode_symbols_test() {
  let input = "Cost €100 or £85"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn simple_slugify_idempotency_empty_result_test() {
  let input = "!@#$%^"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn try_slugify_idempotency_test() {
  let input = "Hello, World!"
  let assert Ok(first_result) = glugify.try_slugify(input)
  let assert Ok(second_result) = glugify.try_slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn try_slugify_idempotency_with_accents_test() {
  let input = "Café résumé"
  let assert Ok(first_result) = glugify.try_slugify(input)
  let assert Ok(second_result) = glugify.try_slugify(first_result)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_custom_separator_idempotency_test() {
  let config = config.default() |> config.with_separator("_")
  let input = "Hello World Test"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_preserve_case_idempotency_test() {
  let config = config.default() |> config.with_lowercase(False)
  let input = "Hello World"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_max_length_idempotency_test() {
  let config = config.default() |> config.with_max_length(10)
  let input = "This is a very long string"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)

  // Verify that truncation doesn't create trailing separators
  { string.length(first_result) <= 10 }
  |> should.be_true

  // Verify result doesn't end with separator if not empty
  case first_result {
    "" -> Nil
    _ -> {
      first_result
      |> string.ends_with("-")
      |> should.be_false
    }
  }
}

pub fn slugify_with_word_boundary_idempotency_test() {
  let config =
    config.default()
    |> config.with_max_length(10)
    |> config.with_word_boundary(True)
  let input = "hello-world-test-example"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_stop_words_idempotency_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "and", "or"])
  let input = "The quick brown fox"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_custom_replacements_idempotency_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([#("&", " and "), #("+", " plus ")])
  let input = "C++ & Java"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_multiple_char_separator_idempotency_test() {
  let config = config.default() |> config.with_separator("--")
  let input = "Hello World Test"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

pub fn slugify_with_complex_config_idempotency_test() {
  let config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(25)
    |> config.with_word_boundary(True)
    |> config.with_stop_words(["the", "and"])
    |> config.with_custom_replacements([#("&", " and ")])
  let input = "The cat & the dog are friends"

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)
}

// MULTIPLE ITERATION TESTS
// Test more than just two iterations to ensure deep idempotency

pub fn simple_slugify_multiple_iterations_test() {
  let input = "Hello, World! & More"
  let first = glugify.slugify(input)
  let second = glugify.slugify(first)
  let third = glugify.slugify(second)
  let fourth = glugify.slugify(third)

  first
  |> should.equal(second)

  second
  |> should.equal(third)

  third
  |> should.equal(fourth)
}

pub fn try_slugify_multiple_iterations_test() {
  let input = "Café & Restaurant"
  let assert Ok(first) = glugify.try_slugify(input)
  let assert Ok(second) = glugify.try_slugify(first)
  let assert Ok(third) = glugify.try_slugify(second)
  let assert Ok(fourth) = glugify.try_slugify(third)

  first
  |> should.equal(second)

  second
  |> should.equal(third)

  third
  |> should.equal(fourth)
}

pub fn slugify_with_multiple_iterations_test() {
  let config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(20)
  let input = "This is a long title that will be truncated"

  let assert Ok(first) = glugify.slugify_with(input, config)
  let assert Ok(second) = glugify.slugify_with(first, config)
  let assert Ok(third) = glugify.slugify_with(second, config)
  let assert Ok(fourth) = glugify.slugify_with(third, config)

  first
  |> should.equal(second)

  second
  |> should.equal(third)

  third
  |> should.equal(fourth)
}

// EDGE CASE IDEMPOTENCY TESTS

pub fn already_slugified_idempotency_test() {
  let input = "hello-world-test"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)

  first_result
  |> should.equal("hello-world-test")
}

pub fn single_char_idempotency_test() {
  let input = "a"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)

  first_result
  |> should.equal("a")
}

pub fn numbers_only_idempotency_test() {
  let input = "12345"
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)

  first_result
  |> should.equal("12345")
}

pub fn with_separators_already_idempotency_test() {
  let input = "hello-world-test"
  let config = config.default() |> config.with_separator("_")

  let assert Ok(first_result) = glugify.slugify_with(input, config)
  let assert Ok(second_result) = glugify.slugify_with(first_result, config)

  first_result
  |> should.equal(second_result)

  first_result
  |> should.equal("hello_world_test")
}

pub fn empty_result_idempotency_test() {
  let input = "   "
  let first_result = glugify.slugify(input)
  let second_result = glugify.slugify(first_result)

  first_result
  |> should.equal(second_result)

  first_result
  |> should.equal("")
}
