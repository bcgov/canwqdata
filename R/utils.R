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

#' Combine parts of a url into one (not queries etc just paths)
#'
#' @param ... parts of the url
#'
#' @return a single url
#' @noRd
safe_make_url <- function(...) {
  parts <- compact(list(...))
  # Get rid of leading and lagging slashes, then combine parts with slashes
  parts <- gsub("^/+|/+$", "", parts)
  paste(parts, collapse = "/")
}

base_url <- function() {
  "http://data.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/"
}

#' Get the 'datapackage.json file from a given folder and parse it 
#' into a list. 
#'
#' @param folder the name of the folder (subfolder of base_url)
#'
#' @noRd
get_metadata_json <- function(folder = NULL) {
  url <- safe_make_url(base_url(), folder, "datapackage.json")
  res <- httr::GET(url)
  httr::stop_for_status(res)
  httr::content(res, as = "parsed", type = "application/json")
}

#' Extract the resources from a datapackage.json in a given folder
#'
#' @param folder the name of the folder (subfolder of base_url)
#'
#' @noRd
get_resources_df <- function(folder = NULL) {
  resources <- get_metadata_json(folder)[["resources"]]
  dplyr::bind_rows(resources)
}

#' Get a 
#'
#' @param name name of the file in the datapackage json
#' @noRd
#'
#' @return a data frame of metadata
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

#' Parse EC metadata
#' 
#' Probably overkill to make this function, but
#' just in case they switch to something other than csv
#'
#' @param x 
#' @param mime_type 
#'
#' @noRd
parse_ec <- function(x, mime_type) {
  switch(mime_type, 
         csv = suppressMessages(
           readr::read_csv(x, locale = readr::locale(encoding = "latin1")))
           )
}

#' Find the links to the folders that contain the csvs for the basins.
#' @noRd
basin_folders_ <- function() {
  ec_site <- xml2::read_html(base_url())
  link_tbl <- rvest::html_node(ec_site, "#indexlist")
  link_tbl <- rvest::html_table(link_tbl)
  
  link_tbl <- link_tbl[link_tbl$Size == "-" & link_tbl$Name != "Parent Directory", 
                       c("Name", "Last modified")]
  stats::setNames(link_tbl, tolower(names(link_tbl)))
}

basin_folders <- memoise::memoise(basin_folders_)

#' Given a basin name (ideally from wq_sites()$PEARSEDA) get the url 
#' for the folder that contains the data
#'
#' @param basin 
#'
#' @noRd
basin_url <- function(basin) {
  basin_links <- basin_folders()
  basin_links_clean <- clean_names(basin_links[["name"]])
  
  basin_clean <- clean_names(basin)
  url_folder <- basin_links[["name"]][basin_clean == basin_links_clean]
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


#' Read a csv from the website. 
#'
#' @param x 
#'
#' @noRd
read_canwq_csv <- function(x) {
  # Read just first row to get the names and standardize - on some of them the 
  # UNIT_UNITE column has accent aigu. Could probaly just use a character vector
  # but that will break if the column order ever changes
  nms <- names(suppressMessages(
    readr::read_csv(x, n_max = 1, locale = readr::locale(encoding = "latin1"))
  ))
  nms[grepl("^UNIT_", nms)] <- "UNIT_UNITE"
  
  ret <- readr::read_csv(x, 
                         locale = readr::locale(encoding = "latin1"), 
                         col_types = readr::cols(
                           SITE_NO = readr::col_character(),
                           DATE_TIME_HEURE = readr::col_datetime(format = "%Y-%m-%d %H:%M"),
                           FLAG_MARQUEUR = readr::col_character(),
                           VALUE_VALEUR = readr::col_double(),
                           SDL_LDE = readr::col_double(),
                           MDL_LDM = readr::col_double(),
                           VMV_CODE = readr::col_integer(),
                           UNIT_UNITE = readr::col_character(),
                           VARIABLE = readr::col_character(),
                           VARIABLE_FR = readr::col_character(),
                           STATUS_STATUT = readr::col_character()
                         ), 
                         col_names = nms, 
                         skip = 1L)
  ret
}
