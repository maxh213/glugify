import gleam/string
import glugify/errors.{type SlugifyError}

pub fn validate_input(text: String) -> Result(String, SlugifyError) {
  case string.trim(text) {
    "" -> Error(errors.EmptyInput)
    trimmed -> Ok(trimmed)
  }
}
