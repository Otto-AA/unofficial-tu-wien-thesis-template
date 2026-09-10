// The three divisions of the thesis, mirroring LaTeX's \frontmatter, \mainmatter and
// \backmatter, plus the appendix switch.
//
// Each one is used as a `show` rule, so everything after it in the document body picks up
// its numbering and page style:
//
//     #show: front-matter
//     …
//     #show: main-matter

#import "page-style.typ": clear-to-recto, ruled-pages

/// Roman folios, unnumbered chapters, no running head.
#let front-matter(body) = {
  set page(numbering: "i")
  counter(page).update(1)
  set heading(numbering: none)
  ruled-pages.update(false)
  body
}

/// Arabic folios restarting at 1, numbered chapters, running heads.
#let main-matter(body) = {
  // \mainmatter clears to a right-hand page before restarting the folios, so that the
  // first chapter really is page 1.
  clear-to-recto
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")
  counter(heading).update(0)
  ruled-pages.update(true)
  body
}

/// Continues the arabic folios but drops chapter numbering and running heads again.
#let back-matter(body) = {
  // ackmatter clears to a right-hand page first, so the change of page style lands on a
  // page boundary instead of halfway down the last page of the main matter.
  clear-to-recto
  set heading(numbering: none)
  ruled-pages.update(false)
  body
}

/// Letters the chapters A, B, C … and restarts the counter.
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}
