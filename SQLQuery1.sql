SELECT * 
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--SELECT * 
--From PortfolioProject..CovidVacination
--Order by 3,4


--Select data which we going to use 

Select Location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total dealths
--show likelihood of dying if you contract covid in your country
Select Location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--Where location like '%States%'
order by 1,2

--looking at Total Cases vs Poplulation
--Show what percentage of population got covid 
Select Location, date, total_cases,Population,(total_cases/population)*100 as PercentPolulationInfected
from CovidDeaths
where continent is not null
--Where location like '%States%'
order by 1,2

--Looking at country with highest infection rate compared to Population
Select Location,Population, Max(total_cases) as HighestInfectionCountry, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--Where location like '%States%'
group by location,population
order by PercentPopulationInfected desc



--Showing Countries with Highest Death Count per Poplulation
Select Location,max(cast(total_deaths as int)) as TotalDealthCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%States%'
group by location
order by TotalDealthCount desc

--Let's break things down by continent
--showing continents with the highest death count per polulation

Select continent,max(cast(total_deaths as int)) as TotalDealthCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%States%'
group by continent
order by TotalDealthCount desc

--Global numbers
--total numbers without group by date

Select  sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths, sum(cast(New_deaths as int))/sum(new_cases)*100 as DealthsPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
--Where location like '%States%'
order by 1,2

--Group by date 

Select date, sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths, sum(cast(New_deaths as int))/sum(new_cases)*100 as DealthsPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
--Where location like '%States%'
order by 1,2


--looking at total population vs vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--Use CTE
With PopvsVac (Contient, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
Drop table if exists #PercentPopulationVacinated

Create Table #PercentPopulationVacinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations  numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVacinated


----Creating view to story data for later visualisation
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVacination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
