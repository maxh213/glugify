import gleam/list
import gleam/result
import glugify/errors.{type SlugifyError}
import glugify/unicode

/// A transformation function that processes text and may fail with an error.
/// 
/// Transformations can be composed together to create complex processing pipelines
/// while preserving type safety and error handling.
/// 
/// ## Examples
/// 
/// ```gleam
/// let my_transform: Transformation = fn(text) {
///   text |> string.uppercase |> Ok
/// }
/// ```
pub type Transformation =
  fn(String) -> Result(String, SlugifyError)

/// Composes multiple transformations into a single transformation.
/// 
/// Transformations are applied in order from left to right.
/// If any transformation fails, the entire composition fails.
/// 
/// ## Examples
/// 
/// ```gleam
/// let pipeline = compose([
///   normalize_unicode(),
///   transliterate_to_ascii()
/// ])
/// 
/// pipeline("café")
/// // -> Ok("cafe")
/// ```
pub fn compose(transformations: List(Transformation)) -> Transformation {
  fn(input: String) -> Result(String, SlugifyError) {
    list.fold(transformations, Ok(input), fn(acc, transform) {
      result.try(acc, transform)
    })
  }
}

/// Creates a transformation that normalizes Unicode text.
/// 
/// Currently this is a no-op transformation that passes text through unchanged.
/// In the future, this could implement Unicode normalization forms (NFC, NFD, etc.).
/// 
/// ## Examples
/// 
/// ```gleam
/// let normalizer = normalize_unicode()
/// normalizer("text")
/// // -> Ok("text")
/// ```
pub fn normalize_unicode() -> Transformation {
  fn(text: String) -> Result(String, SlugifyError) { Ok(text) }
}

/// Creates a transformation that transliterates Unicode to ASCII.
/// 
/// This transformation converts accented characters and symbols to their
/// ASCII equivalents. Characters that cannot be transliterated will cause an error.
/// 
/// ## Examples
/// 
/// ```gleam
/// let transliterator = transliterate_to_ascii()
/// transliterator("café")
/// // -> Ok("cafe")
/// ```
pub fn transliterate_to_ascii() -> Transformation {
  unicode.transliterate_text
}
