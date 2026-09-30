# 🛒 E-Commerce Customer Behavior Analysis and Segmentation Using R

## 1. Project Title
**E-Commerce Customer Behavior Analysis and Segmentation Using R**

## 2. Project Description
This is a beginner-friendly R project that analyzes e-commerce transaction data. It provides insights into sales trends, customer behavior, and segments customers using Recency, Frequency, and Monetary (RFM) analysis combined with K-Means clustering.

## 3. Objectives
* **Sales Analysis**: Track total revenue, average order value, and monthly trends.
* **Customer Behavior Analysis**: Understand customer spending, new vs. returning customers, and top spenders.
* **RFM Analysis**: Calculate customer scores based on Recency, Frequency, and Monetary value.
* **Customer Segmentation**: Group customers into meaningful segments based on their behavior using K-Means clustering.

## 4. Technologies Used
* R
* shiny
* bslib
* dplyr
* tidyr
* lubridate
* ggplot2
* plotly
* cluster
* scales

## 5. Folder Structure
```text
ecommerce-customer-analyzer/
│
├── app.R
├── README.md
├── requirements.txt
├── .gitignore
│
├── data/
│   └── ecommerce_data.csv
│
├── R/
│   ├── data_cleaning.R
│   ├── sales_analysis.R
│   ├── customer_analysis.R
│   ├── rfm_analysis.R
│   └── clustering.R
│
├── output/
│   └── .gitkeep
│
└── screenshots/
    └── .gitkeep
```

## 6. Dataset
The project uses a small, self-contained dataset (`data/ecommerce_data.csv`) consisting of approximately 100-150 transactions. Columns include:
* CustomerID
* OrderID
* OrderDate
* ProductName
* Category
* Quantity
* Price
* PaymentMethod
* City

## 7. Installation
Run this command in your R console to install the required packages:

```r
install.packages(c(
  "shiny",
  "bslib",
  "dplyr",
  "tidyr",
  "lubridate",
  "ggplot2",
  "plotly",
  "cluster",
  "scales"
))
```

## 8. Running in VS Code
1. Open VS Code.
2. Open the `ecommerce-customer-analyzer` folder.
3. Open the VS Code terminal.
4. Navigate to the project directory if necessary.
5. Run the Shiny application using the exact Windows command:

```powershell
Rscript -e "shiny::runApp('app.R', host='127.0.0.1', port=8080)"
```
*(If `Rscript` is not in your PATH, you may need to use the full path to your R installation, e.g., `C:\Program Files\R\R-4.x.x\bin\Rscript.exe`)*

## 9. RFM Explanation
* **Recency**: How many days since the customer's last purchase.
* **Frequency**: How many orders the customer has placed.
* **Monetary**: The total amount of money the customer has spent.
* **RFM Scoring**: We assign a score from 1-5 for each metric using quantiles. For Recency, a lower number of days gets a higher score. For Frequency and Monetary, higher numbers get higher scores.

## 10. K-Means Explanation
* **What clustering means**: Grouping data points so that points in the same group are more similar to each other than to those in other groups.
* **Why K-Means is used**: It is a simple and effective algorithm to partition customers into distinct segments.
* **What Recency, Frequency and Monetary represent**: They are the features used by K-Means to find similarities among customers.
* **How customer segments are identified**: K-Means groups customers based on their RFM values. 
* **Why cluster numbers should not automatically be treated as segment names**: The algorithm just assigns random numbers (1, 2, 3, 4). We calculate the averages of each cluster to programmatically label them as "High Value", "Loyal", etc., based on their actual behavior.

## 11. Expected Output
The dashboard features a modern, beginner-friendly UI with four tabs:
1. **Overview**: KPI cards and a Monthly Revenue Chart.
2. **Sales Analysis**: Revenue by category and sales summary.
3. **Customer Analysis**: Top spenders and customer distributions.
4. **RFM & Segmentation**: Visualizations of customer segments and their statistics.

## 12. Troubleshooting
* **R not installed**: Download and install R from CRAN.
* **Packages missing**: Run the installation command in section 7.
* **`Rscript` not recognized**: Add R to your system PATH or use the full executable path.
* **CSV not found**: Make sure you open the project in the root folder (`ecommerce-customer-analyzer/`).
* **Port 8080 already in use**: Change the port number in the run command (e.g., `port=8081`).
* **No data after filters**: Expand your date range or choose "All" for categories/cities.

## 13. Future Improvements
* Use a larger real-world dataset.
* Build product recommendation systems.
* Calculate Customer Lifetime Value (CLV).
* Use more advanced clustering algorithms like DBSCAN or Hierarchical Clustering.
* Integrate a real database (e.g., PostgreSQL).
* Deploy to Shinyapps.io or a custom server.
