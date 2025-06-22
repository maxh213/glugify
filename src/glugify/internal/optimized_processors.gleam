import gleam/string
import gleam/string_tree
import glugify/config.{type Config}
import glugify/errors.{type SlugifyError}

pub fn optimized_normalize_whitespace(
  text: String,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> normalize_whitespace_with_tree(string_tree.new(), False)
  |> string_tree.to_string
  |> Ok
}

fn normalize_whitespace_with_tree(
  graphemes: List(String),
  builder: string_tree.StringTree,
  last_was_space: Bool,
) -> string_tree.StringTree {
  case graphemes {
    [] -> builder
    [char, ..rest] -> {
      case is_whitespace(char) {
        True -> {
          case last_was_space {
            True -> normalize_whitespace_with_tree(rest, builder, True)
            False ->
              normalize_whitespace_with_tree(
                rest,
                string_tree.append(builder, " "),
                True,
              )
          }
        }
        False ->
          normalize_whitespace_with_tree(
            rest,
            string_tree.append(builder, char),
            False,
          )
      }
    }
  }
}

fn is_whitespace(char: String) -> Bool {
  char == " " || char == "\t" || char == "\n" || char == "\r"
}

pub fn optimized_apply_separators(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  case config.separator {
    "" -> {
      text
      |> string.to_graphemes
      |> filter_alphanumeric_with_tree(string_tree.new())
      |> string_tree.to_string
      |> Ok
    }
    _ -> {
      text
      |> string.to_graphemes
      |> apply_separators_with_tree(config.separator, string_tree.new(), False)
      |> string_tree.to_string
      |> Ok
    }
  }
}

fn filter_alphanumeric_with_tree(
  graphemes: List(String),
  builder: string_tree.StringTree,
) -> string_tree.StringTree {
  case graphemes {
    [] -> builder
    [char, ..rest] -> {
      case is_alphanumeric(char) {
        True ->
          filter_alphanumeric_with_tree(rest, string_tree.append(builder, char))
        False -> filter_alphanumeric_with_tree(rest, builder)
      }
    }
  }
}

fn apply_separators_with_tree(
  graphemes: List(String),
  separator: String,
  builder: string_tree.StringTree,
  last_was_separator: Bool,
) -> string_tree.StringTree {
  case graphemes {
    [] -> builder
    [char, ..rest] -> {
      case is_alphanumeric(char) {
        True ->
          apply_separators_with_tree(
            rest,
            separator,
            string_tree.append(builder, char),
            False,
          )
        False -> {
          case last_was_separator || string_tree.is_empty(builder) {
            True -> apply_separators_with_tree(rest, separator, builder, True)
            False -> {
              case rest {
                [] -> builder  // Don't add separator at the end
                _ -> apply_separators_with_tree(
                  rest,
                  separator,
                  string_tree.append(builder, separator),
                  True,
                )
              }
            }
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
      || { code >= 65 && code <= 90 }
      || { code >= 97 && code <= 122 }
    }
    _ -> False
  }
}

pub fn optimized_remove_invalid_chars(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> filter_valid_chars_with_tree(
    config.separator,
    config.allow_unicode,
    string_tree.new(),
  )
  |> string_tree.to_string
  |> Ok
}

fn filter_valid_chars_with_tree(
  graphemes: List(String),
  separator: String,
  allow_unicode: Bool,
  builder: string_tree.StringTree,
) -> string_tree.StringTree {
  case graphemes {
    [] -> builder
    [char, ..rest] -> {
      case
        is_alphanumeric_or_unicode(char, allow_unicode) || char == separator
      {
        True ->
          filter_valid_chars_with_tree(
            rest,
            separator,
            allow_unicode,
            string_tree.append(builder, char),
          )
        False ->
          filter_valid_chars_with_tree(rest, separator, allow_unicode, builder)
      }
    }
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

pub fn optimized_apply_custom_replacements(
  text: String,
  replacements: List(#(String, String)),
) -> Result(String, SlugifyError) {
  apply_replacements_with_tree(text, replacements) |> Ok
}

fn apply_replacements_with_tree(
  text: String,
  replacements: List(#(String, String)),
) -> String {
  case replacements {
    [] -> text
    [#(find, replace), ..rest] -> {
      let updated = string.replace(text, find, replace)
      apply_replacements_with_tree(updated, rest)
    }
  }
}

pub fn batch_process_with_tree(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  text
  |> string.to_graphemes
  |> batch_process_graphemes(config, string_tree.new(), False)
  |> string_tree.to_string
  |> Ok
}

fn batch_process_graphemes(
  graphemes: List(String),
  config: Config,
  builder: string_tree.StringTree,
  last_was_separator: Bool,
) -> string_tree.StringTree {
  case graphemes {
    [] -> builder
    [char, ..rest] -> {
      let processed_char = case is_whitespace(char) {
        True -> config.separator
        False -> char
      }

      case is_valid_char(processed_char, config) {
        True -> {
          case processed_char == config.separator && last_was_separator {
            True -> batch_process_graphemes(rest, config, builder, True)
            False -> {
              let final_char = case config.lowercase {
                True -> string.lowercase(processed_char)
                False -> processed_char
              }
              batch_process_graphemes(
                rest,
                config,
                string_tree.append(builder, final_char),
                processed_char == config.separator,
              )
            }
          }
        }
        False ->
          batch_process_graphemes(rest, config, builder, last_was_separator)
      }
    }
  }
}

fn is_valid_char(char: String, config: Config) -> Bool {
  is_alphanumeric_or_unicode(char, config.allow_unicode)
  || char == config.separator
}
