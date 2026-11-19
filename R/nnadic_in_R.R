#####
# This script takes the weights from the keras model object and creates a base
#     R function to perform prediction, create feature maps, etc.
#####

all_weights <- readRDS("./inst/pretrained_models/published_weights.rds")

#' Neural Network for Asymptotic Dependence/Independence Classification
#'
#' Classifies datasets as AInd or ADep. Can take a single data set or several.
#'    Data must be in proper format before inputting into `nnadic`, use
#'    `get_nnadic_input()` to prepare your data.
#'
#'@param data an array of dimension \eqn{n}x\eqn{d}x\eqn{2}.
#'  Currently only supports \eqn{d=1000}. Use `get_nnadic_input()`
#'  to prepare your data.
#'@param prob_AInd_only Switch to `TRUE` to only return probability AInd.
#'  Leave as `FALSE` to also return the classification ("AD" or "AI) and the
#'  feature matrix. (defaults to `FALSE`)
#'@param verbose Switch to `TRUE` to display comments. (defaults to `FALSE`)

#'
#' @return a `list` with two or three items:
#'  1) probs - the probability of being AI
#'  2) preds - the predictions ("AD" or "AI")
#'  3) features - \eqn{1000}x\eqn{32} matrix of \eqn{32} features.
#' @export
#'
#' @examples
#' nnadic(get_nnadic_input(matrix(rnorm(20000), ncol = 2)))
nnadic <- function(data, prob_AInd_only = FALSE, verbose = FALSE){
  temp     <- nn_layer(data, w = all_weights$w1[1,,], b = all_weights$b1)
  temp     <- nn_layer(temp, w = all_weights$w2[1,,], b = all_weights$b2)
  features <- nn_layer(temp, w = all_weights$w3[1,,], b = all_weights$b3)
  temp     <- apply(features, which(dim(features) != 1000), mean)
  temp     <- nn_layer(temp, w = all_weights$w4, b = all_weights$b4)
  temp     <- nn_layer(temp, w = all_weights$w5, b = all_weights$b5)
  temp     <- nn_layer(temp, w = all_weights$w6, b = all_weights$b6)
  temp     <- nn_layer(temp, w = all_weights$w7, b = all_weights$b7,
                       activation = "sigmoid")
  probs <- temp
  prediction <- ifelse(probs < 0.5, "AD", "AI")

  if(verbose == TRUE){
    print("Probabilities and predictions for each dataset are being returned")
    print("##################")
    print(paste0("`nnadic`'s probability that these data are AI is: ",
                 round(probs, 3)))
    print(paste0("The prediction is: ", prediction))
  }
  if(prob_AInd_only == FALSE){
    return(list(probs = probs, preds = prediction, features = features))
  } else {
    return(probs)
  }
}


#' Create a feature plot for your dataset
#'
#'@param data an array of dimension \eqn{n}x\eqn{d}x\eqn{2}.
#'  Currently only supports \eqn{n=1} and \eqn{d=1000}. Use `get_nnadic_input()`
#'  to prepare your data.
#'@param nnadic_object the object returned from the `nnadic()` function.
#'@param feature_number an integer between 1 and 32 indicating the feature that
#'  you want to plot.
#'
#' @return a `plot` of the data colored by the `feature_number`

#' @export
#'
#' @examples
#' data <- get_nnadic_input(matrix(rnorm(20000), ncol = 2))
#' prediction <- nnadic(data, prob_AInd_only = FALSE)
#' plot_feature(data, nnadic_object = prediction, feature_number = 1)
plot_feature <- function(data, nnadic_object, feature_number){
  if(length(dim(data)) == 3){
    data <- data[1,,]
    nnadic_object$probs <- nnadic_object$probs[1]
    nnadic_object$preds <- nnadic_object$preds[1]
    nnadic_object$features <- nnadic_object$features[1,,]
    print("Using the first dataset in `data`.")
  }
  data.frame(x1 = data[,1],
             x2 = data[,2],
             feature = nnadic_object$features[,feature_number]) |>
    ggplot2::ggplot() +
    ggplot2::geom_point(ggplot2::aes(x = x1, y = x2, colour = feature)) +
    ggplot2::scale_color_gradient2(low="#541352FF", mid="grey95", high="#ffcf20FF") +
    ggplot2::theme_minimal() +
    ggplot2::coord_fixed() +
    ggplot2::labs(col = "feature", x = "", y = "")
}


#' A single neural network layer with activation function
#'
#' This function performs the computation for a single (dense) neural network
#'    layer. The user must specify the input `x`, weights `w`, biases `b`, and
#'    the `activation` function.
#'
#' @param x an \eqn{d_in}x\eqn{p_in} `matrix` input (data where \eqn{d_in} = n
#'    or output from last layer)
#' @param w an \eqn{p_in}x\eqn{p_out} `matrix` of weights
#' @param b a \eqn{p_out}-`vector` of biases
#' @param activation a string indicating which activation function to use. For
#'    the leaky-relu function \eqn{max(x, -0.3x)} use "relu". For sigmoid
#'    (logistic) function \eqn{(1 + exp(-x))^(-1)} use "sigmoid". For identity
#'    (i.e., no activation) use "identity".
#'
#' @returns an \eqn{d_in}x\eqn{p_out} matrix of outputs from the neural network
#'    layer.
#' @export
#'
#' @examples
#' nn_layer(x = matrix(rnorm(20), ncol = 2),
#'          w = matrix(rnorm(2*32), nrow = 2),
#'          b = rnorm(32),
#'          activation = "relu")
nn_layer <- function(x, w, b, activation = "relu"){
  x_dim <- dim(x)
  w_dim <- dim(w)

  if(length(x_dim) == 2){
    temp <- x %*% w
    temp <- sweep(temp, 2, b, "+")
  } else if(length(x_dim) == 3){
    if(x_dim[1] == 1){
      temp <- x[1,,] %*% w
      temp <- sweep(temp, 2, b, "+")
    } else {
      temp <- matrix(x, nrow = x_dim[1] * x_dim[2]) %*% w
      temp <- sweep(temp, 2, b, "+")
      dim(temp) <- c(x_dim[1], x_dim[2], w_dim[2])
    }
  } else {
    stop("ERROR: `x` has wrong dimensions. \n \t Must be `matrix` or `array` with 3 dimensions.")
  }
  switch(activation,
         relu = pmax(temp, 0.3*temp),
         sigmoid = 1 / (1 + exp(-temp)),
         identity = temp,
         stop("ERROR: activation function unknown: \n \t must be `relu`, `sigmoid`, or `identity`")
  )
}

#' The leaky rectified linear unit (leaky relu) activation function
#'
#' This function avoids the dead neuron issue that the relu function sometimes
#'    runs into by setting the negative values closer to zero, but not equal to
#'    zero. If input `x` is greater that zero this returns `x`. If input `x` is
#'    less than zero this returns \eqn{0.3 * x}
#'
#' @param x the value(s) to be activated
#'
#' @returns an object of the same dimension as `x` with the activated value
#' @export
#'
#' @examples
#' leaky_relu(2)
#' leaky_relu(-2)
#' leaky_relu(-5:5)
leaky_relu <- function(x){
  pmax(x, 0.3*x)
}

#' Sigmoid (logistic) activation function
#'
#' @param x the value(s) to be activated
#'
#' @returns an object of the same dimension as `x` with elements in \eqn{[0, 1]} which
#'    are the activated value
#' @export
#'
#' @examples
#' sigmoid(-2)
#' sigmoid(-5:5)
sigmoid <- function(x){
  1 / (1 + exp(-x))
}

