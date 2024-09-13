SELECT *
FROM Project_portfolio_covid..CovidDeaths
ORDER BY 3,4

SELECT *
FROM Project_portfolio_covid..CovidVac
ORDER BY 3,4

DELETE FROM Project_portfolio_covid..CovidDeaths
WHERE total_cases = 0

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project_portfolio_covid..CovidDeaths
ORDER BY 1,2

--DeathPercantage in US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercantage
FROM Project_portfolio_covid..CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2 


--InfectionRate in US
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS InfectionRate
FROM Project_portfolio_covid..CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2

--Highest infection rate by country
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS InfectionRate
FROM Project_portfolio_covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--Highest Death Count per Location
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM Project_portfolio_covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Highest Death Count per Continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM Project_portfolio_covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- Global numbers

SELECT  date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM Project_portfolio_covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) <>0
ORDER BY 1,2 


--Total Population vs Vaccination
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_portfolio_covid..CovidDeaths dea
JOIN Project_portfolio_covid..CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PercentageofVaccinatedPeople
FROM PopvsVac

--TEMP
DROP TABLE IF EXISTS #PercentageofVaccinatedPeople
CREATE TABLE #PercentageofVaccinatedPeople
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentageofVaccinatedPeople
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_portfolio_covid..CovidDeaths dea
JOIN Project_portfolio_covid..CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PercentageofVaccinatedPeople
FROM #PercentageofVaccinatedPeople


--Views for visualisations

CREATE VIEW PercentageofVaccinatedPeople as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_portfolio_covid..CovidDeaths dea
JOIN Project_portfolio_covid..CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentageofVaccinatedPeople
