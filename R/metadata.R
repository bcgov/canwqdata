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
#' pt_basins(c("BC", "AB"))
pt_basins <- function(prov_terr = c("AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", 
                                          "QC", "SK", "US", "YT")) {
  prov_terr <- match.arg(prov_terr, several.ok = TRUE)
  sites_df <- wq_sites()
  unique(sites_df$PEARSEDA[sites_df$PROV_TERR %in% prov_terr])
}

# get_basin_dl_link <- function(basins
