if(!require("DBI")) install.packages("DBI")
if(!require("RMySQL")) install.packages("RMySQL")
if(!require("jsonlite")) install.packages("jsonlite")
if(!require("httr")) install.packages("httr")

library(DBI)
library(RMySQL)
library(jsonlite)
library(httr)

#Set the Seed for repeatability
set.seed(2000)

#Estabalishes the connection
conn = dbConnect(MySQL(), user='r_example', password='ExamplePassword', dbname='example_database', host='0.0.0.0')

#Lists all tables
dbListTables(conn)

#Sends the query to get the columns and rows
rs = dbSendQuery(conn,"SELECT * FROM colorado_water.2016_WaterQuality;")

#Compiles the data and removes the header
df = fetch(rs, n=-1)
df = as.data.frame(df)

#Disconnects with the database
dbDisconnect(conn)
