# User-defined ts-functions ----

## Writing ts-functions ----

# You can turn existing functions into functions that can deal
# with any ts-boxable object.

# The ts_(...) function is a constructor function for tsbox time series functions.
# It can be used to wrap any function that works with time series.

# The default is set to the base "ts" class,
# so wrapping functions for "ts" time series (or vectors or matrices)
# is as simple as:
library(tsbox)

ts_rowsums <- ts_(rowSums)
ts_rowsums(x = ts_c(mdeaths, fdeaths))

# Note that ts_() returns a function, which cna be with or without a name.
ts_rowsums
# function(x, ...) {
# check_ts_boxable(x)
# z <- rowSums(ts_ts(x), ...)
# copy_class(z, x)
# }

# This is how most ts-functions work. They use a specific converter function,
# here ts_ts() to convert a ts-boxable object to the desired class.

# They then perform the main operation on the object (here: rowSums).

# Finally, they ocnvert the result back to the original class, using copy_class().

# The resulting function has a ... argument you can use to pass
# additional arguments to the underlying functions, e.g.:
ts_rowsums(ts_c(mdeaths, fdeaths), na.rm = TRUE)


## Functions from external packages ----
# Here is a slgithly more complex example, which uses a post-processing 
# function:
# stats::prcomp() performs PCA
# stats::predict() creaes model predictions
ts_prcomp <- ts_(function(x) predict(prcomp(x, scale = TRUE)))

ts_prcomp(x = ts_c(mdeaths, fdeaths))
# PC1, PC2

# It is easy to make functions from external packages to ts-boxable,
# by wrapping them into ts_():
ts_dygraphs <- ts_(dygraphs::dygraph, class = "xts")
ts_forecast <- ts_(function(x, ...) forecast::forecast(x, ...)$mean, vectorize = TRUE)
ts_seas <- ts_(function(x, ...) seasonal::final(seasonal::seas(x, ...)), vectorize = TRUE)

ts_dygraphs(x = ts_c(mdeaths, EuStockMarkets))

ts_forecast(x = ts_c(mdeaths, fdeaths))

ts_seas(ts_c(mdeaths, fdeaths))

# Plot the principal components:
ts_plot(
  ts_scale(ts_c(
    Male = mdeaths,
    Female = fdeaths,
    `First principal compenent` = -ts_prcomp(ts_c(mdeaths, fdeaths))[, 1]
  )),
  title = "Deaths from lung diseases",
  subtitle = "Normalized values"
)

# Plot the forecasts
ts_plot(ts_c(
  male = mdeaths, female = fdeaths,
  ts_forecast(ts_c(`male (fct)` = mdeaths, `female (fct)` = fdeaths))
  ),
  title = "Deaths from lung diseases",
  subtitle = "Exponential smoothing forecast"
)

# Plot the seasonal adjustment
ts_plot(
  `Raw series` = AirPassengers,
  `Adjusted series` = ts_seas(AirPassengers),
  title = "Airline passengers",
  subtitle = "X-13 seasonal adjustment"
)


# See ?imputeTS::na_interpolation for options
?imputeTS::na_interpolation
# The imputeTS package helps with missing values

dta <- ts_c(mdeaths, fdeaths)
dta[c(1, 3, 10), c(1, 2)] <- NA
head(ts_na_interpolation(dta, option = "spline"))

ts_dygraphs(ts_c(mdeaths, EuStockMarkets))


# If you are explicit about the namespace, e.g., dygraphs::dygraph,
# ts_() recognizes the package in use and delivers a meaningful message
# if the package is not installed.

# Note that the ts_() function deals with the conversion and
# vectorizes the function so that it can be used with multiple time series.

ts_forecast
# function(x, ...) {
# load_suggested("forecast")
# ff <- function(x, ...) {
#   stopifnot(ts_boxable(x))
#   z <- (function(x, ...) forecast::forecast(ts_na_omit(x), ...)$mean)(ts_ts(x), ...)
#   copy_class(z, x)
#   }
#   ts_apply(x, ff, ...)
# }

ts_boxable(AirPassengers)
# TRUE

# There are three differences to the ts_rowsum() example:

# First, the function requires the forecast package.
# If it is not installed, load_suggested() will ask the user to do so.

# Second, the function in use is an anonymous function,
# function(x) forecast::forecast(x, ...)$mean,
# that also extracts the $mean component from the result.

# Third, the function is "vectorized", using ts_apply().
# This causes the process to be repeated for each time series in the object.


