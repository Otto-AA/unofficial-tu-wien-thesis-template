// Small shared helpers.

#import "layout.typ": two-sided

/// Render a person as "Pre-title Name, Post-title", skipping the parts that are absent.
///
/// A person is a dictionary with a `name` and the optional keys `pre-title` and
/// `post-title`, matching how vutinfth's \setauthor and friends take their arguments.
#let person-name(person) = {
  if person == none {
    return []
  }
  let pre = person.at("pre-title", default: "")
  let post = person.at("post-title", default: "")
  let parts = ()
  if pre != "" {
    parts.push(pre)
  }
  parts.push(person.at("name", default: ""))
  let rendered = parts.join(" ")
  if post != "" {
    rendered + ", " + post
  } else {
    rendered
  }
}

/// A rule to sign above, with the signatory's name centred underneath.
#let signature-line(name, width: 100%) = align(center)[
  #line(length: width, stroke: 0.5pt)
  #v(2.5pt, weak: true)
  #name
]

/// True on right-hand (recto) pages. Typst counts physical pages, and the document opens on
/// a recto, so odd page numbers are the right-hand ones. Printed on one side there is no
/// left-hand page, and everything follows the right-hand arrangement.
#let is-recto() = not two-sided.get() or calc.odd(here().page())
