-- DEATHS

SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Select the data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Total Cases vs Total Deaths (Death Risk Percentage)
-- Shows the likelihood of dying if you contract covid in every country.
SELECT location, date, total_cases, total_deaths, FORMAT((total_deaths/total_cases), 'P') as deathpercentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- BY POPULATION

--Total Cases vs Population
--Shows the percentage of the population that contracted covid.
SELECT location, date, total_cases, population, FORMAT((total_cases/population), 'P') as PopulationPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Philippines%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY InfectedPopulationPercent DESC

--Countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) AS DeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount DESC

--BY CONTINENT

--Countries with the highest death count per continent
SELECT continent, MAX(CAST(total_deaths as int)) AS DeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount DESC



--Global numbers
SELECT date, SUM(total_cases) as TotalCases, SUM(CAST(total_deaths as int)) as TotalDeaths, FORMAT(SUM(CAST(new_deaths as int))/SUM(new_cases), 'P') as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- VACCINATIONS
--Total Population vs Total Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ as d
JOIN PortfolioProject..CovidVaccinations$ as v
    ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

--PHP CTE
WITH PvsV (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by d.location Order by d.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ AS d
JOIN PortfolioProject..CovidVaccinations$ AS v
    ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/Population)*100 AS RPVPercentage
FROM PvsV


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ AS d
JOIN PortfolioProject..CovidVaccinations$ AS v
    ON d.location = v.location
	and d.date = v.date
--WHERE d.continent is not null
--ORDER BY 2,3

SELECT*,(RollingPeopleVaccinated/Population)*100 AS RPVPercentage
FROM #PercentPopulationVaccinated

--Creating View to store data for visualizations
CREATE VIEW PV AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ AS d
JOIN PortfolioProject..CovidVaccinations$ AS v
    ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3
 
 SELECT *
 FROM PV