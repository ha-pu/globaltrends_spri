# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

### prepare internal category data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(readxl)
library(tidyverse)

# load data --------------------------------------------------------------------
start_db()
score_base <- export_score(control = 1)
disconnect_db()

data_keywords <- read_xlsx("input/spri_topics.xlsx", sheet = 2)

# aggregate by term ------------------------------------------------------------
spri_keyword <- score_base %>%
  inner_join(data_keywords, by = c("keyword" = "code")) %>%
  select(
    control,
    location,
    category,
    group,
    keyword,
    date,
    score_obs
  ) %>%
  unique() %>%
  filter(score_obs != Inf & group != "Drop") %>%
  group_by(control, location, category, group, keyword, date) %>%
  summarise(
    spri = sum(score_obs),
    .groups = "drop"
  )

# save data --------------------------------------------------------------------
data_keyword <- bind_rows(
  read_rds("data/spri_keyword.rds"),
  spri_keyword
)
saveRDS(data_keyword, "data/spri_keyword.rds")
