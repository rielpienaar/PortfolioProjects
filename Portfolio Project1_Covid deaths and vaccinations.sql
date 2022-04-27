Select *
From PortfolioProject1_Covid..Covid_deaths
where continent is not null
Order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1_Covid..Covid_deaths
order by 1,2;

-- Comparing the total cases vs total deaths 
-- illustrates the likelyhood of death following covid infection per country
Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject1_Covid..Covid_deaths
order by 1,2;

-- total cases vs population
-- percentage of population that contracted covid
Select location, date, population, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as PercentPopulationInfected
FROM PortfolioProject1_Covid..Covid_deaths
--where location = 'South Africa'
order by 1,2;

-- countries with the highest infection rates vs poluation size
Select location, population, max(total_cases) as HighestInfectionCount, max((total_deaths)/population)*100 as PopulationInfectionRate
FROM PortfolioProject1_Covid..Covid_deaths
-- where location like '%states%'
group by location, population
order by PopulationInfectionRate desc;

-- countries with the highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1_Covid..Covid_deaths
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc;

-- continent death count 
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1_Covid..Covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- continent with the highest death count per population 
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1_Covid..Covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- global numbers by date
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercetage
FROM PortfolioProject1_Covid..Covid_deaths
where continent is not null
group by date
order by 1,2;

-- total global ases, deaths and death rate per covid case
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercetage
FROM PortfolioProject1_Covid..Covid_deaths
where continent is not null
order by 1,2;

-- joining covid deaths and covid vaccination tables
select *
from PortfolioProject1_Covid..Covid_deaths as dea
join PortfolioProject1_Covid..Covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

-- new vaccinations per population per day with the rolling total vaccinations to date
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1_Covid..Covid_deaths as dea
join PortfolioProject1_Covid..Covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- people vaccinated per population to date
-- use CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
	(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1_Covid..Covid_deaths as dea
join PortfolioProject1_Covid..Covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopvsVac



-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1_Covid..Covid_deaths as dea
join PortfolioProject1_Covid..Covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated



-- creating view to store data for later use
 create View PercentPopulationVaccinated as 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1_Covid..Covid_deaths as dea
join PortfolioProject1_Covid..Covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated