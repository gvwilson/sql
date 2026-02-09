# Combining Information

<p id="terms"></p>

```{.sql data-file="cross_join.memory.sql:keep"}
select *
from work cross join job;
```
```{.text data-file="cross_join.memory.out"}
| person |    job    |   name    | billable |
|--------|-----------|-----------|----------|
| mik    | calibrate | calibrate | 1.5      |
| mik    | calibrate | clean     | 0.5      |
| mik    | clean     | calibrate | 1.5      |
| mik    | clean     | clean     | 0.5      |
| mik    | complain  | calibrate | 1.5      |
| mik    | complain  | clean     | 0.5      |
| po     | clean     | calibrate | 1.5      |
| po     | clean     | clean     | 0.5      |
| po     | complain  | calibrate | 1.5      |
| po     | complain  | clean     | 0.5      |
| tay    | complain  | calibrate | 1.5      |
| tay    | complain  | clean     | 0.5      |
```

-   A [join](g:join) combines information from two tables
-   [cross join](g:cross_join) constructs their cross product
    -   All combinations of rows from each
-   Result isn't particularly useful: `job` and `name` values don't match
    -   I.e., the combined data has records whose parts have nothing to do with each other

## Inner Join

```{.sql data-file="inner_join.memory.sql:keep"}
select *
from work inner join job
    on work.job = job.name;
```
```{.text data-file="inner_join.memory.out"}
| person |    job    |   name    | billable |
|--------|-----------|-----------|----------|
| mik    | calibrate | calibrate | 1.5      |
| mik    | clean     | clean     | 0.5      |
| po     | clean     | clean     | 0.5      |
```

-   Use <code><em>table</em>.<em>column</em></code> notation to specify columns
    -   A column can have the same name as a table
-   Use <code>on <em>condition</em></code> to specify [join condition](g:join_condition)
-   Since `complain` doesn't appear in `job.name`, none of those rows are kept

## Exercise {: .exercise}

Re-run the query shown above using `where job = name` instead of the full `table.name` notation.
Is the shortened form easier or harder to read
and more or less likely to cause errors?

## Aggregating Joined Data

```{.sql data-file="aggregate_join.memory.sql:keep"}
select
    work.person,
    sum(job.billable) as pay
from work inner join job
    on work.job = job.name
group by work.person;
```
```{.text data-file="aggregate_join.memory.out"}
| person | pay |
|--------|-----|
| mik    | 2.0 |
| po     | 0.5 |
```

-   Combines ideas we've seen before
-   But Tay is missing from the table
    -   No records in the `job` table with `tay` as name
    -   So no records to be grouped and summed

## Left Join

```{.sql data-file="left_join.memory.sql:keep"}
select *
from work left join job
    on work.job = job.name;
```
```{.text data-file="left_join.memory.out"}
| person |    job    |   name    | billable |
|--------|-----------|-----------|----------|
| mik    | calibrate | calibrate | 1.5      |
| mik    | clean     | clean     | 0.5      |
| mik    | complain  |           |          |
| po     | clean     | clean     | 0.5      |
| po     | complain  |           |          |
| tay    | complain  |           |          |
```

-   A [left outer join](g:left_outer_join) keeps all rows from the left table
-   Fills missing values from right table with null

## Aggregating Left Joins

```{.sql data-file="aggregate_left_join.memory.sql:keep"}
select
    work.person,
    sum(job.billable) as pay
from work left join job
    on work.job = job.name
group by work.person;
```
```{.text data-file="aggregate_left_join.memory.out"}
| person | pay |
|--------|-----|
| mik    | 2.0 |
| po     | 0.5 |
| tay    |     |
```

-   That's better, but we'd like to see 0 rather than a blank

## Coalescing Values

```{.sql data-file="coalesce.memory.sql:keep"}
select
    work.person,
    coalesce(sum(job.billable), 0.0) as pay
from work left join job
    on work.job = job.name
group by work.person;
```
```{.text data-file="coalesce.memory.out"}
| person | pay |
|--------|-----|
| mik    | 2.0 |
| po     | 0.5 |
| tay    | 0.0 |
```

-   <code>coalesce(<em>val1</em>, <em>val2</em>, …)</code> returns first non-null value

## Full Outer Join {: .aside}

-   [Full outer join](g:full_outer_join) is the union of
    left outer join and [right outer join](g:right_outer_join)
-   Almost the same as cross join, but consider:

```{.sql data-file="full_outer_join.memory.sql"}
create table size (
    s text not null
);
insert into size values ('light'), ('heavy');

create table weight (
    w text not null
);

select * from size full outer join weight;
```
```{.text data-file="full_outer_join.memory.out"}
|   s   | w |
|-------|---|
| light |   |
| heavy |   |
```

-   A cross join would produce empty result

## Exercise {: .exercise}

Find the least time each person spent on any job.
Your output should show that `mik` and `po` each spent 0.5 hours on some job.
Can you find a way to show the name of the job as well
using the SQL you have seen so far?

## Check Understanding {: .aside}

<figure id="f:core_join_concept_map">
  <img src="core_join_concept_map.svg" alt="box and arrow diagram of concepts related to joining tables"/>
  <figcaption>Join Concepts</figcaption>
</figure>
