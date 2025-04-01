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

#' Find the links to csvs for the basins.
#' @importFrom memoise memoise
#' @noRd

basin_csvs_ <- function() {
  basin_csvs <- wq_sites() |>
    dplyr::select(csv_path)

  basin_csvs
}

basin_csvs <- memoise::memoise(basin_csvs_)

#' Given a basin name (ideally from wq_sites()$PEARSEDA) get the csv paths
#'
#' @param basin 
#'
#' @noRd
basin_csv_url <- function(basin) {
  basin_csvs_file <- basin_csvs()
  basin_csvs_clean <- apply(wq_sites()[,"PEARSEDA"], 1, clean_names)
  
  basin_clean <- clean_names(basin)
  basin_resource <- basin_csvs_file[basin_csvs_clean == basin_clean, , drop = FALSE]
  if (!nrow(basin_resource)) 
    stop("Unable to find data for ", basin, " basin")
  
  basin_resource <- basin_resource[!duplicated(basin_resource), , drop = TRUE]
  
  basin_resource
}

clean_names <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z]+", "-", x)
  x <- gsub("(-and-)?(river)?(basin)?(long-term.+data)?(canada-s-north)?(lower-mainland)?(island)?", "", x)
  x <- gsub("waterqualeau.+csv", "", x)
  x <- gsub("-+(water-qual.+csv$)?", "", x)
  x
}

#' Read a csv from the website. 
#'
#' @param x 
#'
#' @noRd
read_canwq_csv <- function(x) {
  nms <- names(suppressMessages(
    readr::read_csv(x, n_max = 1, locale = readr::locale(encoding = "Latin1")) # Zhuoyan used "Latin1" because errors occur when using other encoding methods.
  ))
  nms[grepl("^UNIT_", nms)] <- "UNIT_UNITE"
  nms[grepl("^SAMPLE_ID_", nms)] <- "SAMPLE_ID_ECHANTILLON"
  
  ret <- suppressWarnings(readr::read_csv(x, 
                         locale = readr::locale(encoding = "Latin1"),  
                         col_types = readr::cols(
                           SITE_NO = readr::col_character(),
                           DATE_TIME_HEURE = readr::col_datetime(format = "%Y-%m-%d %H:%M"),
                           FLAG_MARQUEUR = readr::col_character(),
                           VALUE_VALEUR = readr::col_double(),
                           SDL_LDE = readr::col_double(),
                           MDL_LDM = readr::col_double(),
                           VMV_CODE = readr::col_character(),
                           UNIT_UNITE = readr::col_character(),
                           VARIABLE = readr::col_character(),
                           VARIABLE_FR = readr::col_character(),
                           STATUS_STATUT = readr::col_character(),
                           SAMPLE_ID_ECHANTILLON = readr::col_character()
                         ), 
                         col_names = nms, 
                         skip = 1L))
  
  ret$UNIT_UNITE <- stringi::stri_trans_general(ret$UNIT_UNITE, "latin-ascii")
  ret$UNIT_UNITE <- stringr::str_replace_all(ret$UNIT_UNITE, "A", "")
  # Zhuoyan found some issues relating to parsing  
  prblm_data <- suppressMessages(suppressWarnings((readr::problems(vroom::vroom(x)))))
  # Following codes are to address the poorly formatted English and French names, but still not able to split English and French names into separate columns.
  if (nrow(prblm_data)!=0 & any(grepl("columns", prblm_data$expected, fixed = TRUE))) {
    prblm_row <- prblm_data[grepl("columns", prblm_data$expected, fixed = TRUE),"row"] 
    paste_data <- apply(ret[(prblm_row$row-1),c("VARIABLE", "VARIABLE_FR", "STATUS_STATUT", "SAMPLE_ID_ECHANTILLON")], 1 , paste , collapse = "" )
    ret[(prblm_row$row-1),"VARIABLE"] <-stringr::str_split_fixed(paste_data, "\"", 3)[,1]
    ret[(prblm_row$row-1),"VARIABLE_FR"] <-stringr::str_split_fixed(paste_data, "\"", 3)[,1]
    ret[(prblm_row$row-1),"STATUS_STATUT"] <- stringr::str_replace_all(stringr::str_split_fixed(paste_data, "\"", 3)[,2],
                                                                       "[^[:alnum:]]", "")
    ret[(prblm_row$row-1),"SAMPLE_ID_ECHANTILLON"] <- stringr::str_replace_all(stringr::str_split_fixed(paste_data, "\"", 3)[,3],
                                                                               "[^[:alnum:]]", "")
  }
  #Remove "Ã\u0089" and "Ã\u0088" from English and French names
  ret$VARIABLE <- stringi::stri_trans_general(ret$VARIABLE, "latin-ascii")
  ret$VARIABLE_FR <- stringi::stri_trans_general(ret$VARIABLE_FR, "latin-ascii")
  
  ret$VARIABLE <- stringr::str_replace_all(ret$VARIABLE, "A\u0089", "")
  ret$VARIABLE <- stringr::str_replace_all(ret$VARIABLE, "A\u0088", "")
  ret$VARIABLE_FR <- stringr::str_replace_all(ret$VARIABLE_FR, "A\u0089", "")
  ret$VARIABLE_FR <- stringr::str_replace_all(ret$VARIABLE_FR, "A\u0088", "")
  
  ret
}

# NOT CURRENTLY USED: Could be, but need some work to clean up names... the parsing of the first row in 
# read_canwq_csv works well enough for now
# col_types_from_eccc_schema <- function(schema) {
#   out <- lapply(schema, \(x) {
#     switch(x$type, 
#            string = readr::col_character(),
#            integer = readr::col_integer(), 
#            number = readr::col_double()
#     )
#   })
#   
#   names(out) <- vapply(schema, `[[`, "name", FUN.VALUE = character(1))
#   out[grepl("DATE_TIME", names(out))][[1]] <- readr::col_datetime(format = "%Y-%m-%d %H:%M")
#   out
# }
