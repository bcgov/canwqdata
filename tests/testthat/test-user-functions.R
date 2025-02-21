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

library(testthat)

context("user-facing functions")

test_that("wq_params works", {
  skip_on_cran()
  params <- wq_params()
  expect_is(params, "data.frame")
  expect_gt(nrow(params), 1000)
})

# keewatin

test_that("wq_param_desc works", {
  skip_on_cran()
  data_desc <- wq_data_desc()
  expect_is(data_desc, "data.frame")
  expect_gt(nrow(data_desc), 30)
})

test_that("wq_sites works", {
  skip_on_cran()
  sites <- wq_sites()
  expect_is(sites, "data.frame")
  expect_gt(nrow(sites), 30)
})

test_that("wq_basin_data works", {
  skip_on_cran()
  keewatin <- wq_basin_data("LOWER MACKENZIE")
  expect_is(keewatin, "data.frame")
  expect_equal(names(keewatin), names(read.csv("testdata.csv", header = T, nrows = 1, fileEncoding = "UTF-8")))
})

test_that("wq_site_data works", {
  skip_on_cran()
  site_data <- wq_site_data("BC08NL0001")
  expect_is(site_data, "data.frame")
  expect_equal(unique(site_data$SITE_NO), "BC08NL0001")
})
