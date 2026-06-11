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
  case char {
    " " | "\t" | "\n" | "\r" -> True
    _ -> False
  }
}

pub fn apply_separators(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  case config.separator {
    "" -> {
      text
      |> string.to_graphemes
      |> list.filter(fn(char) { is_slug_char(char, config) })
      |> string.join("")
      |> Ok
    }
    _ -> {
      text
      |> string.to_graphemes
      |> apply_separators_simple(config, [], False)
      |> string.join("")
      |> Ok
    }
  }
}

fn apply_separators_simple(
  graphemes: List(String),
  config: Config,
  acc: List(String),
  last_was_separator: Bool,
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case is_slug_char(char, config) {
        True -> apply_separators_simple(rest, config, [char, ..acc], False)
        False -> {
          case last_was_separator || list.is_empty(acc) {
            True -> apply_separators_simple(rest, config, acc, True)
            False -> {
              let separator_chars =
                string.to_graphemes(config.separator) |> list.reverse
              apply_separators_simple(
                rest,
                config,
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

/// A grapheme that belongs in the slug body: alphanumeric, permitted
/// unicode, or explicitly ignored by configuration.
fn is_slug_char(char: String, config: Config) -> Bool {
  is_alphanumeric_or_unicode(char, config.allow_unicode)
  || is_ignored(char, config)
}

/// Ignored graphemes are matched by their lowercased form too when the
/// config lowercases the slug, since these checks run after the lowercase
/// stage: with `ignore: ["Ü"]` the text "Ü" has already become "ü".
fn is_ignored(char: String, config: Config) -> Bool {
  list.contains(config.ignore, char)
  || {
    config.lowercase
    && list.any(config.ignore, fn(entry) { string.lowercase(entry) == char })
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
  // A grapheme may span several codepoints (decomposed accents, emoji
  // with modifiers or joiners); treat it as unicode when any codepoint
  // is outside ASCII.
  case string.to_utf_codepoints(char) {
    [] -> False
    codepoints ->
      list.any(codepoints, fn(codepoint) {
        string.utf_codepoint_to_int(codepoint) > 127
      })
  }
}

fn is_char_in_separator(char: String, separator: String) -> Bool {
  case separator {
    "" -> False
    _ -> string.contains(separator, char)
  }
}

pub fn remove_invalid_chars(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> filter_valid_chars_with_unicode(config, [])
  |> string.join("")
  |> Ok
}

fn filter_valid_chars_with_unicode(
  graphemes: List(String),
  config: Config,
  acc: List(String),
) -> List(String) {
  case graphemes {
    [] -> list.reverse(acc)
    [char, ..rest] -> {
      case
        is_slug_char(char, config)
        || is_char_in_separator(char, config.separator)
      {
        True -> filter_valid_chars_with_unicode(rest, config, [char, ..acc])
        False -> filter_valid_chars_with_unicode(rest, config, acc)
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
  separator: String,
) -> Result(String, SlugifyError) {
  case string.length(text) <= max_length {
    True -> Ok(text)
    False -> {
      case word_boundary {
        True -> truncate_at_word_boundary(text, max_length, separator)
        False -> truncate_without_word_boundary(text, max_length, separator)
      }
    }
  }
}

fn truncate_without_word_boundary(
  text: String,
  max_length: Int,
  separator: String,
) -> Result(String, SlugifyError) {
  let truncated = string.slice(text, 0, max_length)
  case separator {
    "" -> Ok(truncated)
    _ -> {
      case string.ends_with(truncated, separator) {
        True -> Ok(string.drop_end(truncated, string.length(separator)))
        False -> Ok(truncated)
      }
    }
  }
}

fn truncate_at_word_boundary(
  text: String,
  max_length: Int,
  separator: String,
) -> Result(String, SlugifyError) {
  let truncated = string.slice(text, 0, max_length)
  case separator {
    "" -> Ok(truncated)
    _ -> {
      case string.ends_with(truncated, separator) {
        True -> Ok(string.drop_end(truncated, string.length(separator)))
        False -> {
          case find_last_separator(truncated, separator) {
            Ok(index) -> Ok(string.slice(truncated, 0, index))
            Error(_) -> Ok(truncated)
          }
        }
      }
    }
  }
}

fn find_last_separator(text: String, separator: String) -> Result(Int, Nil) {
  find_last_separator_by_string(
    text,
    separator,
    string.length(text) - string.length(separator),
  )
}

fn find_last_separator_by_string(
  text: String,
  separator: String,
  start_index: Int,
) -> Result(Int, Nil) {
  case start_index < 0 {
    True -> Error(Nil)
    False -> {
      let substr = string.slice(text, start_index, string.length(separator))
      case substr == separator {
        True -> Ok(start_index)
        False -> find_last_separator_by_string(text, separator, start_index - 1)
      }
    }
  }
}

/// Inserts spaces at camelCase word boundaries so each word slugifies
/// separately: "fooBar" -> "foo Bar", "HTMLParser" -> "HTML Parser".
/// Only ASCII letters and digits are considered for boundaries.
pub fn decamelize(text: String) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> decamelize_graphemes([])
  |> string.join("")
  |> Ok
}

fn decamelize_graphemes(
  graphemes: List(String),
  acc: List(String),
) -> List(String) {
  case graphemes {
    [a, b, ..rest] -> {
      case is_lower_or_digit(a) && is_upper(b) {
        True -> decamelize_graphemes([b, ..rest], [" ", a, ..acc])
        False ->
          case rest {
            [c, ..] ->
              case is_upper(a) && is_upper(b) && is_lower_or_digit(c) {
                True -> decamelize_graphemes([b, ..rest], [" ", a, ..acc])
                False -> decamelize_graphemes([b, ..rest], [a, ..acc])
              }
            [] -> decamelize_graphemes([b, ..rest], [a, ..acc])
          }
      }
    }
    [a] -> list.reverse([a, ..acc])
    [] -> list.reverse(acc)
  }
}

fn is_upper(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] -> {
      let code = string.utf_codepoint_to_int(codepoint)
      code >= 65 && code <= 90
    }
    _ -> False
  }
}

fn is_lower_or_digit(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [codepoint] -> {
      let code = string.utf_codepoint_to_int(codepoint)
      { code >= 97 && code <= 122 } || { code >= 48 && code <= 57 }
    }
    _ -> False
  }
}

pub fn apply_custom_replacements(
  text: String,
  replacements: List(#(String, String)),
) -> Result(String, SlugifyError) {
  apply_replacements_helper(text, replacements) |> Ok
}

fn apply_replacements_helper(
  text: String,
  replacements: List(#(String, String)),
) -> String {
  case replacements {
    [] -> text
    [#(find, replace), ..rest] -> {
      let updated = string.replace(text, find, replace)
      apply_replacements_helper(updated, rest)
    }
  }
}

pub fn filter_stop_words(
  text: String,
  stop_words: List(String),
  separator: String,
) -> Result(String, SlugifyError) {
  // Splitting on "" would split into graphemes and delete every letter
  // that happens to match a stop word, so an empty separator is a no-op.
  case list.is_empty(stop_words) || separator == "" {
    True -> Ok(text)
    False -> {
      let lowered_stop_words = list.map(stop_words, string.lowercase)
      let words = string.split(text, separator)
      let filtered_words =
        filter_stop_words_helper(words, lowered_stop_words, [])
      string.join(filtered_words, separator) |> Ok
    }
  }
}

fn filter_stop_words_helper(
  words: List(String),
  lowered_stop_words: List(String),
  acc: List(String),
) -> List(String) {
  case words {
    [] -> list.reverse(acc)
    [word, ..rest] -> {
      case list.contains(lowered_stop_words, string.lowercase(word)) {
        True -> filter_stop_words_helper(rest, lowered_stop_words, acc)
        False ->
          filter_stop_words_helper(rest, lowered_stop_words, [word, ..acc])
      }
    }
  }
}
