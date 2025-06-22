import gleam/option
import gleam/result
import gleam/string
import glugify/config.{type Config}
import glugify/errors.{type SlugifyError}
import glugify/internal/processors
import glugify/internal/validators
import glugify/unicode

pub fn slugify(text: String) -> String {
  case try_slugify(text) {
    Ok(slug) -> slug
    Error(_) -> ""
  }
}

pub fn try_slugify(text: String) -> Result(String, SlugifyError) {
  slugify_with(text, config.default())
}

pub fn slugify_with(
  text: String,
  config: Config,
) -> Result(String, SlugifyError) {
  use validated <- result.try(validators.validate_input(text))
  use normalized <- result.try(processors.normalize_whitespace(validated))
  use transliterated <- result.try(case config.transliterate {
    True -> unicode.transliterate_text(normalized)
    False -> unicode.validate_ascii_only(normalized)
  })
  use lowercased <- result.try(
    Ok(case config.lowercase {
      True -> string.lowercase(transliterated)
      False -> transliterated
    }),
  )
  use separated <- result.try(processors.apply_separators(lowercased, config))
  use cleaned <- result.try(processors.remove_invalid_chars(separated, config))
  use collapsed <- result.try(processors.collapse_separators(cleaned, config))
  use trimmed <- result.try(processors.trim_separators(collapsed, config))
  use truncated <- result.try(case config.max_length {
    option.Some(len) ->
      processors.truncate_slug(trimmed, len, config.word_boundary)
    option.None -> Ok(trimmed)
  })

  Ok(truncated)
}
