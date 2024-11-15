# libraries
library(tidyverse)
library(janitor)
library(sf)

# read
un2011 <- read_csv('data/attributes/London-LSOA-Unemployment-2011.csv')
un2021 <- read_csv('data/attributes/London-LSOA-Unemployment-2021.csv')
ln2011 <- st_read('data/spatial/London-LSOA-2011.gpkg') |> select(1,11)

# 2011
un2011 <- ln2011 |>
  left_join(un2011, by = 'lsoa11cd') |>
  st_drop_geometry() |>
  as_tibble() |>
  distinct()

# 2021
names(un2021)[1:2] <- c('lsoa21cd','lsoa21nm')
un2021 <- un2021 |>
  janitor::clean_names() |>
  pivot_wider(id_cols = c('lsoa21cd', 'lsoa21nm'),
              names_from = 'economic_activity_status_7_categories', values_from = 'observation') |>
  janitor::clean_names() |>
  rowwise() |>
  mutate(pop21 = sum(across(3:9))) |>
  select(1,2,5,10)
names(un2021)[3] <- names(un2011)[3]
  
# write
write_csv(un2011, 'data/attributes/London-LSOA-Unemployment-2011.csv')
write_csv(un2021, 'data/attributes/London-LSOA-Unemployment-2021.csv')