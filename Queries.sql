CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_name VARCHAR,
    segment VARCHAR,
    country VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    region VARCHAR
);

CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    category VARCHAR,
    sub_category VARCHAR,
    product_name TEXT
);

CREATE TABLE orders (
    order_id VARCHAR,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR,
    customer_id VARCHAR,
    product_id VARCHAR,
    sales NUMERIC,
    quantity INTEGER,
    discount NUMERIC,
    profit NUMERIC
);

---------------> Basic-Level Questions (Understanding the Data) <------------------------------------------------------------
--1. What are the total sales and total profit across all orders?
select sum(sales) as total_sales, sum(profit) as Total_profit 
from orders

--2. How many unique customers are in the dataset?
select count(distinct customer_id)
from customers

--3. List the different shipping modes used and how many orders used each.
select distinct ship_mode, count(order_id) as total from orders group by ship_mode

--4. Which product categories have the highest number of orders?
select distinct category, count(product_id) as total from products group by category limit 1

--5. What is the average discount given per category?
SELECT category, AVG(discount) AS avg_discount FROM orders join products on orders.product_id = products.product_id GROUP BY category;

--6. Which cities have the most number of orders?
select city,count(order_id) as total_orders
from orders 
join customers
on orders.customer_id = customers.customer_id
group by city 
order by total_orders desc
limit 5

--------------------> Intermediate-Level Questions (Trends and Segmentation) <-----------------------
--7. Which customer placed the highest number of orders?
select customers.customer_id,customers.customer_name, count(order_id) as total_order 
from customers 
join orders on customers.customer_id = orders.customer_id
group by customers.customer_id
order by total_order desc
limit 1

--8. What is the trend of monthly sales over time?
select distinct extract(month from order_date) as month, sum(sales) as total_sales 
from orders
group by month 
order by month 

--9. Which state has the highest total profit?
select customers.state,sum(profit) as total_profit 
from orders 
join customers on orders.customer_id = customers.customer_id 
group by customers.state 
order by total_profit 
limit 1 

--10. What are the top 5 most frequently sold products?
SELECT p.product_name, COUNT(*) AS frequency
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY frequency DESC
LIMIT 5;


--11. How many orders were shipped using 'Same Day' or 'Second Class' shipping?
SELECT ship_mode, COUNT(*) AS total_orders
FROM orders
WHERE ship_mode IN ('Same Day', 'Second Class')
GROUP BY ship_mode;


--12. Which customer segment (Consumer, Corporate, Home Office) generates the most revenue?
select segment, sum(orders.sales) as revenue 
from customers 
join orders on customers.customer_id = orders.customer_id
group by segment 
order by revenue desc 

--13. Find customers who placed more than 5 orders.
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;


--14. What is the average profit per order for each region?
select c.region, avg(o.profit) as average
from orders o
join customers c on o.customer_id = c.customer_id 
group by c.region

-------------------------------> Advanced-Level Questions (Insights and Optimization) <---------------------
--15. Identify products with negative profit.
SELECT DISTINCT p.product_name
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.profit < 0;

--16. Calculate cumulative sales per customer (running total).
SELECT customer_id, order_date, sales,
       SUM(sales) OVER (PARTITION BY customer_id ORDER BY order_date) AS cumulative_sales
FROM orders;


--17. Rank customers based on their total sales.
SELECT customer_id, SUM(sales) AS total_sales,
       RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY customer_id;

--18. Compare sales performance of California vs Florida.
SELECT c.state, SUM(o.sales) AS total_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.state IN ('California', 'Florida')
GROUP BY c.state;

--19. Show the top 3 profitable sub-categories in each category.
select category,sub_category, sum(profit) 
from products 
join orders on products.product_id = orders.product_id
group by sub_category,category
order by sum(profit) desc

--20. What is the average shipping delay (in days) per ship mode?
SELECT ship_mode,
       AVG(ship_date - order_date) AS avg_shipping_delay
FROM orders
GROUP BY ship_mode;

