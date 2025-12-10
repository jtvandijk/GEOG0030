# load libraries
library(tidyverse)
library(sf)
library(tmap)
library(cowplot)
library(biscale)

# read 2011 data
lsoa11 <- read_csv('data/attributes/London-LSOA-Unemployment-2011.csv')

# read 2021 data
lsoa21 <- read_csv('data/attributes/London-LSOA-Unemployment-2021.csv')

# read lookup data
lookup <- read_csv('data/attributes/England-Wales-LSOA-2011-2021.csv')

# read spatial data
lsoa21_sf <- st_read("data/spatial/London-LSOA-2021.gpkg")

# for unchanged LSOAs keep weighting the same 
lsoa_lookup_same  <- lookup |> filter(chgind == 'U') |>
  group_by(lsoa11cd) |>
  mutate(n=n())

# for merged LSOAs: keep weighting the same
lsoa_lookup_merge <- lookup |> filter(chgind == 'M') |>
  group_by(lsoa11cd) |>
  mutate(n=n())

# for split LSOAs: weigh proportionally to the number of 2021 LSOAs 
lsoa_lookup_split <- lookup |> filter(chgind == 'S') |>
  group_by(lsoa11cd) |>
  mutate(n=1/n())

# re-combine the lookup with updated weightings
lsoa_lookup <- rbind(lsoa_lookup_same,
                     lsoa_lookup_merge,
                     lsoa_lookup_split)

# join to lsoa data
lsoa11_21 <- lsoa11 |> 
  select(-lsoa11nm) |>
  left_join(lsoa_lookup, by = c('lsoa11cd' = 'lsoa11cd'))

# weigh data
lsoa11_21 <- lsoa11_21 |>
  mutate(eco_active_unemployed11 = eco_active_unemployed11 * n) |>
  mutate(pop11 = pop11 * n)

# assign 2011 to 2021
lsoa11_21 <- lsoa11_21 |>
  group_by(lsoa21cd) |>
  mutate(eco_active_unemployed11_lsoa21 = sum(eco_active_unemployed11)) |>
  mutate(pop11_lsoa21 = sum(pop11)) |>
  distinct(lsoa21cd, eco_active_unemployed11_lsoa21, pop11_lsoa21)

# join 2011 data with 2021 data
lsoa11_21 <- lsoa11_21 |>
  left_join(lsoa21, by = c("lsoa21cd" = "lsoa21cd"))

# unemployment rates
lsoa11_21 <- lsoa11_21 |>
  mutate(unemp11 = eco_active_unemployed11_lsoa21 / pop11_lsoa21) |>
  mutate(unemp21 = eco_active_unemployed21 / pop21) |>
  select(-lsoa21nm)

# unemployment change
lsoa11_21 <- lsoa11_21 |>
  mutate(unemp_ch = unemp11 - unemp21)

# join to spatial data
lsoa21_sf <- lsoa21_sf |>
  left_join(lsoa11_21, by = c("lsoa21cd" = "lsoa21cd"))

# map / no palette
tm_shape(lsoa21_sf) +
  tm_polygons(
    col = "unemp_ch",
    n = 5,
    style = "jenks"
  )

# map / palette
tm_shape(lsoa21_sf) +
  tm_polygons(
    col = "unemp_ch",
    n = 5,
    style = "jenks",
    palette = "Oranges"
  )

# function
map_test <- function(spatialfile, variable, palette) {
  map <- tm_shape(spatialfile) +
  tm_polygons(
    col = variable,
    n = 5,
    style = "jenks",
    palette = palette
  )
  return(map)
}

# map / function
map_test(lsoa21_sf, "unemp_ch", "Oranges")