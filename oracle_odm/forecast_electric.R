# based on http://oracledmt.blogspot.com/2006/10/time-series-revisited.html
# this is still work in progress

set_current_directory()

xdata2 <- read.csv("data_electric_load.csv", stringsAsFactors = FALSE)
autoplot(as.ts(as.zoo(xdata2)))

xdata2 <- zoo(xdata2$MAX_LOAD,xdata2$DAY_ID)
xdata3 <- ts(xdata2)
xdata4 <- ts(xdata2, frequency = 360/60)

# e <- ets(xdata3)
# e <- auto.arima(xdata3)
# e <- rollmean(xdata3, k = 12, align = "right")
# rma <- rollmean(xdata3, k = 12, align = "right")
# e <- tslm(rma ~ trend + I(trend^2) + I(sin(2*pi*trend/12)) + I(cos(2*pi*trend/12)))
e <- tslm(xdata3 ~ trend + I(trend^2) + I(sin(2*pi*trend/12)) + I(cos(2*pi*trend/12)))
f <- forecast(e,h=length(xdata3), level=FALSE)
autoplot(f)