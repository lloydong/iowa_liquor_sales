USE iowa_liquor_sales;

CREATE TABLE jan_14_to_feb_15 (
date text, 	
convenience_store text, 	
store int, 	
name text, 	
address	text, 
city text, 	
zipcode int, 	
store_location text, 	
county_number int,	
county text, 	
category int, 	
category_name text, 	
vendor_no int, 	
vendor text,	
item int,	
description text, 	
pack int,	
liter_size int,	
state_btl_cost double, 	
btl_price double, 		
bottle_qty int,	
total double 	
);

select *
from jan_14_to_feb_15;

LOAD DATA LOCAL INFILE 'C:/Users/lloyd/Desktop/MySQL/iowa_liquor_sales/liquor.csv' 
INTO TABLE jan_14_to_feb_15
FIELDS TERMINATED BY ','  -- If your CSV is comma-separated
ENCLOSED BY '"'          -- If your CSV has quotes around strings
LINES TERMINATED BY '\n' -- For line breaks (adjust if necessary)
IGNORE 1 LINES;  

-- 0. Examine the dataset

select *
from jan_14_to_feb_15;

-- 1. How many total products are in the table?

SELECT count(item) AS Total_Products
FROM jan_14_to_feb_15;

-- 2. Who are the top most diverse vendors (i.e. they have the highest number of distinct products)? How many different products do they have?

SELECT DISTINCT vendor_no, vendor, COUNT(item) AS different_products
FROM jan_14_to_feb_15
GROUP BY 1, 2
Order BY 3 DESC
LIMIT 5;

-- 3. Which products sell the best by total number of unit sales?

SELECT DISTINCT item, description, SUM(bottle_qty) AS bottles_sold_qty
FROM jan_14_to_feb_15
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;

-- 4. Which products sell the best by total dollar value of sales?

SELECT DISTINCT item, description, round(sum(total),0) AS total_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;

-- 5. What are the top 10 categories of liquor sold based on the total amount of sales revenue?

SELECT category, category_name, round(SUM(total),0) AS sales_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2
Order BY 3 DESC
LIMIT 10;

-- 6. Which rum products have sales greater than $10,000? How about whiskey or vodka products?

SELECT category_name, item, description, round(SUM(total),0) AS sales_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2, 3
HAVING lower(category_name) LIKE '%rum%' AND round(SUM(total),0) > 10000
ORDER BY 4 DESC;

SELECT category_name, item, description, round(SUM(total),0) AS sales_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2, 3
HAVING lower(category_name) LIKE '%whiskey%' AND round(SUM(total),0) > 10000
ORDER BY 4 DESC;

SELECT category_name, item, description, round(SUM(total),0) AS sales_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2, 3
HAVING lower(category_name) LIKE '%vodka%' AND round(SUM(total),0) > 10000
ORDER BY 4 DESC;


-- 7. Which county sold the most amount of vodka during February 2014?

SELECT county, category_name, sum(bottle_qty)
FROM jan_14_to_feb_15
WHERE lower(category_name) LIKE '%vodka%' AND year(date) = 2014 AND month(date) = 2
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1;

-- 8. Which counties were in the top 10 counties for vodka sales in any month in 2014?

WITH monthly_county_vodka_sale AS (SELECT
MONTH(date) as month, county, RANK() OVER (PARTITION BY MONTH(date) ORDER BY SUM(total) DESC) AS monthly_vodka_rank,
SUM(total) as vodka_sales
FROM jan_14_to_feb_15
WHERE lower(category_name) like '%vodka%' AND YEAR(date) = '2014'
GROUP BY month, county
ORDER BY month) 

SELECT
month, county, monthly_vodka_rank, round(vodka_sales,0) as total_revenue
FROM monthly_county_vodka_sale
WHERE monthly_vodka_rank <= 10 and month = 1
ORDER BY month;

-- Note: The top 10 counties for vodka sales in January 2014 are shown in the picture above. You can filter to find results for other months in 2014.

-- 9. Create a report that shows how many times a county appeared in the “top 10 counties for vodka sales in a month” list over the course of 2014.

WITH monthly_county_vodka_sale AS (SELECT
MONTH(date) as month, county, RANK() OVER (PARTITION BY MONTH(date) ORDER BY SUM(total) DESC) AS monthly_vodka_rank, SUM(total) as vodka_sales
FROM jan_14_to_feb_15
WHERE lower(category_name) LIKE '%vodka%' AND YEAR(date) = '2014'
GROUP BY month, county
ORDER BY month)

SELECT
county, count(county) AS monthly_top_10
FROM monthly_county_vodka_sale
WHERE monthly_vodka_rank <= 10
Group by county
ORDER BY monthly_top_10 DESC;

-- 10. What is the trend of sales by month? Break up variables such as bottle_price into categories (for example: cheap, medium, or expensive).

WITH category AS (
SELECT
MONTH(date) as month, btl_price, total,
CASE
WHEN btl_price < '25' THEN 'cheap'
WHEN btl_price BETWEEN '25' AND '50' THEN 'medium'
ELSE 'expensive'
END AS bottle_price_category
FROM jan_14_to_feb_15
-- GROUP BY 1, 2, 3
)

SELECT month, bottle_price_category, ROUND(SUM(total),0) AS sales_by_category
FROM category
WHERE bottle_price_category = 'cheap'
Group by month, bottle_price_category
ORDER BY 1 ASC, 3 DESC;

-- Note: 'cheap' category is shown in the picture above. You can filter to find results for other category.
