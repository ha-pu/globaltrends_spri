# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

# Download data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(tidyverse)

# parameters -------------------------------------------------------------------
readRenviron(".env")

initialize_python(
  api_key = Sys.getenv("GOOGLE_API_KEY"), # Google Trends API key
  conda_env = Sys.getenv("CONDA_ENV") # Location of Conda environment
)

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
