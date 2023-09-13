# Time conversion and regularization ----

# tsbox relies on a set of converter functions to convert time
# series objects of classes ts, mts, xts, data.frame, data.table,
# tibble, zoo, tsibble, tibbletime, or timeSeries, and vectors or matrices
# to each other.

# One challenge is the conversion of equispaced points in time 
# to actual dates or times.

# Another challenge is the regularization of irregular time sequences.

# The original way of storing time series in R is in "ts" bojects,
# which are simple vactors with an attribute that describes the
# start and the end of the series.
# The end is redundant and does not have to be defined.
# The frequency can be defined seperately.
class(AirPassengers) # ts
str(AirPassengers)
# Time-Series[1:144] from 1949 to 1961
start(AirPassengers) # 1949 1
end(AirPassengers) # 1960 12
frequency(AirPassengers) # 12
unclass(AirPassengers)
attributes(AirPassengers)
# $tsp: 1949.000 1960.917 12
# $class: "ts"
time(AirPassengers)

# The monthly series AirPassengers is defined as a numeric vector
# that starts in 1949 and has frequency 12, thus months are thought of
# as equispaced periods with a length of exactly 1/12 of a year.

# February 1949 is actually shorter than January 1949,
# but this is not reflected in this "ts" object.

# When converting to classes with actual time stamps, tsbox
# tries to fix time points by using heuristics, rather than 
# exact time conversions.

## Heuristic time conversion ----

# Whenever possible, tsbox relies on heuristic time conversion.

# When a monthly "ts" object like AirPassengers is converted to a data.frame,
# each time stamp of class "Date" indicates the first day of the month.

# Heuristic conversion uses the following frequencies:
# ts-frequency  time difference
# 365.2415      1 day
# 12            1 month
#  6            2 months
#  4            3 months
#  3            4 months
#  2            6 months
#  1            1 year
#  1/2          2 years
#  1/3          3 years
#  1/5          5 years
#  1/10        10 years

# Converting AirPassengers to a data.frame returns:
library(tsbox)

head(ts_df(AirPassengers))

# Heuristic conversion works both ways, so we can get back to
# the original "ts" object:
all.equal(target = ts_ts(ts_df(AirPassengers)), current = AirPassengers)
# TRUE


### Exact time conversion ----

# For non-standard frquencies, e.g. 260 trading days in the
# EuStockMarkets data, tsbox uses exact time conversion.

# The year is divided into 260 equispaced units, each somewhat longer
# than a day.

# The time stamp of a period will be an exact point in time of class "POSIXct"
head(ts_df(EuStockMarkets))

# Higher frequencies, such as days, hours, minutes, or seconds, are
# naturally equispaced, and exact time covnersion is used as well.

# Exact time conversion is generally reversible:
all.equal(target = ts_ts(ts_df(EuStockMarkets)), current = EuStockMarkets)
# TRUE

# However, for higher frequencies, rounding errors can lead to differences.
# Conversion does not work reliably if the frequency is higher than one second.


## Regularization ---

# In data frame sor "xts" objects, missing values are generally omitted.
# Such missing values are called implicit, because they are not included
# in the output as explicit NA values.

# The function ts_regular() allows the user to regularize a series,
# by making implicit missing values explicit.

# When regularizing, ts_regular() analyzes the differences in the 
# time stamp for known frequencies.

# If it detects any, it builds a regular sequency based on the highest
# known frequency, and tries to match the time stamps to the regular series.

# The result is a data frame or "xts" object with explicit missing values.

# Regularization is automatically done when an object is converted to
# a "ts" object.

# The following time series contains an implicit NA value in february 1974
df <- ts_df(fdeaths)[-2, ]
head(df)
head(fdeaths)
# 1974-01-01
# 1974-03-01 -> 1974-02-01 is missing implicitly!

head(ts_regular(df)) # Explicit NA introduced
head(ts_ts(df)) # Explicit NA introduced



