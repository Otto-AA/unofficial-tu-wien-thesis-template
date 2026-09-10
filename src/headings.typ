// Headings.
//
// memoir's `veelo` chapter style opens a chapter on a right-hand page with the word
// "Chapter" in small caps, an oversized numeral that hangs into the outer margin, and a
// solid block that runs off the edge of the paper. The chapter title follows, flush right.
// Unnumbered chapters — abstract, declaration, back matter — keep the flush-right title
// but drop the numeral and the block.
//
// Sections and below are ordinary flush-left headings in the sizes memoir resolves for an
// 11pt base.

#import "layout.typ": *
#import "fonts.typ": *
#import "i18n/i18n.typ": t
#import "page-style.typ": clear-to-recto

// Horizontal make-up of the chapter opener, measured from the reference PDF.
#let chapter-name-gap = 9.36pt // between "Chapter" and the numeral
#let chapter-number-gap = 12.6pt // between the numeral and the block
#let chapter-block-width = 44.7pt // the visible part; the rest runs off the paper
#let chapter-block-height = 51pt // veelo sizes it to the height of the numeral

// memoir's three chapter skips: above the opener, between opener and title, below title.
#let before-chapter-skip = 54pt
#let mid-chapter-skip = 16.5pt
#let after-chapter-skip = 44.9pt

// An unnumbered chapter has no opener, so its title starts from the top of the type block.
#let plain-chapter-skip = 74.6pt

#let chapter-title-leading = 5.1pt // for a chapter title that runs to two lines

// memoir separates a section number from its title by a fixed quad.
#let section-number-gap = 1.125em

/// The "Chapter N ▉" line. Everything past the type block deliberately overflows into the
/// outer margin, so this must sit at the left edge of the type block. Built in code rather
/// than markup, because a stray space at 81pt would be very visible.
#let chapter-opener(lang, number) = {
  set text(size: chapter-name-size, weight: "regular")
  box(width: body-width + margin-outside, {
    h(1fr)
    smallcaps(t(lang, "chapter"))
    h(chapter-name-gap)
    text(size: chapter-number-size, number)
    h(chapter-number-gap)
    box(fill: black, width: chapter-block-width, height: chapter-block-height)
  })
}

/// Show rules for every heading level.
#let heading-styles(lang, body) = {
  show heading: set text(hyphenate: false, weight: "bold")

  show heading.where(level: 1): it => {
    // A chapter always opens on a right-hand page, which is what puts the numeral and the
    // block in the outer margin.
    clear-to-recto

    // Figures, tables and equations are numbered within the chapter, so their counters
    // restart here.
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)

    let title = align(right, text(size: chapter-title-size, it.body))

    // The block spans the type block, so the title can align with its right edge, and it
    // carries the space below the chapter so that it composes with whatever follows
    // instead of adding to it.
    block(width: 100%, below: after-chapter-skip, {
      set par(justify: false, spacing: 0pt, leading: chapter-title-leading)

      // Strong spacing, because Typst drops weak spacing at the top of a page.
      if it.numbering == none {
        v(plain-chapter-skip)
        title
      } else {
        v(before-chapter-skip)
        chapter-opener(lang, counter(heading).display("1"))
        v(mid-chapter-skip)
        title
      }
    })
  }

  let section-heading(size, above, below) = it => block(
    above: above,
    below: below,
    text(size: size, {
      counter(heading).display(it.numbering)
      h(section-number-gap)
      it.body
    }),
  )

  show heading.where(level: 2): section-heading(section-size, 24pt, 11pt)
  show heading.where(level: 3): section-heading(subsection-size, 18pt, 8pt)
  show heading.where(level: 4): section-heading(subsubsection-size, 15pt, 7pt)

  body
}
