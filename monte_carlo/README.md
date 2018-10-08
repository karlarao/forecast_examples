

### Setup:
```
How to setup:
* Setup R on your computer
* put the ‘analyze.R’ and ‘functions.R’ scripts in the same folder
* call Rscript like this:
  /usr/bin/Rscript/Rscript analyze.R cpu.txt 96 120 0.99 1 200
  * NOTE: the location of Rscript on your computer may be different if you’re not using OSX. On windows it’s C:/Program Files/R/R-3.1.1/bin/Rscript.exe
  * NOTE: if the input file is not in the directory of the R script, you should use the full path like this:
    /usr/bin/Rscript/Rscript /full/path/to/analyze.R /full/path/to/cpu.txt 96 120 0.99 1 200

INPUT: 
#arg 1 is name of input file
#arg 2 is threshold value
#arg 3 is smooth window [default 120]
#arg 4 is quantile [default 120]
#arg 5 is capacity locked to past max (1 if true 0 if false) 
#arg 6 is #days or #samples to project out [default is data length / 2]
EXAMPLE:  /usr/bin/Rscript/Rscript analyze.R cpu.txt 96 120 0.99 1 200

OUTPUTS:
PDF of plot  (same name as input file except with PDF extension) tab delimited file with HRE at quantile chosen on input [see default above]

LIMITATIONS:
* Right now, the program doesn’t look at the date column, only the data column and assumes that the dates are increasing one day or sample at a time. So, if this is not the case, it can give some wrong results. This will be fixed in the future. 

```

### Example run:
```
E:\GitHub\forecast_examples\monte_carlo>"C:\Program Files\R\R-3.2.2\bin\Rscript.exe" analyze.R cpu.txt 99 120 0.99 1 1600
Running Monte Carlo. Please wait
null device
          1
$mean
[1] NA

$quantiles
     quantile headroom
[1,]     0.99       NA
```
Then view the cpu.pdf output 




