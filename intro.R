# Introduction to tsbox ----
# Class-agnostic time series
# Christoph Sax

if (!require(tsbox)) { install.packages("tsbox") }
library(tsbox)
library(tidyverse)

## Convert everything to everything ----
x.ts <- ts_c(fdeaths, mdeaths)
x.xts <- ts_xts(x.ts)
x.df <- ts_df(x.xts)
x.dt <- ts_dt(x.df)
x.tbl <- ts_tbl(x.dt)
x.zoo <- ts_zoo(x.tbl)
x.tsibble <- ts_tsibble(x.zoo)

# We have time series objects of classes
# "ts" ("mts"), "xts", "data.frame", "data.table", "tibble",
# "zoo", "tsibble"

## Use the same functions for all time series classes ----

# ts_scale() normalizes a time series by subtracting the mean
# and dividing by the standard deviation of the series.
# It is based on base::scale()
ts_scale(x.ts)
ts_scale(x.xts)
ts_scale(x.df)
ts_scale(x.dt)
ts_scale(x.tbl)
ts_scale(x.tsibble)

# ts_trend() estimates the trend component using stats::loess():
ts_trend(x.ts)
ts_trend(x.xts)
ts_trend(x.tsibble)

# Functions to calculate differences are:
ts_pc(x.tsibble) # Percentage change compared to previous period
ts_pcy(x.tsibble) # Percentage change compared to same period in previous year
ts_diff(x.tsibble) # Difference compared to previous period
ts_diffy(x.tsibble) # Difference compared to same period in the previous year

# lag or lead time series:
ts_lag(x.tsibble, "1 month")
ts_lag(x.tsibble, "1 year")
ts_lag(x.tsibble, "2 days")
ts_lag(x.tsibble, "-1 day")


# Functions to construct indices are
ts_index(x.tsibble)
ts_compound(ts_pc(x.tsibble))


## Combine multiple time series ----

# The basic workhorse to combine multiple time series of different
# classes is ts_c(), which collects time series:
ts_c(ts_dt(EuStockMarkets), AirPassengers)
ts_c(ts_tbl(mdeaths), EuStockMarkets, ts_xts(lynx))

# You can name the arguments:
ts_c(ts_dt(EuStockMarkets), `Airline Passengers` = AirPassengers)

# Multiple series can be combined into a single series
ts_bind(ts_xts(mdeaths), AirPassengers)

# ts_chain() can be used to chain-link time series.
# The following prolongs a short time series with percentage
# change rates of a longer one:
md.short <- ts_span(x = mdeaths, end = "1976-12-01")
ts_chain(md.short, fdeaths)

# to pick a subset of time series, and optionally rename them,
# use ts_pick():
ts_pick(EuStockMarkets, "DAX", "SMI")
ts_pick(EuStockMarkets, `my shiny new name` = "DAX", "SMI")


## Frequency conversion and alignment ----

# The following changes the frequency of two series to annual:
ts_frequency(ts_c(AirPassengers, austres), to = "year", aggregate = sum)

# ts_span() is used to limit the span of a series.
# ts_regular() makes irregular time series regular by turning 
# implicit missing values into explicit NAs.

## And plot just about everything ----

# The basic function is ts_plot():
ts_plot(AirPassengers, ts_df(lynx), ts_xts(fdeaths))

# If you want to use different names than the object names,
# just name the arguments (and optionally set a title):
ts_plot(
 `Airline passengers` = AirPassengers,
 `Lynx trappings` = ts_df(lynx),
 `Deaths from lung diseases` = ts_xts(fdeaths),
 title = "Airlines, trappings, and deaths",
 subtitle = "Monthly passengers, annual trappings, monthly deaths"
)


# There is also a version that uses ggplot2 syntax.
# With theme_tsbox() and scale_color_tsbox(),
# the output of ts_ggplot() is very similar to ts_plot():
ts_ggplot(ts_scale(ts_c(
  mdeaths,
  austres,
  AirPassengers,
  DAX = EuStockMarkets[, "DAX"]
)))

# Finally, ts_summary() retunrs a data frame with frequently used
# time series properties:
ts_summary(ts_c(mdeaths, austres, AirPassengers))
# id, obs, diff, freq, start, end

## Time series in data frames ----

# In data frames such as data.frame, data.table, or tibble,
# tsbox stores one or multiple time series in the long-format.

# tsbox detects a value, a time and zero, one, or several id columns.

# Column detection is done in the following order:

# 1. Starting on the right, the first numeric or integer column is used as the value column.
# 2. Using the remaining columns and starting on the right again, the first
# Date, POSIXct, numeric or character column is used as the time column.
# Character strings are parsed by anytime::anytime().
# The timestamp, time, indicates the beginning of a period.
# 3. All remaining columns are id columns.
# Each unique combination of id columns points to a time series.

# Alternatively, the time column and the value column can be
# explicitly named with the time and value argument.

# If columns are detected automatically, a message is returned.

# The following data frame has the standard structure that is
# understood by tsbox:
dta <- tribble(
  ~series_name, ~time, ~value,
  "ser1", "2001-01-01", 1,
  "ser1", "2002-01-01", 2,
  "ser2", "2001-01-01", 10,
  "ser2", "2002-01-01", 20,
)

dta

ts_ts(dta)
# Time Series:
# Start = 2001
# End = 2002
# Frequency = 1

# If time and vlaue columns have different names than time and value,
# it works but a message is returned:
dta |> 
  rename(
    mytime = time,
    myvalue = value
  ) |> 
  ts_ts()
# [time]: "mytime" [value]: "myvalue"

# We can have multiple id columns.
# tsbox combines them into a signle value:
dta_multi_id <-
  dplyr::tribble(
    ~series_name, ~series_attribute,  ~time,        ~value,
    "ser1",       "A",                  "2001-01-01",  1.5,
    "ser1",       "A",                  "2002-01-01",  2.5,
    "ser2",       "A",                  "2001-01-01",  10.5,
    "ser2",       "A",                  "2002-01-01",  20.5,
    "ser1",       "B",                  "2001-01-01",  1,
    "ser1",       "B",                  "2002-01-01",  2,
    "ser2",       "B",                  "2001-01-01",  10,
    "ser2",       "B",                  "2002-01-01",  20
  )

ts_ts(dta_multi_id)

# Data frames must be in long-format, with a single value column
# only:
dta_wide <- ts_wide(ts_tbl(ts_c(mdeaths, fdeaths)))
dta_wide

# tsbox tries to detect wide structures and warns if they occur:
ts_ts(dta_wide)
# Found numeric [id] column(s): 'mdeaths'.
# Are you using a wide data frame? To convert, use 'ts_long()'.
ts_long(dta_wide)

## Using tsbox in a dplyr / pipe workflow:
library(nycflights13)
dta <- weather |> 
  select(origin, time = time_hour, temp, humid, precip) |> 
  ts_long()

dta

dta |> 
  filter(id == "temp") |> 
  ts_trend() |> 
  ts_plot()


## Related packages ----
# The tsibble package provides infrastructure for tidy temporal data.
# The timetk package offers converters for time series data.
# As do the zoo and xts packages.

