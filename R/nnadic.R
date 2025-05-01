#' Neural Network for Asymptotic Dependence/Independence Classification
#'
#'@param data an array of dimension \eqn{n}x\eqn{d}x\eqn{2}.
#'  Currently only supports \eqn{d=1000}. Use `get_nnadic_input()` to prepare
#'  your data.
#'@param one_test change to `FALSE` if there are multiple datasets in your test
#'  This can be used to test nnadic on simulated datasets where the truth is
#'  known or on multiple unknown datasets at the same time.
#'@param make_hist change to `FALSE` if you do not want a histogram of the
#'  probabilities to be returned.
#'@param verbose Switch to `FALSE` to skip comments. (defaults to `TRUE`)

#'
#' @return a `list` with two or three items:
#'  1) probs - a vector of probabilities of being AI
#'  2) preds - a vector of predictions (0 is AD, 1 is AI)
#'  3) mean  - the mean of the predictions, included when one_test is TRUE
#' @export
#'
#' @examples
#' nnadic(get_nnadic_input(matrix(rnorm(20000), ncol = 2)))
nnadic <- function(data, one_test = TRUE, make_hist = TRUE, verbose = TRUE){
  results <- list()
  results$probs <- stats::predict(object = model, data)
  results$preds <- ifelse(results$probs >= 0.5, 1, 0)
  if(make_hist){
    hist(results$probs)
  }
  if(verbose){
    print("Probabilities and predictions for each dataset are being returned")
    print("Each probability is the probability of AI which is coded as '1'")
  }

  if(one_test){
    results$mean  <- mean(results$preds)
    if(verbose){
      print("##################")
      print(paste0("The mean of the predictions is: ", results$mean))
      print("This is `nnadic`'s probability that these data are AI")
    }
  }

  return(results)
}
