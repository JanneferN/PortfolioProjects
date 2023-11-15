Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4


-- Select the columns needed, and order by column 1,2 (location then date)

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying from Covid in a country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Singapore%'
and continent is not null
Order by 1,2


-- Total Cases vs Population
-- Finding the percentage of population who got Covid
Select location, date, population, total_cases,  (total_cases/population)*100 as ConfirmedCasesPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Order by 1,2


-- Countries with Highest Infection Rate compared to population
Select location, population, 
MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as ConfirmedCasesPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Group by location, population
Order by ConfirmedCasesPercentage desc


---- Countries with Highest Death Count per population
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----Where location like '%Singapore%'
--Group by location
--Order by TotalDeathCount desc

-- From the above query, invalid location data was found (i.e. Continent names, World)
-- Retrieve data without these rows where continent is null 
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


-- Countries with Highest Death Count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--- BY CONTINENT 

-- Continent with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Where continent is null
Group by location
Order by TotalDeathCount desc


-- GLOBAL NUMBERS


-- Total cases, total deaths and death percentage recorded daily

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
	SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where locaton like '%Singapore%'
Where continent is not null
Group by date
Order by 1,2

-- Overall global cases and deaths 

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
	SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where locaton like '%Singapore%'
Where continent is not null
--Group by date
Order by 1,2



-- COVID VACCINATIONS

Select *
From PortfolioProject..CovidVaccinations

-- Join both tables
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Rolling People Vaccinated by location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (
Partition by dea.location 
Order by dea.location, dea.date
) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (
Partition by dea.location 
Order by dea.location, dea.date
) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population) * 100 as VaccinationPercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (
Partition by dea.location 
Order by dea.location, dea.date
) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population) * 100 as VaccinationPercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (
Partition by dea.location 
Order by dea.location, dea.date
) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population) * 100 as VaccinationPercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for visualisation

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (
Partition by dea.location 
Order by dea.location, dea.date
) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population) * 100 as VaccinationPercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated