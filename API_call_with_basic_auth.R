#!/usr/bin/env Rscript

library(httr)
library(jsonlite)

#Add your authorization keys below
consumer_key = "KZMsb226rX5vJmzzB5fH";
consumer_secret = "TXw7jGDNWdfjt7vvcVXQtCX0";
auth_url = paste0("https://example.com/api/login?",
                 "client_id=",consumer_key, 
                 "&client_secret=", consumer_secret)

#POST request for auth token
req <- httr::POST(auth_url);
raw_auth <- httr::content(req, as = "text")
auth <- fromJSON(raw_auth)
token <- auth$access_token

#GET data
url <- "https://example.com/api/"
req <- httr::GET(url, httr::add_headers(Authorization = paste("Bearer", token, sep = " ")))
json <- httr::content(req, as = "text")
data <- fromJSON(json)
