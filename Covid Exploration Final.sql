SELECT *
FROM [CovidDeaths]
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project Exploration]..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in USA
SELECT Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
FROM [CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, Population, date, total_cases, 
(total_deaths/population)*100 as PercentPopulationInfected
FROM [CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [CovidDeaths]
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [CovidDeaths]
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- By Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [CovidDeaths]
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

-- USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [CovidDeaths] dea
Join [CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [CovidDeaths] dea
Join [CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [CovidDeaths] dea
Join [CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null