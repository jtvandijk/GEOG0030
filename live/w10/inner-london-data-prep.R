# Week 10 - co-development phase: instructor reference
# Not part of the rendered workbook. For live use / own refresher only.
library(tidyverse)
library(sf)
library(janitor)

# --- load ---
lsoa_eth <- read_csv('data/attributes/London-LSOA-Ethnicity.csv')
lsoa21 <- st_read('data/spatial/London-LSOA-2021.gpkg') |> st_drop_geometry()

# --- long to wide, counts to proportions ---
lsoa_eth <- lsoa_eth |>
  clean_names() |>
  pivot_wider(id_cols = 'lower_layer_super_output_areas_code',
              names_from = 'ethnic_group_20_categories',
              values_from = 'observation') |>
  clean_names()

lsoa_eth <- lsoa_eth |>
  rowwise() |>
  mutate(eth_pop = sum(across(2:21))) |>
  mutate(across(2:21, ~ . / eth_pop)) |>
  select(-2)

# rename to something readable
names(lsoa_eth)[2:20] <- c('Asian - Bangladeshi', 'Asian - Chinese', 'Asian - Indian',
  'Asian - Pakistani', 'Asian - Other', 'Black - African', 'Black - Caribbean',
  'Black - Other', 'Mixed - Asian', 'Mixed - Black African', 'Mixed - Black Carribean',
  'Mixed - Other', 'White - British', 'White - Irish', 'White - Traveller',
  'White - Roma', 'White - Other', 'Arab - Other', 'Any Other Group')

# --- restrict to the 12 Inner London Boroughs ---
inner_boroughs <- c('Camden', 'Greenwich', 'Hackney', 'Hammersmith and Fulham',
  'Islington', 'Kensington and Chelsea', 'Lambeth', 'Lewisham', 'Southwark',
  'Tower Hamlets', 'Wandsworth', 'Westminster')

lsoa21_inner <- lsoa21 |>
  filter(str_detect(lsoa21nm, paste(inner_boroughs, collapse = '|')))

lsoa_eth <- lsoa_eth |>
  filter(lower_layer_super_output_areas_code %in% lsoa21_inner$lsoa21cd) |>
  left_join(lsoa21[1:2], by = c('lower_layer_super_output_areas_code' = 'lsoa21cd')) |>
  mutate(borough_name = substr(lsoa21nm, 1, nchar(lsoa21nm) - 5))

# sanity check: row count should be plausible for 12 boroughs' worth of
# Inner London LSOAs, not the full ~5,000 London total
nrow(lsoa_eth)

# end state handed to students: lsoa_eth, one row per Inner London LSOA,
# one column per ethnic group (proportion), plus borough_name
