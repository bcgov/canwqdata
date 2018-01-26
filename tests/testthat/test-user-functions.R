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
  param_desc <- wq_param_desc()
  expect_is(param_desc, "data.frame")
  expect_gt(nrow(param_desc), 30)
})

test_that("wq_sites works", {
  skip_on_cran()
  sites <- wq_sites()
  expect_is(sites, "data.frame")
  expect_gt(nrow(sites), 200)
})

test_that("pt_basins works", {
  skip_on_cran()
  bc_basins <- pt_basins("BC")
  expect_is(bc_basins, "character")
  expect_true("PEACE-ATHABASCA" %in% bc_basins)
})

test_that("dl_basin works", {
  skip_on_cran()
  keewatin <- dl_basin("KEEWATIN-SOUTHERN BAFFIN")
  expect_is(keewatin, "data.frame")
  expect_equal(names(keewatin), names(read.csv("testdata.csv", header = T, nrows = 1)))
})

test_that("dl_sites works", {
  skip_on_cran()
  site_data <- dl_sites("NW06MA0001")
  expect_is(site_data, "data.frame")
  expect_equal(unique(site_data$SITE_NO), "NW06MA0001")
})
