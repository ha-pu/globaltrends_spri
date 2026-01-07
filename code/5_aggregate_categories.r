# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

# Aggregate category data

# packages ---------------------------------------------------------------------
library(lubridate)
library(tidyverse)

# load data --------------------------------------------------------------------
data_keyword <- read_rds("data/spri_keyword.rds")
data_wdi <- read_rds("data/data_wdi.rds")

# compute category -------------------------------------------------------------
category_base <- data_keyword %>%
  filter(spri > 0) %>%
  summarise(
    spri = mean(spri),
    .by = c(location, date, category)
  ) %>%
  mutate(year = year(date))

category_global <- category_base %>%
  left_join(data_wdi, by = c("location" = "iso2c", "year")) %>%
  filter(spri != 0 & !is.na(gdp_share)) %>%
  mutate(
    gdp_total = sum(gdp_share),
    .by = c(date, category)
  ) %>%
  mutate(gdp_share = gdp_share / gdp_total) %>%
  mutate(spri = spri * gdp_share) %>%
  summarise(
    spri = sum(spri),
    .by = c(date, category, year)
  )

category_internet <- category_base %>%
  left_join(data_wdi, by = c("location" = "iso2c", "year")) %>%
  mutate(internet_share = internet_users * population_share) %>%
  filter(spri != 0 & !is.na(internet_share)) %>%
  mutate(
    internet_total = sum(internet_share),
    .by = c(date, category)
  ) %>%
  mutate(internet_share = internet_share / internet_total) %>%
  mutate(spri = spri * internet_share) %>%
  summarise(
    spri = sum(spri),
    .by = c(date, category, year)
  )

# save data --------------------------------------------------------------------
saveRDS(category_base, "data/category_base.rds")
saveRDS(category_global, "data/category_global.rds")
saveRDS(category_internet, "data/category_internet.rds")
