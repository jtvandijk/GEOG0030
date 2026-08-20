# Week 10 - independent task: instructor reference
# Not part of the rendered workbook. For live use / own refresher only.
#
# Fully worked reference for both target visualisations, plus the
# function-parameterisation extension. Not something to hand to students -
# the workbook only gives the cleaned dataset and the two chart
# descriptions, they build this themselves with Copilot.
#
# Assumes lsoa_eth from live/w10/inner-london-data-prep.R is already in
# memory.
#
# See live/w10/reference-treemap.png and reference-histogram-panel.png
# for the target-style outputs to show live at the start of the session.

library(tidyverse)
library(treemapify)

# --- treemap: one borough, all ethnic groups ---
lambeth_mean <- lsoa_eth |>
  filter(borough_name == 'Lambeth') |>
  group_by(borough_name) |>
  summarise(across(2:20, mean)) |>
  pivot_longer(cols = 2:20, names_to = 'population_group', values_to = 'proportion')

ggplot(data = lambeth_mean, aes(area = proportion, fill = population_group, label = population_group)) +
  geom_treemap() +
  geom_treemap_text(colour = 'white', place = 'centre', grow = TRUE, min.size = 8) +
  theme_minimal() +
  theme(legend.position = 'none')
# -> reference-treemap.png

# --- histogram panel: one population group, all boroughs ---
ggplot(data = lsoa_eth, aes(x = `White - British`)) +
  geom_histogram() +
  facet_wrap(~ borough_name, ncol = 4, nrow = 3) +
  labs(title = 'Population self-identifying as White British', y = 'Number of LSOAs', x = '') +
  theme_light()
# -> reference-histogram-panel.png

# ---------------------------------------------------------------------
# turning working code into a function
#
# note: borough and population_group are NOT interchangeable parameters
# across the two chart types. The treemap fixes one borough and shows all
# groups, so it parameterises on borough. The histogram panel fixes one
# population group and shows all boroughs, so it parameterises on
# population group. "Borough" is not a meaningful parameter for the
# histogram panel - flagged by the user when reviewing the first draft of
# this task, the workbook wording was corrected accordingly (2026-08-20).
# The second, chart-agnostic parameter for both is colour/fill.
# ---------------------------------------------------------------------

# treemap function: parameters = borough, fill colour
create_treemap <- function(data, borough, fill_colour) {
  borough_mean <- data |>
    filter(borough_name == borough) |>
    group_by(borough_name) |>
    summarise(across(2:20, mean)) |>
    pivot_longer(cols = 2:20, names_to = 'population_group', values_to = 'proportion')

  ggplot(data = borough_mean, aes(area = proportion, fill = population_group, label = population_group)) +
    geom_treemap(colour = fill_colour) +
    geom_treemap_text(colour = 'white', place = 'centre', grow = TRUE, min.size = 8) +
    theme_minimal() +
    theme(legend.position = 'none')
}

create_treemap(lsoa_eth, 'Southwark', '#000000')

# histogram panel function: parameters = population group, fill colour
create_histogram_panel <- function(data, population_group, fill_colour) {
  ggplot(data = data, aes(x = .data[[population_group]])) +
    geom_histogram(fill = fill_colour) +
    facet_wrap(~ borough_name, ncol = 4, nrow = 3) +
    labs(title = population_group, y = 'Number of LSOAs', x = '') +
    theme_light()
}

create_histogram_panel(lsoa_eth, 'Black - African', '#3182bd')

# test with different inputs to each parameter before trusting either
# function - a function that only works for the exact values used while
# building it is not actually finished
