select*
from PortfolioProject ..CovidDeaths
order by 3,4

--select*
--from PortfolioProject ..CovidVacciantions
--order by 3,4
-- SELECT DATA WE ARE GOING TO USE

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject ..CovidDeaths
order by 1,2

-- Now I need to find the ratio btw total deaths and new cases
-- Likelihood of getting the virus

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
where location like '%pakistan%'
order by 1,2

--Looking for total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject ..CovidDeaths
--where location like '%pakistan%'
order by 1,2

--Now i want to see which country has the highest infection rate(probably China)

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject ..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentagePopulationInfected desc

--Let see the countres with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--let see by continents

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--breaking global numbers

select date, SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercantage
from PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--total cases/deaths

select SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercantage
from PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--now I will look at the vaccination table vs population

select*
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVacciantions vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVacciantions vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- another method that we could apply 

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as SumOfPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVacciantions vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- the top query works but with some errors better to change "int" to "bigint"

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as SumOfPeopleVaccinated
--, (SumofPeopleVaccinated/population)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVacciantions vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- Creating a Temp table

DROP Table if exists #SumofPeopleVaccinated
Create Table #SumofPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumofPeopleVaccinated numeric,
)
insert into #SumofPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as SumOfPeopleVaccinated
--, (SumofPeopleVaccinated/population)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVacciantions vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select *, (SumofPeopleVaccinated/Population)*100
from #SumofPeopleVaccinated


-- Making View to look and store for later

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as SumOfPeopleVaccinated
--, (SumofPeopleVaccinated/population)*100
from PortfolioProject ..CovidDeaths dea
join PortfolioProject ..CovidVacciantions vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3



