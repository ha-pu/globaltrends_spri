### summarise internal risk data

# packages ---------------------------------------------------------------------
library(maps)
library(readxl)
library(tidyverse)
library(writexl)

# load data --------------------------------------------------------------------
category_mean <- bind_rows(
  read_rds("data/category_mean_new.rds"),
  read_rds("data/category_mean_old.rds")
)

category_global <- bind_rows(
  read_rds("data/category_global_new.rds"),
  read_rds("data/category_global_old.rds")
)

category_internet <- bind_rows(
  read_rds("data/category_internet_new.rds"),
  read_rds("data/category_internet_old.rds")
)

data_wdi <- bind_rows(
  read_rds("data/data_wdi_new.rds"),
  read_rds("data/data_wdi_old.rds")
)

lst_countries <- read_xlsx("input/lst_countries.xlsx")

# combine data -----------------------------------------------------------------
data_wdi <- lst_countries %>%
  inner_join(data_wdi, by = c("location" = "iso2c")) %>%
  select(country = country.x, year, gdp_share)

data <- category_mean %>%
  group_by(control, location, date, year) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  mutate(category = "Total") %>%
  bind_rows(category_mean) %>%
  mutate(spri = spri * 100)

data <- data %>%
  filter(control %in% control_base) %>%
  inner_join(lst_countries, by = "location")
  
data_global <- category_mean_global %>%
  group_by(date, year) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  mutate(category = "Total") %>%
  bind_rows(category_mean_global) %>%
  mutate(spri = spri * 100)

data_internet <- category_mean_internet %>%
  group_by(date, year) %>%
  summarise(spri = mean(spri), .groups = "drop") %>%
  mutate(category = "Total") %>%
  bind_rows(category_mean_internet) %>%
  mutate(spri = spri * 100)

data_global <- left_join(data_global, data_internet, by = c("date", "year", "category"))

# plot global spri -------------------------------------------------------------
categories <- c("Total", "Economy", "Government", "Security", "Society")

walk(seq_along(categories), ~{
  data_global %>%
    filter(category == categories[[.x]]) %>%
    ggplot() +
    geom_line(aes(x = date, y = spri.x), colour = "darkred") +
    geom_line(aes(x = date, y = spri.y), colour = "darkblue") +
    labs(
      x = NULL,
      y = str_c("Grassroots SPRI", categories[[.x]], sep = " "),
      tag = LETTERS[[.x]]
    ) +
    theme_bw()
  ggsave(str_c("images/spri_global_", categories[[.x]], ".png"), height = 2.5, width = 10, dpi = 600)
})

# plot map ---------------------------------------------------------------------
world_data <- data %>%
  group_by(year, country, category) %>%
  summarise(spri = mean(spri), .groups = "drop")

world_data <- map_data("world") %>%
  filter(region != "Antarctica") %>%
  fortify() %>%
  left_join(world_data, by = c("region" = "country"))

mean_global <- data_global %>%
  filter(category == "Total") %>%
  summarise(mean_global = log(mean(spri.x))) %>%
  pull(mean_global)

## map for 2010 ----------------------------------------------------------------
world_2010 <- world_data %>%
  filter((is.na(year) | year == 2010) & (is.na(category) | category == "Total")) %>%
  mutate(spri = na_if(spri, 0)) %>%
  mutate(spri = log(spri))

ggplot(data = world_2010) +
  geom_map(
    map = world_2010,
    aes(
      x = long,
      y = lat,
      group = group,
      map_id = region,
      fill = spri
    ),
    colour = "#f2f2f2",
    size = 0.5
  ) +
  scale_y_continuous(breaks = c()) +
  scale_x_continuous(breaks = c()) +
  labs(
    fill = "Grassroots SPRI Total",
    title = 2010,
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_fill_gradient2(midpoint = mean_global, low = "darkgreen", mid = "darkorange", high = "darkred")

ggsave("images/spri_map_2010.png", height = 4, width = 5, dpi = 600)

## map for 2021 ----------------------------------------------------------------
world_2021 <- world_data %>%
  filter((is.na(year) | year == 2021) & (is.na(category) | category == "Total")) %>%
  mutate(spri = na_if(spri, 0)) %>%
  mutate(spri = log(spri))

ggplot(data = world_2021) +
  geom_map(
    map = world_2021,
    aes(
      x = long,
      y = lat,
      group = group,
      map_id = region,
      fill = spri
    ),
    colour = "#f2f2f2",
    size = 0.5
  ) +
  scale_y_continuous(breaks = c()) +
  scale_x_continuous(breaks = c()) +
  labs(
    fill = "Grassroots SPRI Total",
    title = 2021,
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(legend.position = "bottom") +
  scale_fill_gradient2(midpoint = mean_global, low = "darkgreen", mid = "darkorange", high = "darkred")

ggsave("images/spri_map_2021.png", height = 4, width = 5, dpi = 600)

# average spri by country  -----------------------------------------------------
data_spri <- data %>%
  filter(control %in% control_base) %>%
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