# tsbox: Class-angostic time series in R ----

# URL: https://docs.ropensci.org/tsbox/index.html

# The R ecosystem knows a vast number of time series standards.
# The tsbox package provides a set of tools that are
# **agnostic towards the existing standards**.
# The tools allow you to handle time series as plain data frames,
# thus making it easy to deal with time series in a dplyr or data.table workflow.

if (!require(tsbox)) { install.packages("tsbox") }
library(tsbox)

## Convert everything to everything ----

# tsbox is built around a set of converters, which convert
# time series stored as "ts", "xts", "data.frame", "data.table",
# "zoo", "zooreg", "tsibble", "tibbletime", "timeSeries", "irts", 
# or "tis" to each other.
x.ts <- ts_c(fdeaths, mdeaths)
x.ts
class(x.ts) # "mts" "ts" "matrix" "array"

x.xts <- ts_xts(x.ts)
x.xts
class(x.xts) # "xts" "zoo"

x.df <- ts_df(x.xts)
x.df
class(x.df) # "data.frame"

x.tbl <- ts_tbl(x.df)
x.tbl
class(x.tbl) # "tbl_df" "tbl" "data.frame"

x.zoo <- ts_zoo(x.tbl)
x.zoo
class(x.zoo) # "zoo"

x.zooreg <- ts_zooreg(x.zoo)
x.zooreg
class(x.zooreg) # "zooreg" "zoo"

x.tsibble <- ts_tsibble(x.zooreg)
x.tsibble
class(x.tsibble) # "tbl_ts" "tbl_df" "tbl" "data.frame"


## Use the same functions for time series classes ----

ts_trend(x.ts) # trend estimated using stats::loess()
ts_pc(x.ts) # First differences and percentage change
ts_pcy(x.df) # Year-on-year percentage change
ts_lag(x.zoo) # Shift operator

## Time series of the world, unite! ----

# Combine or align time series of different classes:

# collect time sereis as multiple time series
ts_c(ts_dt(EuStockMarkets), AirPassengers)
ts_c(EuStockMarkets, mdeaths)

# combine time series to a new, single time series
ts_bind(ts_dt(mdeaths), AirPassengers)
ts_bind(ts_xts(AirPassengers), ts_tbl(mdeaths))

## And plot just about everything ----
ts_plot(ts_scale(ts_c(mdeaths, austres, AirPassengers, DAX = EuStockMarkets[, "DAX"])))
