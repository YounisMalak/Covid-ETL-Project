-- checking if data imported correctly

SELECT *
FROM CovidDatabase..CovidDeaths
ORDER BY location, date

SELECT *
FROM CovidDatabase..CovidVaccinations
ORDER BY location, date

--selecting relevant data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDatabase..CovidDeaths
ORDER BY location, date

--deaths per total cases

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentOfDeaths
FROM CovidDatabase..CovidDeaths
ORDER BY location, date

--deaths per total cases in Israel

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as percentOfDeaths
FROM CovidDatabase..CovidDeaths
WHERE location = 'Israel'
ORDER BY location, date

--total cases per population in Israel

SELECT location, date, total_cases, population,(total_cases/population)*100 as percentOfCases
FROM CovidDatabase..CovidDeaths
WHERE location = 'Israel'
ORDER BY location, date

--countries with highest infection percentage by population

SELECT location, population, MAX(total_cases) as highestCasesCount, MAX((total_cases/population))*100 as percentOfCases
FROM CovidDatabase..CovidDeaths
GROUP BY location, population
ORDER BY percentOfCases desc

--countries with highest death rate

SELECT location, MAX(cast(total_deaths as int))*100 as highestdeathCount
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY highestdeathCount desc

--continents with highest death rate

SELECT continent, MAX(cast(total_deaths as int)) as highestdeathCount
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY highestdeathCount desc

--Global Numbers

--death percantage globally by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date, SUM(new_cases)

--death percantage globally in general

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
ORDER BY SUM(new_cases)

-- joinig tables CovidDeaths and CovidVaccinations on location and date

SELECT *
FROM CovidDatabase..CovidDeaths dea JOIN CovidDatabase..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date

-- Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDatabase..CovidDeaths dea JOIN CovidDatabase..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date

-- aggregate total number of vaccinatuions by partitioning by location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as VaccinationsSoFar
FROM CovidDatabase..CovidDeaths dea JOIN CovidDatabase..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date

-- percentage of population that is vaccinated

-- aggregate total number of vaccinatuions by partitioning by location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as VaccinationsSoFar
FROM CovidDatabase..CovidDeaths dea JOIN CovidDatabase..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date

--Using CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination,VaccinationsSoFar)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as VaccinationsSoFar
FROM CovidDatabase..CovidDeaths dea JOIN CovidDatabase..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT* , (VaccinationsSoFar/Population)*100 as percentOfPopulationVaccinated
FROM PopvsVac


-- Creating view to store data for future visualizations


CREATE VIEW percentOfVaccinatedFromPopulation as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as VaccinationsSoFar
FROM CovidDatabase..CovidDeaths dea JOIN CovidDatabase..CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

-- querying on view

SELECT *
FROM percentOfVaccinatedFromPopulation