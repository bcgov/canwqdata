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

get_wq_sites <- function() {
  ret <- get_metadata_file("Water-Qual-Eau-Sites-National")
  # Get rid of weird encoding artifacts
  ret <- dplyr::mutate_if(ret, is.character, 
                          function(x) gsub("\u0096", "-", x))
  ret
}

get_wq_params <- function() {
  get_metadata_file("Water-Qual-Eau-VariableInfo")
}

get_wq_param_desc <- function() {
  get_metadata_file("Water-Qual-Eau-TableDescriptions")
}

get_basin <- function(site_no) {
  sites <- get_wq_sites()
  basin <- sites$PEARSEDA[sites$SITE_NO == site_no][1]
  basin
  
}