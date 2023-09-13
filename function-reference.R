# Function reference ----

library(tsbox)
library(tidyverse)

## Convert ----

# Convert to base::data.frame
ts.df <- ts_data.frame(AirPassengers)
class(ts.df) # "data.frame"

ts.df <- ts_df(AirPassengers)
class(ts.df) # "data.frame"

# Convert to data.table::data.table
ts.dt <- ts_data.table(AirPassengers)
class(ts.dt) # "data.table" "data.frame"

ts.dt <- ts_dt(AirPassengers)
class(ts.dt) # "data.table" "data.frame"

# Convert to tibble::tibble
ts.tbl <- ts_tbl(AirPassengers)
class(ts.tbl) # "tbl_df" "tbl" "data.frame"

# Convert to tibbletime
ts.tbltime <- ts_tibbletime(AirPassengers)
class(ts.tbltime) # "tbl_time" "tbl_df" "tbl" "data.frame"

# Convert to timeSeries::timeSeries
ts.timeSeries <- ts_timeSeries(AirPassengers)
class(ts.timeSeries)
# "timeSeries" attr(,"package")

# Convert to tis::tis
ts.tis <- ts_tis(AirPassengers)
class(ts.tis) # "tis"

# Convert to stats::ts
ts.ts <- ts_ts(AirPassengers)
class(ts.ts) # "ts"

# Convert to stats::mts
ts.mts <- ts_ts(ts_c(AirPassengers, AirPassengers*2))
class(ts.mts) # "mts" "ts" "matrix" "array"

# Convert to zoo::irts
ts.irts <- ts_irts(AirPassengers)
class(ts.irts) # "irts"

# Convert to tsibble::tsibble
ts.tsibble <- ts_tsibble(AirPassengers)
class(ts.tsibble) # "tbl_ts" "tbl_df" "tbl" "data.frame"

# Convert to tslist
ts.tslist <- ts_tslist(AirPassengers)
class(ts.tslist) # "tslist" "list"

# Covnert to xts::xts
ts.xts <- ts_xts(AirPassengers)
class(ts.xts) # "xts" "zoo"

# Convert to zoo::zoo
ts.zoo <- ts_zoo(AirPassengers)
class(ts.zoo) # "zoo"

# Convert to zoo::zooreg
ts.zooreg <- ts_zooreg(AirPassengers)
class(ts.zooreg) # "zooreg" "zoo"


## Combine and separate ----

# Collect time series 
ts.c <- ts_c(AirPassengers, AirPassengers*2)
head(ts.c)

ts.c <- ts_c(A = AirPassengers, B = AirPassengers * 2)
head(ts.c)

# Bind time series
ts.bind <- ts_bind(
  ts_span(AirPassengers, end = "1959-12-01"), 
  ts_span(AirPassengers, start = "1960-01-01")
  )

all.equal(target = ts.bind, current = AirPassengers)
# TRUE

# Chain linking:
ts_chain(ts_span(mdeaths, end = "1975-12-01"), fdeaths)

ts_plot(ts_pc(ts_c(
  comb = ts_chain(ts_span(mdeaths, end = "1975-12-01"), fdeaths),
  fdeaths
)))

# Chain-linking is used in CPI data

# Limit time span
ts_span(AirPassengers, start = "1959-07-01", end = "1960-03-01")

# Pick series (experimental)
head(ts_pick(EuStockMarkets, "DAX", "SMI"))


## Transform ----

# Scale and center time series
# subtract the mean sum(x)/n
# divide by the standard deviation sqrt(sum(x^2))/(n-1)
ts_scale(AirPassengers, center = TRUE, scale = TRUE)
ts_plot(ts_scale(AirPassengers))
graphics.off()
# based on base::scale()

# Loess trend estimation 
ts_trend(AirPassengers)
ts_plot(AirPassengers, ts_trend(AirPassengers))
graphics.off()
# based on stats::loess()

# First differences and percentage change rates
# Percentage change compared to observation in previous period
ts_plot(ts_pc(AirPassengers))
abline(h = 0)
# Month-on-month percentage gorwth rates

# Percentage change compared to observation in same period one year ago
ts_plot(ts_pcy(AirPassengers))
abline(h = 0)
# Year-on-year percentage growth rates

# First non-seasonal differences
ts_plot(ts_diff(AirPassengers))
abline(h = 0)
# Absolute growth month-on-monthh
# Y_t - Y_(t-1)

# First seasonal differences
ts_plot(ts_diffy(AirPassengers))
abline(h = 0)
# Absolute growth year-over-year
# Y_t - Y_(t-12)
graphics.off()


# Lag or lead of time series
ts_lag(AirPassengers, by = "1 month")
# Y_(t-1)

ts_lag(AirPassengers, by = "1 year")
# Y_(t-12)

ts_lag(AirPassengers, by = "2 months")
# Y_(t-2)


## Plot and summary ----

# Time series properties
ts_summary(AirPassengers)
# id, obs, diff, freq, start, end

ts_summary(AirPassengers, spark = TRUE)

# Plot time series
ts_plot(AirPassengers, ts_trend(AirPassengers))
graphics.off()

# Plot time series using ggplot2
ts_ggplot(AirPassengers) +
  geom_line(aes(), linewidth = 1)

suppressMessages(library(ggplot2))
df <- ts_df(ts_c(total = ldeaths, female = fdeaths, male = mdeaths))
head(df)
ggplot(data = df, mapping = aes(x = time, y = value)) +
  facet_wrap(facets = "id") +
  geom_line() +
  theme_tsbox() +
  scale_color_tsbox()

if (TRUE) {
  library(dataseries)
  dta <- ds(id = c("GDP.PBRTT.A.R", "CCI.CCIIR"), class = "xts")
  ts_ggplot(ts_scale(ts_span(
    ts_c(
      `GDP Growth` = ts_pc(dta[, "GDP.PBRTT.A.R"]),
      `Consumer Sentiment Index` = dta[, "CCI.CCIIR"]
    ),
    start = "1995-01-01"
  ))) +
    ggplot2::ggtitle("GDP and consumer sentiment", subtitle = "normalized") +
    theme_tsbox() +
    scale_color_tsbox()
}

# Save the previous plot with ts_save()
ts_plot(AirPassengers)
tf <- tempfile(fileext = ".pdf")
ts_save(tf)
unlink(tf)
graphics.off()

# Use default column names with ts_default()


## Reshape ---
x <- ts_df(ts_c(mdeaths, fdeaths))
df.wide <- ts_wide(x)
head(df.wide)
# time mdeaths fdeahts

head(ts_long(df.wide))
# id time value


## Frequency ----

# Change the frequency (aggregate)
ts_frequency(AirPassengers, to = "quarter", aggregate = sum)

# Enforce regularity
x0 <- AirPassengers
x0[c(2, 3)] <- NA
head(x0)

x <- ts_na_omit(ts_dts(x0))
ts_regular(x) # Implicit missings are put back in data frame

ts_regular(x, fill = 0) # Implicit missings replaced with 0

m <- mdeaths
m[c(2, 3)] <- NA

f <- fdeaths
f[c(1, 3, 15)] <- NA

ts_regular(ts_na_omit(ts_dts(ts_c(f, m))))


# Omit NA values
x <- AirPassengers
x[c(2, 4)] <- NA

# A ts object does only know explicit NAs
head(ts_na_omit(x))

# By default, NAs are implicit in data frames and xts objects
head(ts_df(x))

head(ts_xts(x))

# Make them implicit
head(ts_na_omit(ts_df(x)))
head(ts_na_omit(ts_xts(x)))


# Use the first date of a period
x <- ts_c(
  a = ts_lag(ts_df(mdeaths), by = "14 days"),
  b = ts_lag(ts_df(mdeaths), by = "-2 days")
)

head(x)

ts_first_of_period(x)

ts_first_of_period(ts_lag(ts_df(austres), by = "14 days"))


## User-defined ts-functions ----

# ts_() turns existing functions into functions that can deal
# with any ts-boxable class of time series objects.

# The example functions are
ts_prcomp(ts_df(ts_c(mdeaths, fdeaths)))

ts_dygraphs(AirPassengers)
graphics.off()

ts_forecast(AirPassengers)

ts_seas(AirPassengers)

ts_plot(AirPassengers, ts_seas(AirPassengers), ts_forecast(AirPassengers))

# See ?imputeTS::na_interpolation for options
dta <- ts_c(mdeaths, fdeaths)
dta[c(1, 3, 10), c(1, 2)] <- NA
head(ts_na_interpolation(dta, option = "spline"))

# There are some functions that are mostly used internally, 
# i.e. inside the ts_() constructor function:
# load_suggested(pkg)
# ts_(fun, class = "ts", vectorize = FALSE, reclass = TRUE)
# ts_apply(x, fun, ...)

ts_(rowSums)(ts_c(mdeaths, fdeaths))
# You can directly access the created function!

ts_plot(mean = ts_(rowMeans)(ts_c(mdeaths, fdeaths)), mdeaths, fdeaths)
graphics.off()

ts_(function(x) predict(prcomp(x)))(ts_c(mdeaths, fdeaths))
# PC1, PC2
# We have provided an anonymous function, i.e. a function without
# a name or curly braces.

ts_(function(x) predict(prcomp(x, scale. = TRUE)))(ts_c(mdeaths, fdeaths))
# We forecast the PC1 and PC2 values


ts_(dygraphs::dygraph, class = "xts")
# We have not provided an argument inside of braces (x),
# so we see the internals

# attach series to search path:
ts_attach <- ts_(attach, class = "tslist", reclass = FALSE)
ts_attach(EuStockMarkets)
ts_plot(DAX, SMI)
graphics.off()
detach()

# Extract relevant class
relevant_class(ts_xts(AirPassengers)) # "xts"
class(ts_xts(AirPassengers)) # "xts" "zoo"
relevant_class
# function(x) {
# check_ts_boxable(x)
# intersect(class(x), supported_classes())[1]
# }

check_ts_boxable(AirPassengers)
ts_boxable(AirPassengers)
# TRUE

# Internal time series class
# In data frame objects of classes "data.frame", "tibble", "tsibble",
# and "data.table", tsbox detects the time and value column.
ts_dts(ts_df(AirPassengers))
# time, value

df <- ts_df(ts_c(mdeaths, fdeaths))

# non-default colnames
colnames(df) <- c("id", "date", "count")

head(df)

# Switch back to default colnames time and value:
head(ts_default(df))
# id, time, value


## Arithmetic operators ----
head(fdeaths - mdeaths)
head(fdeaths %ts-% mdeaths)
head(ts_df(fdeaths) %ts-% mdeaths)
head(ts_df(fdeaths) %ts+% mdeaths)

head(ts_df(fdeaths) %ts*% mdeaths)
head(ts_df(fdeaths) %ts/% mdeaths)


## Others ----
ts_start(ts_df(mdeaths))
# deprecated
ts_summary(ts_df(mdeaths))$start
ts_summary(ts_df(mdeaths))$end
# END