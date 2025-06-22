import gleeunit
import gleeunit/should
import glugify
import glugify/config
import glugify/errors

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn simple_slugify_test() {
  glugify.slugify("Hello World")
  |> should.equal("hello-world")
}

pub fn simple_slugify_with_special_chars_test() {
  glugify.slugify("Hello World! & More")
  |> should.equal("hello-world-and-more")
}

pub fn slugify_with_accents_test() {
  glugify.slugify("Café résumé naïve")
  |> should.equal("cafe-resume-naive")
}

pub fn slugify_empty_input_test() {
  glugify.slugify("")
  |> should.equal("")
}

pub fn slugify_whitespace_only_test() {
  glugify.slugify("   ")
  |> should.equal("")
}

pub fn try_slugify_success_test() {
  glugify.try_slugify("Hello World")
  |> should.be_ok
  |> should.equal("hello-world")
}

pub fn try_slugify_empty_input_test() {
  glugify.try_slugify("")
  |> should.be_error
  |> should.equal(errors.EmptyInput)
}

pub fn try_slugify_whitespace_only_test() {
  glugify.try_slugify("   ")
  |> should.be_error
  |> should.equal(errors.EmptyInput)
}

pub fn slugify_with_custom_separator_test() {
  let config =
    config.default()
    |> config.with_separator("_")

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("hello_world")
}

pub fn slugify_with_preserve_case_test() {
  let config =
    config.default()
    |> config.with_lowercase(False)

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("Hello-World")
}

pub fn slugify_with_max_length_test() {
  let config =
    config.default()
    |> config.with_max_length(5)

  glugify.slugify_with("Hello World", config)
  |> should.be_ok
  |> should.equal("hello")
}

pub fn slugify_with_no_transliteration_test() {
  let config =
    config.default()
    |> config.with_transliterate(False)

  glugify.slugify_with("Café", config)
  |> should.be_error
}

pub fn slugify_multiple_spaces_test() {
  glugify.slugify("Hello    World")
  |> should.equal("hello-world")
}

pub fn slugify_leading_trailing_spaces_test() {
  glugify.slugify("  Hello World  ")
  |> should.equal("hello-world")
}

pub fn slugify_numbers_test() {
  glugify.slugify("Version 2.0")
  |> should.equal("version-2-0")
}

pub fn slugify_mixed_case_test() {
  glugify.slugify("CamelCase String")
  |> should.equal("camelcase-string")
}
