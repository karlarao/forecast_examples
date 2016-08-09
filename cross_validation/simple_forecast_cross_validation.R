
# simple forecast example
library(forecast)
x <- AirPassengers
mod_arima <- auto.arima(x, ic='aicc', stepwise=FALSE)
mod_exponential <- ets(x, ic='aicc', restrict=FALSE)
mod_neural <- nnetar(x, p=12, size=25)
mod_tbats <- tbats(x, ic='aicc', seasonal.periods=12)
par(mfrow=c(4, 1))
plot(forecast(mod_arima, 12), include=36)
plot(forecast(mod_exponential, 12), include=36)
plot(forecast(mod_neural, 12), include=36)
plot(forecast(mod_tbats, 12), include=36)


# simple cross validation example 
# https://github.com/zachmayer/cv.ts
# devtools::install_github('zachmayer/cv.ts')
library(cv.ts)
data("AirPassengers")
x <- AirPassengers
myControl <- tseriesControl(maxHorizon=4)
theta_model <- cv.ts(x, thetaForecast, tsControl=myControl)
arima_model <- cv.ts(x, auto.arimaForecast, tsControl=myControl)
ets_model <- cv.ts(x, etsForecast, tsControl=myControl)
theta_model$results
arima_model$results
ets_model$results

