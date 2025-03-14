.onLoad <- function(libname, pkgname) {
  model <- keras::keras_model_sequential()

  keras::layer_conv_1d(model, kernel_size = c(1), filters = 32, strides = 1,
                       input_shape = c(500, 2),
                       bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_conv_1d(model, kernel_size = c(1), filters = 32,
                       bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_max_pooling_1d(model, pool_size = c(2))
  keras::layer_conv_1d(model, kernel_size = c(1), filters = 16,
                       bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_max_pooling_1d(model, pool_size = c(2))
  keras::layer_conv_1d(model, kernel_size = c(1), filters = 8,
                       bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_max_pooling_1d(model, pool_size = c(2))
  keras::layer_flatten(model)
  keras::layer_dense(model, units = 32,
                     kernel_initializer = keras::initializer_he_uniform(),
                     bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_dropout(model, 0.5)
  keras::layer_dense(model, units = 32,
                     kernel_initializer = keras::initializer_he_uniform(),
                     bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_dropout(model, 0.5)
  keras::layer_dense(model, units = 32,
                     kernel_initializer = keras::initializer_he_uniform(),
                     bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_dropout(model, 0.5)
  keras::layer_dense(model, units = 16,
                     kernel_initializer = keras::initializer_he_uniform(),
                     bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_dropout(model, 0.5)
  keras::layer_dense(model, units = 16,
                     kernel_initializer = keras::initializer_he_uniform(),
                     bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_dropout(model, 0.5)
  keras::layer_dense(model, units = 8,
                     kernel_initializer = keras::initializer_he_uniform(),
                     bias_initializer = keras::initializer_constant(value = 0.01))
  keras::layer_activation_leaky_relu(model)
  keras::layer_dense(model, units = 1, activation = "sigmoid")

  keras::load_model_weights_hdf5(model, filepath =
      system.file("pretrained_models/final_model_weights.hdf5",
                    package = "nnadic"))
    assign("model", model, envir = parent.env(environment()))
}

.onAttach <- function(libname, pkgname) {
  # to show a startup message
  packageStartupMessage("Welcome to nnadic!")
}
