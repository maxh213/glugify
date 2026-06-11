// Removes every character GitHub strips when turning a heading into an
// anchor, then turns each remaining space into a hyphen. The kept set
// mirrors github-slugger's generated regex: Unicode letters (L), marks
// (M), decimal and letter numbers (Nd, Nl), connector punctuation (Pc),
// the circled and squared Latin letters that are Alphabetic without
// being letters (U+24B6-24E9, U+1F130-1F189), plus space and hyphen.
// The same class is used in the Erlang FFI so both targets behave
// identically; the space replacement lives here too so it happens at the
// codepoint level on both targets.
const GITHUB_REMOVE =
  /[^\p{L}\p{M}\p{Nd}\p{Nl}\p{Pc}\u{24B6}-\u{24E9}\u{1F130}-\u{1F149}\u{1F150}-\u{1F169}\u{1F170}-\u{1F189} -]/gu;

export function github_clean(text) {
  return text.replace(GITHUB_REMOVE, "").replace(/ /g, "-");
}
