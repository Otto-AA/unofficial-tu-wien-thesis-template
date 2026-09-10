// Table of contents, and the lists of figures, tables and listings.
//
// memoir sets chapter entries in bold with no leader and gives them extra air above;
// section entries are regular weight with a dotted leader. Numbers sit in a column of their
// own, so titles stay aligned however wide the numbers grow, and an unnumbered chapter
// starts flush with the margin instead.

#import "fonts.typ": *
#import "floats.typ": in-outline
#import "i18n/i18n.typ": t

#let chapter-number-width = 16.37pt
#let section-number-width = 25.09pt
#let page-number-width = 2.5em // memoir's \setpnumwidth

// Gaps between entry boxes. One em less than the baseline distances they produce, because
// the body's line boxes are exactly one em tall.
#let entry-gap = 2.8pt
#let chapter-entry-gap = 14.37pt

/// memoir lists a figure or table by its number alone, where Typst's own prefix would
/// repeat the supplement — "3.1" rather than "Table 3.1".
#let entry-prefix(it) = {
  if it.element.func() != figure {
    return it.prefix()
  }
  let numbers = counter(figure.where(kind: it.element.kind)).at(it.element.location())
  numbering(it.element.numbering, ..numbers)
}

#let entry-row(it, indent: 0pt, number-width: 0pt, gap: entry-gap, fill: none) = block(
  above: gap,
  below: 0pt,
  width: 100%,
  {
    if indent != 0pt {
      box(width: indent)
    }
    // An unnumbered chapter has no prefix, and then no column is reserved for one.
    let prefix = entry-prefix(it)
    if prefix != none {
      box(width: number-width, prefix)
    }
    it.body()
    if fill == none { h(1fr) } else { box(width: 1fr, inset: (x: 0.6em), fill) }
    box(width: page-number-width, align(right, it.page()))
  },
)

#let leader = repeat[.#h(3.6pt)]

/// Style the outlines. Applied once for the whole document.
#let outline-styles(body) = {
  // The class lists the contents, the figures and the tables in the table of contents
  // itself, which Typst leaves out by default.
  show outline: set heading(outlined: true, bookmarked: true)

  // Let captions switch to their short form while a list is being laid out.
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  show outline.entry: it => {
    let row = if it.element.func() == figure {
      // The lists of figures and tables have a single level, laid out like a section entry
      // but with the number flush against the margin.
      entry-row(it, number-width: section-number-width, fill: leader)
    } else if it.level == 1 {
      entry-row(it, number-width: chapter-number-width, gap: chapter-entry-gap)
    } else {
      entry-row(it, indent: chapter-number-width, number-width: section-number-width, fill: leader)
    }
    let entry = link(it.element.location(), row)
    // Chapters are the only entries memoir sets in bold.
    if it.element.func() == heading and it.level == 1 { strong(entry) } else { entry }
  }

  body
}

/// The table of contents, titled in the document's language.
#let toc(lang) = outline(title: t(lang, "contents"), depth: 2)

#let list-of-figures(lang) = outline(
  title: t(lang, "list-of-figures"),
  target: figure.where(kind: image),
)

#let list-of-tables(lang) = outline(
  title: t(lang, "list-of-tables"),
  target: figure.where(kind: table),
)

#let list-of-algorithms(lang) = outline(
  title: t(lang, "list-of-algorithms"),
  target: figure.where(kind: "algorithm"),
)

#let list-of-listings(lang) = outline(
  title: t(lang, "list-of-listings"),
  target: figure.where(kind: "listing"),
)
