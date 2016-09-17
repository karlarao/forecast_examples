# based on http://oracledmt.blogspot.com/2006/10/time-series-revisited.html
# this is still work in progress

set_current_directory()

xdata <- read.csv("data_airline.csv", stringsAsFactors = FALSE)
autoplot(as.ts(as.zoo(xdata)))

xdata2 <- zoo(xdata$PASSENGERS,xdata$MONTH)
xdata3 <- ts(xdata2)
xdata4 <- ts(xdata2, frequency = 360/60)

e <- tslm(xdata3 ~ trend + I(trend^2) + I(sin(2*pi*trend/12)) + I(cos(2*pi*trend/12)))
f <- forecast(e,h=length(xdata3), level=FALSE)
autoplot(f)
