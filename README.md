
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nnadic

<!-- badges: start -->
<!-- badges: end -->

The goal of nnadic (**N**eural **N**etwork for **A**symptotic
**D**ependence/**I**ndependence **C**lassification) is to classify
bivariate data sets as either asymptotically dependent or independent
using a trained convolutional neural network. The tool *will be* set up
to automatically:  
- transform the marginal distribution  
- take the top 5% of the data (using the $l_\infty$-norm)  
- resample or subsample as necessary to ensure the data is of the
correct dimension  
- output the predicted result from the neural network

There *will be* many customization options which allow the user to take
advantage of advanced functionality.

## Installation

You can install the development version of nnadic from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("twixson/nnadic")
```

Troubleshooting:

- The `nnadic` package requires the `nnadicTestData` package which has
  290Mb of data in it. Some users have found that they need to run
  `options(timeout = 400)` prior to installation.  
- The `nnadic` package requires a working `keras` installation. Some
  users have found that installing `keras` first is helpful.

Suggested install code:

``` r
install.packages("devtools")
install.packages("keras")
  # this may prompt you to install 'miniconda', follow the prompts
library(devtools)
library(keras)
install_keras()
options(timeout = 400)
install_github("twixson/nnadicTestData")
install_github("twixson/nnadic")
```

## Example

This is a basic example which shows you the common workflow:

``` r
library(nnadic)
library(nnadicTestData)
library(evd)      # for generating AD datasets (logistic)
library(mvtnorm)  # for generating AI datasets (gaussian)

results <- nnadic(test_data_four)
mean(results$preds == test_response_four)
#> [1] 0.9525
hist(results$probs, freq = F)
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

data <- rbvevd(10000, dep = 0.5, model = "log")
data_ready <- get_nnadic_input(data)
results <- nnadic(data_ready)
mean(results$preds) # should be 0
#> [1] 0

data <- rmvnorm(19834, c(0,0), matrix(c(1, 0.5, 0.5, 1), nrow = 2))
data_ready <- get_nnadic_input(data, subsample = TRUE)
results <- nnadic(data_ready)
mean(results$preds) # should be 1
#> [1] 1
```
