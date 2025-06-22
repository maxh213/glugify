import gleam/string
import glugify/errors.{type SlugifyError}

pub fn validate_input(text: String) -> Result(String, SlugifyError) {
  case string.trim(text) {
    "" -> Error(errors.EmptyInput)
    trimmed -> Ok(trimmed)
  }
}

pub fn validate_max_length(
  text: String,
  max_length: Int,
) -> Result(String, SlugifyError) {
  let current_length = string.length(text)
  case current_length > max_length {
    True -> Error(errors.TooLong(current_length, max_length))
    False -> Ok(text)
  }
}
