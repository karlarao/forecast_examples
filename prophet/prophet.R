

# set_current_directory()
# use inside the script to set the current working directory

# http://stackoverflow.com/a/36777602/4285039
csf <- function() {
  # http://stackoverflow.com/a/32016824/2292993
  cmdArgs = commandArgs(trailingOnly = FALSE)
  needle = "--file="
  match = grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript via command line
    return(normalizePath(sub(needle, "", cmdArgs[match])))
  } else {
    ls_vars = ls(sys.frames()[[1]])
    if ("fileName" %in% ls_vars) {
      # Source'd via RStudio
      return(normalizePath(sys.frames()[[1]]$fileName))
    } else {
      if (!is.null(sys.frames()[[1]]$ofile)) {
        # Source'd via R console
        return(normalizePath(sys.frames()[[1]]$ofile))
      } else {
        # RStudio Run Selection
        # http://stackoverflow.com/a/35842176/2292993
        return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
      }
    }
  }
}

set_current_directory <- function() {
  source_file <- csf()
  
  # fix path http://stackoverflow.com/posts/26488342/revisions
  source_file <- gsub("\\\\","/",source_file)
  
  # just get directory path http://stackoverflow.com/posts/15073919/revisions
  current_dir <- gsub("(.*\\/)([^.]+)(\\.[[:alnum:]]+$)", "\\1", source_file)
  setwd(current_dir)
  getwd()
}


set_current_directory()
library(prophet)
df <- read.csv('example_wp_log_R.csv')

# set capacity line
df$cap <- 8.5

# model
m <- prophet(df, growth = 'logistic')

# forecast 
future <- make_future_dataframe(m, periods = 1826)
future$cap <- 8.5
fcst <- predict(m, future)
plot(m, fcst)




