/// Represents errors that can occur during slugification.
/// 
/// ## Variants
/// 
/// - `EmptyInput`: The input string is empty
/// - `TransliterationFailed(char)`: A specific character cannot be transliterated
/// - `ConfigurationError(message)`: The provided configuration is invalid
/// 
/// ## Examples
/// 
/// ```gleam
/// case try_slugify("") {
///   Ok(slug) -> slug
///   Error(EmptyInput) -> "Please provide some text"
///   Error(TransliterationFailed(char)) -> "Cannot convert: " <> char
///   Error(ConfigurationError(msg)) -> "Config error: " <> msg
/// }
/// ```
pub type SlugifyError {
  EmptyInput
  TransliterationFailed(char: String)
  ConfigurationError(message: String)
}
