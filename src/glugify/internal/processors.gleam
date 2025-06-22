import gleam/list
import gleam/string
import glugify/config.{type Config}
import glugify/errors.{type SlugifyError}

pub fn normalize_whitespace(text: String) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> normalize_whitespace_graphemes([])
  |> string.join("")
  |> Ok
}

fn normalize_whitespace_graphemes(
  graphemes: List(String),
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case is_whitespace(char) {
        True -> {
          case acc {
            [" ", ..] -> normalize_whitespace_graphemes(rest, acc)
            _ -> normalize_whitespace_graphemes(rest, [" ", ..acc])
          }
        }
        False -> normalize_whitespace_graphemes(rest, [char, ..acc])
      }
    }
  }
}

fn is_whitespace(char: String) -> Bool {
  char == " " || char == "\t" || char == "\n" || char == "\r"
}

pub fn apply_separators(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> apply_separators_graphemes(config.separator, [])
  |> string.join("")
  |> Ok
}

fn apply_separators_graphemes(
  graphemes: List(String),
  separator: String,
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case is_alphanumeric(char) {
        True -> apply_separators_graphemes(rest, separator, [char, ..acc])
        False -> {
          case acc {
            [] -> apply_separators_graphemes(rest, separator, acc)
            [sep, ..] if sep == separator ->
              apply_separators_graphemes(rest, separator, acc)
            _ -> apply_separators_graphemes(rest, separator, [separator, ..acc])
          }
        }
      }
    }
  }
}

fn is_alphanumeric(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] -> {
      let code = string.utf_codepoint_to_int(codepoint)
      { code >= 48 && code <= 57 }
      // 0-9
      || { code >= 65 && code <= 90 }
      // A-Z
      || { code >= 97 && code <= 122 }
      // a-z
    }
    _ -> False
  }
}

pub fn remove_invalid_chars(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  case config.allow_unicode {
    True -> Ok(text)
    False -> {
      text
      |> string.to_graphemes
      |> filter_valid_chars(config.separator, [])
      |> string.join("")
      |> Ok
    }
  }
}

fn filter_valid_chars(
  graphemes: List(String),
  separator: String,
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case is_alphanumeric(char) || char == separator {
        True -> filter_valid_chars(rest, separator, [char, ..acc])
        False -> filter_valid_chars(rest, separator, acc)
      }
    }
  }
}

pub fn collapse_separators(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> collapse_separators_graphemes(config.separator, [])
  |> string.join("")
  |> Ok
}

fn collapse_separators_graphemes(
  graphemes: List(String),
  separator: String,
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case char == separator {
        True -> {
          case acc {
            [sep, ..] if sep == separator ->
              collapse_separators_graphemes(rest, separator, acc)
            _ -> collapse_separators_graphemes(rest, separator, [char, ..acc])
          }
        }
        False -> collapse_separators_graphemes(rest, separator, [char, ..acc])
      }
    }
  }
}

pub fn trim_separators(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  case config.trim {
    True -> {
      text
      |> string.trim_start
      |> string.trim_end
      |> trim_separator_ends(config.separator)
      |> Ok
    }
    False -> Ok(text)
  }
}

fn trim_separator_ends(text: String, separator: String) -> String {
  text
  |> trim_separator_start(separator)
  |> trim_separator_end(separator)
}

fn trim_separator_start(text: String, separator: String) -> String {
  case string.starts_with(text, separator) {
    True ->
      trim_separator_start(
        string.drop_start(text, string.length(separator)),
        separator,
      )
    False -> text
  }
}

fn trim_separator_end(text: String, separator: String) -> String {
  case string.ends_with(text, separator) {
    True ->
      trim_separator_end(
        string.drop_end(text, string.length(separator)),
        separator,
      )
    False -> text
  }
}

pub fn truncate_slug(
  text: String,
  max_length: Int,
  word_boundary: Bool,
) -> Result(String, SlugifyError) {
  case string.length(text) <= max_length {
    True -> Ok(text)
    False -> {
      case word_boundary {
        True -> truncate_at_word_boundary(text, max_length)
        False -> Ok(string.slice(text, 0, max_length))
      }
    }
  }
}

fn truncate_at_word_boundary(
  text: String,
  max_length: Int,
) -> Result(String, SlugifyError) {
  let truncated = string.slice(text, 0, max_length)
  case string.last(truncated) {
    Ok(last_char) -> {
      case last_char == "-" || last_char == "_" {
        True -> Ok(string.drop_end(truncated, 1))
        False -> {
          case string.split_once(truncated, "-") {
            Ok(#(before, _)) -> Ok(before)
            Error(_) -> Ok(truncated)
          }
        }
      }
    }
    Error(_) -> Ok(truncated)
  }
}
