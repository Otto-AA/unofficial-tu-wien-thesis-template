// Page geometry.
//
// vutinfth is a two-sided A4 memoir document that loads the `geometry` package without
// arguments, so the type block is geometry's default: 0.7 of the paper in each direction,
// with the leftover space split 2:3 between inner and outer (and between top and bottom).
// Deriving the numbers instead of writing them out keeps the relationship visible.

#let paper-width = 210mm
#let paper-height = 297mm

#let body-scale = 0.7
#let margin-ratio = 2 / 5 // the "2" of geometry's 2:3 hmarginratio and vmarginratio

#let body-width = body-scale * paper-width // 147mm
#let body-height = body-scale * paper-height // 207.9mm

#let margin-inside = (paper-width - body-width) * margin-ratio // 25.2mm
#let margin-outside = paper-width - body-width - margin-inside // 37.8mm
#let margin-top = (paper-height - body-height) * margin-ratio // 35.64mm
#let margin-bottom = paper-height - body-height - margin-top // 53.46mm

#let body-margin = (
  inside: margin-inside,
  outside: margin-outside,
  top: margin-top,
  bottom: margin-bottom,
)

// Printed on one side, geometry splits the horizontal margin evenly instead of 2:3, there
// are no pages to leave blank, and every page is laid out the way a right-hand page is.
#let margin-symmetric = (paper-width - body-width) / 2

#let single-sided-margin = (
  x: margin-symmetric,
  top: margin-top,
  bottom: margin-bottom,
)

/// Whether the thesis is printed on both sides. Set once by `thesis`, and read wherever the
/// layout depends on which side of the leaf a page falls on.
#let two-sided = state("tuw-two-sided", true)

// memoir's `Ruled` page style runs the head and the foot across the type block *plus* the
// marginal-note strip (\marginparsep + \marginparwidth), so both reach this much further
// into the outer margin than the text does.
#let margin-note-strip = 41.44pt

// Distance from the top of the type block up to the head rule, and from the bottom of the
// type block down to the folio.
#let header-ascent = 19.6pt
#let footer-descent = 18.7pt

// The title pages and the statement page use their own, symmetric geometry.
#let title-page-margin = (left: 2.4cm, right: 2.4cm, top: 2cm, bottom: 2.5cm)

// Corporate-identity header graphic, measured off the official logo artwork.
#let logo-height = 11mm
#let logo-offset-x = 10.6mm // from the paper edge, i.e. outside the type block
#let logo-offset-y = 21mm // top of the logo, from the paper edge

// vutinfth's \vutinfth@bigskipamount, the vertical rhythm of the title page.
#let title-page-skip = 6mm
