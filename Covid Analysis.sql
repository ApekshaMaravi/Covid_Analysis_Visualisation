Select *
From Portfolio..[covid deaths]
order by 3,4

--Select *
--From Portfolio..[covid vaccination]
--order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..[covid deaths]
order by 1,2

-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..[covid deaths]
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
--Shows what percentage of population got covid

Select location, date,population, total_cases, (total_cases/population)*100 as CovidPopulation
From Portfolio..[covid deaths]
--Where location like '%states%'
order by 1,2

--Look at countries where highest infection rate compared to population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as CovidPopulation
From Portfolio..[covid deaths]
--Where location like '%states%'
Group by location, population
order by CovidPopulation desc

-- Showing the countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..[covid deaths]
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break it down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..[covid deaths]
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Portfolio..[covid deaths]
--Where location like '%states%'
--group by date
order by 1,2

--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Portfolio..[covid deaths] dea
join Portfolio..[covid vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE

with PopvsVac (continent, location, date, population,new_vaccinations, rollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Portfolio..[covid deaths] dea
join Portfolio..[covid vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
NewVaccinations numeric, 
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Portfolio..[covid deaths] dea
join Portfolio..[covid vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualisations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From Portfolio..[covid deaths] dea
join Portfolio..[covid vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated



