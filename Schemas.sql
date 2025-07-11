	
create database monday_coffee_db

use monday_coffee_db;

-- Monday Coffee SCHEMAS

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales

-- 1. City Table
CREATE TABLE city (
	city_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    population BIGINT,
    estimated_rent FLOAT,
    city_rank INT
);

-- 2. Product Table
CREATE TABLE products (
	product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price FLOAT
);

-- 3. Customers Table

CREATE TABLE customers (
	customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city_id INT,
    CONSTRAINT fk_city FOREIGN KEY (city_id)
		REFERENCES city(city_id)
);

-- 4. Sales Table

CREATE TABLE sales (
	sale_id INT PRIMARY KEY,
    sale_date DATE,
    product_id INT,
    customer_id INT,
    total FLOAT,
    rating INT,
    CONSTRAINT fk_product FOREIGN KEY (product_id)
		REFERENCES products(product_id),
	CONSTRAINT fk_customer FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id)
);

-- END of SCHEMAS



