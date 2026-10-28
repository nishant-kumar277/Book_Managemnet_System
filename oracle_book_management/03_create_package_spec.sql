CREATE OR REPLACE PACKAGE book_management_pkg AS
  PROCEDURE add_author(p_name VARCHAR2,p_email VARCHAR2,p_country VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2);
  PROCEDURE update_author(p_id NUMBER,p_name VARCHAR2,p_email VARCHAR2,p_country VARCHAR2,p_message OUT VARCHAR2);
  PROCEDURE delete_author(p_id NUMBER,p_message OUT VARCHAR2);
  PROCEDURE add_category(p_name VARCHAR2,p_description VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2);
  PROCEDURE update_category(p_id NUMBER,p_name VARCHAR2,p_description VARCHAR2,p_message OUT VARCHAR2);
  PROCEDURE delete_category(p_id NUMBER,p_message OUT VARCHAR2);
  PROCEDURE add_publisher(p_name VARCHAR2,p_address VARCHAR2,p_phone VARCHAR2,p_email VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2);
  PROCEDURE update_publisher(p_id NUMBER,p_name VARCHAR2,p_address VARCHAR2,p_phone VARCHAR2,p_email VARCHAR2,p_message OUT VARCHAR2);
  PROCEDURE delete_publisher(p_id NUMBER,p_message OUT VARCHAR2);
  PROCEDURE add_member(p_name VARCHAR2,p_email VARCHAR2,p_phone VARCHAR2,p_id OUT NUMBER,p_message OUT VARCHAR2);
  PROCEDURE update_member(p_id NUMBER,p_name VARCHAR2,p_email VARCHAR2,p_phone VARCHAR2,p_message OUT VARCHAR2);
  PROCEDURE delete_member(p_id NUMBER,p_message OUT VARCHAR2);
  PROCEDURE add_book(p_title VARCHAR2,p_author_id NUMBER,p_category_id NUMBER,p_publisher_id NUMBER,p_isbn VARCHAR2,p_price NUMBER,p_year NUMBER,p_stock NUMBER,p_id OUT NUMBER,p_message OUT VARCHAR2);
  PROCEDURE get_book_by_id(p_id NUMBER,p_result OUT SYS_REFCURSOR);
  PROCEDURE update_book(p_id NUMBER,p_title VARCHAR2,p_author_id NUMBER,p_category_id NUMBER,p_publisher_id NUMBER,p_isbn VARCHAR2,p_price NUMBER,p_year NUMBER,p_stock NUMBER,p_message OUT VARCHAR2);
  PROCEDURE delete_book(p_id NUMBER,p_message OUT VARCHAR2);
  PROCEDURE list_books(p_result OUT SYS_REFCURSOR);
  PROCEDURE search_books(p_text VARCHAR2,p_result OUT SYS_REFCURSOR);
  FUNCTION get_book_stock(p_book_id NUMBER) RETURN NUMBER;
  FUNCTION get_total_books RETURN NUMBER;
  FUNCTION get_inventory_value RETURN NUMBER;
  FUNCTION get_overdue_book_count RETURN NUMBER;
  PROCEDURE issue_book(p_book_id NUMBER,p_member_id NUMBER,p_due_date DATE,p_issue_id OUT NUMBER,p_message OUT VARCHAR2);
  PROCEDURE return_book(p_issue_id NUMBER,p_message OUT VARCHAR2);
END book_management_pkg;
/

