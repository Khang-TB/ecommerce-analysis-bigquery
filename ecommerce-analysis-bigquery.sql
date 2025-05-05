-- Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
  SUM(totals.visits) AS total_visit,
  SUM(totals.pageviews) AS page_view,
  SUM(totals.transactions) AS transaction
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))
ORDER BY month ASC;

-- Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
SELECT 
  trafficSource.source,
  SUM(CASE WHEN totals.bounces = 1 THEN 1 ELSE 0 END) AS num_bounce,
  SUM(CASE WHEN totals.visits = 1 THEN 1 ELSE 0 END) AS total_visit,
  CONCAT(
    ROUND(SUM(CASE WHEN totals.bounces = 1 THEN 1 ELSE 0 END) /
      SUM(CASE WHEN totals.visits = 1 THEN 1 ELSE 0 END)*100,2), '%') AS Bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visit DESC;

-- Query 03: Revenue by traffic source by week, by month in June 2017
WITH exploding AS(
  SELECT
    'Month' AS time_type,
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time,
    trafficSource.`source`,
    product.productRevenue AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
  UNNEST(hits) hits,
  UNNEST(hits.product) product
  UNION ALL
  SELECT
    'Week' AS time_type,
    FORMAT_DATE('%Y%W', PARSE_DATE('%Y%m%d', date)) AS time,
    trafficSource.`source`,
    product.productRevenue AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
  UNNEST(hits) hits,
  UNNEST(hits.product) product
)
SELECT
  time_type,
  time,
  source,
  CONCAT(ROUND(SUM(revenue)/1000000,4),' M') AS revenue
FROM exploding
WHERE revenue IS NOT NULL
GROUP BY time_type, time, source
ORDER BY SOURCE, time_type,time ASC;

-- Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
WITH purchasers AS(
  SELECT DISTINCT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    fullVisitorId AS purchaser
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) hits,
  UNNEST(hits.product) product
  WHERE _TABLE_SUFFIX BETWEEN '0601' AND '0731'
    AND product.productRevenue IS NOT NULL
    AND totals.transactions >= 1
),
non_purchasers AS(
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    fullVisitorId AS non_purchaser
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) hits,
  UNNEST(hits.product) product
  WHERE _TABLE_SUFFIX BETWEEN '0601' AND '0731'
    AND product.productRevenue IS NULL
    AND totals.transactions IS NULL
),
purchaser_avg AS(
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId), 2) AS avg_purchaser
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  INNER JOIN purchasers 
    ON fullVisitorId = purchaser AND FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) = purchasers.month
  WHERE _TABLE_SUFFIX BETWEEN '0601' AND '0731'
  GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))
),
non_purchaser_avg AS(
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    ROUND(SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId), 2) AS avg_non_purchaser
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  INNER JOIN non_purchasers 
    ON fullVisitorId = non_purchaser AND FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) = non_purchasers.month
  WHERE _TABLE_SUFFIX BETWEEN '0601' AND '0731'
  GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))
)
SELECT
  month,
  purchaser_avg.avg_purchaser,
  non_purchaser_avg.avg_non_purchaser
FROM purchaser_avg
FULL JOIN non_purchaser_avg USING(month);

-- Query 05: Average number of transactions per user that made a purchase in July 2017
WITH purchaser AS(
  SELECT
    fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  UNNEST(hits) hits,
  UNNEST(hits.product) product
  WHERE totals.transactions >= 1 AND product.productRevenue IS NOT NULL
)
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
  ROUND(SUM(totals.transactions)/COUNT(DISTINCT fullVisitorId), 2) AS Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) hits,
UNNEST(hits.product) product
WHERE product.productRevenue IS NOT NULL
  AND fullVisitorId IN(SELECT fullVisitorId FROM purchaser)
GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date));

-- Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
  CONCAT(ROUND(SUM(product.productRevenue)/COUNT(visitId)/1000000,2), ' M') AS avg_money_spent_per_session
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) hits,
UNNEST(hits.product) product
WHERE totals.transactions IS NOT NULL AND product.productRevenue IS NOT NULL
GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date));

-- Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
WITH customer_who_purchased AS(
  SELECT DISTINCT fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  UNNEST(hits) hits,
  UNNEST(hits.product) product
  WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
  AND product.productRevenue IS NOT NULL
  AND totals.transactions   >= 1
)
SELECT
  product.v2ProductName AS name,
  SUM(productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) hits,
UNNEST(hits.product) product
WHERE productQuantity IS NOT NULL 
  AND fullVisitorId IN(SELECT fullVisitorId FROM customer_who_purchased)
  AND product.productRevenue IS NOT NULL
  AND totals.transactions >= 1
  AND product.v2ProductName <> "YouTube Men's Vintage Henley"
GROUP BY product.v2ProductName
ORDER BY quantity DESC;

-- Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017.
WITH product_view AS(
  SELECT 
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    COUNT(hits.eCommerceAction.action_type) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) hits
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND hits.eCommerceAction.action_type ='2'
  GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))
),
add_to_cart AS(
  SELECT 
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    COUNT(hits.eCommerceAction.action_type) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) hits
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND hits.eCommerceAction.action_type ='3'
  GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))
),
purchase AS(
  SELECT 
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date)) AS month,
    COUNT(hits.eCommerceAction.action_type) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) hits
  WHERE _TABLE_SUFFIX BETWEEN '0101' AND '0331'
    AND hits.eCommerceAction.action_type ='6'
  GROUP BY FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))
)
SELECT
  pv.month,
  num_product_view,
  num_addtocart,
  num_purchase,
  CONCAT(ROUND((num_addtocart/num_product_view)*100, 2), '%') AS add_to_cart_rate,
  CONCAT(ROUND((num_purchase/num_addtocart)*100, 2), '%') AS purchase_rate,
FROM product_view pv
FULL JOIN add_to_cart USING(month)
FULL JOIN purchase USING(month)
ORDER BY pv.month ASC;
