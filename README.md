# glugify

A slugification library for Gleam that converts text into URL-friendly slugs.

[![Package Version](https://img.shields.io/hexpm/v/glugify)](https://hex.pm/packages/glugify)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glugify/)

```sh
gleam add glugify
```

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
// -> Ok("a_very_long_title_th")
```

## Configuration Options

```gleam
import glugify/config

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
```

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
// -> Ok("caf-na-ve-r-sum")
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

## Performance

Glugify is designed for high performance with comprehensive benchmarks covering various input types:

### Benchmark Results

#### Erlang Target

| Test Case | Operations/sec | Avg Time per Operation |
|-----------|----------------|------------------------|
| Simple text ("Hello World") | 4 ops/sec | 202ms |
| Unicode text with emojis | 12 ops/sec | 83ms |
| Long text (200+ chars) | 1 ops/sec | 619ms |
| Complex text (mixed case, symbols) | 2 ops/sec | 336ms |
| Configured simple text | 21 ops/sec | 47ms |
| Configured unicode text | 11 ops/sec | 84ms |
| Configured long text | 1 ops/sec | 629ms |
| Configured complex text | 2 ops/sec | 350ms |

**Erlang Summary:** 800 total operations executed with an average of 6 operations per second.

#### JavaScript Target

| Test Case | Operations/sec | Avg Time per Operation |
|-----------|----------------|------------------------|
| Simple text ("Hello World") | 2,702 ops/sec | 0.38ms |
| Unicode text with emojis | 3,030 ops/sec | 0.33ms |
| Long text (200+ chars) | 347 ops/sec | 2.88ms |
| Complex text (mixed case, symbols) | 613 ops/sec | 1.64ms |
| Configured simple text | 4,761 ops/sec | 0.21ms |
| Configured unicode text | 3,846 ops/sec | 0.27ms |
| Configured long text | 342 ops/sec | 2.92ms |
| Configured complex text | 602 ops/sec | 1.66ms |

**JavaScript Summary:** 800 total operations executed with an average of 2,030 operations per second.

### Performance Characteristics

- **Target Performance**: JavaScript target significantly outperforms Erlang (300-700x faster for simple operations)
- **Simple strings**: Optimized for common use cases with minimal processing overhead
- **Unicode handling**: Efficient transliteration with character mapping tables on both targets
- **Configuration impact**: Minimal performance penalty when using custom configurations
- **String length scaling**: Performance decreases predictably with input length on both targets
- **Memory efficiency**: Uses string trees for optimal memory allocation patterns

**Key Observations:**
- JavaScript target excels at simple text processing (2,700+ ops/sec vs 4-21 ops/sec)
- Both targets show similar relative performance patterns across different input types
- Long text processing is the primary bottleneck on both platforms
- Custom configuration actually improves performance on JavaScript target

The benchmarks were run with 100 iterations per test case on both Erlang and JavaScript targets. Performance may vary depending on your specific use case and runtime environment.

## Installation

Add `glugify` to your Gleam project:

```sh
gleam add glugify
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam format # Format the code
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request!

## Documentation

Further documentation can be found at <https://hexdocs.pm/glugify>.
