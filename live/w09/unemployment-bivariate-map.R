# Week 9 - independent task: instructor reference
# Not part of the rendered workbook. For live use / own refresher only.
#
# This is last year's fully worked solution, kept as a reference for what
# a complete, correct answer looks like - not something to hand to
# students. The workbook itself only gives the data, the lookup table, and
# the end goal (a bivariate map of unemployment change 2011-2021), without
# walking through the split/merge logic below. Students are meant to
# discover that via the lookup table's chgind column themselves, with
# Copilot's help.
#
# See live/w09/reference-bivariate-map-london.png and
# reference-bivariate-map-lambeth.png for the target-style outputs to show
# live at the start of the session.

library(tidyverse)
library(sf)
library(biscale)
library(cowplot)

# --- load ---
lsoa11 <- read_csv('data/attributes/London-LSOA-Unemployment-2011.csv')
lsoa21 <- read_csv('data/attributes/London-LSOA-Unemployment-2021.csv')
lookup <- read_csv('data/attributes/England-Wales-LSOA-2011-2021.csv')

# --- the actual problem: LSOA counts differ between years ---
length(unique(lsoa11$lsoa11cd))
length(unique(lsoa21$lsoa21cd))
# more LSOAs in 2021 than 2011 - boundaries changed, not population growth
# in the naive sense. The lookup table's chgind column flags why:
#   U = unchanged, S = split (1 2011 LSOA -> many 2021 LSOAs)
#   M = merged (many 2011 LSOAs -> 1 2021 LSOA), X = irregular
# London has no X cases, so only S and M need handling.

# --- weight the lookup so splits divide values, merges keep them whole ---
lsoa_lookup_same <- lookup |> filter(chgind == 'U') |>
  group_by(lsoa11cd) |> mutate(n = n())

lsoa_lookup_merge <- lookup |> filter(chgind == 'M') |>
  group_by(lsoa11cd) |> mutate(n = n())

lsoa_lookup_split <- lookup |> filter(chgind == 'S') |>
  group_by(lsoa11cd) |> mutate(n = 1/n())

lsoa_lookup <- rbind(lsoa_lookup_same, lsoa_lookup_merge, lsoa_lookup_split)

# --- join, then reassign 2011 values onto 2021 geography ---
lsoa11_21 <- lsoa11 |>
  select(-lsoa11nm) |>
  left_join(lsoa_lookup, by = c('lsoa11cd' = 'lsoa11cd'))

# sanity check: row count inflates due to the one-to-many join, this is
# expected and is exactly what the weighting column (n) corrects for
nrow(lsoa11); nrow(lsoa21); nrow(lsoa11_21)

lsoa11_21 <- lsoa11_21 |>
  mutate(eco_active_unemployed11 = eco_active_unemployed11 * n) |>
  mutate(pop11 = pop11 * n) |>
  group_by(lsoa21cd) |>
  mutate(eco_active_unemployed11_lsoa21 = sum(eco_active_unemployed11)) |>
  mutate(pop11_lsoa21 = sum(pop11)) |>
  distinct(lsoa21cd, eco_active_unemployed11_lsoa21, pop11_lsoa21)

# validation: total population should match before and after reassignment
sum(lsoa11$pop11)
sum(lsoa11_21$pop11_lsoa21)
# these should be equal (or very close) - if not, the weighting has gone
# wrong somewhere and the map downstream cannot be trusted

lsoa11_21 <- lsoa11_21 |>
  left_join(lsoa21, by = c('lsoa21cd' = 'lsoa21cd'))

# --- rates and bivariate classes ---
lsoa11_21 <- lsoa11_21 |>
  mutate(unemp11 = eco_active_unemployed11_lsoa21 / pop11_lsoa21) |>
  mutate(unemp21 = eco_active_unemployed21 / pop21) |>
  select(-lsoa21nm) |>
  bi_class(x = unemp21, y = unemp11, style = 'quantile', dim = 3)

# --- map ---
lsoa21_sf <- st_read('data/spatial/London-LSOA-2021.gpkg') |>
  left_join(lsoa11_21, by = c('lsoa21cd' = 'lsoa21cd'))

map <- ggplot() +
  geom_sf(data = lsoa21_sf, mapping = aes(fill = bi_class), color = NA, show.legend = FALSE) +
  bi_scale_fill(pal = 'DkBlue2', dim = 3) +
  bi_theme()

legend <- bi_legend(
  pal = 'DkBlue2', dim = 3,
  xlab = 'Higher Unemployment 2021',
  ylab = 'Higher Unemployment 2011',
  size = 6
)

ggdraw() +
  draw_plot(map, 0, 0, 1, 1) +
  draw_plot(legend, 0, 0, .3, 0.3)
# -> reference-bivariate-map-london.png

# zoomed to Lambeth for legibility -> reference-bivariate-map-lambeth.png
lsoa21_lambeth <- lsoa21_sf |> filter(str_detect(lsoa21nm, 'Lambeth')) |>
  bi_class(x = unemp21, y = unemp11, style = 'quantile', dim = 3)

map_lambeth <- ggplot() +
  geom_sf(data = lsoa21_lambeth, mapping = aes(fill = bi_class), color = NA, show.legend = FALSE) +
  bi_scale_fill(pal = 'DkBlue2', dim = 3) +
  bi_theme()

ggdraw() +
  draw_plot(map_lambeth, 0, 0, 1, 1) +
  draw_plot(legend, 0.1, 0.1, 0.3, 0.3)
