--Sales Trend and Transactions by year
SELECT
    YEAR(sale_date) as Year,
    COUNT(*) AS Total_transactions,
    ROUND(AVG(Price_per_sqm), 2) AS Avg_price_per_sqm
FROM HDBFlat_Sales
GROUP BY YEAR(sale_date)
ORDER BY Year;

--Rank towns by price
SELECT 
    town,
    ROUND(AVG(Price_per_sqm), 2) AS Avg_price_per_sqm,
    RANK() OVER (ORDER BY AVG(Price_per_sqm) DESC) AS Price_rank
FROM HDBFlat_Sales
GROUP BY town;

--Top 5 Most Expensive Towns (per sqm)
SELECT TOP 5
    town,
    ROUND(AVG(Price_per_sqm), 2) AS avg_price_per_sqm
FROM HDBFlat_Sales 
GROUP BY town
ORDER BY avg_price_per_sqm DESC;

--Impact of Flat Age and Flat Type on Pricing
SELECT
    Flat_Age,flat_type,
    ROUND(AVG(Price_per_sqm), 2) AS avg_price_per_sqm
FROM HDBFlat_Sales
WHERE remaining_lease IS NOT NULL AND Flat_Age >= 0
GROUP BY flat_type,Flat_Age
ORDER BY Flat_Age,flat_type;

--Classify towns
WITH town_summary AS (
    SELECT
        town,
        COUNT(*) AS total_transactions,
        AVG(Price_per_sqm) AS avg_price_per_sqm
    FROM HDBFlat_Sales
    GROUP BY town
),
thresholds AS (
    SELECT
        AVG(total_transactions) AS avg_transactions,
        AVG(avg_price_per_sqm) AS avg_price
    FROM town_summary
)
SELECT
    t.town,
    t.total_transactions,
    ROUND(t.avg_price_per_sqm, 2) AS avg_price_per_sqm,
    CASE
        WHEN t.total_transactions >= th.avg_transactions
             AND t.avg_price_per_sqm < th.avg_price
            THEN 'High Demand & Affordable'

        WHEN t.total_transactions < th.avg_transactions
             AND t.avg_price_per_sqm < th.avg_price
            THEN 'Low Demand & Affordable'

        WHEN t.total_transactions >= th.avg_transactions
             AND t.avg_price_per_sqm >= th.avg_price
            THEN 'Premium Value'

        ELSE 'Low Demand & Premium'
    END AS market_cluster
FROM town_summary t
CROSS JOIN thresholds th;
