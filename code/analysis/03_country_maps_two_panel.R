# Two-panel country map figure (Equal Earth projection):
#   figures/country_maps_AB.png
#     A  Studies shared via Vivli with a site listed in each country
#     B  Approved data requests by lead researcher country (LMIC hatched)
#
# Panel A reads data/studies.rds (the study dataset: 8,044
# clinical-trial studies posted before 2026, with a site_countries column) and
# counts each study once per site country. The site countries come from Vivli's
# Cosmos study records (the authoritative LocationsOfStudySites field, by study
# name); see data/README.md.
# Panel B is built from the approved-request data via request_data().
#
# Country income groups follow the current World Bank income classification for
# fiscal year 2027 (released July 2026, based on 2025 GNI per capita; World Bank
# Country and Lending Groups,
# https://datahelpdesk.worldbank.org/knowledgebase/articles/906519, accessed
# 2026-09-28). LMIC = low- and middle-income (upper-middle + lower-middle; no
# low-income country appears in the data). Hong Kong (high income, 4 requests)
# has no boundary in the base world map and is not drawn (noted in the caption).
# (One lead-researcher country recorded as a truncated "United", request 11362,
# was corrected to the United Kingdom in the source data.)

library(tidyverse)
library(here)
library(maps)
library(countrycode)
library(ggrepel)
library(ggpattern)
library(cowplot)

source(here::here("code/source_scripts/01_functions.R"))

# ---- shared helpers ----------------------------------------------------------
eqearth <- function(long, lat, lon0 = 0) {   # Equal Earth (Savric et al. 2018)
  A1<-1.340264; A2<--0.081106; A3<-0.000893; A4<-0.003796
  lam <- (long-lon0)*pi/180; phi <- lat*pi/180
  th  <- asin(sqrt(3)/2*sin(phi))
  list(x = (2*sqrt(3)*lam*cos(th))/(3*(A1+3*A2*th^2+7*A3*th^6+9*A4*th^8)),
       y = A1*th+A2*th^3+A3*th^7+A4*th^9)
}
blue <- function(n) colorRampPalette(c("#e5f5fb", "#00affa", "#004f71"))(n)
add_xy <- function(w) { xy <- eqearth(w$long, w$lat); w$x <- xy$x; w$y <- xy$y; w }

base_world <- map_data("world") %>%
  filter(region != "Antarctica") %>%
  mutate(iso3 = suppressWarnings(countrycode(region, "country.name", "iso3c")))

map_theme <- theme_void(base_size = 13) +
  theme(plot.background = element_rect(fill = "white", colour = NA),
        legend.position = "bottom",
        plot.title   = element_text(hjust = 0.5, size = 14),
        plot.caption = element_text(hjust = 0.5, size = 9),
        legend.title = element_text(size = 10), legend.text = element_text(size = 9))

# World Bank income groups for the countries that appear in the request data
upper_middle <- c("China", "Brazil", "South Africa", "Thailand",
                  "Argentina", "Turkey", "Sri Lanka")
lower_middle <- c("Lebanon", "India", "Morocco")

# ---- Panel A: studies per country -------------------------------------------
# Count each study once per site country from the studies dataset's
# site_countries column (Vivli Cosmos site locations; see data/README.md).
pc <- readRDS(here::here("data/studies.rds")) %>%
  filter(!is.na(site_countries), site_countries != "") %>%
  transmute(doi = `Study Metadata Doi`, country = str_split(site_countries, "; ")) %>%
  tidyr::unnest(country) %>%
  mutate(iso3 = suppressWarnings(countrycode(country, "country.name", "iso3c"))) %>%
  filter(!is.na(iso3)) %>%
  distinct(doi, iso3) %>%
  count(iso3, name = "studies")

# panel-A data companion (matches the panel-B data file), with the World Bank
# FY2027 income class from data/world_bank_income_fy2027.csv
pc %>%
  left_join(readr::read_csv(here::here("data/world_bank_income_fy2027.csv"),
                            show_col_types = FALSE) %>% select(iso3, income), by = "iso3") %>%
  transmute(Country = suppressWarnings(countrycode(iso3, "iso3c", "country.name.en")), iso3,
            `World Bank classification (FY2027)` = ifelse(is.na(income), "Not classified (World Bank)", income),
            LMIC = ifelse(is.na(income) | income == "High income", "No", "Yes"), studies) %>%
  arrange(desc(studies)) %>%
  readr::write_csv(here::here("figures/country_maps_AB_studies_data.csv"))

sb <- c(0, 9, 49, 99, 499, 999, 1999, Inf)
sl <- c("1-9", "10-49", "50-99", "100-499", "500-999", "1000-1999", "2000+")
wA <- base_world %>% left_join(pc, by = "iso3") %>%
  mutate(band = cut(studies, sb, labels = sl)) %>% add_xy()

pA <- ggplot(wA, aes(x, y, group = group, fill = band)) +
  geom_polygon(colour = "grey75", linewidth = 0.1) +
  scale_fill_manual(values = blue(length(sl)), na.value = "grey93",
                    na.translate = FALSE, name = "Studies with a site in the country (n)") +
  coord_fixed(expand = FALSE) +
  labs(title = "Studies shared via Vivli with a site listed in each country",
       caption = "Studies posted as of December 31, 2025; counted once per country with a site.") +
  map_theme + guides(fill = guide_legend(nrow = 1))

# ---- Panel B: approved requests per country ---------------------------------
rc <- request_data() %>%
  mutate(country = lead_researcher_country) %>%
  count(country, name = "requests") %>%
  mutate(iso3 = suppressWarnings(countrycode(country, "country.name", "iso3c")),
         lmic = country %in% c(upper_middle, lower_middle))
rb <- c(0, 1, 4, 10, 25, 50, 100, Inf)
rl <- c("1", "2-4", "5-10", "11-25", "26-50", "51-100", "100+")
wB <- base_world %>% left_join(rc %>% select(iso3, requests, lmic), by = "iso3") %>%
  mutate(band = cut(requests, rb, labels = rl),
         lmic = replace_na(lmic, FALSE) & !is.na(requests)) %>% add_xy()

wBr <- wB %>% filter(!is.na(requests))
main_grp <- wBr %>% count(iso3, group) %>% group_by(iso3) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>% ungroup()
cen <- wBr %>% semi_join(main_grp, by = c("iso3", "group")) %>%
  group_by(iso3) %>% summarise(long = mean(long), lat = mean(lat),
                               requests = first(requests), .groups = "drop")
cxy <- eqearth(cen$long, cen$lat); cen$x <- cxy$x; cen$y <- cxy$y

pB <- ggplot(wB, aes(x, y, group = group)) +
  geom_polygon(aes(fill = band), colour = "grey75", linewidth = 0.1) +
  ggpattern::geom_polygon_pattern(
    data = filter(wB, lmic), aes(fill = band), show.legend = FALSE,
    pattern = "stripe", pattern_colour = "grey45", pattern_fill = NA,
    pattern_density = 0.08, pattern_spacing = 0.013, pattern_angle = 45,
    colour = "grey45", linewidth = 0.25) +
  geom_text_repel(data = cen, aes(x, y, label = requests), inherit.aes = FALSE,
                  size = 2.4, fontface = "bold", colour = "black", bg.color = "white",
                  bg.r = 0.18, segment.size = 0.2, segment.color = "grey40",
                  min.segment.length = 0, max.overlaps = Inf, seed = 1) +
  scale_fill_manual(values = blue(length(rl)), na.value = "grey93",
                    na.translate = FALSE, name = "Approved data requests (n)") +
  coord_fixed(expand = FALSE) +
  labs(title = "Approved data requests by lead researcher country",
       caption = "Hatched countries are LMIC. Hong Kong (n = 4) not shown.") +
  map_theme + guides(fill = guide_legend(nrow = 1))

# ---- Combine: A on top (studies), B below (requests) ------------------------
combined <- plot_grid(pA, pB, labels = c("A", "B"), ncol = 1, label_size = 18)
ggsave(here::here("figures/country_maps_AB.png"), combined,
       width = 11, height = 12.5, dpi = 150, bg = "white")
cat("wrote figures/country_maps_AB.png\n")
