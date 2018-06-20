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

    begin;
    insert into journal (description) values ('test tx');
    select * from journal;

    -- this fails as it's not balanced
    insert into posting (entry_id, account_id, amount) values (1, 1, 10), (1, 2, 10);
    commit;

    begin;
    insert into journal (description) values ('test tx');
    select * from journal;
    -- this works as it is balanced
    insert into posting (entry_id, account_id, amount) values (2, 1, 10), (2, 2, -10);
    select * from posting;
    commit;

    begin;
    insert into posting (entry_id, account_id, amount) values (2, 1, 10), (2, 2, -10);
    commit;

Run the test.

    % cat test.sql| sudo -u postgres psql pgdea
     account_id | name
    ------------+------
              1 | jim
              2 | anne
    (2 rows)

    BEGIN
    INSERT 0 1
     entry_id | description |         created_at
    ----------+-------------+----------------------------
            1 | test tx     | 2018-06-19 22:42:01.230601
    (1 row)

    ERROR:  Journal Entries 1 Not Balanced
    CONTEXT:  PL/pgSQL function function_check_zero_balance_journal_entry() line 12 at RAISE
    ROLLBACK
    BEGIN
    INSERT 0 1
     entry_id | description |         created_at
    ----------+-------------+----------------------------
            2 | test tx     | 2018-06-19 22:42:01.234067
    (1 row)

    INSERT 0 2
     posting_id | entry_id | account_id | amount
    ------------+----------+------------+--------
              3 |        2 |          1 |     10
              4 |        2 |          2 |    -10
    (2 rows)

    COMMIT
    BEGIN
    ERROR:  Journal Entries 2 Not Created In This Transaction
    CONTEXT:  PL/pgSQL function function_check_journal_in_this_tx() line 13 at RAISE
    ROLLBACK

