insert into account (account_id, name, balance)
values
  (1, 'Olive Oyl', 0), 
  (2, 'J. Wellington Wimpy', 0),
  (3, 'Popeye', 0)
returning *;

\echo ******************************************
\echo **** This fails as it is not balanced ****
\echo ******************************************
select * from insert_postings('failing test'::text, array[row(1, 10), row(2, -20)]::posting_primative[]);

\echo
\echo ******************************************
\echo **** This is balanced, but overdrawn  ****
\echo ******************************************
select * from insert_postings('passing test'::text, array[row(1, -10), row(2, 10)]::posting_primative[]);

\echo
\echo ******************************************************
\echo **** Three-way transaction, with no (new) overdraw ***
\echo ******************************************************
select * from insert_postings('passing triple test'::text, array[row(1, 5), row(2, -10), row(3, 5)]::posting_primative[]);

\echo
\echo ******************
\echo **** Aftermath ***
\echo ******************
select * from journal;
select * from posting;
select * from account;

