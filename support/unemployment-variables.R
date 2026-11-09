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
# 2021 denominator
# The 2021 population column must count residents aged 16 and over (the 2011 file counts residents aged 16 to 74).
# Summing all categories of the 7-category variable, as above, also counts the under-16s ("Does not apply"),
# which makes the 2021 rate incomparable with the 2011 rate. Fix: take the number of residents aged 16 and over
# from the ONS 4-category economic activity status extract (all categories except "Does not apply").
# es2021 <- read_csv('London-LSOA-EconomicStatus.csv')   # columns: lsoa code, name, category code, category, observation
# names(es2021) <- c('lsoa21cd', 'lsoa21nm', 'k', 'kn', 'o')
# pop16 <- es2021 |> filter(k != -8) |> group_by(lsoa21cd) |> summarise(pop21 = sum(o))
# un2021 <- un2021 |> select(-pop21) |> left_join(pop16, by = 'lsoa21cd')
