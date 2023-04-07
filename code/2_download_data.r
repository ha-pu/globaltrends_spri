# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends

# Download data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(tidyverse)

# parameters -------------------------------------------------------------------
start_db()
batch_object <- read_rds("data/batch_object.rds")

# control keywords -------------------------------------------------------------
download_control(control = 1, locations = gt.env$geo_full)

# object keywords --------------------------------------------------------------
download_object(object = batch_object, control = 1, locations = gt.env$geo_full)

# compute score ----------------------------------------------------------------
compute_score(object = batch_object, control = 1, locations = gt.env$geo_full)

# disconnect -------------------------------------------------------------------
disconnect_db()
