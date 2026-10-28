SELECT table_name FROM user_tables ORDER BY table_name;
SELECT constraint_name,table_name,constraint_type,status FROM user_constraints ORDER BY table_name,constraint_name;
SELECT object_name,object_type,status FROM user_objects WHERE object_name='BOOK_MANAGEMENT_PKG' OR object_type='TRIGGER' ORDER BY object_type,object_name;
SELECT name,type,line,position,text FROM user_errors ORDER BY name,sequence;
SELECT COUNT(*) authors FROM authors;
SELECT COUNT(*) categories FROM categories;
SELECT COUNT(*) publishers FROM publishers;
SELECT COUNT(*) books FROM books;
SELECT COUNT(*) members FROM members;
SELECT COUNT(*) book_issues FROM book_issues;
SELECT book_management_pkg.get_total_books total_books FROM dual;
SELECT book_management_pkg.get_inventory_value inventory_value FROM dual;
SELECT book_management_pkg.get_overdue_book_count overdue_issues FROM dual;

