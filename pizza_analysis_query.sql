CREATE DATABASE pizza_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE pizza_db;
SHOW TABLES;
-- --------------------DATA CLEANING-------------------------
DESCRIBE order_details;
ALTER TABLE order_details ADD PRIMARY KEY(order_details_id);

DESCRIBE orders;
ALTER TABLE orders ADD PRIMARY KEY(order_id);

ALTER TABLE order_details
ADD CONSTRAINT fk_orders FOREIGN KEY(order_id) REFERENCES orders(order_id);

DESCRIBE pizzas;
ALTER TABLE pizzas 
MODIFY COLUMN pizza_id VARCHAR(100);
ALTER TABLE pizzas ADD PRIMARY KEY(pizza_id);
ALTER TABLE pizzas 
MODIFY COLUMN pizza_type_id VARCHAR(100);

DESCRIBE pizza_types;
ALTER TABLE pizza_types 
MODIFY COLUMN pizza_type_id VARCHAR(100);
ALTER TABLE pizza_types ADD PRIMARY KEY(pizza_type_id);

-- --------------------- EXPLORATORY ANALYSIS ----------------------------------
-- KPIs
-- 1) Total Revenue (How much money did we make this year?)
SELECT round(sum(price),2)TotalRevenue 
FROM pizzas
INNER JOIN order_details
USING(pizza_id);

-- 2) Average Order Value
SELECT round(sum(quantity*price)/count(DISTINCT(order_id)),2)`Average Order Value`
FROM order_details INNER JOIN
pizzas USING(pizza_id);

-- 3) Total Pizzas Sold
SELECT sum(quantity)`Total Pizzas Sold` FROM order_details;

-- 4) Total Orders
SELECT count(order_id)`Total Orders` FROM orders;

-- 5) Average Pizzas per Order
SELECT round(sum(quantity)/count(DISTINCT order_id))`Average Pizza per Order` 
FROM order_details;

-- Sales analysis

-- 1) Daily Trends for Total Orders
SELECT DAYNAME(date)`Day of the Week`,
count(order_id)`Total Orders` 
FROM orders
GROUP BY DAYNAME(date)
ORDER BY `Total Orders` DESC;

-- 2) Hourly TrendS for Total Orders
SELECT HOUR(time)`Hours`,
count(order_id)`Total Orders` 
FROM orders
GROUP BY `Hours`
ORDER BY `Hours`;

-- 3) Percentage of Sales by Pizza Category
SELECT category,
round(sum(price*quantity),2)revenue,
round(sum(price*quantity)*100/(SELECT sum(price*quantity) FROM pizzas INNER JOIN order_details 
USING(pizza_id)),2)percentage_sales
FROM pizza_types INNER JOIN pizzas
USING(pizza_type_id)
INNER JOIN order_details
USING(pizza_id)
GROUP BY category
ORDER BY percentage_sales DESC;

-- 4) Percentage of Sales by Pizza Size
SELECT size, 
round(sum(price*quantity))revenue,
round(sum(price*quantity)*100/(
SELECT sum(price*quantity) FROM pizzas INNER JOIN order_details
using(pizza_id)
),2)percentage_sales
FROM pizza_types 
INNER JOIN pizzas
USING(pizza_type_id)
INNER JOIN order_details
USING(pizza_id)
GROUP BY size
ORDER BY percentage_sales DESC;

-- 5) Total Pizzas Sold by Pizza Category
SELECT category,
sum(quantity)quantity_sold
FROM pizza_types INNER JOIN pizzas
USING(pizza_type_id)
INNER JOIN order_details
USING(pizza_id)
GROUP BY category
ORDER BY quantity_sold DESC;

-- 6) Top 5 Best Sellers by Total Pizzas Sold
SELECT name, 
sum(quantity)quantity_sold
FROM pizza_types INNER JOIN pizzas
USING(pizza_type_id)
INNER JOIN order_details
USING(pizza_id)
GROUP BY name
ORDER BY quantity_sold DESC
LIMIT 5;

-- 7) Bottom 5 Best Sellers by Total Pizzas Sold
SELECT name, 
sum(quantity)quantity_sold
FROM pizza_types INNER JOIN pizzas
USING(pizza_type_id)
INNER JOIN order_details
USING(pizza_id)
GROUP BY name
ORDER BY quantity_sold
LIMIT 5;


-- QUESTIONS
-- 1) The busiest days are Thursday (3239 orders), Friday (3538 orders) and Saturday (3158 orders). Most sales are recorded on Friday
-- 2) Most orders are placed between 12pm to 1pm, and 5pm to 7pm
-- 3) Classic pizza has the highest percentage sales (26.91%), followed by Supreme (25.46%), Chicken (23.96%) and Veggie (23.68%) pizzas 
-- 4) Large size pizzas record the highest sales (45.89%) followed by medium (30.49%), then small (21.77%). XL and XXL only account for 1.72% and 0.12% respectively 
-- 5) Classic Pizza accounts for the highest sales (14,888 pizzas) followed by Supreme (11,987 pizzas), Veggie (11,649 pizzas) and Chicken (11,050 pizzas)
-- 6) Top 5 Best Sellers are the Classic Deluxe (2453 pizzas), Barbecue Chicken (2432 pizzas), Hawaiian (2422), Peperoni (2418 pizzas) and Thai Chicken (2371 pizzas)
-- 7) Bottom 5 Worst Sellers are Brie Carre (490 pizzas), Mediterranean (934 pizzas), Calabrese (937 pizzas), Spinach Supreme (950 pizzas) and Soppressata (961).

/*
CONCLUSION:
The outlet should capitalize on Large size Classic, Supreme, Veggie and Chicken pizzas.

Since XL and XXL pizzas account for such a small percentage of their sales (just 1.94%), they can safely get rid of these pizza sizes.

Even though the Brie Carre pizza is the worst seller, it recorded 490 pizzas sold. It would still be a good idea to keep it in the menu. 
*/