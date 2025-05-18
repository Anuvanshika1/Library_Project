-- creating database library_project2
-- 1. Database Structure 
create database library_project2;
-- using the database
use library_project2;
-- importing the tables and the data through import wizard or creating table one by one and then importing data into it
/*
	CREATE TABLE IF NOT EXISTS branch (
    branch_id VARCHAR(10) primary key,
    manager_id VARCHAR(10),
    branch_address VARCHAR(55),
    contact_no VARCHAR(10)
);
*/
-- Assigning primary key and adding foreign key constraint to the table columns either through the SQL Query or
-- through altering the table from the schemas 
/*
alter table issued_status
 add foreign key(issued_member_id) references members(member_id) on delete cascade;
 
 alter table issued_status
 add foreign key(issued_book_isbn) references books(isbn) on delete cascade;
 
 alter table issued_status
 add foreign key(issued_emp_id) references employees(emp_id) on delete cascade;
 
 alter table employees
 add foreign key(branch_id) references branch(branch_id) on delete cascade;
 
 alter table return_status
 add foreign key(return_book_isbn) references books(isbn) on delete cascade;
*/
-- Modifying the data type if needed keeing the column name same
alter table books
modify column book_title varchar(80);  
 -- checking every table if we received all data correctly
SELECT 
    *
FROM
    books;
    
SELECT 
    *
FROM
    branch;

SELECT 
    *
FROM
    employees;
    
-- Now solving tasks
-- 2. Performing CRUD operations
/* Task 1
Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
*/
 insert into books values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
 -- checking if the row being inserted or not
 SELECT 
    *
FROM
    books
WHERE
    isbn = '978-1-60129-456-2';
    
-- Task 2
/* Update an Existing Member's Address */
UPDATE members 
SET 
    member_address = '125 Oak St'
WHERE
    member_id = 'C103';
-- Verifying the update
SELECT 
    *
FROM
    members
WHERE
    member_id = 'C103';

-- Task 3
-- Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status 
WHERE
    issued_id = 'IS121';
-- verifying 
select * from issued_status
where issued_id='IS121';

-- Task 4
-- Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id='E101';

-- Task 5 
-- List employees Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find employees who have issued more than one book.
SELECT 
    issued_emp_id, COUNT(*) AS total_books
FROM
    issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1; 

/* 3. CTAS (Create Table As Select) */
-- Task 6
-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_count** 
CREATE TABLE book_issued_count AS SELECT b.isbn, b.book_title, COUNT(*) AS total_books FROM
    issued_status i
        JOIN
    books b ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn;

select * from book_issued_count;
-- for dropping the table created
drop table book_issued_count;

-- 4. Data Analysis & Findings
-- The following SQL queries were used to address specific questions:
-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where category ='Classic';
-- task 8 
-- Find Total Rental Income by Category:
SELECT 
    b.category,
    SUM(b.rental_price) AS total_rental_income,
    count(*) as total_books_rented
FROM
    books b
        JOIN
    issued_status i ON i.issued_book_isbn = b.isbn
GROUP BY  b.category;

-- task 9 
-- List Members Who Registered in the Last 180 Days
select * from members
where reg_date >= date_sub(current_date(),interval 180 day);  

-- inserting new values to get the last 180 days members registration
insert into members values('C120', 'sam', '145 Main St', '2025-01-01'),
('C121', 'john', '133 Main St', '2025-02-01');

-- task 10 
-- List Employees with Their Branch Manager's Name and their branch details:
with cte as (
				SELECT e.emp_name AS manager_name,b.manager_id,b.branch_id
				FROM
					employees e 
					JOIN branch b ON b.manager_id=e.emp_id
)
select e.*,b.branch_address,b.contact_no,c.manager_name
from 
	employees e 
	left join
    branch b on e.branch_id=b.branch_id
	left join 
	cte c on e.branch_id=c.branch_id
order by e.branch_id;
 
-- task 11
-- Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
CREATE TABLE book_price_above_seven AS SELECT * FROM
    books
WHERE
    rental_price > 7;
    
-- Now checking if the table contains the data
select * from book_price_above_seven;

-- task 12
-- Retrieve the List of Books Not Yet Returned
SELECT 
   distinct i.issued_book_name
FROM
    issued_status i
         LEFT JOIN
    return_status r ON i.issued_id = r.issued_id
    where r.return_id is null
  ;
    






