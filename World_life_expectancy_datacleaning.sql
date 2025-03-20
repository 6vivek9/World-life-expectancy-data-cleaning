SELECT *
FROM worldlifexpectancy;

WITH cte AS
	(SELECT Row_ID,
			CONCAT(Country, Year) AS CY,
			ROW_NUMBER() OVER(PARTITION BY (CONCAT(Country, Year)) ORDER BY (CONCAT(Country, Year))) AS rn
		FROM worldlifexpectancy)
SELECT Row_ID,
	CY,
    rn
FROM cte
WHERE rn >1; -- Identifying duplicates 

DELETE FROM worldlifexpectancy
WHERE Row_ID IN (WITH cte AS
		(SELECT Row_ID,
				CONCAT(Country, Year) AS CY,
				ROW_NUMBER() OVER(PARTITION BY (CONCAT(Country, Year)) ORDER BY (CONCAT(Country, Year))) AS rn
			FROM worldlifexpectancy)
	SELECT Row_ID
	FROM cte
	WHERE rn >1); -- Removing duplicates

SELECT *
FROM worldlifexpectancy
WHERE Status = ''; -- Identifying blank values in Status column


SELECT Status
FROM worldlifexpectancy
GROUP BY 1; -- Identifying types of status

UPDATE worldlifexpectancy AS w1
JOIN worldlifexpectancy AS w2
	ON w1.Country = w2.Country
SET w1.Status = 'Developing'
WHERE w1.Status = ''
	AND w2.Status <> ''
    AND w2.Status = 'Developing'; -- Adding 'Developing' status empty rows of Developing countries

UPDATE worldlifexpectancy AS w1
JOIN worldlifexpectancy AS w2
	ON w1.Country = w2.Country
SET w1.Status = 'Developed'
WHERE w1.Status = ''
	AND w2.Status <> ''
    AND w2.Status = 'Developed'; -- Adding 'Developed' status empty rows of Developed countries

SELECT *
FROM worldlifexpectancy
WHERE Lifeexpectancy = ''; -- Identifying empty life expectancy values

 UPDATE worldlifexpectancy AS w1
 JOIN worldlifexpectancy AS w2
	ON w1.Country = w2.Country
    AND w1.Year = w2.Year + 1
JOIN worldlifexpectancy AS w3
	ON w1.Country = w3.Country
    AND w1.Year = w3.Year - 1
SET w1.Lifeexpectancy = ROUND((w2.Lifeexpectancy + w3.Lifeexpectancy)/2, 1)
WHERE w1.Lifeexpectancy = ''; -- Adding average of life expectancy of previous year and next year to empty values


  