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

wq_sites_ <- function() {
  ret <- get_metadata_file("Water-Qual-Eau-Sites-National")
  # Get rid of weird encoding artifacts
  ret <- dplyr::mutate_if(ret, is.character, 
                          function(x) gsub("\u0096", "-", x))
  ret
}

#' Get a table of water quality monitoring sites
#'
#' @return a data.frame of monitoring sites
#' @export
wq_sites <- memoise::memoise(wq_sites_)

wq_params_ <- function() {
  get_metadata_file("Water-Qual-Eau-VariableInfo", 
                    cols = readr::cols(.default = readr::col_character()))
}

#' Get a table of water quality parameters
#'
#' @return a data.frame of parameters
#' @export
wq_params <- memoise::memoise(wq_params_)

wq_data_desc_ <- function() {
  get_metadata_file("Water-Qual-Eau-TableDescriptions")
}

#' Get a table of water quality parameter descriptions
#'
#' @return a data.frame of parameter descriptions
#' @export
wq_data_desc <- memoise::memoise(wq_data_desc_)

#' Get a list of basins for a Province or Territory.
#'
#' @param prov_terr one or more Province/Territory abbreviations
#'
#' @return a character vector of basin names
#' @export
#'
#' @examples
#' \dontrun{
#'   wq_basins_pt(c("BC", "AB"))
#' }
wq_basins_pt <- function(prov_terr = c("AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", 
                                    "QC", "SK", "US", "YT")) {
  prov_terr <- match.arg(prov_terr, several.ok = TRUE)
  sites_df <- wq_sites()
  unique(sites_df$PEARSEDA[sites_df$PROV_TERR %in% prov_terr])
}

wq_basin_data_ <- function(basin) {
  basin_resource <- basin_csv_url(basin)
  full_url <- safe_make_url(base_url(), basin_resource$path)
  res <- httr::GET(full_url, if (interactive()) httr::progress("down") else NULL)
  httr::stop_for_status(res)
  content <- httr::content(res, as = "raw", type = basin_resource$format)
  
  read_canwq_csv(content)
}

#' Download water quality data for a basin
#'
#' @param basin the name of a basin. 
#' An easy way to get a list of basins is to use the [wq_basins_pt()]
#' function
#'
#' @return a data.frame of all the water quality monitoring data from that basin.
#' @export
wq_basin_data <- memoise::memoise(wq_basin_data_)

#' Download water quality data for a site or multiple sites
#'
#' @param sites site numbers. See [wq_sites]().
#'
#' @return a data.frame of water quality data for the sites. 
#' See [wq_data_desc()]
#' @export
#'
#' @examples
#' \dontrun{
#' wq_site_data(c("NW10OB0003", "NB01AJ0008"))
#' }
wq_site_data <- function(sites) {
  sites_df <- wq_sites()
  if (!all(sites %in% sites_df$SITE_NO)) stop("Not a valid site ID. See wq_sites()")
  basins <- unique(sites_df$PEARSEDA[sites_df$SITE_NO %in% sites])
  basin_data_list <- lapply(basins, wq_basin_data)
  basin_data <- dplyr::bind_rows(basin_data_list)
  basin_data[basin_data$SITE_NO %in% sites, , drop = FALSE]
}
