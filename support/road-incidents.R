# libraries
library(tidyverse)
library(stats19)
library(sf)

# london outline
london_outline <- st_read('data/spatial/London-MSOA-2021.gpkg') |>
  st_union()

# stats19 collision data
collision_uk <- get_stats19(year = 2022, type = 'collision') |>
  format_sf()

# clip, select
collision_london <- collision_uk |>
  st_intersection(london_outline) |>
  st_drop_geometry() |>
  select(1,2,3,4,5,7,8,9,10,11,12,18,19,26,27,28)

# write
st_write(collision_london, 'data/attributes/London-Collisions-2022.csv')