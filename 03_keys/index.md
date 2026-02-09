# Keys

<p id="terms"></p>

## Defining a Primary Key

-   Can use any field (or combination of fields) in a table as a [primary key](g:primary_key)
    as long as value(s) unique for each record
-   Uniquely identifies a particular record in a particular table

```{.sql data-file="primary_key.sql"}
create table lab_equipment (
    size real not null,
    color text not null,
    num integer not null,
    primary key (size, color)
);

insert into lab_equipment values
(1.5, 'blue', 2),
(1.5, 'green', 1),
(2.5, 'blue', 1);

select * from lab_equipment;

insert into lab_equipment values
(1.5, 'green', 2);
```
```{.text data-file="primary_key.out"}
| size | color | num |
|------|-------|-----|
| 1.5  | blue  | 2   |
| 1.5  | green | 1   |
| 2.5  | blue  | 1   |
Runtime error near line 17: UNIQUE constraint failed: lab_equipment.size, lab_equipment.color (19)
```

## Exercise {: .exercise}

Does the `penguins` table have a primary key?
If so, what is it?
What about the `work` and `job` tables?

## Autoincrementing and Primary Keys

```{.sql data-file="autoincrement.sql"}
create table person (
    ident integer primary key autoincrement,
    name text not null
);
insert into person values
(null, 'mik'),
(null, 'po'),
(null, 'tay');
select * from person;
insert into person values (1, 'prevented');
```
```{.text data-file="autoincrement.out"}
| ident | name |
|-------|------|
| 1     | mik  |
| 2     | po   |
| 3     | tay  |
Runtime error near line 12: UNIQUE constraint failed: person.ident (19)
```

-   Database [autoincrements](g:autoincrement) `ident` each time a new record is added
-   Common to use that field as the primary key
    -   Unique for each record
-   If Mik changes their name again,
    we only have to change one fact in the database
-   Downside: manual queries are harder to read (who is person 17?)

## Internal Tables {: .aside}

```{.sql data-file="sequence_table.memory.sql:keep"}
select * from sqlite_sequence;
```
```{.text data-file="sequence_table.memory.out"}
|  name  | seq |
|--------|-----|
| person | 3   |
```

-   Sequence numbers are *not* reset when rows are deleted
    -   In part so that they can be used as primary keys

## M-to-N Relationships {: .aside}

-   Relationships between entities are usually characterized as:
    -   [1-to-1](g:1_to_1):
        fields in the same record
    -   [1-to-many](g:1_to_many):
        the many have a [foreign key](g:foreign_key) referring to the one's primary key
    -   [many-to-many](g:many_to_many):
        don't know how many keys to add to records ("maximum" never is)
-   Nearly-universal solution is a [join table](g:join_table)
    -   Each record is a pair of foreign keys
    -   I.e., each record is the fact that records A and B are related

## Exercise {: .exercise}

Are you able to modify the values stored in `sqlite_sequence`?
In particular,
are you able to reset the values so that
the same sequence numbers are generated again?
