#!/usr/bin/env python
"""Check the built thesis against the metrics measured from the LaTeX reference.

These are the numbers that make the port recognisable as a vutinfth document: the type
block, the running-head band, the title page's font sizes and the chapter opener. Run it
after changing anything in src/.

    ./.venv/Scripts/python.exe tests/check_layout.py     # Windows / Git Bash
    ./.venv/bin/python tests/check_layout.py             # macOS / Linux
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

import pymupdf  # noqa: E402

from build import DEFAULT_INPUT, DEFAULT_OUTPUT, build  # noqa: E402

TOLERANCE = 2.0  # points

failures: list[str] = []


def check(label: str, actual: float, expected: float, tolerance: float = TOLERANCE) -> None:
    ok = abs(actual - expected) <= tolerance
    print(f"  {'ok  ' if ok else 'FAIL'} {label:<44} {actual:8.2f}  (expected {expected:.2f})")
    if not ok:
        failures.append(label)


def spans(page):
    for block in page.get_text("dict")["blocks"]:
        if block["type"] != 0:
            continue
        for line in block["lines"]:
            for span in line["spans"]:
                if span["text"].strip():
                    yield span


def find(page, text):
    for span in spans(page):
        if text in span["text"]:
            return span
    raise AssertionError(f"{text!r} not found on the page")


def horizontal_rules(page, above=None):
    out = []
    for drawing in page.get_drawings():
        rect = drawing["rect"]
        if rect.height < 2 and (above is None or rect.y0 < above):
            out.append(rect)
    return out


def find_chapter_opener(doc):
    """The first page carrying the oversized chapter numeral."""
    for number, page in enumerate(doc):
        if any(span["size"] > 60 for span in spans(page)):
            return number
    raise AssertionError("no chapter opener found")


def main() -> int:
    build(DEFAULT_INPUT, DEFAULT_OUTPUT)
    doc = pymupdf.open(DEFAULT_OUTPUT)
    opener_index = find_chapter_opener(doc)

    print("\npage geometry")
    page = doc[opener_index]  # first chapter opener, a recto
    check("paper width", page.rect.width, 595.28)
    check("paper height", page.rect.height, 841.89)

    print("\ntype block (recto)")
    body = doc[opener_index + 1]  # the verso that follows it
    line_starts = [s["bbox"][0] for s in spans(body) if 90 < s["bbox"][1] < 700]
    check("verso left edge = outer margin", min(line_starts), 107.15)

    print("\nrunning head and folio (verso)")
    rules = horizontal_rules(body, above=95)
    assert rules, "no head rule found"
    check("head rule left edge", rules[0].x0, 65.48)
    check("head rule right edge", rules[0].x1, 523.84)
    check("head rule baseline", rules[0].y0, 81.43)
    folio = min((s for s in spans(body) if s["bbox"][1] > 700), key=lambda s: s["bbox"][0])
    check("folio at the band's outer edge", folio["bbox"][0], 65.48)

    print("\ntitle page")
    title_page = doc[0]
    for label, text, size in (
        ("title size", "Titel der Arbeit", 28.39),
        ("subtitle size", "Optionaler Untertitel", 18.93),
        ("thesis type size", "DIPLOMARBEIT", 16.09),
        ("curriculum size", "Medieninformatik", 13.25),
        ("advisor block size", "Betreuung", 10.41),
    ):
        check(label, find(title_page, text)["size"], size, tolerance=0.1)
    check("title centred on the type block", find(title_page, "Titel der Arbeit")["bbox"][0], 197.0)
    signature_rules = [r for r in horizontal_rules(title_page) if 700 < r.y0 < 760]
    check("signature rules", len(signature_rules), 2, tolerance=0)
    check("outer signature rule ends at margin", max(r.x1 for r in signature_rules), 527.24)

    print("\nchapter opener")
    opener = doc[opener_index]
    check("small-caps 'Chapter' ends at type block", find(opener, "Chapter")["bbox"][2], 488.12)
    numeral = max(spans(opener), key=lambda s: s["size"])
    check("numeral size", numeral["size"], 81.0, tolerance=0.5)
    check("numeral hangs into the margin", numeral["bbox"][2], 537.95)
    blocks = [d["rect"] for d in opener.get_drawings() if d.get("fill") and d["rect"].width > 20]
    assert blocks, "no chapter block found"
    check("block starts", blocks[0].x0, 550.55)
    check("block runs to the paper edge", blocks[0].x1, 595.28)
    check("block height", blocks[0].height, 51.03)

    print("\nbody text")
    tops = sorted({round(s["bbox"][1], 2) for s in spans(body) if 100 < s["bbox"][1] < 300})
    steps = [round(b - a, 2) for a, b in zip(tops, tops[1:])]
    check("baseline distance", min(steps), 13.55, tolerance=0.1)

    print("\nblank pages carry no folio")
    for number in (2, 4):
        text = doc[number - 1].get_text().strip()
        ok = text == ""
        print(f"  {'ok  ' if ok else 'FAIL'} page {number} is blank")
        if not ok:
            failures.append(f"page {number} not blank")

    print()
    if failures:
        print(f"{len(failures)} check(s) failed: {', '.join(failures)}")
        return 1
    print("all checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
