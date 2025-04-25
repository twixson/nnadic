#' Get dataset into format needed for `nnadic()`'s prediction
#'
#' Input your bivariate data and get out the 500 most extreme (by l-infinity
#'   norm) points.
#'   The function defaults to providing 100 datasets. These 100 datasets can be
#'   copies if your data has exactly 10,000 points or if `subsample = FALSE` and
#'   your data have more than 10,000 points without l-infinity norm ties at the
#'   0.95 quantile. If there are ties in the previous cases then the 100
#'   returned data sets will differ on a small number of points. These points
#'   are the tied points which are sampled for inclusion in each dataset.
#'   If your data have less than 10,000 points the top five percent are
#'   re-sampled up to 500 points 100 different times.
#'   Note that all datasets will show 1000 points as the 500 largest points are
#'   repeated, with reflection, to enforce symmetry in all datsets. This makes
#'   all `nnadic()` predictions invariant to components of the random vector.
#'
#' @param data a matrix with two columns
#' @param make_exponential Change to `FALSE` if the data
#'   already have exponential margins. (defaults to `TRUE`)
#' @param subsample Change to `FALSE` if the dataset has at least than 10,000
#'   points and you want to take the top 500 points rather than subsample all
#'   points above the 0.95 quantile. (defaults to `TRUE`)
#' @param num_datasets The number of output datasets (defaults to `100`)
#' @param include_all If there are fewer than 10,000 points in your data should
#'   all of the top five percent be included in every dataset as many times as
#'   possible (`TRUE`) or should all 500 points be from resampling (`FALSE`)?
#'   (defaults to `TRUE`)
#' @param comp_lag If your data is a univariate time series the function will
#'   automatically lag it so that it becomes bivariate. This allows you to
#'   change the lag. (defaults to `1`)
#'
#' @return an `array` of dimension `c(num_datasets, 1000, 2)` which can be input
#'   into `nnadic()` for prediction.
#' @export
#'
#' @examples
#' my_favorite_data <- matrix(rnorm(20000), nrow = 10000)
#' get_nnadic_input(my_favorite_data)
get_nnadic_input <- function(data,
                             make_exponential = TRUE,
                             subsample = TRUE,
                             num_datasets = 100,
                             include_all = TRUE,
                             comp_lag = 1) {
  nnadic_input <- array(NA, dim = c(num_datasets, 500, 2))
  tie_indices <- NULL
  if(is.null(dim(data))) {
    print(paste0("I assume this is a time series and am considering lag-",
                 comp_lag))
    data <- matrix(c(data[1:(length(data)-comp_lag)],
                     data[(comp_lag + 1):length(data)]),
                   ncol = 2,
                   byrow = FALSE)
  }
  if(dim(data)[2] == 2) {
    if(make_exponential == TRUE){
      print("...transforming to exponential marginal distributions")
      print("...   estimated gpd parameters in the marginal transformation were: ")
      data <- apply(data, 2, transform_to_exponential)
    }
    linfinity <- apply(data, 1, max)
    if(length(linfinity) > 10000){
      print("...more than 10000 points detected")
      if(subsample == TRUE) {
        print("...\"subsample = TRUE\" including all points greater than the 0.95 quantile")
        cutoff_value <- stats::quantile(linfinity, probs = 0.95)
      } else {
        print("...\"subsample = FALSE\" including the largest 500 points")
        cutoff_value <- max(stats::quantile(linfinity, probs = 0.95),
                           (sort(linfinity, decreasing = T)[500]))
      }
    } else if(length(linfinity) == 10000){
      print("...exactly 10000 points detected, points above the 0.95 quantile")
      print("...   will be retained")
      cutoff_value <- max(stats::quantile(linfinity, probs = 0.95),
                          (sort(linfinity, decreasing = T)[500]))
    } else {
      print("...fewer than 10000 points detected, points above the 0.95 quantile")
      print("...   will be resampled")
      cutoff_value <- max(stats::quantile(linfinity, probs = 0.95),
                          (sort(linfinity, decreasing = T)[500]))
    }
    temp_indices <- which(linfinity >= cutoff_value)
    print(paste0("...   ", length(temp_indices), " large points identified"))
    if(dim(data)[1] > 10000 && length(temp_indices) < 500){
      print("...ties at the cutoff were detected")
      tie_indices <- which(linfinity == cutoff_value)
    }
    if(length(temp_indices) == 500){
      indices_mat <- matrix(temp_indices, nrow = 500)
      print(paste0("...all ", num_datasets, " datasets are the same: the 500 largest points."))
      for(i in 1:num_datasets){
        nnadic_input[i, , ] <- data[indices_mat[, 1], ]
      }
    } else {
      indices_mat <- resample_to_500(temp_indices,
                                     tie_indices. = tie_indices,
                                     subsample. = subsample,
                                     num_datasets. = num_datasets,
                                     include_all. = include_all)
      for(i in 1:num_datasets){
        nnadic_input[i, , ] <- data[indices_mat[, i], ]
      }
    }

    symmetric_nnadic_input <- make_symmetric(nnadic_input)
    print("...each dataset was made symmetric and now has 1000 points.")
    return(symmetric_nnadic_input)
  } else {
    stop("ERROR: This data matrix has more than two columns,
         input only the two columns you want to compare")
  }
}

#' Transform marginal distribution to unit exponential
#'
#' @param data a vector of observations
#'
#' @return a vector with unit exponential marginal distribution
#' @export
#'
#' @examples
#' my_favorite_data <- matrix(rnorm(20000), nrow = 10000)
#' exp_margins <- my_favorite_data
#' exp_margins[,1] <- transform_to_exponential(my_favorite_data[,1])
transform_to_exponential <- function(data) {
  if(is.null(dim(data))){
    unif_margins <- rep(NA, length(data))
    gpd_quant    <- quantile(data, prob = 0.95)
    ecdf_indices <- which(data <= gpd_quant)
    gpd_indices  <- which(data > gpd_quant)
    gpd_params   <- evd::fpot(data, threshold = gpd_quant, model = "gpd")$estimate

    unif_margins[ecdf_indices] <- ecdf(data)(data[ecdf_indices])
    unif_margins[gpd_indices]  <- 0.95 + 0.05 * evd::pgpd(data[gpd_indices],
                                                          loc = gpd_quant,
                                                          scale = gpd_params[1],
                                                          shape = gpd_params[2])
    print(paste0("...  ...location: ", round(gpd_quant, 3), "   scale: ", round(gpd_params[1], 3), "   shape: ", round(gpd_params[2], 3)))
    exp_margins <- qexp(unif_margins)
  } else {
    stop("ERROR: This is not a vector.
         Use this function on each column/variable as a vector")
  }
  return(exp_margins)
}



resample_to_500 <- function(indices,
                            tie_indices. = NULL,
                            subsample.,
                            num_datasets.,
                            include_all.){
  if(!is.null(dim(indices))){
    stop("ERROR: Need a vector of indices")
  }

  len <- length(indices)
  indices_matrix <- matrix(NA, nrow = 500, ncol = num_datasets.)
  num_included <- 0

  if(len < 500){
    if(!is.null(tie_indices.)){
      indices_matrix[1:len, ] <- indices
      for(i in 1:num_datasets.){
        indices_matrix[(len+1):500, i] <- sample(tie_indices., 500 - len)
      }
      print(paste0("...subsampled indices of tied points ",
                   num_datasets., " times so"))
      print("...   that each dataset has exactly 500 points.")
      return(indices_matrix)
    }
    if(include_all. == TRUE){
      num_included <- floor(500 / len) * len
      indices_matrix[1:num_included, ] <- indices
      print(paste0("...the first ", num_included, " points in each dataset"))
      print("...   are the top 5% of points (repeated when possible).")
      if(num_included == 500){
        return(indices_matrix)
      }
    }
    for(i in 1:num_datasets.){
      sampling_num <- 500 - num_included
      indices_matrix[(num_included + 1):500, i] <- sample(indices,
                                                          sampling_num,
                                                          replace = TRUE)
    }
    print(paste0("...the rest of the points were subsampled so that all ", num_datasets.))
    print("...   datasets have 500 points.")
    return(indices_matrix)
  } else if(subsample. == FALSE){
    if(len == 500) {
      indices_matrix[1:500, ] <- indices
      print(paste0("...all ", num_datasets., " datasets are the same: the 500 largest points."))
      return(indices_matrix)
    } else {
      stop("ERROR: more than 500 present but subsample is FALSE")
    }
  } else {
    for(i in 1:num_datasets.){
      indices_matrix[,i] <- sample(indices, 500, replace = TRUE)
    }
    print(paste0("...points above the 0.95 quantile were subsampled ", num_datasets., " times"))
    print("...   so that each dataset has exactly 500 points.")
    return(indices_matrix)
  }
}

#' Make the data symmetric by copying points with swapped coordinates
#'
#' This function takes the 500 largest points $(X,Y)$ and appends the same
#'  points after reflection across the identity line $(Y, X)$. This ensures all
#'  input datasets are symmetric and the `nnadic()` classification probabilities
#'  are invariant to the order of the components in the random vector.
#'
#' @param data the matrix or array including dataset(s) of the largest 500 points
#'
#' @return an array with 1000 points for each dataset.
#' @export
#'
#' @examples
#' largest_500 <- matrix(rnorm(1000), nrow = 500)
#' symmetric_nnadic_input <- make_symmetric(largest_500)
make_symmetric <- function(data) {
  if(length(dim(data)) == 3){
    temp_array               <- array(NA, dim = c(dim(data)[1], 1000, 2))
    temp_array[, 1:500, ]    <- data
    temp_array[, 501:1000, ] <- data[,, c(2,1)]
  } else if(length(dim(data)) == 2){
    temp_array               <- array(NA, dim = c(1, 1000, 2))
    temp_array[1, 1:500, ]    <- data
    temp_array[1, 501:1000, ] <- data[, c(2,1)]
  } else {
    stop("ERROR: did not input a matrix or an array to make_symmetric")
  }
  return(temp_array)
}
