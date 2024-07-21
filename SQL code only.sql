-- UPDATING DATE (transaction_date) COLUMN TO PROPER DATE FORMAT AND RENAMING IT TO sale_date FOR EASY QUERYING
UPDATE retail_shop_sales
SET  transaction_date = STR_TO_DATE(transaction_date, '%d/%m/%Y');

ALTER TABLE retail_shop_sales
MODIFY COLUMN transaction_date DATE;

ALTER TABLE retail_shop_sales
CHANGE COLUMN trans_id sale_id INT;

ALTER TABLE retail_shop_sales
CHANGE COLUMN transaction_date sale_date INT;

ALTER TABLE retail_shop_sales
MODIFY COLUMN sale_date DATE;


--  CHECKING IF THE QUERIES ARE SUCCESFUL 
DESCRIBE retail_shop_sales;
SELECT * FROM retail_shop_sales;


-- TOTAL SALES FOR MONTH SELECTED
SELECT ROUND(SUM(total_amount)) AS total_sales
FROM retail_shop_sales
WHERE MONTH(sale_date) = 2;

-- THE DIFFERENCE OF TOTAL SALES FROM CURRENT MONTH TO PREVIOUS MONTH SHOWN AS A PERCENTAGE WITH THE USE OF LAG()
-- note that  january 2023 will return null as it has no previous month to be comapred to 
SELECT
	MONTH(sale_date) AS month,
	ROUND(SUM(total_amount)) AS total_sales,
    (SUM(total_amount) - LAG(SUM(total_amount),1)
    OVER (ORDER BY MONTH(sale_date))) / LAG(SUM(total_amount),1)
    OVER (ORDER BY MONTH(sale_date)) * 100 AS mon_to_mon_percent
FROM retail_shop_sales
WHERE MONTH(sale_date) IN (3,4)
GROUP BY MONTH(sale_date)
ORDER BY MONTH(sale_date);


-- TOTAL ORDERS FOR MONTH SELECTED
SELECT COUNT(sale_id) AS total_orders
FROM retail_shop_sales
WHERE MONTH(sale_date) = 1;


-- THE DIFFERENCE OF TOTAL ORDERS FROM CURRENT MONTH TO PREVIOUS MONTH SHOWN AS A PERCENTAGE WITH THE USE OF LAG()
SELECT
	MONTH(sale_date) AS month, 
	ROUND(COUNT(sale_id)) as total_orders, 
    (COUNT(sale_id) - lag(COUNT(sale_id),1)
    OVER (ORDER BY MONTH(sale_date))) / LAG(COUNT(sale_id),1)
    OVER (ORDER BY MONTH(sale_date)) * 100 as mon_to_mon_percent
FROM retail_shop_sales
WHERE MONTH(sale_date) IN (3,4) 
GROUP BY MONTH(sale_date)
ORDER BY MONTH(sale_date);


-- TOTAL QUANTITY FOR MONTH SELECTED
SELECT SUM(quantity) as total_quantity
FROM retail_shop_sales 
WHERE MONTH(sale_date) = 1;


-- THE DIFFERENCE OF TOTAL QUANTITY FROM CURRENT MONTH TO PREVIOUS MONTH SHOWN AS A PERCENTAGE WITH THE USE OF LAG() 
SELECT 
    MONTH(sale_date) AS month,
    ROUND(SUM(quantity)) AS total_quantity_sold,
    (SUM(quantity) - LAG(SUM(quantity), 1) 
    OVER (ORDER BY MONTH(sale_date))) / LAG(SUM(quantity), 1) 
    OVER (ORDER BY MONTH(sale_date)) * 100 AS mon_to_mon_percent
FROM 
    retail_shop_sales
WHERE 
    MONTH(sale_date) IN (3,4)   
GROUP BY 
    MONTH(sale_date)
ORDER BY 
    MONTH(sale_date);
    
    
-- TOTAL SALES, TOTAL QUANTITY SOLD and TOTAL ORDERS FOR A SPECIFIC DAY
SELECT
    SUM(total_amount) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(sale_id) AS total_orders
FROM 
    retail_shop_sales
WHERE 
    sale_date = '2023-01-23'; 
    
    
-- SALES TRENDLINE FOR MONTH SELECTED
SELECT AVG(total_sales) AS average_sales
FROM ( SELECT SUM(total_amount) AS total_sales
    FROM retail_shop_sales
	WHERE MONTH(sale_date) = 1
    GROUP BY sale_date
) AS internal_query;

-- DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(sale_date) AS day_of_month,
    ROUND(SUM(total_amount),1) AS total_sales
FROM 
    retail_shop_sales
WHERE 
    MONTH(sale_date) = 1
GROUP BY 
    DAY(sale_date)
ORDER BY 
    DAY(sale_date);
    

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > average_sales THEN 'Above Average'
        WHEN total_sales < average_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(sale_date) AS day_of_month,
        SUM(total_amount) AS total_sales,
        AVG(SUM(total_amount)) OVER () AS average_sales
    FROM 
        retail_shop_sales
    WHERE 
        MONTH(sale_date) = 1
    GROUP BY 
        DAY(sale_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    
-- SALES BY WEEKDAY / WEEKEND FOR MONTH SELECTED
SELECT 
    CASE 
        WHEN DAYOFWEEK(sale_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(total_amount),2) AS total_sales
FROM 
    retail_shop_sales
WHERE 
    MONTH(sale_date) = 1
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(sale_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;
    
-- SALES BY PRODUCT CATEGORY FOR MONTH SELECTED
SELECT 
	product_category,
	SUM(total_amount) as total_sales
FROM retail_shop_sales
WHERE
	MONTH(sale_date) = 1
GROUP BY product_category
ORDER BY total_sales DESC;

-- SALES BY AGE FOR MONTH SELECTED
SELECT 
	age,
	SUM(total_amount) as total_sales
FROM retail_shop_sales
WHERE
	MONTH(sale_date) = 1
GROUP BY age
ORDER BY total_sales DESC;

-- SALES BY GENDER FOR MONTH SELECTED
SELECT 
	gender,
	SUM(total_amount) as total_sales
FROM retail_shop_sales
WHERE
	MONTH(sale_date) = 1
GROUP BY gender
ORDER BY total_sales DESC;

-- SALES BY SPECIFIC DAY OF MONTH
SELECT 
    ROUND(SUM(total_amount)) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(*) AS total_orders
FROM 
    retail_shop_sales
WHERE 
    DAYOFWEEK(sale_date) = 1 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND MONTH(sale_date) = 1;
    
-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH SELECTED
SELECT 
    CASE 
        WHEN DAYOFWEEK(sale_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(sale_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(sale_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(sale_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(sale_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(sale_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(total_amount)) AS total_sales
FROM 
    retail_shop_sales
WHERE 
    MONTH(sale_date) = 1
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(sale_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(sale_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(sale_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(sale_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(sale_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(sale_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


























