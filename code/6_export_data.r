# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

# Analyze data

# packages ---------------------------------------------------------------------
library(lubridate)
library(nanoparquet)
library(readxl)
library(tidyverse)
library(writexl)

# load data --------------------------------------------------------------------
category_mean <- read_rds("data/category_base.rds")

lst_countries <- read_xlsx("input/spri_countries.xlsx")

# combine data -----------------------------------------------------------------
data <- category_mean %>%
  summarise(
    spri = mean(spri),
    .by = c(location, date, year)
  ) %>%
  mutate(category = "Total") %>%
  bind_rows(category_mean) %>%
  mutate(spri = spri * 100) %>%
  inner_join(
    lst_countries,
    by = c("location" = "iso2c")
  )

# average spri by country  -----------------------------------------------------
data_spri <- data %>%
  summarise(
    spri = mean(spri),
    .by = c(category, year, country)
  ) %>%
  pivot_wider(names_from = category, values_from = spri) %>%
  mutate(
    Total = rowMeans(.[, c("Economy", "Government", "Security", "Society")])
  ) %>%
  inner_join(data_wdi, by = c("year", "country")) %>%
  filter(Total != 0) %>%
  select(
    Country = country,
    Year = year,
    Total,
    Economy,
    Government,
    Security,
    Society
  ) %>%
  arrange(Country, Year)

# save data --------------------------------------------------------------------
saveRDS(data_spri, "data_spri.rds")
write_parquet(data_spri, "data_spri.parquet")
write_xlsx(data_spri, "data_spri.xlsx")
