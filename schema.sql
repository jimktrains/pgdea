create table serialvalues (
  table_name text primary key,
  counter bigint not null
);

create or replace function function_nextserial(tname text)
returns bigint
as $$
declare
  c bigint;
begin
  insert into serialvalues (table_name, counter)
  values (tname, 1)
  on conflict (table_name) do update set counter = serialvalues.counter + 1
  returning counter into c;

  return c;
end;
$$ language plpgsql;

create table account (
  account_id bigserial primary key,
  name text not null unique,
  balance bigint not null
);

create table journal (
  entry_id bigint default function_nextserial('journal') primary key,
  description text,
  created_at timestamp not null default current_timestamp
);

create table posting (
  posting_id bigint default function_nextserial('posting') primary key,
  entry_id bigint not null references journal,
  account_id bigint not null references account,
  amount bigint not null
);

create or replace function function_check_zero_balance_journal_entry ()
returns trigger
as $$
declare
  unbalanced_entries text;
begin
  select string_agg(description, '", "') into unbalanced_entries
    from (
      select min(description) as description
      from new_postings
      join journal
        on journal.entry_id = new_postings.entry_id
      group by journal.entry_id
      having sum(amount) <> 0
    ) x;
  if unbalanced_entries is not null then
   raise exception 'Journal Entries "%" Not Balanced', unbalanced_entries;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trigger_check_zero_balance_journal_entry
after insert
on posting
referencing new table as new_postings
for each statement
execute procedure function_check_zero_balance_journal_entry();

create type posting_primative as (account_id int, amount bigint);

create or replace function insert_postings(descrip text, postings posting_primative[])
returns setof posting
as $$
begin
  return query with journal_entry as (
    insert into journal (description) values (descrip) returning entry_id
  )
  insert into posting (entry_id, account_id, amount)
    select entry_id, account_id, amount
    from journal_entry
    cross join unnest(postings)
  returning *;
end;
$$ language plpgsql;

create or replace function function_check_overdrawn_account ()
returns trigger
as $$
declare
  overdrawn_account text;
begin
  select string_agg(account_id::text, ', ') into overdrawn_account 
    from (select new_account.account_id
      from new_account
      left join old_account
        on new_account.account_id = old_account.account_id
      where new_account.balance < 0 and old_account.balance >= 0
    ) x;
  if overdrawn_account is not null then
   raise notice 'Overdrawn Accounts: %', overdrawn_account;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trigger_check_overdrawn_account
after update
on account
referencing new table as new_account old table as old_account
for each statement
execute procedure function_check_overdrawn_account();

create or replace function function_update_account_balance()
returns trigger
as $$
declare
  unbalanced_entries text;
begin
  update account
  set balance = account.balance + new_postings.amount
  from new_postings
  where new_postings.account_id = account.account_id;

  return new;
end;
$$ language plpgsql;

create trigger trigger_update_account_balance
after insert
on posting
referencing new table as new_postings
for each statement
execute procedure function_update_account_balance();
