# AdventureWorks Retail Performance Analysis with BigQuery

This project queries key retail business metrics from the [AdventureWorks](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure) dataset using advanced SQL techniques on **Google BigQuery**.

---

## Objective

- Write reusable SQL queries that serve as building blocks for business reporting
- Transform raw transactional data into metric-focused summaries as requested by business stakeholders
- Demonstrate practical SQL techniques used in real business contexts

---

## 🛠 Tools & Techniques

- **BigQuery SQL**: CTEs, window functions (`LAG`, `RANK`, `DENSE_RANK`), date functions, aggregations, joins
- **Dataset**: `adventureworks2019` (Sales, Production, Purchasing)
- Time-based aggregation (monthly/yearly)
- Ranking and performance comparison
- Cohort logic based on first occurrence

---

## Metrics Analyzed

| Query No. | Focus Area           | Description                                                                 |
|-----------|----------------------|-----------------------------------------------------------------------------|
| 1         | Subcategory Sales     | Quantity, revenue, and orders over the last 12 months                      |
| 2         | YoY Growth            | Top 3 subcategories with highest year-over-year growth                     |
| 3         | Territory Ranking     | Top 3 territories by order volume per year                                 |
| 4         | Promotion Impact      | Total discount costs from seasonal promotions                              |
| 5         | Customer Retention    | Cohort analysis of repeat customers in 2014 (successfully shipped orders)  |
| 6         | Inventory Trends      | Monthly stock levels and MoM % changes for products in 2011               |
| 7         | Stock-to-Sales        | Monthly stock/sales ratio per product in 2011                              |
| 8         | Pending Orders        | Count and value of orders with pending status in 2014                      |

---

## How to Use

1. Open `adventureworks_business_metrics.sql` in Google BigQuery.
2. Run each query section independently or adapt to your reporting needs. The dataset is public on BigQuery.

---

**Note**: These queries are not full analyses, but serve as **modular building blocks** for BI reports or further statistical interpretation.

---

## Contact

**Trương Bảo Khang**  
Email: truongbaokhang.work@gmail.com  
University: Foreign Trade University
Major: International Economics
