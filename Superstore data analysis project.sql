USE super_store;
SELECT * FROM superstore;
ALTER TABLE superstore RENAME COLUMN `Order ID` TO Orderid;
ALTER TABLE superstore RENAME COLUMN `Customer Name` TO custname;
ALTER TABLE superstore RENAME COLUMN `Product Name` TO productname;
ALTER TABLE superstore RENAME COLUMN `Sub-Category` TO subcategory;
ALTER TABLE superstore RENAME COLUMN `Order Date` TO orderdate;
-- 1. Use a CTE to find total sales per region.
WITH cte as (
SELECT region, ROUND(SUM(Sales),2) AS total
FROM superstore
GROUP BY region
)
SELECT * FROM cte;
-- Helps identify which regions generate the highest revenue so the company can focus marketing and resources on high-performing regions.

-- 2. Write a CTE to calculate average profit per category.
WITH cte as (
SELECT Category, ROUND(AVG(Profit),2) AS avg_profit
FROM superstore
GROUP BY Category
)
SELECT * FROM cte;
-- Shows which product categories are most profitable on average, helping the business prioritize profitable categories.

-- 3. Use a CTE to filter orders where sales are above overall average.
WITH cte as (
SELECT DISTINCT orderid, ROUND(SUM(sales),2) AS total
FROM superstore
GROUP BY orderid
)
SELECT * FROM cte WHERE total > (SELECT AVG(sales) FROM superstore);
-- Identifies high-value orders that perform better than the typical order, useful for analyzing premium or bulk purchases.

-- 4. Create a CTE to find top 5 customers by total sales.
WITH cte as (
SELECT custname, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY custname
ORDER BY total_sales DESC
LIMIT 5
)
SELECT * FROM cte;
-- Helps identify the most valuable customers who contribute the most revenue, enabling targeted loyalty programs or relationship management.

-- 5. Use multiple CTEs to compare region-wise sales vs overall sales.
WITH cte as (
SELECT region, ROUND(SUM(sales),2) AS total_region_sales
FROM superstore
GROUP BY region
),
overall_sales AS (
SELECT ROUND(SUM(sales),2) AS total_sales
FROM superstore
)
SELECT c.region, c.total_region_sales, o.total_sales,
ROUND((c.total_region_sales / o.total_sales),2)*100 AS per
FROM cte c
CROSS JOIN overall_sales o;
-- Shows the percentage contribution of each region to total company sales, helping management evaluate regional performance.

-- 6. Write a CTE to calculate total quantity sold per product.
WITH cte AS (
SELECT productname, SUM(quantity) AS total_quantity
FROM superstore
GROUP BY productname
)
SELECT * FROM cte;
-- Business Insight:* Helps determine which products sell the most units, useful for inventory planning and demand forecasting.

-- 7. Use a CTE to find loss-making orders (profit < 0).
WITH cte AS (
SELECT DISTINCT orderid, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY orderid
HAVING total_profit < 0
ORDER BY total_profit
)
SELECT * FROM cte;
-- Business Insight:* Identifies orders that resulted in losses so the business can analyze pricing, discounts, or shipping costs causing the loss.

-- 8. Create a CTE to rank sub-categories by total sales.
WITH cte AS (
SELECT subcategory, ROUND(SUM(sales),2) AS total_sales,
RANK() OVER 
(ORDER BY SUM(sales) DESC) AS RANK_SC
FROM superstore 
GROUP BY subcategory
)
SELECT * FROM cte;
-- Business Insight:* Highlights the best and worst performing product sub-categories based on sales, helping with product strategy decisions.

-- 9. Use a CTE to calculate monthly sales totals.
WITH cte AS (
SELECT DATE_FORMAT(STR_TO_DATE(orderdate,'%c/%e/%Y'), '%M %Y') AS yearmonth, 
MIN(STR_TO_DATE(orderdate, '%c/%e/%Y')) AS sort_date,
SUM(sales) AS total_sales, 
COUNT(*) AS total_orders
FROM superstore
GROUP BY yearmonth
)
SELECT yearmonth,
ROUND(total_sales,2) AS grand_total, total_orders
FROM cte
ORDER BY sort_date;
-- Business Insight:* Helps track monthly sales trends and identify seasonal patterns or growth/decline in sales over time.


-- 10. Write a CTE to identify customers with more than 10 orders.
WITH cte AS (
SELECT custname, COUNT(orderid) AS total_orders
FROM superstore
GROUP BY custname
)
SELECT * FROM cte WHERE total_orders > 10
ORDER BY total_orders DESC;
-- Business Insight:* Identifies loyal customers who frequently purchase, which is valuable for retention strategies and personalized marketing.

-- 11. Find all orders where the sales amount is greater than the average sales across all orders.
SELECT orderid, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY orderid
HAVING total_sales > (
SELECT AVG(sales) FROM superstore);
--  Identifies high-value orders above the typical transaction size, useful for spotting bulk or premium purchase patterns.

-- 12. List all customers who have placed at least one order in the Technology category.
SELECT DISTINCT custname
FROM superstore
WHERE custname IN (
SELECT custname
FROM superstore
WHERE Category = 'Technology'
);
-- Reveals which customers have already engaged with Technology, making them prime targets for cross-sell campaigns.


-- 13. Find the products whose sales are higher than the average sales of the Furniture category.
SELECT DISTINCT productname, sales
FROM superstore
WHERE sales > (SELECT AVG(sales) FROM superstore WHERE category = 'Furniture'
)
ORDER BY sales DESC ;
-- Surfaces strong revenue SKUs across all categories by using Furniture's average as a mid-range performance benchmark.


-- 14. Get all orders that were placed in the same city as the customer Claire Gute
SELECT orderid, custname, city
FROM superstore
WHERE custname = 'Claire Gute' AND city IN (SELECT DISTINCT city FROM superstore WHERE custname = 'Claire Gute');
--  Template for geographic clustering — swap the name to find co-located accounts for territory planning and rep assignments.

-- 15. Find all orders where the discount is greater than the average discount given across all orders.
SELECT DISTINCT orderid, discount
FROM superstore
WHERE discount > (SELECT AVG(discount) FROM superstore)
ORDER BY Discount DESC;
-- Flags the most aggressively discounted transactions for margin review and discount policy auditing.

-- 16. List customers who have never placed an order in the Consumer segment.
SELECT DISTINCT custname, Segment
FROM superstore
WHERE custname IN (SELECT DISTINCT custname FROM superstore WHERE segment <> 'Consumer');
--  Identifies non-Consumer segment customers to avoid mis-targeting them with irrelevant Consumer-oriented promotions.

-- 17 Find the top 5 states by total sales, and list all orders that belong to those states.
SELECT state, ROUND(SUM(sales),2) AS total_sales
FROM superstore
WHERE state IN (SELECT state FROM (SELECT state FROM superstore
GROUP BY state 
ORDER BY SUM(sales) DESC LIMIT 5) AS top5 )
GROUP BY state
ORDER BY total_sales DESC;
-- Reveals geographic revenue concentration and highlights the states where market share must be most aggressively defended.

-- 18. Get all products that have been ordered more than the average quantity ordered per product.
SELECT productname, SUM(Quantity) AS totalQty
FROM superstore
GROUP BY productname
HAVING SUM(Quantity) > (
SELECT AVG(product_total) 
FROM (
SELECT SUM(quantity) AS product_total
FROM superstore
GROUP BY productname ) AS avg_table );
-- High-unit-volume products are inventory planning priorities where stockouts directly and immediately hurt revenue.

-- 19. Find customers whose total profit is greater than the average profit of all customers in the West region.
SELECT custname, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY custname
HAVING SUM(profit) > 
(SELECT AVG(cust_profit) 
FROM (
SELECT SUM(profit) AS cust_profit
FROM superstore
WHERE region = 'west'
GROUP BY custname ) AS avg_table );
-- Uses the West region's profitability as a benchmark to identify top-tier customer accounts across the entire company.

-- 20. Find all orders where the profit percentage is greater than 20%.
SELECT orderid,
ROUND((profit / sales) * 100, 2) AS profit_percentage
FROM superstore
WHERE (profit / sales) * 100 > 20;
--  Highlights high-efficiency orders where pricing held firm, useful for replicating discount-free selling conditions.

-- 21. Find products where the discount amount (in rupees) is greater than ₹50.
SELECT productname, ROUND(sales*discount,2) AS disc_amt
FROM superstore
WHERE (sales*discount) > 50;
-- Flags SKUs where absolute discount spend is high even if the percentage looks modest, useful for controlling promotional budgets. 

-- 22. Find orders where the profit is negative (i.e. the company lost money).
SELECT orderid, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY orderid
HAVING total_profit <0 ;
-- Every loss-making order erodes margin; patterns here reveal where pricing, discounting, or shipping costs need tightening.

-- 23. Calculate the average sales per order and find all orders above that average.
SELECT orderid, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY orderid
HAVING total_sales >
 (SELECT AVG(sales) FROM superstore);
 
 
-- 24. Find customers whose total discount received is more than ₹100.
SELECT custname, ROUND(SUM(sales*discount),2) AS total_discount
FROM superstore
GROUP BY custname
HAVING SUM(sales*discount) > 100;
-- Customers receiving over ₹100 in discounts should be cross-checked against their lifetime profitability to justify the promotional spend.

-- 25. Find the states where total loss (negative profit) is greater than the average loss across all states.
SELECT state, ROUND(SUM(profit), 2) AS total_loss
FROM superstore
GROUP BY state
HAVING SUM(profit) < (
SELECT AVG(state_profit)
FROM (
SELECT SUM(profit) AS state_profit
FROM superstore
GROUP BY state
HAVING SUM(profit) < 0
) AS loss_states
);
-- Pinpoints structurally loss-heavy states that warrant a full review of logistics costs, pricing, or sales team strategy.


-- 26. Find products where the profit margin is below the average profit margin of their category.
SELECT p.category,p.productname, ROUND((p.profit / p.sales) * 100, 2) AS profit_margin
FROM superstore p
WHERE (p.profit / p.sales) < (
SELECT AVG(profit / sales)
FROM superstore c
WHERE c.category = p.category
);
-- Identifies underperforming SKUs within their own category peer group — the fairest basis for pricing correction or discontinuation decisions.

-- 27. Find customers where the ratio of total discount to total sales is greater than 15%.
SELECT custname, ROUND(SUM(sales*discount),2)/SUM(sales)*100 AS total_p_ration
FROM superstore
GROUP BY custname
HAVING SUM(sales*discount)/SUM(sales)*100 >15;
-- A discount-to-sales ratio above 15% flags margin-dilutive accounts worth renegotiating terms with or deprioritizing.
-- 

-- 28. Each region's % share of total company sales
WITH region_sales AS (
  SELECT Region, ROUND(SUM(Sales),2) AS reg_total
  FROM superstore GROUP BY Region
),
grand AS (SELECT ROUND(SUM(Sales),2) AS grand_total FROM superstore)
SELECT r.Region, r.reg_total, g.grand_total,
  ROUND(r.reg_total / g.grand_total * 100, 2) AS pct_share
FROM region_sales r CROSS JOIN grand g
ORDER BY pct_share DESC;
-- Business Insight:* The 4 regions are Central, East, South, West. This tells you which contributes most — West typically dominates Superstore data.

-- 29. Count of profitable vs loss-making orders
SELECT
CASE WHEN profit >=0 THEN 'profitable' ELSE 'Loss' END AS status,
COUNT(DISTINCT `orderid`) AS orders,
ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY status;
-- BI* Quick health check: what fraction of all orders actually make money? A high loss-order count signals a discounting or pricing problem.

-- 30. Customers whose total profit exceeds the overall customer average.
SELECT Custname, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY custname
HAVING SUM(Profit) > (
SELECT AVG(cust_profit) FROM (
SELECT SUM(Profit) AS cust_profit
FROM superstore
GROUP BY custname
) AS t
)
ORDER BY total_profit DESC;
-- BI -- Two-level subquery: inner query computes per-customer profit, outer AVG averages those totals. Customers above this threshold are your most valuable accounts.

-- 31. Profit statistics per region — avg, stddev, total
SELECT region,
ROUND(SUM(profit),2) AS total_profit,
ROUND(AVG(profit),2) AS avg_profit,
ROUND(STDDEV(profit),2) AS stddev_profit,
ROUND(MIN(profit),2) AS worst_oder,
ROUND(MAX(profit),2) AS best_oder
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;
-- BI -High STDDEV means profit is unpredictable — some orders are very good, others catastrophic. Low average with high STDDEV signals a pricing consistency problem.

-- 32. Customer first order, last order, and tenure in days
SELECT custname,
MIN(STR_TO_DATE(orderdate, '%m/%d/%Y')) AS first_order,
MAX(STR_TO_DATE(orderdate, '%m/%d/%Y')) AS last_order,
DATEDIFF(
MAX(STR_TO_DATE(orderdate, '%m/%d/%Y')),
MIN(STR_TO_DATE(orderdate, '%m/%d/%Y'))
) AS tenure_days,
COUNT(DISTINCT orderdate) AS total_orders
FROM superstore
GROUP BY custname
ORDER BY tenure_days DESC
LIMIT 20; 
-- BI- Tenure + order count together define customer loyalty. Long tenure with few orders = dormant customers worth a win-back campaign.

-- 33. Customers who ordered Technology but never ordered Furniture
SELECT DISTINCT custname
FROM superstore
WHERE Category = 'technology'
AND custname NOT IN (
SELECT DISTINCT 'custname'
FROM superstore
WHERE Category = 'furniture'
)
ORDER BY custname;
-- BI - Cross-category purchasing patterns reveal upsell opportunities. Customers who buy Technology but not Furniture are prime targets for furniture promotions.

-- 34. RFM-style customer segmentation (Recency, Frequency, Value)
WITH rfm AS (
SELECT custname,
DATEDIFF('2018-12-31', MAX(STR_TO_DATE(orderdate, '%m/%d/%Y'))) AS recency_days,
COUNT(DISTINCT 'orderid') AS frequency,
ROUND(SUM(sales),2) AS monetary
FROM superstore
GROUP BY custname
)
SELECT custname, recency_days, frequency, monetary,
NTILE(3) OVER (ORDER BY recency_days ASC) AS r_score,
NTILE(3) OVER (ORDER BY frequency ASC) AS f_score,
NTILE(3) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm
ORDER BY m_score DESC,f_score DESC,r_score ASC;
-- BI - RFM (Recency, Frequency, Monetary) is the gold-standard customer segmentation model. NTILE(3) splits into 3 tiers. Score 3,3,3 = Champions; 1,1,1 = At-risk.

-- 35. Total quantity sold per sub-category
SELECT subcategory,
SUM(Quantity) AS total_qty,
COUNT(DISTINCT productname) AS unique_products,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY subcategory
ORDER BY total_qty DESC;
-- -- BI: Reveals volume leaders vs revenue leaders — a sub-category can be high-volume but low-value (Fasteners) or low-volume but high-value (Copiers), essential for balancing inventory investment.

-- 36. Best and worst selling product per region
WITH prod_region AS (
SELECT region, productname,
ROUND(SUM(sales),2) AS total_sales,
ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS top_rn,
ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) ASC) AS bot_rn
FROM superstore
GROUP BY region, productname
)
SELECT region,
MAX(CASE WHEN top_rn=1 THEN productname END) AS best_product,
MAX(CASE WHEN bot_rn=1 THEN productname END) AS wrost_product
FROM prod_region
GROUP BY region;
-- -- BI: Surfaces regional product preferences and dead-weight inventory — the worst product per region is a candidate for delisting or targeted clearance promotions.

-- 38. Which segment leads in each region?
WITH seg_region AS (
SELECT region, segment,
ROUND(SUM(sales),2) AS total_sales,
RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rnk
FROM superstore
GROUP BY region,Segment
)
SELECT region,segment,total_sales,rnk
FROM seg_region
ORDER BY region,rnk;
-- BI*- PARTITION BY Region gives an independent ranking for each of the 4 regions. rnk=1 per region reveals which segment dominates in each geography.

-- 39. Sales, profit, and order size by customer segment.
SELECT segment,
COUNT(DISTINCT orderid) AS orders,
COUNT(DISTINCT custname) AS customers,
ROUND(SUM(sales),2) AS total_sales,
ROUND(AVG(sales),2) AS Avg_sales,
ROUND(SUM(profit),2) AS total_profit,
ROUND(SUM(profit)/NULLIF(SUM(sales),0)*100,2) AS margin_pct
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;
-- BI* - Consumer is the largest segment by volume; Corporate typically has the highest average order value. Home Office is the most profitable per order.

-- 40. Orders where discount exceeds their sub-category's average discount
WITH subcat_avg AS (
    SELECT 
        subcategory,
        ROUND(AVG(discount), 4) AS subcat_avg_disc
    FROM superstore
    GROUP BY subcategory
)
SELECT 
    s.orderid,
    s.subcategory,
    s.discount,
    ROUND(s.profit, 2) AS profit,
    a.subcat_avg_disc
FROM superstore s
JOIN subcat_avg a 
    ON s.subcategory = a.subcategory
WHERE s.discount > a.subcat_avg_disc
ORDER BY s.discount DESC
LIMIT 30;
-- BI* - Finds the most aggressively discounted orders relative to their peers. These are candidates for pricing policy review — especially where profit is also negative.

-- 41. Profit by discount band — is discounting destroying margin?
SELECT
CASE
WHEN discount = 0 THEN '0% (No discount)'
WHEN discount <= 0.1 THEN '1-10%'
WHEN discount <= 0.2 THEN '11-20%'
WHEN discount <= 0.4 THEN '21-40%'
ELSE 'Over 40%'
END AS discount_band,
COUNT(*) AS orders,
ROUND(AVG(profit),2) AS avg_profit,
ROUND(SUM(profit),2) AS total_profit,
ROUND(AVG(sales),2) AS avg_sales
FROM superstore
GROUP BY discount_band
ORDER BY MIN(discount);
-- BI* - This is one of the most revealing queries in the dataset. Orders with 0% discount are almost always profitable; once discount exceeds 20%, average profit often turns negative.

-- 42. Average discount rate per category and its profit impact
SELECT Category,
  ROUND(AVG(Discount)*100,1) AS avg_discount_pct,
  ROUND(SUM(Sales),2) AS total_sales,
  ROUND(SUM(Profit),2) AS total_profit,
  ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100,2) AS margin_pct
FROM superstore
GROUP BY Category ORDER BY avg_discount_pct DESC;
-- BI* Higher average discount almost always correlates with lower margin. Furniture typically has the worst discount-to-margin ratio in this dataset.

-- 43. Region × Segment sales matrix (pivot table)
SELECT Region,
  ROUND(SUM(CASE WHEN Segment='Consumer'    THEN Sales ELSE 0 END),2) AS Consumer,
  ROUND(SUM(CASE WHEN Segment='Corporate'   THEN Sales ELSE 0 END),2) AS Corporate,
  ROUND(SUM(CASE WHEN Segment='Home Office' THEN Sales ELSE 0 END),2) AS Home_Office,
  ROUND(SUM(Sales),2) AS Grand_Total
FROM superstore
GROUP BY Region ORDER BY Grand_Total DESC;
-- BI* A classic cross-tab / pivot. Shows how each customer segment performs within each region. Useful for tailoring regional marketing by segment type.

-- 44. Top 5 states by sales and all their orders
WITH top_states AS (
    SELECT State
    FROM superstore
    GROUP BY State
    ORDER BY SUM(Sales) DESC
    LIMIT 5
)
SELECT 
s.State,
ROUND(SUM(s.Sales), 2) AS total_sales,
COUNT(DISTINCT s.orderid) AS orders,
ROUND(SUM(s.Profit), 2) AS total_profit
FROM superstore s
JOIN top_states t 
ON s.State = t.State
GROUP BY s.State
ORDER BY total_sales DESC;
-- BI* - first identifies the top-5 states, then the outer query pulls full metrics for them — cleaner than a JOIN for this use case.

-- 45. Sales and profit by state — all 49 states
SELECT State,
  COUNT(DISTINCT orderid) AS orders,
  ROUND(SUM(Sales),2) AS total_sales,
  ROUND(SUM(Profit),2) AS total_profit,
  ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100,2) AS margin_pct
FROM superstore
GROUP BY State
ORDER BY total_sales DESC;

-- 46.Loyal customers with more than 10 orders
SELECT custname,
  COUNT(DISTINCT orderid) AS order_count,
  ROUND(SUM(Sales),2) AS lifetime_sales
FROM superstore
GROUP BY custname
HAVING order_count > 10
ORDER BY order_count DESC;
-- BI - High order-count customers are your loyalty programme candidates. Superstore typically has ~10–15 such customers.

-- 48. Products sold in multiple categories (data quality check)
SELECT productname,
  COUNT(DISTINCT Category) AS category_count,
  GROUP_CONCAT(DISTINCT Category ORDER BY Category SEPARATOR ' / ') AS categories
FROM superstore
GROUP BY productname
HAVING category_count > 1
ORDER BY productname;

-- 49. Rank customers within each segment by sales
WITH cust AS (
  SELECT custname, Segment,
    ROUND(SUM(Sales),2) AS total_sales
  FROM superstore
  GROUP BY custname, Segment
)
SELECT custname, Segment, total_sales,
  RANK() OVER (PARTITION BY Segment ORDER BY total_sales DESC) AS seg_rank
FROM cust
ORDER BY Segment, seg_rank
LIMIT 30;
-- BI* -- Ranks customers within Consumer, Corporate, and Home Office separately. The #1 Corporate customer may have lower sales than the #1 Consumer — this makes comparison fair.

-- 50. Monthly sales with month-over-month growth
WITH monthly AS (
  SELECT DATE_FORMAT(STR_TO_DATE(orderdate,'%m/%d/%Y'),'%Y-%m') AS ym,
    ROUND(SUM(Sales),2) AS total_sales
  FROM superstore GROUP BY ym
)
SELECT ym, total_sales,
  LAG(total_sales) OVER (ORDER BY ym) AS prev_month,
  ROUND(total_sales - LAG(total_sales) OVER (ORDER BY ym),2) AS mom_diff,
  ROUND((total_sales - LAG(total_sales) OVER (ORDER BY ym))
        / LAG(total_sales) OVER (ORDER BY ym) * 100, 2) AS mom_pct
FROM monthly ORDER BY ym;
-- BI* LAG fetches the previous month's value. Dividing the difference gives MoM growth % — the most common KPI in sales dashboards.

-- 51. Profit subtotals with ROLLUP — category, sub-category, grand total
SELECT
  COALESCE(Category,'── TOTAL') AS Category,
  COALESCE(subcategory,'Subtotal') AS SubCategory,
  ROUND(SUM(Sales),2) AS total_sales,
  ROUND(SUM(Profit),2) AS total_profit,
  ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100,2) AS margin_pct
FROM superstore
GROUP BY Category, subcategory WITH ROLLUP
ORDER BY Category, SubCategory;
-- WITH ROLLUP auto-generates subtotal rows. COALESCE labels the NULL placeholders. This is the SQL equivalent of Excel's subtotal feature — in one query.



