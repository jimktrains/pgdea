insert into account (name) values ('jim'), ('anne');
select * from account;

insert into journal (description) values ('test tx');
select * from journal;

-- this fails as it's not balanced
insert into posting (entry_id, account_id, amount) values (1, 1, 10), (1, 2, 10);
-- this works as it is balanced
insert into posting (entry_id, account_id, amount) values (1, 1, 10), (1, 2, -10);
select * from posting;
