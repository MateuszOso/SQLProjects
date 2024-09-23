USE library_project;

SELECT *
FROM books;

INSERT INTO books
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT *
FROM books;

SELECT *
FROM members;

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';


SELECT *
FROM issued_status;

DELETE FROM issued_status
WHERE   issued_id =   'IS121';

#Members Who Have Issued More Than One Book
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;

#Each book and total book_issued
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books AS b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT *
FROM book_issued_cnt;



CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

SELECT *
FROM expensive_books;

SELECT *
FROM books, issued_status;

#Total Rental Income by Category
SELECT 
    b.category,
    SUM(b.rental_price) AS Rental_income,
    COUNT(*) AS Rental_amount
FROM 
issued_status AS ist
JOIN
books AS b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
ORDER BY 2 DESC;

#Members Who Registered in the Last 180 Days
SELECT *
FROM members
WHERE DATEDIFF( CURRENT_DATE, reg_date) <= 180;


SELECT *
FROM employees, branch;

#Employees with Their Branch Manager's Name and their branch details
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id
ORDER BY e1.emp_id;


SELECT *
FROM issued_status, return_status;


#List of Books Not Yet Returned
SELECT * 
FROM issued_status as ist
LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


#Procedure - update the status of books in the books table to "Yes" when they are returned
DELIMITER $$
CREATE PROCEDURE add_return_records(
IN p_return_id VARCHAR(10),
IN p_issued_id VARCHAR(10), 
OUT v_isbn VARCHAR(50),
 OUT v_book_name VARCHAR(80)
 )

BEGIN
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    END$$
    
DELIMITER ;

