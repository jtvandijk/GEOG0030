# GEOG0030 Geocomputation

This GitHub repository generates the GEOG0030 Geocomputation handbook for the 2025-2027 academic year which can be found at: https://jtvandijk.github.io/GEOG0030

## Building this handbook

The handbook is built with [Quarto](https://quarto.org) (`1.10.18`) and R
(`4.6.1`). This is documentation only, not an enforced lockfile (we've
tried `renv` in previous years — `sf`'s dependence on system GDAL/GEOS/PROJ
paths caused enough student-side setup issues, for too little payoff, that
it's not worth requiring). If a render behaves differently in future,
check what's changed against the versions below first.

Render with:

```
quarto render --no-clean
```

(`--no-clean` matters: a plain `quarto render` wipes `docs/` first,
which would delete the archived year snapshots under `docs/<year>/`.)

### R packages used in the teaching material

These are the packages the code in the `.qmd` files actually calls via
`library()` — the same ones a student would need if running the code
themselves outside of the rendered handbook.

| Package | Version |
|---|---|
| biscale | 1.1.0 |
| classInt | 0.4.11 |
| cluster | 2.1.8.2 |
| cowplot | 1.2.0 |
| dbscan | 1.2.5 |
| dodgr | 0.4.3 |
| easystats | 0.7.6 |
| factoextra | 2.2.0 |
| ggcorrplot | 0.3.0 |
| GWmodel | 2.4.1 |
| gstat | 2.1.6 |
| janitor | 2.2.1 |
| openair | 3.1.0 |
| osmdata | 0.4.0 |
| sf | 1.1.2 |
| spatstat | 3.6.2 |
| spdep | 1.4.2 |
| terra | 1.9.34 |
| tidyverse | 2.0.0 |
| tmap | 4.4.1 |
| treemapify | 2.6.1 |

### Additional packages needed only to build the full site

Not needed by students, only by whoever is rendering the handbook itself.
Some of these are used via knitr chunk options rather than `library()`
calls, so they're easy to miss on a quick read of the source:

| Package | Version | Used for |
|---|---|---|
| formatR | 1.14 | `#\| tidy: True` chunk option (most chapters) |
| styler | 1.11.0 | `` {r tidy='styler'} `` chunk option (a few chapters) |
| knitr | 1.51 | rendering engine |
| rmarkdown | 2.31 | rendering engine |

A `simple` conda environment (`python=3`, `pandas`) is also needed for the
section-numbering fix-up step in `_publish.sh` (`_section_numbers.py`).

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg
