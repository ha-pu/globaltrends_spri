### collect internal risk data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(tidyverse)

# parameters -------------------------------------------------------------------
start_db()
batch_control <- read_rds("data/batch_control.rds")
batch_object <- read_rds("data/batch_object.rds")

# control keywords -------------------------------------------------------------
download_control(control = batch_control, locations = gt.env$geo_full)

# object keywords --------------------------------------------------------------
download_object(object = tmp, control = batch_control, locations = gt.env$geo_full)

# compute score ----------------------------------------------------------------
compute_score(object = tmp, control = batch_control, locations = gt.env$geo_full)

# disconnect -------------------------------------------------------------------
disconnect_db()
