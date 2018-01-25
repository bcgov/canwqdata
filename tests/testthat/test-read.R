context("Test reading data")

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

