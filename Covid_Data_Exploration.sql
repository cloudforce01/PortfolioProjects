
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 3, 4

--Select Data that we are going to be starting with

SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 1, 2

-- Looking at total_cases vs total_deaths

SELECT 
	location, date, total_deaths, total_cases, ROUND((total_deaths/total_cases) * 100,2) as deathpercentage, population
FROM 
	PortfolioProject..CovidDeaths
--WHERE 
	--location like '%states%'
WHERE 
	continent is not null
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying while getting covid in the respective coutries.

SELECT 
	location, date, total_deaths, total_cases, population, ROUND((total_cases/population) *100, 2) as PercentPopulationInfected
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
	   location, population, MAX(total_cases) as HighestInfectionRate,
	   MAX(ROUND((total_cases/population) *100, 2)) as PercentPopulationInfected
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	location, population
ORDER BY 
	PercentPopulationInfected desc


-- Countries with Highest Infection Rate compared to Population

SELECT 
	location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
GROUP BY 
	location
ORDER BY 
	TotalDeaths desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Let's break things down by continent

-- Showing contintents with the highest death count per population

SELECT 
	location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is  null
GROUP BY 
	location
ORDER BY 
	TotalDeaths desc

	   
-- Global number new cases vs new deaths

SELECT  
	SUM(new_cases) as Total_New_Cases, ROUND(SUM(CAST(new_deaths as int)),2) as Total_New_Deaths, 
	ROUND( (SUM(CAST(new_deaths as int)) / SUM(new_cases) ) * 100, 2)  as TotalNewDeathsInPercent
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM 
	PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON
	dea.location = vac.location
WHERE 
	dea.date = vac.date
ORDER BY 2, 3


-- Calculation rolling count of new_vaccinations to find out the population vs vaccinations ratio in percentage.

-- Using CTE to perform Calculation on Partition By in previous query


WITH CTEPopVsVac (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, VACCINATEDROLLINGCOUNT)
AS
(

SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinatedRollingCount
FROM 
	PortfolioProject..CovidDeaths dea 
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON 
		dea.location = vac.location
	AND  
		dea.date = vac.date
WHERE 
	dea.continent is not null
)


SELECT 
	*, ROUND( ( VACCINATEDROLLINGCOUNT / POPULATION ) * 100, 3) AS PERCENTVACCINATED  
FROM 
	CTEPopVsVac
WHERE 
	VACCINATEDROLLINGCOUNT IS NOT NULL
AND 
	LOCATION LIKE '%states%'



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #VaccinatedPerPopulation

CREATE TABLE #VaccinatedPerPopulation
(
CONTINENT nvarchar(255),
LOCATION nvarchar(255),
DATE datetime,
POPULATION int,
VACCINATED numeric,
VACCINATEDROLLINGCOUNT float
)

INSERT INTO #VaccinatedPerPopulation 
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinatedRollingCount
FROM 
	PortfolioProject..CovidDeaths dea 
JOIN 
	PortfolioProject..CovidVaccinations vac
	ON 
		dea.location = vac.location
	AND  
		dea.date = vac.date
WHERE 
	dea.continent is not null


SELECT 
	*, ROUND ( ( VACCINATEDROLLINGCOUNT/POPULATION ) * 100, 3)  PERCENTVACCINATED FROM #VaccinatedPerPopulation
WHERE 
	VACCINATEDROLLINGCOUNT IS NOT NULL
AND 
	LOCATION LIKE '%INDIA%'
ORDER BY 2, 3



-- Creating View to store data for later visualizations


CREATE VIEW VW_VaccinatedPerPopulation
AS
(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinatedRollingCount
FROM 
	PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
AND  
	dea.date = vac.date
WHERE 
	dea.continent is not null
)

SELECT 
	*, ROUND((VaccinatedRollingCount/population) * 100, 2) AS PercentVaacinated 
FROM 
	VW_VaccinatedPerPopulation


SELECT 
	   dea.iso_code, dea.continent, dea.location, dea.date, dea.new_cases, 
	   dea.total_cases, dea.new_deaths, dea.total_deaths, vac.new_vaccinations 
FROM 
	PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
AND 
	dea.date = vac.date










