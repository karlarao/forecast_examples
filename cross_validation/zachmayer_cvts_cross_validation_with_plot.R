
# http://stats.stackexchange.com/questions/140163/timeseries-analysis-procedure-and-methods-using-r

# devtools::install_github('zachmayer/cv.ts')
library(cv.ts)

Year  <- c(2008, 2008, 2008, 2008, 2008, 2008, 2008, 2008, 2008, 2009, 2009, 
           2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2009, 2010, 
           2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 2010, 
           2011, 2011, 2011, 2011, 2011, 2011, 2011, 2011, 2011, 2011, 2011, 
           2011, 2012, 2012, 2012, 2012, 2012, 2012, 2012, 2012, 2012, 2012, 
           2012, 2012, 2013, 2013)
Month <- c(4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
           12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 
           8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2) 
Coil  <- c(44000, 44500, 42000, 45000, 42500, 41000, 39000, 35000, 34000, 
           29700, 29700, 29000, 30000, 30000, 31000, 31000, 33500, 33500, 
           33000, 31500, 34000, 35000, 35000, 36000, 38500, 38500, 35500, 
           33500, 34500, 36000, 35500, 34500, 35500, 38500, 44500, 40700, 
           40500, 39100, 39100, 39100, 38600, 39500, 39500, 38500, 39500, 
           40000, 40000, 40500, 41000, 41000, 41000, 40500, 40000, 39300, 
           39300, 39300, 39300, 39300, 39800)
coil <- data.frame(Year = Year, Month = Month, Coil = Coil)
dat <- coil

x <- ts(dat$Coil, start=c(dat$Year[1], dat$Month[1]), frequency=12)
ctrl <- tseriesControl(stepSize=1, maxHorizon=12, minObs=36, fixedWindow=TRUE)
models <- list()

models$arima = cv.ts(
  x, auto.arimaForecast, tsControl=ctrl,
  ic='aicc', stepwise=FALSE)

models$exp = cv.ts(
  x, etsForecast, tsControl=ctrl,
  ic='aicc', restrict=FALSE)

models$neural = cv.ts(
  x, nnetarForecast, tsControl=ctrl,
  nn_p=6, size=5)

models$tbats = cv.ts(
  x, tbatsForecast, tsControl=ctrl,
  seasonal.periods=12)

models$bats = cv.ts(
  x, batsForecast, tsControl=ctrl,
  seasonal.periods=12)

# this errors
# models$stl = cv.ts(
#   x, stl.Forecast, tsControl=ctrl,
#   s.window=12, ic='aicc', robust=TRUE, method='ets')

# calling the function itself works, https://github.com/zachmayer/cv.ts/issues/12
# forecast::stlf(
#      x, h = 12, s.window=12, ic='aicc', 
#      robust=TRUE, method='ets')

models$sts = cv.ts(x, stsForecast, tsControl=ctrl)

models$naive = cv.ts(x, naiveForecast, tsControl=ctrl)

models$theta = cv.ts(x, thetaForecast, tsControl=ctrl)


res_overall <- lapply(models, function(x) x$results[13,-1])
res_overall <- Reduce(rbind, res_overall)
row.names(res_overall) <- names(models)
res_overall <- res_overall[order(res_overall[,'MAPE']),]
round(res_overall, 2)



library(reshape2)
library(ggplot2)
res <- lapply(models, function(x) x$results$MAPE[1:12])
res <- data.frame(do.call(cbind, res))
res$horizon <- 1:nrow(res)
res <- melt(res, id.var='horizon', variable.name='model', value.name='MAPE')
res$model <- factor(res$model, levels=row.names(res_overall))
ggplot(res, aes(x=horizon, y=MAPE, col=model)) +
  geom_line(size=2) + theme_bw() +
  theme(legend.position="top") +
  scale_color_manual(values=c(
    "#1f78b4", "#ff7f00", "#33a02c", "#6a3d9a",
    "#e31a1c", "#b15928", "#a6cee3", "#fdbf6f",
    "#b2df8a")
  )





