# Complex Comparisons

<p id="terms"></p>

## Comparing Individual Values to Aggregates

-   Go back to the original penguins database

```{.sql data-file="compare_individual_aggregate.penguins.sql"}
select body_mass_g
from penguins
where
    body_mass_g > (
        select avg(body_mass_g)
        from penguins
    )
limit 5;
```
```{.text data-file="compare_individual_aggregate.penguins.out"}
| body_mass_g |
|-------------|
| 4675.0      |
| 4250.0      |
| 4400.0      |
| 4500.0      |
| 4650.0      |
```

-   Get average body mass in subquery
-   Compare each row against that
-   Requires two scans of the data, but no way to avoid that
    -   Except calculating a running total each time a penguin is added to the table
-   Null values aren't included in the average or in the final results

## Exercise {: .exercise}

Use a subquery to find the number of penguins
that weigh the same as the lightest penguin.

## Comparing Individual Values to Aggregates Within Groups

```{.sql data-file="compare_within_groups.penguins.sql"}
select
    penguins.species,
    penguins.body_mass_g,
    round(averaged.avg_mass_g, 1) as avg_mass_g
from penguins inner join (
    select
        species,
        avg(body_mass_g) as avg_mass_g
    from penguins
    group by species
) as averaged
    on penguins.species = averaged.species
where penguins.body_mass_g > averaged.avg_mass_g
limit 5;
```
```{.text data-file="compare_within_groups.penguins.out"}
| species | body_mass_g | avg_mass_g |
|---------|-------------|------------|
| Adelie  | 3750.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
| Adelie  | 4675.0      | 3700.7     |
| Adelie  | 4250.0      | 3700.7     |
| Adelie  | 3800.0      | 3700.7     |
```

-   Subquery runs first to create temporary table `averaged` with average mass per species
-   Join that with `penguins`
-   Filter to find penguins heavier than average within their species

## Exercise {: .exercise}

Use a subquery to find the number of penguins
that weigh the same as the lightest penguin of the same sex and species.
