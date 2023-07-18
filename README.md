
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

The `nnadic` package requires the `nnadicTestData` package which has
290Mb of data in it. This can take a while to download. Some users have
found that the previous installation instructions do not work and
instead needed to use:

``` r
options(timeout = 400)
devtools::install_github("twixson/nnadic")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(nnadic)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
