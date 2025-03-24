# World-life-expectancy
## Cleaned data and performed exploratory data analysis using MySQL
### Data cleaning code
```
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
```

### Exploratory data analysis code
```
SELECT *
FROM worldlifexpectancy;


SELECT Year,
	ROUND(AVG(Lifeexpectancy), 2) AS Avg_LfExp,
    ROUND(AVG(infantdeaths), 2) AS Avg_InfDth,
    ROUND(AVG(percentageexpenditure), 2) AS Avg_PerExp,
    ROUND(AVG(Schooling), 2) AS Avg_Sch
FROM worldlifexpectancy
GROUP BY 1
ORDER BY 1; -- Global averages of important metrics over the years


WITH cte AS
	(SELECT Country,
		Year,
		Lifeexpectancy,
        AdultMortality,
        LEAD(AdultMortality, 1) OVER(PARTITION BY Country ORDER BY Year) AS Next_yr_Adlmor,
		LEAD(Lifeexpectancy, 1) OVER(PARTITION BY Country ORDER BY Year) AS Next_yr_Lfexp
	FROM worldlifexpectancy)
SELECT Country,
	Year + 1 AS Year_of_lifeexp_drop,
    ROUND((Next_yr_Adlmor - AdultMortality), 2) AS Adlmore_diff,
    ROUND((Next_yr_Lfexp - Lifeexpectancy), 2) AS Lfexp_diff
FROM cte
WHERE (Next_yr_Lfexp - Lifeexpectancy) < 0; -- Identifying which years life expectancy dropped for each country and understanding if there is any correlation with adult mortality


WITH cte AS
	(SELECT Country AS c1,
		MAX(Lifeexpectancy) AS max,
		MIN(Lifeexpectancy) AS min
	FROM worldlifexpectancy
	GROUP BY 1)
SELECT cte.c1 AS Country,
	cte.max AS max1,
	CASE WHEN wle.Lifeexpectancy = cte.max THEN wle.Year END AS Year_max_Lfexp,
	cte.min AS min1,
	CASE WHEN wle.Lifeexpectancy = cte.min THEN wle.Year END AS Year_min_Lfexp
FROM cte
JOIN worldlifexpectancy AS wle
ON cte.c1 = wle.Country
	AND (cte.max = wle.Lifeexpectancy
		OR cte.min = wle.Lifeexpectancy); -- Identifying maximum and minimum life expectancy for each country and which year those occurred 


SELECT SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
	ROUND(AVG(CASE WHEN GDP >= 1500 THEN Lifeexpectancy ELSE NULL END), 2) AS High_GDP_Lfexp,
    SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
    ROUND(AVG(CASE WHEN GDP < 1500 THEN Lifeexpectancy ELSE NULL END), 2) AS Low_GDP_Lfexp
FROM worldlifexpectancy; -- Trying to find a correlation between GDP and life expectancy
```
