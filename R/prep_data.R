check_dim <- function(data) {
  isTRUE(all.equal(dim(data), c(500, 2)))
}
