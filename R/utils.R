# Copyright 2018 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

safe_make_url <- function(...) {
  parts <- compact(list(...))
  parts <- gsub("^/+|/+$", "", parts)
  paste(parts, collapse = "/")
}

base_url <- function() {
  "http://data.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data"
}

get_metadata_json <- function(folder = NULL) {
  url <- safe_make_url(base_url(), folder, "datapackage.json")
  res <- httr::GET(url)
  httr::stop_for_status(res)
  httr::content(res, as = "parsed", type = "application/json")
}

get_resources_df <- function(folder = NULL) {
  resources <- get_metadata_json(folder)[["resources"]]
  dplyr::bind_rows(resources)
}

get_metadata_file <- function(name) {
  resources <- get_resources_df()
  resource <- resources[resources$name == name, ]
  if (nrow(resource) == 0) 
    stop("No resources found matching that name", call. = FALSE)
  if (nrow(resource) > 1) 
    stop("More than one resource found matching that name", call. = FALSE)
  
  url <- safe_make_url(base_url(), resource$path)
  res <- httr::GET(url)
  httr::stop_for_status(res)
  parse_ec(httr::content(res, as = "raw", type = resource$format), 
           resource$format)
}

parse_ec <- function(x, mime_type) {
  switch(mime_type, 
         csv = suppressMessages(
           readr::read_csv(x, locale = readr::locale(encoding = "latin1")))
           )
}

basin_folders_ <- function() {
  ec_site <- xml2::read_html("http://data.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/?lang=en")
  link_tbl <- rvest::html_node(ec_site, "#indexlist")
  link_tbl <- rvest::html_table(link_tbl)
  
  link_tbl <- link_tbl[link_tbl$Size == "-" & link_tbl$Name != "Parent Directory", 
                       c("Name", "Last modified")]
  link_tbl
}

basin_folders <- memoise::memoise(basin_folders_)

basin_url <- function(basin) {
  basin_links <- basin_folders()
  basin_links_match <- clean_names(basin_links[["Name"]])
  
  basin_clean <- clean_names(basin)
  url_folder <- basin_links[["Name"]][basin_clean %in% basin_links_match]
  if (!length(url_folder)) 
    stop("Unable to find data for ", basin, " basin")
  
  url_folder
}

clean_names <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z]+", "-", x)
  x <- gsub("(-and-)?(river)?(basin)?(long-term.+data)?(canada-s-north)?(lower-mainland)?(island)?", "", x)
  x <- gsub("-+", "", x)
  x
}

compact <- function(x) Filter(Negate(is.null), x)
