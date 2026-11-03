# Data

This folder holds the analysis-ready datasets that reproduce the paper's figures.

## Data availability statement

These datasets describe Vivli approved data access requests and the public disclosures (publications and related outputs) that resulted from them, from December 2018 through December 2025.

**Request-level information in this repository includes the lead researcher's country, the research proposal title, the therapeutic area, and the data-contributing organizations.** No individual participant data (IPD) from any clinical trial is included in this repository; the request records describe what data was requested, not the trial data itself.

Public disclosure records are bibliographic descriptions of already-published outputs (journal articles, preprints, abstracts, and similar), with identifiers (DOI, PubMed ID) where available.

## File dictionary

### `requests.rds` (used by the manuscript figures)

Data Request Export retrieved on: January 7, 2026 restricted to data requests approved on or before December 31, 2025

One row per approved data access request (870 rows). Loaded by `request_data()` in `code/source_scripts/01_functions.R`.

| Column | Description |
|------------------------------------|------------------------------------|
| vivli_id | Unique Vivli identifier for the data request |
| title | Research proposal title |
| lead_researcher_country | Country of the lead researcher |
| data_contributor | Data-contributing organization(s), comma-delimited |
| number_of_data_contributors | Count of contributing organizations |
| total_studies_requested | Number of studies requested. |
| approved_date | Date the request was approved |
| therapeutic_area | Therapeutic area of the request |
| month, year | Approval date floored to month and to year |

### `public_disclosures.rds` (used by the manuscript figures)

One row per public disclosure (532 rows). Loaded by `disclosure_data()`.

| Column | Description |
|------------------------------------|------------------------------------|
| doi | Digital Object Identifier, where available |
| pubmed_id | PubMed identifier, where available |
| vivli_id | Vivli request the disclosure is attributed to |
| public_disclosure | Normalized citation string (unique key for the disclosure) |
| publication_date | Publication date |
| metrics_year | Reporting year the disclosure is counted under |
| publication_format_v02 | PubMed MeSH publication format |
| study_characteristics_v03 | PubMed MeSH study characteristics |
| support_of_research_v04 | PubMed MeSH support-of-research field |
| outcome_category | Vivli outcome category(ies), comma-delimited |
| outcome_category_n | Count of distinct outcome categories |
| outcome_detail | Detailed outcome label(s), comma-delimited |
| outcome_detail_n | Count of distinct detailed outcomes |
| pub_type_vivli | Vivli publication-type classification |
| reviewer | Which reviewer assigned the outcome category (Reviewer 1/2/3, or a combined label); blank where the disclosure was not part of the categorization set |

### `Overton_index articles-2026-02-10.csv`

Policy-citation records for Vivli-linked publications exported from the Overton index (39 rows). Columns include `Title, DOI, Journal, Published on, Policy citation count, Cited by source, Cited by title, Cited by organisation ...`. This is the underlying data for the policy-document citation counts reported in the paper.



### `studies.rds` (study dataset, used by the studies map)

One row per study (8,044 clinical-trial studies posted before January 1, 2026). Read directly with `readRDS()` in `code/analysis/01_manuscript_figures.Rmd`.

| Column | Description |
|------------------------------------|------------------------------------|
| NCT Id | ClinicalTrials.gov NCT identifier for the study, where available |
| Posted Date | Date the study was posted on the Vivli platform |
| Org Name | Name of the organization that contributed the study |
| Study Title | Study title |
| Study Metadata Doi | DOI of the study's metadata record |
| Therapeutic Areas | Therapeutic area(s) assigned to the study |
| # Participants | Number of enrolled participants reported for the study |
| site_countries | Semicolon-separated list of the study's trial-site countries (ISO 3166-1 canonical names, de-duplicated); blank if none recorded |
| n_site_countries | Count of distinct site countries |

The first seven columns come from the Vivli platform Studies Report (pulled September 14, 2026). The two site-country columns are added from Vivli's Cosmos study records (the authoritative `LocationsOfStudySites` field, matched to the Studies Report by study DOI, using the location `name`, since the location `code` field has a separate known bug). The studies map (panel A of `03_country_maps_two_panel.R`) counts each study once per site country directly from `site_countries` (132 countries; 5,630 of the 8,044 studies have site-country data).

### `world_bank_income_fy2027.csv` (income classification reference)

The World Bank income classification for fiscal year 2027 (released July 2026, based on 2025 GNI per capita; World Bank Country and Lending Groups, <https://datahelpdesk.worldbank.org/knowledgebase/articles/906519>, accessed September 28, 2026). Columns: `iso3`, `country`, `income` (High income, Upper middle income, Lower middle income, or Low income), 217 economies. Used by `03_country_maps_two_panel.R` to label each country's income group and the LMIC flag in `figures/country_maps_AB_studies_data.csv` (LMIC = any group other than high income). Countries not listed by the World Bank, such as Taiwan, are marked "Not classified (World Bank)".

### `categorization_definitions.csv` (outcome categorization definitions)

Definitions for the outcome categories and detailed outcomes assigned to journal-article public disclosures during manual review (37 rows). These are the definitions behind the `outcome_category`, `outcome_category_n`, `outcome_detail`, and `outcome_detail_n` columns of `public_disclosures.rds`.

| Column | Description |
|------------------------------------|------------------------------------|
| Outcome category | Rolled-up outcome category |
| Detailed outcome | Detailed outcome label that rolls up to its category |
| Definition | Working definition of the detailed outcome |

