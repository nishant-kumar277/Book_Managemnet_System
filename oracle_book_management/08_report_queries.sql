-- All reports can be run with Ctrl+Enter (one statement at a time).
SELECT b.book_id,b.title,a.author_name,c.category_name,p.publisher_name,b.isbn,b.price,b.available_stock
FROM books b JOIN authors a ON a.author_id=b.author_id JOIN categories c ON c.category_id=b.category_id JOIN publishers p ON p.publisher_id=b.publisher_id ORDER BY b.title;
SELECT book_id,title,available_stock FROM books WHERE available_stock<=3 ORDER BY available_stock,title;
SELECT b.title,a.author_name FROM books b JOIN authors a ON a.author_id=b.author_id WHERE a.author_name LIKE '%Orwell%';
SELECT b.title,c.category_name FROM books b JOIN categories c ON c.category_id=b.category_id WHERE c.category_name='Classic';
SELECT i.issue_id,b.title,m.member_name,i.issue_date,i.due_date,i.issue_status FROM book_issues i JOIN books b ON b.book_id=i.book_id JOIN members m ON m.member_id=i.member_id WHERE i.issue_status='ISSUED' ORDER BY i.due_date;
SELECT i.issue_id,b.title,m.member_name,i.return_date FROM book_issues i JOIN books b ON b.book_id=i.book_id JOIN members m ON m.member_id=i.member_id WHERE i.issue_status='RETURNED';
SELECT i.issue_id,b.title,m.member_name,i.due_date FROM book_issues i JOIN books b ON b.book_id=i.book_id JOIN members m ON m.member_id=i.member_id WHERE i.issue_status='ISSUED' AND i.due_date<TRUNC(SYSDATE) ORDER BY i.due_date;
SELECT COUNT(*) total_book_titles FROM books;
SELECT NVL(SUM(price*available_stock),0) inventory_value FROM books;
SELECT m.member_id,m.member_name,COUNT(i.issue_id) issue_count FROM members m LEFT JOIN book_issues i ON i.member_id=m.member_id GROUP BY m.member_id,m.member_name ORDER BY issue_count DESC,m.member_name;

