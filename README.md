# pgdea
Double Entry Accounting using PostgreSQL 10 triggers and transition tables.

This version should have gapless sequences.

Notices are raised on overdrawn accounts.

No guarentee is given to preformance.

Use `make` to install to a test db and run the test

## Examples

Insert accounts

    insert into account (account_id, name, balance)
    values
      (1, 'Olive Oyl', 0),
      (2, 'J. Wellington Wimpy', 0)
    returning *;

     account_id |        name         | balance
    ------------+---------------------+---------
              1 | Olive Oyl           |       0
              2 | J. Wellington Wimpy |       0
    (2 rows)


Insert an unbalanced posting. Note that this fails and gives the list of descriptions that failed.

    select * from insert_postings('failing test'::text, array[row(1, 10), row(2, -20)]::posting_primative[]);


    ERROR:  Journal Entries "failing test" Not Balanced
    CONTEXT:  PL/pgSQL function function_check_zero_balance_journal_entry() line 12 at RAISE
    PL/pgSQL function insert_postings(text,posting_primative[]) line 3 at RETURN QUERY


Insert a balanced posting. Note the notice on the overdrawn account, but lets the transaction happen.

    select * from insert_postings('passing test'::text, array[row(1, -10), row(2, 10)]::posting_primative[]);

    NOTICE:  Overdrawn Accounts: 2
     posting_id | entry_id | account_id | amount 
    ------------+----------+------------+--------
              1 |        1 |          1 |    -10
              2 |        1 |          2 |     10
    (2 rows)

 Let's just look at everything.

    select * from journal;

     entry_id | description  |         created_at         
    ----------+--------------+----------------------------
            1 | passing test | 2018-10-12 22:02:17.233009
    (1 row)

    select * from posting;

     posting_id | entry_id | account_id | amount 
    ------------+----------+------------+--------
              1 |        1 |          1 |    -10
              2 |        1 |          2 |     10
    (2 rows)

    select * from account;

     account_id |        name         | balance
    ------------+---------------------+---------
              1 | Olive Oyl           |     -10
              2 | J. Wellington Wimpy |      10
    (2 rows)
