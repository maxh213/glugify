import gleam/option.{type Option}
import gleam/string

/// Configuration options for customizing slugification behavior.
/// 
/// Each field controls a specific aspect of the slugification process:
/// 
/// - `separator`: Character(s) used to separate words (default: "-")
/// - `lowercase`: Whether to convert to lowercase (default: `True`)
/// - `max_length`: Optional maximum length limit (default: `None`)
/// - `word_boundary`: Whether to truncate at word boundaries (default: `False`)
/// - `transliterate`: Whether to convert Unicode to ASCII (default: `True`)
/// - `allow_unicode`: Whether to allow Unicode characters in output (default: `False`)
/// - `custom_replacements`: List of custom string replacements (default: `[]`)
/// - `preserve_leading_underscore`: Whether to keep leading underscores (default: `False`)
/// - `preserve_trailing_dash`: Whether to keep trailing dashes (default: `False`)
/// - `stop_words`: List of words to remove (default: `[]`)
/// - `trim`: Whether to trim whitespace (default: `True`)
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

/// Creates a default configuration with sensible defaults for most use cases.
/// 
/// ## Default values:
/// 
/// - Separator: `-`
/// - Lowercase: `True`
/// - Max length: `None` (unlimited)
/// - Word boundary: `False`
/// - Transliterate: `True`
/// - Allow unicode: `False`
/// - Custom replacements: `[]`
/// - Preserve leading underscore: `False`
/// - Preserve trailing dash: `False`
/// - Stop words: `[]`
/// - Trim: `True`
/// 
/// ## Examples
/// 
/// ```gleam
/// let config = default()
/// ```
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

/// Sets the separator character(s) used between words.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_separator("_")
/// // Results in: "hello_world" instead of "hello-world"
/// ```
pub fn with_separator(config: Config, separator: String) -> Config {
  Config(..config, separator: separator)
}

/// Validates configuration parameters and returns an error if invalid.
/// 
/// Currently validates:
/// - Separator length must be <= 10 characters
/// 
/// Returns the same config if valid, or an error message if invalid.
pub fn validate_config(config: Config) -> Result(Config, String) {
  case string.length(config.separator) > 10 {
    True -> Error("Separator too long (max 10 characters)")
    False -> Ok(config)
  }
}

/// Sets whether the output should be converted to lowercase.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_lowercase(False)
/// // Results in: "Hello-World" instead of "hello-world"
/// ```
pub fn with_lowercase(config: Config, lowercase: Bool) -> Config {
  Config(..config, lowercase: lowercase)
}

/// Sets the maximum length for the generated slug.
/// 
/// If the value is negative, the config remains unchanged.
/// Use with `with_word_boundary(True)` to truncate at word boundaries.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_max_length(10)
/// // Will truncate slugs to 10 characters maximum
/// ```
pub fn with_max_length(config: Config, max_length: Int) -> Config {
  case max_length < 0 {
    True -> config
    False -> Config(..config, max_length: option.Some(max_length))
  }
}

/// Sets whether truncation should respect word boundaries.
/// 
/// When `True`, truncation will not cut words in half.
/// Only applies when `max_length` is set.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_max_length(10)
/// |> with_word_boundary(True)
/// // "hello world test" -> "hello" (not "hello worl")
/// ```
pub fn with_word_boundary(config: Config, word_boundary: Bool) -> Config {
  Config(..config, word_boundary: word_boundary)
}

/// Sets whether Unicode characters should be transliterated to ASCII.
/// 
/// When `True`, characters like "café" become "cafe".
/// When `False`, Unicode characters are preserved or cause an error.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_transliterate(False)
/// |> with_allow_unicode(True)
/// // Preserves Unicode: "café" -> "café"
/// ```
pub fn with_transliterate(config: Config, transliterate: Bool) -> Config {
  Config(..config, transliterate: transliterate)
}

/// Sets whether Unicode characters are allowed in the output.
/// 
/// When `True`, Unicode characters are preserved in the output.
/// When `False`, only ASCII characters are allowed.
/// Usually used with `transliterate: False`.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_transliterate(False)
/// |> with_allow_unicode(True)
/// ```
pub fn with_allow_unicode(config: Config, allow_unicode: Bool) -> Config {
  Config(..config, allow_unicode: allow_unicode)
}

/// Sets custom string replacements to apply before other processing.
/// 
/// Each tuple contains `#(from, to)` where `from` is replaced with `to`.
/// Replacements are applied in the order provided.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_custom_replacements([
///   #("&", " and "),
///   #("@", " at "),
///   #("%", " percent ")
/// ])
/// // "Cats & Dogs @ 100%" -> "cats-and-dogs-at-100-percent"
/// ```
pub fn with_custom_replacements(
  config: Config,
  replacements: List(#(String, String)),
) -> Config {
  Config(..config, custom_replacements: replacements)
}

/// Sets a list of stop words to remove from the slug.
/// 
/// Stop words are removed after other processing but before final cleanup.
/// Matching is case-insensitive.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_stop_words(["the", "a", "an", "and", "or"])
/// // "The Quick Brown Fox and the Lazy Dog" -> "quick-brown-fox-lazy-dog"
/// ```
pub fn with_stop_words(config: Config, stop_words: List(String)) -> Config {
  Config(..config, stop_words: stop_words)
}

/// Sets whether to trim leading and trailing whitespace from the input.
/// 
/// This is applied early in the processing pipeline.
/// 
/// ## Examples
/// 
/// ```gleam
/// default()
/// |> with_trim(False)
/// // Preserves leading/trailing spaces in processing
/// ```
pub fn with_trim(config: Config, trim: Bool) -> Config {
  Config(..config, trim: trim)
}
