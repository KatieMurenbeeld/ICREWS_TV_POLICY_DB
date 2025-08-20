library(DBI)
library(dbplyr)
library(tidyverse)


# create a database connection
con <- DBI::dbConnect(duckdb::duckdb())

# load some data
dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)

# use dbListTables to see the tables in the database
dbListTables(con)

## use dbReadTable (default is a data.frame) and as_tibble to 
## review the tables
con %>%
  dbReadTable("mpg") %>%
  as_tibble()

# use SQL to query the database
sql <- "
  SELECT carat, cut, clarity, color, price 
  FROM diamonds 
  WHERE price > 15000
"
as_tibble(dbGetQuery(con, sql))


# intro to dbplyr
## must be a table object
diamonds_db <- tbl(con, "diamonds")
diamonds_db

## use normal dplyr commands
big_diamonds_db <- diamonds_db |> 
  filter(price > 15000) |> 
  select(carat:clarity, price)

big_diamonds_db
### Note: This is lazy, only recording the sequence of operations but not running them

## can see the SQL equivalent
big_diamonds_db |> 
  show_query()

## to get the subset and filter data into R have to collect it into memory as a tibble
big_diamonds <- big_diamonds_db |>
  collect()
big_diamonds

# Learning some SQL basics through the lens of dplyr

dbplyr::copy_nycflights13(con)
flights <- tbl(con, "flights")
planes <- tbl(con, "planes")


