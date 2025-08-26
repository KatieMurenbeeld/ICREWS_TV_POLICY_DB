library(DBI)
library(dbplyr)
library(tidyverse)






# Create a sqlite database
mydb <- dbConnect(RSQLite::SQLite(), "my-db.sqlite")

# Create a table to add to the database

test_dt_01 <- data.frame(matrix(ncol=3,nrow=0, dimnames=list(NULL, c("state", "county", "city"))))
