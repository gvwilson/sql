# SQL Practice Questions

<figure id="f:questions_er">
  <img src="tools_assays_er.svg" alt="entity-relationship diagram showing logical structure of assay database"/>
  <figcaption>Assay ER Diagram</figcaption>
</figure>

<figure id="f:questions_tables">
  <img src="tools_assays_tables.svg" alt="table-level diagram of assay database showing primary and foreign key relationships"/>
  <figcaption>Assay Database Table Diagram</figcaption>
</figure>

```sql
CREATE TABLE department(
       ident            text not null primary key,
       name             text not null,
       building         text not null
);

CREATE TABLE staff(
       ident            integer primary key autoincrement,
       personal         text not null,
       family           text not null,
       dept             text,
       age              integer not null,
       foreign key (dept) references department(ident)
);

CREATE TABLE experiment(
       ident            integer primary key autoincrement,
       kind             text not null,
       started          text not null,
       ended            text
);

CREATE TABLE performed(
       staff            integer not null,
       experiment       integer not null,
       foreign key (staff) references staff(ident),
       foreign key (experiment) references experiment(ident)
);

CREATE TABLE plate(
       ident            integer primary key autoincrement,
       experiment       integer not null,
       upload_date      text not null,
       filename         text unique,
       foreign key (experiment) references experiment(ident)
);

CREATE TABLE invalidated(
       plate            integer not null,
       staff            integer not null,
       invalidate_date  text not null,
       foreign key (plate) references plate(ident),
       foreign key (staff) references staff(ident)
);
```

## Queries to Debug

### 1. List all department names

```sql
SELECT dept
FROM department;
```

### 2. Find staff older than 50

```sql
SELECT personal, family
FROM staff
WHERE age >= '50';
```

### 3. Count the number of experiments

```sql
SELECT ident, COUNT(*)
FROM experiment;
```

### 4. List all staff and their department names

```sql
SELECT personal, family, name
FROM staff
JOIN department ON staff.ident = department.ident;
```

### 5. Find experiments that have not ended

```sql
SELECT *
FROM experiment
WHERE ended = NULL;
```

### 6. Count staff per department

```sql
SELECT dept, COUNT(dept)
FROM staff;
```

### 7. Find all plates for experiment 3

```sql
SELECT *
FROM plate
WHERE ident = 3;
```

### 8. Find staff who performed experiments

```sql
SELECT personal, family
FROM staff
JOIN performed;
```

### 9. Find experiments of kind biology

```sql
SELECT *
FROM experiment
WHERE kind LIKE biology;
```

### 10. List staff who never performed an experiment

```sql
SELECT personal, family
FROM staff
WHERE ident NOT IN (SELECT staff FROM performed);
```

### 11. List experiments and their plates

```sql
SELECT e.ident, p.filename
FROM experiment e
LEFT JOIN plate p;
```

### 12. Count plates per experiment

```sql
SELECT experiment, COUNT(filename)
FROM plate
GROUP BY filename;
```

### 13. Find departments with staff

```sql
SELECT name
FROM department
WHERE ident IN staff.dept;
```

### 14. Find staff who invalidated plates

```sql
SELECT personal, family
FROM staff s
JOIN invalidated i ON s.ident = i.plate;
```

### 15. Find plates invalidated after 2023

```sql
SELECT plate
FROM invalidated
WHERE invalidate_date > 2023;
```

### 16. Count experiments per kind

```sql
SELECT kind, COUNT(*)
FROM experiment
WHERE kind;
```

### 17. Find staff in the Biology department

```sql
SELECT personal, family
FROM staff
WHERE dept = 'Biology';
```

### 18. Find experiments with invalidated plates

```sql
SELECT DISTINCT experiment
FROM plate
WHERE ident IN (SELECT experiment FROM invalidated);
```

### 19. List staff and experiments they performed

```sql
SELECT s.personal, e.ident
FROM staff s, experiment e, performed p
WHERE s.ident = p.staff;
```

### 20. Find the department with the youngest average staff age

```sql
SELECT dept
FROM staff
ORDER BY AVG(age)
LIMIT 1;
```

## Queries to Write

### 1. List all departments

Show all columns for every department.

### 2. List staff names and ages

Show the personal name, family name, and age of all staff members.

### 3. Staff older than a given age

Find the personal and family names of staff who are older than 40.

### 4. Departments in a specific building

List the names of departments located in the building "Science Hall".

### 5. Experiments that have ended

List all experiments that have an end date.

### 6. Experiments of a given kind

Show the identifiers and start dates of all experiments of kind "chemistry".

### 7. Count staff members

How many staff members are in the database?

### 8. Staff per department

List each department identifier and the number of staff assigned to it.

### 9. Staff with their department names

List each staff member’s personal name, family name, and department name.

### 10. Experiments performed by staff

List the experiment IDs along with the personal and family names of staff who performed them.

### 11. Plates for each experiment

List each experiment ID and the filename of every plate associated with it.

### 12. Number of plates per experiment

Show each experiment ID and the number of plates uploaded for it.

### 13. Experiments with no end date

List experiments that are still ongoing.

### 14. Staff who performed experiments of a given kind

Find the personal and family names of staff who performed "biology" experiments.

### 15. Plates invalidated by staff

List the plate ID, invalidation date, and the family name of the staff member who invalidated it.

### 16. Plates invalidated more than once

Find plates that have been invalidated more than once.

### 17. Staff who never performed an experiment

List staff members who have never performed any experiment.

### 18. Experiments with no plates

List experiments that have no associated plates.

### 19. Department with the most staff

Find the department identifier that has the largest number of staff.

### 20. Staff involved in experiments with invalidated plates

List the distinct personal and family names of staff members who performed experiments that have at least one invalidated plate.
