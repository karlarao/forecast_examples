

### R script HOWTO:
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
#arg 3 is smooth window [default 120] - #days to look back
#arg 4 is quantile [default .99]
#arg 5 is capacity locked to past max (1 if true 0 if false) 
#arg 6 is #days or #samples to project out [default is data length / 2]

EXAMPLE:  
Rscript analyze.R cpu.txt 96 120 0.99 1 200

OUTPUT:
PDF of plot  (same name as input file except with PDF extension) tab delimited file with HRE 
at quantile chosen on input [see default above]

LIMITATIONS:
Right now, the program doesn’t look at the date column, only the data column and assumes that 
the dates are increasing one day or sample at a time. So, if this is not the case, it can 
give some wrong results. This will be fixed in the future. 

```


##### NOTE:

* Read the PDF - [CPU capacity forecasting and node failure scenarios](https://github.com/karlarao/forecast_examples/blob/master/monte_carlo/HOWTO_CPU%20capacity%20forecasting%20and%20node%20failure%20scenarios.pdf) to learn how to apply forecasting with sizing scenarios 
* The entire exercise files and output are available on this folder [4_node_rac_cluster_forecast](https://github.com/karlarao/forecast_examples/tree/master/monte_carlo/4_node_rac_cluster_forecast) 





### Example run:

![](https://i.imgur.com/d3SnVWK.png)


![](https://i.imgur.com/2PcawjX.png)

![](https://i.imgur.com/IGuadBI.png)

![](https://i.imgur.com/3WqlzhJ.png)

![](https://i.imgur.com/0xlFtuD.png)

![](https://i.imgur.com/MXblgXK.png)

![](https://i.imgur.com/UIWAFC3.png)


![](https://i.imgur.com/H9wFLSU.png)

![](https://i.imgur.com/Ktg2om2.png)

![](https://i.imgur.com/76BrKLw.png)

![](https://i.imgur.com/3iCZlZJ.png)

![](https://i.imgur.com/qV1ePzR.png)


## Other forecast examples:

![](https://i.imgur.com/s07lSV6.png)

![](https://i.imgur.com/R8dYFFE.png)


