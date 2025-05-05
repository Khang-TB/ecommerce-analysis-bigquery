# E-commerce User Behavior Query Project (BigQuery)

This project includes a set of structured SQL queries developed in **Google BigQuery** to extract behavioral and performance metrics from the `google_analytics_sample` dataset.

The queries are designed as modular building blocks to support BI reporting on session engagement, traffic source effectiveness, and conversion funnel steps.

---

## 🎯 Objective

- Develop reusable SQL queries to support e-commerce performance monitoring
- Retrieve session-level behavioral data and user actions across the conversion funnel
- Provide clean query logic for integration into dashboards or marketing analytics workflows

---

## 🛠 Tools & Techniques

- **BigQuery SQL**: CTEs, `UNNEST`, conditional logic, date formatting, aggregations  
- **Dataset**: `bigquery-public-data.google_analytics_sample`  
- **Focus Areas**:
  - Traffic attribution
  - Session engagement
  - Funnel stage breakdown (view → add to cart → purchase)

---

## 📊 Metrics Analyzed

| Query No. | Focus Area                      | Description                                                                 |
|-----------|----------------------------------|-----------------------------------------------------------------------------|
| 01        | Monthly Session Summary         | Visits, pageviews, and transactions in Jan–Mar 2017                         |
| 02        | Bounce Rate by Source           | Bounce rate per traffic source in July 2017                                |
| 03        | Revenue by Source (Time-Based)  | Revenue per source by week and by month in June 2017                       |
| 04        | Pageviews by User Type          | Avg. pageviews for purchasers vs non-purchasers in Jun–Jul 2017            |
| 05        | Transactions per Purchasing User| Avg. transactions per purchaser in July 2017                               |
| 06        | Revenue per Session             | Avg. amount spent per session (purchasers only) in July 2017               |
| 07        | Product Affinity                | Products commonly purchased with "YouTube Men's Vintage Henley"            |
| 08        | Funnel Conversion Cohort        | Monthly funnel map: product view → add to cart → purchase (Jan–Mar 2017)   |

---

## ▶️ How to Use

1. Open the file `ecommerce_user_behavior_bigquery.sql` in Google BigQuery.  
2. Run each query independently depending on the metric of interest. The dataset is publicly available via Google Cloud (`bigquery-public-data`).
3. You can adapt queries for other months, traffic segments, or KPIs as needed.

> Note: This project focused on logic and metric extraction only. This is not a full analysis.

---

## 👤 Author

**Trương Bảo Khang**  
Email: truongbaokhang.work@gmail.com  
University: Foreign Trade University  
Major: International Economics
