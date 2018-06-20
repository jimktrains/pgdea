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
