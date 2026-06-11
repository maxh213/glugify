/// Locales for language-specific transliteration rules.
///
/// The default transliteration maps each character to its closest single
/// ASCII letter (`ä` -> `a`). Some languages have their own romanization
/// conventions, which a locale enables:
///
/// - `German`: `ä` -> `ae`, `ö` -> `oe`, `ü` -> `ue`
/// - `Danish` / `Norwegian`: `æ` -> `ae`, `ø` -> `oe`, `å` -> `aa`
/// - `Swedish` and `Turkish`: same as the default mapping; provided so
///   the intent can be stated explicitly in code
///
/// ## Examples
///
/// ```gleam
/// import glugify/config
/// import glugify/locale
///
/// config.default()
/// |> config.with_locale(locale.German)
/// // "Über München" -> "ueber-muenchen"
/// ```
pub type Locale {
  Default
  German
  Danish
  Norwegian
  Swedish
  Turkish
}
