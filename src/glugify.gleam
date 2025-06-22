import gleam/option
import gleam/result
import gleam/string
import glugify/config.{type Config}
import glugify/errors.{type SlugifyError}
import glugify/internal/processors
import glugify/internal/validators
import glugify/unicode

/// Converts text to a URL-friendly slug using default configuration.
/// This is the simplest API that always returns a string.
/// 
/// ## Examples
/// 
/// ```gleam
/// slugify("Hello, World!")
/// // -> "hello-world"
/// 
/// slugify("Café & Restaurant")
/// // -> "cafe-and-restaurant"
/// ```
/// 
/// If the input cannot be processed, returns an empty string.
/// For error handling, use `try_slugify` instead.
pub fn slugify(text: String) -> String {
  case try_slugify(text) {
    Ok(slug) -> slug
    Error(_) -> ""
  }
}

/// Converts text to a URL-friendly slug with explicit error handling.
/// Returns `Result(String, SlugifyError)` for cases where you need to handle errors.
/// 
/// ## Examples
/// 
/// ```gleam
/// try_slugify("My Blog Post")
/// // -> Ok("my-blog-post")
/// 
/// try_slugify("")
/// // -> Error(EmptyInput)
/// ```
pub fn try_slugify(text: String) -> Result(String, SlugifyError) {
  slugify_with(text, config.default())
}

/// Converts text to a URL-friendly slug using custom configuration.
/// This is the most flexible API that allows full control over the slugification process.
/// 
/// ## Examples
/// 
/// ```gleam
/// import glugify/config
/// 
/// let custom_config = config.default()
///   |> config.with_separator("_")
///   |> config.with_max_length(20)
/// 
/// slugify_with("A Very Long Title", custom_config)
/// // -> Ok("a_very_long_title")
/// ```
/// 
/// ## Errors
/// 
/// - `EmptyInput`: When the input text is empty
/// - `InvalidInput`: When the input contains invalid characters
/// - `ConfigurationError`: When the configuration is invalid
/// - `TransliterationFailed`: When a character cannot be transliterated
pub fn slugify_with(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  use _ <- result.try(case config.validate_config(config) {
    Ok(_) -> Ok(Nil)
    Error(msg) -> Error(errors.ConfigurationError(msg))
  })
  use validated <- result.try(validators.validate_input(text))
  use normalized <- result.try(processors.normalize_whitespace(validated))
  use with_custom_replacements <- result.try(
    processors.apply_custom_replacements(normalized, config.custom_replacements),
  )
  use transliterated <- result.try(case config.transliterate {
    True -> unicode.transliterate_text(with_custom_replacements)
    False ->
      unicode.validate_ascii_or_unicode(
        with_custom_replacements,
        config.allow_unicode,
      )
  })
  use normalized_after_transliteration <- result.try(
    processors.normalize_whitespace(transliterated),
  )
  use lowercased <- result.try({
    let result = case config.lowercase {
      True -> string.lowercase(normalized_after_transliteration)
      False -> normalized_after_transliteration
    }
    Ok(result)
  })
  use separated <- result.try(processors.apply_separators(lowercased, config))
  use cleaned <- result.try(processors.remove_invalid_chars(separated, config))
  use collapsed <- result.try(processors.collapse_separators(cleaned, config))
  use without_stop_words <- result.try(processors.filter_stop_words(
    collapsed,
    config.stop_words,
    config.separator,
  ))
  use trimmed <- result.try(processors.trim_separators(
    without_stop_words,
    config,
  ))
  use truncated <- result.try(case config.max_length {
    option.Some(len) ->
      processors.truncate_slug(trimmed, len, config.word_boundary)
    option.None -> Ok(trimmed)
  })

  Ok(truncated)
}
