insert into account (account_id, name, balance)
values
  (1, 'jim', 0), 
  (2, 'anne', 0);
select * from account;

\echo This fails as it is not balanced
select * from insert_postings('failing test'::text, array[row(1, 10), row(2, -20)]::posting_primative[]);

\echo Inserting
select * from insert_postings('passing test'::text, array[row(1, 10), row(2, -10)]::posting_primative[]);

\echo After Insert
select * from journal;
select * from posting;
select * from account;

