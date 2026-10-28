-- Run as an authorized DBA in the target PDB, not as BOOK_APP.
-- Replace the password and USERS tablespace/quota to match your installation.
CREATE USER BOOK_APP IDENTIFIED BY "ChangeThis_StrongPassword1"
  DEFAULT TABLESPACE USERS QUOTA 100M ON USERS;
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE TRIGGER TO BOOK_APP;

