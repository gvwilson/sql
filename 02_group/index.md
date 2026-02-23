# Aggregating and Grouping

<p id="terms"></p>

> See also ["Essential SQL Techniques"](https://github.com/UofT-DSI/sql/blob/main/01_materials/slides/slides_03.pdf)

```{.sql data-file="simple_sum.penguins.sql"}
select sum(body_mass_g) as total_mass
from penguins;
```
```{.text data-file="simple_sum.penguins.out"}
| total_mass |
|------------|
| 1437000.0  |
```

-   [Aggregation](g:aggregation) combines many values to produce one
-   `sum` is an [aggregation function](g:aggregation_func)
-   Combines corresponding values from multiple rows

## Common Aggregation Functions

```{.sql data-file="common_aggregations.penguins.sql"}
select
    max(bill_length_mm) as longest_bill,
    min(flipper_length_mm) as shortest_flipper,
    avg(bill_length_mm) / avg(bill_depth_mm) as weird_ratio
from penguins;
```
```{.text data-file="common_aggregations.penguins.out"}
| longest_bill | shortest_flipper |   weird_ratio    |
|--------------|------------------|------------------|
| 59.6         | 172.0            | 2.56087082530644 |
```

-   This actually shouldn't work:
    can't calculate maximum or average if any values are null
-   SQL does the useful thing instead of the right one

## Exercise {: .exercise}

What is the average body mass of penguins that weigh more than 3000.0 grams?

## Counting

```{.sql data-file="count_behavior.penguins.sql"}
select
    count(*) as count_star,
    count(sex) as count_specific,
    count(distinct sex) as count_distinct
from penguins;
```
```{.text data-file="count_behavior.penguins.out"}
| count_star | count_specific | count_distinct |
|------------|----------------|----------------|
| 344        | 333            | 2              |
```

-   `count(*)` counts rows
-   <code>count(<em>column</em>)</code> counts non-null entries in column
-   <code>count(distinct <em>column</em>)</code> counts distinct non-null entries

## Exercise {: .exercise}

How many different body masses are in the penguins dataset?

## Grouping

```{.sql data-file="simple_group.penguins.sql"}
select avg(body_mass_g) as average_mass_g
from penguins
group by sex;
```
```{.text data-file="simple_group.penguins.out"}
|  average_mass_g  |
|------------------|
| 4005.55555555556 |
| 3862.27272727273 |
| 4545.68452380952 |
```

-   Put rows in [groups](g:group) based on distinct combinations of values in columns specified with `group by`
-   Then perform aggregation separately for each group
-   But which is which?

## Behavior of Unaggregated Columns

```{.sql data-file="unaggregated_columns.penguins.sql"}
select
    sex,
    avg(body_mass_g) as average_mass_g
from penguins
group by sex;
```
```{.text data-file="unaggregated_columns.penguins.out"}
|  sex   |  average_mass_g  |
|--------|------------------|
|        | 4005.55555555556 |
| FEMALE | 3862.27272727273 |
| MALE   | 4545.68452380952 |
```

-   All rows in each group have the same value for `sex`, so no need to aggregate

## Arbitrary Choice in Aggregation

```{.sql data-file="arbitrary_in_aggregation.penguins.sql"}
select
    sex,
    body_mass_g                   
from penguins
group by sex;
```
```{.text data-file="arbitrary_in_aggregation.penguins.out"}
|  sex   | body_mass_g |
|--------|-------------|
|        |             |
| FEMALE | 3800.0      |
| MALE   | 3750.0      |
```

-   If we don't specify how to aggregate a column,
    SQLite chooses *any arbitrary value* from the group
    -   All penguins in each group have the same sex because we grouped by that, so we get the right answer
    -   The body mass values are in the data but unpredictable
    -   A common mistake
-   Other database managers don't do this
    -   E.g., PostgreSQL complains that column must be used in an aggregation function

## Exercise {: .exercise}

Explain why the output of the previous query
has a blank line before the rows for female and male penguins.

Write a query that shows each distinct body mass in the penguin dataset
and the number of penguins that weigh that much.

## Filtering Aggregated Values

```{.sql data-file="filter_aggregation.penguins.sql"}
select
    sex,
    avg(body_mass_g) as average_mass_g
from penguins
group by sex
having average_mass_g > 4000.0;
```
```{.text data-file="filter_aggregation.penguins.out"}
| sex  |  average_mass_g  |
|------|------------------|
|      | 4005.55555555556 |
| MALE | 4545.68452380952 |
```

-   Using <code>having <em>condition</em></code> instead of <code>where <em>condition</em></code> for aggregates

## Readable Output

```{.sql data-file="readable_aggregation.penguins.sql"}
select
    sex,
    round(avg(body_mass_g), 1) as average_mass_g
from penguins
group by sex
having average_mass_g > 4000.0;
```
```{.text data-file="readable_aggregation.penguins.out"}
| sex  | average_mass_g |
|------|----------------|
|      | 4005.6         |
| MALE | 4545.7         |
```

-   Use <code>round(<em>value</em>, <em>decimals</em>)</code> to round off a number

## Filtering Aggregate Inputs

```{.sql data-file="filter_aggregate_inputs.penguins.sql"}
select
    sex,
    round(
        avg(body_mass_g) filter (where body_mass_g < 4000.0),
        1
    ) as average_mass_g
from penguins
group by sex;
```
```{.text data-file="filter_aggregate_inputs.penguins.out"}
|  sex   | average_mass_g |
|--------|----------------|
|        | 3362.5         |
| FEMALE | 3417.3         |
| MALE   | 3729.6         |
```

-   <code>filter (where <em>condition</em>)</code> applies to *inputs*

## Exercise {: .exercise}

Write a query that uses `filter` to calculate the average body masses
of heavy penguins (those over 4500 grams)
and light penguins (those under 3500 grams)
simultaneously.
Is it possible to do this using `where` instead of `filter`?

## Check Understanding {: .aside}

<figure id="f:core_aggregate_concept_map">
  <img src="core_aggregate_concept_map.svg" alt="box and arrow diagram of concepts related to aggregation in SQL"/>
  <figcaption>Aggregation Concepts</figcaption>
</figure>

