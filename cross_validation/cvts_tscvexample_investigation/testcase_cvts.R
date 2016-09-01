set_current_directory()

# load excel data 
workbook <- loadWorkbook("AustralianWines.xls")
xdata <- readWorksheet(workbook, sheet = "Sheet1", region = "A1:G181",header = TRUE)
xdata2 <- as.ts(xdata)
xdata2[is.na(xdata2)] <- 0
xdata2 <- as.data.frame(xdata2)
xdata <- cbind(Month = xdata$Month, xdata2[,-1])

data_1 <- ts(xdata$Fortified, start=c(1980,01), frequency=12)
data_2 <- ts(xdata$Red., start=c(1980,01), frequency=12)
data_3 <- ts(xdata$Rose., start=c(1980,01), frequency=12)
data_4 <- ts(xdata$sparkling., start=c(1980,01), frequency=12)
data_5 <- ts(xdata$Sweet.white, start=c(1980,01), frequency=12)
data_6 <- ts(xdata$Dry.white, start=c(1980,01), frequency=12)

# create training and validation periods 
x <- window(data_1, end=c(1993,12))         # train
test_x <- window(data_1, start=c(1994, 1))  # test/validation

# run cvts
tsControl <- tseriesControl(stepSize=1, maxHorizon=12, minObs=12, fixedWindow=TRUE)

ctrl <- tseriesControl(stepSize=1, maxHorizon=12, minObs=12, fixedWindow=TRUE)
models <- list()

models$arima = cv.ts(
  x, auto.arimaForecast, tsControl=ctrl,
  ic='aicc', stepwise=FALSE)

# explore the results
xdata <- read.csv("actuals.csv")
xdata2 <- ts(xdata$col1, frequency=12)

# models$arima = cv.ts(
#   x, auto.arimaForecast, tsControl=ctrl,
#   ic='aicc', stepwise=FALSE)

# #' auto.arima forecast wrapper
# #' @export
# auto.arimaForecast <- function(x,h,xreg=NULL,newxreg=NULL,...) {
#   fit <- forecast::auto.arima(x, xreg=xreg, ...)
#   forecast::forecast(fit, h=h, level=99, xreg=newxreg)$mean
# }

aa <- auto.arima(xdata2,ic='aicc', stepwise=FALSE)
aaf <- forecast(aa, h=12)




library(fpp)
x <- a10
myControl <- tseriesControl(maxHorizon=12)
lmForecast <- cv.ts(x, lmForecast, tsControl=myControl)

# errors with 
# Error in data.frame(horizon = c(1:maxHorizon, "All"), out) : 
#   arguments imply differing number of rows: 13, 61 In addition: There were 50 or more warnings (use warnings() to see the first 50)






