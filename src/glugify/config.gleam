import gleam/option.{type Option}

pub type Config {
  Config(
    separator: String,
    lowercase: Bool,
    max_length: Option(Int),
    word_boundary: Bool,
    transliterate: Bool,
    allow_unicode: Bool,
    custom_replacements: List(#(String, String)),
    preserve_leading_underscore: Bool,
    preserve_trailing_dash: Bool,
    stop_words: List(String),
    trim: Bool,
  )
}

pub fn default() -> Config {
  Config(
    separator: "-",
    lowercase: True,
    max_length: option.None,
    word_boundary: False,
    transliterate: True,
    allow_unicode: False,
    custom_replacements: [],
    preserve_leading_underscore: False,
    preserve_trailing_dash: False,
    stop_words: [],
    trim: True,
  )
}

pub fn with_separator(config: Config, separator: String) -> Config {
  Config(..config, separator: separator)
}

pub fn with_lowercase(config: Config, lowercase: Bool) -> Config {
  Config(..config, lowercase: lowercase)
}

pub fn with_max_length(config: Config, max_length: Int) -> Config {
  Config(..config, max_length: option.Some(max_length))
}

pub fn with_word_boundary(config: Config, word_boundary: Bool) -> Config {
  Config(..config, word_boundary: word_boundary)
}

pub fn with_transliterate(config: Config, transliterate: Bool) -> Config {
  Config(..config, transliterate: transliterate)
}

pub fn with_allow_unicode(config: Config, allow_unicode: Bool) -> Config {
  Config(..config, allow_unicode: allow_unicode)
}

pub fn with_custom_replacements(
  config: Config,
  replacements: List(#(String, String)),
) -> Config {
  Config(..config, custom_replacements: replacements)
}

pub fn with_stop_words(config: Config, stop_words: List(String)) -> Config {
  Config(..config, stop_words: stop_words)
}

pub fn with_trim(config: Config, trim: Bool) -> Config {
  Config(..config, trim: trim)
}
