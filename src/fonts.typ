// Font stacks and the size scale, mirroring what vutinfth loads.
//
// The class pulls in `lmodern` for the roman body text, `helvet` (scaled) for the sans
// serif used on the title page, and `courier` for verbatim text.
//
// New Computer Modern ships with Typst and is the maintained successor of Latin Modern, so
// the body face needs no installation at all. TeX Gyre Heros and TeX Gyre Cursor are the
// very same URW Nimbus faces that `helvet` and `courier` select under LaTeX; they live in
// fonts/ and are picked up through `--font-path fonts`. Every stack ends in a widely
// available substitute, so the document still builds when that flag is missing.

#let serif = ("New Computer Modern", "Latin Modern Roman")
#let sans = ("TeX Gyre Heros", "Nimbus Sans", "Helvetica", "Arial", "Liberation Sans")
#let mono = ("TeX Gyre Cursor", "Nimbus Mono PS", "Courier New", "DejaVu Sans Mono")

// The address line under the title page is the one place where the class falls back to
// LaTeX's own sans serif rather than Helvetica, because it is emitted by the page style
// and so sits outside the title page's Helvetica group.
#let latin-sans = ("Latin Modern Sans", "New Computer Modern Sans", ..sans)

// `\RequirePackage[scaled]{helvet}` sets Helvetica a touch smaller than its nominal size so
// that it sits well beside Latin Modern. Reproducing the factor keeps the title page
// metrically identical to the LaTeX original.
#let helvet-scale = 0.9464

// Body text. vutinfth's \normalsize is \fontsize{11}{13.6}; Latin Modern's optical sizing
// renders that at the sizes measured below in the reference PDF.
#let body-size = 10.91pt
#let body-baseline = 13.55pt

// Heading sizes, as memoir resolves them for an 11pt base.
#let chapter-title-size = 24.79pt // \Huge
#let chapter-name-size = 17.22pt // \LARGE, the small-caps word "Chapter"
#let chapter-number-size = 81pt // veelo scales the numeral to fill the block
#let section-size = 14.35pt // \Large
#let subsection-size = 11.96pt // \large
#let subsubsection-size = body-size // \normalsize

// Title page sizes. vutinfth defines these explicitly as \fontsize{size}{leading}.
#let title-page-size = (
  title: 30pt, // \vutinfth@HUGE
  subtitle: 20pt, // \vutinfth@huge
  headline: 17pt, // \vutinfth@LARGE — thesis type and academic degree
  name: 14pt, // \vutinfth@Large — curriculum and author
  lead-in: 12pt, // \vutinfth@large — the connecting lines
  detail: 11pt, // \vutinfth@normalsize — faculty, advisors, signatures
)

// Set text in the title page's sans face at one of the sizes above.
#let title-page-text(size, weight: "regular", body) = text(
  font: sans,
  size: helvet-scale * size,
  weight: weight,
  body,
)
