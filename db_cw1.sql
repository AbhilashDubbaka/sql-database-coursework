--Q1 returns (name)
SELECT   name
FROM     person
WHERE    gender = 'M'
EXCEPT
SELECT   father
FROM     person
ORDER BY name
;

--Q2 returns (name)
SELECT   name
FROM     person AS mother
WHERE    NOT EXISTS (SELECT gender
                     FROM   person
                     EXCEPT
                     SELECT gender
                     FROM   person
                     WHERE  mother.name = person.mother
                    )
ORDER BY name
;

--Q3 returns (name,father,mother)
SELECT   name, father, mother
FROM     person
WHERE    dob <= ALL (SELECT person_b.dob
                     FROM   person AS person_b
                     WHERE  person.father = person_b.father
                     AND    person.mother = person_b.mother
                  )
AND      father IS NOT NULL
AND      mother IS NOT NULL
ORDER BY name
;

--Q4 returns (name,popularity)
SELECT   person.name,
         COUNT(*) AS popularity
FROM     (SELECT CASE WHEN POSITION(' ' IN name) = 0 THEN name
             	   ELSE SUBSTRING(name FROM 1 FOR (POSITION(' ' IN name) -1)) END AS name
          FROM person
         ) AS person
GROUP BY person.name
HAVING   COUNT(*) > 1
ORDER BY popularity DESC, person.name
;

--Q5 returns (name,forties,fifties,sixties)
SELECT 	 parent.name,
         COUNT(CASE WHEN child.dob >= '1940-01-01' AND child.dob < '1950-01-01'
               THEN child.name ELSE NULL END) AS forties,
         COUNT(CASE WHEN child.dob >= '1950-01-01' AND child.dob < '1960-01-01'
               THEN child.name ELSE NULL END) AS fifties,
         COUNT(CASE WHEN child.dob >= '1960-01-01' AND child.dob < '1970-01-01'
               THEN child.name ELSE NULL END) AS sixties
FROM 	   person AS parent
         JOIN person AS child
         ON child.father = parent.name
         OR child.mother = parent.name
GROUP BY parent.name
HAVING   COUNT(parent.name) > 1
ORDER BY parent.name
;

--Q6 returns (father,mother,child,born)
SELECT   father, mother, name AS child,
	       RANK() OVER (PARTITION BY father, mother ORDER BY dob) AS born
FROM     person
WHERE    father IS NOT NULL
AND      mother IS NOT NULL
ORDER BY father, mother, born
;

--Q7 returns (father,mother,male)
SELECT   father, mother,
	       ROUND(100.0 * COUNT(CASE WHEN gender = 'M' THEN gender ELSE NULL END) / COUNT(*)) AS male
FROM     person
WHERE    father IS NOT NULL
AND      mother IS NOT NULL
GROUP BY father, mother
ORDER BY father, mother
;