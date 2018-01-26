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
  out <- basin_folders()
  expect_identical(names(out), c("name", "last modified"))
})

test_that("basin_url works", {
  skip_on_cran()
  fraser <- basin_url("fraser")
  expect_is(fraser, "character")
  expect_length(fraser, 1)
  expect_true(grepl("fraser", fraser))
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
  
  expect_identical(no_accent, read_canwq_csv(testdata_raw))
  expect_identical(accent, read_canwq_csv(testdata_raw_accent))
})
