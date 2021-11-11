--Queries for Tableau visualization


--Query 1:
 
SELECT 
		SUM(new_cases) as Total_Cases, SUM(CONVERT(int, new_deaths)) AS Total_Deaths,
		ROUND((SUM(CONVERT(int, new_deaths)) / SUM(new_cases)) * 100, 2) AS PercentDeathCount
FROM
		PortfolioProject..CovidDeaths
WHERE 
		continent IS NOT NULL



--Query 2:
SELECT
		location, SUM(CONVERT(int, new_deaths)) AS TotalDeatCount
FROM 
		PortfolioProject..CovidDeaths
WHERE
		continent IS  NULL
AND
		location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeatCount DESC


--Query 3: 

SELECT
		location, population, MAX(total_cases) AS HighestInfectionCount, 
		ROUND(MAX(total_cases / population) * 100, 2) AS PercentPopulationInfected
FROM
		PortfolioProject..CovidDeaths
WHERE
		continent IS NOT  NULL
--AND 
--		location IN ('World', 'European Union', 'International')
GROUP BY
		location, population
ORDER BY
		PercentPopulationInfected DESC


--Query 4:

SELECT
		location, date, population, MAX(total_cases) AS HighestInfectionCount,
		ROUND(MAX(total_cases / population) * 100, 2) AS PercentPopulationInfected
FROM
		PortfolioProject..CovidDeaths
WHERE
		continent IS NOT NULL		
GROUP BY
		location, date, population
ORDER BY HighestInfectionCount DESC