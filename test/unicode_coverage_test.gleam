//// Tests for the expanded transliteration coverage and graceful handling
//// of unmappable characters introduced in v2.1.0.

import gleeunit/should
import glugify
import glugify/config
import glugify/errors

// EXTENDED LATIN

pub fn polish_test() {
  glugify.slugify("Łódź")
  |> should.equal("lodz")
}

pub fn danish_norwegian_test() {
  glugify.slugify("København Æble Øl Å")
  |> should.equal("kobenhavn-aeble-ol-a")
}

pub fn icelandic_test() {
  glugify.slugify("Þór Ðögg")
  |> should.equal("thor-dogg")
}

pub fn czech_test() {
  glugify.slugify("Žluťoučký kůň")
  |> should.equal("zlutoucky-kun")
}

pub fn turkish_test() {
  // Transliteration runs before lowercasing, so İ -> I -> i
  glugify.slugify("İstanbul INATÇI")
  |> should.equal("istanbul-inatci")
}

pub fn french_ligature_test() {
  glugify.slugify("Œuvre cœur")
  |> should.equal("oeuvre-coeur")
}

pub fn romanian_test() {
  glugify.slugify("București își")
  |> should.equal("bucuresti-isi")
}

// CYRILLIC AND GREEK

pub fn russian_test() {
  glugify.slugify("Привет мир")
  |> should.equal("privet-mir")
}

pub fn russian_complex_test() {
  glugify.slugify("Щука и ёж")
  |> should.equal("shchuka-i-yozh")
}

pub fn ukrainian_test() {
  glugify.slugify("Київ їжак")
  |> should.equal("kiyiv-yizhak")
}

pub fn greek_test() {
  glugify.slugify("Καλημέρα κόσμε")
  |> should.equal("kalimera-kosme")
}

// ARABIC AND HEBREW

pub fn arabic_test() {
  // Basic consonantal romanization, as in other slugify libraries
  glugify.slugify("مرحبا بالعالم")
  |> should.equal("mrhba-balaalm")
}

pub fn arabic_digits_test() {
  glugify.slugify("الفصل ٣")
  |> should.equal("alfsl-3")
}

pub fn persian_test() {
  glugify.slugify("پژوهش گروه")
  |> should.equal("pzhwhsh-grwh")
}

pub fn hebrew_test() {
  glugify.slugify("שלום עולם")
  |> should.equal("shlvm-avlm")
}

// TYPOGRAPHIC PUNCTUATION

pub fn smart_quotes_test() {
  glugify.slugify("“Hello” ‘World’")
  |> should.equal("hello-world")
}

pub fn smart_apostrophe_joins_test() {
  // Apostrophes are removed rather than turned into separators
  glugify.slugify("Don’t Stop Believin’")
  |> should.equal("dont-stop-believin")
}

pub fn dashes_test() {
  glugify.slugify("2020–2021 — report")
  |> should.equal("2020-2021-report")
}

pub fn ellipsis_and_guillemets_test() {
  glugify.slugify("Wait… «really»?")
  |> should.equal("wait-really")
}

pub fn non_breaking_space_test() {
  glugify.slugify("hello\u{00A0}world")
  |> should.equal("hello-world")
}

// CURRENCY AND SYMBOLS

pub fn currency_test() {
  glugify.slugify("¥100 and ₹500")
  |> should.equal("yen-100-and-rupee-500")
}

pub fn trademark_test() {
  glugify.slugify("Gleam™")
  |> should.equal("gleam-tm")
}

pub fn degrees_test() {
  // ASCII apostrophes join like smart apostrophes: "It's" -> "its"
  glugify.slugify("It's 30° outside")
  |> should.equal("its-30-degrees-outside")
}

// UNMAPPED CHARACTERS ARE STRIPPED, NOT ERRORS

pub fn emoji_is_stripped_test() {
  glugify.slugify("10 Tips 🚀 for Gleam 🎉")
  |> should.equal("10-tips-for-gleam")
}

pub fn emoji_with_variation_selector_test() {
  glugify.slugify("I ❤️ Gleam")
  |> should.equal("i-gleam")
}

pub fn cjk_is_stripped_test() {
  // CJK has no transliteration tables yet; characters are stripped
  glugify.try_slugify("hello 世界 world")
  |> should.equal(Ok("hello-world"))
}

pub fn emoji_only_input_gives_empty_test() {
  glugify.try_slugify("🚀🎉")
  |> should.equal(Ok(""))
}

// DECOMPOSED (NFD) INPUT

pub fn nfd_accent_test() {
  // "café" written as "cafe" + U+0301 combining acute accent
  glugify.slugify("cafe\u{0301}")
  |> should.equal("cafe")
}

pub fn nfd_multiple_accents_test() {
  // "résumé" with both accents as combining marks
  glugify.slugify("re\u{0301}sume\u{0301}")
  |> should.equal("resume")
}

pub fn nfd_with_allow_unicode_is_kept_test() {
  // Multi-codepoint graphemes survive allow_unicode mode
  let unicode_config =
    config.default()
    |> config.with_transliterate(False)
    |> config.with_allow_unicode(True)

  glugify.slugify_with("cafe\u{0301} time", unicode_config)
  |> should.equal(Ok("cafe\u{0301}-time"))
}

pub fn zero_width_joiner_emoji_with_allow_unicode_test() {
  let unicode_config =
    config.default()
    |> config.with_transliterate(False)
    |> config.with_allow_unicode(True)

  glugify.slugify_with("family 👨‍👩‍👧 fun", unicode_config)
  |> should.equal(Ok("family-👨‍👩‍👧-fun"))
}

// STRICT ASCII VALIDATION STILL ERRORS

pub fn transliterate_disabled_still_errors_test() {
  let strict_config =
    config.default()
    |> config.with_transliterate(False)

  glugify.slugify_with("café", strict_config)
  |> should.equal(Error(errors.TransliterationFailed("é")))
}

// STOP WORDS ARE CASE-INSENSITIVE

pub fn stop_words_case_insensitive_test() {
  let stop_config =
    config.default()
    |> config.with_lowercase(False)
    |> config.with_stop_words(["the", "a"])

  glugify.slugify_with("The Quick Brown Fox", stop_config)
  |> should.equal(Ok("Quick-Brown-Fox"))
}

pub fn stop_words_uppercase_config_test() {
  let stop_config =
    config.default()
    |> config.with_stop_words(["THE"])

  glugify.slugify_with("the quick fox", stop_config)
  |> should.equal(Ok("quick-fox"))
}

// PRESERVE OPTIONS

pub fn preserve_leading_underscore_test() {
  let preserve_config =
    config.default()
    |> config.with_preserve_leading_underscore(True)

  glugify.slugify_with("_private notes", preserve_config)
  |> should.equal(Ok("_private-notes"))
}

pub fn preserve_leading_underscore_off_by_default_test() {
  glugify.slugify("_private notes")
  |> should.equal("private-notes")
}

pub fn preserve_trailing_dash_test() {
  let preserve_config =
    config.default()
    |> config.with_preserve_trailing_dash(True)

  glugify.slugify_with("draft-", preserve_config)
  |> should.equal(Ok("draft-"))
}

pub fn preserve_trailing_dash_uses_separator_test() {
  let preserve_config =
    config.default()
    |> config.with_separator("_")
    |> config.with_preserve_trailing_dash(True)

  glugify.slugify_with("draft-", preserve_config)
  |> should.equal(Ok("draft_"))
}

pub fn preserve_trailing_dash_off_by_default_test() {
  glugify.slugify("draft-")
  |> should.equal("draft")
}

// IDEMPOTENCY OF NEW MAPPINGS

pub fn expanded_coverage_is_idempotent_test() {
  let once = glugify.slugify("Łódź — Привет ‘don’t’ 🚀")
  glugify.slugify(once)
  |> should.equal(once)
}
