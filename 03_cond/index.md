# Conditionals

<p id="terms"></p>

## If/Else

```{.sql data-file="if_else.penguins.sql"}
with sized_penguins as (
    select
        species,
        iif(
            body_mass_g < 3500,
            'small',
            'large'
        ) as size
    from penguins
    where body_mass_g is not null
)

select
    species,
    size,
    count(*) as num
from sized_penguins
group by species, size
order by species, num;
```
```{.text data-file="if_else.penguins.out"}
|  species  | size  | num |
|-----------|-------|-----|
| Adelie    | small | 54  |
| Adelie    | large | 97  |
| Chinstrap | small | 17  |
| Chinstrap | large | 51  |
| Gentoo    | large | 123 |
```

-   <code>iif(<em>condition</em>, <em>true_result</em>, <em>false_result</em>)</code>
    -   Note: `iif` with two i's
-   May feel odd to think of `if`/`else` as a function,
    but common in [vectorized](g:vectorization) calculations

## Exercise {: .exercise}

How does the result of the previous query change
if the check for null body mass is removed?
Why is the result without that check misleading?

What does each of the expressions shown below produce?
Which ones do you think actually attempt to divide by zero?

1.  `iif(0, 123, 1/0)`
1.  `iif(1, 123, 1/0)`
1.  `iif(0, 1/0, 123)`
1.  `iif(1, 1/0, 123)`

## Selecting a Case

-   What if we want small, medium, and large?
-   Can nest `iif`, but quickly becomes unreadable

```{.sql data-file="case_when.penguins.sql"}
with sized_penguins as (
    select
        species,
        case
            when body_mass_g < 3500 then 'small'
            when body_mass_g < 5000 then 'medium'
            else 'large'
        end as size
    from penguins
    where body_mass_g is not null
)

select
    species,
    size,
    count(*) as num
from sized_penguins
group by species, size
order by species, num;
```
```{.text data-file="case_when.penguins.out"}
|  species  |  size  | num |
|-----------|--------|-----|
| Adelie    | small  | 54  |
| Adelie    | medium | 97  |
| Chinstrap | small  | 17  |
| Chinstrap | medium | 51  |
| Gentoo    | medium | 56  |
| Gentoo    | large  | 67  |
```

-   Evaluate `when` options in order and take first
-   Result of `case` is null if no condition is true
-   Use `else` as fallback

## Exercise {: .exercise}

Modify the query above so that
the outputs are `"penguin is small"` and `"penguin is large"`
by concatenating the string `"penguin is "` to the entire `case`
rather than to the individual `when` branches.
(This exercise shows that `case`/`when` is an [expression](g:expression)
rather than a [statement](g:statement).)

## Checking a Range

```{.sql data-file="check_range.penguins.sql"}
with sized_penguins as (
    select
        species,
        case
            when body_mass_g between 3500 and 5000 then 'normal'
            else 'abnormal'
        end as size
    from penguins
    where body_mass_g is not null
)

select
    species,
    size,
    count(*) as num
from sized_penguins
group by species, size
order by species, num;
```
```{.text data-file="check_range.penguins.out"}
|  species  |   size   | num |
|-----------|----------|-----|
| Adelie    | abnormal | 54  |
| Adelie    | normal   | 97  |
| Chinstrap | abnormal | 17  |
| Chinstrap | normal   | 51  |
| Gentoo    | abnormal | 61  |
| Gentoo    | normal   | 62  |
```

-   `between` can make queries easier to read
-   But be careful of the `and` in the middle

## Exercise {: .exercise}

The expression `val between 'A' and 'Z'` is true if `val` is `'M'` (upper case)
but false if `val` is `'m'` (lower case).
Rewrite the expression using [SQLite's built-in scalar functions][sqlite_function]
so that it is true in both cases.

| name      | purpose |
| --------- | ------- |
| `substr`  | Get substring given starting point and length |
| `trim`    | Remove characters from beginning and end of string |
| `ltrim`   | Remove characters from beginning of string |
| `rtrim`   | Remove characters from end of string |
| `length`  | Length of string |
| `replace` | Replace occurrences of substring with another string |
| `upper`   | Return upper-case version of string |
| `lower`   | Return lower-case version of string |
| `instr`   | Find location of first occurrence of substring (returns 0 if not found) |
