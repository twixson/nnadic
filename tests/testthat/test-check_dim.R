test_that("check_dim() returns TRUE for matching dimensions", {
  expect_equal(check_dim(matrix(rnorm(2000), 1000)), TRUE)
  expect_equal(check_dim(matrix(0, 1000, 2)), TRUE)
  expect_equal(check_dim(data.frame(matrix(0, 1000, 2))), TRUE)
  expect_equal(check_dim(array(0, dim = c(1000, 2))), TRUE)
})

test_that("check_dim() returns FALSE for dimensions that don't match", {
  expect_equal(check_dim(matrix(0, 500, 2)), FALSE)
  expect_equal(check_dim(matrix(0, 2, 1000)), FALSE)
})

test_that("check_dim() returns FALSE for differing number of dimensions", {
  expect_equal(check_dim(array(0, dim = c(1000, 2, 1))), FALSE)
  expect_equal(check_dim(array(0, dim = c(20, 2))), FALSE)
})

test_that("check_dim() returns FALSE for wrong data type", {
  expect_equal(check_dim("This is a string"), FALSE)
  expect_equal(check_dim(c(1000, 2)), FALSE)
  expect_equal(check_dim(list(a = 1000, b = 2)), FALSE)
})
