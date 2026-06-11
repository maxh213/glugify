//// A stateful slugger that guarantees unique slugs across a batch of
//// inputs — the building block for tables of contents, static site
//// generators and CMS imports, where two posts titled "Hello" must not
//// share a URL.
////
//// The state is an immutable value threaded through each call, so it
//// works naturally in folds and works identically on the Erlang and
//// JavaScript targets:
////
//// ```gleam
//// import glugify/slugger
////
//// let s = slugger.new()
//// let #(s, a) = slugger.slug(s, "Hello World")
//// let #(s, b) = slugger.slug(s, "Hello World")
//// let #(_, c) = slugger.slug(s, "Hello World")
//// // a -> "hello-world"
//// // b -> "hello-world-1"
//// // c -> "hello-world-2"
//// ```

import gleam/dict.{type Dict}
import gleam/int
import gleam/result
import gleam/set.{type Set}
import glugify
import glugify/config.{type Config}
import glugify/errors.{type SlugifyError}

/// Tracks which slugs have been handed out. Create one with `new` and
/// thread it through `slug` or `slug_with` calls.
pub opaque type Slugger {
  Slugger(taken: Set(String), counts: Dict(String, Int))
}

/// Creates a fresh slugger with no slugs taken.
pub fn new() -> Slugger {
  Slugger(taken: set.new(), counts: dict.new())
}

/// Slugifies `text` with the default configuration and makes the result
/// unique against everything this slugger has produced before, by
/// appending `-1`, `-2`, ... to duplicates.
///
/// Unlike github-slugger, a suffixed slug never collides with a slug
/// produced from genuinely suffixed input: `"foo"`, `"foo"`, `"foo-1"`
/// yields `"foo"`, `"foo-1"`, `"foo-1-1"`.
///
/// Empty results (e.g. from symbol-only input) bypass uniqueness and are
/// returned as-is.
///
/// ## Examples
///
/// ```gleam
/// let #(slugger, first) = slug(new(), "My Post")
/// let #(_, second) = slug(slugger, "My Post")
/// // first -> "my-post"
/// // second -> "my-post-1"
/// ```
pub fn slug(slugger: Slugger, text: String) -> #(Slugger, String) {
  let base = glugify.slugify(text)
  unique(slugger, base)
}

/// Like `slug`, but slugifies with a custom configuration.
///
/// ## Examples
///
/// ```gleam
/// import glugify/config
///
/// let cfg = config.default() |> config.with_separator("_")
/// slug_with(new(), "My Post", cfg)
/// // -> Ok(#(slugger, "my_post"))
/// ```
pub fn slug_with(
  slugger: Slugger,
  text: String,
  config: Config,
) -> Result(#(Slugger, String), SlugifyError) {
  glugify.slugify_with(text, config)
  |> result.map(unique(slugger, _))
}

fn unique(slugger: Slugger, base: String) -> #(Slugger, String) {
  case base {
    "" -> #(slugger, "")
    _ ->
      case set.contains(slugger.taken, base) {
        False -> #(
          Slugger(..slugger, taken: set.insert(slugger.taken, base)),
          base,
        )
        True -> {
          let next = case dict.get(slugger.counts, base) {
            Ok(count) -> count
            Error(Nil) -> 1
          }
          find_free(slugger, base, next)
        }
      }
  }
}

fn find_free(slugger: Slugger, base: String, n: Int) -> #(Slugger, String) {
  let candidate = base <> "-" <> int.to_string(n)
  case set.contains(slugger.taken, candidate) {
    True -> find_free(slugger, base, n + 1)
    False -> #(
      Slugger(
        taken: set.insert(slugger.taken, candidate),
        counts: dict.insert(slugger.counts, base, n + 1),
      ),
      candidate,
    )
  }
}
