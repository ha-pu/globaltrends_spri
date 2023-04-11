# Puhr, H. & Müllner, J.
# Vox Populi, Vox Dei
# A Concept and Measure for Grassroots Socio-Political Risk Using Google Trends

# Install packages

# packages ---------------------------------------------------------------------
if (!require("globaltrends")) install.packages("globaltrends")
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("WDI")) install.packages("WDI")

# save new year ----------------------------------------------------------------
year <- 2013
write_lines(year, "input/new_year.txt")
