simulate <- function(data.in, log=FALSE, half.life=60, replace=TRUE, trials=10000, steps=100, smooth.window=20,plots=FALSE,capacity.past.lock=TRUE)
{
  if (log) data.in <- log(data.in)
  # separate the trend from the data
  x <- 1:length(data.in)
  loe <- loess(data.in~x,deg=1,span= smooth.window/length(data.in),control = loess.control(surface = "direct"))
  trend.part <- predict(loe,x)
  error.part <- data.in - trend.part
  if (plots)
  {
    hist(error.part,n=100)
    readline()
    plot(data.in)
    lines(trend.part,col='red',lwd=2)
    readline()
  }
  len <- length(data.in)
  weights <- NULL
  current.max.capacity <- max(data.in)
  if (half.life > 0)
  {
    weights <- exp(1/(half.life*log(.5))*(len):1)
    start <- max(1,len-half.life)
    current.max.capacity <- max(data.in[start:len])
  }
  trial.data <- matrix(NA, trials,steps)
  trial.trend <- matrix(NA, trials,steps)
  trend.data <- (trend.part[1:(len-1)+1]-trend.part[1:(len-1)])
  for (i in 1:trials) 
  {
    trial.trend[i,] <- cumsum(sample(trend.data,steps,prob=weights[1:(len-1)],replace)) + trend.part[len]
    trial.data[i,] <- trial.trend[i,] + sample(error.part,steps,prob=weights,replace)
    if (plots) 
    {
      plot(trial.data[i,])
      lines(trial.trend,lwd=2,col='red')
    }
#    for(j in 2:steps) 
#    {
#      if (trial.data[i,j] < trial.data[i,j-1]) 
#        trial.data[i,j] = trial.data[i,j-1]
#      if (trial.trend[i,j] < trial.trend[i,j-1]) 
#        trial.trend[i,j] = trial.trend[i,j-1]
#    }
    if (plots) 
    {
      lines(trial.data[i,])
      readline()
    }
  }
  if (log) trial.data <- exp(trial.data)
  #set minimum to old max if past lock is on
  if (capacity.past.lock) 
    trial.data[trial.data<current.max.capacity] <- current.max.capacity

  #set the minimum to 0
  trial.data[trial.data<0] <- 0

  list(capacity=trial.data, trend=trial.trend, data=data.in, data.trend=trend.part)
}

plot.simulation <- function(trial.data,xlim=NULL,ylim=NULL,axis.tics=20,probs=c(0.05,0.25,0.5,0.75,0.95),threshold=NULL,...)
{
  trial.trend <- trial.data$trend
  data <- trial.data$data
  trend.part <- trial.data$data.trend
  trial.data <- trial.data$capacity
  len <- length(data)
  steps <- ncol(trial.trend)
  capacity.quantiles <- apply(trial.data,2,quantile, probs=probs)
  trend.quantiles <- apply(trial.trend,2,quantile, probs=probs)
  capacity.mean <- apply(trial.data,2,mean)
  trend.mean <- apply(trial.trend,2,mean)
  if (is.null(xlim)) xlim <- c(0,len+steps)-len
  if (is.null(ylim)) ylim <- c(min(c(data, capacity.quantiles[1,])),max(capacity.quantiles[5,]))
  if (!is.null(threshold)) ylim[2] <- max(threshold,ylim)
  plot(-1,-1,xlim=xlim, ylim=ylim, xlab="Time",ylab="Value",axes=FALSE,...)
  axis(2,las=2)
  box()
  axis(1,at=c(seq(0,-1*len,by=-axis.tics),seq(0,steps,by= axis.tics)),las=2)
  abline(h=threshold,lwd=2,col="red")
  points(1:len-len,data)
  lines(1:len-len,trend.part,col='red',lwd=2)
  lines((1:steps), capacity.quantiles[1,],col='green',lwd=2)
  lines((1:steps), capacity.quantiles[2,],col='blue',lwd=2)
  lines((1:steps), capacity.quantiles[3,],col='brown',lwd=2)
  lines((1:steps), capacity.quantiles[4,],col='blue',lwd=2)
  lines((1:steps), capacity.quantiles[5,],col='green',lwd=2)
  lines((1:steps), capacity.mean,col='black',lwd=2)
  lines((1:steps), trend.quantiles[1,],col='green',lwd=2,lty=2)
  lines((1:steps), trend.quantiles[2,],col='blue',lwd=2,lty=2)
  lines((1:steps), trend.quantiles[3,],col='brown',lwd=2,lty=2)
  lines((1:steps), trend.quantiles[4,],col='blue',lwd=2,lty=2)
  lines((1:steps), trend.quantiles[5,],col='green',lwd=2,lty=2)
  lines((1:steps), trend.mean,col='black',lwd=2,lty=2)
  legend(-len,ylim[2]*.95,legend=c("trend","capacity"),lty=c(2,1),lwd=2,bg='white')
}

threshold.dates <- function(trial.data, threshold, get.mean=TRUE, quantiles=NULL)
{
  headroom.quantiles <- NULL
  headroom.mean <- NULL

  if (get.mean) 
  {
    means <- apply(trial.data$capacity,2,mean)
    temp.which <- which(means>=threshold)
    if (length(temp.which)>0) headroom.mean <- min(temp.which)
    else headroom.mean <- NA
  }
  if (length(quantiles) > 0)
  {
    headroom.quantiles <- NULL
    for (i in 1:length(quantiles))
    {
      quantiles.temp <- apply(trial.data$capacity,2,quantile,quantiles[i])
      temp.which <- which(quantiles.temp >=threshold)
      if (length(temp.which)>0) headroom.quantiles[i] <- min(temp.which)
      else headroom.quantiles[i] <- NA
    }
    headroom.quantiles <- cbind(quantiles, headroom.quantiles)
    colnames(headroom.quantiles) <- c("quantile","headroom")
  }
  return(list(mean=headroom.mean, quantiles=headroom.quantiles))
}

forecast <- function(trial.data,days,get.mean=TRUE, quantiles=NULL,threshold=NULL,plots=TRUE,ask.legend=FALSE)
{
  result <- NULL
  names <- NULL
  #if threshold is defined, forecast in terms of utilization
  #"*100" is because we want to do it in percentage
  if (!is.null(threshold))
  {
    trial.data$trend <- trial.data$trend/threshold*100
    trial.data$capacity <- trial.data$capacity/threshold*100
    ylab <- "Forecasted Utilization(%)"
  }
  else ylab <- "Forecasted Value"
  #do trend
  if (get.mean)
  {
    means <- apply(trial.data$trend,2,mean)
    result <- cbind(result,means[days])
    names <- c(names,"trend.mean")
  }
  if (length(quantiles) > 0)
  {
    for (i in 1:length(quantiles))
    {
      quantiles.temp <- apply(trial.data$trend,2,quantile,quantiles[i])
      result <- cbind(result, quantiles.temp[days])
      names <- c(names,paste("trend.quantile.",quantiles[i],sep=""))
    }
  }
  #do capacity
  if (get.mean)
  {
    means <- apply(trial.data$capacity,2,mean)
    result <- cbind(result,means[days])
    names <- c(names,"capacity.mean")
  }
  if (length(quantiles) > 0)
  {
    for (i in 1:length(quantiles))
    {
      quantiles.temp <- apply(trial.data$capacity,2,quantile,quantiles[i])
      result <- cbind(result, quantiles.temp[days])
      names <- c(names,paste("capacity.quantile.",quantiles[i],sep=""))
    }
  }
  if (plots)
  {
    ylim <- range(result)
    if (ylim[2] < 100) ylim[2] <- 100
    plot(-1,-1,xlim=range(days),ylim=ylim,xlab="Time",ylab=ylab,axes=F)
    axis(2)
    box()
    axis(1,at=days,las=2)
    legend.col <- NULL
    legend.lty <- NULL
    legend.name <- NULL
    index <- 1
    #plot trend
    if (get.mean) 
    {
      points(days,result[,index],pch=20)
      lines(days,result[,index],lty=2)
      legend.col[index] <- 1
      legend.lty[index] <- 2
      legend.name[index] <- "trend mean"
      index <- index+1
    }
    if (length(quantiles) > 0)
    {
      for (i in 1:length(quantiles))
      {
        lines(days,result[,index],col=i+1,lty=2)
        points(days,result[,index],col=i+1,pch=20)
        legend.col[index] <- i+1
        legend.lty[index] <- 2
        legend.name[index] <- paste("trend - ",quantiles[i]*100,"%",sep="")
        index <- index+1
      }
    }
    #plot capacity
    if (get.mean) 
    {
      points(days,result[,index],pch=20)
      lines(days,result[,index],lty=1)
      legend.col[index] <- 1
      legend.lty[index] <- 1
      legend.name[index] <- "capacity mean"
      index <- index+1
    }
    if (length(quantiles) > 0)
    {
      for (i in 1:length(quantiles))
      {
        lines(days,result[,index],col=i+1,lty=1)
        points(days,result[,index],col=i+1,pch=20)
        legend.col[index] <- i+1
        legend.lty[index] <- 1
        legend.name[index] <- paste("capacity - ",quantiles[i]*100,"%",sep="")
        index <- index+1
      }
    }
    if (ask.legend)
    {
      cat("Please click for the top-left corner of the legend position\n")
      pos <- locator()
      names <- NULL
      lty <- NULL
      col <- NULL
      if (get.mean) 
      {
        names <- c("mean")
        lty <- 1
        col <- 1
      }
      if (length(quantiles) > 0) 
      {
        names <- c(names, paste(quantiles*100,"%",sep=""))
        lty <- c(lty,rep(1,length(quantiles)))
        col <- c(col,1+1:length(quantiles))
      }
      names <- c(names, "trend","capacity")
      lty <- c(lty,2,1)
      col <- c(col,1,1)
      legend(pos$x[1],pos$y[1], legend=names, lty=lty, lwd=2, col=col)
    }
  }
  colnames(result) <- names
  rownames(result) <- paste("day.",days,sep="")
  result
}