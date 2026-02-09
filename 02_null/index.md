# Missing Values

<p id="terms"></p>

```{.sql data-file="show_missing_values.penguins.sql"}
select
    flipper_length_mm / 10.0 as flipper_cm,
    body_mass_g / 1000.0 as weight_kg,
    island as where_found
from penguins
limit 5;
```
```{.text data-file="show_missing_values.penguins.out"}
| flipper_cm | weight_kg | where_found |
|------------|-----------|-------------|
| 18.1       | 3.75      | Torgersen   |
| 18.6       | 3.8       | Torgersen   |
| 19.5       | 3.25      | Torgersen   |
|            |           | Torgersen   |
| 19.3       | 3.45      | Torgersen   |
```

-   SQL uses a special value [<code>null</code>](g:null) to representing missing data
    -   Not 0 or empty string, but "I don't know"
-   Flipper length and body weight not known for one of the first five penguins
-   "I don't know" divided by 10 or 1000 is "I don't know"

## Exercise {: .exercise}

Use SQLite's `.nullvalue` command
to change the printed representation of null to the string `null`
and then re-run the previous query.
When will displaying null as `null` be easier to understand?
When might it be misleading?

## Null Equality

-   Repeated from earlier

```{.sql data-file="filter.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe';
```
```{.text data-file="filter.penguins.out"}
| species |  sex   | island |
|---------|--------|--------|
| Adelie  | FEMALE | Biscoe |
| Adelie  | MALE   | Biscoe |
| Gentoo  | FEMALE | Biscoe |
| Gentoo  | MALE   | Biscoe |
| Gentoo  |        | Biscoe |
```

-   If we ask for female penguins the row with the missing sex drops out

```{.sql data-file="null_equality.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe' and sex = 'FEMALE';
```
```{.text data-file="null_equality.penguins.out"}
| species |  sex   | island |
|---------|--------|--------|
| Adelie  | FEMALE | Biscoe |
| Gentoo  | FEMALE | Biscoe |
```

## Null Inequality

-   But if we ask for penguins that *aren't* female it drops out as well

```{.sql data-file="null_inequality.penguins.sql"}
select distinct
    species,
    sex,
    island
from penguins
where island = 'Biscoe' and sex != 'FEMALE';
```
```{.text data-file="null_inequality.penguins.out"}
| species | sex  | island |
|---------|------|--------|
| Adelie  | MALE | Biscoe |
| Gentoo  | MALE | Biscoe |
```

## Ternary Logic

```{.sql data-file="ternary_logic.penguins.sql"}
select null = null;
```
```{.text data-file="ternary_logic.penguins.out"}
| null = null |
|-------------|
|             |
```

-   If we don't know the left and right values, we don't know if they're equal or not
-   So the result is `null`
-   Get the same answer for `null != null`
-   [Ternary logic](g:ternary_logic)

<table>
  <tbody>
    <tr>
      <th colspan="4">equality</th>
    </tr>
    <tr>
      <th></th>
      <th>X</th>
      <th>Y</th>
      <th>null</th>
    </tr>
    <tr>
      <th>X</th>
      <td>true</td>
      <td>false</td>
      <td>null</td>
    </tr>
    <tr>
      <th>Y</th>
      <td>false</td>
      <td>true</td>
      <td>null</td>
    </tr>
    <tr>
      <th>null</th>
      <td>null</td>
      <td>null</td>
      <td>null</td>
    </tr>
  </tbody>
</table>

## Handling Null Safely

```{.sql data-file="safe_null_equality.penguins.sql"}
select
    species,
    sex,
    island
from penguins
where sex is null;
```
```{.text data-file="safe_null_equality.penguins.out"}
| species | sex |  island   |
|---------|-----|-----------|
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Torgersen |
| Adelie  |     | Dream     |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
| Gentoo  |     | Biscoe    |
```

-   Use `is null` and `is not null` to handle null safely
-   Other parts of SQL handle nulls specially

## Exercise {: .exercise}

1.  Write a query to find penguins whose body mass is known but whose sex is not.

2.  Write another query to find penguins whose sex is known but whose body mass is not.

## Check Understanding {: .aside}

<figure id="f:core_missing_concept_map">
  <img src="core_missing_concept_map.svg" alt="box and arrow diagram of concepts related to null values in SQL"/>
  <figcaption>Missing Value Concepts</figcaption>
</figure>

