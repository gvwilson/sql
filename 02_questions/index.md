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

## 1. List all departments

Show all columns for every department.

## 2. List staff names and ages

Show only the personal name, family name, and age of all staff members.

## 3. Staff older than a given age

Show the personal and family names of staff who are older than 40 as a single column.
(Hint: `||` glues text together.)

## 4. Departments in a specific building

Show the names of departments located in the Chesson Building.

## 5. Experiments that have not ended

List all experiments that have no end date.

## 6. Experiment range

Show the earliest and latest start dates of the experiments that have ended.

## 7. Count staff members

How many staff members are in the database?

## 8. Staff per department

List each department identifier and the number of staff assigned to it.
How do you handle staff who aren't assigned to a department?

## 9. Staff with their department names

List each staff member's personal name, family name, and department name (not department ID).

## 10. Experiments performed by staff

Count the number of experiments of each kind that each staff member helped perform.

## 11. Number of plates per experiment

Show each experiment ID and the number of plates uploaded for it.

## 12. Plates for each experiment

List each experiment ID and the filename of every plate associated with it,
with the filenames in a single column.
(Hint: look at the `group_concat` function.)

## 13. Short experiments

Count experiments that ended on the same day they started.

## 14. Staff who performed experiments of a given kind

Find the personal and family names of staff who performed calibration experiments.
List each staff member once.
Hint: you will need to use the `performed` table to combine `staff` and `experiment`.

## 15. Plates invalidated by staff

Show the plate ID and invalidation date of every invalidated plate
along with the family name of the staff member who invalidated it.

## 16. Plates invalidated more than once

Have any plates been invalidated more than once?

## 17. Staff who never performed an experiment

List staff members who have never performed any experiment.

## 18. Experiments with no plates

List experiments that have no associated plates.

## 19. Department with the most staff

Show the name of the department with the most staff.

## 20. Staff involved in experiments with invalidated plates

List the names of staff members who performed experiments that have at least one invalidated plate.
