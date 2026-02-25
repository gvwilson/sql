# Subqueries

<p id="terms"></p>

## Negating Incorrectly

-   Who doesn't calibrate?

```{.sql data-file="negate_incorrectly.memory.sql:keep"}
select distinct person
from work
where job != 'calibrate';
```
```{.text data-file="negate_incorrectly.memory.out"}
| person |
|--------|
| mik    |
| po     |
| tay    |
```

-   But Mik *does* calibrate
-   Problem is that there's an entry for Mik cleaning
-   And since `'clean' != 'calibrate'`, that row is included in the results
-   We need a different approach…

## Set Membership

```{.sql data-file="set_membership.sql:keep"}
select *
from work
where person not in ('mik', 'tay');
```
```{.text data-file="set_membership.out"}
| person |   job    |
|--------|----------|
| po     | clean    |
| po     | complain |
```

-   <code>in <em>values</em></code> and <code>not in <em>values</em></code> do exactly what you expect

## Subqueries

```{.sql data-file="subquery_set.sql:keep"}
select distinct person
from work
where person not in (
    select distinct person
    from work
    where job = 'calibrate'
);
```
```{.text data-file="subquery_set.out"}
| person |
|--------|
| po     |
| tay    |
```

-   Use a [subquery](g:subquery) to select the people who *do* calibrate
-   Then select all the people who *aren't* in that set
-   Initially feels odd, but subqueries are useful in other ways

## Common Table Expressions

```{.sql data-file="common_table_expressions.penguins.sql"}
with grouped as (
    select
        species,
        avg(body_mass_g) as avg_mass_g
    from penguins
    group by species
)

select
    penguins.species,
    penguins.body_mass_g,
    grouped.avg_mass_g
from penguins inner join grouped
on penguins.species = grouped.species
where penguins.body_mass_g > grouped.avg_mass_g
limit 5;
```
```{.text data-file="common_table_expressions.penguins.out"}
| species | body_mass_g | avg_mass_g |
|---------|-------------|------------|
| Adelie  | 3750.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
| Adelie  | 4675.0      | 3700.7     |
| Adelie  | 4250.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
```

-   Use [common table expression](g:cte) (CTE) to make queries clearer
    -   Nested subqueries quickly become difficult to understand
-   Database decides how to optimize
