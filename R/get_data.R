# Copyright 2025 Province of British Columbia
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

# Load site information from a csv file and include csv paths of BC water quality data
wq_sites_ <- function() {
  ret <- readr::read_csv("https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-Sites-National.csv",
                         col_types = NULL, show_col_types = FALSE)
  csv_path <- data.frame(
    OPEN_DATA_URL = c("https://data-donnees.az.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/peace-athabasca-river-basin-long-term-water-quality-monitoring-data?lang=en",
                      "https://data-donnees.az.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/pacific-coastal-basin-long-term-water-quality-monitoring-data?lang=en",
                      "https://data-donnees.az.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/fraser-river-long-term-water-quality-monitoring-data?lang=en",
                      "https://data-donnees.az.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/columbia-river-basin-long-term-water-quality-monitoring-data?lang=en",
                      "https://data-donnees.az.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/okanagan-similkameen-river-basin-long-term-water-quality-monitoring-data?lang=en",
                      "https://data-donnees.az.ec.gc.ca/data/substances/monitor/national-long-term-water-quality-monitoring-data/lower-mackenzie-river-basin-long-term-water-quality-monitoring-data-canada-s-north?lang=en"),
    csv_path = c("https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2Fpeace-athabasca-river-basin-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-Peace-Athabasca-2000-present.csv",
                 "https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2Fpacific-coastal-basin-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-Pacific-Coastal-Cote-Pacifique-2000-present.csv",
                 "https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2Ffraser-river-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-Fraser-2000-present.csv",
                 "https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2Fcolumbia-river-basin-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-Columbia-2000-present.csv",
                 "https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2Fokanagan-similkameen-river-basin-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-Okanagan-Similkameen-2000-present.csv",
                 "https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2Flower-mackenzie-river-basin-long-term-water-quality-monitoring-data-canada-s-north%2FWater-Qual-Eau-Mackenzie-2000-present.csv")
  )
  
  csv_path <- tibble::as_tibble(csv_path)
  
  ret_BC <- ret |> 
    dplyr::filter(PROV_TERR == "B.C.") |>
    dplyr::left_join(csv_path, by = "OPEN_DATA_URL")
    
  ret_BC
}
#' Get a table of water quality monitoring sites
#'
#' @importFrom memoise memoise
#' @return a data.frame of monitoring sites
#' @export
wq_sites <- memoise::memoise(wq_sites_)

# Load water parameter information from a csv file
wq_params_ <- function() {
  wq_params <- suppressWarnings(readr::read_csv("https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-VariableInfo.csv",
                  col_types = NULL, show_col_types = FALSE))
  wq_params
}

#' Get a table of water quality parameters
#'
#' @importFrom memoise memoise
#' @return a data.frame of parameters
#' @export
wq_params <- memoise::memoise(wq_params_)

# Load water parameter descriptions from a csv file
wq_data_desc_ <- function() {
  wq_data_desc <- readr::read_csv("https://data-donnees.az.ec.gc.ca/api/file?path=%2Fsubstances%2Fmonitor%2Fnational-long-term-water-quality-monitoring-data%2FWater-Qual-Eau-TableDescriptions.csv",
                col_types = NULL, show_col_types = FALSE)
  wq_data_desc
}

#' Get a table of water quality parameter descriptions
#'
#' @importFrom memoise memoise
#' @return a data.frame of parameter descriptions
#' @export
wq_data_desc <- memoise::memoise(wq_data_desc_)

# Get a list of basins for BC.
wq_basin_data_ <- function(basin) {
  full_url <- basin_csv_url(basin)
  res <- httr::GET(full_url, if (interactive()) httr::progress("down") else NULL)
  httr::stop_for_status(res)
  content <- httr::content(res, as = "raw", type = "text/csv", encoding = "Latin1")
  
  read_canwq_csv(content)
}

#' Download BC water quality data for a basin
#'
#' @param basin the name of a basin. 
#'
#' @importFrom memoise memoise
#' @return a data.frame of all the water quality monitoring data from that basin.
#' @export
wq_basin_data <- memoise::memoise(wq_basin_data_)

#' Download BC water quality data for a site or multiple sites
#'
#' @param sites site numbers. See [wq_sites()].
#'
#' @return a data.frame of water quality data for the sites. 
#' See [wq_data_desc()]
#' @export
#'
#' @examples
#' \dontrun{
#' wq_site_data(c("BC08NF0001", "BC08NM0160"))
#' }
wq_site_data <- function(sites) {
  sites_df <- wq_sites()
  if (!all(sites %in% sites_df$SITE_NO)) stop("Not a valid site ID. See wq_sites()")
  basins <- unique(sites_df$PEARSEDA[sites_df$SITE_NO %in% sites])
  basin_data_list <- lapply(basins, wq_basin_data)
  basin_data <- dplyr::bind_rows(basin_data_list)
  basin_data[basin_data$SITE_NO %in% sites, , drop = FALSE]
}
