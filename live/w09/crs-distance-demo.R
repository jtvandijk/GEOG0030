# Week 9 - worked example: instructor reference
# Not part of the rendered workbook. For live use in class only.
library(tidyverse)
library(sf)

# load the landmarks file (data/attributes/London-Landmarks.csv -
# deliberately named without "WGS84" in it, since that would give the
# twist away; the file itself is fine to link publicly, only the old
# filename was the problem)
landmarks <- read_csv('data/attributes/London-Landmarks.csv')
landmarks

# --- step 1: the prompt to give Copilot live ---
# "What is the distance between Big Ben and the Tower of London?"
#
# Deliberately vague - do not spell out "latitude and longitude" or
# "metres" in the prompt itself. Naming the coordinate columns explicitly
# is enough to nudge Copilot towards handling them properly, which defeats
# the point (flagged 2026-08-20). The dataframe already has columns called
# latitude/longitude that Copilot can see in context regardless, so the
# prompt itself should stay as close to a naive, real question as possible.
# The actual teaching moment is not really about Copilot's specific
# mistake - it is getting students to pause before trusting any distance
# figure and ask themselves whether the coordinate system was ever
# checked. Prompt that question live after running the naive version
# below, before revealing the correct one.

# --- step 2: what Copilot plausibly returns ---
# a single fixed conversion factor applied to both latitude and longitude
deg_to_m <- 111320

big_ben <- landmarks |> filter(name == 'Big Ben')
tower <- landmarks |> filter(name == 'Tower of London')

lat_diff_m <- (tower$latitude - big_ben$latitude) * deg_to_m
lon_diff_m <- (tower$longitude - big_ben$longitude) * deg_to_m

naive_distance <- sqrt(lat_diff_m^2 + lon_diff_m^2)
naive_distance
# ~5,483 m. Sounds entirely plausible on its own - central London landmarks
# are often a few km apart on foot. This is the point: nothing about the
# number itself looks wrong.

# --- step 3: check it properly ---
big_ben_sf <- st_as_sf(big_ben, coords = c('longitude', 'latitude'), crs = 4326)
tower_sf <- st_as_sf(tower, coords = c('longitude', 'latitude'), crs = 4326)
st_distance(big_ben_sf, tower_sf)
# ~3,470 m. More than a third shorter than Copilot's answer.

# --- the rationale, for explaining live ---
# 111,320 m per degree is a reasonable approximation for a degree of
# LATITUDE anywhere on Earth. It is not a reasonable approximation for a
# degree of LONGITUDE, because lines of longitude converge towards the
# poles - a degree of longitude covers less real distance the further you
# get from the equator. At London's latitude (~51.5N) that shortening
# factor is cos(51.5 deg) =~ 0.62, so treating longitude degrees as if they
# were the same length as latitude degrees inflates any east-west distance
# by roughly that much. Verified numerically: naive/correct =~ 1.58, i.e.
# about a 58% overestimate, consistent with 1/0.62.
#
# The code ran without error both times. The only way to catch the mistake
# was to check it against a method that actually accounts for the shape of
# the Earth (st_distance() on proper sf points with a CRS set), rather than
# trust that a working answer is a correct one.
