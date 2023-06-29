nnadic <- function(data){
  probabilities <- stats::predict(object = model, data)
  predictions <- ifelse(probabilities >= 0.5, 1, 0)
  list(probs = probabilities, preds = predictions)
}
