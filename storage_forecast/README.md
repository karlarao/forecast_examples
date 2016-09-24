

#### Updated Graph with headroom expiry days
<a href="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/headroom%20threshold%20with%20expiry%20days/80_percent.png" target="_blank">
<img class="aligncenter" style="width: 600px;" src="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/headroom%20threshold%20with%20expiry%20days/80_percent.png" />
</a>

The idea behind the viz is shown below: 
---

#### Exponential smoothing (without outliers)
This trend shows and additive trend on the data and the forecast (beyond the blue line) seems to be pretty robust.
<a href="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08_august_ets.png?raw=true" target="_blank">
<img class="aligncenter" style="width: 600px;" src="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08_august_ets.png?raw=true" />
</a>

#### Exponential smoothing (with outliers)
But when I put some outliers on the data the forecast gets out of whack. This means the model is not robust to outliers. That's a very important factor for forecasting.
<a href="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08b_august_ets_not_robust.png?raw=true" target="_blank">
<img class="aligncenter" style="width: 600px;" src="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08b_august_ets_not_robust.png?raw=true" />
</a>

#### Linear regression w/ quadratic trend + sine/cosine (with outliers)
When the model was changed to Liner Regression and adding a quadratic trend as well as sine and cosine functions for capturing the smooth seasonality pattern the forecast became robust to outliers. 
<a href="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08c_august_robust_with_outliers.png?raw=true" target="_blank">
<img class="aligncenter" style="width: 600px;" src="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08c_august_robust_with_outliers.png?raw=true" />
</a>

#### Linear regression w/ quadratic trend + sine/cosine (without outliers)
Here's the forecast without the outliers.
<a href="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08d_august_robust_no_outliers.png?raw=true" target="_blank">
<img class="aligncenter" style="width: 600px;" src="https://raw.githubusercontent.com/karlarao/forecast_examples/master/storage_forecast/examples/08d_august_robust_no_outliers.png?raw=true" />
</a>


