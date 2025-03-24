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
