// Running heads, folios, and LaTeX's \cleardoublepage.
//
// vutinfth uses two page styles. Its own default — front matter, back matter and the page
// a chapter opens on — carries nothing but the folio at the outer edge of the type block.
// The main matter switches to memoir's `Ruled`: the chapter mark in small caps on verso
// pages, the section mark on recto pages, a rule under both, and the folio again at the
// outer edge. `Ruled` runs its head and foot across the type block plus the marginal-note
// strip, so both reach further into the outer margin than the text does.

#import "layout.typ": *
#import "fonts.typ": *
#import "util.typ": is-recto

/// Which of the two page styles is in force. Set by the matter functions.
#let ruled-pages = state("tuw-ruled-pages", false)

// Pages left blank by \cleardoublepage. LaTeX gives them an empty page style, so they carry
// neither a running head nor a folio. Typst has no hook on the page a break skips over, so
// the pages are recorded as they are produced and looked up again from the head and foot.
#let blank-pages = state("tuw-blank-pages", ())
#let last-content-page = state("tuw-last-content-page", 0)

/// LaTeX's \cleardoublepage: continue on the next right-hand page, leaving any page in
/// between deliberately blank. Printed on one side there is nothing to skip, and it is an
/// ordinary page break.
#let clear-to-recto = {
  // Each state is read in its own context: an update nested inside a context that branches
  // on another state does not reliably reach that state's final value.
  context { last-content-page.update(here().page()) }
  context {
    if two-sided.get() { pagebreak(to: "odd", weak: true) } else { pagebreak(weak: true) }
  }
  context {
    let landed = here().page()
    let ended = last-content-page.get()
    // The break skipped a page exactly when it advanced by two.
    if landed == ended + 2 {
      blank-pages.update(pages => pages + (ended + 1,))
    }
  }
}

/// The same, for the page after a standalone `page()` such as a title page. The flow
/// resumes on an already-empty verso, which `clear-to-recto` cannot recognise as skipped.
#let skip-blank-verso = {
  context {
    let current = here().page()
    if calc.even(current) {
      blank-pages.update(pages => pages + (current,))
    }
  }
  context { if two-sided.get() { pagebreak(to: "odd", weak: true) } }
}

#let is-blank-page() = here().page() in blank-pages.final()

/// Stretch a head or foot to memoir's running width. The extra strip lives in the outer
/// margin, so it changes sides with the page.
#let running-band(body) = {
  let band = box(width: body-width + margin-note-strip, body)
  if is-recto() { band } else { move(dx: -margin-note-strip, band) }
}

/// The last numbered chapter at or before this page, and whether it opens on this page.
#let chapter-context() = {
  let page-number = here().page()
  let chapters = query(heading.where(level: 1)).filter(it => it.numbering != none)
  (
    chapter: chapters.filter(it => it.location().page() <= page-number).at(-1, default: none),
    opens-here: query(heading.where(level: 1)).any(it => it.location().page() == page-number),
  )
}

#let mark-number(it) = numbering(it.numbering, ..counter(heading).at(it.location())) + "."

#let running-head() = context {
  if not ruled-pages.get() or is-blank-page() {
    return
  }
  let (chapter, opens-here) = chapter-context()
  // memoir prints no running head on the page a chapter opens on.
  if chapter == none or opens-here {
    return
  }

  let mark = if is-recto() {
    let sections = query(selector(heading.where(level: 2)).before(here()))
    if sections.len() == 0 {
      return
    }
    let section = sections.at(-1)
    align(right, mark-number(section) + h(1em) + section.body)
  } else {
    align(left, mark-number(chapter) + h(1em) + smallcaps(chapter.body))
  }

  running-band({
    mark
    v(3.5pt, weak: true)
    line(length: 100%, stroke: 0.4pt)
  })
}

#let running-foot() = context {
  if is-blank-page() {
    return
  }
  let folio = counter(page).display()
  let outer = align(if is-recto() { right } else { left }, folio)
  if ruled-pages.get() and not chapter-context().opens-here {
    // The `Ruled` foot follows the head out into the marginal-note strip.
    running-band(outer)
  } else {
    outer
  }
}
