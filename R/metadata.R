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
  get_metadata_file("Water-Qual-Eau-VariableInfo")
}

#' Get a table of water quality parameters
#'
#' @return a data.frame of parameters
#' @export
wq_params <- memoise::memoise(wq_params_)

wq_param_desc_ <- function() {
  get_metadata_file("Water-Qual-Eau-TableDescriptions")
}

#' Get a table of water quality parameter descriptions
#'
#' @return a data.frame of parameter descriptions
#' @export
wq_param_desc <- memoise::memoise(wq_param_desc_)

#' Get a list of basins for a Province or Territory.
#'
#' @param prov_terr one or more Province/Territory abbreviations
#'
#' @return a character vector of basin names
#' @export
#'
#' @examples
#' \dontrun{
#'   pt_basins(c("BC", "AB"))
#' }
pt_basins <- function(prov_terr = c("AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", 
                                    "QC", "SK", "US", "YT")) {
  prov_terr <- match.arg(prov_terr, several.ok = TRUE)
  sites_df <- wq_sites()
  unique(sites_df$PEARSEDA[sites_df$PROV_TERR %in% prov_terr])
}

dl_basin_ <- function(basin) {
  url <- basin_url(basin)
  resources <- get_resources_df(folder = url)
  resource <- resources[grepl("^Water-Qual.+present", resources[["name"]]), ]
  full_url <- safe_make_url(base_url(), url, resource$path)
  res <- httr::GET(full_url, httr::progress("down"))
  httr::stop_for_status(res)
  ret <- readr::read_csv(httr::content(res, as = "raw", type = resource$format), 
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
                    UNIT_UNITÉ = readr::col_character(),
                    VARIABLE = readr::col_character(),
                    VARIABLE_FR = readr::col_character(),
                    STATUS_STATUT = readr::col_character()
                  ))
  names(ret)[names(ret) == "UNIT_UNITÉ"] <- "UNIT_UNITE"
  ret
}

#' Download water quality data for a basin
#'
#' @param basin the name of a basin. 
#' An easy way to get a list of basins is to use the \code{\link{pt_basins}}
#' function
#'
#' @return a data.frame of all the water quality monitoring data from that basin.
#' @export
dl_basin <- memoise::memoise(dl_basin_)

#' Download water quality data for a site
#'
#' @param site site number. See \code{\link{wq_sites}}.
#'
#' @return a data.frame of water quality data for the site. See \code{\link{wq_param_desc}}
#' @export
#'
#' @examples
#' \dontrun{
#' dl_site("YT09FC0002")
#' }
dl_site <- function(sites) {
  sites_df <- wq_sites()
  if (!all(sites %in% sites_df$SITE_NO)) stop("Not a valid site ID. See wq_sites()")
  basins <- unique(sites_df$PEARSEDA[sites_df$SITE_NO %in% sites])
  basin_data_list <- lapply(basins, dl_basin)
  basin_data <- dplyr::bind_rows(basin_data_list)
  basin_data[basin_data$SITE_NO %in% sites, , drop = FALSE]
}
