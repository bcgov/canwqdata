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

context("utility functions")
library(httr)

test_that("clean_names works", {
  test_names <- c("foo-and-bar-river-basin-long-term-monitoring-data-canada-s-north", 
                  "foo-bar-island-long-term-water-quality-monitoring-data", 
                  "foobar-basin-long-term-water-quality-monitoring-data", 
                  "foo-bar-and-lower-mainland-long-term-water-quality-monitoring-data", 
                  "foo-and-bar-lower-mainland-island-river-basin-long-term-monitoring-data-canada-s-north")
  expect_identical(clean_names(test_names), 
                   rep("foobar", length(test_names)))
})

test_that("base_url works and is alive", {
  skip_on_cran()
  expect_true(identical(status_code(GET(base_url())), 200L))
})

test_that("basin_folders works", {
  skip_on_cran()
  out <- basin_csvs()
  expect_identical(names(out), c("path", "profile", "name", "format", "mediatype", "encoding", "resource_type", "schema"))
})

test_that("basin_url works", {
  skip_on_cran()
  fraser <- basin_csv_url("fraser")
  expect_is(fraser, "data.frame")
  expect_equal(nrow(fraser), 1)
  expect_true(grepl("fraser", fraser$path))
})

test_data <- "testdata.csv"
test_data_accent <- "testdata_accent.csv"
no_accent <- read_canwq_csv(test_data)
accent <- read_canwq_csv(test_data_accent)

test_that("read_canwq_csv works", {
  expect_identical(names(no_accent), 
                   c("SITE_NO", "DATE_TIME_HEURE", "FLAG_MARQUEUR", "VALUE_VALEUR", 
                     "SDL_LDE", "MDL_LDM", "VMV_CODE", "UNIT_UNITE", "VARIABLE", 
                     "VARIABLE_FR", "STATUS_STATUT"))
  expect_identical(names(no_accent), names(accent))
  expect_equal(lapply(no_accent, class), lapply(accent, class))
})

test_that("read_canwq_csv works with raw vectors", {
  testdata_raw <- charToRaw(readChar(test_data, 1000, useBytes = TRUE))
  testdata_raw_accent <- charToRaw(readChar(test_data_accent, 1000, useBytes = TRUE))
  
  expect_equal(no_accent, read_canwq_csv(testdata_raw))
  expect_equal(accent, read_canwq_csv(testdata_raw_accent))
})
