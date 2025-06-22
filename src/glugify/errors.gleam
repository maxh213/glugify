/// Represents errors that can occur during slugification.
/// 
/// ## Variants
/// 
/// - `EmptyInput`: The input string is empty
/// - `InvalidInput(reason)`: The input contains invalid data with a description
/// - `TooLong(current, max)`: The input exceeds maximum length limits
/// - `TransliterationFailed(char)`: A specific character cannot be transliterated
/// - `ConfigurationError(message)`: The provided configuration is invalid
/// 
/// ## Examples
/// 
/// ```gleam
/// case try_slugify("") {
///   Ok(slug) -> slug
///   Error(EmptyInput) -> "Please provide some text"
///   Error(InvalidInput(reason)) -> "Invalid: " <> reason
///   Error(TooLong(current, max)) -> "Too long: " <> int.to_string(current)
///   Error(TransliterationFailed(char)) -> "Cannot convert: " <> char
///   Error(ConfigurationError(msg)) -> "Config error: " <> msg
/// }
/// ```
pub type SlugifyError {
  EmptyInput
  InvalidInput(reason: String)
  TooLong(current: Int, max: Int)
  TransliterationFailed(char: String)
  ConfigurationError(message: String)
}
