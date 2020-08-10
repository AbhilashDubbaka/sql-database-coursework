# SQL Database Coursework

This database coursework was completed as part of MSc Computing Science at Imperial College London. The repo contains SQL file with all the SQL queries, which are also outlined below under their respective question. The database could not be provided but an image showing the extract of the data is shown below:
[![Database Extract](Database_Extract.png "Database Extract")]

**Question 1**

Write an SQL query returning the scheme (name) ordered by name that lists men not known to be fathers.

**SQL Query:** 
```sql
SELECT   name
FROM     person
WHERE    gender = 'M'
EXCEPT
SELECT   father
FROM     person
ORDER BY name;
```

**Question 2**

Write an SQL query that returns the scheme (name) ordered by name containing the name of mothers who have had every gender of baby that appears in the database. You must not
write the query to assume that gender is limited to ’M’ and ’F’.

**SQL Query:** 
```sql
SELECT   name
FROM     person AS mother
WHERE    NOT EXISTS (SELECT gender
                     FROM   person
                     EXCEPT
                     SELECT gender
                     FROM   person
                     WHERE  mother.name = person.mother
                    )
ORDER BY name;
```

**Question 3**

Write a query that returns the scheme (name, father, mother) ordered by name that lists the name of people who are the first born of their known full siblings. A full sibling is defined as a person sharing the same father and mother.

**SQL Query:** 
```sql
SELECT   name, father, mother
FROM     person
WHERE    dob <= ALL (SELECT person_b.dob
                     FROM   person AS person_b
                     WHERE  person.father = person_b.father
                     AND    person.mother = person_b.mother
                    )
AND      father IS NOT NULL
AND      mother IS NOT NULL
ORDER BY name;
```

**Question 4**

Write an SQL query that returns the scheme (name, popularity) ordered by popularity, name listing first names and the number of occurances of first names. A first name is taken to mean the first word appearing the name column. The most popular first name must be listed first, and the list must exclude any first name that appears only once.

**SQL Query:** 
```sql
SELECT   person.name,
         COUNT(*) AS popularity
FROM     (SELECT CASE WHEN POSITION(' ' IN name) = 0 THEN name
             	   ELSE SUBSTRING(name FROM 1 FOR (POSITION(' ' IN name) -1)) END AS name
          FROM person
         ) AS person
GROUP BY person.name
HAVING   COUNT(*) > 1
ORDER BY popularity DESC, person.name;
```

**Question 5**

Write an SQL query that returns the scheme (name, forties, fifties, sixties) ordered by name listing one row for each person in the database whom has had at least two children, and for each such person, gives three columns forties, fifties and sixties containing the number of that person’s children born in those 20th century decades.

**SQL Query:** 
```sql
SELECT 	 parent.name,
         COUNT(CASE WHEN child.dob >= '1940-01-01' AND child.dob < '1950-01-01'
               THEN child.name ELSE NULL END) AS forties,
         COUNT(CASE WHEN child.dob >= '1950-01-01' AND child.dob < '1960-01-01'
               THEN child.name ELSE NULL END) AS fifties,
         COUNT(CASE WHEN child.dob >= '1960-01-01' AND child.dob < '1970-01-01'
               THEN child.name ELSE NULL END) AS sixties
FROM     person AS parent
         JOIN person AS child
         ON child.father = parent.name
         OR child.mother = parent.name
GROUP BY parent.name
HAVING   COUNT(parent.name) > 1
ORDER BY parent.name;
```

**Question 6**

Write an SQL query returning the scheme (father, mother, child, born) that lists known fathers and mothers of children, with born being the number of the child of the parents (i.e. returning 1 for the first born, 2 for the second born, etc). The result should be ordered by father, mother, born.

**SQL Query:** 
```sql
SELECT   father, mother, name AS child,
         RANK() OVER (PARTITION BY father, mother ORDER BY dob) AS born
FROM     person
WHERE    father IS NOT NULL
AND      mother IS NOT NULL
ORDER BY father, mother, born;
```

**Question 7**

Write an SQL query that returns the scheme (father, mother, male) ordered by father,mother that lists all pairs of known parents with the percentage (as a whole number) of their children that are male.

**SQL Query:** 
```sql
SELECT   father, mother,
         ROUND(100.0 * COUNT(CASE WHEN gender = 'M' THEN gender ELSE NULL END) / COUNT(*)) AS male
FROM     person
WHERE    father IS NOT NULL
AND      mother IS NOT NULL
GROUP BY father, mother
ORDER BY father, mother;
```
