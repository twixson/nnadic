#' Computes the confusion matrix for a given threshold
#'
#' @details
#' Confusion matrix is:
#'
#'  True Negative | False Negative
#'
#'  False Positive | True Positive
#'
#'
#' @param pred_prob the "probabilities" returned from `nnadic()`
#' @param truth. the true classifications (a vector of zeros and ones)
#' @param t_hold what the cutoff is for classifying a dataset as AI
#'
#' @return the confusion matrix as a 2x2 `matrix` object
#' @export
#'
#' @examples
#' predicted_probs <- nnadic(test_data)
#' get_confusion_matrix(pred_prob = predicted_prob, truth = test_response)
get_confusion_matrix <- function(pred_prob,
                                 truth.,
                                 t_hold = 0.5) {
  predicted_class <- ifelse(pred_prob > t_hold, 1, 0)
  conf_mat <- matrix(table(predicted_class, truth.), ncol = 2)
  if(sum(dim(conf_mat)) < 4) conf_mat <- rbind(conf_mat, c(0,0))
  return(conf_mat)
}

#' Computes the true positive rate and false positive rate from a confusion
#'  matrix
#'
#' @param conf_mat confusion matrix, often the output from
#'  `get_confusion_matrix()`
#'
#' @return a vector with two values, the false positive rate (fpr) and the true
#'  positive rate (tpr) in that order.
#' @export
#'
#' @examples
#' confusion_matrix <- get_confusion_matrix(pred_prob = predicted_prob,
#'                                          truth = test_response)
#' get_tpr_fpr(conf_mat = confusion_matrix)
get_tpr_fpr <- function(conf_mat) {
  tpr <- conf_mat[2, 2] / (conf_mat[2, 2] + conf_mat[1, 2])
  fpr <- conf_mat[2, 1] / (conf_mat[2, 1] + conf_mat[1, 1])
  c(fpr, tpr)
}

#' Compute the ROC (receiver operating characteristic) curve for 200 evenly
#'  spaced thresholds
#'
#' @param predicted_probabilities the "probabilities" returned from `nnadic()`
#' @param truth the true classifications (a vector of zeros and ones)
#' @param make_plot set to `TRUE` if you want an ROC plot to be auto-generated.
#'  Default is `FALSE`
#' @param add_auc set to `TRUE` if you want the AUC (area under the curve)
#'  added to the ROC plot. Default is `FALSE`. Does nothing if set to `TRUE`
#'  while `make_plot = FALSE`.
#'
#' @return a matrix of false and true positive rates (FPR, TPR)
#' @export
#'
#' @examples
#' predicted_probs <- nnadic(test_data)
#' roc <- get_roc(predicted_probabilities = predicted_prob,
#'                truth = test_response,
#'                make_plot = TRUE,
#'                add_auc = TRUE)
get_roc <- function(predicted_probabilities, truth,
                    make_plot = FALSE, add_auc = FALSE) {
  roc <- matrix(NA, nrow = 200, ncol = 2)
  thresholds <- seq(0, 1, length.out = 200)
  for(i in 1:200) {
    temp_confusion <- get_confusion_matrix(pred_prob = predicted_probabilities,
                                           truth. = truth,
                                           t_hold = thresholds[i])
    roc[i,] <- get_tpr_fpr(conf_mat = temp_confusion)
  }
  if(make_plot){
    plot(roc, type = "l",
         ylim = c(0, 1), ylab = "TPR",
         xlim = c(0, 1), xlab = "FPR")
    abline(a = 0, b = 1, col = 2, lty = 2)
    if(add_auc){
      temp_text <- paste0("AUC = ", get_auc(roc. = roc))
      legend("bottomright", legend = temp_text, bty = "n")
    }
  }
  return(roc)
}

#' Computes the area under the curve from `get_roc()` output
#'
#' @param roc. Nx2 matrix of false and true positive rates, often the output
#'  from `get_roc()`
#'
#' @return A value between zero and one which represents the area under the ROC
#'  curve
#' @export
#'
#' @examples
#' predicted_probs <- nnadic(test_data)
#' roc <- get_roc(predicted_probabilities = predicted_prob,
#'                truth = test_response,
#'                make_plot = TRUE,
#'                add_auc = TRUE)
#'get_auc(roc)
get_auc <- function(roc.) {
  num_points <- dim(roc.)[1]
  auc <- 0
  for(i in 1:(num_points-1)){
    temp_x <- roc.[i, 1] - roc.[(i+1), 1]
    temp_y <- mean(roc.[i:(i+1), 2])
    auc <- auc + temp_x * temp_y
  }
  return(round(auc, 4))
}

#' Computes the Brier Score
#'
#' @param predicted_probabilities the "probabilities" returned from `nnadic()`
#' @param truth the true classifications (a vector of zeros and ones)
#'
#' @return a value between zero and one that is equivalent to the MSE
#' @export
#'
#' @examples
#' predicted_probs <- nnadic(test_data)
#' get_brier(predicted_probabilities = predicted_prob,
#'                truth = test_response)
get_brier <- function(predicted_probabilities, truth) {
  N <- length(truth)
  brier_sum <- sum((predicted_probabilities - truth)^2)
  brier_sum/N
}
