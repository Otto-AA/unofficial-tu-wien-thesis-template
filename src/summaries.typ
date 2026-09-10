// The summary chapters of the front matter.
//
// An Austrian thesis is written in one language and summarised in both, so each of these
// takes the language it is written in rather than inheriting the document's. That is what
// makes the four usual arrangements possible:
//
//     English only          #abstract("en")[…]
//     English, German too   #abstract("en")[…]  #abstract("de")[…]
//     German, English too   #abstract("de")[…]  #abstract("en")[…]
//     German only           #abstract("de")[…]
//
// The heading follows the language, so `abstract("de")` is titled "Kurzfassung" and
// `acknowledgements("de")` "Danksagung", exactly as the class names them.

#import "i18n/i18n.typ": t

#let summary-chapter(lang, key, body) = {
  set text(lang: lang)
  heading(level: 1, numbering: none, outlined: true, t(lang, key))
  body
}

/// "Abstract" in English, "Kurzfassung" in German.
#let abstract(lang, body) = summary-chapter(lang, "abstract-chapter", body)

/// "Acknowledgements" in English, "Danksagung" in German.
#let acknowledgements(lang, body) = summary-chapter(lang, "acknowledgements-chapter", body)

/// The appendix the declaration of authorship refers to, listing the generative AI tools
/// that were used.
#let ai-tools(lang, body) = summary-chapter(lang, "ai-tools-chapter", body)
