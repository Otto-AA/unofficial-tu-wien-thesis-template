// Floats beyond the plain figure: sub-figures, algorithms and code listings.
//
// The LaTeX class reaches for `subcaption`, `algorithm2e` and `listings` here. Typst needs
// none of those packages, but it does need the numbering and the supplements wired up so
// that references read "Figure 3.1a" and "Algorithm 3.1", and so that the corresponding
// lists can be generated.

#import "fonts.typ": *
#import "i18n/i18n.typ": t

/// True while an outline is being laid out, so that a caption can offer a shorter form.
#let in-outline = state("tuw-in-outline", false)

/// A caption with a long form for the float itself and a short one for the list of figures
/// or tables — LaTeX's `\caption[short]{long}`.
#let flex-caption(long, short) = context {
  if in-outline.get() { short } else { long }
}

// Sub-figures are lettered within their parent, so the counter restarts with every figure.
#let subfigure-counter = counter(figure.where(kind: "subfigure"))

// Gaps the class produces around a figure's caption.
#let figure-caption-gap = 8.2pt
#let subfigure-caption-gap = 6.6pt

/// One panel of a multi-part figure. Give each its own label to reference it as
/// "Figure 3.1a"; the panels must be wrapped in an enclosing `figure`, which supplies the
/// number they hang off.
#let subfigure(body, caption: none) = figure(
  body,
  caption: caption,
  kind: "subfigure",
  supplement: context t(text.lang, "figure"),
  numbering: n => context {
    // The enclosing figure has not stepped its counter yet, so look one ahead.
    let chapter = counter(heading).get().first()
    let parent = counter(figure.where(kind: image)).get().first() + 1
    numbering("1.1", chapter, parent) + numbering("a", n)
  },
)

/// A panel's caption reads "(a) …", while a reference to it reads "Figure 3.1a". Typst
/// derives both from the same numbering, so the caption is rendered here by hand and the
/// numbering is left to serve the reference.
#let subfigure-styles(body) = {
  show figure.where(kind: "subfigure"): it => block(width: 100%, {
    it.body
    v(subfigure-caption-gap, weak: true)
    context {
      let letter = numbering("a", subfigure-counter.at(it.location()).first())
      set par(justify: true)
      [(#letter)#h(0.35em)#it.caption.body]
    }
  })
  body
}

/// Lay panels out side by side. Each entry is the content of one `subfigure`, and the
/// labels stay with the entries at the call site.
#let subfigure-row(..panels, gutter: 1em) = {
  subfigure-counter.update(0)
  grid(
    columns: (1fr,) * panels.pos().len(),
    column-gutter: gutter,
    align: bottom,
    ..panels.pos(),
  )
}

/// A ruled, line-numbered block of pseudo code, in the manner of `algorithm2e`.
///
/// Each step is a pair of an indentation level and the line itself:
///
///     #algorithm(caption: [Gauss–Seidel], input: [...], output: [...],
///       (0, [*for* $k <- 1$ *to* $m$ *do*]),
///       (1, [$x_i <- b_i$]),
///     )
#let algorithm(caption: none, input: none, output: none, indent: 1.2em, ..steps) = {
  let line-number(n) = text(size: 0.85em, str(n))
  let rows = ()
  for (i, step) in steps.pos().enumerate() {
    let (level, body) = step
    rows.push(align(right, line-number(i + 1)))
    rows.push(pad(left: level * indent, body))
  }

  figure(
    kind: "algorithm",
    supplement: context t(text.lang, "algorithm"),
    caption: caption,
    block(width: 100%, {
      // A figure centres its body; pseudo code has to stay flush left for the indentation
      // to mean anything.
      set align(left)
      set par(justify: false)
      line(length: 100%, stroke: 0.8pt)
      v(3pt, weak: true)
      if input != none {
        context [*#t(text.lang, "algorithm-input"):* #input]
        parbreak()
      }
      if output != none {
        context [*#t(text.lang, "algorithm-output"):* #output]
        parbreak()
      }
      v(1pt, weak: true)
      line(length: 100%, stroke: 0.4pt)
      v(3pt, weak: true)
      grid(
        columns: (1.6em, 1fr),
        column-gutter: 0.6em,
        row-gutter: 0.45em,
        ..rows,
      )
      v(3pt, weak: true)
      line(length: 100%, stroke: 0.8pt)
    }),
  )
}

/// A code listing. `body` is a raw block, so the usual ```lang fences apply.
#let listing(body, caption: none) = figure(
  kind: "listing",
  supplement: context t(text.lang, "listing"),
  caption: caption,
  block(width: 100%, {
    set align(left)
    set par(justify: false)
    set text(size: 0.9em)
    body
  }),
)
