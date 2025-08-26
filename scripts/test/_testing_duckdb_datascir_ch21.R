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


flights %>% show_query()
planes %>% show_query()

flights %>% 
  filter(dest == "IAH") %>%
  arrange(dep_delay) %>%
  show_query()

flights %>%
  group_by(dest) %>%
  summarise(dep_delays = mean(dep_delay, na.rm = TRUE)) %>%
  show_query()

## SELECT
planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  show_query()

planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  rename(year_built = year) |> 
  show_query()

planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  relocate(manufacturer, model, .before = type) |> 
  show_query()

flights |> 
  mutate(
    speed = distance / (air_time / 60)
  ) |> 
  show_query()

## GROUP BY

diamonds_db |> 
  group_by(cut) |> 
  summarize(
    n = n(),
    avg_price = mean(price, na.rm = TRUE)
  ) |> 
  show_query()

## WHERE 

flights |> 
  filter(dest == "IAH" | dest == "HOU") |> 
  show_query()

flights |> 
  filter(arr_delay > 0 & arr_delay < 20) |> 
  show_query()

flights |> 
  filter(dest %in% c("IAH", "HOU")) |> 
  show_query()

flights |> 
  group_by(dest) |> 
  summarize(delay = mean(arr_delay)) |>
  show_query()

flights |> 
  filter(!is.na(dep_delay)) |> 
  show_query()

diamonds_db |> 
  group_by(cut) |> 
  summarize(n = n()) |> 
  filter(n > 100) |> 
  show_query()

## ORDER BY

flights |> 
  arrange(year, month, day, desc(dep_delay)) |> 
  show_query()

## Subqueries

flights |> 
  mutate(
    year1 = year + 1,
    year2 = year1 + 1
  ) |> 
  show_query()

flights |> 
  mutate(year1 = year + 1) |> 
  filter(year1 == 2014) |> 
  show_query()

## Joins

flights |> 
  left_join(planes |> rename(year_built = year), join_by(tailnum)) |> 
  show_query()
