# customer_analysis.R

library(dplyr)

get_customer_metrics <- function(df) {
  df %>%
    group_by(CustomerID) %>%
    summarise(
      NumberOfOrders = n_distinct(OrderID),
      TotalSpending = sum(Revenue, na.rm = TRUE),
      AverageOrderValue = sum(Revenue, na.rm = TRUE) / n_distinct(OrderID),
      FirstPurchaseDate = min(OrderDate, na.rm = TRUE),
      LastPurchaseDate = max(OrderDate, na.rm = TRUE)
    ) %>%
    mutate(
      CustomerType = ifelse(NumberOfOrders == 1, "One-Time", "Returning")
    )
}

get_top_customers <- function(customer_df, top_n = 10) {
  customer_df %>%
    arrange(desc(TotalSpending)) %>%
    head(top_n)
}

get_customer_type_distribution <- function(customer_df) {
  customer_df %>%
    count(CustomerType) %>%
    mutate(Percentage = n / sum(n) * 100)
}
