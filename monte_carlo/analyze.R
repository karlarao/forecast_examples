#get all of the function code
source("functions.R")
#get the command line args
args <- commandArgs(trailingOnly = TRUE)

#arg 1 is name of input file
#arg 2 is threshold value
#arg 3 is smooth window [default 120]
#arg 4 is quantile [default 120]
#arg 5 is capacity locked to past max (1 if true 0 if false)
#arg 6 is #days or #samples to project out [default is data length / 2]
#EXAMPLE /usr/bin/Rscript/Rscript analyze.R cpu.txt 96 120 0.99 1 200

if (length(args) < 2) stop("Usage input_file threshold <smooth window> <quantile>")

srcFile <- args[1]
#derive the pdf filename by removing the extention and adding ".pdf"
pdfFile <- paste(sub("\\.[[:alnum:]]+$", "",srcFile),".pdf",sep="")
#derive output file by removing extension and adding ".hre.txt"
outFile <- paste(sub("\\.[[:alnum:]]+$", "",srcFile),".hre.txt",sep="")

threshold <- as.numeric(args[2])

#get the window if passed
if (length(args)> 2) { window <- as.numeric(args[3]) 
} else window <- 120

#get the hre.quantile if passed
if (length(args)> 3) { hre.quantile <- as.numeric(args[4]) 
} else hre.quantile <- c(.95,.975,.99)

#get capacity past lock if set
if ((length(args)> 4) && (as.numeric(args[5])==1)) { capacity.past.lock=TRUE
} else capacity.past.lock=FALSE



#read the input file
data.in <- read.table(srcFile, header=T, sep="\t",na.strings = "",)

#strip out NA values
ind <- !is.na(data.in[,2])
data.in <- data.in[ind,]
#only look at the second column
data <- data.in[,2]
data <- as.numeric(data)

#get the #steps if passed
if (length(args)> 5) { steps <- as.numeric(args[6]) 
} else steps <- length(data) / 2

#set the parameters to run
half.life <- window
smooth.window <- window
cat("Running Monte Carlo. Please wait","\n", sep="")
#run the trial
#set capacity.past.lock=FALSE if you don't want the minimum capacity value to be at least oldest previous maximum
trial.data <- simulate(data,half.life=half.life, steps=steps, smooth.window=smooth.window, capacity.past.lock=capacity.past.lock)

#plot it in the PDF file)
pdf(file=pdfFile, width=9, height=6.5)
plot.simulation(trial.data,probs=c(0.01,0.05,0.5,0.95,0.99),threshold=threshold, main=srcFile)
dev.off()

#calculate the headroom expiry
HRE <- threshold.dates(trial.data,threshold=threshold,quantiles=hre.quantile)
#show it on the screen
HRE
write.table(HRE$quantiles,file=outFile,quote=FALSE,sep="\t", row.names=FALSE,col.names=TRUE)
