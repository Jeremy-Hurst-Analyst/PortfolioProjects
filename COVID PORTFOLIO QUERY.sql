SELECT *
FROM dbo.CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM dbo.CovidVaccinations
--order by 3,4

--SELECT DATA THAT WE WILL BE USING

Select location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths

--Shows Likelihhod of Dying if you Contract Covid in Your Country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
-- Shows Percentage of Population that Contracted Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopInfected
From dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
Order by 4 DESC

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount DESC

--Continental Views
--Continents with Highest Death Count per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where continent is not null
--Group by date
Order by 1

--Total Population vs Total Vaccination
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations,
SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVax
From dbo.CovidDeaths death
Join dbo.CovidVaccinations vax
on death.location = vax.location and death.date = vax.date
where death.continent is not null
order by 2,3

--Use CTE
With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVax)
as 
(
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations,
SUM(CONVERT(int, vax.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVax
From dbo.CovidDeaths death
Join dbo.CovidVaccinations vax
on death.location = vax.location and death.date = vax.date
where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVax/Population)*100
From PopvsVax


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVax numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVax
From dbo.CovidDeaths death
Join dbo.CovidVaccinations vax
on death.location = vax.location and death.date = vax.date
where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVax/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for late Viz

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVax
From dbo.CovidDeaths death
Join dbo.CovidVaccinations vax
on death.location = vax.location and death.date = vax.date
where death.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated