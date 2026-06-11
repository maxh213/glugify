import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/errors
import glugify/locale
import glugify/slugger

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

  // Stop word matching is case-insensitive, so "The" is removed by "the"
  glugify.slugify_with("The Amazing @Café & Restaurant", comprehensive_config)
  |> should.equal(Ok("Amazing_at_Café_and_Restaurant"))
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

pub fn readme_unique_slugs_test() {
  let s = slugger.new()
  let #(s, a) = slugger.slug(s, "Hello World")
  let #(s, b) = slugger.slug(s, "Hello World")
  let #(_, c) = slugger.slug(s, "Hello World")
  a |> should.equal("hello-world")
  b |> should.equal("hello-world-1")
  c |> should.equal("hello-world-2")
}

pub fn readme_transliteration_coverage_test() {
  glugify.slugify("10 Tips 🚀 for Gleam")
  |> should.equal("10-tips-for-gleam")

  glugify.slugify("Привет мир")
  |> should.equal("privet-mir")

  glugify.slugify("Don’t — “Stop”")
  |> should.equal("dont-stop")
}

pub fn readme_locale_examples_test() {
  let config =
    config.default()
    |> config.with_locale(locale.German)

  glugify.slugify_with("Über München", config)
  |> should.equal(Ok("ueber-muenchen"))

  let config =
    config.default()
    |> config.with_locale(locale.Danish)

  glugify.slugify_with("København på Ærø", config)
  |> should.equal(Ok("koebenhavn-paa-aeroe"))
}

pub fn readme_decamelize_example_test() {
  let config =
    config.default()
    |> config.with_decamelize(True)

  glugify.slugify_with("myAwesomeXMLParser", config)
  |> should.equal(Ok("my-awesome-xml-parser"))
}

pub fn readme_html_entities_example_test() {
  let config =
    config.default()
    |> config.with_decode_html_entities(True)

  glugify.slugify_with("Tom &amp; Jerry &ndash; Classics", config)
  |> should.equal(Ok("tom-and-jerry-classics"))
}

pub fn readme_ignored_characters_example_test() {
  let config =
    config.default()
    |> config.with_ignore(["#"])

  glugify.slugify_with("C# and F# compared", config)
  |> should.equal(Ok("c#-and-f#-compared"))
}
