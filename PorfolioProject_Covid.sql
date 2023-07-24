SELECT * 
	FROM [Portfolio Project]..CovidDeaths
	where continent is not NULL
	Order By 3,4
	;


/*
SELECT * 
	FROM [Portfolio Project]..CovidVaccinations$
	Order By 3,4
	;
*/

SELECT location, date, total_cases, new_cases, total_deaths,population
	FROM [Portfolio Project]..CovidDeaths
	where continent is not NULL
	Order By 1,2;


-- getting total cases vs total deaths (death rate)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
	FROM [Portfolio Project]..CovidDeaths
	WHERE location like '%india%' and continent is not NULL
	Order By 1,2
	;


-- total cases vs population
-- Percentage of people out of all the population that are infected by Covid

SELECT location, date, population, total_cases,(total_cases/population)*100 AS InfectionRate
	FROM [Portfolio Project]..CovidDeaths
	--WHERE location like '%india%'
	Order By 1,2
	;

-- Country that has highest infection rate
SELECT location, population, MAX(total_cases) AS MaxTotalCasesCount, MAX((total_cases/population))*100 AS InfectionRate
	FROM [Portfolio Project]..CovidDeaths
	Group By location, population
	Order By 4 DESC
	;


-- Countries with higest death count per population
SELECT location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
	FROM [Portfolio Project]..CovidDeaths
	where continent is not NULL
	Group By location, population
	Order By TotalDeathCount DESC
	;


--death rate by continent
-- highest death count per population by continent 

SELECT continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
	FROM [Portfolio Project]..CovidDeaths
	where continent is not NULL
	Group By continent
	Order By TotalDeathCount DESC
	;

/*
SELECT location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
	FROM [Portfolio Project]..CovidDeaths
	where continent is NULL
	Group By location
	Order By TotalDeathCount DESC
	;
*/


-- Global Numbers 

SELECT date,
 SUM(new_cases) As TotalCases, SUM(Cast(new_deaths as int)) As totalDeathCount,  SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS deathRate
	FROM [Portfolio Project]..CovidDeaths
	where continent is not NULL
	Group By date
	Order By deathRate DESC
	;


--sum of all the global new cases, total death count and death rate
SELECT  SUM(new_cases) As TotalCases, SUM(Cast(new_deaths as int)) As totalDeathCount,  SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS deathRate
	FROM [Portfolio Project]..CovidDeaths
	where continent is not NULL
	--Group By date
	Order By deathRate DESC
	;

--------------------USING VACCINATION DATA----------------------------


SELECT * FROM [Portfolio Project]..CovidVaccinations


SELECT * 
	FROM [Portfolio Project]..CovidDeaths da
	Join [Portfolio Project]..CovidVaccinations vac
	ON da.location = vac.location
	and da.date = vac.date


-- total population vs vaccination

SELECT da.continent, da.location, da.date, population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) 
	OVER (Partition By da.location Order by da.location, da.date) as RollingPeopleVaccinated,
	FROM [Portfolio Project]..CovidDeaths da
	Join [Portfolio Project]..CovidVaccinations vac
	ON da.location = vac.location
	and da.date = vac.date
	where da.continent is not NULL
	Order by 2,3


-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By da.location Order by da.location, da.date) as RollingPeopleVaccinated
	FROM [Portfolio Project]..CovidDeaths da
	Join [Portfolio Project]..CovidVaccinations vac
	ON da.location = vac.location
	and da.date = vac.date
	where da.continent is not NULL
	--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100  From PopvsVac


--Temp table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
SELECT da.continent, da.location, da.date, da.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By da.location Order by da.location, da.date) as RollingPeopleVaccinated
	FROM [Portfolio Project]..CovidDeaths da
	Join [Portfolio Project]..CovidVaccinations vac
	ON da.location = vac.location
	and da.date = vac.date
	--where da.continent is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100  From #PercentPopulationVaccinated


-- creating view to store data for visualization
--DROP VIEW PercentPopulationVaccinated;

USE [Portfolio Project]
Go
Create View PercentPopulationVaccinated AS
SELECT da.continent,
	   da.location, 
	   da.date, 
	   da.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By da.location Order by da.location, da.date) as RollingPeopleVaccinated
	FROM [Portfolio Project]..CovidDeaths da
	Join [Portfolio Project]..CovidVaccinations vac
	ON da.location = vac.location
	and da.date = vac.date
	where da.continent is not NULL
	--order by 2,3


SELECT * 
	FROM PercentPopulationVaccinated