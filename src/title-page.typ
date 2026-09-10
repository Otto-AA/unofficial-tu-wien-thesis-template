// The title page, reproducing vutinfth's \AddTitlePage.
//
// The class typesets it in Helvetica on its own, symmetric geometry, with the corporate
// logo bleeding into the left margin and the university's address in the foot. The whole
// page is generated once per language, German first.
//
// LaTeX stacks the centred lines on a baseline grid: it advances \baselineskip from one
// line to the next and an explicit \bigskip adds on top of that. Typst measures the gap
// between line *boxes* instead, so the whole page is set with `top-edge` and `bottom-edge`
// pinned to the baseline. Every vertical distance below is then a baseline distance, and
// reads the same way the class does.

#import "layout.typ": *
#import "fonts.typ": *
#import "i18n/i18n.typ": format-date, localised, t
#import "util.typ": person-name

// The two signature fields are flush with the outer edge of the type block.
#let signature-field-width = 5.1cm
#let signature-field-gap = 0.5cm

// \baselineskip on the title page, and the resulting step between two centred lines.
#let title-page-baseline = 13.6pt
#let centred-step = title-page-baseline + title-page-skip

// Title and subtitle bottom out inside a block of this height, so that a long title grows
// upwards into the space above instead of displacing everything below it.
#let title-block-height = 5cm

// From the "reviewed by" line down to the reviewers' rules, and from their names down to
// the author's. The signature block is anchored to the foot of the page, so the second of
// these is what lifts the reviewers clear of it.
#let reviewed-to-signature = 60.2pt
#let reviewers-to-signature = 27.5pt

// LaTeX places the first baseline of a page \topskip below the top of the type block and
// advances a further \baselineskip before each box that follows; Typst starts flush with
// the top edge. This offset lines the two models up.
#let first-baseline = 24.8pt

// Kept out of the line box with `move`, so the raised square does not open up the leading.
#let bullet = [ #box(height: 0pt, move(dy: -2.6pt, square(size: 1.94pt, fill: black))) ]

#let address-footer(lang, university) = {
  set align(center)
  set text(
    font: latin-sans,
    size: title-page-size.detail,
    lang: lang,
    top-edge: "baseline",
    bottom-edge: "baseline",
  )
  set par(spacing: title-page-baseline)
  line(length: 100%, stroke: 0.5pt)
  v(12.2pt, weak: true)
  university.name
  parbreak()
  university.contact.join(bullet, last: bullet)
}

#let logo = place(
  top + left,
  dx: logo-offset-x,
  dy: logo-offset-y,
  image("assets/tuw-informatics-logo.svg", height: logo-height, alt: "TU Wien Informatics"),
)

/// The block of advisors and assistants, label column on the left.
#let advisor-block(lang, advisor, second-advisor, assistants) = {
  let rows = ()
  if advisor != none {
    rows.push((t(lang, "advisor") + ":", person-name(advisor)))
  }
  if second-advisor != none {
    rows.push((t(lang, "second-advisor") + ":", person-name(second-advisor)))
  }
  for (i, assistant) in assistants.enumerate() {
    // Only the first assistant carries the label; the rest line up underneath.
    rows.push((if i == 0 { t(lang, "assistance") + ":" } else { [] }, person-name(assistant)))
  }
  grid(
    columns: (auto, auto),
    column-gutter: 0.3em,
    row-gutter: body-baseline,
    ..rows.flatten(),
  )
}

/// vutinfth's \SignatureFields: rules of a fixed width, flush with the outer edge of the
/// type block, each with a name centred underneath. `lead` is whatever sits to their left —
/// the date, or nothing. The date shares its baseline with the rules.
#let signature-fields(lead, names, row-gutter: 15.2pt) = grid(
  columns: (1fr,) + (signature-field-width,) * names.len(),
  column-gutter: signature-field-gap,
  row-gutter: row-gutter,
  align: bottom,
  lead,
  ..names.map(_ => line(length: 100%, stroke: 0.5pt)),
  [],
  ..names.map(name => align(center, name)),
)

/// The date on the left, then the signatures. A thesis is signed by its author and its
/// advisor; a dissertation only by its author, whose field stays at the outer edge.
#let signature-block(lang, date, graduate, author, advisor) = {
  let name-of(person) = if person == none { "" } else { person.at("name", default: "") }
  let names = if graduate {
    (name-of(author),)
  } else {
    (name-of(author), name-of(advisor))
  }
  signature-fields([#t(lang, "place"), #format-date(lang, date)], names)
}

/// The reviewers of a dissertation sign above the author, in fields of the same width.
///
/// The class defines \setfirstreviewerdata and \setsecondreviewerdata for a reviewer's
/// affiliation, but stopped printing them when support for external reviewers was removed
/// in v1.12, so only the names appear here.
#let reviewer-block(lang, reviewers) = {
  if reviewers.len() == 0 {
    return
  }
  t(lang, "reviewed-by")
  v(reviewed-to-signature, weak: true)
  signature-fields([], reviewers.map(r => r.at("name", default: "")))
  v(reviewers-to-signature)
}

/// One title page in the given language.
#let title-page(lang, meta) = {
  // Each centred line is its own paragraph, so paragraph spacing is the baseline step.
  let centred-line(size, weight: "regular", body) = {
    title-page-text(size, weight: weight, body)
    parbreak()
  }

  page(
    margin: title-page-margin,
    numbering: none,
    header: none,
    background: logo,
    footer-descent: 8.7pt,
    footer: address-footer(lang, meta.university),
  )[
    #set text(
      font: sans,
      size: helvet-scale * title-page-size.detail,
      lang: lang,
      top-edge: "baseline",
      bottom-edge: "baseline",
    )
    #set par(justify: false, leading: title-page-baseline, spacing: centred-step)

    #v(1.2cm + first-baseline)

    // Two \bigskips separate the title block from the lines below it. Typst takes the
    // larger of two adjacent spacings rather than adding them, so each gap below is set on
    // one side only.
    #block(
      width: 100%,
      height: title-block-height,
      below: 2 * title-page-skip + title-page-size.headline,
    )[
      #align(center + bottom)[
        #set par(spacing: title-page-skip + title-page-size.subtitle)
        #centred-line(title-page-size.title, weight: "bold", localised(meta.title, lang))
        #if meta.subtitle != none {
          title-page-text(title-page-size.subtitle, weight: "bold", localised(meta.subtitle, lang))
        }
      ]
    ]

    #align(center)[
      #centred-line(title-page-size.headline, t(lang, "thesis-type-" + meta.thesis-name))
      #centred-line(title-page-size.lead-in, t(lang, "submission"))
      #centred-line(title-page-size.headline, weight: "bold", localised(meta.degree, lang))
      #if meta.curriculum != none [
        #centred-line(title-page-size.lead-in, t(lang, "in-curriculum"))
        #centred-line(title-page-size.name, weight: "bold", localised(meta.curriculum, lang))
      ]
      #centred-line(title-page-size.lead-in, t(lang, "by"))
      // Only a \smallskip separates the registration number from the name, so the two are
      // kept in one block and the tighter spacing applies inside it.
      #block(below: 0pt)[
        #set par(spacing: title-page-baseline + 4.4pt)
        #centred-line(title-page-size.name, weight: "bold", person-name(meta.author))
        #title-page-text(
          title-page-size.lead-in,
          [#t(lang, "registration-number") #meta.author.at("student-number", default: "")],
        )
      ]
    ]

    #block(width: 100%, height: 1.6cm, above: 2 * title-page-skip + 5pt, below: 6.8pt)[
      #align(horizon)[
        #set par(spacing: 20.3pt)
        #t(lang, "faculty")
        #parbreak()
        #t(lang, "university")
      ]
    ]

    #advisor-block(
      lang,
      meta.advisor,
      meta.second-advisor,
      if meta.graduate { () } else { meta.assistants },
    )

    #v(1fr)

    #reviewer-block(lang, meta.reviewers)

    #signature-block(lang, meta.date, meta.graduate, meta.author, meta.advisor)

    #v(1cm)
  ]
}
