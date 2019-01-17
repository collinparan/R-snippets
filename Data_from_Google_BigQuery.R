library(bigrquery)

# Put your project ID here
project <- "something-test-project" 

# Example query
sql <- 'SELECT vendor_id, pickup_datetime, passenger_count, store_and_fwd_flag, FORMAT("%.02f", trip_distance) as `trip_distance` FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2018` LIMIT 100'

# Execute the query and store the result
df <- query_exec(sql, project = project, use_legacy_sql = FALSE, max_pages=Inf, page_size=500000)

#Do something with the data
modified_data <- df

#CAUTION! This overwrites modified data set
insert_upload_job(project, "collin_test", "df", modified_data, write_disposition = "WRITE_TRUNCATE")
