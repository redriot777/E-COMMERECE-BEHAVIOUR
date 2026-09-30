# sales_analysis.R

library(dplyr)
library(lubridate)

get_sales_metrics <- function(df) {
  list(
    TotalRevenue = sum(df$Revenue, na.rm = TRUE),
    TotalOrders = n_distinct(df$OrderID),
    TotalCustomers = n_distinct(df$CustomerID),
    AverageOrderValue = sum(df$Revenue, na.rm = TRUE) / n_distinct(df$OrderID)
  )
}

get_revenue_by_category <- function(df) {
  df %>%
    group_by(Category) %>%
    summarise(Revenue = sum(Revenue, na.rm = TRUE)) %>%
    arrange(desc(Revenue))
}

get_monthly_revenue <- function(df) {
  df %>%
    mutate(Month = floor_date(OrderDate, "month")) %>%
    group_by(Month) %>%
    summarise(Revenue = sum(Revenue, na.rm = TRUE)) %>%
    arrange(Month)
}
