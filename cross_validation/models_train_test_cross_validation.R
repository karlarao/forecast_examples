
# http://stats.stackexchange.com/questions/140163/timeseries-analysis-procedure-and-methods-using-r

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
test_x <- window(x, start=c(2012, 3))
x <- window(x, end=c(2012, 2))

models <- list(
  mod_arima = auto.arima(x, ic='aicc', stepwise=FALSE),
  mod_exp = ets(x, ic='aicc', restrict=FALSE),
  mod_neural = nnetar(x, p=12, size=25),
  mod_tbats = tbats(x, ic='aicc', seasonal.periods=12),
  mod_bats = bats(x, ic='aicc', seasonal.periods=12),
  mod_stl = stlm(x, s.window=12, ic='aicc', robust=TRUE, method='ets'),
  mod_sts = StructTS(x)
)

forecasts <- lapply(models, forecast, 12)
forecasts$naive <- naive(x, 12)
par(mfrow=c(3, 3))
for(f in forecasts){
  plot(f)
  lines(test_x, col='red')
}

# test
acc <- lapply(forecasts, function(f){
  accuracy(f, test_x)[2,,drop=FALSE]
})
acc <- Reduce(rbind, acc)
row.names(acc) <- names(forecasts)
acc <- acc[order(acc[,'MASE']),]
round(acc, 2)

# training
acc <- lapply(forecasts, function(f){
  accuracy(f, test_x)[1,,drop=FALSE]
})
acc <- Reduce(rbind, acc)
row.names(acc) <- names(forecasts)
acc <- acc[order(acc[,'MASE']),]
round(acc, 2)






