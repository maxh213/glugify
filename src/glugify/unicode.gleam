import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import glugify/errors.{type SlugifyError}

/// Transliterates Unicode text to ASCII equivalents.
/// 
/// This function converts accented characters and common symbols to their
/// ASCII equivalents. Characters that cannot be transliterated will cause
/// an error to be returned.
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
/// transliterate_text("Résumé")
/// // -> Ok("Resume")
/// ```
/// 
/// ## Errors
/// 
/// Returns `TransliterationFailed(char)` when a character cannot be converted.
pub fn transliterate_text(text: String) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> transliterate_graphemes([])
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
  |> validate_ascii_graphemes
  |> result.map(fn(_) { text })
}

/// Validates text based on Unicode allowance settings.
/// 
/// If `allow_unicode` is `True`, all text is accepted.
/// If `allow_unicode` is `False`, only ASCII text is accepted.
/// 
/// ## Examples
/// 
/// ```gleam
/// validate_ascii_or_unicode("café", True)
/// // -> Ok("café")
/// 
/// validate_ascii_or_unicode("café", False)
/// // -> Error(TransliterationFailed("é"))
/// ```
pub fn validate_ascii_or_unicode(
  text: String,
  allow_unicode: Bool,
) -> Result(String, SlugifyError) {
  case allow_unicode {
    True -> Ok(text)
    False -> validate_ascii_only(text)
  }
}

fn validate_ascii_graphemes(
  graphemes: List(String),
) -> Result(Nil, SlugifyError) {
  case graphemes {
    [] -> Ok(Nil)
    [grapheme, ..rest] -> {
      case is_ascii_safe(grapheme) {
        True -> validate_ascii_graphemes(rest)
        False -> Error(errors.TransliterationFailed(grapheme))
      }
    }
  }
}

fn transliterate_graphemes(
  graphemes: List(String),
  acc: List(String),
) -> Result(List(String), SlugifyError) {
  case graphemes {
    [] -> Ok(list.reverse(acc))
    [grapheme, ..rest] -> {
      case dict.get(get_char_map(), grapheme) {
        Ok(replacement) -> transliterate_graphemes(rest, [replacement, ..acc])
        Error(_) -> {
          case is_ascii_safe(grapheme) {
            True -> transliterate_graphemes(rest, [grapheme, ..acc])
            False -> Error(errors.TransliterationFailed(grapheme))
          }
        }
      }
    }
  }
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

fn get_char_map() -> dict.Dict(String, String) {
  dict.from_list([
    #("à", "a"),
    #("á", "a"),
    #("ä", "a"),
    #("ã", "a"),
    #("â", "a"),
    #("å", "a"),
    #("è", "e"),
    #("é", "e"),
    #("ë", "e"),
    #("ê", "e"),
    #("ì", "i"),
    #("í", "i"),
    #("ï", "i"),
    #("î", "i"),
    #("ò", "o"),
    #("ó", "o"),
    #("ö", "o"),
    #("õ", "o"),
    #("ô", "o"),
    #("ù", "u"),
    #("ú", "u"),
    #("ü", "u"),
    #("û", "u"),
    #("ç", "c"),
    #("ñ", "n"),
    #("ß", "ss"),
    #("À", "A"),
    #("Á", "A"),
    #("Ä", "A"),
    #("Ã", "A"),
    #("Â", "A"),
    #("Å", "A"),
    #("È", "E"),
    #("É", "E"),
    #("Ë", "E"),
    #("Ê", "E"),
    #("Ì", "I"),
    #("Í", "I"),
    #("Ï", "I"),
    #("Î", "I"),
    #("Ò", "O"),
    #("Ó", "O"),
    #("Ö", "O"),
    #("Õ", "O"),
    #("Ô", "O"),
    #("Ù", "U"),
    #("Ú", "U"),
    #("Ü", "U"),
    #("Û", "U"),
    #("Ç", "C"),
    #("Ñ", "N"),
    #("&", " and "),
    #("@", " at "),
    #("%", " percent "),
    #("$", " dollar "),
    #("€", " euro "),
    #("£", " pound "),
  ])
}
