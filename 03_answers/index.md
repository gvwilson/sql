# More Practice Questions

## 1. Show each person's first and last name.

```sql
select personal, family
from person;
```

## 2. Count the number of people.

```sql
select count(*) as num_people
from person;
```

## 3. Show people with no supervisor.

```sql
select person_id, personal, family
from person
where supervisor_id is null;
```

## 4. Show each person's full name and their supervisor's full name.

```sql
select
    p.personal || ' ' || p.family as person_name,
    s.personal || ' ' || s.family as supervisor_name
from person as p
left join person as s on p.supervisor_id = s.person_id;
```

## 5. Find surveys with no end date.

```sql
select *
from survey
where end_date is null;
```

## 6. Show surveys with their owner's name.

```sql
select
    survey.survey_id,
    person.personal || ' ' || person.family as owner_name,
    survey.start_date,
    survey.end_date
from survey
join person on survey.person_id = person.person_id;
```

## 7. Show distinct machine types.

```sql
select distinct machine_type
from machine;
```

## 8. Count machines by type.

```sql
select machine_type, count(*) as num_machines
from machine
group by machine_type;
```

## 9. Find ratings above level 1.

```sql
select *
from rating
where level > 1;
```

## 10. Show who has a rating for which machine.

```sql
select
    person.personal,
    person.family,
    machine.machine_id,
    machine.machine_type,
    rating.level
from rating
join person on rating.person_id = person.person_id
join machine on rating.machine_id = machine.machine_id;
```

## 11. Calculate each person's average rating on all machines.

```sql
select
    person.personal,
    person.family,
    round(avg(rating.level), 1) as avg_rating
from person
join rating on person.person_id = rating.person_id
group by person.person_id;
```

## 12. Show people who have at least one machine rating.

```sql
select distinct person.personal, person.family
from person
join rating on person.person_id = rating.person_id;
```

## 13. Show machines that no one has a rating for.

```sql
select machine.machine_id, machine.machine_type
from machine
where machine.machine_id not in (select distinct machine_id from rating);
```

## 14. Show all people who supervise someone else.

```sql
select distinct p.person_id, p.personal, p.family
from person as p
join person as s on p.person_id = s.supervisor_id;
```

## 15. Show how many surveys each person is associated with.

```sql
select
    person.personal,
    person.family,
    count(survey.survey_id) as num_surveys
from person
left join survey on person.person_id = survey.person_id
group by person.person_id;
```

## 16. Show people who do not have ratings for any machines.

```sql
select person.personal, person.family
from person
where person.person_id not in (select distinct person_id from rating);
```

## 17. Find machines that have not been rated by person P001.

```sql
select machine.machine_id, machine.machine_type
from machine
where machine.machine_id not in (
    select machine_id from rating where person_id = 'P001'
);
```

## 18. Find supervisors who are not associated with any surveys.

```sql
select distinct p.person_id, p.personal, p.family
from person as p
join person as s on p.person_id = s.supervisor_id
where p.person_id not in (select person_id from survey);
```

## 19. Show people who have ratings for more than one type of machine.

```sql
select person.personal, person.family
from person
join rating on person.person_id = rating.person_id
join machine on rating.machine_id = machine.machine_id
group by person.person_id
having count(distinct machine.machine_type) > 1;
```

## 20. Find the highest rating that anyone has on any kind of machine.

```sql
select max(level) as highest_rating
from rating;
```

## 21. Show all of the people who have that highest rating for any kind of machine.

```sql
select
    person.personal,
    person.family,
    machine.machine_type,
    rating.level
from rating
join person on rating.person_id = person.person_id
join machine on rating.machine_id = machine.machine_id
where rating.level = (select max(level) from rating);
```

## 22. Show the length in days of each survey.

```sql
select
    survey_id,
    cast(julianday(end_date) - julianday(start_date) as integer) as length_days
from survey
where start_date is not null
and end_date is not null;
```

## 23. Show the total length of time that each person has spent doing surveys.

```sql
select
    person.personal,
    person.family,
    cast(sum(julianday(survey.end_date) - julianday(survey.start_date)) as integer) as total_days
from person
join survey on person.person_id = survey.person_id
where survey.start_date is not null
and survey.end_date is not null
group by person.person_id;
```

## 24. Find the longest time *between* surveys for each person.

```sql
with ordered as (
    select
        person_id,
        start_date,
        end_date,
        lead(start_date) over (partition by person_id order by start_date) as next_start
    from survey
    where start_date is not null
)
select
    person.personal,
    person.family,
    cast(max(julianday(ordered.next_start) - julianday(ordered.end_date)) as integer) as longest_gap_days
from ordered
join person on ordered.person_id = person.person_id
where ordered.end_date is not null
and ordered.next_start is not null
group by ordered.person_id;
```
