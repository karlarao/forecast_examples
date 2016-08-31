# set current directory
set_current_directory()

# load excel data 
workbook <- loadWorkbook("storage.xlsx")

# load data
xdata <- readWorksheet(workbook, sheet = "Sheet1", header = TRUE)
xdata$Date <- as.POSIXct(xdata$Source, format="%Y-%m-%d/%H:%M:%S")
xdata2 <- zoo(xdata$Value, xdata$Date)
xdata3 <- ts(xdata2)

# validate data
# autoplot(xdata2)  # graph data
# xdata3 <- ts(xdata$Value, start=c(2016,01),frequency = 365/60); autoplot(decompose(xdata3)) # hack to get decomposition
# tsdisplay(xdata3) # check seasonality and autocorrelation
# tsdisplay(diff(xdata3, lag=1)) # check seasonality and autocorrelation

# save new data to excel sheet
# writeWorksheet (workbook, data=xdata, sheet="Sheet1", header = TRUE)
# saveWorkbook(workbook, file = "storage2.xlsx")

# generate forecast
e <- ets(xdata3) 
f <- forecast(xdata3,h=length(xdata3), level=FALSE)
GB <- append(xdata$Value,f$mean)

# plot 
capacity=362000
# Time <- seq(as.Date(min(xdata$Date)), by = "days", length = length(xdata3)*2)  # create seq of dates
Time <- seq(min(xdata$Date), by = "hours", length = length(xdata3)*2) # create seq of hours
plot(Time,GB, main=paste0("Storage (", month(min(xdata$Date),label=TRUE,abbr=FALSE),")"), ylim=c(0,capacity*2))
# axis(1, 1:length(xdata3)*2,  cex.axis = .7)   # just number index on x axis
abline(h=capacity, col="red", lty=2)
abline(v=max(xdata$Date), col="blue")
legend("topleft",legend=c("Capacity",paste0("Current Day ", as.Date(max(xdata$Date))) ),col=c("red","blue"), lty=c(2,1),  pt.cex=1, cex=.6)

