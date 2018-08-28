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
if(file.exists("data/10100025-eng.csv")) {
  # Nothing to do
}  else {
  download.file("https://www150.statcan.gc.ca/n1/en/tbl/csv/10100025-eng.zip?st=C42QCYlQ",
                destfile = "data/10100025-eng.zip")
  unzip("data/10100025-eng.zip", exdir = "data")
}

employment <- read.csv("data/10100025.csv", na.strings = "x")
keep <- levels(employment$Sector)[c(1:2, 5:10, 12)] # Remove aggregates to prevent double counting

# Subset the data for Ontario, Provincial employment
ontario_provincial_employment <- employment %>%
  filter(GEO == "Ontario", Seasonal.adjustment == "Unadjusted", Public.sector..components == "Employment", Sector %in% keep) %>%
  mutate(type = Sector, employment = VALUE, 
         date = as.Date(paste(REF_DATE, "-01", sep = "")), 
         year = years(date), month = months(date)) %>%
  filter(month == "February") %>% # Use just one month to isolate flucuations
  group_by(type, date) %>%
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
