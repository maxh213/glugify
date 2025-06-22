import gleam/int
import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/errors

pub fn main() {
  gleeunit.main()
}

pub fn quick_start_examples_test() {
  glugify.slugify("Hello, World!")
  |> should.equal("hello-world")

  glugify.try_slugify("My Blog Post Title!")
  |> should.equal(Ok("my-blog-post-title"))
}

pub fn tier_1_simple_api_test() {
  glugify.slugify("My awesome blog post!")
  |> should.equal("my-awesome-blog-post")

  glugify.slugify("Café & Restaurant")
  |> should.equal("cafe-and-restaurant")
}

pub fn tier_2_error_aware_api_test() {
  let result = case glugify.try_slugify("") {
    Ok(slug) -> "Generated slug: " <> slug
    Error(_error) -> "Failed to generate slug"
  }
  result
  |> should.equal("Failed to generate slug")

  glugify.try_slugify("Valid input")
  |> should.equal(Ok("valid-input"))
}

pub fn tier_3_configurable_api_test() {
  let custom_config =
    config.default()
    |> config.with_separator("_")
    |> config.with_max_length(20)
    |> config.with_word_boundary(True)

  glugify.slugify_with("A Very Long Title That Needs Truncation", custom_config)
  |> should.equal(Ok("a_very_long_title"))
}

pub fn custom_replacements_test() {
  let custom_config =
    config.default()
    |> config.with_custom_replacements([
      #("&", " and "),
      #("@", " at "),
      #("%", " percent "),
    ])

  glugify.slugify_with("Cats & Dogs @ 100%", custom_config)
  |> should.equal(Ok("cats-and-dogs-at-100-percent"))
}

pub fn unicode_handling_transliteration_test() {
  glugify.slugify("Café naïve résumé")
  |> should.equal("cafe-naive-resume")
}

pub fn unicode_handling_preserve_test() {
  let unicode_config =
    config.default()
    |> config.with_transliterate(False)
    |> config.with_allow_unicode(True)

  glugify.slugify_with("Café naïve résumé", unicode_config)
  |> should.equal(Ok("café-naïve-résumé"))
}

pub fn stop_words_test() {
  let stop_words_config =
    config.default()
    |> config.with_stop_words(["the", "a", "an", "and", "or"])

  glugify.slugify_with(
    "The Quick Brown Fox and the Lazy Dog",
    stop_words_config,
  )
  |> should.equal(Ok("quick-brown-fox-lazy-dog"))
}

pub fn error_handling_test() {
  let result = case glugify.try_slugify("") {
    Ok(slug) -> slug
    Error(errors.EmptyInput) -> "Please provide some text"
    Error(errors.InvalidInput(reason)) -> "Invalid input: " <> reason
    Error(errors.TooLong(current, max)) ->
      "Text too long: " <> int.to_string(current) <> "/" <> int.to_string(max)
    Error(errors.TransliterationFailed(char)) ->
      "Cannot transliterate: " <> char
    Error(errors.ConfigurationError(msg)) -> "Config error: " <> msg
  }
  result
  |> should.equal("Please provide some text")
}

pub fn various_configuration_options_test() {
  let comprehensive_config =
    config.default()
    |> config.with_separator("_")
    |> config.with_lowercase(False)
    |> config.with_max_length(50)
    |> config.with_word_boundary(True)
    |> config.with_transliterate(False)
    |> config.with_allow_unicode(True)
    |> config.with_custom_replacements([#("&", " and "), #("@", " at ")])
    |> config.with_stop_words(["the", "a"])

  glugify.slugify_with("The Amazing @Café & Restaurant", comprehensive_config)
  |> should.equal(Ok("The_Amazing_at_Café_and_Restaurant"))
}

pub fn edge_case_empty_input_test() {
  glugify.slugify("")
  |> should.equal("")

  glugify.try_slugify("")
  |> should.be_error()
}

pub fn edge_case_whitespace_only_test() {
  glugify.slugify("   ")
  |> should.equal("")

  glugify.try_slugify("   ")
  |> should.be_error()
}

pub fn edge_case_special_chars_only_test() {
  glugify.slugify("!@#$%^&*()")
  |> should.equal("at-dollar-percent-and")
}
