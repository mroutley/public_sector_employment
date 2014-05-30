shinyUI(fluidPage(
  titlePanel("Public-sector employment in Ontario"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Plot public-sector employment from Cansim table ", a("18-30002.", 
                                                                     href = "http://www5.statcan.gc.ca/cansim/a26?lang=eng&retrLang=eng&id=1830002")),
      
      uiOutput("choose_employment_types"),
      
      downloadButton('downloadData', 'Download')
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("plot")), 
        tabPanel("Table", dataTableOutput("table"))
      )
    )
    
  )
))