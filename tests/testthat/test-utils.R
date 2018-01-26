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
  expect_true(identical(status_code(GET(base_url())), 200L))
})

test_that("basin_folders works", {
  out <- basin_folders_()
  expect_identical(names(out), c("name", "last modified"))
})

test_that("basin_url works", {
  fraser <- basin_url("fraser")
  expect_is(fraser, "character")
  expect_length(fraser, 1)
  expect_true(grepl("fraser", fraser))
})
