// Acronyms, a glossary and an index, in the manner of the `glossaries` and `makeidx`
// packages the class's example loads.
//
// Typst has none of these built in. They are small enough to do here rather than take on a
// package dependency, which also keeps the template compiling offline.
//
// Terms are declared once, on `thesis`, and used through `gls`. Every use drops a marker in
// the flow, so the lists at the back can find both which terms were used and on which pages
// — the job `makeindex` does for LaTeX.

#import "i18n/i18n.typ": t

#let terms-state = state("tuw-terms", (:))

#let term-uses = <tuw-term-use>
#let index-uses = <tuw-index-use>

/// Counts uses of one term, so that the first can spell an acronym out.
#let term-counter(key) = counter("tuw-term-" + key)

#let lookup(key) = {
  let terms = terms-state.get()
  assert(key in terms, message: "no term declared under the key \"" + key + "\"")
  terms.at(key)
}

/// The short form of an entry: an acronym's abbreviation, or a glossary entry's name.
#let short-form(entry) = entry.at("short", default: entry.at("name", default: ""))

#let inflect(word, plural: false, capitalize: false) = {
  let text = word + if plural { "s" } else { "" }
  if capitalize { upper(text.first()) + text.slice(1) } else { text }
}

/// Record a use: it counts towards the first-use rule, and marks the page for the lists.
#let mark-use(key) = {
  term-counter(key).step()
  [#metadata(key)#term-uses]
}

#let short-of(key) = context short-form(lookup(key))

#let long-of(key) = context {
  let entry = lookup(key)
  entry.at("long", default: entry.at("description", default: ""))
}

/// Use a term, as \gls does.
///
/// The first use of an acronym spells it out — "Portable Document Format (PDF)" — and later
/// uses give the abbreviation. A glossary entry always renders its name. `plural` appends an
/// "s", `capitalize` raises the first letter, covering \glspl, \Gls and \Glspl.
#let gls(key, plural: false, capitalize: false) = {
  mark-use(key)
  context {
    let entry = lookup(key)
    let first = term-counter(key).get().first() == 1
    let short = inflect(short-form(entry), plural: plural, capitalize: capitalize)
    if first and "long" in entry {
      [#inflect(entry.long, plural: plural, capitalize: capitalize) (#short-form(entry))]
    } else {
      short
    }
  }
}

/// The abbreviation alone, whether or not it has been used before — \acrshort.
#let acrshort(key) = { mark-use(key); short-of(key) }

/// The spelled-out form alone — \acrlong.
#let acrlong(key) = { mark-use(key); long-of(key) }

/// Both forms, however often the term has been used — \acrfull.
#let acrfull(key) = { mark-use(key); [#long-of(key) (#short-of(key))] }

/// Mark this place as worth indexing under `term` — \index.
#let index-entry(term) = [#metadata(term)#index-uses]

/// The pages a set of markers falls on, deduplicated and in order.
#let pages-of(markers) = {
  let numbers = ()
  for marker in markers {
    let location = marker.location()
    // A page with no numbering of its own — a title page — still has a physical number.
    let format = location.page-numbering()
    let page = numbering(
      if format == none { "1" } else { format },
      ..counter(page).at(location),
    )
    if page not in numbers {
      numbers.push(page)
    }
  }
  numbers
}

#let entry-list(rows) = {
  set par(justify: false, hanging-indent: 1.5em)
  for row in rows {
    row
    parbreak()
  }
}

/// The terms used in the document, grouped by which markers point at them.
#let used-terms() = {
  let uses = query(term-uses)
  let grouped = (:)
  for use in uses {
    let key = use.value
    grouped.insert(key, grouped.at(key, default: ()) + (use,))
  }
  grouped
}

/// The list of acronyms — every declared term that has a spelled-out form and was used.
#let acronyms(lang) = {
  heading(level: 1, numbering: none, outlined: true, t(lang, "acronyms"))
  context {
    let terms = terms-state.get()
    let used = used-terms()
    entry-list(
      used
        .keys()
        .filter(key => "long" in terms.at(key, default: (:)))
        .sorted(key: key => lower(short-form(terms.at(key))))
        .map(key => [
          *#short-form(terms.at(key))* #h(0.8em) #terms.at(key).long.
          #pages-of(used.at(key)).join(", ")
        ]),
    )
  }
}

/// The glossary — every declared term that carries a description and was used.
#let glossary(lang) = {
  heading(level: 1, numbering: none, outlined: true, t(lang, "glossary"))
  context {
    let terms = terms-state.get()
    let used = used-terms()
    entry-list(
      used
        .keys()
        .filter(key => "description" in terms.at(key, default: (:)))
        .sorted(key: key => lower(short-form(terms.at(key))))
        .map(key => [
          *#short-form(terms.at(key))* #h(0.8em) #terms.at(key).description
          #pages-of(used.at(key)).join(", ")
        ]),
    )
  }
}

/// The index — every place marked with `index-entry`, alphabetically.
#let index(lang) = {
  heading(level: 1, numbering: none, outlined: true, t(lang, "index"))
  context {
    let grouped = (:)
    for use in query(index-uses) {
      grouped.insert(use.value, grouped.at(use.value, default: ()) + (use,))
    }
    entry-list(
      grouped
        .keys()
        .sorted(key: term => lower(term))
        .map(term => [#term, #pages-of(grouped.at(term)).join(", ")]),
    )
  }
}
