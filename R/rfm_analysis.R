# rfm_analysis.R

library(dplyr)

calculate_rfm <- function(df) {
  # Calculate current date as the max date in dataset + 1 day
  current_date <- max(df$OrderDate, na.rm = TRUE) + 1
  
  rfm <- df %>%
    group_by(CustomerID) %>%
    summarise(
      Recency = as.numeric(current_date - max(OrderDate, na.rm = TRUE)),
      Frequency = n_distinct(OrderID),
      Monetary = sum(Revenue, na.rm = TRUE)
    )
  
  # Quantile scoring (1-5 system)
  # For Recency: lower is better (5 is best)
  # For Frequency & Monetary: higher is better (5 is best)
  
  score_quantiles <- function(x, reverse = FALSE) {
    q <- quantile(x, probs = seq(0, 1, 0.2), na.rm = TRUE, type = 7)
    # Ensure unique breaks by adding small noise if necessary, but cut with unique helps
    breaks <- unique(q)
    if (length(breaks) < 2) {
      return(rep(3, length(x))) # default to 3 if no variance
    }
    
    scores <- as.integer(cut(x, breaks = breaks, include.lowest = TRUE, labels = FALSE))
    
    if (reverse) {
      scores <- (max(scores, na.rm=TRUE) + 1) - scores
    }
    return(scores)
  }
  
  rfm$R_Score <- score_quantiles(rfm$Recency, reverse = TRUE)
  rfm$F_Score <- score_quantiles(rfm$Frequency, reverse = FALSE)
  rfm$M_Score <- score_quantiles(rfm$Monetary, reverse = FALSE)
  
  rfm <- rfm %>%
    mutate(
      RFM_Score = paste0(R_Score, F_Score, M_Score)
    )
  
  return(rfm)
}
