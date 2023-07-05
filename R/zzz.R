.onLoad <- function(libname, pkgname) {
  model <- keras::keras_model_sequential()

    model <- keras::load_model_hdf5(filepath =
        system.file("pretrained_models/CNN_0705_model.hdf5",
                    package = "nnadic"))
    assign("model", model, envir = parent.env(environment()))
}

