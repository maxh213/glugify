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
  case config.separator {
    "" -> {
      text
      |> string.to_graphemes
      |> list.filter(is_alphanumeric)
      |> string.join("")
      |> Ok
    }
    _ -> {
      text
      |> string.to_graphemes
      |> apply_separators_simple(config.separator, [], False)
      |> string.join("")
      |> Ok
    }
  }
}

fn apply_separators_simple(
  graphemes: List(String),
  separator: String,
  acc: List(String),
  last_was_separator: Bool,
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case is_alphanumeric(char) {
        True -> apply_separators_simple(rest, separator, [char, ..acc], False)
        False -> {
          case last_was_separator || list.is_empty(acc) {
            True -> apply_separators_simple(rest, separator, acc, True)
            False -> {
              let separator_chars =
                string.to_graphemes(separator) |> list.reverse
              apply_separators_simple(
                rest,
                separator,
                list.append(separator_chars, acc),
                True,
              )
            }
          }
        }
      }
    }
  }
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
            _ -> {
              case separator {
                "" -> apply_separators_graphemes(rest, separator, acc)
                _ -> {
                  case ends_with_separator(acc, separator) {
                    True -> apply_separators_graphemes(rest, separator, acc)
                    False -> {
                      let separator_chars =
                        string.to_graphemes(separator) |> list.reverse
                      apply_separators_graphemes(
                        rest,
                        separator,
                        list.append(separator_chars, acc),
                      )
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn ends_with_separator(acc: List(String), separator: String) -> Bool {
  case separator {
    "" -> False
    _ -> {
      let separator_chars = string.to_graphemes(separator) |> list.reverse
      ends_with_separator_helper(acc, separator_chars)
    }
  }
}

fn ends_with_separator_helper(
  acc: List(String),
  separator_chars: List(String),
) -> Bool {
  case separator_chars {
    [] -> True
    [sep_char, ..rest_sep] -> {
      case acc {
        [acc_char, ..rest_acc] if acc_char == sep_char ->
          ends_with_separator_helper(rest_acc, rest_sep)
        _ -> False
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

fn is_alphanumeric_or_unicode(char: String, allow_unicode: Bool) -> Bool {
  case allow_unicode {
    True -> is_alphanumeric(char) || is_unicode_char(char)
    False -> is_alphanumeric(char)
  }
}

fn is_unicode_char(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] -> {
      let code = string.utf_codepoint_to_int(codepoint)
      code > 127
    }
    _ -> False
  }
}

fn is_ascii_printable(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] -> {
      let code = string.utf_codepoint_to_int(codepoint)
      code >= 32 && code <= 126
    }
    _ -> False
  }
}

pub fn remove_invalid_chars(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> filter_valid_chars_with_unicode(config.separator, config.allow_unicode, [])
  |> string.join("")
  |> Ok
}

fn filter_valid_chars_with_unicode(
  graphemes: List(String),
  separator: String,
  allow_unicode: Bool,
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case
        is_alphanumeric_or_unicode(char, allow_unicode) || char == separator
      {
        True ->
          filter_valid_chars_with_unicode(rest, separator, allow_unicode, [
            char,
            ..acc
          ])
        False ->
          filter_valid_chars_with_unicode(rest, separator, allow_unicode, acc)
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
  case separator {
    "" -> list.reverse(list.append(list.reverse(graphemes), acc))
    _ -> collapse_separators_helper(graphemes, separator, acc)
  }
}

fn collapse_separators_helper(
  graphemes: List(String),
  separator: String,
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    _ -> {
      case starts_with_separator(graphemes, separator) {
        True -> {
          case ends_with_separator(acc, separator) {
            True -> {
              let remaining = drop_separator_prefix(graphemes, separator)
              collapse_separators_helper(remaining, separator, acc)
            }
            False -> {
              let separator_chars = string.to_graphemes(separator)
              let remaining = drop_separator_prefix(graphemes, separator)
              collapse_separators_helper(
                remaining,
                separator,
                list.append(list.reverse(separator_chars), acc),
              )
            }
          }
        }
        False -> {
          case graphemes {
            [char, ..rest] ->
              collapse_separators_helper(rest, separator, [char, ..acc])
            [] -> list.reverse(acc)
          }
        }
      }
    }
  }
}

fn starts_with_separator(graphemes: List(String), separator: String) -> Bool {
  let separator_chars = string.to_graphemes(separator)
  starts_with_separator_helper(graphemes, separator_chars)
}

fn starts_with_separator_helper(
  graphemes: List(String),
  separator_chars: List(String),
) -> Bool {
  case separator_chars {
    [] -> True
    [sep_char, ..rest_sep] -> {
      case graphemes {
        [grapheme, ..rest_graphemes] if grapheme == sep_char ->
          starts_with_separator_helper(rest_graphemes, rest_sep)
        _ -> False
      }
    }
  }
}

fn drop_separator_prefix(
  graphemes: List(String),
  separator: String,
) -> List(String) {
  let separator_chars = string.to_graphemes(separator)
  drop_separator_prefix_helper(graphemes, separator_chars)
}

fn drop_separator_prefix_helper(
  graphemes: List(String),
  separator_chars: List(String),
) -> List(String) {
  case separator_chars {
    [] -> graphemes
    [_, ..rest_sep] -> {
      case graphemes {
        [_, ..rest_graphemes] ->
          drop_separator_prefix_helper(rest_graphemes, rest_sep)
        [] -> []
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
  case separator {
    "" -> text
    _ ->
      case string.starts_with(text, separator) {
        True ->
          trim_separator_start(
            string.drop_start(text, string.length(separator)),
            separator,
          )
        False -> text
      }
  }
}

fn trim_separator_end(text: String, separator: String) -> String {
  case separator {
    "" -> text
    _ ->
      case string.ends_with(text, separator) {
        True ->
          trim_separator_end(
            string.drop_end(text, string.length(separator)),
            separator,
          )
        False -> text
      }
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
