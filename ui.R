shinyUI(fluidPage(
  titlePanel("Public-sector employment in Ontario"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Plot public-sector employment from Cansim table ", a("10100025.", 
                                                                     href = "https://open.canada.ca/data/dataset/b38895a5-eef9-43ad-bd3f-aa2525de8d24")),
      
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
