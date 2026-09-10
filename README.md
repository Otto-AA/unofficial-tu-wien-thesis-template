# Unofficial thesis template for informatics at TU Wien

A Typst template for theses at TU Wien Informatics, following
[`vutinfth`](https://gitlab.com/ThomasAUZINGER/vutinfth), the official LaTeX class by
Thomas Auzinger, as closely as Typst allows: the same page geometry, the same fonts at the
same sizes, memoir's `veelo` chapter openers, the `Ruled` running heads that reach into the
outer margin, and the official title page down to the position of the signature rules.

An example thesis can be viewed here:
https://otto-aa.github.io/definitely-not-tuw-thesis/thesis.pdf

The same document is committed as [`example.pdf`](./example.pdf), so the output can be read
without building anything. Regenerate it with `just example` after changing the template.

## Usage

```bash
typst init @preview/definitely-not-tuw-thesis
```

Then compile with the bundled fonts on the search path:

```bash
typst compile --font-path fonts thesis.typ
```

### Template overview

After setting up the template you will have:

- `thesis.typ` — the metadata for the title pages, the language arrangement, the reference
  style, and the overall structure
- `content/summaries.typ` — Danksagung, Acknowledgements, Kurzfassung, Abstract
- `content/introduction.typ`, `content/related-work.typ` — your chapters
- `content/template-tour.typ` — a chapter exercising every element the template supports;
  read it once, then delete it
- `refs.bib` — your references
- `fonts/` — the faces the LaTeX class selects, so they need not be installed

## Configuration

Everything a thesis sets lives at the top of `thesis.typ`.

### Language

An Austrian thesis is written in one language and usually summarised in both. `lang` is the
language of the thesis, `secondary-lang` the one it is additionally summarised in — or
`none`. A title page is printed for each language in use, German first.

| | `lang` | `secondary-lang` |
| --- | --- | --- |
| English, with a German Kurzfassung | `"en"` | `"de"` |
| German, with an English abstract | `"de"` | `"en"` |
| English only | `"en"` | `none` |
| German only | `"de"` | `none` |

The summaries carry the language they are written in, so the heading follows:

```typst
#acknowledgements("de")[Ihr Text hier.]
#abstract("en")[Enter your text here.]     // titled "Abstract"
#abstract("de")[Ihr Text hier.]            // titled "Kurzfassung"
```

The declaration of authorship, the running heads and the contents follow `lang`. A title page
is printed for each language in use, German first — the order the class's own example uses.
Pass `title-page-languages: ("en", "de")` to lead with the thesis's own language instead, or
to print only one.

### Thesis type and degree

The type of thesis decides both the name on the cover and the degree awarded, and most
degrees are gendered — so neither is typed out. Set `thesis-type`, the degree variant, and
the author's `gender`, exactly as `\setthesis`, `\setmasterdegree` and `\setdoctordegree`
do in the class:

| `thesis-type` | variant | cover | degree |
| --- | --- | --- | --- |
| `"bachelor"` | — | BACHELORARBEIT | Bachelor of Science |
| `"master"` | `master-degree: "dipl."` | DIPLOMARBEIT | Diplom-Ingenieur / Diplom-Ingenieurin |
| `"master"` | `master-degree: "master"` | MASTERARBEIT | Master of Science |
| `"master"` | `master-degree: "rer.nat."` | MASTERARBEIT | Magister / Magistra der Naturwissenschaften |
| `"master"` | `master-degree: "rer.soc.oec."` | MASTERARBEIT | Magister / Magistra der Sozial- und Wirtschaftswissenschaften |
| `"doctor"` | `doctor-degree: "rer.nat."` | DISSERTATION | Doktor / Doktorin der Naturwissenschaften |
| `"doctor"` | `doctor-degree: "techn."` | DISSERTATION | Doktor / Doktorin der Technischen Wissenschaften |
| `"doctor"` | `doctor-degree: "rer.soc.oec."` | DISSERTATION | Doktor / Doktorin der Sozial- und Wirtschaftswissenschaften |

A mistyped variant is an error naming the ones that exist, and a gendered degree without a
`gender` is an error too, rather than a silently wrong cover. `degree:` overrides the
derivation for an award the class does not list.

A dissertation is laid out differently, and the template follows: it names no curriculum,
lists no assistants, is reviewed by the people in `reviewers`, and is signed by its author
alone where a thesis is countersigned by its advisor.

### People and data

`author`, `advisor`, `second-advisor`, `assistants` and `reviewers` take the same shape as
the class's `\setauthor` and friends — a `name` with optional `pre-title` and `post-title`.
The author additionally carries a `student-number` and a `gender`. `title`, `subtitle` and
`curriculum` take one variant per language.
`date` is a `datetime`, rendered the way `datetime2` renders it: "1. Jänner 2001" in German,
"January 1, 2001" in English. The institution under the title page is `university`,
defaulting to TU Wien.

### Printing

`two-sided` defaults to `true`, as a bound thesis is printed — the margins alternate 25.2mm
and 37.8mm so the binding edge is wider, chapters open on a right-hand page, and the page in
between is left blank and unnumbered. Set it to `false` for the class's `onside` layout:
margins split evenly at 31.5mm, no page is left blank, and every page is laid out the way a
right-hand page is. The title pages keep their own symmetric margins either way.

### References

`reference-style` defaults to `"alpha"` — BibTeX's alpha style, whose labels are built from
the author and the year, as in `[Lam94]`. `"numeric"` gives `[1]`, and `"acm"` and `"apa"`
the respective house styles. Any CSL style name Typst knows also works. It is applied as a
set rule, so `#bibliography("refs.bib")` needs no arguments, and a `style:` given there
still wins.

## Writing

Beyond ordinary Typst, the template adds:

| | |
| --- | --- |
| `subfigure`, `subfigure-row` | panels side by side, captioned "(a)" and referenced "Figure 3.1a" |
| `algorithm` | ruled, line-numbered pseudo code in the manner of `algorithm2e` |
| `listing` | a numbered, captioned code block |
| `flex-caption(long, short)` | LaTeX's `\caption[short]{long}` — the short form appears in the lists |
| `toc`, `list-of-figures`, `list-of-tables`, `list-of-algorithms`, `list-of-listings` | |
| `front-matter`, `main-matter`, `back-matter`, `appendix` | applied as `#show:` rules |
| `ai-tools` | the appendix the declaration of authorship refers to |
| `gls`, `acrshort`, `acrlong`, `acrfull` | acronyms and glossary terms |
| `index-entry` | mark a place for the index |
| `acronyms`, `glossary`, `index` | the three lists at the back |

Figures, tables, equations, algorithms and listings are numbered within their chapter and
their counters restart with it.

### Acronyms, a glossary and an index

Terms are declared once, on `thesis`, the way `\newacronym` and `\newglossaryentry` declare
them — an acronym carries a `short` and a `long` form, a glossary entry a `name` and a
`description`:

```typst
terms: (
  pdf: (short: "PDF", long: "Portable Document Format"),
  editor: (name: "editor", description: "A program for editing plain text."),
),
```

`gls("pdf")` then spells the acronym out on its first use — "Portable Document Format
(PDF)" — and gives the abbreviation after that, as `\gls` does. `plural` and `capitalize`
cover `\glspl`, `\Gls` and `\Glspl`; `acrshort`, `acrlong` and `acrfull` force one form.
`index-entry("term")` marks a place for the index, like `\index`.

`acronyms()`, `glossary()` and `index()` print the three lists at the back. Each lists only
the terms actually used, and collects the pages they appear on — the job `makeindex` does
for LaTeX, except that nothing has to be run twice.

Code is syntax-highlighted by default. For the plain black of the LaTeX original, add
`#show raw: set text(fill: black)` to `thesis.typ`.

### Styling

To adapt the styling, remove the `show: …` rules in `thesis.typ` and replace them with your
own, or simply add further `show: …` rules after them.

## Fonts

`template/fonts/` carries the faces the LaTeX class selects, so that a thesis looks right
without installing anything:

| File | Stands in for | Licence |
| --- | --- | --- |
| `texgyreheros-*.otf` | `helvet` (URW Nimbus Sans), the title page | GUST Font License |
| `texgyrecursor-*.otf` | `courier` (URW Nimbus Mono), verbatim text | GUST Font License |
| `lmsans10-*.otf` | Latin Modern Sans, the address line | GUST Font License |

The body font, New Computer Modern, ships with Typst itself, so the body text needs no font
path at all. Each stack ends in a widely available substitute, so a document still compiles
without `--font-path fonts`; only the title page and the address line fall back.

## How closely it matches

Measured against `example-ref.pdf`, the reference output shipped with the LaTeX class, every
horizontal position on the title page lands within half a point and the vertical positions
within about two. The chapter opener — the small-caps "Chapter", the oversized numeral
hanging into the margin and the block that runs off the paper — matches to within a point,
as do the running heads, the folios and the table of contents columns.

Two differences are inherent rather than incidental:

- **Font metrics.** New Computer Modern is the maintained successor of Latin Modern. Its
  bold is about 2% wider than the Type 1 Latin Modern the reference was built with, and its
  small caps about 7% narrower, so individual words differ slightly in width even though
  sizes and positions agree.
- **Line breaking.** Typst and TeX break paragraphs differently, so a given paragraph will
  not always occupy the same number of lines.

## Layout

```
src/
  lib.typ            the thesis() entry point and the document-wide defaults
  layout.typ         page geometry, derived from the geometry package's defaults
  fonts.typ          font stacks and the size scale vutinfth defines
  title-page.typ     \AddTitlePage
  statement-page.typ \AddStatementPage
  summaries.typ      Kurzfassung, Abstract, Danksagung, Acknowledgements
  headings.typ       the veelo chapter opener and the section levels
  page-style.typ     running heads, folios, and \cleardoublepage
  floats.typ         sub-figures, algorithms, listings, flexible captions
  outlines.typ       the table of contents and the four lists
  matter.typ         \frontmatter, \mainmatter, \backmatter, appendix
  reference-lists.typ acronyms, the glossary and the index
  degrees.typ        the degree each thesis type awards
  i18n/              the class's own German and English wording
template/            what `typst init` gives you, fonts included
tests/               regression checks against the reference metrics
```

## Contributing

I guess there are many ways to improve this template, feel free to do so and submit issues
and PRs! More information at [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

The code is licensed under MIT-0. The 'TU Wien Informatics' logo and signet are copyright of
the TU Wien. The fonts in `template/fonts/` are distributed under the
[GUST Font License](https://www.gust.org.pl/projects/e-foundry/licenses).

## Acknowledgments

This work is based on the [official template](https://gitlab.com/ThomasAUZINGER/vutinfth)
maintained by Thomas Auzinger. The repository structure is based on
[typst-package-template](https://github.com/typst-community/typst-package-template).
