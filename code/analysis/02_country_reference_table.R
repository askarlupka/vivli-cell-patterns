# Country reference table for approved data requests:
#   figures/country_maps_AB_requests_data.csv   one row per country, with
#   country name, ISO 3166-1 alpha-3 code, World Bank income classification,
#   LMIC flag, and the total number of approved requests. This is the underlying
#   data for the requests panel (panel B) of country_maps_AB.png, saved beside
#   the figure. The map itself is drawn by 03_country_maps_two_panel.R.
#
# Country income groups follow the current World Bank income classification for
# fiscal year 2027 (released July 2026, based on 2025 GNI per capita; World Bank
# Country and Lending Groups,
# https://datahelpdesk.worldbank.org/knowledgebase/articles/906519, accessed
# 2026-09-28). LMIC = low- and middle-income (upper-middle + lower-middle; no
# low-income country appears in the data). Hong Kong (high income, 4 requests) is
# kept as its own row. (One lead-researcher country recorded as a truncated
# "United", request 11362, was corrected to the United Kingdom in the source data,
# verified against Vivli's records.)

library(tidyverse)
library(here)
library(countrycode)

source(here::here("code/source_scripts/01_functions.R"))

# ---- World Bank income group lookup (for countries present in the data) ------
upper_middle <- c("China", "Brazil", "South Africa", "Thailand",
                  "Argentina", "Turkey", "Sri Lanka")
lower_middle <- c("Lebanon", "India", "Morocco")
classify <- function(country) dplyr::case_when(
  country %in% lower_middle ~ "Lower middle income",
  country %in% upper_middle ~ "Upper middle income",
  TRUE                       ~ "High income")

req <- request_data() %>%
  mutate(country = lead_researcher_country,
         wb_income = classify(country))

# ---- Reference table: one row per country, total requests only --------------
tab <- req %>%
  count(country, wb_income, name = "Requests") %>%
  mutate(iso3    = suppressWarnings(countrycode(country, "country.name", "iso3c")),
         Country = suppressWarnings(countrycode(iso3, "iso3c", "country.name.en")),
         `World Bank classification (FY2027)` = wb_income,
         LMIC    = ifelse(wb_income == "High income", "No", "Yes")) %>%
  arrange(desc(Requests)) %>%
  select(Country, iso3, `World Bank classification (FY2027)`, LMIC, Requests)

totals <- tibble(Country = "All countries", iso3 = "",
                 `World Bank classification (FY2027)` = "", LMIC = "",
                 Requests = sum(tab$Requests))
tab_out <- bind_rows(tab, totals)

write.csv(tab_out, here::here("figures/country_maps_AB_requests_data.csv"), row.names = FALSE)
cat("wrote figures/country_maps_AB_requests_data.csv (", nrow(tab), "countries )\n")
