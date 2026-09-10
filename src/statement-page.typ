// The declaration of authorship, reproducing vutinfth's \AddStatementPage.
//
// Unlike the title pages this one uses the ordinary type block and is part of the front
// matter, so it carries a roman folio. The heading is an unnumbered chapter; the author's
// name, the date and the signature stay in the title page's sans face, while the
// declaration itself is set in the body's roman.

#import "fonts.typ": *
#import "i18n/i18n.typ": format-date, t
#import "title-page.typ": signature-field-width
#import "util.typ": person-name

// Gaps between the blocks of the page, as the class lays them out. Each is set on one side
// only, since Typst takes the larger of two adjacent spacings rather than adding them.
#let heading-to-name = 38.9pt
#let name-to-statement = 36.4pt
#let statement-to-signature = 83.8pt
// A box gap, not a baseline distance: unlike the title page this one is set with the
// body's line boxes, which already carry three quarters of an em above the baseline.
#let signature-rule-to-name = 6.2pt

#let statement-page(lang, author, date) = {
  set text(lang: lang)

  heading(level: 1, numbering: none, outlined: false, t(lang, "statement-chapter"))

  block(above: heading-to-name, title-page-text(title-page-size.detail, person-name(author)))

  // The class separates the two declarations with a plain line break rather than a
  // paragraph break, so they read as one continuous block.
  set par(justify: true)
  block(above: name-to-statement, {
    t(lang, "statement")
    linebreak()
    t(lang, "ai-statement")
  })

  set text(font: sans, size: helvet-scale * title-page-size.detail)
  block(above: statement-to-signature, grid(
    columns: (1fr, signature-field-width),
    column-gutter: 0.5cm,
    row-gutter: signature-rule-to-name,
    align: bottom,
    [#t(lang, "place"), #format-date(lang, date)],
    line(length: 100%, stroke: 0.5pt),
    [],
    align(center, author.at("name", default: "")),
  ))
}
