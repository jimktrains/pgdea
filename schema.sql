create table account (
  account_id bigserial primary key,
  name text not null unique
);

create table journal (
  entry_id bigserial primary key,
  description text,
  created_at timestamp not null default current_timestamp
);

create table posting (
  -- Yes, this might have gaps :(
  posting_id bigserial primary key,
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
  select string_agg(entry_id::text, ', ') into unbalanced_entries
    from (select entry_id
      from new_postings
      group by entry_id
      having sum(amount) <> 0
    ) x;
  if unbalanced_entries is not null then
   raise exception 'Journal Entries % Not Balanced', unbalanced_entries;
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

create or replace function function_check_journal_in_this_tx()
returns trigger
as $$
declare
  unbalanced_entries text;
begin
  select string_agg(entry_id::text, ', ') into unbalanced_entries
    from (select entry_id
      from journal
      where
            entry_id IN (select entry_id from new_postings)
        and xmin::text <> txid_current()::text
    ) x;
  if unbalanced_entries is not null then
   raise exception 'Journal Entries % Not Created In This Transaction', unbalanced_entries;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trigger_check_journal_in_this_tx
after insert
on posting
referencing new table as new_postings
for each statement
execute procedure function_check_journal_in_this_tx();
