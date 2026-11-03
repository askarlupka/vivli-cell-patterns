# Vivli Platform Outcomes and Impact: Analysis Code and Data

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23901525.svg)](https://doi.org/10.5281/zenodo.23901525)

This repository contains the analysis code and the underlying data used to
produce the metrics and figures reported in:

> Li R, Skarlupka AL, O'Callaghan J, Peloquin D, McAllister DA, Graham E,
> Levenstein M, Wood J, Conklin R, Sim I. *The Vivli Platform: A Global
> Clinical Research Data Sharing Platform.* Patterns (Cell Press), 2026. DOI: `TODO-add-article-DOI-when-available`

It covers Vivli's approved data access requests and the resulting public
disclosures (publications, preprints, abstracts, and other outputs) from
December 2018 through December 2025.

> **Note on scope.** This repository is the *analysis and metrics* code for the
> paper. It is not the Vivli platform's production source code. As described in
> the paper's Source-Code Availability section, Vivli's custom platform code
> (governance workflow, access control, and environment provisioning) is
> deliberately not released for security reasons.

---

## What you can reproduce

**The figures in the paper are fully reproducible from this repository.** The
manuscript figure and the supporting figures are generated from the
analysis-ready data files under `data/`, using the scripts in
`code/analysis/`. This has been tested end to end.

This deposit is deliberately focused on figure reproduction. The upstream
data-cleaning and bibliographic-enrichment code is **not** included, because it
references Vivli-internal source files and workflow and is not runnable outside
Vivli. How the analysis-ready datasets were built is summarized in
[Data preparation and provenance](#data-preparation-and-provenance) below.

---

## Repository structure

```
outcomes-impact/
├── README.md                     This file
├── LICENSE                       GNU General Public License v3
├── CITATION.cff                  How to cite this software and data
├── .zenodo.json                  Metadata for the Zenodo deposit
├── renv.lock                     Exact package versions (figure environment)
├── DEPENDENCIES.md               Human-readable package list and roles
├── outcomes-impact.Rproj         RStudio project file
├── code/
│   ├── source_scripts/
│   │   └── 01_functions.R        request_data() and disclosure_data(): load the figure inputs
│   └── analysis/                 Figure generation
│       ├── 01_manuscript_figures.Rmd     Produces the multi-panel manuscript figure
│       ├── 02_country_reference_table.R  Country reference table (requests by country, income group)
│       ├── 03_country_maps_two_panel.R   Two-panel figure: studies map (A) and requests map (B)
│       └── 04_country_bars.R             Two-panel country bar chart (studies and requests per country)
├── data/                         Analysis-ready datasets (the figure inputs)
│   ├── README.md                 Data dictionary and data availability statement
│   ├── requests.rds              Approved data requests. Input for every figure.
│   ├── public_disclosures.rds    Public disclosures with outcome categories and a reviewer column. Input for the manuscript figure.
│   ├── studies.rds               Study dataset: 8,044 clinical trials posted before 2026, with a site_countries column (source for the studies map).
│   ├── Overton_index articles-2026-02-10.csv     Overton export underlying the policy-citation metric.
│   ├── world_bank_income_fy2027.csv       World Bank FY2027 income classification (iso3, country, income) used for the LMIC labels.
│   └── categorization_definitions.csv   Outcome-category and detailed-outcome definitions
├── figures/
│   ├── manuscript_figure.png     Reference copy of the reproduced manuscript figure
│   ├── study_therapeutic_area.png    Studies and participants per therapeutic area (two-panel)
│   ├── country_maps_AB.png       Two-panel country map (A studies, B requests)
│   ├── country_bars.png          Country bar chart: top 10 Non-LMIC and top 10 LMIC per panel (A studies, B requests)
│   ├── country_maps_AB_studies_data.csv   Panel A data: country, ISO3, World Bank class (FY2027), LMIC, studies with a site
│   ├── country_maps_AB_requests_data.csv  Panel B data: country, ISO3, World Bank class (FY2027), LMIC, total approved requests
│   ├── Supplemental_Table_3_policy_citations.csv             Overton policy citations (Supplemental Table 3)
│   ├── vivli_platform_diagram.pptx   Editable inputs -> Vivli -> outputs concept diagram
│   └── vivli_platform_diagram.png    Rendered copy of the concept diagram
```

---

## Reproducing the figures

### Prerequisites

- R version 4.5.2 (the version the analysis was run under).
- The R packages listed in `renv.lock` / `DEPENDENCIES.md`.

### Option A: restore the exact environment with renv (recommended)

`renv.lock` pins the exact version of every package needed for the figure
environment. From the project root in R:

```r
install.packages("renv")   # if not already installed
renv::restore()            # installs the pinned package versions
```

`renv::restore()` reads `renv.lock` and installs each package at the recorded
version into a project-local library, so your result matches ours regardless of
what is installed system-wide.

### Option B: install the packages yourself

If you prefer not to use renv, install the packages listed in
`DEPENDENCIES.md` and continue.

### Generate the figure

Open `outcomes-impact.Rproj` in RStudio and knit
`code/analysis/01_manuscript_figures.Rmd`, or from the project root run:

```r
rmarkdown::render("code/analysis/01_manuscript_figures.Rmd")
```

This reads `data/requests.rds`, `data/public_disclosures.rds`, and
`data/studies.rds`, builds the multi-panel manuscript figure, the
studies-by-therapeutic-area figure, and Supplemental Table 3, and writes them to
`figures/`. A reference copy of the expected manuscript figure is
committed at `figures/manuscript_figure.png`.

The trials-per-request and contributors-per-request breakdowns are panels C and
D of that manuscript figure. The country reference table and the two-panel
country map are produced by `02_country_reference_table.R` and
`03_country_maps_two_panel.R`, each run from the project root. The two country
maps read their committed panel-data CSVs in `figures/`. `04_country_bars.R`
then reads those same CSVs and renders the counts as bar charts
(`figures/country_bars.png`), so it is run after 06 and 07.

All file paths in the code are resolved with the `here` package relative to the
project root, so the code runs from any machine without editing paths, as long
as it is run inside the project.

---

## Data preparation and provenance

The analysis-ready datasets under `data/` were built from Vivli's
internal request-tracking records and from external bibliographic sources. The
code that performs that preparation is Vivli-internal and is not part of this
deposit; the methodology is summarized here so the provenance is clear.

- **Approved data requests** (`requests.rds`) come from Vivli's
  internal request-tracking records, filtered to approved requests from December
  2018 through December 2025 and reduced to the fields the figures use (proposal
  title, lead-researcher country, approval date, therapeutic area, and study and
  data-contributor counts).
- **Public disclosures** (`public_disclosures.rds`) come from Vivli's
  disclosure tracking, enriched with bibliographic metadata from PubMed and
  Crossref (publication type and publication date) and with manually assigned
  outcome categories. Publication-type assignment
  used PubMed publication formats followed by a manual review step.
- **Study dataset** (`studies.rds`) combines the Vivli platform Studies
  Report (pulled September 14, 2026: 8,044 clinical-trial studies posted before
  January 1, 2026, seven selected columns) with `site_countries` and
  `n_site_countries` columns giving each study's trial-site countries.
- **Policy citations** (`Overton_index articles-2026-02-10.csv`) come from the
  Overton policy-document index.
- **Outcome categories** were assigned by manual review. The outcome-category
  and detailed-outcome definitions are provided in
  `data/categorization_definitions.csv`. The reviewer who
  categorized each disclosure is recorded, anonymized, in the `reviewer` column
  of `public_disclosures.rds`.

Because these steps depend on internal Vivli files, live external APIs, and a
manual review checkpoint, they are not reproducible outside Vivli. The figures,
by contrast, are fully reproducible from the datasets in `data/`.

---

## Data

The datasets included here, a data dictionary for every column, and the data
availability statement explaining the legal basis for sharing researcher-level
request information are documented in [`data/README.md`](data/README.md).

The outcome-category and detailed-outcome definitions used in the manual review
are provided as
[`data/categorization_definitions.csv`](data/categorization_definitions.csv).
The per-publication reviewer attribution is the `reviewer` column of
[`data/public_disclosures.rds`](data/public_disclosures.rds).

---

## Dependencies

- `renv.lock` pins exact package versions for the figure-reproduction
  environment (R 4.5.2).
- `DEPENDENCIES.md` is a human-readable list of the packages and their roles.

---

## License

The code in this repository is licensed under the GNU General Public License
version 3 or later (`GPL-3.0-or-later`); see [`LICENSE`](LICENSE). If you intend
version 3 only, change the SPDX identifier in `CITATION.cff` and `.zenodo.json`
to `GPL-3.0-only`. The data files are shared under the terms described in
`data/README.md`.

---

## Before publishing this repository

A few placeholders need to be filled in before the GitHub push and Zenodo
deposit:

- [ ] Add the article DOI once assigned (this README, `CITATION.cff`, `.zenodo.json`).
- [ ] Confirm the author list and add ORCID iDs in `CITATION.cff` and `.zenodo.json`.
- [ ] Set the GitHub repository URL in `CITATION.cff` and `.zenodo.json`.
- [ ] Publish

---

## Contact

For questions about Vivli or data access, see https://vivli.org.
