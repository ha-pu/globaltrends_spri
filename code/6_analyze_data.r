# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

# Analyze data

# packages ---------------------------------------------------------------------
library(lubridate)
library(maps)
library(readxl)
library(tidyverse)
library(writexl)

# load data --------------------------------------------------------------------
category_mean <- read_rds("data/category_base.rds")
category_global <- read_rds("data/category_global.rds")
category_internet <- read_rds("data/category_internet.rds")

data_wdi <- read_rds("data/data_wdi.rds")

lst_countries <- read_xlsx("input/spri_countries.xlsx")

year <- read_lines("input/new_year.txt")

# combine data -----------------------------------------------------------------
data_wdi <- lst_countries %>%
  inner_join(data_wdi, by = "iso2c", multiple = "all") %>%
  select(country = country.x, year, gdp_share)

data <- category_mean %>%
  group_by(location, date, year) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  mutate(category = "Total") %>%
  bind_rows(category_mean) %>%
  mutate(spri = spri * 100)

data <- inner_join(data, lst_countries, by = c("location" = "iso2c"))
  
data_global <- category_global %>%
  group_by(date, year) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  mutate(category = "Total") %>%
  bind_rows(category_global) %>%
  mutate(spri = spri * 100)

data_internet <- category_internet %>%
  group_by(date, year) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  mutate(category = "Total") %>%
  bind_rows(category_internet) %>%
  mutate(spri = spri * 100)

data_global <- left_join(data_global, data_internet, by = c("date", "year", "category"))

# plot global spri -------------------------------------------------------------
categories <- c("Total", "Economy", "Government", "Security", "Society")
year_min <- year(min(data_global$date))
year_max <- year(max(data_global$date))
year_seq <- seq(year_min, year_max)
date_seq <- dmy(paste(31, 12, year_seq, sep = "-"))

walk(seq_along(categories), ~{
  data_global %>%
    filter(category == categories[[.x]]) %>%
    ggplot() +
    geom_line(aes(x = date, y = spri.x), colour = "darkred") +
    geom_line(aes(x = date, y = spri.y), colour = "darkblue") +
    scale_x_date(minor_breaks = date_seq) +
    labs(
      x = NULL,
      y = str_c("Grassroots SPRI", categories[[.x]], sep = " "),
      tag = LETTERS[[.x]]
    ) +
    theme_bw()
  ggsave(str_c("images/spri_global_", categories[[.x]], ".png"), height = 5, width = 10)
})

# plot map ---------------------------------------------------------------------
world_data <- data %>%
  group_by(year, country, category) %>%
  summarise(spri = mean(spri), .groups = "drop")

world_data <- map_data("world") %>%
  filter(region != "Antarctica") %>%
  fortify() %>%
  left_join(world_data, by = c("region" = "country"), relationship = "many-to-many")

mean_global <- data_global %>%
  filter(category == "Total") %>%
  summarise(mean_global = log(mean(spri.x))) %>%
  pull(mean_global)

## map for 2010 ----------------------------------------------------------------
world_old <- world_data %>%
  filter((is.na(year) | year == 2010) & (is.na(category) | category == "Total")) %>%
  mutate(spri = na_if(spri, 0)) %>%
  mutate(spri = log(spri))

ggplot(data = world_old) +
  geom_map(
    map = world_old,
    aes(
      x = long,
      y = lat,
      group = group,
      map_id = region,
      fill = spri
    ),
    colour = "black",
    linewidth = 0.5
  ) +
  scale_y_continuous(breaks = c()) +
  scale_x_continuous(breaks = c()) +
  scale_fill_gradient2(midpoint = mean_global, low = "darkgreen", mid = "darkorange", high = "darkred") +
  labs(
    fill = "Grassroots SPRI Total",
    title = 2010,
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

ggsave("images/spri_map_old.png", height = 5, width = 10)

## map for new_year ------------------------------------------------------------
world_new <- world_data %>%
  filter((is.na(year) | year == year) & (is.na(category) | category == "Total")) %>%
  mutate(spri = na_if(spri, 0)) %>%
  mutate(spri = log(spri))

ggplot(data = world_new) +
  geom_map(
    map = world_new,
    aes(
      x = long,
      y = lat,
      group = group,
      map_id = region,
      fill = spri
    ),
    colour = "black",
    linewidth = 0.5
  ) +
  scale_y_continuous(breaks = c()) +
  scale_x_continuous(breaks = c()) +
  scale_fill_gradient2(midpoint = mean_global, low = "darkgreen", mid = "darkorange", high = "darkred") +
  labs(
    fill = "Grassroots SPRI Total",
    title = year,
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

ggsave("images/spri_map_new.png", height = 5, width = 10)

# average spri by country  -----------------------------------------------------
data_spri <- data %>%
  group_by(category, year, country) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  pivot_wider(names_from = category, values_from = spri) %>%
  mutate(Total = rowMeans(.[, c("Economy", "Government", "Security", "Society")])) %>%
  inner_join(data_wdi, by = c("year", "country"))

data_spri %>%
  filter(Total != 0) %>%
  select(Country = country, Year = year, Total, Economy, Government, Security, Society) %>%
  arrange(Country, Year) %>%
  write_xlsx("data_spri.xlsx")
