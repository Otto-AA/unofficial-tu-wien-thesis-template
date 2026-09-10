// tuw-thesis — a Typst port of the vutinfth LaTeX class used for theses at
// TU Wien Informatics.
//
// The single entry point is `thesis`, applied as a show rule at the top of the document.
// It sets the page and text defaults, emits the title pages and the declaration of
// authorship, and then hands over to the author's own content.

#import "layout.typ": *
#import "layout.typ": two-sided as two-sided-state
#import "fonts.typ": *
#import "degrees.typ": resolve-degree
#import "floats.typ": (
  algorithm, figure-caption-gap, flex-caption, listing, subfigure, subfigure-row,
  subfigure-styles,
)
#import "headings.typ": heading-styles
#import "i18n/i18n.typ": format-date, localised, t
#import "matter.typ": appendix, back-matter, front-matter, main-matter
#import "outlines.typ": (
  list-of-algorithms, list-of-figures, list-of-listings, list-of-tables, outline-styles, toc,
)
#import "page-style.typ": running-foot, running-head, skip-blank-verso
#import "reference-lists.typ": (
  acrfull, acrlong, acronyms, acrshort, glossary, gls, index, index-entry, terms-state,
)
#import "statement-page.typ": statement-page
#import "summaries.typ": abstract, acknowledgements, ai-tools
#import "title-page.typ": title-page
#import "util.typ": person-name

/// How references are labelled and formatted.
///
/// "alpha" is what the LaTeX class produces: BibTeX's alpha style, whose labels are built
/// from the author and the year — [Lam94]. Typst's `alphanumeric` CSL produces those labels
/// but only formats citations, so the entries themselves are laid out by a second style.
#let reference-styles = (
  alpha: (cite: "alphanumeric", entries: "ieee"),
  numeric: (cite: auto, entries: "ieee"),
  acm: (
    cite: auto,
    entries: "association-for-computing-machinery",
  ),
  apa: (cite: auto, entries: "american-psychological-association"),
)

/// The institution printed under the title page. Overridable, but the defaults are the ones
/// the class ships.
#let tu-wien = (
  name: "Technische Universität Wien",
  contact: ("A-1040 Wien", "Karlsplatz 13", "Tel. +43-1-58801-0", "www.tuwien.at"),
)

#let thesis(
  /// Language the thesis is written in: "en" or "de".
  lang: "en",
  /// A second language for the title page and the summaries, or `none` for a thesis that
  /// stays in one language. Austrian theses are usually written in one language and
  /// summarised in both.
  secondary-lang: "de",
  /// Which languages get a title page, and in which order. `auto` prints one per language
  /// in use, German first, as the class's own example does. Pass an explicit array such as
  /// `("en", "de")` to lead with the thesis's own language instead.
  title-page-languages: auto,
  /// Title and subtitle, as a dictionary of per-language variants.
  title: (:),
  subtitle: none,
  /// "bachelor", "master" or "doctor".
  thesis-type: "master",
  /// Which master's degree, when `thesis-type` is "master": "dipl.", "master", "rer.nat."
  /// or "rer.soc.oec.". "dipl." is what makes a thesis a Diplomarbeit.
  master-degree: "dipl.",
  /// Which doctorate, when `thesis-type` is "doctor": "rer.nat.", "techn." or
  /// "rer.soc.oec.".
  doctor-degree: none,
  /// The degree awarded is derived from the two settings above and from the author's
  /// gender, as the class derives it. Set this only for an award the class does not list.
  degree: auto,
  /// The curriculum. A dissertation does not name one, and this is ignored there.
  curriculum: none,
  /// People. Each is a dictionary with `name` and the optional keys `pre-title` and
  /// `post-title`; the author additionally carries a `student-number` and a `gender` of
  /// "male" or "female", which most degree names depend on. Reviewers apply to a
  /// dissertation, which they sign above the author.
  author: (:),
  advisor: none,
  second-advisor: none,
  assistants: (),
  reviewers: (),
  /// Printed on both sides of the leaf, as a bound thesis is. Set to false for single-sided
  /// printing: the margins become symmetric, no page is left blank to start a chapter on a
  /// right-hand page, and every page is laid out the way a right-hand page is.
  two-sided: true,
  /// The institution's own details, printed under the title page.
  university: tu-wien,
  /// A name from `reference-styles`, or any CSL style Typst knows.
  reference-style: "alpha",
  /// Acronyms and glossary entries, keyed the way \newacronym and \newglossaryentry are.
  /// An acronym carries a `short` and a `long` form, a glossary entry a `name` and a
  /// `description`. Use them with `gls`, and list them with `acronyms` and `glossary`.
  terms: (:),
  keywords: (),
  date: datetime.today(),
  body,
) = {
  assert(lang in ("en", "de"), message: "lang must be \"en\" or \"de\"")
  assert(
    secondary-lang == none or secondary-lang in ("en", "de"),
    message: "secondary-lang must be \"en\", \"de\" or none",
  )
  let awarded = resolve-degree(
    thesis-type,
    master-degree,
    doctor-degree,
    author.at("gender", default: none),
    degree,
  )

  set document(
    title: localised(title, lang),
    author: author.at("name", default: ""),
    keywords: keywords,
    date: date,
  )

  two-sided-state.update(two-sided)
  terms-state.update(terms)

  set page(
    width: paper-width,
    height: paper-height,
    margin: if two-sided { body-margin } else { single-sided-margin },
    header-ascent: header-ascent,
    footer-descent: footer-descent,
    header: running-head(),
    footer: running-foot(),
  )

  // LaTeX's \baselineskip is a baseline-to-baseline distance, whereas Typst's `leading` is
  // the gap between line *boxes*. Pinning the box to exactly one em makes the two models
  // agree, so every leading in the template can be written the way the class states it.
  set text(font: serif, size: body-size, lang: lang, top-edge: 0.75em, bottom-edge: -0.25em)
  set par(
    justify: true,
    leading: body-baseline - body-size,
    // vutinfth's example turns on \nonzeroparskip and removes the indent, so paragraphs
    // are separated by space rather than by a first-line indent.
    first-line-indent: 0pt,
    spacing: body-baseline - body-size + 5.5pt,
  )
  set heading(supplement: t(lang, "chapter"))
  show heading.where(level: 2): set heading(supplement: t(lang, "section"))
  set text(hyphenate: true)
  show raw: set text(font: mono)

  let refs = reference-styles.at(
    reference-style,
    default: (cite: auto, entries: reference-style),
  )
  set cite(style: refs.cite)
  set bibliography(style: refs.entries, title: t(lang, "bibliography"))

  // Figures, tables and equations are numbered within the chapter — "Figure 3.1" — and
  // their counters restart with it, which the chapter show rule takes care of.
  let within-chapter(format) = n => numbering(format, counter(heading).get().first(), n)
  set figure(numbering: within-chapter("1.1"))
  set math.equation(numbering: within-chapter("(1.1)"))
  // memoir puts a table's caption below it, like a figure's.
  show figure.where(kind: table): set figure.caption(position: bottom)
  set figure(gap: figure-caption-gap)

  show: heading-styles.with(lang)
  show: outline-styles
  show: subfigure-styles

  let meta = (
    title: title,
    subtitle: subtitle,
    thesis-name: awarded.thesis-name,
    degree: awarded.degree,
    // A dissertation names no curriculum and lists no assistants.
    graduate: awarded.graduate,
    curriculum: if awarded.graduate { none } else { curriculum },
    author: author,
    advisor: advisor,
    second-advisor: second-advisor,
    assistants: assistants,
    reviewers: reviewers,
    university: university,
    date: date,
  )

  // The class issues \frontmatter before the title pages, so they are already part of the
  // roman page sequence — printed without a folio, but counted. The declaration that
  // follows them is page v.
  show: front-matter

  // One title page per language. German comes first by default, which is the order the
  // class's own example uses.
  let title-languages = if title-page-languages != auto {
    title-page-languages
  } else if secondary-lang == none {
    (lang,)
  } else if lang == "de" {
    (lang, secondary-lang)
  } else {
    (secondary-lang, lang)
  }
  for language in title-languages {
    title-page(language, meta)
    skip-blank-verso
  }

  statement-page(lang, author, date)

  body
}
