/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, and Creating Views

*/

SELECT*
FROM PortfolioProject..covid_deaths$
Where continent is not NULL
order by 3,4

-- Select Data that we are going to be starting with


Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
Where continent is not NULL
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths$
WHERE location like '%states%'
Where continent is not NULL
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 AS PercentofInfected
FROM PortfolioProject..covid_deaths$
WHERE location like '%states%'
and continent is not NULL
order by 1,2

--Countries with highest infenction date compared to population

Select Location, Population, MAX(total_cases) as HighestTotalCases, MAX((total_cases/population))*100 AS 
	PercentofInfected
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY Location, population
ORDER BY PercentofInfected desc

---- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
Where continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as 
	int))/SUM (New_cases) * 100 as DeathPercentage 
FROM PortfolioProject..covid_deaths$
--WHERE location like '%states%'
WHERE continent is not NULL
--GROUP BY Date 
order by 1,2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..covid_deaths$ AS dea
join PortfolioProject..Covid_Vaccinations$ AS vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..covid_deaths$ AS dea
join PortfolioProject..Covid_Vaccinations$ AS vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)
Select *, (((RollingPeopleVaccinated / 2) / Population) * 100) AS PercentageFullyVaccinated
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationFullyVaccinated
CREATE Table #PercentPopulationFullyVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO  #PercentPopulationFullyVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..covid_deaths$ AS dea
join PortfolioProject..Covid_Vaccinations$ AS vac
	On dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not NULL
--order by 2,3

Select *, (((RollingPeopleVaccinated / 2) / Population) * 100) AS PercentageFullyVaccinated
From #PercentPopulationFullyVaccinated

-- Creating View to store data for later visualizations

Create View PeopleVaccinated as

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..covid_deaths$ AS dea
join PortfolioProject..Covid_Vaccinations$ AS vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3

CREATE View PercentFullyVaccinated as
With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..covid_deaths$ AS dea
join PortfolioProject..Covid_Vaccinations$ AS vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)
Select *, (((RollingPeopleVaccinated / 2) / Population) * 100) AS PercentageFullyVaccinated
From PopvsVac


--SELECT *
--From PercentPopulationFullyVaccinated