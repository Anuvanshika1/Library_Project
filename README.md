# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project]((https://github.com/Anuvanshika1/Library_Project/blob/main/library.jpg))

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Anuvanshika1/Library_Project/blob/main/library_project_er_diagram.png)

- **Database Creation**: Created a database named `library_project2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_project2;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
-- Either we can use CREATE TABLE Statements or we can directly export the table and then we can assign primary and foreign keys
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

-- we can change the data type then after using MODIFY statement
alter table books
modify column book_title varchar(80);  
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
 insert into books values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

 -- checking if the row being inserted or not
 SELECT 
    *
FROM
    books
WHERE
    isbn = '978-1-60129-456-2';
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';

-- verifying 
select * from issued_status
where issued_id='IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
    issued_emp_id, COUNT(*) AS total_books
FROM
    issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_count AS SELECT b.isbn, b.book_title, COUNT(*) AS total_books FROM
    issued_status i
        JOIN
    books b ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn;

select * from book_issued_count;
-- for dropping the table created
drop table book_issued_count;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,
    SUM(b.rental_price) AS total_rental_income,
    count(*) as total_books_rented
FROM
    books b
        JOIN
    issued_status i ON i.issued_book_isbn = b.isbn
GROUP BY  b.category;

```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select * from members
where reg_date >= date_sub(current_date(),interval 180 day);

-- inserting new values to get the last 180 days members registration
insert into members values('C120', 'sam', '145 Main St', '2025-01-01'),
('C121', 'john', '133 Main St', '2025-02-01'); 
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
with cte as (  SELECT e.emp_name AS manager_name,b.manager_id,b.branch_id
                    FROM employees e
                         JOIN branch b
                    ON b.manager_id=e.emp_id
)
select e.*,b.branch_address,b.contact_no,c.manager_name
from 
	employees e 
	left join
    branch b on e.branch_id=b.branch_id
	left join 
	cte c on e.branch_id=c.branch_id
order by e.branch_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold 7USD**:
```sql
CREATE TABLE book_price_above_seven AS SELECT * FROM
    books
WHERE
    rental_price > 7;

-- Now checking if the table contains the data
select * from book_price_above_seven;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
   distinct i.issued_book_name
FROM
    issued_status i
         LEFT JOIN
    return_status r ON i.issued_id = r.issued_id
    where r.return_id is null
  ;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    m.member_id,
    m.member_name,
    i.issued_book_name,
    i.issued_date,
    CURRENT_DATE() - i.issued_date AS days_overdue
FROM
    issued_status i
        LEFT JOIN
    members m ON m.member_id = i.issued_member_id
        LEFT JOIN
    return_status r ON r.issued_id = i.issued_id
WHERE
    r.return_date IS NULL
        AND (CURRENT_DATE - i.issued_date) > 30
;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

**Creating a trigger for the query**
```sql
delimiter $$
create trigger update_book_status
after insert on return_status
for each row
begin
declare v_issued_isbn varchar(20);-- declaring a variable in order to get the isbn of the book that is issued
SELECT 
    issued_book_isbn
INTO v_issued_isbn FROM
    issued_status
WHERE
    issued_id = new.issued_id;-- we are getting the isbn of that issued book whose issued_id 
UPDATE books 
SET 
    status = 'Yes'
WHERE
    isbn = v_issued_isbn;    -- we will update the status of that book whose isbn in the book table        
                             -- will match the isbn of the new row isbn that we had stored in a variable
end$$
delimiter ;

-- testing the trigger by inserting a new record in the return_status table
insert into return_status
values('RS123','IS135','Sapiens: A Brief History of Humankind','24-02-01','978-0-307-58837-1');

```
**Creating the stored procedure for the same query**
``` sql
delimiter $$
create procedure book_status_update(in p_return_id varchar(10),in p_issued_id varchar(10), in p_return_book_isbn varchar(20))
begin
declare v_issued_isbn varchar(20);  -- declaring the variable to store the value of the newly entered rows isbn

-- inserting the values in the columns of the return_status table with the values that we will put p_issued_id ... 
insert into return_status(return_id,issued_id,return_date,return_book_isbn)
values(p_return_id,p_issued_id,current_date,p_return_book_isbn);
 
-- after the insertion it will check the issued_id, if it gets matched with the newly inserted
-- issued_id it will store that isbn in the variable
SELECT 
    issued_book_isbn
INTO v_issued_isbn FROM
    issued_status
WHERE
    issued_id = p_issued_id;
-- updating the book status
UPDATE books 
SET 
    status = 'Yes'
WHERE
    isbn = v_issued_isbn;
END$$
DELIMITER ;

-- now after calling the procedure the row will be inserted and the book status would have been changed
call book_status_update('RS128','IS135','978-0-307-58837-1');
```


**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
SELECT 
    b.branch_id,
    COUNT(i.issued_id) AS books_issued,
    COUNT(r.return_id) AS return_book_count,
    SUM(bb.rental_price) AS total_revenue
FROM
    branch b
        JOIN
    employees e ON b.branch_id = e.branch_id
        LEFT JOIN
    issued_status i ON i.issued_emp_id = e.emp_id
        LEFT JOIN
    return_status r ON r.issued_id = i.issued_id
        JOIN
    books bb ON bb.isbn = i.issued_book_isbn
GROUP BY b.branch_id;

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members AS SELECT * FROM
    members
WHERE
    member_id IN (SELECT 
            issued_member_id
        FROM
            issued_status
        WHERE
            issued_date >= DATE_SUB(current_date(), INTERVAL 2 MONTH) -- as the dataset is from 2024, we can change the date accordingly
        GROUP BY issued_member_id
        HAVING COUNT(issued_member_id) >= 1);

-- select the table
SELECT 
    *
FROM
    active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
with cte as (select e.emp_name,
                    count(i.issued_emp_id) as total_books,
                    b.branch_id,
                    dense_rank() over(order by count(i.issued_emp_id) desc) as top_books
            from issued_status i
                   JOIN
            employees e ON e.emp_id = i.issued_emp_id
                   JOIN
            branch b ON b.branch_id = e.branch_id
                GROUP BY e.emp_name , i.issued_emp_id
)
select * from cte 
where top_books <=3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    b.status,
    COUNT(*) AS time_book_damage
FROM
    members m
        JOIN
    issued_status i ON m.member_id = i.issued_member_id
        JOIN
    books b ON b.isbn = i.issued_book_isbn
WHERE
    b.status = 'Damaged'
GROUP BY m.member_id , m.member_name , b.book_title
HAVING COUNT(*) >= 2;
```


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
delimiter $$
create procedure update_status(in p_issued_id varchar(15),in p_member_id varchar(30),in p_issued_isbn varchar(20))
begin
declare v_status varchar(10);
SELECT 
    status
INTO v_status FROM
    books
WHERE
    isbn = p_issued_isbn;
if v_status='Yes' then 
insert into issued_status(issued_id,issued_member_id,issued_book_isbn) values(p_issued_id,p_member_id,p_issued_isbn);

UPDATE books 
SET 
    status = 'no'
WHERE
    isbn = p_issued_isbn;
else SIGNAL SQLSTATE '45000' 
set Message_Text='Book not available';
end if;
end $$
delimiter ;

drop procedure update_status;
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL update_status('IS155', 'C108', '978-0-553-29698-2');  -- if the status is YES then this record 
															-- will be inserted to issued_status table and the book status will become No
CALL update_status('IS156', 'C108', '978-0-375-41398-8');  -- status is no then error message will come

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8' ;-- here it will show error book not available

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
```sql
CREATE TABLE overdue_members AS SELECT m.member_id,
    m.member_name,
    COUNT(i.issued_member_id) AS total_books_issued,
    SUM(DATEDIFF(r.return_date, i.issued_date)) AS total_days,  -- to sum up the total days more than 30 per member
    SUM(0.5 * ABS(DATEDIFF(r.return_date, i.issued_date))) AS overdue_fees  -- sum up the total rental fine per member
    FROM
    members m
        JOIN
    issued_status i ON i.issued_member_id = m.member_id
       left JOIN
    return_status r ON r.issued_id = i.issued_id
WHERE r.return_date is null or  -- because we need to find those members also who did not return the book till today
    DATEDIFF(r.return_date, i.issued_date) >= 30
GROUP BY m.member_name , m.member_id;

drop table overdue_members;
select * from overdue_members;

```
**Some extra Trigger and Procedure Questions**
1. Write a stored procedure get_book_title that takes a book's ISBN as input and returns the title of the book.
```sql
delimiter $$
create procedure get_book_title(in p_isbn varchar(20),out p_book_title varchar(80))
begin
select book_title into p_book_title
from books
where isbn=p_isbn;
end$$
delimiter ;


-- declaring a session variable to store the output
set @p_book_title='';
-- calling the procedure
call get_book_title('978-0-06-112241-5',@p_book_title);
-- checking the result
select @p_book_title;
```
2. Create a stored procedure add_member that inserts a new member into the members table. Accept name, email, and 
-- registration date as parameters.
 ```sql
 delimiter $$
 create procedure add_member(in p_id varchar(15),in p_name varchar(15),in p_member_address varchar(20), in p_registration_date date)
 begin
 insert into members values (p_id,p_name,p_member_address,p_registration_date);

 end$$
 delimiter ;
 
 -- calling the procedure
 call add_member('C132','Ram','34 Delhi Road','2025-02-11');
-- checking the output
 select * from members
 where member_id='C132';
```
 
 3. Count Books Issued to a Member
-- Write a stored procedure count_books_issued that accepts a member_id and returns the total number of books issued to that member.
```sql
delimiter $$
 create procedure count_books_issued(in p_issued_member_id varchar(15),out p_total_books int)
 begin
 select count(issued_member_id) into p_total_books
 from issued_status
 where issued_member_id=p_issued_member_id
 group by issued_member_id;
 
 end$$
 delimiter ;
 set @p_total_books=0; -- setting initial value of the variable to 0
 call count_books_issued('C102',@p_total_books); -- calling the procedure
 select @p_total_books; -- checking the output

```

 4. Increase Book Price by Category
 Create a stored procedure increase_price_by_category that increases the price of all books in a given category by 10%.
```sql
delimiter $$
create procedure increase_price_by_category(in p_category varchar(20))  -- we will put the category name as input 
begin
select category,(rental_price + (rental_price*10/100)) as new_rental_price  -- selecting the category and increased rental price
from books
where category=p_category;  -- selecting only those categories whose category is same as the input we put
end$$ 
delimiter ;

-- calling the procedure
call increase_price_by_category('classic');

```
5. Delete Old Issued Records
   Write a stored procedure delete_old_issued that deletes issued records older than a given number of days (input parameter).
```sql

delimiter $$
create procedure delete_old_issued(in p_num_days int)
begin
delete from issued_status
where issued_date < date_sub(current_date(),interval p_num_days day);  
end$$
delimiter ;

-- calling the procedure
call delete_old_issued(30);

```

**Section 2: Triggers**

 1. Auto-Set Book Status to 'Available' on Insert
Create a BEFORE INSERT trigger on the books table that sets status = 'Available' if no status is provided when inserting a new book.
```sql
delimiter $$
create trigger t_book_status
before insert on books
for each row
begin
if new.status is null then 
set new.status='Available';
end if
;
end $$
delimiter ;
 -- inserting the values into books table
INSERT INTO books (isbn, book_title, category, rental_price)
VALUES ('123-456', 'SQL Basics', 'Education', 100);
-- checking the table
select * from books
where isbn='123-456';

``` 

 2. Update Book Status to 'Issued' When a Book is Issued
 Create an AFTER INSERT trigger on issued_status that updates the status of the corresponding book in the books table to 'Issued'.
```sql
delimiter $$
create trigger t_book_issued
after insert on issued_status
for each row
begin
update books
set status='Issued'
where isbn=new.issued_book_isbn;   -- we directly reffered to new.issued_bbok_isbn because we are already doing insert on issued_status,
                                   --  so we can take that value directly from issued_status to use for books table
end $$
delimiter ;

-- inserting the value in issued_status
 insert into issued_status(issued_id,issued_book_name,issued_date,issued_book_isbn) values('is001','SQL Basics',current_date,'123-456');
 -- checking the books table
 SELECT 
    *
FROM
    books
WHERE
    isbn = '123-456';

```

3. Update Book Status to 'Available' When a Book is Returned
Create an AFTER INSERT trigger on return_status that sets the status of the corresponding book in the books table to 'Available'.
```sql
delimiter $$
create trigger t_retur_book
after insert on return_status
for each row 
begin 
declare v_isbn varchar(15);
-- we got the issued_book_isbn just in case if we dont have the return_book_isbn in the return_status table, so tried to fetch that from issued_status
select issued_book_isbn into v_isbn
from issued_status
where issued_id=new.issued_id;

update books
set status = 'Available'
where isbn=v_isbn;
end $$
delimiter ;

-- if the return_book_isbn is present than we can directly get the isbn from return_status_table
delimiter $$
create trigger t_retur_book
after insert on return_status
for each row 
begin 
update books
set status = 'Available'
where isbn=new.return_book_isbn;
end $$
delimiter ;

```

4. Prevent More Than One Issue Per Member Per Day
 Create a BEFORE INSERT trigger on issued_status that checks if the same member (issued_member_id) is trying to issue more than one book on the same date.If so, prevent the insert.
```sql
delimiter $$
create trigger t_member_status
before insert on issued_status
for each row
begin
declare v_count int ;
select count(issued_member_id) into v_count
from issued_status
where issued_member_id=new.issued_member_id
and issued_date=new.issued_date
group by issued_member_id;
 if v_count > 1 
 then signal sqlstate '45000'
 set Message_Text='Member not allowed to take another book';  -- writing a message 
 end if;
end $$
delimiter ;

INSERT INTO issued_status (
  issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn,issued_emp_id
) VALUES (
  'IS1003','C106', 'Sql basics', '2024-03-10', '978-0-330-25864-8', 'E104'
);
--  checking the table
select * from issued_status;
-- deleting the record
delete from issued_status
where issued_id='IS1003';

```

5. Auto-Fill return_book_name from Issued Info
 Create a BEFORE INSERT trigger on return_status to automatically fill return_book_name based on the corresponding issued_id from issued_status.
```sql
delimiter $$
create trigger t_return_book_name
before insert on return_status
for each row 
begin 
declare v_return_book varchar(80);
-- fetching the book name based on issued id that will be equal to the new issued id that is going to be added in return_status table
select issued_book_name into v_return_book  -- putting the book_name into the variable
from issued_status
where issued_id=new.issued_id;  

set new.return_book_name=v_return_book;  -- setting the return_book_name equal to the book name we put down in v_return_book
end $$
delimiter ;

-- inserting a row without book_name
insert into return_status(return_id,issued_id,return_date) values('r109','IS106',current_date);
-- checking the values
select * from return_status
where return_id='r109';

```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Author - Anuvanshika



Thank you for your interest in this project!
