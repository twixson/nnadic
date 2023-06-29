.onLoad <- function(libname, pkgname) {
  model <- keras::load_model_hdf5(
    system.file("pretrained_models/CNN_0530_model.hdf5", package = "nnadic"))
  assign("model", model, envir = parent.env(environment()))
}

