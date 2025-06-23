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
// -> Ok("a_very_long_title")
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

### Benchmark Results (using gleamy_bench)

#### Erlang Target

| Test Case | Function | IPS (ops/sec) | Min Time (ms) | P99 Time (ms) |
|-----------|----------|---------------|---------------|---------------|
| Simple text ("Hello World") | slugify | 20,412 | 0.046 | 0.061 |
| Simple text ("Hello World") | slugify_with_custom_config | 20,646 | 0.046 | 0.060 |
| Unicode text with emojis | slugify | 11,903 | 0.081 | 0.098 |
| Unicode text with emojis | slugify_with_custom_config | 12,064 | 0.081 | 0.095 |
| Long text (200+ chars) | slugify | 1,545 | 0.606 | 1.090 |
| Long text (200+ chars) | slugify_with_custom_config | 1,571 | 0.607 | 0.709 |
| Complex text (mixed case, symbols) | slugify | 2,897 | 0.327 | 0.381 |
| Complex text (mixed case, symbols) | slugify_with_custom_config | 2,933 | 0.329 | 0.373 |

**Erlang Summary:** Average of ~9,750 operations per second across all test cases.

#### JavaScript Target

| Test Case | Function | IPS (ops/sec) | Min Time (ms) | P99 Time (ms) |
|-----------|----------|---------------|---------------|---------------|
| Simple text ("Hello World") | slugify | 5,925 | 0.129 | 0.570 |
| Simple text ("Hello World") | slugify_with_custom_config | 5,681 | 0.133 | 0.655 |
| Unicode text with emojis | slugify | 3,992 | 0.199 | 0.700 |
| Unicode text with emojis | slugify_with_custom_config | 4,021 | 0.202 | 0.729 |
| Long text (200+ chars) | slugify | 385 | 2.083 | 3.227 |
| Long text (200+ chars) | slugify_with_custom_config | 369 | 2.185 | 3.471 |
| Complex text (mixed case, symbols) | slugify | 654 | 1.195 | 2.635 |
| Complex text (mixed case, symbols) | slugify_with_custom_config | 635 | 1.264 | 2.489 |

**JavaScript Summary:** Average of ~2,670 operations per second across all test cases.

### Performance Characteristics

- **Target Performance**: Erlang target significantly outperforms JavaScript (3-4x faster for most operations)
- **Simple strings**: Excellent performance for common use cases (20K+ ops/sec on Erlang, 6K+ ops/sec on JavaScript)
- **Unicode handling**: Efficient transliteration with minimal performance impact on both targets
- **Configuration impact**: Custom configurations show comparable or slightly better performance
- **String length scaling**: Performance decreases predictably with input length on both targets
- **Memory efficiency**: Uses gleamy_bench for accurate performance measurement with proper statistical analysis

**Key Insights:**
- Erlang target shows superior performance for text processing operations
- Both targets maintain consistent relative performance patterns across different input types
- Long text processing (200+ characters) is the primary performance bottleneck
- Custom configuration adds minimal overhead and sometimes improves performance
- P99 latency remains low for simple operations (sub-millisecond on Erlang)

The benchmarks were run using gleamy_bench with 1000ms duration per test and 100ms warmup. Performance includes proper statistical analysis with IPS (iterations per second), minimum time, and 99th percentile measurements. Results may vary depending on your specific use case and runtime environment.

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
