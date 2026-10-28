-- Demo / smoke test. Run after 01 and 02.
SET SERVEROUTPUT ON

DECLARE
  v_user  NUMBER;
  v_order NUMBER;
  c       SYS_REFCURSOR;
  v_title VARCHAR2(200);
  v_copies NUMBER;
  v_rev    NUMBER;
BEGIN
  -- Seed books
  bookstore_pkg.add_book('The Pragmatic Programmer', 'Andrew Hunt', 'Tech', 450, 10);
  bookstore_pkg.add_book('Clean Code', 'Robert Martin', 'Tech', 500, 5);
  bookstore_pkg.add_book('Wings of Fire', 'A.P.J. Abdul Kalam', 'Biography', 250, 20);

  -- Register + login
  bookstore_pkg.register_user('Test User', 'test@example.com', 'secret123', 'Jalandhar, Punjab');
  v_user := bookstore_pkg.login('test@example.com', 'secret123');
  DBMS_OUTPUT.PUT_LINE('Logged in user_id = ' || v_user);

  -- Cart + checkout
  bookstore_pkg.add_to_cart(v_user, 1, 2);
  bookstore_pkg.add_to_cart(v_user, 3, 1);
  v_order := bookstore_pkg.checkout(v_user);
  DBMS_OUTPUT.PUT_LINE('Order placed: ' || v_order);

  bookstore_pkg.update_order_status(v_order, 'SHIPPED');

  -- Report: best sellers
  c := bookstore_pkg.best_sellers(3);
  LOOP
    FETCH c INTO v_title, v_copies, v_rev;
    EXIT WHEN c%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_title || ' | sold ' || v_copies || ' | revenue ' || v_rev);
  END LOOP;
  CLOSE c;
END;
/
