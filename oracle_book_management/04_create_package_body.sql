CREATE OR REPLACE PACKAGE BODY book_management_pkg AS
  PROCEDURE require_text(p_value VARCHAR2,p_label VARCHAR2) IS
  BEGIN
    IF p_value IS NULL OR LENGTH(TRIM(p_value))=0 THEN RAISE_APPLICATION_ERROR(-20001,p_label||' is required'); END IF;
  END;
  PROCEDURE check_row(p_count NUMBER,p_label VARCHAR2) IS
  BEGIN
    IF p_count=0 THEN RAISE_APPLICATION_ERROR(-20002,p_label||' not found'); END IF;
  END;

  PROCEDURE add_author(p_name VARCHAR2,p_email VARCHAR2,p_country VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Author name'); INSERT INTO authors(author_name,email,country) VALUES(TRIM(p_name),LOWER(TRIM(p_email)),p_country) RETURNING author_id INTO p_id; p_message:='Author created';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20003,'Author email already exists'); END;
  PROCEDURE update_author(p_id NUMBER,p_name VARCHAR2,p_email VARCHAR2,p_country VARCHAR2,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Author name'); UPDATE authors SET author_name=TRIM(p_name),email=LOWER(TRIM(p_email)),country=p_country WHERE author_id=p_id; check_row(SQL%ROWCOUNT,'Author'); p_message:='Author updated';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20003,'Author email already exists'); END;
  PROCEDURE delete_author(p_id NUMBER,p_message OUT VARCHAR2) IS
  BEGIN DELETE FROM authors WHERE author_id=p_id; check_row(SQL%ROWCOUNT,'Author'); p_message:='Author deleted';
  EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002,'Author not found'); WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20004,'Cannot delete author while books refer to it'); ELSE RAISE; END IF; END;

  PROCEDURE add_category(p_name VARCHAR2,p_description VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Category name'); INSERT INTO categories(category_name,description) VALUES(TRIM(p_name),p_description) RETURNING category_id INTO p_id; p_message:='Category created';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20005,'Category name already exists'); END;
  PROCEDURE update_category(p_id NUMBER,p_name VARCHAR2,p_description VARCHAR2,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Category name'); UPDATE categories SET category_name=TRIM(p_name),description=p_description WHERE category_id=p_id; check_row(SQL%ROWCOUNT,'Category'); p_message:='Category updated';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20005,'Category name already exists'); END;
  PROCEDURE delete_category(p_id NUMBER,p_message OUT VARCHAR2) IS
  BEGIN DELETE FROM categories WHERE category_id=p_id; check_row(SQL%ROWCOUNT,'Category'); p_message:='Category deleted';
  EXCEPTION WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20006,'Cannot delete category while books refer to it'); ELSE RAISE; END IF; END;

  PROCEDURE add_publisher(p_name VARCHAR2,p_address VARCHAR2,p_phone VARCHAR2,p_email VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Publisher name'); INSERT INTO publishers(publisher_name,address,contact_number,email) VALUES(TRIM(p_name),p_address,p_phone,LOWER(TRIM(p_email))) RETURNING publisher_id INTO p_id; p_message:='Publisher created';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20007,'Publisher email already exists'); END;
  PROCEDURE update_publisher(p_id NUMBER,p_name VARCHAR2,p_address VARCHAR2,p_phone VARCHAR2,p_email VARCHAR2,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Publisher name'); UPDATE publishers SET publisher_name=TRIM(p_name),address=p_address,contact_number=p_phone,email=LOWER(TRIM(p_email)) WHERE publisher_id=p_id; check_row(SQL%ROWCOUNT,'Publisher'); p_message:='Publisher updated';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20007,'Publisher email already exists'); END;
  PROCEDURE delete_publisher(p_id NUMBER,p_message OUT VARCHAR2) IS
  BEGIN DELETE FROM publishers WHERE publisher_id=p_id; check_row(SQL%ROWCOUNT,'Publisher'); p_message:='Publisher deleted';
  EXCEPTION WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20008,'Cannot delete publisher while books refer to it'); ELSE RAISE; END IF; END;

  PROCEDURE add_member(p_name VARCHAR2,p_email VARCHAR2,p_phone VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Member name'); require_text(p_email,'Member email'); INSERT INTO members(member_name,email,phone_number) VALUES(TRIM(p_name),LOWER(TRIM(p_email)),p_phone) RETURNING member_id INTO p_id; p_message:='Member created';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20009,'Member email already exists'); END;
  PROCEDURE update_member(p_id NUMBER,p_name VARCHAR2,p_email VARCHAR2,p_phone VARCHAR2,p_message OUT VARCHAR2) IS
  BEGIN require_text(p_name,'Member name'); require_text(p_email,'Member email'); UPDATE members SET member_name=TRIM(p_name),email=LOWER(TRIM(p_email)),phone_number=p_phone WHERE member_id=p_id; check_row(SQL%ROWCOUNT,'Member'); p_message:='Member updated';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20009,'Member email already exists'); END;
  PROCEDURE delete_member(p_id NUMBER,p_message OUT VARCHAR2) IS
  BEGIN DELETE FROM members WHERE member_id=p_id; check_row(SQL%ROWCOUNT,'Member'); p_message:='Member deleted';
  EXCEPTION WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20010,'Cannot delete member; issue history is retained'); ELSE RAISE; END IF; END;

  PROCEDURE add_book(p_title VARCHAR2,p_author_id NUMBER,p_category_id NUMBER,p_publisher_id NUMBER,p_isbn VARCHAR2,p_price NUMBER,p_year NUMBER,p_stock NUMBER,p_id OUT NUMBER,p_message OUT VARCHAR2) IS
  BEGIN
    require_text(p_title,'Title'); require_text(p_isbn,'ISBN');
    IF p_price IS NULL OR p_price<0 OR p_stock IS NULL OR p_stock<0 THEN RAISE_APPLICATION_ERROR(-20011,'Price and stock must be nonnegative'); END IF;
    INSERT INTO books(title,author_id,category_id,publisher_id,isbn,price,publication_year,available_stock) VALUES(TRIM(p_title),p_author_id,p_category_id,p_publisher_id,TRIM(p_isbn),p_price,p_year,p_stock) RETURNING book_id INTO p_id; p_message:='Book created';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20012,'ISBN already exists'); WHEN OTHERS THEN IF SQLCODE=-2291 THEN RAISE_APPLICATION_ERROR(-20013,'Author, category, or publisher ID does not exist'); ELSE RAISE; END IF; END;
  PROCEDURE get_book_by_id(p_id NUMBER,p_result OUT SYS_REFCURSOR) IS
  BEGIN OPEN p_result FOR SELECT b.book_id,b.title,b.author_id,a.author_name,b.category_id,c.category_name,b.publisher_id,p.publisher_name,b.isbn,b.price,b.publication_year,b.available_stock FROM books b JOIN authors a ON a.author_id=b.author_id JOIN categories c ON c.category_id=b.category_id JOIN publishers p ON p.publisher_id=b.publisher_id WHERE b.book_id=p_id; END;
  PROCEDURE update_book(p_id NUMBER,p_title VARCHAR2,p_author_id NUMBER,p_category_id NUMBER,p_publisher_id NUMBER,p_isbn VARCHAR2,p_price NUMBER,p_year NUMBER,p_stock NUMBER,p_message OUT VARCHAR2) IS
  BEGIN
    require_text(p_title,'Title'); require_text(p_isbn,'ISBN'); IF p_price IS NULL OR p_price<0 OR p_stock IS NULL OR p_stock<0 THEN RAISE_APPLICATION_ERROR(-20011,'Price and stock must be nonnegative'); END IF;
    UPDATE books SET title=TRIM(p_title),author_id=p_author_id,category_id=p_category_id,publisher_id=p_publisher_id,isbn=TRIM(p_isbn),price=p_price,publication_year=p_year,available_stock=p_stock WHERE book_id=p_id; check_row(SQL%ROWCOUNT,'Book'); p_message:='Book updated';
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20012,'ISBN already exists'); WHEN OTHERS THEN IF SQLCODE=-2291 THEN RAISE_APPLICATION_ERROR(-20013,'Author, category, or publisher ID does not exist'); ELSE RAISE; END IF; END;
  PROCEDURE delete_book(p_id NUMBER,p_message OUT VARCHAR2) IS
  BEGIN DELETE FROM books WHERE book_id=p_id; check_row(SQL%ROWCOUNT,'Book'); p_message:='Book deleted';
  EXCEPTION WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20014,'Cannot delete book with issue history'); ELSE RAISE; END IF; END;
  PROCEDURE list_books(p_result OUT SYS_REFCURSOR) IS
  BEGIN OPEN p_result FOR SELECT b.book_id,b.title,a.author_name,c.category_name,p.publisher_name,b.isbn,b.price,b.publication_year,b.available_stock FROM books b JOIN authors a ON a.author_id=b.author_id JOIN categories c ON c.category_id=b.category_id JOIN publishers p ON p.publisher_id=b.publisher_id ORDER BY b.title; END;
  PROCEDURE search_books(p_text VARCHAR2,p_result OUT SYS_REFCURSOR) IS
  BEGIN OPEN p_result FOR SELECT b.book_id,b.title,a.author_name,c.category_name,p.publisher_name,b.isbn,b.price,b.available_stock FROM books b JOIN authors a ON a.author_id=b.author_id JOIN categories c ON c.category_id=b.category_id JOIN publishers p ON p.publisher_id=b.publisher_id WHERE UPPER(b.title) LIKE '%'||UPPER(p_text)||'%' OR UPPER(b.isbn) LIKE '%'||UPPER(p_text)||'%' OR UPPER(a.author_name) LIKE '%'||UPPER(p_text)||'%' OR UPPER(c.category_name) LIKE '%'||UPPER(p_text)||'%' ORDER BY b.title; END;
  FUNCTION get_book_stock(p_book_id NUMBER) RETURN NUMBER IS v NUMBER; BEGIN SELECT available_stock INTO v FROM books WHERE book_id=p_book_id; RETURN v; EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002,'Book not found'); END;
  FUNCTION get_total_books RETURN NUMBER IS v NUMBER; BEGIN SELECT COUNT(*) INTO v FROM books; RETURN v; END;
  FUNCTION get_inventory_value RETURN NUMBER IS v NUMBER; BEGIN SELECT NVL(SUM(price*available_stock),0) INTO v FROM books; RETURN v; END;
  FUNCTION get_overdue_book_count RETURN NUMBER IS v NUMBER; BEGIN SELECT COUNT(*) INTO v FROM book_issues WHERE issue_status='ISSUED' AND due_date<TRUNC(SYSDATE); RETURN v; END;
  PROCEDURE issue_book(p_book_id NUMBER,p_member_id NUMBER,p_due_date DATE,p_issue_id OUT NUMBER,p_message OUT VARCHAR2) IS v_stock NUMBER;
  BEGIN
    SAVEPOINT issue_start;
    IF p_due_date IS NULL OR TRUNC(p_due_date)<TRUNC(SYSDATE) THEN RAISE_APPLICATION_ERROR(-20015,'Due date must be today or later'); END IF;
    SELECT available_stock INTO v_stock FROM books WHERE book_id=p_book_id FOR UPDATE;
    IF v_stock<1 THEN RAISE_APPLICATION_ERROR(-20016,'Insufficient stock'); END IF;
    UPDATE books SET available_stock=available_stock-1 WHERE book_id=p_book_id;
    INSERT INTO book_issues(book_id,member_id,issue_date,due_date) VALUES(p_book_id,p_member_id,SYSDATE,p_due_date) RETURNING issue_id INTO p_issue_id; p_message:='Book issued';
  EXCEPTION WHEN NO_DATA_FOUND THEN ROLLBACK TO issue_start; RAISE_APPLICATION_ERROR(-20002,'Book not found'); WHEN OTHERS THEN ROLLBACK TO issue_start; IF SQLCODE=-2291 THEN RAISE_APPLICATION_ERROR(-20017,'Member does not exist'); ELSE RAISE; END IF; END;
  PROCEDURE return_book(p_issue_id NUMBER,p_message OUT VARCHAR2) IS v_book NUMBER; v_status VARCHAR2(12);
  BEGIN
    SELECT book_id,issue_status INTO v_book,v_status FROM book_issues WHERE issue_id=p_issue_id FOR UPDATE;
    IF v_status<>'ISSUED' THEN RAISE_APPLICATION_ERROR(-20018,'Issue was already returned'); END IF;
    UPDATE book_issues SET return_date=SYSDATE,issue_status='RETURNED' WHERE issue_id=p_issue_id;
    UPDATE books SET available_stock=available_stock+1 WHERE book_id=v_book; p_message:='Book returned';
  EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002,'Issue record not found'); END;
END book_management_pkg;
/

