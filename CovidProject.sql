SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population contracted COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC



-- Showing the global numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as bigint)) AS Total_Deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	ORDER BY 2,3







	-- CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as 
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	--ORDER BY 2,3
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac





	-- TEMP TABLE
	DROP TABLE if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)




	Insert into #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
	--ORDER BY 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	FROM #PercentPopulationVaccinated







-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated