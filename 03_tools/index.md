# Tools

<p id="terms"></p>

## Altering Tables

```{.sql data-file="alter_tables.sql:keep"}
alter table job
add ident integer not null default -1;

update job
set ident = 1
where name = 'calibrate';

update job
set ident = 2
where name = 'clean';

select * from job;
```
```{.text data-file="alter_tables.out"}
|   name    | billable | ident |
|-----------|----------|-------|
| calibrate | 1.5      | 1     |
| clean     | 0.5      | 2     |
```

-   Add a column after the fact
-   Since it can't be null, we have to provide a default value
    -   Really want to make it the primary key, but SQLite doesn't allow that after the fact
-   Then use `update` to modify existing records
    -   Can modify any number of records at once
    -   So be careful about `where` clause
-   An example of [data migration](g:data_migration)

## Creating New Tables from Old

```{.sql data-file="insert_select.sql:keep"}
create table new_work (
    person_id integer not null,
    job_id integer not null,
    foreign key (person_id) references person (ident),
    foreign key (job_id) references job (ident)
);

insert into new_work
select
    person.ident as person_id,
    job.ident as job_id
from
    (person inner join work on person.name = work.person)
    inner join job on job.name = work.job;
select * from new_work;
```
```{.text data-file="insert_select.out"}
| person_id | job_id |
|-----------|--------|
| 1         | 1      |
| 1         | 2      |
| 2         | 2      |
```

-   `new_work` is our join table
-   Each column refers to a record in some other table

## Removing Tables

```{.sql data-file="drop_table.sql:keep"}
drop table work;
alter table new_work rename to work;
```
```{.text data-file="drop_table.out"}
CREATE TABLE job (
    ident integer primary key autoincrement,
    name text not null,
    billable real not null
);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE person (
    ident integer primary key autoincrement,
    name text not null
);
CREATE TABLE IF NOT EXISTS "work" (
    person_id integer not null,
    job_id integer not null,
    foreign key(person_id) references person(ident),
    foreign key(job_id) references job(ident)
);
```

-   Remove the old table and rename the new one to take its place
    -   Note `if exists`
-   Please back up your data first

## Exercise {: .exercise}

1.  Reorganize the penguins database:
    1.  Make a copy of the `penguins.db` file
        so that your changes won't affect the original.
    2.  Write a SQL script that reorganizes the data into three tables:
        one for each island.
    3.  Why is organizing data like this a bad idea?

2.  Tools like [Sqitch][sqitch] can manage changes to database schemas and data
    so that they can be saved in version control
    and rolled back if they are unsuccessful.
    Translate the changes made by the scripts above into Sqitch.
    Note: this exercise may take an hour or more.

## Explaining Query Plans {: .aside}

```{.sql data-file="explain_query_plan.penguins.sql"}
explain query plan
select
    species,
    avg(body_mass_g)
from penguins
group by species;
```
```{.text data-file="explain_query_plan.penguins.out"}
QUERY PLAN
|--SCAN penguins
`--USE TEMP B-TREE FOR GROUP BY
```

-   SQLite plans to scan every row of the table
-   It will build a temporary [B-tree data structure](g:b_tree) to group rows

## Exercise {: .exercise}

Use a CTE to find
the number of penguins
that weigh the same as the lightest penguin of the same sex and species.

## Enumerating Rows

-   Every table has a special column called `rowid`

```{.sql data-file="rowid.penguins.sql"}
select
    rowid,
    species,
    island
from penguins
limit 5;
```
```{.text data-file="rowid.penguins.out"}
| rowid | species |  island   |
|-------|---------|-----------|
| 1     | Adelie  | Torgersen |
| 2     | Adelie  | Torgersen |
| 3     | Adelie  | Torgersen |
| 4     | Adelie  | Torgersen |
| 5     | Adelie  | Torgersen |
```

-   `rowid` is persistent within a session
    -   I.e., if we delete the first 5 rows we now have row IDs 6…N
-   *Do not rely on row ID*
    -   In particular, do not use it as a key

## Exercise {: .exercise}

To explore how row IDs behave:

1.  Suppose that you create a new table,
    add three rows,
    delete those rows,
    and add the same values again.
    Do you expect the row IDs of the final rows to be 1–3 or 4–6?

2.  Using an in-memory database,
    perform the steps in part 1.
    Was the result what you expected?

## Yet Another Database {: .aside}

-   [Entity-relationship diagram](g:er_diagram) (ER diagram) shows relationships between tables
-   Like everything to do with databases, there are lots of variations

<figure id="f:assays_er">
  <img src="tools_assays_er.svg" alt="entity-relationship diagram showing logical structure of assay database"/>
  <figcaption>Assay ER Diagram</figcaption>
</figure>

<figure id="f:tools_assays_tables">
  <img src="tools_assays_tables.svg" alt="table-level diagram of assay database showing primary and foreign key relationships"/>
  <figcaption>Assay Database Table Diagram</figcaption>
</figure>

```{.sql data-file="assay_staff.assays.sql"}
select * from staff;
```
```{.text data-file="assay_staff.assays.out"}
| ident | personal |  family   | dept | age |
|-------|----------|-----------|------|-----|
| 1     | Kartik   | Gupta     |      | 46  |
| 2     | Divit    | Dhaliwal  | hist | 34  |
| 3     | Indrans  | Sridhar   | mb   | 47  |
| 4     | Pranay   | Khanna    | mb   | 51  |
| 5     | Riaan    | Dua       |      | 23  |
| 6     | Vedika   | Rout      | hist | 45  |
| 7     | Abram    | Chokshi   | gen  | 23  |
| 8     | Romil    | Kapoor    | hist | 38  |
| 9     | Ishaan   | Ramaswamy | mb   | 35  |
| 10    | Nitya    | Lal       | gen  | 52  |
```

## Exercise {: .exercise}

Draw a table diagram and an ER diagram to represent the following database:

-   `person` has `id` and `full_name`
-   `course` has `id` and `name`
-   `section` has `course_id`, `start_date`, and `end_date`
-   `instructor` has `person_id` and `section_id`
-   `student` has `person_id`, `section_id`, and `status`

## Pattern Matching

```{.sql data-file="like_glob.assays.sql"}
select
    personal,
    family
from staff
where personal like '%ya%';
```
```{.text data-file="like_glob.assays.out"}
| personal | family |
|----------|--------|
| Nitya    | Lal    |
```

-   `like` is the original SQL pattern matcher
    -   `%` matches zero or more characters at the start or end of a string
    -   Case insensitive by default
-   `glob` supports Unix-style wildcards

## Exercise {: .exercise}

Rewrite the pattern-matching query shown above using `glob`.

## Selecting First and Last Rows

```{.sql data-file="union_all.assays.sql"}
select * from (
    select * from (select * from experiment order by started asc limit 5)
    union all
    select * from (select * from experiment order by started desc limit 5)
)
order by started asc;
```
```{.text data-file="union_all.assays.out"}
| ident |    kind     |  started   |   ended    |
|-------|-------------|------------|------------|
| 17    | trial       | 2023-01-29 | 2023-01-30 |
| 35    | calibration | 2023-01-30 | 2023-01-30 |
| 36    | trial       | 2023-02-02 | 2023-02-03 |
| 25    | trial       | 2023-02-12 | 2023-02-14 |
| 2     | calibration | 2023-02-14 | 2023-02-14 |
| 40    | calibration | 2024-01-21 | 2024-01-21 |
| 12    | trial       | 2024-01-26 | 2024-01-28 |
| 44    | trial       | 2024-01-27 | 2024-01-29 |
| 34    | trial       | 2024-02-01 | 2024-02-02 |
| 14    | calibration | 2024-02-03 | 2024-02-03 |
```

-   `union all` combines records
    -   Keeps duplicates: `union` on its own only keeps unique records
    -   Which is more work but sometimes more useful
-   Yes, it feels like the extra `select * from` should be unnecessary

## Exercise {: .exercise}

Write a query whose result includes two rows for each Adelie penguin
in the `penguins` database.
How can you check that your query is working correctly?

## Intersection

```{.sql data-file="intersect.assays.sql"}
select
    personal,
    family,
    dept,
    age
from staff
where dept = 'mb'
intersect
select
    personal,
    family,
    dept,
    age from staff
where age < 50;
```
```{.text data-file="intersect.assays.out"}
| personal |  family   | dept | age |
|----------|-----------|------|-----|
| Indrans  | Sridhar   | mb   | 47  |
| Ishaan   | Ramaswamy | mb   | 35  |
```

-   Rows involved must have the same structure
-   Intersection usually used when pulling values from different sources
    -   In the query above, would be clearer to use `where`

## Exercise {: .exercise}

Use `intersect` to find all Adelie penguins that weigh more than 4000 grams.
How can you check that your query is working correctly?

Use `explain query plan` to compare the `intersect`-based query you just wrote
with one that uses `where`.
Which query looks like it will be more efficient?
Why do you believe this?

## Exclusion

```{.sql data-file="except.assays.sql"}
select
    personal,
    family,
    dept,
    age
from staff
where dept = 'mb'
except
    select
        personal,
        family,
        dept,
        age from staff
    where age < 50;
```
```{.text data-file="except.assays.out"}
| personal | family | dept | age |
|----------|--------|------|-----|
| Pranay   | Khanna | mb   | 51  |
```

-   Again, tables must have same structure
    -   And this would be clearer with `where`
-   SQL operates on sets, not tables, except where it doesn't

## Exercise {: .exercise}

Use `exclude` to find all Gentoo penguins that *aren't* male.
How can you check that your query is working correctly?

## Random Numbers and Why Not

```{.sql data-file="random_numbers.assays.sql"}
with decorated as (
    select random() as rand,
    personal || ' ' || family as name
    from staff
)

select
    rand,
    abs(rand) % 10 as selector,
    name
from decorated
where selector < 5;
```
```{.text data-file="random_numbers.assays.out"}
|         rand         | selector |      name       |
|----------------------|----------|-----------------|
| -5088363674211922423 | 0        | Divit Dhaliwal  |
| 6557666280550701355  | 1        | Indrans Sridhar |
| -2149788664940846734 | 3        | Pranay Khanna   |
| -3941247926715736890 | 8        | Riaan Dua       |
| -3101076015498625604 | 5        | Vedika Rout     |
| -7884339441528700576 | 4        | Abram Chokshi   |
| -2718521057113461678 | 4        | Romil Kapoor    |
```

-   There is no way to seed SQLite's random number generator
-   Which means there is no way to reproduce its pseudo-random sequences
-   Which means you should *never* use it
    -   How are you going to debug something you can't re-run?

## Exercise {: .exercise}

Write a query that:

-   uses a CTE to create 1000 random numbers between 0 and 10 inclusive;

-   uses a second CTE to calculate their mean; and

-   uses a third CTE and [SQLite's built-in math functions][sqlite_math]
    to calculate their standard deviation.

## Creating an Index

```{.sql data-file="create_use_index.sql"}
explain query plan
select filename
from plate
where filename like '%07%';

create index plate_file on plate(filename);

explain query plan
select filename
from plate
where filename like '%07%';
```
```{.text data-file="create_use_index.out"}
QUERY PLAN
`--SCAN plate USING COVERING INDEX sqlite_autoindex_plate_1
QUERY PLAN
`--SCAN plate USING COVERING INDEX plate_file
```

-   An [index](g:index) is an auxiliary data structure that enables faster access to records
    -   Spend storage space to buy speed
-   Don't have to mention it explicitly in queries
    -   Database manager will use it automatically
-   Unlike primary keys, SQLite supports defining indexes after the fact

## Generating Sequences

```{.sql data-file="generate_sequence.assays.sql"}
select value from generate_series(1, 5);
```
```{.text data-file="generate_sequence.assays.out"}
| value |
|-------|
| 1     |
| 2     |
| 3     |
| 4     |
| 5     |
```

-   A (non-standard) [table-valued function](g:table_valued_func)

## Generating Sequences Based on Data

```{.sql data-file="data_range_sequence.memory.sql"}
create table temp (
    num integer not null
);
insert into temp values (1), (5);
select value from generate_series (
    (select min(num) from temp),
    (select max(num) from temp)
);
```
```{.text data-file="data_range_sequence.memory.out"}
| value |
|-------|
| 1     |
| 2     |
| 3     |
| 4     |
| 5     |
```

-   Must have the parentheses around the `min` and `max` selections to keep SQLite happy

## Generating Sequences of Dates

```{.sql data-file="date_sequence.assays.sql"}
select date((select julianday(min(started)) from experiment) + value) as some_day
from (
    select value from generate_series(
        (select 0),
        (select julianday(max(started)) - julianday(min(started)) from experiment)
    )
)
limit 5;
```
```{.text data-file="date_sequence.assays.out"}
|  some_day  |
|------------|
| 2023-01-29 |
| 2023-01-30 |
| 2023-01-31 |
| 2023-02-01 |
| 2023-02-02 |
```

-   SQLite represents dates as YYYY-MM-DD strings
    or as Julian days or as Unix milliseconds or…
    -   Julian days is fractional number of days since November 24, 4714 BCE
-   `julianday` and `date` convert back and forth
-   `julianday` is specific to SQLite
    -   Other databases have their own date handling functions

## Counting Experiments Started per Day Without Gaps

```{.sql data-file="experiments_per_day.assays.sql"}
with
-- complete sequence of days with 0 as placeholder for number of experiments
all_days as (
    select
        date((select julianday(min(started)) from experiment) + value) as some_day,
        0 as zeroes
    from (
        select value from generate_series(
            (select 0),
            (select count(*) - 1 from experiment)
        )
    )
),

-- sequence of actual days with actual number of experiments started
actual_days as (
    select
        started,
        count(started) as num_exp
    from experiment
    group by started
)

-- combined by joining on day and taking actual number (if available) or zero
select
    all_days.some_day as day,
    coalesce(actual_days.num_exp, all_days.zeroes) as num_exp
from
    all_days left join actual_days on all_days.some_day = actual_days.started
limit 5;
```
```{.text data-file="experiments_per_day.assays.out"}
|    day     | num_exp |
|------------|---------|
| 2023-01-29 | 1       |
| 2023-01-30 | 1       |
| 2023-01-31 | 0       |
| 2023-02-01 | 0       |
| 2023-02-02 | 1       |
```

## Exercise {: .exercise}

What does the expression `date('now', 'start of month', '+1 month', '-1 day')` produce?
(You may find [the documentation on SQLite's date and time functions][sqlite_datetime] helpful.)

## Self Join

```{.sql data-file="self_join.assays.sql"}
with person as (
    select
        ident,
        personal || ' ' || family as name
    from staff
)

select
    left_person.name,
    right_person.name
from person as left_person inner join person as right_person
limit 10;
```
```{.text data-file="self_join.assays.out"}
|     name     |       name       |
|--------------|------------------|
| Kartik Gupta | Kartik Gupta     |
| Kartik Gupta | Divit Dhaliwal   |
| Kartik Gupta | Indrans Sridhar  |
| Kartik Gupta | Pranay Khanna    |
| Kartik Gupta | Riaan Dua        |
| Kartik Gupta | Vedika Rout      |
| Kartik Gupta | Abram Chokshi    |
| Kartik Gupta | Romil Kapoor     |
| Kartik Gupta | Ishaan Ramaswamy |
| Kartik Gupta | Nitya Lal        |
```

-   Join a table to itself
    -   Use `as` to create [aliases](g:alias) for copies of tables to distinguish them
    -   Nothing special about the names `left` and `right`
-   Get all n^2 pairs, including person with themself

## Generating Unique Pairs

```{.sql data-file="unique_pairs.assays.sql"}
with person as (
    select
        ident,
        personal || ' ' || family as name
    from staff
)

select
    left_person.name,
    right_person.name
from person as left_person inner join person as right_person
on left_person.ident < right_person.ident
where left_person.ident <= 4 and right_person.ident <= 4;
```
```{.text data-file="unique_pairs.assays.out"}
|      name       |      name       |
|-----------------|-----------------|
| Kartik Gupta    | Divit Dhaliwal  |
| Kartik Gupta    | Indrans Sridhar |
| Kartik Gupta    | Pranay Khanna   |
| Divit Dhaliwal  | Indrans Sridhar |
| Divit Dhaliwal  | Pranay Khanna   |
| Indrans Sridhar | Pranay Khanna   |
```

-   `left.ident < right.ident` ensures distinct pairs without duplicates
    -   Query uses `left.ident <= 4 and right.ident <= 4` to shorten output
-   Quick check: n(n-1)/2 pairs

## Filtering Pairs

```{.sql data-file="filter_pairs.assays.sql"}
with
person as (
    select
        ident,
        personal || ' ' || family as name
    from staff
),

together as (
    select
        left_perf.staff as left_staff,
        right_perf.staff as right_staff
    from performed as left_perf inner join performed as right_perf
        on left_perf.experiment = right_perf.experiment
    where left_staff < right_staff
)

select
    left_person.name as person_1,
    right_person.name as person_2
from person as left_person inner join person as right_person join together
    on left_person.ident = left_staff and right_person.ident = right_staff;
```
```{.text data-file="filter_pairs.assays.out"}
|    person_1     |     person_2     |
|-----------------|------------------|
| Kartik Gupta    | Vedika Rout      |
| Pranay Khanna   | Vedika Rout      |
| Indrans Sridhar | Romil Kapoor     |
| Abram Chokshi   | Ishaan Ramaswamy |
| Pranay Khanna   | Vedika Rout      |
| Kartik Gupta    | Abram Chokshi    |
| Abram Chokshi   | Romil Kapoor     |
| Kartik Gupta    | Divit Dhaliwal   |
| Divit Dhaliwal  | Abram Chokshi    |
| Pranay Khanna   | Ishaan Ramaswamy |
| Indrans Sridhar | Romil Kapoor     |
| Kartik Gupta    | Ishaan Ramaswamy |
| Kartik Gupta    | Nitya Lal        |
| Kartik Gupta    | Abram Chokshi    |
| Pranay Khanna   | Romil Kapoor     |
```

## Existence and Correlated Subqueries

```{.sql data-file="correlated_subquery.assays.sql"}
select
    name,
    building
from department
where
    exists (
        select 1
        from staff
        where dept = department.ident
    )
order by name;
```
```{.text data-file="correlated_subquery.assays.out"}
|       name        |     building     |
|-------------------|------------------|
| Genetics          | Chesson          |
| Histology         | Fashet Extension |
| Molecular Biology | Chesson          |
```

-   Endocrinology is missing from the list
-   `select 1` could equally be `select true` or any other value
-   A [correlated subquery](g:correlated_subquery) depends on a value from the outer query
    -   Equivalent to nested loop

## Nonexistence

```{.sql data-file="nonexistence.assays.sql"}
select
    name,
    building
from department
where
    not exists (
        select 1
        from staff
        where dept = department.ident
    )
order by name;
```
```{.text data-file="nonexistence.assays.out"}
|     name      | building |
|---------------|----------|
| Endocrinology | TGVH     |
```

## Exercise {: .exercise}

Can you rewrite the previous query using `exclude`?
If so, is your new query easier to understand?
If the query cannot be rewritten, why not?

## Avoiding Correlated Subqueries {: .aside}

```{.sql data-file="avoid_correlated_subqueries.assays.sql"}
select distinct
    department.name as name,
    department.building as building
from department inner join staff
    on department.ident = staff.dept
order by name;
```
```{.text data-file="avoid_correlated_subqueries.assays.out"}
|       name        |     building     |
|-------------------|------------------|
| Genetics          | Chesson          |
| Histology         | Fashet Extension |
| Molecular Biology | Chesson          |
```

-   The join might or might not be faster than the correlated subquery
-   Hard to find unstaffed departments without either `not exists` or `count` and a check for 0

## Lead and Lag

```{.sql data-file="lead_lag.assays.sql"}
with ym_num as (
    select
        strftime('%Y-%m', started) as ym,
        count(*) as num
    from experiment
    group by ym
)

select
    ym,
    lag(num) over (order by ym) as prev_num,
    num,
    lead(num) over (order by ym) as next_num
from ym_num
order by ym;
```
```{.text data-file="lead_lag.assays.out"}
|   ym    | prev_num | num | next_num |
|---------|----------|-----|----------|
| 2023-01 |          | 2   | 5        |
| 2023-02 | 2        | 5   | 5        |
| 2023-03 | 5        | 5   | 1        |
| 2023-04 | 5        | 1   | 6        |
| 2023-05 | 1        | 6   | 5        |
| 2023-06 | 6        | 5   | 3        |
| 2023-07 | 5        | 3   | 2        |
| 2023-08 | 3        | 2   | 4        |
| 2023-09 | 2        | 4   | 6        |
| 2023-10 | 4        | 6   | 4        |
| 2023-12 | 6        | 4   | 5        |
| 2024-01 | 4        | 5   | 2        |
| 2024-02 | 5        | 2   |          |
```

-   Use `strftime` to extract year and month
    -   Clumsy, but date/time handling is not SQLite's strong point
-   Use [window functions](g:window_func) `lead` and `lag` to shift values
    -   Unavailable values at the top or bottom are null

## Boundaries {: .aside}

-   [Documentation on SQLite's window functions][sqlite_window] describes
    three frame types and five kinds of frame boundary
-   It feels very ad hoc, but so does the real world

## Windowing Functions

```{.sql data-file="window_functions.assays.sql"}
with ym_num as (
    select
        strftime('%Y-%m', started) as ym,
        count(*) as num
    from experiment
    group by ym
)

select
    ym,
    num,
    sum(num) over (order by ym) as num_done,
    (sum(num) over (order by ym) * 1.00) / (select sum(num) from ym_num) as completed_progress, 
    cume_dist() over (order by ym) as linear_progress
from ym_num
order by ym;
```
```{.text data-file="window_functions.assays.out"}
|   ym    | num | num_done | completed_progress |  linear_progress   |
|---------|-----|----------|--------------------|--------------------|
| 2023-01 | 2   | 2        | 0.04               | 0.0769230769230769 |
| 2023-02 | 5   | 7        | 0.14               | 0.153846153846154  |
| 2023-03 | 5   | 12       | 0.24               | 0.230769230769231  |
| 2023-04 | 1   | 13       | 0.26               | 0.307692307692308  |
| 2023-05 | 6   | 19       | 0.38               | 0.384615384615385  |
| 2023-06 | 5   | 24       | 0.48               | 0.461538461538462  |
| 2023-07 | 3   | 27       | 0.54               | 0.538461538461538  |
| 2023-08 | 2   | 29       | 0.58               | 0.615384615384615  |
| 2023-09 | 4   | 33       | 0.66               | 0.692307692307692  |
| 2023-10 | 6   | 39       | 0.78               | 0.769230769230769  |
| 2023-12 | 4   | 43       | 0.86               | 0.846153846153846  |
| 2024-01 | 5   | 48       | 0.96               | 0.923076923076923  |
| 2024-02 | 2   | 50       | 1.0                | 1.0                |
```

-   `sum() over` does a running total
-   `cume_dist()` is fraction *of rows seen so far*
-   So `num_done` column is number of experiments done…
-   …`completed_progress` is the fraction of experiments done…
-   …and `linear_progress` is the fraction of time passed

## Explaining Another Query Plan {: .aside}

```{.sql data-file="explain_window_function.assays.sql"}
explain query plan
with ym_num as (
    select
        strftime('%Y-%m', started) as ym,
        count(*) as num
    from experiment
    group by ym
)
select
    ym,
    num,
    sum(num) over (order by ym) as num_done,
    cume_dist() over (order by ym) as progress
from ym_num
order by ym;
```
```{.text data-file="explain_window_function.assays.out"}
QUERY PLAN
|--CO-ROUTINE (subquery-3)
|  |--CO-ROUTINE (subquery-4)
|  |  |--CO-ROUTINE ym_num
|  |  |  |--SCAN experiment
|  |  |  `--USE TEMP B-TREE FOR GROUP BY
|  |  |--SCAN ym_num
|  |  `--USE TEMP B-TREE FOR ORDER BY
|  `--SCAN (subquery-4)
`--SCAN (subquery-3)
```

-   Becomes useful…eventually

## Partitioned Windows

```{.sql data-file="partition_window.assays.sql"}
with y_m_num as (
    select
        strftime('%Y', started) as year,
        strftime('%m', started) as month,
        count(*) as num
    from experiment
    group by year, month
)

select
    year,
    month,
    num,
    sum(num) over (partition by year order by month) as num_done
from y_m_num
order by year, month;
```
```{.text data-file="partition_window.assays.out"}
| year | month | num | num_done |
|------|-------|-----|----------|
| 2023 | 01    | 2   | 2        |
| 2023 | 02    | 5   | 7        |
| 2023 | 03    | 5   | 12       |
| 2023 | 04    | 1   | 13       |
| 2023 | 05    | 6   | 19       |
| 2023 | 06    | 5   | 24       |
| 2023 | 07    | 3   | 27       |
| 2023 | 08    | 2   | 29       |
| 2023 | 09    | 4   | 33       |
| 2023 | 10    | 6   | 39       |
| 2023 | 12    | 4   | 43       |
| 2024 | 01    | 5   | 5        |
| 2024 | 02    | 2   | 7        |
```

-   `partition by` creates groups
-   So this counts experiments started since the beginning of each year

## Exercise {: .exercise}

Create a query that:

1.  finds the unique weights of the penguins in the `penguins` database;
2.  sorts them;
3.  finds the difference between each successive distinct weight; and
4.  counts how many times each unique difference appears.
