### import macro data

# packages ---------------------------------------------------------------------
library(tidyverse)
library(WDI)

year <- 2022

# load wdi data ----------------------------------------------------------------
data_wdi <- WDI(indicator = c("NY.GDP.MKTP.PP.CD", "SP.POP.TOTL", "IT.NET.USER.ZS"), start = year, end = year) %>%
  as_tibble() %>%
  rename(
    gdp_ppp = NY.GDP.MKTP.PP.CD,
    population = SP.POP.TOTL,
    internet_users = IT.NET.USER.ZS
  )

data_wdi <- data_wdi %>%
  filter(country == "World") %>%
  select(year, gdp_ppp, population) %>%
  left_join(data_wdi, by = "year", multiple = "all") %>%
  mutate(
    gdp_share = gdp_ppp.y / gdp_ppp.x,
    population_share = population.y / population.x,
    internet_users = internet_users / 100
  ) %>%
  select(
    iso2c,
    country,
    year,
    gdp_share,
    population_share,
    internet_users
  )

data_wdi <- expand_grid(year = year, iso2c = unique(data_wdi$iso2c)) %>%
  left_join(data_wdi, by = c("iso2c", "year")) %>%
  group_by(iso2c) %>%
  fill(internet_users, .direction = "updown") %>%
  ungroup()

# save data --------------------------------------------------------------------
saveRDS(data_wdi, "data/data_wdi_new.rds")
