-- Advance Question
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.
select m.member_id,m.member_name,i.issued_book_name,i.issued_date,current_date()-i.issued_date as days_overdue
from issued_status i 
left join members m on m.member_id=i.issued_member_id
left join return_status r on r.issued_id=i.issued_id
where r.return_date is null
and  (CURRENT_DATE - i.issued_date) > 30
;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned 
-- (based on entries in the return_status table).
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
insert into return_status values('RS123','IS135','Sapiens: A Brief History of Humankind','24-02-01','978-0-307-58837-1');


-- creating stored procedure for the same query
delimiter $$
create procedure book_status_update(in p_return_id varchar(10),in p_issued_id varchar(10), in p_return_book_isbn varchar(20))
begin
declare v_issued_isbn varchar(20);  -- declaring the variable to store the value of the newly entered rows isbn

-- inserting the values in the columns of the return_status table with the values that we will put p_issued_id ... 
insert into return_status(return_id,issued_id,return_date,return_book_isbn) values(p_return_id,p_issued_id,current_date,p_return_book_isbn);
 
-- after the insertion it will check the issued_id, if it gets matched with the newly inserted issued_id it will store that isbn in the variable
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

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/
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

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at 
least one book in the last 2 months.*/
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


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/
with cte as (select e.emp_name,
					count(i.issued_emp_id) as total_books,
					b.branch_id,
					dense_rank() over(order by count(i.issued_emp_id) desc) as top_books
			from issued_status i
					JOIN
			employees e ON e.emp_id = i.issued_emp_id
					JOIN
			branch b ON b.branch_id = e.branch_id
				GROUP BY e.emp_name , i.issued_emp_id)
select * from cte 
where top_books <=3;

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/
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


/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued,
and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/
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

/*Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: 
Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's 
fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number
of overdue books Total fines*/

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

