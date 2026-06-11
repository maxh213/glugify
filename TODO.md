# glugify Library Development TODO

This TODO list provides a comprehensive roadmap for implementing the glugify slugification library for Gleam, following the implementation plan outlined in brief.md.

## v1.0.12
- [x] update the error handling readme section to reflect the reality of the code

## v1.0.13
- [x] double check the readme section using wordboundaries matches the reality of the tests and code

## v1.0.14
- [x] Update the benchmarking code so that it runs using gleamy_bench

## v2.0.0
- [x] Benchmarking code shouldn't be apart of the public API / Package, move it under /dev so it isn't included when gleam/publish is run.

## v2.0.1
- [x] Move the benchmarking code again to be outside of src, next to src and test. So it isn't in the main package.

## v3.0.0
- [x] Expand transliteration coverage (Latin extended, Cyrillic, Greek, smart punctuation, currency/symbols)
- [x] Strip unmappable characters during transliteration instead of erroring (emoji/CJK no longer empty the slug)
- [x] Handle decomposed (NFD) Unicode input
- [x] Preserve multi-codepoint graphemes in allow_unicode mode
- [x] Make stop word matching case-insensitive (as documented)
- [x] Add builders for preserve_leading_underscore and preserve_trailing_dash
- [x] Fix incorrect Unicode example output in README
- [x] Uniqueness counter API: glugify/slugger with collision-safe -1/-2 suffixing
- [x] Locale-aware transliteration via typed Locale (German, Danish, Norwegian, Swedish, Turkish)
- [x] decamelize option (fooBar -> foo-bar)
- [x] HTML entity decoding (&amp;, &#38;, &#x26;) via with_decode_html_entities
- [x] seo_preset() config (max_length: 60, word_boundary: True)
- [x] Strip ASCII apostrophes like smart apostrophes (don't -> dont)
- [x] Elixir slugify-style `ignore` option (exempt specific graphemes from transliteration and removal)
- [x] Arabic/Persian and Hebrew transliteration tables (basic consonantal romanization)

## v3.1.0
- [x] Fix stop words destroying content when separator is "" (grapheme-split bug)
- [x] Fix uppercase non-ASCII `ignore` graphemes being stripped by the lowercase pass
- [x] Remove dead code from the published package (optimized_processors, glugify_ffi.mjs)
- [x] Correct `with_trim` and `with_ignore` documentation
- [x] Add `gleam = ">= 1.0.0"` constraint to gleam.toml
- [x] github-slugger-compatible anchor mode (`glugify/anchor`), fixture-validated on both targets
- [x] Fix playground switches not toggling on click; add locale/decamelize/HTML-entity controls
- [x] Publish playground via GitHub Pages (main:/docs) and link it from README + Hex
- [x] Code-generate transliteration tables from dev/char_data/*.tsv (groundwork for CJK)
- [x] CI: Gleam version matrix (1.14.0, 1.17.0) + latest-deps job

## Roadmap candidates (from market research, June 2026)
- [ ] CJK transliteration tables (Chinese -> pinyin), possibly code-generated like the deunicode/unidecode tables
- [ ] Consider making Config opaque (with field accessors) so future options stop being major version bumps

## Development Guidelines

Each task should be completed following these principles:
- Write comprehensive tests before implementation (TDD approach)
- Ensure all code is type-safe and leverages Gleam's strengths
- Follow functional programming principles with pure functions
- Keep functions small (d10 lines) and modules focused (d200 lines)
- Run `gleam format`, `gleam check`, and `gleam test` after each implementation
- Update this TODO.md to reflect completed tasks
