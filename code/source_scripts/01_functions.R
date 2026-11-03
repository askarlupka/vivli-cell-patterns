# Data-loading helpers for the manuscript figure scripts.
#
# request_data()    reads data/requests.rds and returns the
#                   approved-request table the figures use.
# disclosure_data() reads a public-disclosures rds (for example
#                   data/public_disclosures.rds) and returns
#                   the disclosure table the manuscript figure uses.
#
# These are the only two functions the figure scripts (04-07) rely on. The
# upstream data-cleaning and bibliographic-enrichment functions are not part of
# this release; that methodology is described in the README instead.

#### Read in Disclosure Data ####

disclosure_data <- function(disclosure_file) {

#disclosure_file <- 'data/public_disclosures.rds'

df <- readRDS(file =here::here(disclosure_file)) %>%
  dplyr::select(vivli_id, metrics_year, public_disclosure, pub_type_vivli, pubmed_id, doi, publication_date, outcome_category, outcome_category_n)

df$publication_date[df$publication_date == "1905-07-13"] <- "2021-10-01"

df <- df %>%
  dplyr::mutate(publication_month = lubridate::floor_date(publication_date, unit = "month"),
                publication_year = lubridate::floor_date(publication_date, unit = "year"),
                pub_type_vivli = ifelse(pub_type_vivli == "Research Snapshot", "Abstract", pub_type_vivli))

return(df)
}

#### Read in Requests Data ####

request_data <- function(request_file = "data/requests.rds") {
  df <- readRDS(file=here::here(request_file)) %>%
    dplyr::select(vivli_id, title, lead_researcher_country, approved_date, month, year, therapeutic_area, total_studies_requested, number_of_data_contributors) %>%
    dplyr::rename(data_contributor_n = number_of_data_contributors, studies_n = total_studies_requested, approved_month = month, approved_year = year) %>%
    dplyr::mutate(vivli_id = as.character(vivli_id))

  return(df)
}
