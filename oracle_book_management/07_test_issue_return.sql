-- Run as BOOK_APP after sample data. Executes and rolls back its own test transaction.
SET SERVEROUTPUT ON
DECLARE
  b NUMBER; m NUMBER; issue_no NUMBER; msg VARCHAR2(4000); stock_before NUMBER;
BEGIN
  SELECT book_id,available_stock INTO b,stock_before FROM books WHERE isbn='9780486282114';
  SELECT member_id INTO m FROM members WHERE email='asha.rao@example.test';
  book_management_pkg.issue_book(b,m,TRUNC(SYSDATE)+7,issue_no,msg);
  DBMS_OUTPUT.PUT_LINE(msg||'; issue='||issue_no||'; stock='||book_management_pkg.get_book_stock(b));
  IF book_management_pkg.get_book_stock(b)<>stock_before-1 THEN RAISE_APPLICATION_ERROR(-20990,'Stock decrement check failed'); END IF;
  book_management_pkg.return_book(issue_no,msg); DBMS_OUTPUT.PUT_LINE(msg||'; stock='||book_management_pkg.get_book_stock(b));
  IF book_management_pkg.get_book_stock(b)<>stock_before THEN RAISE_APPLICATION_ERROR(-20991,'Stock restoration check failed'); END IF;
  ROLLBACK;
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
-- Insufficient-stock test (in a fresh transaction): set an unused test book stock to zero,
-- call ISSUE_BOOK, expect -20016, then ROLLBACK. Do not modify a live issued book's stock.
-- Duplicate return: RETURN_BOOK on an already returned issue_id -> -20018.
-- Bad issue ID -> -20002; unknown member -> -20017. Use ROLLBACK after manual test calls.

