import gleam/list
import gleam/result
import gleam/string
import glugify/errors.{type SlugifyError}
import glugify/internal/char_maps
import glugify/locale.{type Locale}

/// Transliterates Unicode text to ASCII equivalents.
///
/// This function converts accented characters, Cyrillic, Greek, typographic
/// punctuation and common symbols to their ASCII equivalents. Decomposed
/// (NFD) characters are handled by stripping combining marks and mapping the
/// base character. Characters with no known mapping (such as emoji) are
/// stripped from the output.
///
/// ## Examples
///
/// ```gleam
/// transliterate_text("café")
/// // -> Ok("cafe")
///
/// transliterate_text("naïve")
/// // -> Ok("naive")
///
/// transliterate_text("Résumé 🚀")
/// // -> Ok("Resume ")
/// ```
pub fn transliterate_text(text: String) -> Result(String, SlugifyError) {
  transliterate_text_with(text, locale.Default, [])
}

/// Transliterates Unicode text to ASCII using locale-specific rules,
/// keeping the graphemes in `ignore` verbatim.
///
/// Locale rules take precedence over the general tables, so with
/// `locale.German` the text "Über" becomes "Ueber" rather than "Uber".
///
/// ## Examples
///
/// ```gleam
/// import glugify/locale
///
/// transliterate_text_with("Über München", locale.German, [])
/// // -> Ok("Ueber Muenchen")
///
/// transliterate_text_with("嗨 hello", locale.Default, ["嗨"])
/// // -> Ok("嗨 hello")
/// ```
pub fn transliterate_text_with(
  text: String,
  locale: Locale,
  ignore: List(String),
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> transliterate_graphemes(locale, ignore, [])
  |> result.map(string.join(_, ""))
}

/// Validates that text contains only ASCII characters.
/// 
/// This function checks that all characters in the input are within
/// the printable ASCII range (32-126). Non-ASCII characters will cause
/// an error to be returned.
/// 
/// ## Examples
/// 
/// ```gleam
/// validate_ascii_only("hello world")
/// // -> Ok("hello world")
/// 
/// validate_ascii_only("café")
/// // -> Error(TransliterationFailed("é"))
/// ```
pub fn validate_ascii_only(text: String) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> validate_ascii_graphemes([])
  |> result.map(fn(_) { text })
}

/// Validates text based on Unicode allowance settings.
///
/// If `allow_unicode` is `True`, all text is accepted.
/// If `allow_unicode` is `False`, only ASCII text and graphemes listed
/// in `ignore` are accepted.
///
/// ## Examples
///
/// ```gleam
/// validate_ascii_or_unicode("café", True, [])
/// // -> Ok("café")
///
/// validate_ascii_or_unicode("café", False, [])
/// // -> Error(TransliterationFailed("é"))
///
/// validate_ascii_or_unicode("café", False, ["é"])
/// // -> Ok("café")
/// ```
pub fn validate_ascii_or_unicode(
  text: String,
  allow_unicode: Bool,
  ignore: List(String),
) -> Result(String, SlugifyError) {
  case allow_unicode {
    True -> Ok(text)
    False ->
      text
      |> string.to_graphemes
      |> validate_ascii_graphemes(ignore)
      |> result.map(fn(_) { text })
  }
}

fn validate_ascii_graphemes(
  graphemes: List(String),
  ignore: List(String),
) -> Result(Nil, SlugifyError) {
  case graphemes {
    [] -> Ok(Nil)
    [grapheme, ..rest] -> {
      case is_ascii_safe(grapheme) || list.contains(ignore, grapheme) {
        True -> validate_ascii_graphemes(rest, ignore)
        False -> Error(errors.TransliterationFailed(grapheme))
      }
    }
  }
}

fn transliterate_graphemes(
  graphemes: List(String),
  locale: Locale,
  ignore: List(String),
  acc: List(String),
) -> Result(List(String), SlugifyError) {
  case graphemes {
    [] -> Ok(list.reverse(acc))
    [grapheme, ..rest] -> {
      case list.contains(ignore, grapheme) {
        True -> transliterate_graphemes(rest, locale, ignore, [grapheme, ..acc])
        False ->
          case lookup_with_locale(grapheme, locale) {
            Ok(replacement) ->
              transliterate_graphemes(rest, locale, ignore, [replacement, ..acc])
            Error(_) -> {
              case is_ascii_safe(grapheme) {
                True ->
                  transliterate_graphemes(rest, locale, ignore, [
                    grapheme,
                    ..acc
                  ])
                False ->
                  transliterate_graphemes(rest, locale, ignore, [
                    transliterate_codepoints(grapheme, locale),
                    ..acc
                  ])
              }
            }
          }
      }
    }
  }
}

fn lookup_with_locale(grapheme: String, locale: Locale) -> Result(String, Nil) {
  case char_maps.lookup_locale(grapheme, locale) {
    Ok(replacement) -> Ok(replacement)
    Error(Nil) -> char_maps.lookup(grapheme)
  }
}

/// Fallback for graphemes that have no direct mapping: decompose into
/// codepoints, drop combining marks and invisible joiners, and map each
/// remaining codepoint individually. Handles NFD (decomposed) input such
/// as "e" followed by U+0301. Codepoints with no mapping are stripped.
fn transliterate_codepoints(grapheme: String, locale: Locale) -> String {
  grapheme
  |> string.to_utf_codepoints
  |> list.filter_map(fn(codepoint) {
    let code = string.utf_codepoint_to_int(codepoint)
    case is_ignorable_codepoint(code) {
      True -> Error(Nil)
      False -> {
        let char = string.from_utf_codepoints([codepoint])
        case lookup_with_locale(char, locale) {
          Ok(replacement) -> Ok(replacement)
          Error(_) ->
            case code >= 32 && code <= 126 {
              True -> Ok(char)
              False -> Error(Nil)
            }
        }
      }
    }
  })
  |> string.join("")
}

/// Combining marks (U+0300-U+036F), Hebrew cantillation and niqqud
/// (U+0591-U+05C7), Arabic tashkeel (U+064B-U+0652), zero-width
/// joiners/non-joiners and bidirectional marks (U+200C-U+200F), and
/// variation selectors (U+FE00-U+FE0F) carry no slug content of their own.
fn is_ignorable_codepoint(code: Int) -> Bool {
  { code >= 0x0300 && code <= 0x036F }
  || { code >= 0x0591 && code <= 0x05C7 }
  || { code >= 0x064B && code <= 0x0652 }
  || { code >= 0x200C && code <= 0x200F }
  || { code >= 0xFE00 && code <= 0xFE0F }
}

fn is_ascii_safe(char: String) -> Bool {
  case string.length(char) {
    1 -> {
      case string.pop_grapheme(char) {
        Ok(#(grapheme, "")) -> {
          case string.to_utf_codepoints(grapheme) {
            [codepoint] -> {
              let code = string.utf_codepoint_to_int(codepoint)
              code >= 32 && code <= 126
            }
            _ -> False
          }
        }
        _ -> False
      }
    }
    _ -> False
  }
}
