insert into account (account_id, name, balance)
values
  (1, 'Olive Oyl', 0), 
  (2, 'J. Wellington Wimpy', 0)
returning *;

\echo This fails as it is not balanced
select * from insert_postings('failing test'::text, array[row(1, 10), row(2, -20)]::posting_primative[]);

\echo Inserting
select * from insert_postings('passing test'::text, array[row(1, -10), row(2, 10)]::posting_primative[]);

\echo After Insert
select * from journal;
select * from posting;
select * from account;

