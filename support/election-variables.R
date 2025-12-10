# libraries
library(tidyverse)
library(janitor)

# read
ind <- read_csv('data/attributes/England-Wales-PC2024-Industry.csv')

# industry variable - pivot
names(ind)[1:2] <- c('constituency_code','constituency_name')
ind <- ind |>
  janitor::clean_names() |>
  pivot_wider(id_cols = c('constituency_code', 'constituency_name'),
              names_from = 'industry_current_9_categories', values_from = 'observation') |>
  janitor::clean_names()
names(ind)[4:11] <- c('agriculture_energy_and_water', 'manufacturing', 'construction', 'distribution_hotels_and_restaurants', 'transport_and_communication',
                      'financial_real_estate_professional_and_administrative_activities','administration_education_and_health', 'other')
ind <- ind |>
  rowwise() |>
  mutate(constituency_total_population = sum(across(3:11))) 

# write
write_csv(ind, 'data/attributes/England-Wales-PC2024-Industry.csv')