if(!require("anytime")) install.packages("anytime")
if(!require("jsonlite")) install.packages("jsonlite")
if(!require("httr")) install.packages("httr")
if(!require("plotly")) install.packages("plotly")
if(!require("quantmod")) install.packages("quantmod")
if(!require("randomForest")) install.packages("randomForest")
if(!require("rpart")) install.packages("rpart")
if(!require("rpart.plot")) install.packages("rpart.plot")
if(!require("dplyr")) install.packages("dplyr")
if(!require("prophet")) install.packages("prophet")
if(!require("animation")) install.packages("animation")

library(anytime)
library(jsonlite)
library(httr)
library(plotly)
library(quantmod)
library(randomForest)
library(rpart)
library(rpart.plot)
library(dplyr)
library(prophet)


#Daily data via GET API
alldata <- fromJSON("https://api.gdax.com/products/BTC-USD/candles?granularity=86400") #granularity in seconds

alldata <- as.data.frame(alldata)

colnames(alldata)<- c("time", "low", "high", "open", "close", "volume")

alldata$date_time<-anytime(alldata$time)

alldata$ds<-anydate(alldata$time)

#Mutates to add change
mutate(alldata, alldata$futureopen <- lead(alldata$open) - alldata$open)
mutate(alldata, alldata$percentchange <- alldata$futureopen/alldata$open)
mutate(alldata, alldata$trend <- cut(alldata$percentchange, breaks=c(-Inf, -0.02, 0.02, Inf), labels=c("down","neutral","up")))

#Candlestick charts
p <- alldata %>%
  plot_ly(x = alldata$date_time, type="candlestick",
          open = alldata$open, close = alldata$close,
          high = alldata$high, low = alldata$low) %>%
  layout(title = "GDAX Candlestick Chart")

p


#########################################################
#Using Facebook Prophet
##########################################################

stats <- alldata %>% 
  select(ds, open) 

colnames(stats) <- c("ds", "y")

View(summary(stats))

m <- prophet(stats)
future <- make_future_dataframe(m, periods = 90)
forecast <- predict(m, future)

plot(m, forecast, main="Bitcoin & FB Prophet", sub="analysis by Collin Paran", xlab="time", ylab="USD value")


tail(forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')])

tail(forecast)

prophet_plot_components(m, forecast)

#############################################
##Plotly
############################################
p <- plot_ly(forecast, x = forecast$ds, y = forecast$yhat_upper, type = 'scatter', mode = 'lines',
             line = list(color = 'transparent'),
             showlegend = FALSE, name = 'High') %>%
  add_trace(y = forecast$yhat_lower, type = 'scatter', mode = 'lines',
            fill = 'tonexty', fillcolor='rgba(168, 216, 234,0.5)', line = list(color = 'transparent'),
            showlegend = FALSE, name = 'Low') %>%
  add_trace(x = forecast$ds, y = forecast$yhat, type = 'scatter', mode = 'lines',
            line = list(color='rgb(168, 216, 234)'),
            name = 'Average') %>%
  add_trace(x = alldata$ds, y = alldata$open, type = 'scatter', mode = 'markers',
            line = list(color=I('black')),
            name = 'Actual') %>%
  layout(title = "Average, High and Low Price",
         paper_bgcolor='rgb(255,255,255)', plot_bgcolor='rgb(229,229,229)',
         xaxis = list(title = "Date Time",
                      gridcolor = 'rgb(255,255,255)',
                      showgrid = TRUE,
                      showline = FALSE,
                      showticklabels = TRUE,
                      tickcolor = 'rgb(127,127,127)',
                      ticks = 'outside',
                      zeroline = FALSE),
         yaxis = list(title = "USD",
                      gridcolor = 'rgb(255,255,255)',
                      showgrid = TRUE,
                      showline = FALSE,
                      showticklabels = TRUE,
                      tickcolor = 'rgb(127,127,127)',
                      ticks = 'outside',
                      zeroline = FALSE))

p
