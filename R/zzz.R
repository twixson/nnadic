.onLoad <- function(libname, pkgname) {
  model <- keras::keras_model_sequential()

  model %>% keras::layer_conv_1d(kernel_size = c(2),
                                 filters = 32,
                                 strides = 1,
                                 padding = "same",
                                 input_shape = c(500, 2),
                                 kernel_initializer = initializer_he_uniform(),
                                 bias_initializer =
                                   initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_max_pooling_1d(pool_size = c(2), padding = "same") %>%
    keras::layer_conv_1d(kernel_size = c(2),
                         filters = 16,
                         strides = 1,
                         padding = "same",
                         kernel_initializer = initializer_he_uniform(),
                         bias_initializer =
                           initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_max_pooling_1d(pool_size = c(2), padding = "same") %>%
    keras::layer_conv_1d(kernel_size = c(2),
                         filters = 8,
                         strides = 1,
                         padding = "same",
                         kernel_initializer = initializer_he_uniform(),
                         bias_initializer =
                           initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_max_pooling_1d(pool_size = c(2), padding = "same") %>%
    keras::layer_flatten() %>%
    keras::layer_dense(units = 32,
                       kernel_initializer = initializer_he_uniform(),
                       bias_initializer =
                         initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_dropout(0.5) %>%
    keras::layer_dense(units = 32,
                       kernel_initializer = initializer_he_uniform(),
                       bias_initializer =
                         initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_dropout(0.5) %>%
    keras::layer_dense(units = 32,
                       kernel_initializer = initializer_he_uniform(),
                       bias_initializer =
                         initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_dropout(0.5) %>%
    keras::layer_dense(units = 16,
                       kernel_initializer = initializer_he_uniform(),
                       bias_initializer =
                         initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_dropout(0.5) %>%
    keras::layer_dense(units = 16,
                       kernel_initializer = initializer_he_uniform(),
                       bias_initializer =
                         initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_dropout(0.5) %>%
    keras::layer_dense(units = 8,
                       kernel_initializer = initializer_he_uniform(),
                       bias_initializer =
                         initializer_constant(value = 0.01)) %>%
    keras::layer_activation_leaky_relu() %>%
    keras::layer_dense(units = 1, activation = "sigmoid")


    keras::load_model_weights_hdf5(model,
                                   "./pretrained_models/CNN_0530_model.hdf5")
  #   system.file("pretrained_models/CNN_0530_model.hdf5", package = "nnadic"))
  # assign("model", model, envir = parent.env(environment()))
}

