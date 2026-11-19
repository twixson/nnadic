#' Testing data for the `nnadic` function
#'
#' These data are the first 100 data sets from the training data in
#'    `nnadicTestData` in the object `train_data_four`. The data were simulated
#'    by the authors and used to train the neural network.
#'
#' @name test_data
#' @format An `array` with 100 data sets that each have 500 rows and 2 columns.
#'
#' @source <https://github.com/twixson/nnadicTestData>
"test_data"

#' Metadata for `test_data`
#'
#' These data are the metadata from the first 100 data sets from the training
#'    data in `nnadicTestData` in the object `train_indices_four`. The data
#'    were simulated by the authors and used to train the neural network.
#'
#' @name test_metadata
#' @format A dataframe with 100 rows and 8 columns:
#' \describe{
#'   \item{original_index}{index of the datset when generated}
#'   \item{AD.0_AI.1}{numeric indicator of whether the dataset is AD (0) or AI (1)}
#'   \item{dep_param}{dependence parameter used to generate the data}
#'   \item{chi}{analytic chi calculated from the generating model and dependence parameter}
#'   \item{chiBar}{analytic chi-bar calculated from the generating model and dependence parameter}
#'   \item{asym_param1}{asymmetry parameter 1 used to generate the data (0 indicates no asymmetry parameter was used)}
#'   \item{asym_param2}{asymmetry parameter 2 used to generate the data}
#'   \item{model}{the name of the data generating model}
#'   }
#'
#' @source <https://github.com/twixson/nnadicTestData>
"test_metadata"
