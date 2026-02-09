# Modifying Data

<p id="terms"></p>

## Creating In-memory Database {: .aside}

```{.sh data-file="in_memory_db.sh"}
sqlite3 :memory:
```

-   "Connect" to an [in-memory database](g:in_memory_db)
    -   Changes aren't saved to disk
    -   Very useful for testing (discussed later)

## Creating Tables

```{.sql data-file="create_work_job.sql"}
create table job (
    name text not null,
    billable real not null
);
create table work (
    person text not null,
    job text not null
);
```

-   <code>create table <em>name</em></code> followed by parenthesized list of columns
-   Each column is a name, a data type, and optional extra information
    -   E.g., `not null` prevents nulls from being added
-   `.schema` is *not* standard SQL
-   SQLite has added a few things
    -   `create if not exists`
    -   upper-case keywords (SQL is case insensitive)

## Following Along {: .aside}

-   Use `work_job.db` from the zip file

## Inserting Data

> See also ["Advanced Techniques"](https://github.com/UofT-DSI/sql/blob/main/01_materials/slides/slides_05.pdf)

```{.sql data-file="populate_work_job.sql"}
insert into job values
('calibrate', 1.5),
('clean', 0.5);
insert into work values
('mik', 'calibrate'),
('mik', 'clean'),
('mik', 'complain'),
('po', 'clean'),
('po', 'complain'),
('tay', 'complain');
```
```{.text data-file="show_work_job.memory.out"}
|   name    | billable |
|-----------|----------|
| calibrate | 1.5      |
| clean     | 0.5      |
| person |    job    |
|--------|-----------|
| mik    | calibrate |
| mik    | clean     |
| mik    | complain  |
| po     | clean     |
| po     | complain  |
| tay    | complain  |
```

## Exercise {: .exercise}

Using an in-memory database,
define a table called `notes` with two text columns `author` and `note`
and then add three or four rows.
Use a query to check that the notes have been stored
and that you can (for example) select by author name.

What happens if you try to insert too many or too few values into `notes`?
What happens if you insert a number instead of a string into the `note` field?

## Updating Rows

```{.sql data-file="update_work_job.sql"}
update work
set person = 'tae'
where person = 'tay';
```
```{.text data-file="show_after_update.memory.out"}
| person |    job    |
|--------|-----------|
| mik    | calibrate |
| mik    | clean     |
| mik    | complain  |
| po     | clean     |
| po     | complain  |
| tae    | complain  |
```

-   (Almost) always specify row(s) to update using `where`
    -   Otherwise update all rows in table, which is usually not wanted

## Deleting Rows

```{.sql data-file="delete_rows.memory.sql:keep"}
delete from work
where person = 'tae';

select * from work;
```
```{.text data-file="delete_rows.memory.out"}
| person |    job    |
|--------|-----------|
| mik    | calibrate |
| mik    | clean     |
| mik    | complain  |
| po     | clean     |
| po     | complain  |
```

-   Again, (almost) always specify row(s) to delete using `where`

## Exercise {: .exercise}

What happens if you try to delete rows that don't exist
(e.g., all entries in `work` that refer to `juna`)?

## Backing Up

```{.sql data-file="backing_up.memory.sql:keep"}
create table backup (
    person text not null,
    job text not null
);

insert into backup
select
    person,
    job
from work
where person = 'tae';

delete from work
where person = 'tae';

select * from backup;
```
```{.text data-file="backing_up.memory.out"}
| person |   job    |
|--------|----------|
| tae    | complain |
```

-   We will explore another strategy based on [tombstones](g:tombstone) below

## Exercise {: .exercise}

Saving and restoring data as text:

1.  Re-create the `notes` table in an in-memory database
    and then use SQLite's `.output` and `.dump` commands
    to save the database to a file called `notes.sql`.
    Inspect the contents of this file:
    how has your data been stored?

2.  Start a fresh SQLite session
    and load `notes.sql` using the `.read` command.
    Inspect the database using `.schema` and `select *`:
    is everything as you expected?

Saving and restoring data in binary format:

1.  Re-create the `notes` table in an in-memory database once again
    and use SQLite's `.backup` command to save it to a file called `notes.db`.
    Inspect this file using `od -c notes.db` or a text editor that can handle binary data:
    how has your data been stored?

2.  Start a fresh SQLite session
    and load `notes.db` using the `.restore` command.
    Inspect the database using `.schema` and `select *`:
    is everything as you expected?

## Check Understanding {: .aside}

<figure id="f:core_datamod_concept_map">
  <img src="core_datamod_concept_map.svg" alt="box and arrow diagram of concepts related to defining and modifying data"/>
  <figcaption>Data Definition and Modification Concepts</figcaption>
</figure>
