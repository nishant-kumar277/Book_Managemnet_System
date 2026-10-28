-- Creates the admin account: admin@bookstore.com / admin123
BEGIN
  bookstore_pkg.register_user('Admin', 'admin@bookstore.com', 'admin123', 'HQ');
  UPDATE users SET role = 'ADMIN' WHERE email = 'admin@bookstore.com';
  COMMIT;
END;
/
