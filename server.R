# server.R

library(dplyr)
library(chron)
library(ggplot2)
library(scales)
source("helpers.R")

# Create data directory for downloads and unzips
if(file.exists("data")) {
  # Nothing to do
}  else {
  dir.create("data")
}
# Download Cansim table 18-30002
if(file.exists("data/01830002-eng.csv")) {
  # Nothing to do
}  else {
  download.file("http://www20.statcan.gc.ca/tables-tableaux/cansim/csv/01830002-eng.zip",
                destfile = "data/01830002-eng.zip")
  unzip("data/01830002-eng.zip", exdir = "data")
}

employment <- read.csv("data/01830002-eng.csv", na.strings = "x")
keep <- levels(employment$SEC)[c(2, 5:10, 12)] # Remove aggregates to prevent double counting

# Subset the data for Ontario, Provincial employment
ontario_provincial_employment <- employment %.%
  filter(GEO == "Ontario", SEASONAL == "Unadjusted", COM == "Employment (persons)", SEC %in% keep) %.%
  mutate(type = SEC, employment = Value), 
         date = as.Date(paste(Ref_Date, "/01", sep = "")), 
         year = years(date), month = months(date)) %.%
  filter(month == "February") %.% # Use just one month to isolate flucuations
  group_by(type, date) %.%
  summarize(employment = sum(employment))
ontario_provincial_employment <- droplevels(ontario_provincial_employment) # Clean-up the factor labels
rm(employment)


shinyServer(
  function(input, output) {
    
    datasetInput <- reactive({
      filter(ontario_provincial_employment, 
             type %in% input$employment_types)
    })
    
    output$plot <- renderPlot({
      
      employment_plot(data = datasetInput())
      
    })
    
    output$choose_employment_types <- renderUI({
      
      employment_types <- levels(ontario_provincial_employment$type)
      
      # Create the checkboxes and select them all by default
      checkboxGroupInput("employment_types", "Choose employment types", 
                         choices  = employment_types,
                         selected = employment_types[5:8])
    })
    
    output$table = renderDataTable({
      datasetInput()
    })
    
    output$downloadData <- downloadHandler(
      filename = function() { paste("employment_data", "csv", sep = ".") },
      content = function(file) {
        write.csv(datasetInput(), file)
      }
    )
  }
)
