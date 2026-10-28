-- Online Bookstore: business logic package

CREATE OR REPLACE PACKAGE bookstore_pkg AS
  -- Users
  PROCEDURE register_user(p_name VARCHAR2, p_email VARCHAR2, p_password VARCHAR2, p_address VARCHAR2);
  FUNCTION  login(p_email VARCHAR2, p_password VARCHAR2) RETURN NUMBER;  -- returns user_id or NULL
  PROCEDURE update_profile(p_user_id NUMBER, p_name VARCHAR2, p_address VARCHAR2);
  -- Books (admin)
  PROCEDURE add_book(p_title VARCHAR2, p_author VARCHAR2, p_category VARCHAR2, p_price NUMBER, p_qty NUMBER);
  PROCEDURE update_book(p_book_id NUMBER, p_price NUMBER, p_qty NUMBER);
  PROCEDURE remove_book(p_book_id NUMBER);
  FUNCTION  search_books(p_text VARCHAR2) RETURN SYS_REFCURSOR;
  -- Cart
  PROCEDURE add_to_cart(p_user_id NUMBER, p_book_id NUMBER, p_qty NUMBER);
  PROCEDURE remove_from_cart(p_user_id NUMBER, p_book_id NUMBER);
  -- Orders
  FUNCTION  checkout(p_user_id NUMBER) RETURN NUMBER;  -- returns order_id
  FUNCTION  order_history(p_user_id NUMBER) RETURN SYS_REFCURSOR;
  PROCEDURE update_order_status(p_order_id NUMBER, p_status VARCHAR2);
  -- Reports
  FUNCTION  best_sellers(p_top NUMBER DEFAULT 5) RETURN SYS_REFCURSOR;
  FUNCTION  sales_by_day RETURN SYS_REFCURSOR;
END bookstore_pkg;
/

CREATE OR REPLACE PACKAGE BODY bookstore_pkg AS

  FUNCTION hash_pw(p_pw VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN RAWTOHEX(STANDARD_HASH(p_pw, 'SHA256'));
  END;

  PROCEDURE register_user(p_name VARCHAR2, p_email VARCHAR2, p_password VARCHAR2, p_address VARCHAR2) IS
  BEGIN
    INSERT INTO users(name, email, password_hash, address)
    VALUES (p_name, LOWER(p_email), hash_pw(p_password), p_address);
    COMMIT;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20001, 'Email already registered');
  END;

  FUNCTION login(p_email VARCHAR2, p_password VARCHAR2) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT user_id INTO v_id FROM users
     WHERE email = LOWER(p_email) AND password_hash = hash_pw(p_password);
    RETURN v_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END;

  PROCEDURE update_profile(p_user_id NUMBER, p_name VARCHAR2, p_address VARCHAR2) IS
  BEGIN
    UPDATE users SET name = p_name, address = p_address WHERE user_id = p_user_id;
    COMMIT;
  END;

  PROCEDURE add_book(p_title VARCHAR2, p_author VARCHAR2, p_category VARCHAR2, p_price NUMBER, p_qty NUMBER) IS
  BEGIN
    INSERT INTO books(title, author, category, price, quantity)
    VALUES (p_title, p_author, p_category, p_price, p_qty);
    COMMIT;
  END;

  PROCEDURE update_book(p_book_id NUMBER, p_price NUMBER, p_qty NUMBER) IS
  BEGIN
    UPDATE books SET price = p_price, quantity = p_qty WHERE book_id = p_book_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'Book not found');
    END IF;
    COMMIT;
  END;

  PROCEDURE remove_book(p_book_id NUMBER) IS
  BEGIN
    DELETE FROM books WHERE book_id = p_book_id;
    COMMIT;
  END;

  FUNCTION search_books(p_text VARCHAR2) RETURN SYS_REFCURSOR IS
    c SYS_REFCURSOR;
  BEGIN
    OPEN c FOR
      SELECT book_id, title, author, category, price, quantity
        FROM books
       WHERE UPPER(title)    LIKE '%' || UPPER(p_text) || '%'
          OR UPPER(author)   LIKE '%' || UPPER(p_text) || '%'
          OR UPPER(category) LIKE '%' || UPPER(p_text) || '%';
    RETURN c;
  END;

  PROCEDURE add_to_cart(p_user_id NUMBER, p_book_id NUMBER, p_qty NUMBER) IS
  BEGIN
    MERGE INTO cart_items c
    USING (SELECT p_user_id u, p_book_id b FROM dual) s
       ON (c.user_id = s.u AND c.book_id = s.b)
     WHEN MATCHED THEN UPDATE SET c.quantity = p_qty
     WHEN NOT MATCHED THEN INSERT (user_id, book_id, quantity) VALUES (p_user_id, p_book_id, p_qty);
    COMMIT;
  END;

  PROCEDURE remove_from_cart(p_user_id NUMBER, p_book_id NUMBER) IS
  BEGIN
    DELETE FROM cart_items WHERE user_id = p_user_id AND book_id = p_book_id;
    COMMIT;
  END;

  FUNCTION checkout(p_user_id NUMBER) RETURN NUMBER IS
    v_order_id NUMBER;
    v_total    NUMBER := 0;
    v_stock    NUMBER;
  BEGIN
    INSERT INTO orders(user_id, total_amount) VALUES (p_user_id, 0)
    RETURNING order_id INTO v_order_id;

    FOR r IN (SELECT c.book_id, c.quantity, b.price
                FROM cart_items c JOIN books b ON b.book_id = c.book_id
               WHERE c.user_id = p_user_id) LOOP
      SELECT quantity INTO v_stock FROM books WHERE book_id = r.book_id FOR UPDATE;
      IF v_stock < r.quantity THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Not enough stock for book ' || r.book_id);
      END IF;
      UPDATE books SET quantity = quantity - r.quantity WHERE book_id = r.book_id;
      INSERT INTO order_items VALUES (v_order_id, r.book_id, r.quantity, r.price);
      v_total := v_total + r.quantity * r.price;
    END LOOP;

    IF v_total = 0 THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20004, 'Cart is empty');
    END IF;

    UPDATE orders SET total_amount = v_total WHERE order_id = v_order_id;
    DELETE FROM cart_items WHERE user_id = p_user_id;
    COMMIT;
    RETURN v_order_id;
  END;

  FUNCTION order_history(p_user_id NUMBER) RETURN SYS_REFCURSOR IS
    c SYS_REFCURSOR;
  BEGIN
    OPEN c FOR
      SELECT o.order_id, o.order_date, o.status, o.total_amount,
             b.title, i.quantity, i.price
        FROM orders o
        JOIN order_items i ON i.order_id = o.order_id
        JOIN books b       ON b.book_id  = i.book_id
       WHERE o.user_id = p_user_id
       ORDER BY o.order_date DESC, o.order_id DESC;
    RETURN c;
  END;

  PROCEDURE update_order_status(p_order_id NUMBER, p_status VARCHAR2) IS
  BEGIN
    UPDATE orders SET status = UPPER(p_status) WHERE order_id = p_order_id;
    COMMIT;
  END;

  FUNCTION best_sellers(p_top NUMBER DEFAULT 5) RETURN SYS_REFCURSOR IS
    c SYS_REFCURSOR;
  BEGIN
    OPEN c FOR
      SELECT * FROM (
        SELECT b.title, SUM(i.quantity) AS copies_sold, SUM(i.quantity * i.price) AS revenue
          FROM order_items i JOIN books b ON b.book_id = i.book_id
         GROUP BY b.title
         ORDER BY copies_sold DESC)
       WHERE ROWNUM <= p_top;
    RETURN c;
  END;

  FUNCTION sales_by_day RETURN SYS_REFCURSOR IS
    c SYS_REFCURSOR;
  BEGIN
    OPEN c FOR
      SELECT TRUNC(order_date) AS day, COUNT(*) AS orders, SUM(total_amount) AS revenue
        FROM orders GROUP BY TRUNC(order_date) ORDER BY day;
    RETURN c;
  END;

END bookstore_pkg;
/
