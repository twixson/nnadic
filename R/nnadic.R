nnadic <- function(data){
  probabilities <- stats::predict(object = model, data)
  predictions <- ifelse(probabilities >= 0.5, "AI", "AD")
  list(probs = probabilities, preds = predictions)
}
