import gleam/dict

/// Returns the combined character mapping that includes both Latin extended
/// characters and common symbols.
pub fn combined_char_map() -> dict.Dict(String, String) {
  dict.merge(latin_extended_map(), symbol_map())
}

pub fn latin_extended_map() -> dict.Dict(String, String) {
  dict.from_list([
    #("à", "a"),
    #("á", "a"),
    #("ä", "a"),
    #("ã", "a"),
    #("â", "a"),
    #("å", "a"),
    #("è", "e"),
    #("é", "e"),
    #("ë", "e"),
    #("ê", "e"),
    #("ì", "i"),
    #("í", "i"),
    #("ï", "i"),
    #("î", "i"),
    #("ò", "o"),
    #("ó", "o"),
    #("ö", "o"),
    #("õ", "o"),
    #("ô", "o"),
    #("ù", "u"),
    #("ú", "u"),
    #("ü", "u"),
    #("û", "u"),
    #("ç", "c"),
    #("ñ", "n"),
    #("ß", "ss"),
    #("À", "A"),
    #("Á", "A"),
    #("Ä", "A"),
    #("Ã", "A"),
    #("Â", "A"),
    #("Å", "A"),
    #("È", "E"),
    #("É", "E"),
    #("Ë", "E"),
    #("Ê", "E"),
    #("Ì", "I"),
    #("Í", "I"),
    #("Ï", "I"),
    #("Î", "I"),
    #("Ò", "O"),
    #("Ó", "O"),
    #("Ö", "O"),
    #("Õ", "O"),
    #("Ô", "O"),
    #("Ù", "U"),
    #("Ú", "U"),
    #("Ü", "U"),
    #("Û", "U"),
    #("Ç", "C"),
    #("Ñ", "N"),
  ])
}

pub fn symbol_map() -> dict.Dict(String, String) {
  dict.from_list([
    #("&", " and "),
    #("@", " at "),
    #("%", " percent "),
    #("$", " dollar "),
    #("€", " euro "),
    #("£", " pound "),
  ])
}
