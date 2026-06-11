//// Tests for the v3.0.0 features: unique slugger, locales, decamelize,
//// HTML entity decoding and the SEO preset.

import gleam/string
import gleeunit/should
import glugify
import glugify/config
import glugify/locale
import glugify/slugger

// UNIQUE SLUGGER

pub fn slugger_first_occurrence_is_plain_test() {
  let #(_, slug) = slugger.slug(slugger.new(), "Hello World")
  slug |> should.equal("hello-world")
}

pub fn slugger_duplicates_get_suffixes_test() {
  let s = slugger.new()
  let #(s, a) = slugger.slug(s, "Hello World")
  let #(s, b) = slugger.slug(s, "Hello World")
  let #(_, c) = slugger.slug(s, "Hello World")
  a |> should.equal("hello-world")
  b |> should.equal("hello-world-1")
  c |> should.equal("hello-world-2")
}

pub fn slugger_presuffixed_input_does_not_collide_test() {
  let s = slugger.new()
  let #(s, a) = slugger.slug(s, "foo")
  let #(s, b) = slugger.slug(s, "foo")
  let #(_, c) = slugger.slug(s, "foo-1")
  a |> should.equal("foo")
  b |> should.equal("foo-1")
  c |> should.equal("foo-1-1")
}

pub fn slugger_suffix_taken_first_skips_ahead_test() {
  let s = slugger.new()
  let #(s, a) = slugger.slug(s, "foo-1")
  let #(s, b) = slugger.slug(s, "foo")
  let #(_, c) = slugger.slug(s, "foo")
  a |> should.equal("foo-1")
  b |> should.equal("foo")
  // "foo-1" is already taken, so the duplicate skips to "foo-2"
  c |> should.equal("foo-2")
}

pub fn slugger_empty_results_bypass_uniqueness_test() {
  let s = slugger.new()
  let #(s, a) = slugger.slug(s, "!!!")
  let #(_, b) = slugger.slug(s, "!!!")
  a |> should.equal("")
  b |> should.equal("")
}

pub fn slugger_with_config_test() {
  let cfg = config.default() |> config.with_separator("_")
  let assert Ok(#(s, a)) = slugger.slug_with(slugger.new(), "My Post", cfg)
  let assert Ok(#(_, b)) = slugger.slug_with(s, "My Post", cfg)
  a |> should.equal("my_post")
  b |> should.equal("my_post-1")
}

// LOCALES

pub fn german_locale_test() {
  let cfg = config.default() |> config.with_locale(locale.German)
  glugify.slugify_with("Über München", cfg)
  |> should.equal(Ok("ueber-muenchen"))
}

pub fn german_locale_eszett_test() {
  let cfg = config.default() |> config.with_locale(locale.German)
  glugify.slugify_with("Straße", cfg)
  |> should.equal(Ok("strasse"))
}

pub fn danish_locale_test() {
  let cfg = config.default() |> config.with_locale(locale.Danish)
  glugify.slugify_with("København på Ærø", cfg)
  |> should.equal(Ok("koebenhavn-paa-aeroe"))
}

pub fn default_locale_unchanged_test() {
  glugify.slugify("Über München")
  |> should.equal("uber-munchen")
}

pub fn swedish_locale_matches_default_test() {
  let cfg = config.default() |> config.with_locale(locale.Swedish)
  glugify.slugify_with("Smörgåsbord", cfg)
  |> should.equal(Ok("smorgasbord"))
}

// DECAMELIZE

pub fn decamelize_simple_test() {
  let cfg = config.default() |> config.with_decamelize(True)
  glugify.slugify_with("fooBar", cfg)
  |> should.equal(Ok("foo-bar"))
}

pub fn decamelize_acronym_test() {
  let cfg = config.default() |> config.with_decamelize(True)
  glugify.slugify_with("myAwesomeXMLParser", cfg)
  |> should.equal(Ok("my-awesome-xml-parser"))
}

pub fn decamelize_with_digits_test() {
  // Digit-to-upper is a boundary; letter-to-digit is not
  let cfg = config.default() |> config.with_decamelize(True)
  glugify.slugify_with("version2Update", cfg)
  |> should.equal(Ok("version2-update"))
}

pub fn decamelize_off_by_default_test() {
  glugify.slugify("fooBar")
  |> should.equal("foobar")
}

pub fn decamelize_leaves_normal_text_alone_test() {
  let cfg = config.default() |> config.with_decamelize(True)
  glugify.slugify_with("Hello Wonderful World", cfg)
  |> should.equal(Ok("hello-wonderful-world"))
}

// HTML ENTITIES

pub fn entity_named_test() {
  let cfg = config.default() |> config.with_decode_html_entities(True)
  glugify.slugify_with("Tom &amp; Jerry", cfg)
  |> should.equal(Ok("tom-and-jerry"))
}

pub fn entity_decimal_test() {
  let cfg = config.default() |> config.with_decode_html_entities(True)
  glugify.slugify_with("Tom &#38; Jerry", cfg)
  |> should.equal(Ok("tom-and-jerry"))
}

pub fn entity_hex_test() {
  let cfg = config.default() |> config.with_decode_html_entities(True)
  glugify.slugify_with("Tom &#x26; Jerry", cfg)
  |> should.equal(Ok("tom-and-jerry"))
}

pub fn entity_typographic_test() {
  let cfg = config.default() |> config.with_decode_html_entities(True)
  glugify.slugify_with("Rock&nbsp;&ndash;&nbsp;Roll&hellip;", cfg)
  |> should.equal(Ok("rock-roll"))
}

pub fn entity_invalid_left_alone_test() {
  let cfg = config.default() |> config.with_decode_html_entities(True)
  glugify.slugify_with("AT&T &notanentity; x", cfg)
  |> should.equal(Ok("at-and-t-and-notanentity-x"))
}

pub fn entities_off_by_default_test() {
  glugify.slugify("Tom &amp; Jerry")
  |> should.equal("tom-and-amp-jerry")
}

// SEO PRESET

pub fn seo_preset_truncates_at_word_boundary_test() {
  let assert Ok(slug) =
    glugify.slugify_with(
      "A Very Long Production Title That Search Engines Would Rather Not See In Full",
      config.seo_preset(),
    )
  { string.length(slug) <= 60 } |> should.be_true
  string.ends_with(slug, "-") |> should.be_false
  slug |> should.equal("a-very-long-production-title-that-search-engines-would")
}

// IGNORE LIST

pub fn ignore_keeps_ascii_symbol_test() {
  let cfg = config.default() |> config.with_ignore(["#"])
  glugify.slugify_with("C# rocks", cfg)
  |> should.equal(Ok("c#-rocks"))
}

pub fn ignore_keeps_unicode_grapheme_test() {
  let cfg = config.default() |> config.with_ignore(["嗨"])
  glugify.slugify_with("嗨 hello", cfg)
  |> should.equal(Ok("嗨-hello"))
}

pub fn ignore_exempts_from_transliteration_test() {
  // Without ignore, é is transliterated to e; with ignore it is kept
  let cfg = config.default() |> config.with_ignore(["é"])
  glugify.slugify_with("café", cfg)
  |> should.equal(Ok("café"))
}

pub fn ignore_with_strict_ascii_validation_test() {
  let cfg =
    config.default()
    |> config.with_transliterate(False)
    |> config.with_ignore(["é"])

  glugify.slugify_with("café", cfg)
  |> should.equal(Ok("café"))
}

pub fn ignore_empty_changes_nothing_test() {
  glugify.slugify("C# rocks")
  |> should.equal("c-rocks")
}

// APOSTROPHES (ASCII, aligned with smart quotes in 3.0.0)

pub fn ascii_apostrophe_joins_test() {
  glugify.slugify("don't stop")
  |> should.equal("dont-stop")
}
