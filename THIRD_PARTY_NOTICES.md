# Third-party notices

The rendered HTML in this repository is self-contained: every deck and notebook carries its
JavaScript, CSS and web fonts inline rather than fetching them from a CDN. That vendored
front-end code belongs to its own authors and is **not** covered by this repository's CC BY 4.0
grant (see [`LICENSE.md`](LICENSE.md)). This file records the notices those components carry.

Seventeen rendered `.html` files are affected:

| Group | Files | Where |
|---|---|---|
| reveal.js decks | 7 | `lectures/slides/Week1…Week7_*_slides.html` |
| Quarto HTML notebooks | 8 | `examples/{M1,M3,M4,P1,P2,P3,P4,P5}/*.html` |
| Reproduced tables | 2 | `reproduction/output/tables/table{1,2}_reproduced.html` |

Within each group the bundled components are identical across files, so the per-component
sections below say which group a component appears in rather than listing all seventeen paths.

**How this list was made.** Each component was found by searching the bundled HTML itself for
licence headers and library banners; the copyright line and licence name are quoted verbatim
from those files. Where minification stripped a banner, the authoritative text is taken from
the copy shipped by the local toolchain that produced the file — Quarto 1.7.31
(`…/Apps/Quarto/share/…`) or the R `rmarkdown` package (`…/win-library/4.5/rmarkdown/…`) — and
in those cases the embedded bytes were confirmed identical to the on-disk source file. Nothing
below is written from memory; a component whose licence could not be established from a file on
disk is listed at the end under **Licence not established from the bundled copy**.

---

## reveal.js 5.1.0

*In: reveal.js decks.* Banner carried by the bundled script, verbatim:

```
/*!
* reveal.js 5.1.0
* https://revealjs.com
* MIT licensed
*
* Copyright (C) 2011-2024 Hakim El Hattab, https://hakim.se
*/
```

Two components distributed inside reveal.js carry their own headers in the bundle:

```
/*!
	 * zoom.js 0.3 (modified for use with reveal.js)
	 * http://lab.hakim.se/zoom-js
	 * MIT licensed
	 *
	 * Copyright (C) 2011-2014 Hakim El Hattab, http://hakim.se
	 */
```

```
/*!
	 * Handles finding a text string anywhere in the slides and showing the next occurrence to the user
	 * by navigatating to that slide and highlighting it.
	 *
	 * @author Jon Snyder <snyder.jon@gmail.com>, February 2013
	 */
```

(The second is the reveal.js search plugin. Its header states authorship only, no separate
licence; it is distributed as part of reveal.js above.)

The decks register these reveal.js plugins: `QuartoLineHighlight, PdfExport, RevealMenu,
QuartoSupport, RevealMath, RevealNotes, RevealSearch, RevealZoom`.

## Source Sans Pro (web font)

*In: reveal.js decks*, embedded as four EOT faces (regular, italic, semibold, semibold-italic).
The bundled copy carries no notice. The embedded bytes are identical to the files Quarto ships
at `share/formats/revealjs/reveal/dist/theme/fonts/source-sans-pro/`, whose `LICENSE` file
begins:

```
SIL Open Font License

Copyright 2010, 2012 Adobe Systems Incorporated (http://www.adobe.com/), with Reserved Font Name ‘Source’. All Rights Reserved. Source is a trademark of Adobe Systems Incorporated in the United States and/or other countries.

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at: http://scripts.sil.org/OFL
```

Licence: **SIL Open Font License, Version 1.1**.

## Bootstrap 5.3.1

*In: Quarto HTML notebooks.* Banner carried by the bundled script, verbatim:

```
/*!
  * Bootstrap v5.3.1 (https://getbootstrap.com/)
  * Copyright 2011-2023 The Bootstrap Authors (https://github.com/twbs/bootstrap/graphs/contributors)
  * Licensed under MIT (https://github.com/twbs/bootstrap/blob/main/LICENSE)
  */
```

## Bootstrap Icons 1.11.1 (web font)

*In: Quarto HTML notebooks*, embedded as a base64 WOFF under `font-family: "bootstrap-icons"`.
The bundled `@font-face` rule carries no notice. The embedded bytes are identical to
`bootstrap-icons.woff` shipped by Quarto at `share/formats/html/bootstrap/dist/`, whose
accompanying `bootstrap-icons.css` begins:

```
/*!
 * Bootstrap Icons v1.11.1 (https://icons.getbootstrap.com/)
 * Copyright 2019-2023 The Bootstrap Authors
 * Licensed under MIT (https://github.com/twbs/icons/blob/main/LICENSE)
 */
```

## Popper (@popperjs/core) 2.11.7

*In: reveal.js decks and Quarto HTML notebooks.* Banner carried by the bundled script, verbatim:

```
/**
 * @popperjs/core v2.11.7 - MIT License
 */
```

## clipboard.js 2.0.11

*In: reveal.js decks and Quarto HTML notebooks.* Banner carried by the bundled script, verbatim:

```
/*!
 * clipboard.js v2.0.11
 * https://clipboardjs.com/
 *
 * Licensed MIT © Zeno Rocha
 */
```

## AnchorJS 5.0.0

*In: Quarto HTML notebooks.* Header carried by the bundled script, verbatim:

```
// @license magnet:?xt=urn:btih:d3d9a9a6595521f9666a5e94cc830dab83b65699&dn=expat.txt Expat
//
// AnchorJS - v5.0.0 - 2023-01-18
// https://www.bryanbraun.com/anchorjs/
// Copyright (c) 2023 Bryan Braun; Licensed MIT
//
// @license magnet:?xt=urn:btih:d3d9a9a6595521f9666a5e94cc830dab83b65699&dn=expat.txt Expat
```

The `anchorjs-icons` web font embedded in these files is inserted by AnchorJS's own code and is
part of that distribution.

## Quarto (Posit Software, PBC)

*In: reveal.js decks and Quarto HTML notebooks.* Quarto's own runtime — `QuartoLineHighlight`,
`QuartoSupport`, the tabset and code-copy scripts, and the generated stylesheets — is emitted by
Quarto 1.7.31 without an inline banner. `share/COPYING.md` in that installation reads:

```
MIT License

Copyright (c) 2020-2024 Posit Software, PBC
```

and `share/COPYRIGHT` reads:

```
Quarto
Copyright (C) 2020-2024 Posit Software, PBC

With the exceptions noted below, this code is released under the
[MIT License](https://opensource.org/license/mit/):
```

Licence: **MIT**. Quarto's source is at <https://github.com/quarto-dev/quarto-cli>.

## jQuery 3.6.0

*In: reproduced tables.* Banner carried by the bundled script, verbatim:

```
/*! jQuery v3.6.0 | (c) OpenJS Foundation and other contributors | jquery.org/license */
```

The `rmarkdown` package that produced these files states in its `NOTICE`, under the heading
`jQuery License`:

```
Copyright (c) 2012 jQuery Foundation and other contributors,
http://jquery.com/
```

followed by the MIT permission and warranty-disclaimer paragraphs.

## Bootstrap 3.3.5

*In: reproduced tables.* Banner carried by the bundled script, verbatim:

```
/*!
 * Bootstrap v3.3.5 (http://getbootstrap.com)
 * Copyright 2011-2015 Twitter, Inc.
 * Licensed under the MIT license
 */
```

The matching stylesheet is inlined with its comments stripped; the source file
(`rmarkdown/rmd/h/bootstrap/css/bootstrap.css`) carries the same notice with the licence URL
`https://github.com/twbs/bootstrap/blob/master/LICENSE`.

## Bootswatch "Simplex" theme

*In: reproduced tables.* The inlined stylesheet is the Bootswatch Simplex build that `rmarkdown`
ships as `rmd/h/bootstrap/css/simplex.min.css` (confirmed by matching the stylesheet body); its
comment banners did not survive inlining. The `rmarkdown` `NOTICE` file records, under the
heading `Bootswatch`:

```
The MIT License (MIT)

Copyright 2014 Thomas Park
```

## normalize.css 3.0.3

*In: reproduced tables*, as the opening section of the Bootswatch stylesheet above. Its banner
was stripped during inlining; the source file `simplex.min.css` carries it verbatim:

```
/*! normalize.css v3.0.3 | MIT License | github.com/necolas/normalize.css */
```

## Respond.js 1.4.2

*In: reproduced tables.* Banner carried by the bundled script, verbatim:

```
/*! Respond.js v1.4.2: min/max-width media query polyfill * Copyright 2013 Scott Jehl
 * Licensed under https://github.com/scottjehl/Respond/blob/master/LICENSE-MIT
 *  */
```

## HTML5 Shiv 3.7.2

*In: reproduced tables.* Banner carried by the bundled script, verbatim:

```
/**
* @preserve HTML5 Shiv 3.7.2 | @afarkas @jdalton @jon_neal @rem | MIT/GPL2 Licensed
*/
```

## Open Sans (web font)

*In: reproduced tables*, embedded as two base64 TrueType faces (400 and 700). The bundled
`@font-face` rules carry no notice. The embedded bytes are identical to `OpenSans.ttf` and
`OpenSansBold.ttf` shipped by `rmarkdown` at `rmd/h/bootstrap/css/fonts/`. That package's
`NOTICE` covers them under the heading:

```
tufte latex and Open Sans Web Font License
```

followed by the full text of the **Apache License, Version 2.0**.

---

## Licence not established from the bundled copy

The following are present in the rendered HTML, but no copyright or licence notice could be
found for them in the bundled file **or** in the toolchain copy on this machine. They are listed
here rather than being assigned terms.

| Component | Appears in | What was checked |
|---|---|---|
| **Tippy.js** (UMD build, loads against Popper) | reveal.js decks, Quarto HTML notebooks | No banner in the bundled script or CSS. Quarto's own `share/formats/html/tippy/tippy.umd.min.js`, `tippy.css` and `_tippy.scss` carry no banner either; no version string and no `LICENSE` file anywhere under `share/`. |
| **Tabby** (`root.Tabby = factory(root)`) | reveal.js decks | Bundled unminified with no header. Quarto's `share/formats/html/tabby/js/tabby.js` also has no header and no adjacent `LICENSE`. |
| **reveal.js-menu** (`RevealMenu`) | reveal.js decks | No banner in the bundle. Quarto's `share/formats/revealjs/plugins/menu/menu.js`, `menu.css` and `plugin.yml` carry no copyright or licence line, and the directory has no `LICENSE`. |
| **PdfExport** reveal.js plugin | reveal.js decks | No banner in the bundle. Quarto's `share/formats/revealjs/plugins/pdfexport/pdfexport.js` and `plugin.yml` carry none either. |
| **marked** (bundled inside the reveal.js notes plugin) | reveal.js decks | Identified only by the string `https://github.com/markedjs/marked` in an error message. No banner and no version string in the bundle; nothing under Quarto's `share/formats/revealjs` names it. |
| **Glyphicons Halflings** (web font) | reproduced tables | Embedded as base64 EOT/TTF, matching `rmarkdown/rmd/h/bootstrap/fonts/glyphicons-halflings-regular.*`. No notice in the bundled `@font-face` rule; `rmarkdown`'s `NOTICE` and `COPYING` do not mention Glyphicons, and Bootstrap 3's bundled CSS references the font files without an attribution comment. |

---

## Components looked for and *not* found in the bundle

Recorded so the absence is not mistaken for an omission: **Font Awesome** (the reveal.js menu
plugin can load it, but the decks are configured `"loadIcons":false` and no Font Awesome CSS or
font is embedded), **MathJax** and **KaTeX** (only the reveal.js math plugin's loader code is
present; neither library is embedded, and neither is fetched unless a deck uses math),
**highlight.js** (only `.hljs` class rules from reveal.js's stylesheet; the highlighting in these
files is Pandoc's), **mermaid**, **jQuery** in the decks and notebooks (only Bootstrap's optional
`window.jQuery` interop check), and the reveal.js **chalkboard** plugin (menu entries reference
`RevealChalkboard`, but the plugin is not registered and its code is not bundled).
