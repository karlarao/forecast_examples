
# http://robjhyndman.com/hyndsight/tscvexample/

###########################################
# summary of the window calculations
###########################################
# example1: add 1 on training set
# xshort <- window(a10, end=st + i/12)
# xnext <- window(a10, start=st + (i+1)/12, end=st + (i+12)/12)

# example2: fixed training window (training set always consists of k observations)
# xshort <- window(a10, start=st+(i-k+1)/12, end=st+i/12)
# xnext <- window(a10, start=st + (i+1)/12, end=st + (i+12)/12)

# example3: one step forecast in test
# xshort <- window(a10, end=st + i/12)
# xnext <- window(a10, start=st + (i+1)/12, end=st + (i+12)/12)
# xlong <- window(a10, end=st + (i+12)/12)

# example4: k-fold cross-validation (for large data sets)
# xshort <- window(a10, end=st + (i-1))
# xnext <- window(a10, start=st + (i-1) + 1/12, end=st + i)

# Zach's cv.ts used the example #2 and #1 on his tool (https://github.com/zachmayer/cv.ts)
# more examples here https://gist.github.com/zachmayer/1383028
# if (fixedWindow) {
#   xshort <- window(x, start=st+(i-minObs+1)/freq, end=st+i/freq)
#   
# } else {
#   xshort <- window(x, end=st + i/freq)
# }


###########################################
# examples 1-4 (LM only on a10 data) 
###########################################


library(fpp) # To load the data set a10
plot(a10, ylab="$ million", xlab="Year", main="Antidiabetic drug sales")
plot(log(a10), ylab="", xlab="Year", main="Log Antidiabetic drug sales")

k <- 60 # minimum data length for fitting a model
n <- length(a10)
mae1 <- mae2 <- mae3 <- matrix(NA,n-k,12)
st <- tsp(a10)[1]+(k-2)/12

# Example1: add 1 on training set
for(i in 1:(n-k))
{
  xshort <- window(a10, end=st + i/12)
  xnext <- window(a10, start=st + (i+1)/12, end=st + (i+12)/12)
  fit1 <- tslm(xshort ~ trend + season, lambda=0)
  fcast1 <- forecast(fit1, h=12)
  # fit2 <- Arima(xshort, order=c(3,0,1), seasonal=list(order=c(0,1,1), period=12), 
  #               include.drift=TRUE, lambda=0, method="ML")
  # fcast2 <- forecast(fit2, h=12)
  # fit3 <- ets(xshort,model="MMM",damped=TRUE)
  # fcast3 <- forecast(fit3, h=12)
  mae1[i,1:length(xnext)] <- abs(fcast1[['mean']]-xnext)
  # mae2[i,1:length(xnext)] <- abs(fcast2[['mean']]-xnext)
  # mae3[i,1:length(xnext)] <- abs(fcast3[['mean']]-xnext)
}

plot(1:12, colMeans(mae1,na.rm=TRUE), type="l", col=2, xlab="horizon", ylab="MAE",
     ylim=c(0.65,1.05))
lines(1:12, colMeans(mae2,na.rm=TRUE), type="l",col=3)
lines(1:12, colMeans(mae3,na.rm=TRUE), type="l",col=4)
legend("topleft",legend=c("LM","ARIMA","ETS"),col=2:4,lty=1)


# Example 2: fixed training window (training set always consists of k observations)
for(i in 1:(n-k))
{
  xshort <- window(a10, start=st+(i-k+1)/12, end=st+i/12)
  xnext <- window(a10, start=st + (i+1)/12, end=st + (i+12)/12)
  fit1 <- tslm(xshort ~ trend + season, lambda=0)
  fcast1 <- forecast(fit1, h=12)
  # fit2 <- Arima(xshort, order=c(3,0,1), seasonal=list(order=c(0,1,1), period=12), 
  #               include.drift=TRUE, lambda=0, method="ML")
  # fcast2 <- forecast(fit2, h=12)
  # fit3 <- ets(xshort,model="MMM",damped=TRUE)
  # fcast3 <- forecast(fit3, h=12)
  mae1[i,1:length(xnext)] <- abs(fcast1[['mean']]-xnext)
  # mae2[i,1:length(xnext)] <- abs(fcast2[['mean']]-xnext)
  # mae3[i,1:length(xnext)] <- abs(fcast3[['mean']]-xnext)
}

plot(1:12, colMeans(mae1,na.rm=TRUE), type="l", col=2, xlab="horizon", ylab="MAE",
     ylim=c(0.65,1.05))
lines(1:12, colMeans(mae2,na.rm=TRUE), type="l",col=3)
lines(1:12, colMeans(mae3,na.rm=TRUE), type="l",col=4)
legend("topleft",legend=c("LM","ARIMA","ETS"),col=2:4,lty=1)

# Example 3: one step forecast in test
for(i in 1:(n-k))
{
  xshort <- window(a10, end=st + i/12)
  xnext <- window(a10, start=st + (i+1)/12, end=st + (i+12)/12)
  xlong <- window(a10, end=st + (i+12)/12)
  fit1 <- tslm(xshort ~ trend + season, lambda=0)
  fcast1 <- forecast(fit1, h=12)$mean
  # fit2 <- Arima(xshort, order=c(3,0,1), seasonal=list(order=c(0,1,1), period=12), 
  #               include.drift=TRUE, lambda=0, method="ML")
  # fit2a <- Arima(xlong, model=fit2, lambda=0)
  # fcast2 <- fitted(fit2a)[-(1:length(xshort))]
  # fit3 <- ets(xshort,model="MMM",damped=TRUE)
  # fit3a <- ets(xlong, model=fit3)
  # fcast3 <- fitted(fit3a)[-(1:length(xshort))]
  mae1[i,1:length(xnext)] <- abs(fcast1-xnext)
  # mae2[i,1:length(xnext)] <- abs(fcast2-xnext)
  # mae3[i,1:length(xnext)] <- abs(fcast3-xnext)
}

plot(1:12, colMeans(mae1,na.rm=TRUE), type="l", col=2, xlab="horizon", ylab="MAE",
     ylim=c(0.65,1.05))
lines(1:12, colMeans(mae2,na.rm=TRUE), type="l",col=3)
lines(1:12, colMeans(mae3,na.rm=TRUE), type="l",col=4)
legend("topleft",legend=c("LM","ARIMA","ETS"),col=2:4,lty=1)

# Example 4: k-fold cross-validation (for large data sets)
k <- 60 # minimum data length for fitting a model
n <- length(a10)
mae1 <- mae2 <- mae3 <- matrix(NA,12,12)
st <- tsp(a10)[1]+(k-1)/12
for(i in 1:12)
{
  xshort <- window(a10, end=st + (i-1))
  xnext <- window(a10, start=st + (i-1) + 1/12, end=st + i)
  fit1 <- tslm(xshort ~ trend + season, lambda=0)
  fcast1 <- forecast(fit1, h=12)
  # fit2 <- Arima(xshort, order=c(3,0,1), seasonal=list(order=c(0,1,1), period=12), 
  #               include.drift=TRUE, lambda=0, method="ML")
  # fcast2 <- forecast(fit2, h=12)
  # fit3 <- ets(xshort,model="MMM",damped=TRUE)
  # fcast3 <- forecast(fit3, h=12)
  mae1[i,] <- abs(fcast1[['mean']]-xnext)
  # mae2[i,] <- abs(fcast2[['mean']]-xnext)
  # mae3[i,] <- abs(fcast3[['mean']]-xnext)
}
plot(1:12, colMeans(mae1), type="l", col=2, xlab="horizon", ylab="MAE",
     ylim=c(0.35,1.5))
lines(1:12, colMeans(mae2), type="l",col=3)
lines(1:12, colMeans(mae3), type="l",col=4)
legend("topleft",legend=c("LM","ARIMA","ETS"),col=2:4,lty=1)
mean(mae1)
# mean(mae2)
# mean(mae3)





