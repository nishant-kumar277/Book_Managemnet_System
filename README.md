# Online Bookstore Management System (Oracle PL/SQL + Flask)

Users, books, cart, orders and reports. All business logic lives in PL/SQL (`bookstore_pkg`); the Flask app is a thin web UI on top.

## Structure
```
bookstore/
├── 01_schema.sql      tables, constraints, indexes
├── 02_package.sql     bookstore_pkg (all business logic)
├── 03_demo.sql        optional sample data + smoke test
├── 04_admin.sql       creates admin@bookstore.com / admin123
├── app.py             Flask web app
├── requirements.txt
└── templates/         base, login, register, profile, index, cart, orders, admin, reports
```

## Setup
1. **Database** (Oracle XE 21c is free). As a DBA, create the app user:
   ```sql
   CREATE USER bookstore IDENTIFIED BY bookstore QUOTA UNLIMITED ON USERS;
   GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO bookstore;
   ```
2. Connect as `bookstore` in VS Code (Oracle SQL Developer extension) and run, in order:
   `01_schema.sql` → `02_package.sql` → `04_admin.sql` (and optionally `03_demo.sql`).
   Note: `03_demo.sql` registers `test@example.com`, so skip it if you want a clean database.
3. **Web app:**
   ```bash
   python -m venv venv
   venv\Scripts\activate          # Windows  (Linux/Mac: source venv/bin/activate)
   pip install -r requirements.txt
   python app.py
   ```
4. Open http://127.0.0.1:5000 and log in as `admin@bookstore.com` / `admin123`.

Optional environment variables: `DB_USER`, `DB_PASSWORD`, `DB_DSN` (default `localhost:1521/XEPDB1`), `SECRET_KEY`.

## Features
- **Users:** register, login, update profile
- **Books (admin):** add, update price/stock, remove; search by title, author or category
- **Cart:** add, update quantity, remove, checkout
- **Orders:** history with items and totals; admin updates status (pending → processing → shipped → delivered)
- **Reports (admin):** best sellers, sales by day

## Security notes
- Passwords are stored as SHA-256 hashes (use salted hashing in production).
- Everything goes through bind variables and PL/SQL parameters, so there is no dynamic SQL and no SQL injection.
- Checkout locks stock rows (`FOR UPDATE`) to avoid overselling.
- Change the default admin password and `SECRET_KEY` before deploying.
