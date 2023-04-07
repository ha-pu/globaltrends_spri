### categorize internal data - mean

# packages ---------------------------------------------------------------------
library(lubridate)
library(tidyverse)

# load data --------------------------------------------------------------------
data_keyword <- read_rds("data/spri_keyword_int.rds")
data_wdi <- read_rds("data/data_wdi.rds")
batch_control <- read_rds("data/batch_control.rds")

# compute category -------------------------------------------------------------
category_base <- data_keyword %>%
  filter(spri > 0) %>%
  group_by(control, location, date, category) %>%
  summarise(
    spri = mean(spri),
    .groups = "drop"
  ) %>%
  mutate(year = year(date))

category_base_global <- category_base %>%
  left_join(data_wdi, by = c("location" = "iso2c", "year")) %>%
  filter(spri != 0 & !is.na(gdp_share)) %>%
  group_by(date, category) %>%
  mutate(gdp_total = sum(gdp_share)) %>%
  mutate(gdp_share = gdp_share / gdp_total) %>%
  mutate(spri = spri * gdp_share) %>%
  group_by(date, category, year) %>%
  summarise(spri = sum(spri), .groups = "drop")

category_base_internet <- category_base %>%
  left_join(data_wdi, by = c("location" = "iso2c", "year")) %>%
  mutate(internet_share = internet_users * population_share) %>%
  filter(spri != 0 & !is.na(internet_share)) %>%
  group_by(date, category) %>%
  mutate(internet_total = sum(internet_share)) %>%
  mutate(internet_share = internet_share / internet_total) %>%
  mutate(spri = spri * internet_share) %>%
  group_by(date, category, year) %>%
  summarise(spri = sum(spri), .groups = "drop")

# save data --------------------------------------------------------------------
saveRDS(category_base, "data/category_base_new.rds")
saveRDS(category_global, "data/category_global_new.rds")
saveRDS(category_internet, "data/category_internet_new.rds")
