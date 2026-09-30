# data_cleaning.R

library(dplyr)
library(lubridate)

clean_data <- function(file_path) {
  # Read the CSV
  if (!file.exists(file_path)) {
    stop("Dataset could not be found.")
  }
  
  df <- read.csv(file_path, stringsAsFactors = FALSE)
  
  # Remove duplicate rows
  df <- df %>% distinct()
  
  # Handle missing values by omitting rows with NA
  df <- na.omit(df)
  
  # Convert OrderDate to Date type
  df$OrderDate <- as.Date(df$OrderDate, format="%Y-%m-%d")
  
  # Remove invalid Quantity and Price values
  df <- df %>%
    filter(Quantity > 0, Price > 0)
  
  # Calculate Revenue
  df <- df %>%
    mutate(Revenue = Quantity * Price)
  
  return(df)
}
