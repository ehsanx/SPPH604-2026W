#!/usr/bin/env python3
"""Render every student-facing course document to HTML and PDF.

WHY THIS EXISTS
---------------
Course materials in this repository are authored in Markdown and Quarto. Students
should never need R, Quarto, Pandoc or LaTeX installed merely to READ them, so a
compiled HTML and PDF ship beside every source file.

This script is what produced them. It is a small, self-contained rendering wrapper
for this public repository: it renders the sources that are here, using tools that
are freely available, and it does nothing else. It is not the instructor's course
build system, which is deliberately not part of this repository.

You do not need to run this. The compiled artifacts are already committed. Run it
only if you have edited a source file and want to regenerate what sits beside it.

REQUIREMENTS
------------
    pandoc          (HTML and PDF for .md sources)
    xelatex         (PDF engine, e.g. from TeX Live or TinyTeX)
    quarto          (the reveal.js lecture decks in lectures/slides/)

USAGE
-----
    python tools/render_public.py            # render everything that is stale
    python tools/render_public.py --force    # render everything
    python tools/render_public.py --check    # report staleness, render nothing

WHAT IT RENDERS
---------------
    practice/P*.md        -> .html + .pdf      the P1-P5 project increments
    labs/L*.md            -> .html + .pdf      the L0-L6 lab handouts
    lectures/Week*.md     -> .html + .pdf      the weekly lecture plans
    milestones/M*.md      -> .html + .pdf      the M0-M4 assignment briefs
    lectures/slides/*.qmd -> .html + .pdf      the reveal.js decks, plus a static
                                               slide PDF via Quarto's beamer output

Both HTML outputs are self-contained: images, styles and fonts are embedded, so a
downloaded file opens correctly with no network access and no local path
dependencies.
"""

import argparse
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (directory, filename prefix, extension) for each family of student-facing source.
FAMILIES = [
    ('practice', 'P', '.md'),
    ('labs', 'L', '.md'),
    ('lectures', 'Week', '.md'),
    ('milestones', 'M', '.md'),
]
DECKS = os.path.join('lectures', 'slides')


def sh(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=1800)


def stale(src, out):
    return not os.path.exists(out) or os.path.getmtime(src) > os.path.getmtime(out) + 1


def sources():
    """Every student-facing source, as (abs path, kind)."""
    found = []
    for d, prefix, ext in FAMILIES:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full):
            continue
        for f in sorted(os.listdir(full)):
            if f.startswith(prefix) and f.endswith(ext):
                found.append((os.path.join(full, f), 'md'))
    deck_dir = os.path.join(ROOT, DECKS)
    if os.path.isdir(deck_dir):
        for f in sorted(os.listdir(deck_dir)):
            if f.endswith('.qmd'):
                found.append((os.path.join(deck_dir, f), 'deck'))
    return found


def render_md_html(path):
    d, f = os.path.dirname(path), os.path.basename(path)
    cmd = ['pandoc', f, '-o', f[:-3] + '.html',
           '--standalone', '--embed-resources',
           '--metadata', 'title=' + f[:-3].replace('_', ' '),
           '--toc', '--toc-depth=2']
    return sh(cmd, d)


def render_md_pdf(path):
    d, f = os.path.dirname(path), os.path.basename(path)
    cmd = ['pandoc', '--pdf-engine=xelatex', '-V', 'geometry:margin=1in',
           f, '-o', f[:-3] + '.pdf']
    pre = os.path.join(d, 'preamble.tex')
    if os.path.exists(pre):
        cmd += ['-H', 'preamble.tex']
    return sh(cmd, d)


def render_deck_html(path):
    d, f = os.path.dirname(path), os.path.basename(path)
    return sh(['quarto', 'render', f, '--to', 'revealjs'], d)


def render_deck_pdf(path):
    """A static slide PDF, produced by Quarto's beamer output rather than by
    screenshotting the reveal.js deck. Speaker notes are not included."""
    d, f = os.path.dirname(path), os.path.basename(path)
    return sh(['quarto', 'render', f, '--to', 'beamer'], d)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--force', action='store_true', help='render even if current')
    ap.add_argument('--check', action='store_true', help='report only, render nothing')
    args = ap.parse_args()

    jobs, built, failed, current = [], 0, [], 0
    for src, kind in sources():
        base = src[:-4] if kind == 'deck' else src[:-3]
        for ext, fn in ((('.html', render_deck_html), ('.pdf', render_deck_pdf))
                        if kind == 'deck' else
                        (('.html', render_md_html), ('.pdf', render_md_pdf))):
            out = base + ext
            if args.force or stale(src, out):
                jobs.append((src, out, fn))
            else:
                current += 1

    rel = lambda p: os.path.relpath(p, ROOT).replace(os.sep, '/')
    if args.check:
        print('%d current, %d stale or missing' % (current, len(jobs)))
        for src, out, _ in jobs:
            print('   STALE %s -> %s' % (rel(src), rel(out)))
        return 0

    for src, out, fn in jobs:
        r = fn(src)
        if r.returncode == 0 and os.path.exists(out):
            built += 1
            print('   built %s' % rel(out))
        else:
            failed.append((rel(out), (r.stderr or r.stdout or '').strip()[:200]))
            print('   FAILED %s' % rel(out))

    print()
    print('%d built, %d already current, %d failed' % (built, current, len(failed)))
    for out, err in failed:
        print('   %s\n      %s' % (out, err))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
