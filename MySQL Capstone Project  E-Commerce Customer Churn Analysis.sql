-- Module End Assignment: Analyzing E-Learning Platform Purchases using MySQL

-- Database Setup & Data Entry

CREATE DATABASE e_learning;

USE e_learning;

CREATE TABLE learners(learner_id INT PRIMARY KEY,full_name VARCHAR(50),country VARCHAR(50));

CREATE TABLE courses(course_id INT PRIMARY KEY,course_name VARCHAR(50),category VARCHAR(50),unit_price INT);

CREATE TABLE purchases(purchase_id INT PRIMARY KEY,learner_id INT,course_id INT,quantity INT,purchase_date DATE,
FOREIGN KEY(learner_id) REFERENCES learners(learner_id),
FOREIGN KEY(course_id) REFERENCES courses(course_id ));

INSERT INTO learners VALUES
(1, 'Aarav Sharma', 'India'),
(2, 'Emma Johnson', 'USA'),
(3, 'Noah Williams', 'Canada'),
(4, 'Sophia Brown', 'UK'),
(5, 'Liam Davis', 'Australia'),
(6, 'Priya Nair', 'India'),
(7, 'Olivia Wilson', 'Germany'),
(8, 'Ethan Taylor', 'Singapore');

INSERT INTO courses VALUES
(101, 'SQL for Beginners', 'Database', 2999),
(102, 'Python Programming', 'Programming', 3999),
(103, 'Power BI Masterclass', 'Data Analytics', 4999),
(104, 'Excel Advanced', 'Productivity', 2499),
(105, 'Machine Learning', 'Artificial Intelligence', 6999),
(106, 'Web Development', 'Programming', 5499);

INSERT INTO purchases VALUES
(1001, 1, 101, 1, '2026-01-10'),
(1002, 2, 102, 2, '2026-01-15'),
(1003, 3, 103, 1, '2026-02-02'),
(1004, 1, 104, 3, '2026-02-10'),
(1005, 4, 105, 1, '2026-02-18'),
(1006, 5, 106, 2, '2026-03-05'),
(1007, 6, 101, 2, '2026-03-12'),
(1008, 7, 103, 1, '2026-03-20'),
(1009, 8, 102, 1, '2026-04-01'),
(1010, 2, 104, 2, '2026-04-08'),
(1011, 3, 106, 1, '2026-04-15'),
(1012, 6, 105, 1, '2026-05-03'),
(1013, 5, 101, 4, '2026-05-10'),
(1014, 4, 103, 2, '2026-05-18'),
(1015, 8, 104, 1, '2026-06-05');

INSERT INTO learners VALUES(9, 'Rahul Verma', 'India');
INSERT INTO courses VALUES(107, 'Tableau Basics', 'Data Analytics', 5999);

SELECT * FROM learners;
SELECT * FROM courses;
SELECT * FROM purchases;

-- Data Exploration Using Joins
-- INNER JOIN

SELECT l.*,c.*,p.purchase_date FROM learners l
INNER JOIN purchases p
ON l.learner_id=p.learner_id
INNER JOIN courses c
ON p.course_id=c.course_id;

-- LEFT JOIN
-- Combine learner, course, and purchase data

SELECT l.learner_id,full_name,c.course_name,c.unit_price,p.quantity,p.purchase_date FROM learners l
LEFT JOIN purchases p
ON l.learner_id=p.learner_id
LEFT JOIN courses c
ON p.course_id=c.course_id;

-- RIGHT JOIN 

SELECT l.learner_id,full_name,c.course_name,c.unit_price,p.quantity,p.purchase_date FROM purchases p 
RIGHT JOIN learners l
ON l.learner_id=p.learner_id
RIGHT JOIN courses c
ON p.course_id=c.course_id;

-- Display: Learner name, Course name, Category, Quantity, Total amount, Purchase

SELECT l.full_name AS learner_name,c.course_name,c.category,p.quantity,(p.quantity * c.unit_price) AS Total_amount,p.purchase_date 
FROM learners l
INNER JOIN purchases p
ON l.learner_id=p.learner_id
INNER JOIN courses c
ON p.course_id=c.course_id;

-- Sort by the highest total amount

SELECT l.full_name AS learner_name,c.course_name,c.category,p.quantity,(p.quantity * c.unit_price) AS Total_amount,p.purchase_date 
FROM learners l
INNER JOIN purchases p
ON l.learner_id=p.learner_id
INNER JOIN courses c
ON p.course_id=c.course_id
ORDER BY total_amount DESC;

-- Format currency to 2 decimal places 

SELECT course_name,FORMAT(unit_price,2) FROM courses;

-- Use column aliases 
-- Sort by the highest total amount

SELECT l.full_name AS learner_name,c.course_name,c.category,p.quantity,FORMAT(p.quantity * c.unit_price,2) AS Total_amount,p.purchase_date 
FROM learners l
INNER JOIN purchases p
ON l.learner_id=p.learner_id
INNER JOIN courses c
ON p.course_id=c.course_id
ORDER BY (p.quantity * c.unit_price) DESC;

-- Core Analytical Queries
-- Display each learner’s total spending with their country.

SELECT l.full_name AS learner_name,l.country,SUM(p.quantity * c.unit_price) AS Total_Spend FROM learners l
INNER JOIN purchases p
ON l.learner_id=p.learner_id
INNER JOIN courses c
ON p.course_id=c.course_id
GROUP BY l.full_name,l.country;
SELECT * FROM courses;
SELECT * FROM purchases;

-- Find the top 3 most purchased courses by quantity.

SELECT c.course_id,c.course_name,SUM(p.quantity) Total_quantity FROM courses c
JOIN purchases p
ON p.course_id=c.course_id
GROUP BY c.course_id,c.course_name
ORDER BY SUM(p.quantity) DESC
LIMIT 3;

-- Show each category’s: Total revenue & Number of unique learners

SELECT COUNT(DISTINCT l.learner_id) Unique_Learners,c.category,SUM(p.quantity * c.unit_price) Total_Revenue
FROM courses c
INNER JOIN purchases p
ON p.course_id=c.course_id
INNER JOIN learners l
ON l.learner_id=p.learner_id
GROUP BY category;

-- List learners who purchased from more than one category.

SELECT l.learner_id,l.full_name,COUNT(DISTINCT c.category) category_count
FROM courses c
INNER JOIN purchases p
ON p.course_id=c.course_id
INNER JOIN learners l
ON l.learner_id=p.learner_id
GROUP BY l.learner_id,l.full_name
HAVING category_count>1;

-- Identify courses never purchased.

SELECT c.course_id,c.course_name,c.category
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
WHERE p.course_id IS NULL;

-- Subqueries 
-- Find learners whose total spending is above the average learner spending.

SELECT l.learner_id,l.full_name,SUM(p.quantity * c.unit_price) AS total_spending FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING SUM(p.quantity * c.unit_price) >(SELECT AVG(total_spending) FROM 
(SELECT SUM(p.quantity * c.unit_price) AS total_spending 
FROM purchases p 
JOIN courses c 
ON p.course_id = c.course_id GROUP BY p.learner_id ) AS avg_spending );
        
-- Display courses whose price is higher than any course in the ‘Beginner’ category.

SELECT course_name,unit_price FROM courses
WHERE unit_price > ANY (SELECT unit_price FROM courses WHERE category = 'Beginner');

-- CTE, CASE, View, and NULL Handling
-- Use a CTE to calculate total spending per learner.

WITH learners_spend AS (
SELECT l.learner_id,l.full_name,SUM(p.quantity * c.unit_price) Total_Spend
FROM courses c
INNER JOIN purchases p
ON p.course_id=c.course_id
INNER JOIN learners l
ON l.learner_id=p.learner_id
GROUP BY l.full_name,l.learner_id )
SELECT * FROM learners_spend;

-- CASE Expression

WITH learners_spend AS (
SELECT l.learner_id,l.full_name,SUM(p.quantity * c.unit_price) Total_Spend
FROM courses c
INNER JOIN purchases p
ON p.course_id=c.course_id
INNER JOIN learners l
ON l.learner_id=p.learner_id
GROUP BY l.full_name,l.learner_id 
)
SELECT learner_id,full_name,Total_Spend,
CASE
WHEN Total_Spend>15000 THEN "High Value"
WHEN Total_Spend>=8000 THEN "Medium Value"
ELSE "Low Value"
END AS Learners_Category FROM learners_spend; 

--  NULL Handling
-- Display all courses and replace NULL purchase counts with 0 using: IFNULL() or COALESCE()

SELECT c.course_id,c.course_name,IFNULL(SUM(p.quantity), 0) AS Purchase_Count FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name;

-- View
-- Create a view: category_performance_view Showing:Category,Total revenue,Number of purchases,Average revenue per purchase

CREATE VIEW category_performance_view AS
SELECT c.category,SUM(p.quantity * c.unit_price) Total_Revenue,COUNT(p.purchase_id) No_of_Purchase,
AVG(p.quantity * c.unit_price) Avg_Revenue FROM courses c
JOIN purchases p
ON c.course_id=p.course_id
GROUP BY c.category;

SELECT * FROM category_performance_view;


/* Summary Report

Created a database and tables using Primary Keys and Foreign Keys.
Inserted sample data into the Learners, Courses, and Purchases tables.
Used INNER JOIN, LEFT JOIN, and RIGHT JOIN to combine data from multiple tables.
Performed data analysis using SUM(), COUNT(), AVG(), GROUP BY, HAVING, and ORDER BY.
Solved analytical problems using Subqueries and CTEs.
Applied CASE statements for learner classification and IFNULL() for NULL handling.
Created a VIEW to generate a reusable category performance report.
*/









