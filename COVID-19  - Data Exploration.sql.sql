/*
COVID-19 DATA EXPLORATION 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


--Select Data and Columns to be used for analysis

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--1
-- Percentage of Total Deaths to Total Cases
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases*100),2) AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%ghana%'
ORDER BY 5 DESC


--2
--Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, ROUND((total_cases/population*100),2) AS cases_percentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%ghana%'
ORDER BY 1,2


--3
--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX(total_cases/population*100),2) AS infection_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY infection_percentage DESC


--4
--Countries with Highest Death Count

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- BREAKING THINGS DOWN BY CONTINENT

--5
-- Contintents with Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY total_death_count DESC


--6
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--7
-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,5)
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, ROUND((RollingPeopleVaccinated/Population)*100,2)
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 












