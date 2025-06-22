import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import glugify/errors.{type SlugifyError}

pub fn transliterate_text(text: String) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> transliterate_graphemes([])
  |> result.map(string.join(_, ""))
}

pub fn validate_ascii_only(text: String) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> validate_ascii_graphemes
  |> result.map(fn(_) { text })
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
    [] -> Ok(acc |> list.reverse)
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
    #("ä", "ae"),
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
    #("ö", "oe"),
    #("õ", "o"),
    #("ô", "o"),
    #("ù", "u"),
    #("ú", "u"),
    #("ü", "ue"),
    #("û", "u"),
    #("ç", "c"),
    #("ñ", "n"),
    #("À", "A"),
    #("Á", "A"),
    #("Ä", "AE"),
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
    #("Ö", "OE"),
    #("Õ", "O"),
    #("Ô", "O"),
    #("Ù", "U"),
    #("Ú", "U"),
    #("Ü", "UE"),
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
