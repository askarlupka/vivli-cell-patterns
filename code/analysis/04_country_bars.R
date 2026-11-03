# Country bar charts: studies per country and approved data requests per country,
# split by World Bank income group.
#
# Companion to the two-panel country map (03_country_maps_two_panel.R). Each panel
# shows the top 10 countries that are NOT low- or middle-income (Non-LMIC), a
# horizontal divider, and then the top 10 LMIC countries, ranked within each group:
#   Panel A  studies with a trial site in each country
#   Panel B  approved data requests per lead-researcher country
#
# Inputs (written by 02_country_reference_table.R and 03_country_maps_two_panel.R):
#   figures/country_maps_AB_studies_data.csv
#   figures/country_maps_AB_requests_data.csv   (full per-country counts for all countries)
# Output:
#   figures/country_bars.png

library(tidyverse)
library(cowplot)

my_theme <- theme_bw(base_size = 15) +
  theme(
    panel.background  = element_rect(fill = 'transparent', colour = NA),
    plot.background   = element_rect(fill = 'transparent', colour = NA),
    legend.position   = "none"
  )

gradient_blue <- function(n) scales::seq_gradient_pal("#00affa", "#004f71",
                                                      "Lab")(seq(0, 1, length.out = max(n, 2)))

studies_by_country <- readr::read_csv(here::here("figures/country_maps_AB_studies_data.csv"),
                                      show_col_types = FALSE) %>%
  dplyr::filter(!is.na(iso3))

requests_by_country <- readr::read_csv(here::here("figures/country_maps_AB_requests_data.csv"),
                                       show_col_types = FALSE) %>%
  dplyr::filter(!is.na(iso3))                              # drop the "All countries" total row

# Top n_top Non-LMIC countries, a divider, then top n_top LMIC countries, each
# group ranked by its own count. LMIC is the World Bank low-/middle-income flag.
lmic_split_panel <- function(df, valcol, ylab, label_size, n_top = 10) {
  top_non  <- df %>% dplyr::filter(LMIC == "No")  %>% dplyr::arrange(dplyr::desc(.data[[valcol]])) %>% head(n_top)
  top_lmic <- df %>% dplyr::filter(LMIC == "Yes") %>% dplyr::arrange(dplyr::desc(.data[[valcol]])) %>% head(n_top)
  d <- dplyr::bind_rows(top_non, top_lmic) %>%
    dplyr::mutate(Country = factor(Country, levels = rev(Country)))  # Non-LMIC on top, LMIC below

  n_non  <- nrow(top_non)
  n_lmic <- nrow(top_lmic)
  divider <- n_lmic + 0.5                                  # boundary between the two groups
  maxv <- max(d[[valcol]])

  ggplot(d, aes(x = Country, y = .data[[valcol]], fill = Country)) +
    geom_col() +
    geom_text(aes(label = scales::comma(.data[[valcol]])), hjust = -0.2, size = label_size) +
    geom_vline(xintercept = divider, linewidth = 0.5, colour = "gray40") +
    annotate("text", x = n_lmic + n_non / 2 + 0.5, y = maxv * 0.9, label = "Non-LMIC",
             fontface = "italic", colour = "gray30", size = 4.2) +
    annotate("text", x = n_lmic / 2 + 0.5, y = maxv * 0.9, label = "LMIC",
             fontface = "italic", colour = "gray30", size = 4.2) +
    coord_flip(clip = "off") +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15)), labels = scales::comma) +
    scale_fill_manual(values = gradient_blue(nrow(d))) +
    xlab("Country") + ylab(ylab) +
    my_theme +
    theme(plot.margin = margin(t = 14, r = 8, b = 3, l = 3),
          axis.text.y = element_text(size = 11))
}

pA_country <- lmic_split_panel(studies_by_country, "studies", "Studies (n)", 3.5)
pB_country <- lmic_split_panel(requests_by_country, "Requests", "Approved data requests (n)", 3.5)

# A studies per country   B approved data requests per country (each: top 10 Non-LMIC / top 10 LMIC)
country_bars <- cowplot::plot_grid(pA_country, pB_country, labels = c("A", "B"),
                                   ncol = 2, rel_widths = c(1, 1), align = "h",
                                   label_y = 1, vjust = 1)

ggsave2(plot = country_bars,
        filename = here::here("figures/country_bars.png"),
        width = 13, height = 7.5, dpi = 300, bg = "transparent")

cat("wrote figures/country_bars.png (top 10 Non-LMIC and top 10 LMIC per panel)\n")
