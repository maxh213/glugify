import gleam/int
import gleam/list
import gleam/string

/// Decodes HTML entities in text: named entities with slug-relevant
/// meanings (`&amp;`, `&nbsp;`, `&mdash;`, ...), decimal numeric
/// references (`&#38;`) and hexadecimal references (`&#x26;`).
/// Sequences that are not valid entities are left untouched.
pub fn decode(text: String) -> String {
  text
  |> string.to_graphemes
  |> decode_graphemes([])
  |> string.join("")
}

fn decode_graphemes(
  graphemes: List(String),
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    ["&", ..rest] ->
      case take_entity(rest, [], 0) {
        Ok(#(name, remaining)) ->
          case decode_entity(name) {
            Ok(replacement) -> decode_graphemes(remaining, [replacement, ..acc])
            Error(Nil) -> decode_graphemes(rest, ["&", ..acc])
          }
        Error(Nil) -> decode_graphemes(rest, ["&", ..acc])
      }
    [grapheme, ..rest] -> decode_graphemes(rest, [grapheme, ..acc])
  }
}

/// Collects the entity name between "&" and ";", up to a sane length.
fn take_entity(
  graphemes: List(String),
  acc: List(String),
  length: Int,
) -> Result(#(String, List(String)), Nil) {
  case graphemes {
    [";", ..rest] ->
      case acc {
        [] -> Error(Nil)
        _ -> Ok(#(string.join(list.reverse(acc), ""), rest))
      }
    [grapheme, ..rest] ->
      case length > 10 {
        True -> Error(Nil)
        False -> take_entity(rest, [grapheme, ..acc], length + 1)
      }
    [] -> Error(Nil)
  }
}

fn decode_entity(name: String) -> Result(String, Nil) {
  case name {
    "amp" -> Ok("&")
    "lt" -> Ok("<")
    "gt" -> Ok(">")
    "quot" -> Ok("\"")
    "apos" -> Ok("'")
    "nbsp" -> Ok("\u{00A0}")
    "ndash" -> Ok("–")
    "mdash" -> Ok("—")
    "hellip" -> Ok("…")
    "lsquo" -> Ok("‘")
    "rsquo" -> Ok("’")
    "ldquo" -> Ok("“")
    "rdquo" -> Ok("”")
    "copy" -> Ok("©")
    "reg" -> Ok("®")
    "trade" -> Ok("™")
    "deg" -> Ok("°")
    "euro" -> Ok("€")
    "pound" -> Ok("£")
    "yen" -> Ok("¥")
    "cent" -> Ok("¢")
    _ -> decode_numeric_entity(name)
  }
}

fn decode_numeric_entity(name: String) -> Result(String, Nil) {
  case name {
    "#x" <> hex | "#X" <> hex ->
      case int.base_parse(hex, 16) {
        Ok(code) -> codepoint_to_string(code)
        Error(Nil) -> Error(Nil)
      }
    "#" <> decimal ->
      case int.parse(decimal) {
        Ok(code) -> codepoint_to_string(code)
        Error(Nil) -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn codepoint_to_string(code: Int) -> Result(String, Nil) {
  case string.utf_codepoint(code) {
    Ok(codepoint) -> Ok(string.from_utf_codepoints([codepoint]))
    Error(Nil) -> Error(Nil)
  }
}
