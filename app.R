# app.R

# 1. Load required packages
library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(plotly)
library(cluster)
library(scales)

# 2. Load the R scripts from the R/ folder
source("R/data_cleaning.R")
source("R/sales_analysis.R")
source("R/customer_analysis.R")
source("R/rfm_analysis.R")
source("R/clustering.R")

# 3. Define UI
ui <- page_navbar(
  title = "🛒 E-Commerce Customer Behavior Analyzer",
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#2c3e50"),
  
  # Filters Sidebar
  sidebar = sidebar(
    title = "Filters",
    uiOutput("date_filter"),
    uiOutput("category_filter"),
    uiOutput("city_filter"),
    uiOutput("payment_filter"),
    helpText("Note: RFM and Clustering are based on the complete dataset to keep segments stable.")
  ),
  
  # TAB 1 - Overview
  nav_panel("Overview",
    layout_columns(
      fill = FALSE,
      value_box(
        title = "Total Revenue",
        value = textOutput("kpi_revenue"),
        showcase = bsicons::bs_icon("currency-dollar"),
        theme = "primary"
      ),
      value_box(
        title = "Total Orders",
        value = textOutput("kpi_orders"),
        showcase = bsicons::bs_icon("cart"),
        theme = "info"
      ),
      value_box(
        title = "Total Customers",
        value = textOutput("kpi_customers"),
        showcase = bsicons::bs_icon("people"),
        theme = "success"
      ),
      value_box(
        title = "Avg Order Value",
        value = textOutput("kpi_aov"),
        showcase = bsicons::bs_icon("receipt"),
        theme = "warning"
      )
    ),
    card(
      card_header("Monthly Revenue Chart"),
      plotlyOutput("monthly_revenue_chart")
    )
  ),
  
  # TAB 2 - Sales Analysis
  nav_panel("Sales Analysis",
    layout_columns(
      card(
        card_header("Revenue by Category"),
        plotlyOutput("category_revenue_chart")
      ),
      card(
        card_header("Sales Summary"),
        tableOutput("sales_summary_table")
      )
    )
  ),
  
  # TAB 3 - Customer Analysis
  nav_panel("Customer Analysis",
    layout_columns(
      card(
        card_header("Top 10 Customers by Spending"),
        plotlyOutput("top_customers_chart")
      ),
      card(
        card_header("Returning vs One-Time Customers"),
        plotlyOutput("customer_type_chart")
      )
    ),
    card(
      card_header("Customer Spending Distribution"),
      plotlyOutput("spending_dist_chart")
    )
  ),
  
  # TAB 4 - RFM & Segmentation
  nav_panel("RFM & Segmentation",
    layout_columns(
      card(
        card_header("Customer Segment Distribution"),
        plotlyOutput("segment_dist_chart")
      ),
      card(
        card_header("Cluster Statistics"),
        tableOutput("cluster_stats_table")
      )
    ),
    layout_columns(
      card(
        card_header("Recency vs Monetary (by Segment)"),
        plotlyOutput("rfm_scatter_chart")
      ),
      card(
        card_header("RFM Customer Table"),
        dataTableOutput("rfm_table")
      )
    )
  )
)

# 4. Define Server
server <- function(input, output, session) {
  
  # Reactive value for data loading
  rv <- reactiveValues(
    raw_data = NULL,
    clean_data = NULL,
    rfm_clustered = NULL,
    error_msg = NULL
  )
  
  # Load and clean data on startup
  observe({
    tryCatch({
      df <- clean_data("data/ecommerce_data.csv")
      rv$raw_data <- df
      rv$clean_data <- df
      
      # Run RFM and Clustering on full cleaned data
      rfm <- calculate_rfm(df)
      rv$rfm_clustered <- perform_clustering(rfm, k = 4)
      
    }, error = function(e) {
      rv$error_msg <- e$message
    })
  })
  
  # Dynamic Filters UI
  output$date_filter <- renderUI({
    req(rv$clean_data)
    min_date <- min(rv$clean_data$OrderDate, na.rm = TRUE)
    max_date <- max(rv$clean_data$OrderDate, na.rm = TRUE)
    dateRangeInput("dates", "Date Range", start = min_date, end = max_date, min = min_date, max = max_date)
  })
  
  output$category_filter <- renderUI({
    req(rv$clean_data)
    choices <- c("All", unique(rv$clean_data$Category))
    selectInput("category", "Category", choices = choices, selected = "All")
  })
  
  output$city_filter <- renderUI({
    req(rv$clean_data)
    choices <- c("All", unique(rv$clean_data$City))
    selectInput("city", "City", choices = choices, selected = "All")
  })
  
  output$payment_filter <- renderUI({
    req(rv$clean_data)
    choices <- c("All", unique(rv$clean_data$PaymentMethod))
    selectInput("payment", "Payment Method", choices = choices, selected = "All")
  })
  
  # Filtered Data
  filtered_data <- reactive({
    req(rv$clean_data)
    df <- rv$clean_data
    
    if (!is.null(input$dates)) {
      df <- df %>% filter(OrderDate >= input$dates[1] & OrderDate <= input$dates[2])
    }
    if (!is.null(input$category) && input$category != "All") {
      df <- df %>% filter(Category == input$category)
    }
    if (!is.null(input$city) && input$city != "All") {
      df <- df %>% filter(City == input$city)
    }
    if (!is.null(input$payment) && input$payment != "All") {
      df <- df %>% filter(PaymentMethod == input$payment)
    }
    
    df
  })
  
  # --- TAB 1: Overview ---
  output$kpi_revenue <- renderText({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return("$0")
    dollar(sum(filtered_data()$Revenue, na.rm = TRUE))
  })
  
  output$kpi_orders <- renderText({
    req(filtered_data())
    n_distinct(filtered_data()$OrderID)
  })
  
  output$kpi_customers <- renderText({
    req(filtered_data())
    n_distinct(filtered_data()$CustomerID)
  })
  
  output$kpi_aov <- renderText({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return("$0")
    dollar(sum(filtered_data()$Revenue, na.rm = TRUE) / n_distinct(filtered_data()$OrderID))
  })
  
  output$monthly_revenue_chart <- renderPlotly({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return(plotly::plot_ly() %>% layout(title="No data"))
    
    monthly <- get_monthly_revenue(filtered_data())
    
    p <- ggplot(monthly, aes(x = Month, y = Revenue)) +
      geom_line(color = "#2c3e50", size = 1) +
      geom_point(color = "#e74c3c", size = 3) +
      scale_y_continuous(labels = dollar) +
      theme_minimal() +
      labs(x = "Month", y = "Revenue")
    
    ggplotly(p)
  })
  
  # --- TAB 2: Sales Analysis ---
  output$category_revenue_chart <- renderPlotly({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return(plotly::plot_ly() %>% layout(title="No data"))
    
    cat_rev <- get_revenue_by_category(filtered_data())
    
    p <- ggplot(cat_rev, aes(x = reorder(Category, Revenue), y = Revenue, fill = Category)) +
      geom_col() +
      coord_flip() +
      scale_y_continuous(labels = dollar) +
      theme_minimal() +
      theme(legend.position = "none") +
      labs(x = "Category", y = "Revenue")
    
    ggplotly(p)
  })
  
  output$sales_summary_table <- renderTable({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return(data.frame(Message="No data available for the selected filters."))
    
    df <- get_revenue_by_category(filtered_data())
    df$Revenue <- dollar(df$Revenue)
    df
  })
  
  # --- TAB 3: Customer Analysis ---
  output$top_customers_chart <- renderPlotly({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return(plotly::plot_ly() %>% layout(title="No data"))
    
    cust_metrics <- get_customer_metrics(filtered_data())
    top_cust <- get_top_customers(cust_metrics, 10)
    
    p <- ggplot(top_cust, aes(x = reorder(CustomerID, TotalSpending), y = TotalSpending)) +
      geom_col(fill = "#3498db") +
      coord_flip() +
      scale_y_continuous(labels = dollar) +
      theme_minimal() +
      labs(x = "Customer ID", y = "Total Spending")
    
    ggplotly(p)
  })
  
  output$customer_type_chart <- renderPlotly({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return(plotly::plot_ly() %>% layout(title="No data"))
    
    cust_metrics <- get_customer_metrics(filtered_data())
    dist <- get_customer_type_distribution(cust_metrics)
    
    p <- ggplot(dist, aes(x = CustomerType, y = Percentage, fill = CustomerType)) +
      geom_col() +
      theme_minimal() +
      labs(x = "Customer Type", y = "Percentage (%)")
    
    ggplotly(p)
  })
  
  output$spending_dist_chart <- renderPlotly({
    req(filtered_data())
    if(nrow(filtered_data()) == 0) return(plotly::plot_ly() %>% layout(title="No data"))
    
    cust_metrics <- get_customer_metrics(filtered_data())
    
    p <- ggplot(cust_metrics, aes(x = TotalSpending)) +
      geom_histogram(fill = "#2ecc71", bins = 15, color="white") +
      scale_x_continuous(labels = dollar) +
      theme_minimal() +
      labs(x = "Total Spending", y = "Number of Customers")
    
    ggplotly(p)
  })
  
  # --- TAB 4: RFM & Segmentation ---
  output$segment_dist_chart <- renderPlotly({
    req(rv$rfm_clustered)
    
    seg_counts <- rv$rfm_clustered %>% count(Segment)
    
    p <- plot_ly(seg_counts, labels = ~Segment, values = ~n, type = 'pie',
                 textposition = 'inside', textinfo = 'label+percent') %>%
      layout(showlegend = FALSE)
    
    p
  })
  
  output$cluster_stats_table <- renderTable({
    req(rv$rfm_clustered)
    get_cluster_statistics(rv$rfm_clustered)
  })
  
  output$rfm_scatter_chart <- renderPlotly({
    req(rv$rfm_clustered)
    
    p <- ggplot(rv$rfm_clustered, aes(x = Recency, y = Monetary, color = Segment, text = CustomerID)) +
      geom_point(size = 3, alpha = 0.7) +
      scale_y_continuous(labels = dollar) +
      theme_minimal() +
      labs(x = "Recency (Days)", y = "Monetary Value ($)")
    
    ggplotly(p, tooltip = c("text", "x", "y", "color"))
  })
  
  output$rfm_table <- renderDataTable({
    req(rv$rfm_clustered)
    rv$rfm_clustered %>%
      select(CustomerID, Recency, Frequency, Monetary, RFM_Score, Segment) %>%
      arrange(desc(Monetary))
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  # Global Error Handling
  observe({
    if (!is.null(rv$error_msg)) {
      showModal(modalDialog(
        title = "Error",
        paste("An error occurred:", rv$error_msg),
        easyClose = TRUE
      ))
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
