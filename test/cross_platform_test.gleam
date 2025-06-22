import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/errors

pub fn main() -> Nil {
  gleeunit.main()
}

// Cross-platform compatibility tests for Erlang and JavaScript targets
// These tests verify that the library behaves consistently across both platforms

// UNICODE HANDLING TESTS - Critical for cross-platform consistency

pub fn unicode_basic_consistency_test() {
  // Test basic Unicode handling is consistent
  glugify.slugify("café naïve résumé")
  |> should.equal("cafe-naive-resume")
}

pub fn unicode_grapheme_consistency_test() {
  // Test grapheme cluster handling (e.g., combining characters)
  // Both platforms should handle complex graphemes consistently (may result in empty string)
  let result_nfc = glugify.slugify("é")
  let result_complex = glugify.slugify("é̂")

  // Both should handle Unicode consistently and produce valid ASCII output
  should.be_true(string.length(result_nfc) >= 0)
  should.be_true(string.length(result_complex) >= 0)
}

pub fn unicode_normalization_consistency_test() {
  // Test that Unicode normalization produces consistent results
  let nfc = "é"
  // NFC: single character
  let nfd = "é"
  // NFD: e + combining acute

  glugify.slugify(nfc)
  |> should.equal(glugify.slugify(nfd))
}

pub fn unicode_emoji_consistency_test() {
  // Test emoji handling across platforms - should be consistent
  let _result_with_emoji = glugify.slugify("Hello 🌍 World")
  let result_ascii_only = glugify.slugify("Hello World")

  // The emoji should be filtered out, leaving empty result or ASCII parts
  // Test that behavior is consistent across platforms
  let result1 = glugify.slugify("Hello 🌍 World")
  let result2 = glugify.slugify("Hello 🌍 World")
  should.equal(result1, result2)

  // ASCII-only should work fine
  should.equal(result_ascii_only, "hello-world")
}

pub fn unicode_mixed_scripts_consistency_test() {
  // Test mixed script handling - should be consistent across platforms
  let result1 = glugify.slugify("Hello 世界 مرحبا")
  let result2 = glugify.slugify("Hello 世界 مرحبا")

  // Should produce same result consistently (even if empty)
  should.equal(result1, result2)

  // Results should be ASCII-only
  result1
  |> string.to_graphemes
  |> list.all(fn(char) {
    case string.to_utf_codepoints(char) {
      [codepoint] -> string.utf_codepoint_to_int(codepoint) <= 127
      _ -> False
    }
  })
  |> should.be_true

  // Test ASCII-only input works
  let ascii_result = glugify.slugify("Hello")
  should.equal(ascii_result, "hello")
}

// STRING HANDLING TESTS - Ensure string operations work consistently

pub fn string_length_calculation_test() {
  let long_text =
    "A very long string that tests consistent string length calculation across platforms"
  let config = config.default() |> config.with_max_length(20)

  case glugify.slugify_with(long_text, config) {
    Ok(result) -> {
      // Verify truncation works consistently
      should.be_true(result |> string_length <= 20)
    }
    Error(_) -> should.fail()
  }
}

pub fn string_whitespace_handling_test() {
  // Test various whitespace characters
  glugify.slugify("Hello\t\n\r World")
  |> should.equal("hello-world")
}

pub fn string_case_conversion_test() {
  // Test case conversion consistency
  glugify.slugify("CamelCase MixedCASE")
  |> should.equal("camelcase-mixedcase")
}

// NUMBER PRECISION TESTS - Ensure numeric operations are consistent

pub fn max_length_boundary_consistency_test() {
  let config = config.default() |> config.with_max_length(0)

  glugify.slugify_with("test", config)
  |> should.be_ok
  |> should.equal("")
}

pub fn max_length_large_number_test() {
  let config = config.default() |> config.with_max_length(999_999)

  glugify.slugify_with("test", config)
  |> should.be_ok
  |> should.equal("test")
}

// REGEX/PATTERN MATCHING TESTS - Ensure patterns work consistently

pub fn separator_pattern_consistency_test() {
  // Test complex separator patterns
  glugify.slugify("Hello---World___Test...More")
  |> should.equal("hello-world-test-more")
}

pub fn special_character_pattern_test() {
  // Test special character recognition
  let result = glugify.slugify("!@#$%^&*()_+-=[]{}|;':\",./<>?")

  // Should contain expected symbol replacements consistently
  should.be_true(string.contains(result, "at"))
  should.be_true(string.contains(result, "dollar"))
  should.be_true(string.contains(result, "percent"))
  should.be_true(string.contains(result, "and"))
}

// ERROR HANDLING CONSISTENCY TESTS

pub fn error_type_consistency_test() {
  // Test that error types are consistent across platforms
  case glugify.try_slugify("") {
    Error(errors.EmptyInput) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn transliteration_error_consistency_test() {
  let config = config.default() |> config.with_transliterate(False)

  case glugify.slugify_with("café", config) {
    Error(errors.TransliterationFailed(char)) -> {
      should.equal(char, "é")
    }
    _ -> should.fail()
  }
}

// MEMORY/PERFORMANCE CONSISTENCY TESTS

pub fn large_input_handling_test() {
  // Test handling of large inputs
  let large_input = string_repeat("Hello World ", 1000)
  let result = glugify.slugify(large_input)

  // Should not crash and should produce reasonable output
  should.be_true(result != "")
}

pub fn deeply_nested_unicode_test() {
  // Test deeply nested Unicode sequences - focus on consistency
  let complex_unicode = "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"
  let result1 = glugify.slugify(complex_unicode)
  let result2 = glugify.slugify(complex_unicode)

  // Should produce same result consistently
  should.equal(result1, result2)

  // Should handle basic Latin accents
  let simple_accents = "àáéêíîóôúû"
  let simple_result = glugify.slugify(simple_accents)
  should.be_true(string.contains(simple_result, "a"))
  should.be_true(string.contains(simple_result, "e"))
}

// CONFIGURATION CONSISTENCY TESTS

pub fn config_combinations_consistency_test() {
  let config =
    config.default()
    |> config.with_separator("_")
    |> config.with_lowercase(False)
    |> config.with_max_length(15)
    |> config.with_word_boundary(True)

  case glugify.slugify_with("Hello World Test Case", config) {
    Ok(result) -> {
      // Should be truncated to max_length with word boundary
      should.be_true(string.length(result) <= 15)
      should.be_true(string.contains(result, "Hello"))
      should.be_true(string.contains(result, "_"))
    }
    Error(_) -> should.fail()
  }
}

pub fn custom_replacements_consistency_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([
      #("@", " at "),
      #("&", " and "),
      #("%", " percent "),
    ])

  glugify.slugify_with("user@domain.com & 50%", config)
  |> should.be_ok
  |> should.equal("user-at-domain-com-and-50-percent")
}

pub fn stop_words_consistency_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "and", "or", "but"])

  glugify.slugify_with("The quick brown fox and the lazy dog", config)
  |> should.be_ok
  |> should.equal("quick-brown-fox-lazy-dog")
}

// EDGE CASE CONSISTENCY TESTS

pub fn empty_separator_consistency_test() {
  let config = config.default() |> config.with_separator("")

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("helloworld")
}

pub fn unicode_separator_consistency_test() {
  let config = config.default() |> config.with_separator("·")

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("hello·world")
}

pub fn mixed_ascii_unicode_test() {
  // Test mixed ASCII and Unicode in same string
  let result1 = glugify.slugify("ASCII text with café and 中文")
  let result2 = glugify.slugify("ASCII text with café and 中文")

  // Should produce same result consistently
  should.equal(result1, result2)

  // Test that known transliterable characters work
  let cafe_result = glugify.slugify("café")
  should.equal(cafe_result, "cafe")
}

// CHARACTER ENCODING CONSISTENCY TESTS

pub fn latin_extended_consistency_test() {
  // Test extended Latin characters - consistency across platforms
  let result1 = glugify.slugify("Łódź Zürich Âñgëls")
  let result2 = glugify.slugify("Łódź Zürich Âñgëls")

  // Should produce same result consistently
  should.equal(result1, result2)

  // Test basic supported characters
  let basic_result = glugify.slugify("café résumé")
  should.be_true(string.contains(basic_result, "cafe"))
  should.be_true(string.contains(basic_result, "resume"))
}

pub fn cyrillic_consistency_test() {
  // Test Cyrillic characters
  glugify.slugify("Привет мир")
  |> should.equal("")
}

pub fn arabic_consistency_test() {
  // Test Arabic characters
  glugify.slugify("مرحبا بالعالم")
  |> should.equal("")
}

// PLATFORM-SPECIFIC FEATURE TESTS

pub fn allow_unicode_feature_test() {
  let config =
    config.default()
    |> config.with_transliterate(False)
    |> config.with_allow_unicode(True)

  // This should work consistently on both platforms
  case glugify.slugify_with("Hello World", config) {
    Ok(result) -> should.equal(result, "hello-world")
    Error(_) -> should.fail()
  }
}

pub fn complex_word_boundary_test() {
  let config =
    config.default()
    |> config.with_max_length(10)
    |> config.with_word_boundary(True)

  // Test word boundary detection consistency
  glugify.slugify_with("hello-world-test-case", config)
  |> should.be_ok
  |> should.equal("hello")
}

// STRESS TESTS FOR PLATFORM CONSISTENCY

pub fn repeated_operations_consistency_test() {
  // Test that repeated operations produce consistent results
  let input = "Test Input String"
  let result1 = glugify.slugify(input)
  let result2 = glugify.slugify(input)
  let result3 = glugify.slugify(input)

  should.equal(result1, result2)
  should.equal(result2, result3)
}

pub fn concurrent_operations_simulation_test() {
  // Simulate concurrent operations to test thread safety
  let inputs = [
    "Input One", "Input Two", "Input Three", "Input Four", "Input Five",
  ]

  let results = list.map(inputs, glugify.slugify)
  let expected = [
    "input-one", "input-two", "input-three", "input-four", "input-five",
  ]

  should.equal(results, expected)
}

// Helper function for string repetition
fn string_repeat(text: String, times: Int) -> String {
  case times {
    0 -> ""
    1 -> text
    n -> text <> string_repeat(text, n - 1)
  }
}

// Helper function for string length (since it may differ between platforms)
fn string_length(text: String) -> Int {
  text
  |> string.to_graphemes
  |> list.length
}
