-- Run as BOOK_APP after 05_sample_data.sql. F5. Uses uniquely named test rows and cleans them up.
SET SERVEROUTPUT ON
DECLARE
  a NUMBER; c NUMBER; p NUMBER; m NUMBER; b NUMBER; x NUMBER; msg VARCHAR2(4000);
  cur SYS_REFCURSOR; title_value VARCHAR2(250);
BEGIN
  book_management_pkg.add_author('CRUD Test Author','crud.author@example.test','Test',a,msg); DBMS_OUTPUT.PUT_LINE(msg||' id='||a);
  book_management_pkg.update_author(a,'CRUD Test Author Updated','crud.author@example.test','Test',msg); DBMS_OUTPUT.PUT_LINE(msg);
  book_management_pkg.add_category('CRUD Test Category','temporary',c,msg); book_management_pkg.update_category(c,'CRUD Test Category Updated','edited',msg); DBMS_OUTPUT.PUT_LINE(msg);
  book_management_pkg.add_publisher('CRUD Test Publisher','Test address','000','crud.publisher@example.test',p,msg); book_management_pkg.update_publisher(p,'CRUD Test Publisher Updated','Test address','000','crud.publisher@example.test',msg); DBMS_OUTPUT.PUT_LINE(msg);
  book_management_pkg.add_member('CRUD Test Member','crud.member@example.test','000',m,msg); book_management_pkg.update_member(m,'CRUD Test Member Updated','crud.member@example.test','111',msg); DBMS_OUTPUT.PUT_LINE(msg);
  book_management_pkg.add_book('CRUD test title',a,c,p,'TEST-ISBN-0001',20,2020,4,b,msg); DBMS_OUTPUT.PUT_LINE(msg||' id='||b);
  book_management_pkg.update_book(b,'CRUD updated title',a,c,p,'TEST-ISBN-0001',25,2021,7,msg); DBMS_OUTPUT.PUT_LINE(msg);
  book_management_pkg.get_book_by_id(b,cur); FETCH cur INTO x,title_value; DBMS_OUTPUT.PUT_LINE('Get-by-id title='||title_value); CLOSE cur;
  book_management_pkg.search_books('CRUD updated',cur); FETCH cur INTO x,title_value; DBMS_OUTPUT.PUT_LINE('Search title='||title_value); CLOSE cur;
  DBMS_OUTPUT.PUT_LINE('Stock='||book_management_pkg.get_book_stock(b));
  book_management_pkg.delete_book(b,msg); book_management_pkg.delete_member(m,msg); book_management_pkg.delete_publisher(p,msg); book_management_pkg.delete_category(c,msg); book_management_pkg.delete_author(a,msg);
  DBMS_OUTPUT.PUT_LINE('Temporary CRUD rows deleted successfully.');
  ROLLBACK;
END;
/
-- Expected failures (run separately to observe custom -20xxx messages):
-- 1) Duplicate ISBN: call ADD_BOOK with an ISBN already in BOOKS -> -20012.
-- 2) Invalid author/category/publisher ID -> -20013. Missing target ID on update/delete -> -20002.
-- 3) NULL title -> -20001; negative price or stock -> -20011.
-- 4) Delete author/category/publisher/book/member with dependent records -> corresponding -20004/-20006/-20008/-20014/-20010.
-- 5) Constraints are also checked directly by Oracle; see README for ORA codes.

