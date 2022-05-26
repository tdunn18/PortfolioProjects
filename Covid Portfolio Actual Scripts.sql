select *
from PortfolioProject..CovidDeaths$
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%united%King%'
order by 1,2

-- total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%kingd%'
order by 1,2

--looking at country with highest infection rTE COMPARED TO POPULtion

select location, population, max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

-- Showing countrys with the hihest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathsCount desc

-- breaking things down by continent

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathsCount desc

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathsCount desc


-- global numbers 


select date, sum(new_cases) as total_cases, sum(Cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated 
--, (RollingPepoleVaccinated)/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

--Temp table

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated 
--, (RollingPepoleVaccinated)/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualisation

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated 
--, (RollingPepoleVaccinated)/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated