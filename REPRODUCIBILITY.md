# Reproducibility

Package versions used to build the handbook, kept here for reference. This is documentation rather than an enforced lockfile — `renv` was evaluated in previous years but is not used, owing to `sf`'s system-level dependency on GDAL/GEOS/PROJ.

Built with [Quarto](https://quarto.org) `1.10.18` and R `4.6.1`.

## R packages used in the teaching material

The packages called via `library()` in the `.qmd` files. A student running the code independently of the rendered handbook would need these.

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

## Additional packages required to build the site

Required only to render the handbook, not by students. `formatR` and `styler` are invoked via knitr chunk options rather than `library()` calls.

| Package | Version | Used for |
|---|---|---|
| formatR | 1.14 | `#\| tidy: True` chunk option |
| styler | 1.11.0 | `` {r tidy='styler'} `` chunk option |
| knitr | 1.51 | rendering engine |
| rmarkdown | 2.31 | rendering engine |

A `simple` conda environment (`python=3`, `pandas`) is required for the section-numbering step in `_publish.sh` (`_section_numbers.py`).
