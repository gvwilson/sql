# SQL Practice Questions


## 1. List all departments

Show all columns for every department.

```sql
SELECT *
FROM department;
```

## 2. List staff names and ages

Show the personal name, family name, and age of all staff members.

```sql
SELECT personal, family, age
FROM staff;
```

## 3. Staff older than a given age

Find the personal and family names of staff who are older than 40.

```sql
SELECT personal, family
FROM staff
WHERE age > 40;
```

## 4. Departments in a specific building

List the names of departments located in the building "Science Hall".

```sql
SELECT name
FROM department
WHERE building = 'Science Hall';
```

## 5. Experiments that have ended

List all experiments that have an end date.

```sql
SELECT *
FROM experiment
WHERE ended IS NOT NULL;
```

## 6. Experiments of a given kind

Show the identifiers and start dates of all experiments of kind "chemistry".

```sql
SELECT ident, started
FROM experiment
WHERE kind = 'chemistry';
```

## 7. Count staff members

How many staff members are in the database?

```sql
SELECT COUNT(*) AS staff_count
FROM staff;
```

## 8. Staff per department

List each department identifier and the number of staff assigned to it.

```sql
SELECT dept, COUNT(*) AS num_staff
FROM staff
GROUP BY dept;
```

## 9. Staff with their department names

List each staff member’s personal name, family name, and department name.

```sql
SELECT s.personal, s.family, d.name AS department_name
FROM staff s
JOIN department d ON s.dept = d.ident;
```

## 10. Experiments performed by staff

List the experiment IDs along with the personal and family names of staff who performed them.

```sql
SELECT p.experiment, s.personal, s.family
FROM performed p
JOIN staff s ON p.staff = s.ident;
```

## 11. Plates for each experiment

List each experiment ID and the filename of every plate associated with it.

```sql
SELECT experiment, filename
FROM plate;
```

## 12. Number of plates per experiment

Show each experiment ID and the number of plates uploaded for it.

```sql
SELECT experiment, COUNT(*) AS plate_count
FROM plate
GROUP BY experiment;
```

## 13. Experiments with no end date

List experiments that are still ongoing.

```sql
SELECT *
FROM experiment
WHERE ended IS NULL;
```

## 14. Staff who performed experiments of a given kind

Find the personal and family names of staff who performed "biology" experiments.

```sql
SELECT DISTINCT s.personal, s.family
FROM staff s
JOIN performed p ON s.ident = p.staff
JOIN experiment e ON p.experiment = e.ident
WHERE e.kind = 'biology';
```

## 15. Plates invalidated by staff

List the plate ID, invalidation date, and the family name of the staff member who invalidated it.

```sql
SELECT i.plate, i.invalidate_date, s.family
FROM invalidated i
JOIN staff s ON i.staff = s.ident;
```

## 16. Plates invalidated more than once

Find plates that have been invalidated more than once.

```sql
SELECT plate, COUNT(*) AS invalidation_count
FROM invalidated
GROUP BY plate
HAVING COUNT(*) > 1;
```

## 17. Staff who never performed an experiment

List staff members who have never performed any experiment.

```sql
SELECT s.personal, s.family
FROM staff s
LEFT JOIN performed p ON s.ident = p.staff
WHERE p.staff IS NULL;
```

## 18. Experiments with no plates

List experiments that have no associated plates.

```sql
SELECT e.ident
FROM experiment e
LEFT JOIN plate p ON e.ident = p.experiment
WHERE p.ident IS NULL;
```

## 19. Department with the most staff

Find the department identifier that has the largest number of staff.

```sql
SELECT dept
FROM staff
GROUP BY dept
ORDER BY COUNT(*) DESC
LIMIT 1;
```

## 20. Staff involved in experiments with invalidated plates

List the distinct personal and family names of staff members who performed experiments that have at least one invalidated plate.

```sql
SELECT DISTINCT s.personal, s.family
FROM staff s
JOIN performed pf ON s.ident = pf.staff
JOIN plate p ON pf.experiment = p.experiment
JOIN invalidated i ON p.ident = i.plate;
```
