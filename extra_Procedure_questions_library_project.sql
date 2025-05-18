-- PERFORMING CRUD OPERATIONS ON THE DATABASE USING PROCEDURES
-- 1. Write a stored procedure get_book_title that takes a book's ISBN as input and returns the title of the book.
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

-- 2. Create a stored procedure add_member that inserts a new member into the members table. Accept name, email, and 
-- registration date as parameters.
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
 
--  3. Count Books Issued to a Member
-- Write a stored procedure count_books_issued that accepts a member_id and returns the total number of books issued to that member.
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

-- 4. Increase Book Price by Category
-- Create a stored procedure increase_price_by_category that increases the price of all books in a given category by 10%.
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

-- 5. Delete Old Issued Records
-- Write a stored procedure delete_old_issued that deletes issued records older than a given number of days (input parameter).
delimiter $$
create procedure delete_old_issued(in p_num_days int)
begin
delete from issued_status
where issued_date < date_sub(current_date(),interval p_num_days day);  
end$$
delimiter ;

-- calling the procedure
call delete_old_issued(30);


-- Section 2: Triggers
-- 1. Auto-Set Book Status to 'Available' on Insert
-- Create a BEFORE INSERT trigger on the books table that sets status = 'Available' if no status is provided when inserting a new book.
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


-- 2. Update Book Status to 'Issued' When a Book is Issued
-- Create an AFTER INSERT trigger on issued_status that updates the status of the corresponding book in the books table to 'Issued'.
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
-- 3. Update Book Status to 'Available' When a Book is Returned
-- Create an AFTER INSERT trigger on return_status that sets the status of the corresponding book in the books table to 'Available'.
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

-- 4. Prevent More Than One Issue Per Member Per Day
-- Create a BEFORE INSERT trigger on issued_status that checks if the same member (issued_member_id) is trying to issue more than one book on the same date. 
-- If so, prevent the insert.
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

-- 5. Auto-Fill return_book_name from Issued Info
-- Create a BEFORE INSERT trigger on return_status to automatically fill return_book_name based on the corresponding issued_id from issued_status.
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
