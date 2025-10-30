library(shiny)
library(shinyFeedback)
library(dplyr)
library(ggplot2)
library(googlesheets4)
library(rsconnect)
library(DT)
library(lubridate)


### Before running the app copy the following lines of code into the console
library(googlesheets4)
#setwd(here::here())
#gs4_auth(email = "your@email.edu", cache = ".secrets")
# Make sure to update your .gitignore to include .secrets and */.secrets
# You will be taken to an authorization page, make sure to check the box that allows for editing
###

gs4_auth(cache = ".secrets", email = "katiemurenbeeld@boisestate.edu")

#sheet_id <- "https://docs.google.com/spreadsheets/d/1jn_TqyXtymTnzBb16T_ksquF8WDW2JMzq7AmbQf-jZ8/edit?gid=0#gid=0"
sheet_id <- "https://docs.google.com/spreadsheets/d/1qLphiarm80vDPjZNx1AAWpYaU-ik8gnyk_6ok2QKX28/edit?gid=0#gid=0"

# The article coding sheet
#sheet_id <- "https://docs.google.com/spreadsheets/d/1Jc_PqvodlLBQkXpZfkf85NNbFPprCAMWRiMK6NeHNro/edit#gid=0"

# the fields need to match the google sheet column headers AND the input IDs
fields <- c("state", "county",	"community", "community_type", "water_district",
            "highway_district", "doc_name", "doc_link",
            "doc_year_written", "doc_year_adopted", "doc_year_amended", 
            "doc_type", "doc_address_water_supply", "doc_address_energy_supply",
            "doc_address_water_restrict", "doc_address_energy_restrict",
            "spatial_data_type", "spatial_name", "comments")

state_list <- c("Idaho")

county_list <- c("Ada", 
                 "Canyon", 
                 "NA")

community_list <- c("Boise",
                    "Meridian",
                    "Eagle",
                    "Kuna",
                    "Garden City",
                    "Star",
                    "Avimor",
                    "Hidden Springs",
                    "Mora",
                    "Pleasant Valley", 
                    "Sonna",
                    "Snake River Birds of Prey",
                    "Boise National Forest",
                    "National Gaurd Maneuver Area",
                    "Caldwell",
                    "Greenleaf",
                    "Melba",
                    "Middleton",
                    "Nampa", 
                    "Notus", 
                    "Parma", 
                    "Wider",
                    "Bowmont",
                    "Huston",
                    "Roswell",
                    "Sunnyslope",
                    "Walters Ferry",
                    "Deer Flat Wildlife Refuge", 
                    "NA"
                    )

community_type_list <- c("City",
                         "Planned Community",
                         "Census Designated",
                         "Unincorporated",
                         "Natural Protected Area",
                         "HOA", 
                         "NA")

water_district_list <- c("NA")


yes_no_list <- c("Yes",
                "No", 
                "Unsure")

spatial_type_list <- c("raster",
                       "vector",
                       "tabular",
                       "NA")



# Define function to use in server logic
table <- "entries"

saveData <- function(data) {
  # The data must be a dataframe rather than a named vector
  #data <- data %>% as.list() %>% data.frame() 
  # Add the data as a new row
  sheet_append(sheet_id, data)
}

loadData <- function() {
  # Read the data
  read_sheet(sheet_id)
}


# Define UI for app that can append to a google sheet  from input options
shinyApp(
  ui <- fluidPage(
    dataTableOutput("entries", width = 300), tags$hr(),
    titlePanel("Treasure Valley Site Policy Data Entry"),
    selectInput("state", "State", 
                choices = state_list, 
                selected = ""),
    selectInput("county", "County", 
                choices = county_list, 
                selected = ""),
    selectInput("community", "Community", 
                choices = community_list, 
                selected = ""),
    selectInput("community_type", "Community Type", 
                choices = community_type_list, 
                selected = ""),
    textInput("water_district", "Water District", value = "NA"),
    textInput("highway_district", "Highway District", value = "NA"),
    textInput("doc_name", "Document Name", value = ""),
    textInput("doc_link", "Document URL", value = ""),
    numericInput("doc_year_written", "Year Doc Written", value = 1999),
    numericInput("doc_year_adopted", "Year Doc Adopted", value = 1999),
    numericInput("doc_year_amended", "Year Doc Last Amended", value = 1999),
    textInput("doc_type", "Document Type", value = ""),
    selectInput("doc_address_water_supply", "Addresses Water Supply?", 
                choices = yes_no_list,
                selected = ""),
    selectInput("doc_address_energy_supply", "Addresses Energy Supply?", 
                choices = yes_no_list,
                selected = ""),
    selectInput("doc_address_water_restrict", "Addresses Water Restriction?", 
                choices = yes_no_list,
                selected = ""),
    selectInput("doc_address_energy_restrict", "Addresses Energy Restriction?", 
                choices = yes_no_list,
                selected = ""),
    selectInput("spatial_data_type", "Spatial Data Type",
                choices = spatial_type_list, 
                selected = ""),
    textInput("spatial_name", "Spatial Data Name", value = "NA"),
    textInput("comments", "Comments", value = "no comments"),
    actionButton("submit", "Submit"),
  ),
  
  # Define server logic ----
  server <- function(input, output, session) {
    
    # Whenever a field is filled, aggregate all form data
    formData <- eventReactive(input$submit, {
      data <- sapply(fields, function(x) input[[x]])
      data <- data %>% as.list() %>% data.frame() 
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })
    
    # Show the previous entries. Can take this out
    # (update with current entry when Submit is clicked)
    output$entries <- renderDataTable({
      input$submit
      loadData()
    })     
  }
)

# Run the app ----
shinyApp(ui = ui, server = server)