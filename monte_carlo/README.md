

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
#arg 4 is quantile [default .99]
#arg 5 is capacity locked to past max (1 if true 0 if false) 
#arg 6 is #days or #samples to project out [default is data length / 2]
EXAMPLE:  /usr/bin/Rscript/Rscript analyze.R cpu.txt 96 120 0.99 1 200

OUTPUTS:
PDF of plot  (same name as input file except with PDF extension) tab delimited file with HRE at quantile chosen on input [see default above]

LIMITATIONS:
* Right now, the program doesn’t look at the date column, only the data column and assumes that the dates are increasing one day or sample at a time. So, if this is not the case, it can give some wrong results. This will be fixed in the future. 

```

### Example run:

##### Characterize the data using Tableau
* Check the folder [raw_data_and_exploratory_viz](https://github.com/karlarao/forecast_examples/tree/master/monte_carlo/raw_data_and_exploratory_viz) for the example file and tableau worksheet. From here you are free to filter data and drill down on the data sample you want to forecast. In this example the CPU capacity shows as 28 per host (there could be instance caging set), so on this graph which is a clusterwide aggregation of CPU demand the overall capacity is actually 28x2 (this is a 2node RAC environment). Around Sept 28 to Oct 6 the workload reached the max capacity of the cluster.  
![](https://i.imgur.com/I3gjEFR.png)
* In this example I "keep only" the AAS CPU and then pivoted the data
![](https://i.imgur.com/EA2nQSN.png) 
* From here you can export the data to excel. Go to "Worksheet" -> "Export" -> "Crosstab to Excel"
* Copy the A and B columns to cpu.txt file 
![](https://i.imgur.com/YsPSs2Y.png)
* Run the script 

```
E:\GitHub\forecast_examples\monte_carlo>"C:\Program Files\R\R-3.2.2\bin\Rscript.exe" analyze.R cpu.txt 99 120 0.99 0 1600
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
* In this data example, per row or data is 1hour and we are looking at the past 120 data to forecast with .99 accuracy the next 1600 which is equivalent to about 66 days (1600/24hours)
* In terms of capacity planning this cluster, we have about 2months to reach the 75% CPU utilization range. We can either do a remediation on the workload (tuning) or add more machines to the cluster (2months lead time).   

![](https://i.imgur.com/J65h63C.png)



### Exploring the parameters:

* Running with few parameters
	* You can also run with ONLY the input file and threshold value as parameters
```
E:\GitHub\forecast_examples\monte_carlo>"C:\Program Files\R\R-3.2.2\bin\Rscript.exe" analyze.R cpu.txt 99
Running Monte Carlo. Please wait
null device
          1
$mean
[1] NA

$quantiles
     quantile headroom
[1,]    0.950       NA
[2,]    0.975       NA
[3,]    0.990       NA
``` 
And this will output to 
![](https://i.imgur.com/Uiu5zkj.png)

* Smooth Window 
	* The smooth window (default 120) looks back to the recent 120 samples to give "more weight" vs older data (the ones older than 120 samples)  
	* Here we set the smooth window to 1600 (2months) which is equivalent to the oldest data where the workload was still better and no spikes are occurring
```
E:\GitHub\forecast_examples\monte_carlo>"C:\Program Files\R\R-3.2.2\bin\Rscript.exe" analyze.R cpu.txt 99 1600 0.99 0 1600
Running Monte Carlo. Please wait
null device
          1
$mean
[1] NA

$quantiles
     quantile headroom
[1,]     0.99       NA
``` 

* The forecast did not put weight on the more recent spikes or growth of workload and so the output showed that everything is fine for the next 2 months
* Just keep this in mind when forecasting!
![](https://i.imgur.com/6cCDJex.png)

