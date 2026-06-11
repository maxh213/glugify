# glugify

A slugification library for Gleam that converts text into URL-friendly slugs.

[![Package Version](https://img.shields.io/hexpm/v/glugify)](https://hex.pm/packages/glugify)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glugify/)

```sh
gleam add glugify
```

## Try it live

An interactive playground — powered by this exact library compiled to JavaScript — lives in [`docs/`](docs/). Open `docs/index.html` in a browser (or visit [here](https://maxh213.github.io/glugify/)) to experiment with the core configuration options and copy the generated Gleam code. Rebuild the bundle after source changes with `./docs/build-playground.sh`.

## Quick Start

```gleam
import glugify

// Simple usage - always returns a string
glugify.slugify("Hello, World!")
// -> "hello-world"

// Error-aware usage - returns Result
glugify.try_slugify("My Blog Post Title!")
// -> Ok("my-blog-post-title")
```

## Three-Tier API

### Tier 1: Simple API
Zero-configuration slugification that always returns a string:

```gleam
import glugify

glugify.slugify("My awesome blog post!")
// -> "my-awesome-blog-post"

glugify.slugify("Café & Restaurant")
// -> "cafe-and-restaurant"
```

### Tier 2: Error-Aware API
Returns `Result(String, SlugifyError)` for explicit error handling:

```gleam
import glugify

case glugify.try_slugify("") {
  Ok(slug) -> "Generated slug: " <> slug
  Error(error) -> "Failed to generate slug"
}
```

### Tier 3: Configurable API
Full control with custom configuration:

```gleam
import glugify
import glugify/config

let custom_config = config.default()
  |> config.with_separator("_")
  |> config.with_max_length(20)
  |> config.with_word_boundary(True)

glugify.slugify_with("A Very Long Title That Needs Truncation", custom_config)
// -> Ok("a_very_long_title")
```

## Configuration Options

```gleam
import glugify/config
import glugify/locale

config.default()
  |> config.with_separator("_")           // Default: "-"
  |> config.with_lowercase(False)         // Default: True
  |> config.with_max_length(50)           // Default: None
  |> config.with_word_boundary(True)      // Default: False
  |> config.with_transliterate(False)     // Default: True
  |> config.with_allow_unicode(True)      // Default: False
  |> config.with_custom_replacements([    // Default: []
    #("&", " and "),
    #("@", " at ")
  ])
  |> config.with_stop_words(["the", "a"]) // Default: []
  |> config.with_preserve_leading_underscore(True) // Default: False
  |> config.with_preserve_trailing_dash(True)      // Default: False
  |> config.with_locale(locale.German)             // Default: locale.Default
  |> config.with_decamelize(True)                  // Default: False
  |> config.with_decode_html_entities(True)        // Default: False
  |> config.with_ignore(["#"])                     // Default: []
```

There is also an SEO-tuned preset (60-character limit, word-boundary truncation, per search engine URL guidance):

```gleam
glugify.slugify_with(long_title, config.seo_preset())
```

## Unique Slugs

When slugifying many titles (tables of contents, CMS imports, static sites), use `glugify/slugger` to guarantee uniqueness. The state is an immutable value, so it threads naturally through folds and behaves identically on both targets:

```gleam
import glugify/slugger

let s = slugger.new()
let #(s, a) = slugger.slug(s, "Hello World")
let #(s, b) = slugger.slug(s, "Hello World")
let #(_, c) = slugger.slug(s, "Hello World")
// a -> "hello-world"
// b -> "hello-world-1"
// c -> "hello-world-2"
```

Suffixed slugs never collide with slugs from genuinely suffixed input: `"foo"`, `"foo"`, `"foo-1"` yields `foo`, `foo-1`, `foo-1-1`. Use `slugger.slug_with` to combine uniqueness with a custom `Config`.

## Advanced Examples

### Custom Replacements
```gleam
let config = config.default()
  |> config.with_custom_replacements([
    #("&", " and "),
    #("@", " at "),
    #("%", " percent ")
  ])

glugify.slugify_with("Cats & Dogs @ 100%", config)
// -> Ok("cats-and-dogs-at-100-percent")
```

### Unicode Handling
```gleam
// With transliteration (default)
glugify.slugify("Café naïve résumé")
// -> "cafe-naive-resume"

// Preserving Unicode
let unicode_config = config.default()
  |> config.with_transliterate(False)
  |> config.with_allow_unicode(True)

glugify.slugify_with("Café naïve résumé", unicode_config)
// -> Ok("café-naïve-résumé")
```

Transliteration covers Latin-extended characters (e.g. `ø`, `Ł`, `æ`, `ß`, `İ`), Cyrillic, Greek, Arabic/Persian and Hebrew (basic consonantal romanization), typographic punctuation (smart quotes, dashes, ellipses), and common currency signs and symbols. Decomposed (NFD) input is normalized by mapping base characters and dropping combining marks. Characters with no known mapping — such as emoji or CJK — are stripped rather than causing an error:

```gleam
glugify.slugify("10 Tips 🚀 for Gleam")
// -> "10-tips-for-gleam"

glugify.slugify("Привет мир")
// -> "privet-mir"

glugify.slugify("Don’t — “Stop”")
// -> "dont-stop"
```

### Locale-Aware Transliteration
```gleam
import glugify/locale

let config = config.default()
  |> config.with_locale(locale.German)

glugify.slugify_with("Über München", config)
// -> Ok("ueber-muenchen")    (default locale gives "uber-munchen")

let config = config.default()
  |> config.with_locale(locale.Danish)

glugify.slugify_with("København på Ærø", config)
// -> Ok("koebenhavn-paa-aeroe")
```

### Decamelize
```gleam
let config = config.default()
  |> config.with_decamelize(True)

glugify.slugify_with("myAwesomeXMLParser", config)
// -> Ok("my-awesome-xml-parser")
```

### HTML Entities
```gleam
let config = config.default()
  |> config.with_decode_html_entities(True)

glugify.slugify_with("Tom &amp; Jerry &ndash; Classics", config)
// -> Ok("tom-and-jerry-classics")
```

### Ignored Characters
```gleam
let config = config.default()
  |> config.with_ignore(["#"])

glugify.slugify_with("C# and F# compared", config)
// -> Ok("c#-and-f#-compared")
```

### Stop Words
```gleam
let config = config.default()
  |> config.with_stop_words(["the", "a", "an", "and", "or"])

glugify.slugify_with("The Quick Brown Fox and the Lazy Dog", config)
// -> Ok("quick-brown-fox-lazy-dog")
```

## Error Handling

The library provides explicit error types for robust error handling:

```gleam
import glugify/errors

case glugify.try_slugify("") {
  Ok(slug) -> slug
  Error(errors.EmptyInput) -> "Please provide some text"
  Error(errors.TransliterationFailed(char)) -> "Cannot transliterate: " <> char
  Error(errors.ConfigurationError(msg)) -> "Config error: " <> msg
}
```

- `EmptyInput` is returned when the input is empty or whitespace-only.
- `TransliterationFailed` is returned only when transliteration is disabled (`with_transliterate(False)`) and the input contains non-ASCII characters while `allow_unicode` is `False`. With transliteration enabled (the default), unmappable characters are stripped instead.
- `ConfigurationError` is returned for invalid configuration, such as a separator longer than 10 characters.

## Performance

### Benchmark Results (using gleamy_bench)

#### Erlang Target

| Test Case | Function | IPS (ops/sec) | Min Time (ms) | P99 Time (ms) |
|-----------|----------|---------------|---------------|---------------|
| Simple text ("Hello World") | slugify | 44,937 | 0.019 | 0.033 |
| Simple text ("Hello World") | slugify_with_custom_config | 46,145 | 0.019 | 0.033 |
| Unicode text with emojis | slugify | 22,292 | 0.039 | 0.081 |
| Unicode text with emojis | slugify_with_custom_config | 22,328 | 0.041 | 0.073 |
| Long text (200+ chars) | slugify | 4,304 | 0.214 | 0.430 |
| Long text (200+ chars) | slugify_with_custom_config | 4,449 | 0.216 | 0.275 |
| Complex text (mixed case, symbols) | slugify | 7,399 | 0.129 | 0.162 |
| Complex text (mixed case, symbols) | slugify_with_custom_config | 7,278 | 0.131 | 0.166 |

**Erlang Summary:** Average of ~19,900 operations per second across all test cases.

#### JavaScript Target

| Test Case | Function | IPS (ops/sec) | Min Time (ms) | P99 Time (ms) |
|-----------|----------|---------------|---------------|---------------|
| Simple text ("Hello World") | slugify | 5,391 | 0.112 | 1.614 |
| Simple text ("Hello World") | slugify_with_custom_config | 6,085 | 0.107 | 1.669 |
| Unicode text with emojis | slugify | 2,559 | 0.265 | 1.888 |
| Unicode text with emojis | slugify_with_custom_config | 2,224 | 0.290 | 2.099 |
| Long text (200+ chars) | slugify | 383 | 1.660 | 5.404 |
| Long text (200+ chars) | slugify_with_custom_config | 394 | 1.717 | 5.362 |
| Complex text (mixed case, symbols) | slugify | 663 | 0.955 | 4.523 |
| Complex text (mixed case, symbols) | slugify_with_custom_config | 661 | 0.961 | 4.833 |

**JavaScript Summary:** Average of ~2,300 operations per second across all test cases.

### Performance Characteristics

- The Erlang target significantly outperforms JavaScript (roughly 8x for most operations)
- Custom configurations add negligible overhead
- Performance decreases predictably with input length; long text (200+ characters) is the main bottleneck
- Character lookups use pattern matching rather than dictionary construction, so transliteration adds minimal cost

The benchmarks were run using gleamy_bench with 100ms duration and 10ms warmup per test (`gleam run -m benchmark_runner`). Results may vary depending on your specific use case and runtime environment.

## Installation

Add `glugify` to your Gleam project:

```sh
gleam add glugify
```

## Development

```sh
gleam test                          # Run the tests
gleam test --target javascript     # Run the tests on the JavaScript target
gleam format                        # Format the code
gleam run -m benchmark_runner       # Run the benchmarks
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request!

## Documentation

Further documentation can be found at <https://hexdocs.pm/glugify>.
