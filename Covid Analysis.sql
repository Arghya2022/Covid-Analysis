Select *
From ProjectCovid..CovidDeaths
order by 3,4

--Select *
--From ProjectCovid..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectCovid..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From ProjectCovid..CovidDeaths
order by 1,2

-- Shows the likelihood of dying if ge COVID in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From ProjectCovid..CovidDeaths
Where location like '%India%'
order by 1,2

--Loking at Total Cases vs Population
-- Shows percentage of population got covid

Select Location, date, total_cases,population, (total_cases/population)*100 as CasesPercent
From ProjectCovid..CovidDeaths
Where location like '%India%'
order by 1,2

-- Looking at countries with highest Infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as PopulationPercent
From ProjectCovid..CovidDeaths
-- Where location like '%India%'
Group by location, population
order by PopulationPercent desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectCovid..CovidDeaths
-- Where location like '%India%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Showing Continent with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectCovid..CovidDeaths
-- Where location like '%India%'
Where continent is null
Group by location
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent 

From ProjectCovid..CovidDeaths
-- Where location like '%India%'
Where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


--Creating view to store date for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectCovid..CovidDeaths dea
Join ProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3


Select *
From PercentPopulationVaccinated