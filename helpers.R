employment_plot <- function(data) {
  
  p <- ggplot(data, aes(x = date, y = employment, fill = type)) + 
    geom_area(stat = "identity") + 
    labs(title = "Ontario public sector employment", x = "Year", y = "Employment", fill = "Type") + 
    scale_y_continuous(labels = comma)
  print(p)
  
}
