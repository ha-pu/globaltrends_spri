# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends
# Journal of International Management, 30(2): 101096

# Install packages

# packages ---------------------------------------------------------------------
# devtools::install_github(repo = "ha-pu/globaltrends", ref = "parquet")
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("WDI")

# save new year ----------------------------------------------------------------
year <- 2025
readr::write_lines(year, "input/new_year.txt")
