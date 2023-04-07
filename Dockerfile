FROM rocker/r-ver

RUN mkdir /home/spri
RUN mkdir /home/spri/code
RUN mkdir /home/spri/input
RUN mkdir /home/spri/data

COPY code/0_packages.r /home/spri/code/0_packages.r
COPY code/1_create_db.r /home/spri/code/1_create_db.r
COPY code/2_download_data.r /home/spri/code/2_download_data.r
COPY code/3_prepare_categories.r /home/spri/code/3_prepare_categories.r
COPY code/4_download_macro_data.r /home/spri/code/4_download_macro_data.r
COPY code/5_aggregate_categories.r /home/spri/code/5_aggregate_categories.r
COPY input/spri_countries.xlsx /home/spri/input/spri_countries.xlsx
COPY input/spri_topics.xlsx /home/spri/input/spri_topics.xlsx

RUN apt-get update && apt-get install -y --no-install-recommends nano

WORKDIR /home/spri
