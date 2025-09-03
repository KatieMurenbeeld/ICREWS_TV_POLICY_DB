library(pdftools)
library(rJava)
library(tabulapdf)
library(tesseract)
library(stringr)
library(vroom)

# water districts table
# https://research.idwr.idaho.gov/files/ExternalReports/WaterDistrictDescriptionReport.pdf

pdf_data <- "https://research.idwr.idaho.gov/files/ExternalReports/WaterDistrictDescriptionReport.pdf"

download.file(pdf_data, here::here("data/original/water_districts_id.pdf"))

test_pdf <- here::here("data/original/water_districts_id.pdf")

extract_tables(test_pdf, pages = 2)

pdf_tables <- pdf_data %>% 
  extract_tables(method = "lattice", pages = 1) 

dat <- vroom(pdf_tables)

areas <- extract_areas(pdf_data)

# Use the coordinates from the interactive selection to re-extract the tables
extracted_tables_manual <- extract_tables(pdf_data, area = areas)

test_df <- pdf_tables[[2]]
library(dplyr)
library(tidyr)

# Example: If a column was split across multiple rows, and the cell contents can be identified, you can use `separate()` or `unite()`
# You will need to inspect your data to see how the rows were split.
# This is a simplified example
df_repaired <- test_df %>%
  group_by(`Description:`) %>% # `some_id` is a unique identifier if possible
  summarise(across(everything(), ~paste(na.omit(.), collapse = " "))) %>%
  ungroup()

d

wd_metadata <- extract_metadata(pdf_data, password = NULL, copy = FALSE)

get_page_dims(pdf_data)

#region <- c(250, 0, 450, 595)

test_tables <- pdf_data %>% 
  extract_tables(output = "tibble", area = ) 

pdf_ocr_text(pdf_data)

# using pdftools
# https://crimebythenumbers.com/scrape-table.html
water_districts <- pdf_text(pdf_data)
length(water_districts)

water_districts[1]

sector_profile <- water_districts[1]
sector_newline <- str_replace_all(sector_profile[[1]], "\n", "  ")
sector_newline
sector_profile
sector_profile <- strsplit(sector_profile, "\n")
sector_test <- sector_profile[[1]]
head(sector_profile)
head(sector_test)

sector_profile <- sector_profile[grep("\n01", sector_profile):
                                   grep("\n02", sector_profile)]


sector_test_row01 <- str_c(sector_newline[3:12], collapse = " ")

sector_test_row01 <- trimws(sector_test_row01)
head(sector_test_row01)

sector_test_row01 <- str_split_fixed(sector_test_row01, " {2,}", 5)
head(sector_test_row01)
sector_test_row01

# the first page is messed up
page01_row01 <- sector_profile[grep("\n01", sector_profile):
                                   grep("\n02", sector_profile)]
