--Select *
--From PortolioProject..CovidDeaths
--where continent is not null
--order by 3,4

----Select *
----From PortolioProject..CovidVaccinations
----order by 3,4

--Select location, date, total_cases, new_cases, total_deaths, population
--From PortolioProject..CovidDeaths
--where continent is not null
--order by 1,2

--total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortolioProject..CovidDeaths
where location like '%states%'
where continent is not null
order by 1,2

--total cases vs population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentOfInfections
From PortolioProject..CovidDeaths
where location like '%cyprus%'
where continent is not null
order by 1,2

--countries with highest infection rates compareed to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfInfections
From PortolioProject..CovidDeaths
--where location like '%cyprus%'
where continent is not null
Group by location, population
order by PercentOfInfections desc

--countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortolioProject..CovidDeaths
--where location like '%cyprus%'
where continent is not null
Group by location
order by TotalDeaths desc

--by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortolioProject..CovidDeaths
--where location like '%cyprus%'
where continent is null
Group by location
order by TotalDeaths desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From PortolioProject..CovidDeaths
--where location like '%cyprus%'
where continent is not null
Group by continent
order by TotalDeaths desc

--global deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage  --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortolioProject..CovidDeaths
where continent is not null
order by 1,2

--total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingVaccinations 
From PortolioProject..CovidDeaths dea
join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with PopvsVac (continent, location, date, population, new_vaccinations,RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingVaccinations 
From PortolioProject..CovidDeaths dea
join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinations/population)*100 as VaccinePercntage
From PopvsVac


--tmp table
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingVaccinations 
From PortolioProject..CovidDeaths dea
join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingVaccinations/population)*100 as VaccinePercntage
From #PercentPopulationVaccinated

--View
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingVaccinations 
From PortolioProject..CovidDeaths dea
join PortolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * From PercentPopulationVaccinated 