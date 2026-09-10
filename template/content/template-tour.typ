#import "@preview/definitely-not-tuw-thesis:0.3.0": (
  acrfull, algorithm, flex-caption, gls, index-entry, listing, subfigure, subfigure-row,
)

= Using This Template <sec-tour-chapter>

This chapter is the counterpart of the LaTeX class's own introductory chapter: it exercises
every element a thesis is likely to need, so that anything looking wrong here can be spotted
before you start writing. Delete it once you do.

== Cross-references <sec-cross-references>

Anything with a label can be referenced. @fig-logo-full is a figure, @tab-squad a table,
@eq-basel an equation, @alg-gauss-seidel an algorithm and @lst-fibonacci a listing.
Sections work the same way: this is @sec-cross-references inside @sec-tour-chapter. Citations
go through the bibliography, as in @lamport1994latex and @typst.

== Figures

=== A figure at full text width

Give the image `width: 100%` to fill the type block, and attach the label after the figure,
as in @fig-logo-full.

#figure(
  image("../graphics/TUWI-Logo-Code.png", width: 100%),
  caption: [The TU Wien Informatics logo at the full width of the type block.],
) <fig-logo-full>

=== Several panels in one row

Papers often place two or three images side by side, each with its own caption and label.
Wrap the panels in `subfigure-row` inside a normal figure: @fig-panels-a and @fig-panels-b
are the panels of @fig-panels.

#figure(
  subfigure-row(
    [#subfigure(
        image("../graphics/TUWI-Logo-Code.png", width: 100%),
        caption: [At the width of its column.],
      ) <fig-panels-a>],
    [#subfigure(
        image("../graphics/TUWI-Logo-Code.png", width: 60%),
        caption: [At sixty per cent of it.],
      ) <fig-panels-b>],
  ),
  caption: flex-caption(
    [The same logo twice, to show how panels are lettered and referenced individually. This
      caption is long on purpose, and the list of figures shows the short form instead.],
    [Two panels of the same logo.],
  ),
) <fig-panels>

=== A diagram drawn in Typst

Diagrams need not be imported as images. The two below are drawn from the document source
itself, so they pick up the body font and stay sharp at any zoom.

#let node(body) = box(
  stroke: 0.6pt,
  inset: (x: 8pt, y: 6pt),
  radius: 2pt,
  align(center, body),
)

#let flow-arrow = box(width: 1fr, height: 6pt, {
  place(horizon, line(length: 100%, stroke: 0.6pt))
  place(horizon + right, polygon(fill: black, (0pt, -2.4pt), (0pt, 2.4pt), (4.5pt, 0pt)))
})

#figure(
  block(width: 100%, grid(
    columns: (auto, 1fr, auto, 1fr, auto, 1fr, auto),
    align: horizon,
    node[Sources], flow-arrow, node[Compiler], flow-arrow, node[Layout], flow-arrow, node[PDF],
  )),
  caption: [A pipeline drawn with boxes, rules and a polygon for the arrow head.],
) <fig-pipeline>

#let bars = (("2021", 34), ("2022", 51), ("2023", 78), ("2024", 96), ("2025", 120))
#let bar-max = calc.max(..bars.map(entry => entry.at(1)))

#figure(
  block(width: 100%, grid(
    columns: (auto,) * bars.len(),
    column-gutter: 1.4em,
    align: bottom + center,
    ..bars.map(((label, value)) => {
      stack(
        spacing: 4pt,
        text(size: 0.85em, str(value)),
        rect(width: 1.6em, height: value / bar-max * 4cm, fill: luma(35%)),
        text(size: 0.85em, label),
      )
    }),
  )),
  caption: [A bar chart computed from an array in the document source.],
) <fig-chart>

== Tables

Rules come from `table.hline`; the booktabs look is a thick rule at the top and bottom and a
thin one under the header. @tab-distributions is the plainest form.

#figure(
  table(
    columns: 4,
    stroke: none,
    align: center,
    table.hline(stroke: 0.8pt),
    table.header[Distribution][Unix][Windows][MacOS],
    table.hline(stroke: 0.4pt),
    [TeX Live], strong[yes], [yes], [(yes)],
    [MacTeX], [no], [no], strong[yes],
    [MiKTeX], [(yes)], strong[yes], [yes],
    table.hline(stroke: 0.8pt),
  ),
  caption: [TeX distributions for different operating systems, with the recommended choice
    in *bold*.],
) <tab-distributions>

Cells span rows and columns with `table.cell`, and a partial rule takes `start` and `end`.
@tab-squad is the class's own example, carried over.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: left,
    table.hline(stroke: 0.8pt),
    table.cell(colspan: 2, align: center)[Position], [],
    table.hline(start: 0, end: 2, stroke: 0.4pt),
    [Group], [Abbrev], [Name],
    table.hline(stroke: 0.4pt),
    [Goalkeeper], [GK], [Paul Robinson],
    table.hline(stroke: 0.4pt),
    table.cell(rowspan: 4)[Defenders], [LB], [Lucas Radebe],
    [DC], [Michael Duberry],
    [DC], [Dominic Matteo],
    [RB], [Didier Domi],
    table.hline(stroke: 0.4pt),
    table.cell(rowspan: 3)[Midfielders], [MC], [David Batty],
    [MC], [Eirik Bakke],
    [MC], [Jody Morris],
    table.hline(stroke: 0.4pt),
    [Forward], [FW], [Jamie McMaster],
    table.hline(stroke: 0.4pt),
    table.cell(rowspan: 2)[Strikers], [ST], [Alan Smith],
    [ST], [Mark Viduka],
    table.hline(stroke: 0.8pt),
  ),
  caption: flex-caption(
    [Adapted from the LaTeX guide at #link("https://en.wikibooks.org/wiki/LaTeX/Tables").
      It shows cells spanning several rows and columns and a rule covering only part of the
      width.],
    [A table with cells spanning rows and columns.],
  ),
) <tab-squad>

== Mathematical expressions <sec-math>

An expression can be set inline as $sum_(n = 1)^oo 1 / n^2 = pi^2 / 6$, or displayed outside
the text stream as

#[
  #set math.equation(numbering: none)
  $ sum_(n = 1)^oo 1 / n^2 = pi^2 / 6 $
]

or as a numbered equation with

$ sum_(n = 1)^oo 1 / n^2 = pi^2 / 6. $ <eq-basel>

Equations align on `&`, and `cases` covers piecewise definitions.

$
  nabla dot bold(E) &= rho / epsilon_0 &         quad nabla times bold(E) &= -(partial bold(B)) / (partial t) \
  nabla dot bold(B) &= 0               & quad nabla times bold(B) &= mu_0 (bold(J) + epsilon_0 (partial bold(E)) / (partial t))
$ <eq-maxwell>

$
  op("sgn")(x) = cases(
    -1 & "if " x < 0,
    0 & "if " x = 0,
    +1 & "if " x > 0,
  )
$

Matrices, determinants and large operators scale with their contents.

$
  bold(A) = mat(
    a_11, a_12, dots.h, a_(1 n);
    a_21, a_22, dots.h, a_(2 n);
    dots.v, dots.v, dots.down, dots.v;
    a_(m 1), a_(m 2), dots.h, a_(m n)
  ),
  quad
  det bold(A) = sum_(sigma in S_n) op("sgn")(sigma) product_(i = 1)^n a_(i, sigma(i))
$

The following exercises the symbol coverage of the maths font. Every row should render
without a missing glyph.

#let symbol-rows = (
  ([Greek], $alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi pi rho sigma tau upsilon phi chi psi omega$),
  ([Greek, capital], $Gamma Delta Theta Lambda Xi Pi Sigma Upsilon Phi Psi Omega$),
  ([Variants], $epsilon.alt theta.alt phi.alt pi.alt rho.alt sigma.alt$),
  ([Relations], $< <= << subset subset.eq in in.not equiv approx tilde.equiv prop != >= > >>$),
  ([Operators], $plus.minus minus.plus times div dot.c ast.op star circle.small xor times.o and or inter union$),
  ([Large operators], $sum product integral integral.double integral.cont union.big inter.big limits(max)_x$),
  ([Arrows], $arrow.l arrow.r arrow.l.r arrow.t arrow.b arrow.l.double arrow.r.double arrow.l.r.double arrow.r.long arrow.r.bar arrow.tr$),
  ([Set theory], $emptyset nothing forall exists exists.not nabla infinity partial without complement$),
  ([Logic], $not and or arrow.r.double arrow.l.r.double tack.r models bot top$),
  ([Calculus], $lim_(x -> 0) (sin x) / x = 1 quad integral_a^b f(x) dif x quad (partial^2 u) / (partial x partial y)$),
  ([Delimiters], $lr(( a / b )) lr([ a / b ]) lr({ a / b }) abs(a / b) norm(a / b) floor(x) ceil(x)$),
  ([Accents], $hat(a) tilde(a) macron(a) arrow(a) dot(a) dot.double(a) breve(a) caron(a) overline(A B)$),
  ([Blackboard, script], $NN ZZ QQ RR CC quad cal(A) cal(B) cal(F) quad frak(g) frak(h)$),
  ([Spacing and text], $a thin b med c thick d quad e wide f quad "plain text" quad op("lim sup")$),
)

#figure(
  table(
    columns: (auto, 1fr),
    stroke: none,
    align: (right + horizon, left + horizon),
    row-gutter: 3pt,
    table.hline(stroke: 0.8pt),
    ..symbol-rows.map(((name, sample)) => (text(size: 0.9em, name), sample)).flatten(),
    table.hline(stroke: 0.8pt),
  ),
  caption: [A survey of the mathematical symbols the template renders.],
) <tab-symbols>

== Code listings

Fenced blocks are highlighted by language. Wrap one in `listing` to give it a number, a
caption and an entry in the list of listings, as in @lst-fibonacci.

#listing(
  ```python
  def fibonacci(n: int) -> int:
      """Return the n-th Fibonacci number."""
      a, b = 0, 1
      for _ in range(n):
          a, b = b, a + b
      return a
  ```,
  caption: [An iterative Fibonacci function in Python.],
) <lst-fibonacci>

Short fragments stay inline as `raw` text: `git rebase --interactive`, or
`typst compile --font-path fonts template/thesis.typ`.

== Algorithms

Pseudo code is written as a list of steps, each with an indentation level, which keeps the
line numbering continuous across nesting the way `algorithm2e` does.

#algorithm(
  caption: [Gauss--Seidel],
  input: [A scalar $epsilon$, a matrix $bold(A) = (a_(i j))$, a vector $arrow(b)$, and an
    initial vector $arrow(x)^((0))$],
  output: [$arrow(x)^((n))$ with $bold(A) arrow(x)^((n)) approx arrow(b)$],
  (0, [*for* $k <- 1$ *to* maximum iterations *do*]),
  (1, [*for* $i <- 1$ *to* $n$ *do*]),
  (
    2,
    [$x_i^((k)) = 1 / a_(i i) (b_i - sum_(j < i) a_(i j) x_j^((k)) - sum_(j > i) a_(i j) x_j^((k - 1)))$],
  ),
  (1, [*end*]),
  (1, [*if* $abs(arrow(x)^((k)) - arrow(x)^((k - 1))) < epsilon$ *then break for*]),
  (0, [*end*]),
  (0, [*return* $arrow(x)^((k))$]),
) <alg-gauss-seidel>

== Acronyms, a glossary and an index

Terms are declared once in `thesis.typ` and used with `gls`. The first use of an acronym
spells it out and the rest give the abbreviation, so #gls("pdf") reads in full here and as
#gls("pdf") from now on. `gls` takes `plural` and `capitalize` for the other forms:
#gls("editor", plural: true), #gls("wysiwyg", capitalize: true). `acrfull` gives both forms
wherever you need them: #acrfull("ctan").

A word is added to the index by marking a place in the text#index-entry("index") with
`index-entry`. The same term can be marked as often as
needed#index-entry("index")#index-entry("typesetting"); the entry collects the pages.

The three lists at the back are printed by `acronyms()`, `glossary()` and `index()`, and
each lists only the terms actually used, as `\printglossaries` does.

== Lists and quotations

- An unordered list,
- with a second item,
  - and a nested one.

+ An ordered list,
+ whose numbers follow automatically.

/ Term: A description list pairs a term with its explanation.
/ Second term: Which is what a glossary entry looks like.

#quote(block: true, attribution: [Donald E. Knuth])[
  Programs are meant to be read by humans and only incidentally for computers to execute.
]

Footnotes hang off the page they appear on.#footnote[Like this one.]
