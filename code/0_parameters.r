# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends

# Install packages

# packages ---------------------------------------------------------------------
# Automatic installation in Dockerfile
# install.packages("globaltrends")
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("WDI")

# save new year ----------------------------------------------------------------
year <- 2022
readr::write_lines(year, "input/new_year.txt")
