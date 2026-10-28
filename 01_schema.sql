-- Online Bookstore: schema (Oracle 12c+)

CREATE TABLE users (
  user_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name          VARCHAR2(100) NOT NULL,
  email         VARCHAR2(150) NOT NULL UNIQUE,
  password_hash VARCHAR2(64)  NOT NULL,
  address       VARCHAR2(300),
  role          VARCHAR2(10) DEFAULT 'USER' CHECK (role IN ('USER','ADMIN')),
  created_at    DATE DEFAULT SYSDATE
);

CREATE TABLE books (
  book_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title     VARCHAR2(200) NOT NULL,
  author    VARCHAR2(120) NOT NULL,
  category  VARCHAR2(60),
  price     NUMBER(8,2) NOT NULL CHECK (price >= 0),
  quantity  NUMBER DEFAULT 0 CHECK (quantity >= 0)
);

CREATE TABLE cart_items (
  user_id  NUMBER REFERENCES users(user_id) ON DELETE CASCADE,
  book_id  NUMBER REFERENCES books(book_id) ON DELETE CASCADE,
  quantity NUMBER NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (user_id, book_id)
);

CREATE TABLE orders (
  order_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id      NUMBER NOT NULL REFERENCES users(user_id),
  order_date   DATE DEFAULT SYSDATE,
  total_amount NUMBER(10,2),
  status       VARCHAR2(12) DEFAULT 'PENDING'
               CHECK (status IN ('PENDING','PROCESSING','SHIPPED','DELIVERED'))
);

CREATE TABLE order_items (
  order_id NUMBER REFERENCES orders(order_id),
  book_id  NUMBER REFERENCES books(book_id),
  quantity NUMBER NOT NULL,
  price    NUMBER(8,2) NOT NULL,
  PRIMARY KEY (order_id, book_id)
);

CREATE INDEX idx_books_title  ON books(UPPER(title));
CREATE INDEX idx_books_author ON books(UPPER(author));
CREATE INDEX idx_orders_user  ON orders(user_id);
