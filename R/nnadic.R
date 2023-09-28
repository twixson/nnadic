#' Neural Network for Asymptotic Dependence/Independence Classification
#'
#' @param data a matrix of dimension \eqn{d}x\eqn{2}.
#'  Currently only supports \eqn{d=500}
#'
#' @return a `list` with two items:
#'  1) probs - a vector of probabilities of being AI
#'  2) preds - a vector of predictions (0 is AD, 1 is AI)
#' @export
#'
#' @examples
#' nnadic(matrix(rnorm(1000), ncol = 2))
nnadic <- function(data, make_hist = TRUE){
  results <- list()
  results$probs <- stats::predict(object = model, data)
  results$preds <- ifelse(probabilities >= 0.5, 1, 0)
  results$mean  <- mean(preds)
  if(make_hist){
    hist(results$probs)
  }
  print(paste0("The mean of the predictions is: ", results$mean,
               " which is `nnadic`'s probability that these data are AI"))
  print("Probabilities and predictions for each dataset have been returned")
  return(results)
}
