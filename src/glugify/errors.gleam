pub type SlugifyError {
  EmptyInput
  InvalidInput(reason: String)
  TooLong(current: Int, max: Int)
  TransliterationFailed(char: String)
  ConfigurationError(message: String)
}
