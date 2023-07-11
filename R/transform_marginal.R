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
#'
#' @param data a matrix with two columns
#' @param make_exponential Change to `FALSE` if the data
#'   already have exponential margins. (defaults to `TRUE`)
#' @param subsample Change to `TRUE` if the dataset has
#'   at least than 10,000 points and you want to subsample all points above the
#'   0.95 quantile rather than take the top 500 points. (defaults to `FALSE`)
#' @param num_datasets The number of output datasets (defaults to `100`)
#' @param include_all If there are fewer than 10,000 points in your data should
#'   all of the top five percent be included in every dataset (`TRUE`) or should
#'   all 500 points be from resampling (`FALSE`)? (defaults to `TRUE`)
#' @param comp_lag If your data is a univariate time series the function will
#'   automatically lag it so that it becomes bivariate. This allows you to
#'   change the lag. (defaults to `1`)
#'
#' @return an `array` of dimension `c(num_datasets, 500, 2)` which can be input
#'   into `nnadic()` for prediction.
#' @export
#'
#' @examples
#' get_nnadic_input(my_favorite_data)
get_nnadic_input <- function(data,
                             make_exponential = TRUE,
                             subsample = FALSE,
                             num_datasets = 100,
                             include_all = TRUE,
                             comp_lag = 1) {
  nnadic_input <- array(NA, dim = c(num_datasets, 500, 2))
  tie_indices <- NULL
  if(is.null(dim(data))) {
    print(paste0("I assume this is a time series and am considering lag-",
                 comp_lag))
    data <- matrix(c(data[1:(length(data-comp_lag))],
                     data[(comp_lag + 1):length(data)]),
                   ncol = 2,
                   byrow = FALSE)
  }
  if(dim(data)[2] == 2) {
    if(make_exponential == TRUE){
      data <- apply(data, 2, transform_to_exponential)
    }
    linfinity <- apply(data, 1, max)
    if(length(linfinity) > 10000){
      if(subsample == TRUE) {
        cutoff_value <- stats::quantile(linfinity, probs = 0.95)
      }
    } else {
      cutoff_value <- max(stats::quantile(linfinity, probs = 0.95),
                          sort(linfinity)[500])
    }
    temp_indices <- which(linfinity > cutoff_value)
    if(dim(data)[1] > 10000 && length(temp_indices) < 500){
      tie_indices <- which(linfinity == stats::quantile(linfinity, probs = 0.95))
    }
    indices_mat <- resample_to_500(temp_indices,
                                   tie_indices. = tie_indices,
                                   subsample. = subsample,
                                   num_datasets. = num_datasets,
                                   include_all. = include_all)
    for(i in 1:num_datasets){
      nnadic_input[i, , ] <- data[indices_mat[, i], ]
    }
    return(nnadic_input)
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

    exp_margins <- qexp(unif_margins)
  } else {
    stop("ERROR: This is not a vector.
         Use this function on each column/variable as a vector")
  }
  return(exp_margins)
}



resample_to_500 <- function(indices,
                            tie_indices.,
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
        indices_matrix[len+1:500, i] <- sample(tie_indices., 500 - len)
      }
      return(indices_matrix)
    }
    if(include_all. == TRUE){
      num_included <- floor(500 / len) * len
      indices_matrix[1:num_included, ] <- indices
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
    return(indices_matrix)
  } else if(subsample. == FALSE){
    if(len == 500) {
      indices_matrix[1:500, ] <- indices
      return(indices_matrix)
    } else {
      stop("ERROR: more than 500 present but subsample is FALSE")
    }
  } else {
    for(i in 1:num_datasets.){
      indices_matrix[,i] <- sample(indices, 500, replace = TRUE)
    }
    return(indices_matrix)
  }
}


