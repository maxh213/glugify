//// GitHub-compatible heading anchors, matching the `github-slugger`
//// JavaScript library (and therefore GitHub's own markdown rendering).
//// Use this when generating anchors for tables of contents, static site
//// generators or anything that must agree with GitHub about which `#id`
//// a heading gets.
////
//// This is a different algorithm from `glugify.slugify`: GitHub keeps
//// underscores, keeps every Unicode letter (no transliteration), turns
//// each space into exactly one hyphen without collapsing, and does not
//// trim. `"Hello, _World_!"` anchors to `"hello-_world_"` but slugifies
//// to `"hello-world"`.
////
//// ```gleam
//// import glugify/anchor
////
//// anchor.to_anchor("Hello, World!")
//// // -> "hello-world"
////
//// let a = anchor.new()
//// let #(a, first) = anchor.anchor(a, "Intro")
//// let #(_, second) = anchor.anchor(a, "Intro")
//// // first -> "intro"
//// // second -> "intro-1"
//// ```
////
//// The character classes come from the host's Unicode tables (Erlang's
//// `re` module or the JavaScript regex engine), so behavior can differ
//// for characters from recently added scripts. In particular, OTP 27
//// and earlier bundle a regex engine with Unicode 7.0 tables, so
//// letters from scripts added later (Osage, Adlam, Cherokee lowercase,
//// ...) are stripped there but kept on OTP 28+ and JavaScript. Common
//// scripts are unaffected.

import gleam/dict.{type Dict}
import gleam/int
import gleam/string

/// Converts text to a GitHub-style anchor: lowercased, with every
/// character GitHub strips removed and each space turned into a hyphen.
///
/// Unlike `glugify.slugify`, consecutive spaces produce consecutive
/// hyphens and underscores are kept, exactly as GitHub renders heading
/// ids.
///
/// ## Examples
///
/// ```gleam
/// to_anchor("Hello, World!")
/// // -> "hello-world"
///
/// to_anchor(":ok_hand: Single")
/// // -> "ok_hand-single"
///
/// to_anchor("I ♥ unicode")
/// // -> "i--unicode"
/// ```
pub fn to_anchor(text: String) -> String {
  text
  |> string.lowercase
  |> github_clean
}

/// Like `to_anchor`, but keeps the original case, matching
/// `github-slugger`'s `maintainCase` option.
///
/// ## Examples
///
/// ```gleam
/// to_anchor_maintaining_case("Hello, World!")
/// // -> "Hello-World"
/// ```
pub fn to_anchor_maintaining_case(text: String) -> String {
  github_clean(text)
}

/// Tracks anchors handed out so far, so duplicate headings get unique
/// ids (`intro`, `intro-1`, `intro-2`, ...) with the same counting
/// behavior as `github-slugger`. Create one with `new` and thread it
/// through `anchor` calls.
pub opaque type Anchorer {
  Anchorer(occurrences: Dict(String, Int))
}

/// Creates a fresh anchorer with no anchors taken.
pub fn new() -> Anchorer {
  Anchorer(occurrences: dict.new())
}

/// Converts text to a GitHub-style anchor and makes it unique against
/// everything this anchorer has produced before.
///
/// ## Examples
///
/// ```gleam
/// let a = new()
/// let #(a, first) = anchor(a, "Intro")
/// let #(_, second) = anchor(a, "Intro")
/// // first -> "intro"
/// // second -> "intro-1"
/// ```
pub fn anchor(anchorer: Anchorer, text: String) -> #(Anchorer, String) {
  unique(anchorer, to_anchor(text))
}

/// Like `anchor`, but keeps the original case.
pub fn anchor_maintaining_case(
  anchorer: Anchorer,
  text: String,
) -> #(Anchorer, String) {
  unique(anchorer, to_anchor_maintaining_case(text))
}

/// Replicates github-slugger's occurrence counting: each base anchor
/// remembers how many duplicates it has produced, and a candidate that
/// is itself already taken bumps the counter again.
fn unique(anchorer: Anchorer, base: String) -> #(Anchorer, String) {
  let occurrences = anchorer.occurrences
  case dict.get(occurrences, base) {
    Error(Nil) -> #(Anchorer(dict.insert(occurrences, base, 0)), base)
    Ok(count) -> find_free(occurrences, base, count + 1)
  }
}

fn find_free(
  occurrences: Dict(String, Int),
  original: String,
  n: Int,
) -> #(Anchorer, String) {
  let candidate = original <> "-" <> int.to_string(n)
  case dict.has_key(occurrences, candidate) {
    True -> find_free(occurrences, original, n + 1)
    False -> #(
      Anchorer(
        occurrences
        |> dict.insert(original, n)
        |> dict.insert(candidate, 0),
      ),
      candidate,
    )
  }
}

/// Removes every character GitHub strips when turning a heading into an
/// anchor — everything except Unicode letters, marks, decimal and letter
/// numbers, connector punctuation (underscores), circled/squared Latin
/// letters, spaces and hyphens — then turns each space into a hyphen.
/// Implemented per target so each side can use its native Unicode-aware
/// regex engine, and so the space replacement happens at the codepoint
/// level (a grapheme-aware replace would skip spaces carrying combining
/// marks).
@external(erlang, "glugify_ffi", "github_clean")
@external(javascript, "./anchor_ffi.mjs", "github_clean")
fn github_clean(text: String) -> String
