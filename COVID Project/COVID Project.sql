-- delete non locations from location column
select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4
delete from PortfolioProject.dbo.CovidDeaths where location in ('Africa', 'Europe', 'Oceania', 'Europe', 'European Union',
'North America', 'South America', 'High income', 'Low income', 'Lower middle income', 'Upper middle income','Asia',
'International', 'World')

-- delete non locations from location column
select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4
delete from PortfolioProject.dbo.CovidVaccinations where location in ('Africa', 'Europe', 'Oceania', 'Europe', 'European Union',
'North America', 'South America', 'High income', 'Low income', 'Lower middle income', 'Upper middle income','Asia',
'International', 'World')

-- looking at total cases, new cases, total deaths, and population by location and date
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- looking at total cases vs total deaths for United States
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2


-- looking at total cases vs population in 2022
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where date like '%2022%'
order by 1,2

-- shows what percentage of population got Covid for 2022 in Ghana
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%Ghana%' and date like '%2022%'
order by 1,2


-- looking at countries with highest infection rate compared to population 
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as  PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- showing the countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- global numbers 

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


-- join 2 tables

select *
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- use cte
with PopsVac (continet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.date like '%2022%'
)
select *
from PopsVac


-- temp table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.date like '%2022%'
