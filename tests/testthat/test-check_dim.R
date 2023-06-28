test_that("check_dim() returns TRUE for matching dimensions", {
  expect_equal(check_dim(matrix(rnorm(1000), 500)), TRUE)
  expect_equal(check_dim(matrix(0, 500, 2)), TRUE)
  expect_equal(check_dim(data.frame(matrix(0, 500, 2))), TRUE)
  expect_equal(check_dim(array(0, dim = c(500, 2))), TRUE)
})

test_that("check_dim() returns FALSE for dimensions that don't match", {
  expect_equal(check_dim(matrix(0, 50, 2)), FALSE)
  expect_equal(check_dim(matrix(0, 2, 500)), FALSE)
})

test_that("check_dim() returns FALSE for differing number of dimensions", {
  expect_equal(check_dim(array(0, dim = c(500, 2, 1))), FALSE)
  expect_equal(check_dim(array(0, dim = c(20, 2))), FALSE)
})

test_that("check_dim() returns FALSE for wrong data type", {
  expect_equal(check_dim("This is a string"), FALSE)
  expect_equal(check_dim(c(500, 2)), FALSE)
  expect_equal(check_dim(list(a = 500, b = 2)), FALSE)
})
