# clustering.R

library(dplyr)
library(cluster)

perform_clustering <- function(rfm_df, k = 4) {
  # Select RFM columns and scale them for K-Means
  rfm_data <- rfm_df %>% select(Recency, Frequency, Monetary)
  
  # Handle cases with very few rows
  if (nrow(rfm_data) < k) {
    rfm_df$Cluster <- 1
    rfm_df$Segment <- "All Customers"
    return(rfm_df)
  }
  
  scaled_data <- scale(rfm_data)
  
  # Perform K-Means clustering
  set.seed(123)
  kmeans_res <- kmeans(scaled_data, centers = k, nstart = 25)
  
  rfm_df$Cluster <- as.factor(kmeans_res$cluster)
  
  # Calculate cluster averages to assign meaningful names
  cluster_summary <- rfm_df %>%
    group_by(Cluster) %>%
    summarise(
      Avg_R = mean(Recency),
      Avg_F = mean(Frequency),
      Avg_M = mean(Monetary)
    )
  
  # Logic to assign labels:
  # We will score each cluster based on Avg_F and Avg_M (higher is better) and Avg_R (lower is better)
  # Ranking them relative to each other
  cluster_summary <- cluster_summary %>%
    mutate(
      Rank_R = rank(Avg_R), # Lower recency gets lower rank number (good)
      Rank_F = rank(-Avg_F), # Higher frequency gets lower rank number (good)
      Rank_M = rank(-Avg_M), # Higher monetary gets lower rank number (good)
      Total_Rank = Rank_R + Rank_F + Rank_M
    ) %>%
    arrange(Total_Rank)
  
  # Assuming k=4, we assign labels based on Total_Rank
  labels <- c("High Value Customers", "Loyal Customers", "Regular Customers", "At-Risk Customers")
  
  # If k is different, just use safe fallbacks
  if (nrow(cluster_summary) == 4) {
    cluster_summary$Segment <- labels
  } else {
    cluster_summary$Segment <- paste("Segment", 1:nrow(cluster_summary))
  }
  
  # Merge labels back
  rfm_df <- rfm_df %>%
    left_join(cluster_summary %>% select(Cluster, Segment), by = "Cluster")
  
  return(rfm_df)
}

get_cluster_statistics <- function(clustered_df) {
  clustered_df %>%
    group_by(Segment) %>%
    summarise(
      Customers = n(),
      `Average Recency` = round(mean(Recency), 1),
      `Average Frequency` = round(mean(Frequency), 1),
      `Average Monetary` = round(mean(Monetary), 2)
    ) %>%
    arrange(desc(`Average Monetary`))
}
