-- COVID DEATHS
SELECT * FROM CovidDeaths
ORDER BY 2,3

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population	 FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Casas vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM CovidDeaths
WHERE location like '%brazil%' and continent is not null ORDER BY 1,2

-- looking at Total Cases vs Population
-- Showing what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/NULLIF(population,0))*100 as PercentPopulationInfected FROM CovidDeaths
--WHERE location like '%brazil%' 
ORDER BY 1,2

-- Looking at Country with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/NULLIF(population,0))*100 as PercentPopulationInfected 
FROM CovidDeaths
--WHERE location like '%brazil%' 
GROUP BY location, population
ORDER BY 1,2

-- Showing countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount FROM CovidDeaths
--WHERE location like '%brazil%' 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break thing by continent

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount FROM CovidDeaths
--WHERE location like '%brazil%' 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global number

SELECT SUM(new_cases) as total_case, SUM(new_deaths) as total_death, SUM(New_deaths)/ NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Global numbers per date

SELECT date, SUM(new_cases) as total_case, SUM(new_deaths) as total_death, SUM(New_deaths)/ NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

-- COVID VACCINATION

-- looking at Total Population vs Vaccinations per Day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN  CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN  CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *,(RollingPeopleVaccinated/NULLIF(Population,0))*100 FROM PopvsVac


-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN  CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *,(RollingPeopleVaccinated/NULLIF(Population,0))*100 FROM #PercentPopulationVaccinated