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

wq_sites <- memoise::memoise(wq_sites_)

get_wq_params <- function() {
  get_metadata_file("Water-Qual-Eau-VariableInfo")
}

get_wq_param_desc <- function() {
  get_metadata_file("Water-Qual-Eau-TableDescriptions")
}

get_basins <- function(site_nums) {
  sites <- wq_sites()
  basins <- unique(sites$PEARSEDA[sites$SITE_NO %in% site_nums])
  basins
}

pt_basins <- function(prov_terr = c("AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", 
                                          "QC", "SK", "US", "YT")) {
  prov_terr <- match.arg(prov_terr, several.ok = TRUE)
  sites <- wq_sites()
  sites <- sites$SITE_NO[sites$PROV_TERR %in% prov_terr]
  get_basins(sites)
}

# get_basin_dl_link <- function(basins
