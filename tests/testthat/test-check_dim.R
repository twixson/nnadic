test_that("check_dim() correctly identifies matching dimensions", {
  expect_equal(check_dim(matrix(rnorm(1000), 500)), TRUE)
})
