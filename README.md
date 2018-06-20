# pgdea
Double Entry Accounting using PostgreSQL 10 triggers and transition tables.

Set up the database.

    % sudo -u postgres dropdb pgdea;
    dropdb: database removal failed: ERROR:  database "pgdea" does not exist
    % sudo -u postgres createdb pgdea;
    % cat schema.sql | sudo -u postgres psql pgdea
    CREATE TABLE
    CREATE TABLE
    CREATE TABLE
    CREATE FUNCTION
    CREATE TRIGGER

Look at the schema (not shown) and test definition.

    % cat test.sql
    insert into account (name) values ('jim'), ('anne');
    select * from account;

    insert into journal (description) values ('test tx');
    select * from journal;

    -- this fails as it's not balanced
    insert into posting (entry_id, account_id, amount) values (1, 1, 10), (1, 2, 10);
    -- this works as it is balanced
    insert into posting (entry_id, account_id, amount) values (1, 1, 10), (1, 2, -10);
    select * from posting;

Run the test.

    % cat test.sql| sudo -u postgres psql pgdea
    INSERT 0 2
     account_id | name
    ------------+------
              1 | jim
              2 | anne
    (2 rows)

    INSERT 0 1
     entry_id | description |         created_at
    ----------+-------------+----------------------------
            1 | test tx     | 2018-06-19 22:20:00.006885
    (1 row)

    ERROR:  Journal Entries 1 Not Balanced
    CONTEXT:  PL/pgSQL function function_check_zero_balance_journal_entry() line 12 at RAISE
    INSERT 0 2
     posting_id | entry_id | account_id | amount
    ------------+----------+------------+--------
              3 |        1 |          1 |     10
              4 |        1 |          2 |    -10
    (2 rows)

