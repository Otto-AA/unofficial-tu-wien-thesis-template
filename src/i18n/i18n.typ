// Translation lookup.
//
// The title pages are always typeset in both languages, so a string is looked up by an
// explicit language rather than by the ambient `text.lang`. Everything the template itself
// emits lives in strings.toml; anything the author supplies is passed in as a dictionary
// keyed the same way, e.g. `title: (en: "…", de: "…")`.

#let strings = toml("strings.toml")

#let languages = strings.keys()

/// Look up a template string in the given language.
#let t(lang, key) = {
  assert(lang in strings, message: "unsupported language: " + lang)
  let table = strings.at(lang)
  assert(key in table, message: "unknown string: " + key)
  table.at(key)
}

/// Format a date the way `datetime2` with `useregional` renders it for that language.
#let format-date(lang, date) = {
  let month = t(lang, "months").split("|").at(date.month() - 1)
  if lang == "de" {
    [#date.day(). #month #date.year()]
  } else {
    [#month #date.day(), #date.year()]
  }
}

/// Pick the author-supplied variant for a language.
///
/// Accepts either a plain value, used for every language, or a dictionary of per-language
/// variants. A missing variant falls back to the other language rather than vanishing,
/// which is what a thesis with an untranslated title needs.
#let localised(value, lang) = {
  if type(value) != dictionary {
    return value
  }
  if lang in value {
    return value.at(lang)
  }
  for other in languages {
    if other in value {
      return value.at(other)
    }
  }
  none
}
