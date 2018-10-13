# pgdea
Double Entry Accounting using PostgreSQL 10 triggers and transition tables.

This version should have gapless sequences.

Notices are raised on overdrawn accounts.

No guarentee is given to preformance.

Use `make` to install to a test db and run the test

    CREATE TABLE
    CREATE FUNCTION
    CREATE TABLE
    CREATE TABLE
    CREATE TABLE
    CREATE FUNCTION
    CREATE TRIGGER
    CREATE TYPE
    CREATE FUNCTION
    CREATE FUNCTION
    CREATE TRIGGER
    CREATE FUNCTION
    CREATE TRIGGER
    cat test.sql | psql pgdea_test
    INSERT 0 2
     account_id | name | balance 
    ------------+------+---------
              1 | jim  |       0
              2 | anne |       0
    (2 rows)

    This fails as it is not balanced
    ERROR:  Journal Entries 1 Not Balanced
    CONTEXT:  PL/pgSQL function function_check_zero_balance_journal_entry() line 12 at RAISE
    PL/pgSQL function insert_postings(text,posting_primative[]) line 3 at RETURN QUERY


    Inserting
    NOTICE:  Overdrawn Accounts:2
     posting_id | entry_id | account_id | amount 
    ------------+----------+------------+--------
              1 |        1 |          1 |     10
              2 |        1 |          2 |    -10
    (2 rows)

    After Insert
     entry_id | description  |         created_at         
    ----------+--------------+----------------------------
            1 | passing test | 2018-10-12 22:02:17.233009
    (1 row)

     posting_id | entry_id | account_id | amount 
    ------------+----------+------------+--------
              1 |        1 |          1 |     10
              2 |        1 |          2 |    -10
    (2 rows)

     account_id | name | balance 
    ------------+------+---------
              1 | jim  |      10
              2 | anne |     -10
    (2 rows)

