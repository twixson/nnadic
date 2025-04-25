#' Check if dimension of input data matches needed dimensions for `nnadic`
#'
#' @param data
#' A matrix of input data
#'
#' @return A `logical` indicating if dimensions match
#' @export
#'
#' @examples
#' check_dim(matrix(rnorm(2000), 1000))
#' check_dim(matrix(rnorm(2000), 2))
#' a <- matrix(rnorm(100), 50)
#' check_dim(a)
#' b <- matrix(0, 1000, 2)
#' check_dim(b)
#' c <- array(0, dim = c(1000, 2, 1))
#' check_dim(c)
check_dim <- function(data) {
  isTRUE(all.equal(dim(data), c(1000, 2)))
}
