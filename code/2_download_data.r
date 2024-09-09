# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

# Download data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(tidyverse)

# parameters -------------------------------------------------------------------
initialize_python(
  api_key = gtrends_api, # Google Trends API key
  conda_env = gtrends_conda # Location of Conda environment
)
gt.env$query_wait <- 1 # Set wait time between queries to 1 second
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
