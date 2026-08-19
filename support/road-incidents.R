# libraries
library(tidyverse)
library(stats19)
library(sf)

# london outline
london_outline <- st_read('data/spatial/London-MSOA-2021.gpkg') |>
  st_union()

# stats19 collision data
collision_uk <- get_stats19(year = 2025, type = 'collision') |>
  format_sf()

# clip, select
# named selection, not positional: the dft schema has changed column order
# and added fields (e.g. local_authority_*) between 2022 and 2025, so fixed
# column positions silently pick up the wrong fields once the schema shifts
collision_london <- collision_uk |>
  st_intersection(london_outline) |>
  st_drop_geometry() |>
  select(
    collision_index, collision_year, collision_reference, longitude, latitude,
    collision_severity, number_of_vehicles, number_of_casualties, date,
    day_of_week, time, road_type, speed_limit, light_conditions,
    weather_conditions, road_surface_conditions
  ) |>
  rename(
    accident_index = collision_index,
    accident_year = collision_year,
    accident_reference = collision_reference,
    accident_severity = collision_severity
  )

# write
st_write(collision_london, 'data/attributes/London-Collisions-2025.csv')