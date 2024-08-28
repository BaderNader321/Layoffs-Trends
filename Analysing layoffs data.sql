-- Layoffs Data from 2022 to 2023 

SELECT * FROM layoffs_staging2; 

-- > which company had 100 percent of their employees laid off
SELECT company, total_laid_off, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
	ORDER BY total_laid_off DESC; 


-- > Companies who had raised millions and laid off 100% of their employees
SELECT company, funds_raised_millions, stage
FROM layoffs_staging2
WHERE percentage_laid_off = 1
	ORDER BY funds_raised_millions DESC;


-- > Companies who gets series A funding 
SELECT company, funds_raised_millions, stage
FROM layoffs_staging2
WHERE stage LIKE "%Series%"
	ORDER BY stage;


-- > Top 10 company with most total layoffs
SELECT company, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
	GROUP BY company
	ORDER BY total_layoffs DESC
	LIMIT 10; 

    
-- > Company with biggest layoffs in single day
SELECT company, total_laid_off
FROM layoffs_staging2
	ORDER BY total_laid_off DESC;


-- > Top 10 company which had most layoffs during pandemic 
SELECT company, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE EXTRACT(YEAR FROM date) = 2020
	GROUP BY company
	ORDER BY total_layoffs DESC;


-- > Total layoffs by each year 
SELECT YEAR(date) AS year, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE YEAR(date) IS NOT NULL
	GROUP BY YEAR(date) 
	ORDER BY year, total_layoffs DESC;


-- > By Year and Month 
SELECT YEAR(date) AS year, MONTH(date) AS month, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE YEAR(date) IS NOT NULL
	GROUP BY YEAR(date), MONTH(date) 
	ORDER BY year, month, total_layoffs DESC;


-- > Total layoffs by each country
SELECT country,
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE country IS NOT NULL 
	GROUP BY country
	ORDER BY total_layoffs DESC;


-- > Total layoffs by stage of funding  
SELECT stage, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
	GROUP BY stage
	ORDER BY total_layoffs DESC;


-- > Post IPO Companies with most layoffs 
SELECT company, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE stage = "Post-IPO" AND total_laid_off IS NOT NULL
	GROUP BY company
	ORDER BY total_layoffs DESC;


-- > By each country and location
SELECT country, location, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE country IS NOT NULL
	GROUP BY country, location 
	ORDER BY country, total_layoffs DESC;


-- > Total layoffs by Industry 
SELECT industry, 
	SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE country IS NOT NULL
	GROUP BY industry
	ORDER BY total_layoffs DESC;


-- > Rolling total of layoffs per month 
WITH cte_rt AS ( 
	SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
		GROUP BY dates
		ORDER BY dates ASC
)
SELECT dates, total_layoffs,
	SUM(total_layoffs) OVER(ORDER BY dates ASC) AS rolling_total
FROM cte_rt
WHERE dates IS NOT NULL
	ORDER BY dates ASC;


-- > Ranking the companies based on the most layoffs for each year 
WITH cpy_layoffs AS (
	SELECT YEAR(date) AS year, company, 
		SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
	WHERE YEAR(date) IS NOT NULL
		GROUP BY YEAR(date), company
		ORDER BY year ASC, total_layoffs DESC 
), cpy_ranking AS (
	SELECT *, 
		DENSE_RANK() OVER(PARTITION BY year ORDER BY total_layoffs DESC) AS rank_num
	FROM cpy_layoffs
)
SELECT *
FROM cpy_ranking
WHERE rank_num <= 5
	ORDER BY year ASC, total_layoffs DESC; 







