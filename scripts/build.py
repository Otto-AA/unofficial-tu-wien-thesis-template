#!/usr/bin/env python
"""Build the template and, optionally, rasterise the result.

The Typst compiler and the PDF tooling both come from the project virtual environment, so
nothing has to be installed system-wide:

    python -m venv .venv
    ./.venv/Scripts/python.exe -m pip install -r requirements.txt   # Windows / Git Bash
    ./.venv/bin/python -m pip install -r requirements.txt           # macOS / Linux

Usage:
    python scripts/build.py                     # build template/thesis.typ -> build/thesis.pdf
    python scripts/build.py --render            # also rasterise every page to build/pages/
    python scripts/build.py --render --pages 1-8

`template/` imports the library through `@preview/definitely-not-tuw-thesis`, because that is
what a project created with `typst init` gets. To build from a checkout without publishing or
installing the package first, the template is staged into build/ with those imports pointed
at src/ — the same substitution the compile workflow makes.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TEMPLATE_DIR = ROOT / "template"
FONT_DIR = TEMPLATE_DIR / "fonts"
STAGE_DIR = ROOT / "build" / "template"
DEFAULT_INPUT = TEMPLATE_DIR / "thesis.typ"
DEFAULT_OUTPUT = ROOT / "build" / "thesis.pdf"

PACKAGE_IMPORT = re.compile(r'@preview/definitely-not-tuw-thesis:[0-9]+\.[0-9]+\.[0-9]+')
LIBRARY = "/src/lib.typ"


def stage(source: Path) -> Path:
    """Copy the template into build/ with its package imports pointed at src/."""
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)
    shutil.copytree(TEMPLATE_DIR, STAGE_DIR)
    for path in STAGE_DIR.rglob("*.typ"):
        text = path.read_text(encoding="utf-8")
        rewritten = PACKAGE_IMPORT.sub(LIBRARY, text)
        if rewritten != text:
            path.write_text(rewritten, encoding="utf-8", newline="\n")
    return STAGE_DIR / source.relative_to(TEMPLATE_DIR)


def parse_pages(spec: str, last: int) -> list[int]:
    pages: list[int] = []
    for part in spec.split(","):
        if "-" in part:
            start, end = part.split("-")
            pages.extend(range(int(start), int(end) + 1))
        else:
            pages.append(int(part))
    return [p for p in pages if 1 <= p <= last]


def build(source: Path, output: Path) -> None:
    import typst

    output.parent.mkdir(parents=True, exist_ok=True)
    entry = stage(source) if TEMPLATE_DIR in source.parents else source
    typst.compile(str(entry), output=str(output), root=str(ROOT), font_paths=[str(FONT_DIR)])
    print(f"built {output.relative_to(ROOT)}")


def render(pdf: Path, outdir: Path, pages: str | None, dpi: int) -> None:
    import pymupdf

    doc = pymupdf.open(pdf)
    outdir.mkdir(parents=True, exist_ok=True)
    selected = parse_pages(pages, doc.page_count) if pages else range(1, doc.page_count + 1)
    for number in selected:
        image = outdir / f"p{number:02d}.png"
        doc[number - 1].get_pixmap(dpi=dpi).save(image)
    print(f"rendered {len(list(selected))} page(s) to {outdir.relative_to(ROOT)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--render", action="store_true", help="rasterise the pages to PNG")
    parser.add_argument("--pages", help="page selection for --render, e.g. 1-8,15")
    parser.add_argument("--dpi", type=int, default=110)
    args = parser.parse_args()

    # An output path given on the command line may be relative to the caller's directory.
    output = args.output.resolve()
    build(args.source, output)
    if args.render:
        render(output, output.parent / "pages", args.pages, args.dpi)
    return 0


if __name__ == "__main__":
    sys.exit(main())
