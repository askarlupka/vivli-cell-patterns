# Dependencies

The analysis was run under **R 4.5.2** on Windows (x86_64-w64-mingw32).

There are two ways to install what you need:

- **Exact figure environment:** run `renv::restore()` against the committed
  `renv.lock`, which pins the exact version of every package in the
  figure-reproduction dependency chain (the direct packages below plus their
  dependencies). This is the recommended path and is sufficient to reproduce the
  paper's figures.
- **Manual install:** install the packages listed below.

This deposit contains only the figure-reproduction code, so every package here
is used by the scripts in `code/analysis/`.

## Figure layer (required to reproduce the figures)

These packages are pinned in `renv.lock` at the versions used for the paper.

| Package     | Version used | Role |
|-------------|--------------|------|
| tidyverse   | 2.0.0        | Meta-package loading dplyr, tidyr, ggplot2, stringr, forcats, readr, tibble, purrr, lubridate |
| ggplot2     | 4.0.2        | All plotting |
| dplyr       | 1.2.0        | Data manipulation |
| tidyr       | 1.3.2        | Reshaping (pivot, complete) |
| stringr     | 1.6.0        | String handling |
| forcats     | 1.0.1        | Factor handling |
| lubridate   | 1.9.5        | Dates (floor_date, year) |
| readr       | 2.1.6        | Reading the CSV panel-data inputs |
| scales      | 1.4.0        | Colour gradients and axis scales |
| patchwork   | 1.3.2        | Combining plots |
| cowplot     | 1.2.0        | Plot-grid layout for the multi-panel figures |
| here        | 1.0.2        | Project-root-relative file paths |
| knitr       | 1.51         | R Markdown chunk engine |
| rmarkdown   | 2.30         | Rendering the .Rmd figure file |

Quick manual install:

```r
install.packages(c(
  "tidyverse", "ggplot2", "dplyr", "tidyr", "stringr", "forcats", "lubridate",
  "readr", "scales", "patchwork", "cowplot", "here", "knitr", "rmarkdown"
))
```

## Country map layer (for `02_country_reference_table.R` and `03_country_maps_two_panel.R`)

The country maps and the country reference table use these additional packages.
The reference table (`06`) needs only `tidyverse`, `here`, and `countrycode`;
the two maps (`07`) need all of the following.

| Package     | Role |
|-------------|------|
| maps        | World country polygons (`map_data("world")`) |
| mapproj     | Map projection support (dependency of the map workflow) |
| countrycode | Match country names to ISO 3166-1 alpha-3 codes for a reliable join |
| ggrepel     | Non-overlapping country count labels |
| ggpattern   | Hatch pattern marking LMIC countries |
| gridpattern | Pattern backend used by ggpattern |

```r
install.packages(c("maps", "mapproj", "countrycode", "ggrepel", "ggpattern", "gridpattern"))
```
