#import "@preview/definitely-not-tuw-thesis:0.3.0": *

#show: thesis.with(
  // Language the thesis is written in, and the language it is additionally summarised in.
  //
  //   lang: "en", secondary-lang: "de"    English thesis, German Kurzfassung as well
  //   lang: "de", secondary-lang: "en"    German thesis, English abstract as well
  //   lang: "en", secondary-lang: none    English only
  //   lang: "de", secondary-lang: none    German only
  //
  // A title page is printed for each language in use, German first.
  lang: "en",
  secondary-lang: "de",

  title: (
    en: "Title of the Thesis",
    de: "Titel der Arbeit",
  ),
  subtitle: (
    en: "Optional Subtitle of the Thesis",
    de: "Optionaler Untertitel der Arbeit",
  ),

  // The thesis type decides both the name on the cover and the degree awarded, exactly as
  // \setthesis, \setmasterdegree and \setdoctordegree do in the LaTeX class:
  //
  //   "bachelor"                            BACHELORARBEIT, Bachelor of Science
  //   "master" + master-degree "dipl."      DIPLOMARBEIT,   Diplom-Ingenieur(in)
  //   "master" + master-degree "master"     MASTERARBEIT,   Master of Science
  //   "master" + master-degree "rer.nat."   MASTERARBEIT,   Magister/Magistra der Naturwissenschaften
  //   "master" + "rer.soc.oec."             MASTERARBEIT,   … der Sozial- und Wirtschaftswissenschaften
  //   "doctor" + doctor-degree "techn."     DISSERTATION,   Doktor(in) der Technischen Wissenschaften
  //   "doctor" + "rer.nat." / "rer.soc.oec." likewise
  //
  // Most of those names are gendered, so the author below carries a `gender`.
  thesis-type: "master",
  master-degree: "dipl.",
  // doctor-degree: "techn.",
  curriculum: (
    en: "Media Informatics and Visual Computing",
    de: "Medieninformatik und Visual Computing",
  ),

  author: (
    pre-title: "Pretitle",
    name: "Forename Surname",
    post-title: "Posttitle",
    student-number: "0123456",
    gender: "female",
  ),
  advisor: (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
  // second-advisor: (name: "Forename Surname"),
  assistants: (
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
    (pre-title: "Pretitle", name: "Forename Surname", post-title: "Posttitle"),
  ),
  // A dissertation names its reviewers instead of assistants. They sign above the author,
  // who then signs alone — a thesis is countersigned by its advisor, a dissertation is not.
  // reviewers: ((name: "Forename Surname"), (name: "Forename Surname")),

  // The institution under the title page. Defaults to TU Wien; override for another one.
  // university: (name: "…", contact: ("…", "…")),

  // "alpha" gives BibTeX's [Lam94] labels, "numeric" gives [1], and "acm" and "apa" the
  // respective house styles. Any CSL style name Typst knows also works.
  reference-style: "alpha",

  // Printed on both sides, as a bound thesis is. Set to false for single-sided printing:
  // even margins, no blank pages, every page laid out like a right-hand one.
  two-sided: true,

  // Acronyms and glossary entries, declared here the way \newacronym and \newglossaryentry
  // declare them. Use them in the text with gls(), and list them at the back with
  // acronyms() and glossary().
  terms: (
    ctan: (short: "CTAN", long: "Comprehensive TeX Archive Network"),
    pdf: (short: "PDF", long: "Portable Document Format"),
    wysiwyg: (short: "WYSIWYG", long: "What You See Is What You Get"),
    editor: (
      name: "editor",
      description: "A text editor is a type of program used for editing plain text files.",
    ),
  ),

  keywords: ("a", "list", "of", "keywords"),
  date: datetime(year: 2001, month: 1, day: 1),
)

// Front matter. Each summary carries the language it is written in, so the heading is
// "Danksagung" or "Acknowledgements", "Kurzfassung" or "Abstract" accordingly. Drop the
// ones you do not need — a single-language thesis keeps only one of each.
#include "content/summaries.typ"

#toc("en")

#show: main-matter

#include "content/introduction.typ"
#include "content/related-work.typ"
#include "content/template-tour.typ"

#show: back-matter

// The appendix the declaration of authorship refers to.
#ai-tools("en")[
  List here every generative AI tool used in the making of this thesis, where it was used,
  and — for passages taken over without substantial changes — the prompts and the product
  name and version of the application.
]

#list-of-figures("en")
#list-of-tables("en")
#list-of-algorithms("en")
#list-of-listings("en")

#acronyms("en")
#glossary("en")
#index("en")

#bibliography("refs.bib")
