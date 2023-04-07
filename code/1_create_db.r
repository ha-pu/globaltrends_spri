### setup database - internal

# packages ---------------------------------------------------------------------
library(globaltrends)
library(readxl)
library(tidyverse)

# parameters -------------------------------------------------------------------
initialize_db()
start_db()

year <- 2022

time_frame <- paste0(year, "-01-01 ", year, "-12-31")

# control keywords -------------------------------------------------------------
controls <- read_xlsx("input/spri_topics.xlsx", sheet = 1) %>%
  select(topic) %>%
  nest(control = code) %>%
  mutate(control = map(control, ~ .$code))

batch_control <- add_control_keyword(keyword = controls$control, time = time_frame)

# object keywords --------------------------------------------------------------
keywords <- read_xlsx("input/spri_topics.xlsx", sheet = 2) %>%
  select(
    id,
    category,
    group,
    code
  )%>%
  nest(keyword = code) %>%
  mutate(keyword = map(keyword, ~ .$code))

batch_object <- map(keywords$keyword, add_object_keyword, time = time_frame)

# locations --------------------------------------------------------------------
countries <- read_xlsx("input/spri_countries.xlsx")

add_locations(countries$iso2c, "geo_full")

# disconnect -------------------------------------------------------------------
disconnect_db()

# save data --------------------------------------------------------------------
names(batch_control) <- years
names(batch_object) <- years

saveRDS(batch_control, "data/batch_control.rds")
saveRDS(batch_object, "data/batch_object.rds")
