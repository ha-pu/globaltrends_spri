### prepare internal category data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(readxl)
library(tidyverse)

# load data --------------------------------------------------------------------
start_db()
batch_control <- read_rds("data/batch_control.rds")
score_base <- export_score(control = batch_control)
disconnect_db()

data_keywords <- read_xlsx("input/spri_topics.xlsx", sheet = 2)

# aggregate by term ------------------------------------------------------------
spri_keyword_base <- score_base %>%
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
saveRDS(spri_keyword_base, "data/spri_keyword_int.rds")
