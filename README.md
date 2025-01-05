# Iowa Liquor Sales Analysis

![pic](./pictures/cover_1.webp "pic")

This project analyzes the Iowa Liquor Sales dataset using MySQL. The dataset contains detailed records of 15,000 rows of liquor sales in Iowa from Jan 2014 to Feb 2015. The analysis aims to uncover insights regarding product sales, vendor diversity, county-specific trends, and sales patterns over time.

## Dataset Source
https://www.kaggle.com/datasets/anandaramg/liquor-sales

## Questions and SQL Approach

#### 1. How many total products are in the table?

MySQL:

```sql
SELECT count(item) AS Total_Products
FROM jan_14_to_feb_15;
```

Result:

![pic](./pictures/q1.png "pic")

#### 2. Who are the top most diverse vendors (i.e. they have the highest number of distinct products)? How many different products do they have?

MySQL:

```sql
SELECT DISTINCT vendor_no, vendor, COUNT(item) AS different_products
FROM jan_14_to_feb_15
GROUP BY 1, 2
Order BY 3 DESC
LIMIT 5;
```

Result:

![pic](./pictures/q2.png "pic")

#### 3. Which products sell the best by total number of unit sales? 

MySQL:

```sql
SELECT DISTINCT item, description, SUM(bottle_qty) AS bottles_sold_qty
FROM jan_14_to_feb_15
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;
```

Result:

![pic](./pictures/q3.png "pic")

#### 4. Which products sell the best by total dollar value of sales?

MySQL:

```sql
SELECT DISTINCT item, description, round(sum(total),0) AS total_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;
```

Result:

![pic](./pictures/q4.png "pic")

#### 5. What are the top 10 categories of liquor sold based on the total amount of sales revenue?

MySQL:

```sql
SELECT category, category_name, round(SUM(total),0) AS sales_revenue
FROM jan_14_to_feb_15
GROUP BY 1, 2
Order BY 3 DESC
LIMIT 10;
```

Result:

![pic](./pictures/q5.png "pic")

#### 6. Which rum products have sales greater than $10,000? How about whiskey or vodka products?

MySQL:

```sql
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
```

Results:

![pic](./pictures/q6_1.png "pic")

![pic](./pictures/q6_2.png "pic")

![pic](./pictures/q6_3.png "pic")

#### 7. Which county sold the most amount of vodka during February 2014?

MySQL:

```sql
SELECT county, category_name, sum(bottle_qty)
FROM jan_14_to_feb_15
WHERE lower(category_name) LIKE '%vodka%' AND year(date) = 2014 AND month(date) = 2
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1;
```

Result:

![pic](./pictures/q7.png "pic")

#### 8. Which counties were in the top 10 counties for vodka sales in any month in 2014?

MySQL:

```sql
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
```

Result:

![pic](./pictures/q8.png "pic")


Note: The top 10 counties for vodka sales in January 2014 are shown in the picture above. You can filter to find results for other months in 2014.

#### 9. Create a report that shows how many times a county appeared in the “top 10 counties for vodka sales in a month” list over the course of 2014.

MySQL:

```sql
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
```

Result:

![pic](./pictures/q9.png "pic")

#### 10. What is the trend of sales by month? Break up variables such as bottle_price into categories (for example: cheap, medium, or expensive).

MySQL:

```sql
WITH category AS (
SELECT
MONTH(date) as month, btl_price, total,
CASE
WHEN btl_price < '25' THEN 'cheap'
WHEN btl_price BETWEEN '25' AND '50' THEN 'medium'
ELSE 'expensive'
END AS bottle_price_category
FROM jan_14_to_feb_15
)

SELECT month, bottle_price_category, ROUND(SUM(total),0) AS sales_by_category
FROM category
WHERE bottle_price_category = 'cheap'
Group by month, bottle_price_category
ORDER BY 1 ASC, 3 DESC;
```

Result:

![pic](./pictures/q10.png "pic")

Note: 'cheap' category is shown in the picture above. You can filter to find results for other category.