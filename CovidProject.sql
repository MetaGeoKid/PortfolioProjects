SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4

/* SELECT *
FROM CovidVaccines
ORDER BY 3,4 */

-- Select Data we are going to be using

SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at the total cases vs total deaths in the United States

SELECT [location], [date], total_cases, total_deaths, ((total_deaths * 1.0)/(total_cases*1.0))*100 AS DeathRate
FROM CovidDeaths
WHERE [location] like '%states%'
ORDER BY 1,2

-- Looking at Total cases vs Populations

SELECT [location], [date], total_cases, population, ((total_cases*1.0)/(population*1.0))*100 AS RateOfInfection
FROM CovidDeaths
WHERE [location] like '%states%'
ORDER BY 1,2


-- Looking at countries with the highest infection rates compared to population

SELECT [location], MAX(total_cases) AS HighestInfectionCount, population, ((MAX(total_cases)*1.0)/(population*1.0))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Looking at Countries with highest death count per population

SELECT [location], MAX(total_deaths) AS TotalDeaths, population, ((MAX(total_deaths)*1.0)/(population*1.0))*100 AS PercentPopulationDied
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC


-- Looking at Continents with  highest death count

SELECT [continent], MAX(total_deaths) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC


-- Global Numbers

SELECT [date], SUM(new_cases) CasesPerDay, SUM(new_deaths) DeathsPerDay, (SUM(new_deaths * 1.0)/SUM(new_cases*1.0))*100 AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases != 0
GROUP BY date
ORDER BY 1,2

-- Looking at Total Populaiton vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.date = vac.[date]
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (Continent, location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.date = vac.[date]
WHERE dea.continent IS NOT NULL 
)

SELECT *, ((Rolling_People_Vaccinated*1.00)/(Population*1.00))*100 AS Percent_of_Population_Vaccinated
FROM PopvsVac
ORDER BY 2,3

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulatuionVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC
)

INSERT INTO #PercentPopulatuionVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.date = vac.[date]
WHERE dea.continent IS NOT NULL 

SELECT *, ((Rolling_People_Vaccinated*1.00)/(Population*1.00))*100 AS Percent_of_Population_Vaccinated
FROM #PercentPopulatuionVaccinated
ORDER BY 2,3


-- Creating View to store data for later visualtions

CREATE VIEW TotalDeathsByContinent AS
SELECT [continent], MAX(total_deaths) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent


CREATE VIEW PercentPopulatuionVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location] = vac.[location]
    AND dea.date = vac.[date]
WHERE dea.continent IS NOT NULL

-- Which country had the highest death rate from each continent