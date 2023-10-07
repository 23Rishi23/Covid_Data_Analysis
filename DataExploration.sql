SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Exploring Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


--Comparing Total cases vs Total deaths
--Comparison is also done across individual countries
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India'
ORDER BY 1,2


--Comparing Highest Infection Count vs Percentage of population Infectioned
SELECT location, population, MAX(CONVERT(float, total_cases)) AS HighestInfectionCount, MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

	
--Showing Countries with highest Death count per population
SELECT location, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Without the following line, continent's and income level's death counts are also added
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Diving into the different continents
SELECT continent, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Without the following line, continent's and income level's death counts are also added
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

	
--Checking Global Levels
SELECT SUM(CONVERT(float, new_cases)) AS total_cases, SUM(CONVERT(float, new_deaths)) AS total_deaths, (SUM(CONVERT(float, new_deaths))/SUM(NULLIF(CONVERT(float, new_cases), 0)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


----EXPLORING DIFFERENT WAYS TO UTILIZE NEWLY MADE COLUMNS (CTE, TEMP TABLE, VIEWS)
--Using a CTE
With PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
	--Moving over to Covid Vaccinations
	--Looking Total Population vs. Vaccinations
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *,  (rolling_vaccinations/population)*100 AS PercentPopulationVaccinated
FROM PopVsVac

	
-- TempTable
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population Numeric,
	New_Vaccinations float,
	Rolling_Vaccinations float 
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Rolling_vaccinations/Population * 100)
FROM #PercentPeopleVaccinated
ORDER BY Location, Date


--Creating View for later Visualizations
Create View PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
