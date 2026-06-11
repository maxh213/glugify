// Playground entry: exposes the REAL compiled Gleam library to the browser.
// Bundled by docs/build-playground.sh — do not edit the generated bundle.
import { toList } from "../build/dev/javascript/prelude.mjs";
import {
  slugify,
  try_slugify,
  slugify_with,
} from "../build/dev/javascript/glugify/glugify.mjs";
import {
  default$ as defaultConfig,
  with_separator,
  with_lowercase,
  with_max_length,
  with_word_boundary,
  with_transliterate,
  with_allow_unicode,
  with_custom_replacements,
  with_stop_words,
} from "../build/dev/javascript/glugify/glugify/config.mjs";
import {
  EmptyInput,
  TransliterationFailed,
  ConfigurationError,
} from "../build/dev/javascript/glugify/glugify/errors.mjs";

function buildConfig(opts) {
  let cfg = defaultConfig();
  cfg = with_separator(cfg, opts.separator);
  cfg = with_lowercase(cfg, opts.lowercase);
  if (opts.maxLength !== null && opts.maxLength !== undefined) {
    cfg = with_max_length(cfg, opts.maxLength);
  }
  cfg = with_word_boundary(cfg, opts.wordBoundary);
  cfg = with_transliterate(cfg, opts.transliterate);
  cfg = with_allow_unicode(cfg, opts.allowUnicode);
  if (opts.customReplacements.length > 0) {
    cfg = with_custom_replacements(
      cfg,
      toList(opts.customReplacements.map(([from, to]) => [from, to])),
    );
  }
  if (opts.stopWords.length > 0) {
    cfg = with_stop_words(cfg, toList(opts.stopWords));
  }
  return cfg;
}

function describeError(err) {
  if (err instanceof EmptyInput) {
    return { tag: "EmptyInput", message: "The input string is empty" };
  }
  if (err instanceof TransliterationFailed) {
    return {
      tag: "TransliterationFailed",
      message: "Cannot transliterate: " + err.char,
    };
  }
  if (err instanceof ConfigurationError) {
    return { tag: "ConfigurationError", message: err.message };
  }
  return { tag: "Unknown", message: "Unknown error" };
}

window.Glugify = {
  slugify,
  trySlugify(text) {
    const result = try_slugify(text);
    return result.isOk()
      ? { ok: true, slug: result[0] }
      : { ok: false, error: describeError(result[0]) };
  },
  slugifyWith(text, opts) {
    const result = slugify_with(text, buildConfig(opts));
    return result.isOk()
      ? { ok: true, slug: result[0] }
      : { ok: false, error: describeError(result[0]) };
  },
};
