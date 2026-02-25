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
