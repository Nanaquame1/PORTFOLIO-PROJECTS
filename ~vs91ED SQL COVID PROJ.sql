Select *
From PortfolioProjectA..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProjectA..CovidVaccinations
--order by 3,4

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProjectA..CovidDeaths
where location like '%ghana%'
 and continent is not null
order by 1,2

Select location, date, total_cases, population, (total_cases/population)*100 as infectedpoppercentage
From PortfolioProjectA..CovidDeaths
--where location like '%ghana%'
where continent is not null
order by 1,2

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as infectedpoppercentage
From PortfolioProjectA..CovidDeaths
--where location like '%ghana%'
where continent is not null
Group by Location, population
order by infectedpoppercentage desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectA..CovidDeaths
--where location like '%ghana%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--breaking it down by continents
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectA..CovidDeaths
--where location like '%ghana%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/(SUM(New_cases))*100 as DeathPercentage
From PortfolioProjectA..CovidDeaths
--where location like '%ghana%'
where continent is not null
group by date
order by 1,2

--WORLDWIDE TOTAL
Select SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/(SUM(New_cases))*100 as DeathPercentage
From PortfolioProjectA..CovidDeaths
--where location like '%ghana%'
where continent is not null
order by 1,2

--total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as CompoundedVaccination
 --,(CompundedVaccination/population)*100
From PortfolioProjectA..CovidDeaths as dea
JOIN PortfolioProjectA..CovidVaccinations as vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --CTE
 With PopvsVac (continent, location, date, population, new_vaccinations, CompoundedVaccination)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as CompoundedVaccination
 --,(CompundedVaccination/population)*100
From PortfolioProjectA..CovidDeaths as dea
JOIN PortfolioProjectA..CovidVaccinations as vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
)
Select *, (CompoundedVaccination/population)*100
From PopvsVac


--Temp Table

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
compoundedvaccination numeric
)
insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as CompoundedVaccination
 --,(CompundedVaccination/population)*100
From PortfolioProjectA..CovidDeaths as dea
JOIN PortfolioProjectA..CovidVaccinations as vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select *, (compoundedvaccination/population)*100
 From #PercentPopulationVaccinated

 --For Later Visualization#

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as CompoundedVaccination
 --,(CompundedVaccination/population)*100
From PortfolioProjectA..CovidDeaths as dea
JOIN PortfolioProjectA..CovidVaccinations as vac
on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 Select *
 From PercentPopulationVaccinated
