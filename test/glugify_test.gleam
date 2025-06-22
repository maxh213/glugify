import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/errors

pub fn main() -> Nil {
  gleeunit.main()
}

// TIER 1 API TESTS (Simple API)

pub fn simple_slugify_basic_test() {
  glugify.slugify("Hello World")
  |> should.equal("hello-world")
}

pub fn simple_slugify_with_special_chars_test() {
  glugify.slugify("Hello World! & More")
  |> should.equal("hello-world-and-more")
}

pub fn simple_slugify_with_accents_test() {
  glugify.slugify("Café résumé naïve")
  |> should.equal("cafe-resume-naive")
}

pub fn simple_slugify_empty_input_test() {
  glugify.slugify("")
  |> should.equal("")
}

pub fn simple_slugify_whitespace_only_test() {
  glugify.slugify("   ")
  |> should.equal("")
}

pub fn simple_slugify_numbers_test() {
  glugify.slugify("Version 2.0")
  |> should.equal("version-2-0")
}

pub fn simple_slugify_mixed_case_test() {
  glugify.slugify("CamelCase String")
  |> should.equal("camelcase-string")
}

pub fn simple_slugify_multiple_spaces_test() {
  glugify.slugify("Hello    World")
  |> should.equal("hello-world")
}

pub fn simple_slugify_leading_trailing_spaces_test() {
  glugify.slugify("  Hello World  ")
  |> should.equal("hello-world")
}

pub fn simple_slugify_tabs_newlines_test() {
  glugify.slugify("Hello\tWorld\nTest")
  |> should.equal("hello-world-test")
}

pub fn simple_slugify_punctuation_test() {
  glugify.slugify("Hello, World! How are you?")
  |> should.equal("hello-world-how-are-you")
}

pub fn simple_slugify_symbols_test() {
  glugify.slugify("Price: $25.99 @ store")
  |> should.equal("price-dollar-25-99-at-store")
}

pub fn simple_slugify_unicode_symbols_test() {
  glugify.slugify("Cost €100 or £85")
  |> should.equal("cost-euro-100-or-pound-85")
}

pub fn simple_slugify_consecutive_separators_test() {
  glugify.slugify("Hello---World___Test")
  |> should.equal("hello-world-test")
}

pub fn simple_slugify_german_chars_test() {
  glugify.slugify("Müller & Söhne")
  |> should.equal("muller-and-sohne")
}

pub fn simple_slugify_uppercase_accents_test() {
  glugify.slugify("CAFÉ RÉSUMÉ")
  |> should.equal("cafe-resume")
}

// TIER 2 API TESTS (Error-aware API)

pub fn try_slugify_success_test() {
  glugify.try_slugify("Hello World")
  |> should.be_ok
  |> should.equal("hello-world")
}

pub fn try_slugify_empty_input_test() {
  glugify.try_slugify("")
  |> should.be_error
  |> should.equal(errors.EmptyInput)
}

pub fn try_slugify_whitespace_only_test() {
  glugify.try_slugify("   ")
  |> should.be_error
  |> should.equal(errors.EmptyInput)
}

pub fn try_slugify_tabs_only_test() {
  glugify.try_slugify("\t\t\n")
  |> should.be_error
  |> should.equal(errors.EmptyInput)
}

pub fn try_slugify_success_with_accents_test() {
  glugify.try_slugify("Café")
  |> should.be_ok
  |> should.equal("cafe")
}

// TIER 3 API TESTS (Configurable API)

pub fn slugify_with_custom_separator_test() {
  let config = config.default() |> config.with_separator("_")

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("hello_world")
}

pub fn slugify_with_dot_separator_test() {
  let config = config.default() |> config.with_separator(".")

  glugify.slugify_with("Hello World Test", config)
  |> should.be_ok
  |> should.equal("hello.world.test")
}

pub fn slugify_with_preserve_case_test() {
  let config = config.default() |> config.with_lowercase(False)

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("Hello-World")
}

pub fn slugify_with_preserve_case_and_custom_separator_test() {
  let config =
    config.default()
    |> config.with_lowercase(False)
    |> config.with_separator("_")

  glugify.slugify_with("CamelCase String", config)
  |> should.be_ok
  |> should.equal("CamelCase_String")
}

pub fn slugify_with_max_length_test() {
  let config = config.default() |> config.with_max_length(5)

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("hello")
}

pub fn slugify_with_max_length_exact_test() {
  let config = config.default() |> config.with_max_length(11)

  glugify.slugify_with("hello-world", config)
  |> should.be_ok
  |> should.equal("hello-world")
}

pub fn slugify_with_max_length_zero_test() {
  let config = config.default() |> config.with_max_length(0)

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("")
}

pub fn slugify_with_word_boundary_truncation_test() {
  let config =
    config.default()
    |> config.with_max_length(10)
    |> config.with_word_boundary(True)

  glugify.slugify_with("hello-world-test", config)
  |> should.be_ok
  |> should.equal("hello")
}

pub fn slugify_with_no_transliteration_success_test() {
  let config = config.default() |> config.with_transliterate(False)

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("hello-world")
}

pub fn slugify_with_no_transliteration_failure_test() {
  let config = config.default() |> config.with_transliterate(False)

  glugify.slugify_with("Café", config)
  |> should.be_error
  |> should.equal(errors.TransliterationFailed("é"))
}

pub fn slugify_with_allow_unicode_test() {
  let config =
    config.default()
    |> config.with_transliterate(False)
    |> config.with_allow_unicode(True)

  glugify.slugify_with("Hello 世界", config)
  |> should.be_ok
  |> should.equal("hello-世界")
}

// EDGE CASE TESTS

pub fn slugify_only_separators_test() {
  glugify.slugify("---___...")
  |> should.equal("")
}

pub fn slugify_only_special_chars_test() {
  glugify.slugify("!@#$%^&*()")
  |> should.equal("at-dollar-percent-and")
}

pub fn slugify_mixed_whitespace_test() {
  glugify.slugify("Hello\tWorld\nTest")
  |> should.equal("hello-world-test")
}

pub fn slugify_single_char_test() {
  glugify.slugify("a")
  |> should.equal("a")
}

pub fn slugify_single_accent_test() {
  glugify.slugify("é")
  |> should.equal("e")
}

pub fn slugify_numbers_only_test() {
  glugify.slugify("12345")
  |> should.equal("12345")
}

pub fn slugify_decimal_numbers_test() {
  glugify.slugify("3.14159")
  |> should.equal("3-14159")
}

pub fn slugify_very_long_string_test() {
  let long_text =
    "This is a very long string that contains many words and should be handled properly by the slugification function without any issues"
  let expected =
    "this-is-a-very-long-string-that-contains-many-words-and-should-be-handled-properly-by-the-slugification-function-without-any-issues"

  glugify.slugify(long_text)
  |> should.equal(expected)
}

pub fn slugify_repeated_words_test() {
  glugify.slugify("test test test")
  |> should.equal("test-test-test")
}

// CONFIGURATION EDGE CASES

pub fn slugify_with_empty_separator_test() {
  let config = config.default() |> config.with_separator("")

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("helloworld")
}

pub fn slugify_with_multi_char_separator_test() {
  let config = config.default() |> config.with_separator("--")

  glugify.slugify_with("Hello World Test", config)
  |> should.be_ok
  |> should.equal("hello--world--test")
}

pub fn slugify_with_triple_char_separator_test() {
  let config = config.default() |> config.with_separator("___")

  glugify.slugify_with("Hello World Test", config)
  |> should.be_ok
  |> should.equal("hello___world___test")
}

pub fn slugify_with_mixed_multi_char_separator_test() {
  let config = config.default() |> config.with_separator("-_-")

  glugify.slugify_with("Hello World Test", config)
  |> should.be_ok
  |> should.equal("hello-_-world-_-test")
}

// NEGATIVE TESTS FOR ERROR HANDLING

pub fn try_slugify_no_transliteration_with_accents_test() {
  let config = config.default() |> config.with_transliterate(False)

  glugify.slugify_with("résumé", config)
  |> should.be_error
}

pub fn try_slugify_no_transliteration_with_symbols_test() {
  let config = config.default() |> config.with_transliterate(False)

  glugify.slugify_with("price €100", config)
  |> should.be_error
}

// COMPREHENSIVE UNICODE TESTS

pub fn slugify_all_latin_accents_test() {
  glugify.slugify("àáäãâåèéëêìíïîòóöõôùúüûçñ")
  |> should.equal("aaaaaaeeeeiiiiooooouuuucn")
}

pub fn slugify_all_latin_accents_uppercase_test() {
  glugify.slugify("ÀÁÄÃÂÅÈÉËÊÌÍÏÎÒÓÖÕÔÙÚÜÛÇÑ")
  |> should.equal("aaaaaaeeeeiiiiooooouuuucn")
}

pub fn slugify_german_specific_test() {
  glugify.slugify("Müller Grösse")
  |> should.equal("muller-grosse")
}

// STRESS TESTS

pub fn slugify_many_consecutive_spaces_test() {
  let many_spaces = "Hello                    World"

  glugify.slugify(many_spaces)
  |> should.equal("hello-world")
}

pub fn slugify_many_consecutive_separators_test() {
  glugify.slugify("Hello--------World________Test")
  |> should.equal("hello-world-test")
}

// BOUNDARY VALUE TESTS

pub fn slugify_max_length_boundary_test() {
  let config = config.default() |> config.with_max_length(1)

  glugify.slugify_with("hello", config)
  |> should.be_ok
  |> should.equal("h")
}

// COMPREHENSIVE INTEGRATION TESTS

pub fn slugify_complex_integration_test() {
  let config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(20)
    |> config.with_word_boundary(True)

  glugify.slugify_with("Café & Restaurant: €50 per person!", config)
  |> should.be_ok
  |> should.equal("cafe_and_restaurant")
}

pub fn slugify_preserve_case_with_unicode_test() {
  let config =
    config.default()
    |> config.with_lowercase(False)
    |> config.with_separator("_")

  glugify.slugify_with("CafeÉ & RestaurantÑ", config)
  |> should.be_ok
  |> should.equal("CafeE_and_RestaurantN")
}

// STOP WORDS TESTS

pub fn slugify_with_stop_words_basic_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "and", "or"])

  glugify.slugify_with("The quick and brown fox", config)
  |> should.be_ok
  |> should.equal("quick-brown-fox")
}

pub fn slugify_with_stop_words_empty_list_test() {
  let config = config.default() |> config.with_stop_words([])

  glugify.slugify_with("The quick and brown fox", config)
  |> should.be_ok
  |> should.equal("the-quick-and-brown-fox")
}

pub fn slugify_with_stop_words_case_sensitive_test() {
  let config =
    config.default()
    |> config.with_stop_words(["The", "and"])
    |> config.with_lowercase(False)

  glugify.slugify_with("The quick and brown fox", config)
  |> should.be_ok
  |> should.equal("quick-brown-fox")
}

pub fn slugify_with_stop_words_all_filtered_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "quick", "and", "brown", "fox"])

  glugify.slugify_with("The quick and brown fox", config)
  |> should.be_ok
  |> should.equal("")
}

pub fn slugify_with_stop_words_custom_separator_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "and"])
    |> config.with_separator("_")

  glugify.slugify_with("The quick and brown fox", config)
  |> should.be_ok
  |> should.equal("quick_brown_fox")
}

pub fn slugify_with_stop_words_partial_match_test() {
  let config =
    config.default()
    |> config.with_stop_words(["and"])

  glugify.slugify_with("brand and product", config)
  |> should.be_ok
  |> should.equal("brand-product")
}

pub fn slugify_with_stop_words_consecutive_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "and", "or", "of"])

  glugify.slugify_with("The art of war and peace", config)
  |> should.be_ok
  |> should.equal("art-war-peace")
}

pub fn slugify_with_stop_words_at_edges_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "end"])

  glugify.slugify_with("the beginning and the end", config)
  |> should.be_ok
  |> should.equal("beginning-and")
}

// CUSTOM REPLACEMENTS TESTS

pub fn slugify_with_custom_replacements_basic_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([#("&", " and "), #("+", " plus ")])

  glugify.slugify_with("C++ & Java", config)
  |> should.be_ok
  |> should.equal("c-plus-plus-and-java")
}

pub fn slugify_with_custom_replacements_empty_list_test() {
  let config = config.default() |> config.with_custom_replacements([])

  glugify.slugify_with("C++ & Java", config)
  |> should.be_ok
  |> should.equal("c-and-java")
}

pub fn slugify_with_custom_replacements_multiple_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([
      #("@", " at "),
      #("#", " hash "),
      #("%", " percent "),
    ])

  glugify.slugify_with("email@domain.com #tag 50%", config)
  |> should.be_ok
  |> should.equal("email-at-domain-com-hash-tag-50-percent")
}

pub fn slugify_with_custom_replacements_word_replacement_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([
      #("JavaScript", "JS"),
      #("TypeScript", "TS"),
    ])

  glugify.slugify_with("JavaScript and TypeScript Guide", config)
  |> should.be_ok
  |> should.equal("js-and-ts-guide")
}

pub fn slugify_with_custom_replacements_preserve_case_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([#("JS", "JavaScript")])
    |> config.with_lowercase(False)

  glugify.slugify_with("My JS Project", config)
  |> should.be_ok
  |> should.equal("My-JavaScript-Project")
}

pub fn slugify_with_custom_replacements_overlapping_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([
      #("++", " plus plus "),
      #("+", " plus "),
    ])

  glugify.slugify_with("C++ and C+", config)
  |> should.be_ok
  |> should.equal("c-plus-plus-and-c-plus")
}

pub fn slugify_with_custom_replacements_unicode_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([#("→", " arrow "), #("∞", " infinity ")])

  glugify.slugify_with("A → B ∞", config)
  |> should.be_ok
  |> should.equal("a-arrow-b-infinity")
}

// COMBINED FEATURES TESTS

pub fn slugify_with_stop_words_and_custom_replacements_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "and"])
    |> config.with_custom_replacements([#("&", " and ")])

  glugify.slugify_with("The cat & the dog", config)
  |> should.be_ok
  |> should.equal("cat-dog")
}

pub fn slugify_with_all_advanced_features_test() {
  let config =
    config.default()
    |> config.with_stop_words(["the", "of"])
    |> config.with_custom_replacements([#("C++", "C plus plus")])
    |> config.with_separator("_")
    |> config.with_max_length(30)
    |> config.with_word_boundary(True)

  glugify.slugify_with("The history of C++ programming", config)
  |> should.be_ok
  |> should.equal("history_c_plus_plus")
}

// EDGE CASES FOR NEW FEATURES

pub fn slugify_with_stop_words_no_match_test() {
  let config =
    config.default()
    |> config.with_stop_words(["xyz", "abc"])

  glugify.slugify_with("hello world test", config)
  |> should.be_ok
  |> should.equal("hello-world-test")
}

pub fn slugify_with_custom_replacements_no_match_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([#("xyz", "abc")])

  glugify.slugify_with("hello world test", config)
  |> should.be_ok
  |> should.equal("hello-world-test")
}

pub fn slugify_with_stop_words_single_word_test() {
  let config =
    config.default()
    |> config.with_stop_words(["hello"])

  glugify.slugify_with("hello", config)
  |> should.be_ok
  |> should.equal("")
}

pub fn slugify_with_custom_replacements_empty_string_test() {
  let config =
    config.default()
    |> config.with_custom_replacements([#("remove", "")])

  glugify.slugify_with("please remove this", config)
  |> should.be_ok
  |> should.equal("please-this")
}
