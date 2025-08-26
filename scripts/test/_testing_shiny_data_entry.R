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

sheet_id <- "https://docs.google.com/spreadsheets/d/1jn_TqyXtymTnzBb16T_ksquF8WDW2JMzq7AmbQf-jZ8/edit?gid=0#gid=0"

# The article coding sheet
#sheet_id <- "https://docs.google.com/spreadsheets/d/1Jc_PqvodlLBQkXpZfkf85NNbFPprCAMWRiMK6NeHNro/edit#gid=0"

# the fields need to match the google sheet column headers AND the input IDs
fields <- c("state", "county",	"city")

state_list <- c("Idaho", 
                "Oregon", 
                "Washington", 
                "Montana")

county_list <- c("Ada", 
                 "Canyon")

city_list <- c("Boise",
               "Meridian",
               "Kuna",
               "Nampa",
               "Caldwell")

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
    selectInput("city", "City", 
                choices = city_list, 
                selected = ""),
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