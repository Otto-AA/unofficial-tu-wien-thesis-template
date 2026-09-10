# Contributing

Any improvements and fixes are welcome! If you notice any inconsistencies with the official
template, please open an issue.

## Development setup

This project uses [Just](https://just.systems/man/en/) to have some convenience scripts
(similar to `make`). You can view those in the [Justfile](./Justfile) and list them with
running `just`.

The build and the tests run through the `typst` Python package, so they need no Typst binary
and no global installs — a virtual environment in the project root is enough:

```bash
python -m venv .venv
./.venv/Scripts/python.exe -m pip install -r requirements.txt   # Windows / Git Bash
./.venv/bin/python -m pip install -r requirements.txt           # macOS / Linux
```

Then `just build` compiles the template to `build/thesis.pdf`, and `just render` also
rasterises every page to `build/pages/` so a change can be looked at.

`template/` imports the library through `@preview/definitely-not-tuw-thesis`, because that
is what a project created with `typst init` gets. Building from a checkout stages the
template into `build/` with those imports pointed at `src/`, so no publishing or installing
is needed first.

`example.pdf` at the repository root is the rendered template, committed so that a change
can be reviewed without building. Regenerate it with `just example` whenever the output
changes.

## Testing

`just test` runs two suites:

- `tests/check_layout.py` asserts the metrics measured from `example-ref.pdf`, the reference
  output shipped with the [official template](https://gitlab.com/ThomasAUZINGER/vutinfth):
  the type block, the running-head band, the title page's font sizes and the chapter opener.
  These are the numbers that make the document recognisable as a vutinfth thesis, so a
  change that moves them should be deliberate.
- `tests/check_variants.py` compiles the template once per language arrangement and once per
  reference style, and checks what comes out.

Both print every check with the value it found and the value it expected, so a failure shows
how far off it is rather than just that it broke.

The suites deliberately assert on numbers rather than compare rendered images, because the
rendering depends on the fonts in `template/fonts/` and on the Typst version, while the
metrics do not.
