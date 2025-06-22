import gleam/result
import glugify/errors.{type SlugifyError}
import glugify/unicode

pub type Transformation =
  fn(String) -> Result(String, SlugifyError)

pub fn compose(transformations: List(Transformation)) -> Transformation {
  fn(input: String) -> Result(String, SlugifyError) {
    case transformations {
      [] -> Ok(input)
      [first, ..rest] -> {
        use result <- result.try(first(input))
        compose(rest)(result)
      }
    }
  }
}

pub fn normalize_unicode() -> Transformation {
  fn(text: String) -> Result(String, SlugifyError) { Ok(text) }
}

pub fn transliterate_to_ascii() -> Transformation {
  unicode.transliterate_text
}
