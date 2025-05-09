% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep_data.R
\name{check_dim}
\alias{check_dim}
\title{Check if dimension of input data matches needed dimensions for \code{nnadic}}
\usage{
check_dim(data)
}
\arguments{
\item{data}{A matrix of input data}
}
\value{
A \code{logical} indicating if dimensions match
}
\description{
Check if dimension of input data matches needed dimensions for \code{nnadic}
}
\examples{
check_dim(matrix(rnorm(2000), 1000))
check_dim(matrix(rnorm(2000), 2))
a <- matrix(rnorm(100), 50)
check_dim(a)
b <- matrix(0, 1000, 2)
check_dim(b)
c <- array(0, dim = c(1000, 2, 1))
check_dim(c)
}
