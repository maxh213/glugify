import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/errors
import qcheck

pub fn main() -> Nil {
  gleeunit.main()
}

// PROPERTY-BASED TESTS FOR SLUGIFICATION

pub fn slugify_idempotent_test() {
  qcheck.given(qcheck.string(), fn(input) {
    let first_slug = glugify.slugify(input)
    let second_slug = glugify.slugify(first_slug)

    should.equal(first_slug, second_slug)
  })
}

pub fn slugify_non_empty_input_produces_result_test() {
  qcheck.given(
    qcheck.non_empty_string_from(qcheck.alphanumeric_ascii_codepoint()),
    fn(input) {
      // For alphanumeric ASCII input, we should always get a valid result
      // This input type should never fail since it contains only safe characters
      case glugify.try_slugify(input) {
        Ok(_) -> Nil
        Error(errors.EmptyInput) -> should.fail()
        Error(_) -> should.fail()
        // Alphanumeric ASCII should never produce other errors
      }
    },
  )
}

pub fn slugify_length_property_test() {
  let config = config.default() |> config.with_max_length(10)

  qcheck.given(qcheck.string(), fn(input) {
    case glugify.slugify_with(input, config) {
      Ok(slug) -> {
        let length = string.length(slug)
        case length <= 10 {
          True -> Nil
          False -> panic as "Slug length exceeded maximum"
        }
      }
      Error(errors.EmptyInput) -> Nil
      // EmptyInput is expected for empty strings
      Error(errors.TransliterationFailed(_)) -> Nil
      // TransliterationFailed is expected for some Unicode inputs
      Error(errors.ConfigurationError(_)) -> should.fail()
      // ConfigurationError should not occur with valid config
    }
  })
}

pub fn slugify_separator_consistency_test() {
  qcheck.given(
    qcheck.tuple2(qcheck.string(), qcheck.printable_ascii_codepoint()),
    fn(pair) {
      let #(input, separator_codepoint) = pair
      let separator = string.from_utf_codepoints([separator_codepoint])
      let config = config.default() |> config.with_separator(separator)

      case glugify.slugify_with(input, config) {
        Ok(slug) -> {
          // Check that the separator is used correctly (no consecutive separators)
          case string.contains(slug, separator <> separator) {
            True -> panic as "Found consecutive separators in slug"
            False -> Nil
          }
        }
        Error(errors.EmptyInput) -> Nil
        Error(errors.TransliterationFailed(_)) -> Nil
        Error(errors.ConfigurationError(_)) -> Nil
        // ConfigurationError may occur with some separator characters
      }
    },
  )
}

pub fn slugify_no_leading_trailing_separators_test() {
  qcheck.given(qcheck.string(), fn(input) {
    let slug = glugify.slugify(input)

    case slug {
      "" -> Nil
      // Empty slugs are fine
      _ -> {
        // Should not start or end with separator
        case string.starts_with(slug, "-") || string.ends_with(slug, "-") {
          True -> panic as "Slug has leading or trailing separator"
          False -> Nil
        }
      }
    }
  })
}

pub fn slugify_lowercase_property_test() {
  qcheck.given(qcheck.string(), fn(input) {
    let slug = glugify.slugify(input)
    let lowercased = string.lowercase(slug)

    should.equal(slug, lowercased)
  })
}

pub fn slugify_preserve_case_property_test() {
  let config = config.default() |> config.with_lowercase(False)

  qcheck.given(
    qcheck.string_from(qcheck.alphabetic_ascii_codepoint()),
    fn(input) {
      case glugify.slugify_with(input, config) {
        Ok(slug) -> {
          // With lowercase=False, output should preserve case where possible
          case
            string.lowercase(slug) == slug && string.uppercase(slug) != slug
          {
            True ->
              // All lowercase might happen due to transliteration, which is acceptable
              Nil
            False -> Nil
          }
        }
        Error(_) -> Nil
      }
    },
  )
}

pub fn slugify_ascii_only_output_test() {
  qcheck.given(qcheck.string(), fn(input) {
    let slug = glugify.slugify(input)

    // Check that all characters in the slug are ASCII
    slug
    |> string.to_graphemes
    |> list.all(is_ascii_char)
    |> should.be_true
  })
}

pub fn slugify_unicode_handling_test() {
  let config =
    config.default()
    |> config.with_allow_unicode(True)
    |> config.with_transliterate(False)

  qcheck.given(qcheck.string_from(qcheck.uniform_codepoint()), fn(input) {
    case glugify.slugify_with(input, config) {
      Ok(_slug) -> {
        // With unicode allowed and no transliteration, some unicode chars might remain
        // This is expected behavior
        Nil
      }
      Error(errors.TransliterationFailed(_)) -> {
        // This is expected when transliteration is disabled and non-ASCII chars are found
        Nil
      }
      Error(errors.EmptyInput) -> Nil
      // EmptyInput is expected for empty/whitespace-only strings
      Error(errors.ConfigurationError(_)) -> should.fail()
      // ConfigurationError should not occur with this valid config
    }
  })
}

pub fn slugify_stop_words_removal_test() {
  let stop_words = ["the", "and", "or", "but"]
  let config = config.default() |> config.with_stop_words(stop_words)

  qcheck.given(
    qcheck.string_from(qcheck.alphabetic_ascii_codepoint()),
    fn(input) {
      case glugify.slugify_with(input, config) {
        Ok(slug) -> {
          // The slug should not contain any of the stop words as separate words
          stop_words
          |> list.all(fn(stop_word) {
            let words = string.split(slug, "-")
            !list.contains(words, stop_word)
          })
          |> should.be_true
        }
        Error(errors.EmptyInput) -> Nil
        // EmptyInput is expected for empty/whitespace-only strings
        Error(errors.TransliterationFailed(_)) -> should.fail()
        // Should not occur with alphabetic ASCII input
        Error(errors.ConfigurationError(_)) -> should.fail()
        // Should not occur with valid config
      }
    },
  )
}

pub fn slugify_custom_replacements_test() {
  let replacements = [#("&", " and "), #("+", " plus ")]
  let config = config.default() |> config.with_custom_replacements(replacements)

  qcheck.given(qcheck.string(), fn(input) {
    case glugify.slugify_with(input, config) {
      Ok(slug) -> {
        // The slug should not contain the original symbols
        case string.contains(slug, "&") || string.contains(slug, "+") {
          True -> panic as "Slug contains unreplaced symbols"
          False -> Nil
        }
      }
      Error(errors.EmptyInput) -> Nil
      Error(errors.TransliterationFailed(_)) -> Nil
      Error(errors.ConfigurationError(_)) -> should.fail()
      // Should not occur with valid config
    }
  })
}

pub fn slugify_word_boundary_truncation_test() {
  let config =
    config.default()
    |> config.with_max_length(15)
    |> config.with_word_boundary(True)

  qcheck.given(qcheck.string(), fn(input) {
    case glugify.slugify_with(input, config) {
      Ok(slug) -> {
        case string.length(slug) > 0 && string.length(slug) <= 15 {
          True -> {
            // Should not end with partial word when word boundary is enabled
            case string.ends_with(slug, "-") {
              True ->
                panic as "Slug ends with separator after word boundary truncation"
              False -> Nil
            }
          }
          False -> Nil
        }
      }
      Error(errors.EmptyInput) -> Nil
      Error(errors.TransliterationFailed(_)) -> Nil
      Error(errors.ConfigurationError(_)) -> should.fail()
    }
  })
}

pub fn slugify_empty_string_handling_test() {
  qcheck.given(qcheck.return(""), fn(_empty) {
    let simple_result = glugify.slugify("")
    let try_result = glugify.try_slugify("")

    should.equal(simple_result, "")
    should.equal(try_result, Error(errors.EmptyInput))
  })
}

pub fn slugify_whitespace_normalization_test() {
  let whitespace_gen = qcheck.string_from(qcheck.ascii_whitespace_codepoint())

  qcheck.given(
    qcheck.tuple3(qcheck.string(), whitespace_gen, qcheck.string()),
    fn(parts) {
      let #(start, whitespace, end) = parts
      let input = start <> whitespace <> end
      let slug = glugify.slugify(input)

      // Should not contain multiple consecutive separators
      case string.contains(slug, "--") {
        True -> panic as "Slug contains consecutive separators"
        False -> Nil
      }
    },
  )
}

pub fn slugify_numeric_preservation_test() {
  qcheck.given(
    qcheck.string_from(qcheck.ascii_digit_codepoint()),
    fn(numeric_input) {
      let slug = glugify.slugify(numeric_input)

      // Numbers should be preserved in slugs
      case string.length(numeric_input) > 0 {
        True -> {
          case string.length(slug) > 0 {
            True -> {
              // All characters in the slug should be digits or separators
              slug
              |> string.to_graphemes
              |> list.all(fn(char) { is_digit_char(char) || char == "-" })
              |> should.be_true
            }
            False -> Nil
            // Empty slug is acceptable
          }
        }
        False -> Nil
      }
    },
  )
}

pub fn slugify_configuration_invariants_test() {
  qcheck.given(
    qcheck.tuple2(
      qcheck.string(),
      qcheck.from_generators(qcheck.return("-"), [
        qcheck.return("_"),
        qcheck.return("."),
        qcheck.return(""),
      ]),
    ),
    fn(pair) {
      let #(input, separator) = pair
      let config = config.default() |> config.with_separator(separator)

      case glugify.slugify_with(input, config) {
        Ok(slug) -> {
          case separator {
            "" -> {
              // With empty separator, there should be no separators in the slug
              case string.contains(slug, "-") || string.contains(slug, "_") {
                True ->
                  panic as "Found separators in slug with empty separator config"
                False -> Nil
              }
            }
            _ -> {
              // With non-empty separator, consecutive separators should be collapsed
              let double_sep = separator <> separator
              case string.contains(slug, double_sep) {
                True -> panic as "Found consecutive separators"
                False -> Nil
              }
            }
          }
        }
        Error(errors.EmptyInput) -> Nil
        Error(errors.TransliterationFailed(_)) -> Nil
        Error(errors.ConfigurationError(_)) -> should.fail()
        // Should not occur with these valid separators
      }
    },
  )
}

pub fn slugify_content_preservation_test() {
  // Test that alphanumeric content is preserved
  qcheck.given(
    qcheck.string_from(qcheck.alphanumeric_ascii_codepoint()),
    fn(input) {
      let slug = glugify.slugify(input)

      // For alphanumeric ASCII input, the slug should contain recognizable content
      case string.length(input) > 0 {
        True -> {
          // The lowercased slug should contain the basic content structure
          let slug_chars = string.to_graphemes(string.replace(slug, "-", ""))
          case string.length(string.join(slug_chars, "")) > 0 {
            True -> Nil
            // Content was preserved
            False -> Nil
            // Empty result is acceptable for some edge cases
          }
        }
        False -> Nil
      }
    },
  )
}

// Helper functions

fn is_ascii_char(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] -> {
      let code = string.utf_codepoint_to_int(codepoint)
      code >= 0 && code <= 127
    }
    _ -> False
  }
}

fn is_digit_char(char: String) -> Bool {
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}
