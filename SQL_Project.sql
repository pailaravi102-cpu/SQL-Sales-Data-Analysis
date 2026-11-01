create database Retail_Sales;
use Retail_Sales;
create table customers(
Customer_ID int primary key,
Customer_Name varchar(100),
City varchar(50),
Join_Date date);

insert into customers(Customer_id,Customer_Name,City,Join_Date)
values(101,'Amit Sharma','Delhi','2022-01-10'),
(102,'Neha Verma','Mumbai','2022-03-15'),
(103,'Rahul Mehta','Bangalore','2022-05-01'),
(104,'Priya Singh','Delhi','2023-01-12'),
(105,'Karan Patel','Ahmedabad','2023-02-20'),
(106,'Sneha Reddy','Hyderabad','2023-03-18'),
(107,'Arjun Nair','Kochi','2023-04-10'),
(108,'Pooja Gupta','Jaipur','2023-05-05');

select * from customers;

create table products(
product_id int primary key,
product_name varchar(100),
category char(100),
price int);

insert into products(product_id,product_name,category,price)
values(201,'Laptop','Electronics','55000'),
(202,'Mobile','Electronics','25000'),
(203,'Tablet','Electronics','18000'),
(204,'Headphones','Accessories','2000'),
(205,'Keyboard','Accessories','1500'),
(206,'Mouse','Accessories','800'),
(207,'Monitor','Electronics','12000'),
(208,'Printer','Electronics','9000');

create table orders(
Order_ID int,
Customer_ID int ,
OrderDate date,
Employee_ID int);

insert into orders(Order_ID ,Customer_ID,OrderDate ,Employee_ID)
values(301,101,'2023-01-15',401),
(302,102,'2023-01-18',402),
(303,103,'2023-02-05',401),
(304,104,'2023-02-10',403),
(305,105,'2023-03-01',404),
(306,106,'2023-03-15',402),
(307,107,'2023-04-01',401),
(308,108,'2023-04-20',403);

create table order_details(
order_Detail_ID INT,
Order_ID INT,
Prodct_ID INT,
Quntity int);

insert into order_details(order_detail_id,order_id,prodct_id,quntity)
values(1,301,201,1),
(2,301,204,2),
(3,302,202,1),
(4,303,203,1),
(5,304,207,2),
(6,305,205,3),
(7,306,206,5),
(8,307,208,1),
(9,308,201,1);

create table Employee(
Employee_id int,
Employee_name varchar(100),
Department varchar(100),
Hire_date date);

insert into employee(Employee_id,employee_name,Department,hire_date)
values(401,'Rajesh Kumar','Sales','2020-02-01'),
(402,'Meena Iyer','Sales','2021-06-15'),
(403,'Vikram Shah','Sales','2022-09-10'),
(404,'Anil Gupta','Sales','2023-01-05');

### 1.	Display all orders with customer names ###

select orders.order_id,customers.customer_name,orders.orderdate,orders.employee_id
from orders
join customers
on orders.customer_id = customers.customer_id;


### Show product names and quantities for each order ###
select products.product_name,ord.quntity
from order_details as ord
join products
on ord.prodct_id = products.product_id;

###  3.	Display employee name who handled each order  ###

select emp.employee_name,ord.order_id
from orders as ord
join employee as emp
on ord.employee_id = emp.employee_id;

###  4.	Show all customers and their orders (including customers without orders) ###
select cus.customer_name,ord.order_id
from customers as cus
left join orders as ord
on cus.customer_id = ord.customer_id;

###  5.	Display total number of orders handled by each employee ###

select emp.employee_name,count(ord.order_id) as total_orders
from employee as emp
left join orders as ord
on emp.employee_id = ord.employee_id
group by emp.employee_name;

####  Subqueries ####

###  Find customers who placed more than 1 order  ###
select customer_name
from customers
where customer_id in(
	select customer_id from orders
	group by customer_id
	having count(*)>1);
    
  ###  Display products with price higher than the average product price  ### 
  select product_name ,price from products
  where price > (select avg(price) from products);
  
###	Find the customer who placed the highest number of orders  ###  
  
  select customer_name from customers
  where customer_id =(select customer_id from orders
					group by customer_id
                    order by count(*)desc
                    limit 1 );
                    
  ###  Show orders where total quantity is greater than the average quantity  ### 
  select order_detail_id,quntity from order_details
  where quntity > (select avg(quntity) from order_details);
  
 ###  Find employees who handled more orders than the average employee  ### 
SELECT employee_id, COUNT(*) AS order_count
FROM orders
GROUP BY employee_id
HAVING COUNT(*) > (
    SELECT AVG(order_count)
    FROM (
        SELECT employee_id, COUNT(*) AS order_count
        FROM orders
        GROUP BY employee_id
    ) AS employee_orders
);
####   CTE (Common Table Expressions)  ####

###  Using CTE, calculate total sales amount for each order  ###

with order_sales as(
	select o.order_id,o.quntity,p.product_id,p.price,
    o.quntity * p.price as total_sales
    from order_details as o
    join products as p
    on o.prodct_id = p.product_id) 
    select * from order_sales;
    
 ####  Using CTE, find customers whose total purchase amount is greater than 20,000  ###   
 WITH customer_sales AS (
    SELECT
        o.Customer_id,
        c.Customer_Name,
        SUM(od.Quntity * p.Price) AS total_purchase
    FROM Orders o
    JOIN Customers c
        ON o.Customer_id = c.Customer_id
    JOIN Order_details od
        ON o.Order_id = od.Order_id
    JOIN Products p
        ON od.Prodct_id = p.Product_id
    GROUP BY o.Customer_id, c.Customer_Name
)
SELECT
    Customer_id,
    Customer_Name,
    total_purchase
FROM customer_sales
WHERE total_purchase > 20000;

###  Using CTE, display the total revenue generated by each product category  ###
    
with product_sales as(
		select p.category,
        sum(od.quntity*p.price)as total_revenue
        from products as p
        join order_details as od
        on p.product_id = od.prodct_id
        group by p.category)
select 
category,total_revenue
from product_sales;

###  Using CTE, find the top 3 customers based on total spending   ###

with top_customers as(
select o.customer_id ,c.customer_name,
sum(od.quntity*p.price) as total_spending
from orders o
join customers c
on o.customer_id = c.customer_id
join order_details od
on od.order_id = o.order_id
join products p
on p.product_id =od.prodct_id
group by o.customer_id,c.customer_name
)
select
customer_id,customer_name,total_spending
from top_customers
order by total_spending desc
limit 3;

#### WINDOW Functions ####

###  Assign rank to customers based on total purchase amount  ###

WITH customer_spending AS (
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        SUM(od.Quntity * p.Price) AS total_purchase
    FROM Customers c
    JOIN Orders o
        ON c.Customer_ID = o.Customer_ID
    JOIN Order_Details od
        ON o.Order_ID = od.Order_ID
    JOIN Products p
        ON od.Prodct_ID = p.Product_ID
    GROUP BY c.Customer_ID, c.Customer_Name
)
SELECT
    Customer_ID,
    Customer_Name,
    total_purchase,
    RANK() OVER (ORDER BY total_purchase DESC) AS purchase_rank
FROM customer_spending;

####  Display cumulative sales amount by order date  ###

WITH order_sales AS (
    SELECT
        o.order_id,
        o.orderdate,
        SUM(od.quntity * p.price) AS sales_amount
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    JOIN products p
        ON od.prodct_id = p.product_id
    GROUP BY o.order_id, o.orderdate
)
SELECT
    order_id,
    orderdate,
    sales_amount,
    SUM(sales_amount) OVER (
        ORDER BY orderdate, order_id
    ) AS cumulative_sales
FROM order_sales
ORDER BY orderdate, order_id;

###	Display running total of sales for each employee  ###

WITH order_sales AS (
    SELECT
        o.order_id,
        o.orderdate,
        o.employee_id,
        SUM(od.quntity * p.price) AS sales_amount
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    JOIN products p
        ON od.prodct_id = p.product_id
    GROUP BY
        o.order_id,
        o.orderdate,
        o.employee_id
)
SELECT
    order_id,
    orderdate,
    employee_id,
    sales_amount,
    SUM(sales_amount) OVER (
        PARTITION BY employee_id
        ORDER BY orderdate, order_id
    ) AS running_total
FROM order_sales
ORDER BY employee_id, orderdate, order_id;

###  Find the highest priced product in each category  ###

WITH ranked_products AS (
    SELECT
        product_id,
        product_name,
        Category,
        Price,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY Price DESC
        ) AS product_rank
    FROM products
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM ranked_products
WHERE product_rank = 1;
    
###  Find customers who never placed an order  ###

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

  ### Find the second highest selling product  ###
  
  WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(od.quntity * p.price) AS total_sales
    FROM products p
    JOIN order_details od
        ON p.product_id = od.prodct_id
    GROUP BY
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        Product_id,
        Product_name,
        total_sales,
        DENSE_RANK() OVER (
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM product_sales
)
SELECT
    Product_id,
    Product_name,
    total_sales
FROM ranked_products
WHERE sales_rank = 2;
  
 ### Identify duplicate orders placed on the same day  ### 
  
SELECT 
    orderdate, COUNT(*) AS order_count
FROM
    orders
GROUP BY orderdate
HAVING COUNT(*) > 1;

###  Calculate monthly sales growth percentage  ###

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.orderdate, '%Y-%m') AS sales_month,
        SUM(od.quntity * p.price) AS total_sales
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    JOIN products p
        ON od.prodct_id = p.product_id
    GROUP BY DATE_FORMAT(o.orderdate, '%Y-%m')
),
sales_with_previous AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    ROUND(
        ((total_sales - previous_month_sales)
        / previous_month_sales) * 100,
        2
    ) AS growth_percentage
FROM sales_with_previous
ORDER BY sales_month;  
  
 ###  Find the top performing employee each month  ###
 
  WITH monthly_employee_sales AS (
    SELECT
        DATE_FORMAT(o.orderdate, '%Y-%m') AS sales_month,
        o.employee_id,
        e.employee_name,
        SUM(od.quntity * p.price) AS total_sales
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    JOIN products p
        ON od.prodct_id = p.product_id
    JOIN employee e
        ON o.employee_id = e.employee_id
    GROUP BY
        DATE_FORMAT(o.orderdate, '%Y-%m'),
        o.employee_id,
        e.employee_name
),
ranked_employees AS (
    SELECT
        sales_month,
        employee_id,
        employee_name,
        total_sales,
        RANK() OVER (
            PARTITION BY sales_month
            ORDER BY total_sales DESC
        ) AS employee_rank
    FROM monthly_employee_sales
)
SELECT
    sales_month,
    employee_id,
    employee_name,
    total_sales
FROM ranked_employees
WHERE employee_rank = 1
ORDER BY sales_month;
  
  
  
  
  
  
    
    
    
    
						







































































