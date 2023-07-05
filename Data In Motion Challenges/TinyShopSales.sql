CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

-- Case Study Questions

-- 1) Which product has the highest price? Only return a single row.
SELECT *
FROM products
ORDER BY price DESC
LIMIT 1;
		
-- 2) Which customer has made the most orders?
with totOrdersCTE AS
(
	SELECT customer_id, COUNT(order_id) as TotalOrders
  	FROM orders
  	GROUP BY customer_id
)
SELECT customer_id, TotalOrders as MaxOrders
FROM totOrdersCTE
where TotalOrders = (SELECT MAX(TotalOrders) FROM totOrdersCTE);

-- 3) What’s the total revenue per product?
SELECT o.product_id, product_name, SUM(quantity*price) as TotalRevenue
FROM order_items o
JOIN products USING(product_id)
GROUP BY product_id, product_name;

-- 4) Find the day with the highest revenue.
SELECT order_date, SUM(quantity*price) as TotalRevenue
FROM products 
JOIN order_items o USING(product_id)
JOIN orders USING(order_id)
GROUP BY order_date
ORDER BY TotalRevenue DESC 
LIMIT 1;

-- 5) Find the first order (by date) for each customer.
SELECT customer_id, order_id, product_id, quantity
from (
    SELECT order_id, customer_id, product_id, quantity, order_date,
           DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS OrderNumber
    from orders
    JOIN order_items USING(order_id)
  ) temptable
where OrderNumber = 1;

SELECT  
  cus.first_name, 
  cus.last_name, 
  min(ord.order_date) first_order
FROM customers cus
JOIN orders ord ON cus.customer_id = ord.customer_id
GROUP  BY cus.first_name, cus.last_name, ord.order_date
ORDER BY first_order;


-- 6) Find the top 3 customers who have ordered the most distinct products
SELECT customer_id, COUNT( DISTINCT product_id) as UniqueProductsOrdered
from orders
JOIN order_items USING(order_id)
GROUP BY customer_id;

-- 7) Which product has been bought the least in terms of quantity?
with OrderQuantityCTE AS
(
	SELECT product_id, SUM(quantity) as QuantityOfProductsOrdered
    from order_items
    JOIN products USING(product_id)
    GROUP BY product_id
    order BY QuantityOfProductsOrdered
)
SELECT product_id, MinQuantityOfProductsOrdered
FROM OrderQuantityCTE
where QuantityOfProductsOrdered = (SELECT MIN(QuantityOfProductsOrdered) FROM OrderQuantityCTE);

-- 8) What is the median order total?
with medianCTE AS
(
    SELECT TotalOrderAmount,
          round(PERCENT_RANK() OVER (ORDER BY TotalOrderAmount),1) as percentile
    FROM
    (
          SELECT order_id, SUM(quantity*price) as TotalOrderAmount
          FROM order_items 
          JOIN products USING(product_id)
          GROUP BY order_id
    ) temptable
  
)
SELECT TotalOrderAmount
from medianCTE
where percentile = 0.5;

-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
SELECT order_id, SUM(quantity*price) as TotalAmount,
CASE
	WHEN SUM(quantity*price) > 300 then 'Expensive'
    WHEN SUM(quantity*price) > 100 THEN 'Affordable'
    ELSE 'Cheap'
END AS Category
FROM order_items 
JOIN products USING(product_id)
GROUP BY order_id;

-- 10) Find customers who have ordered the product with the highest price.
SELECT customer_id, product_name, price
from orders
join order_items USING(order_id)
JOIN products USING(product_id)
where price = (SELECT MAX(price) from products);
