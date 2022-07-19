select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2

--Looking at Total case Vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(Total_deaths/Total_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
 where location like 'canada'
order by 1,2

--Looking at the total cases Vs the population
select iso_code,continent,location,population,total_cases, (total_cases/population)*100 as percentage_infected
from coviddeaths
where continent like 'North%' and 'south%'
order by 1,2;

-- Looking at countries with the highest infection rate compared to Population
select Location,MAX(total_cases)AS hIGHESTinfectionCount,Max(Total_deaths/Total_cases)*100 as PercentPopulationinfected
from PortfolioProject..coviddeaths
 where location like '%states%'
 group by Location, Population
order by PercentPopulationinfected desc

--Breaking Down by Continent
select continent,MAX(cast(Total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc;

--Showing countries with the highest death count per population
select Location,MAX(cast(Total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as Deathpercentage
From PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2
--Looking total population Vs Vaccination
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3
--Test 1
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
From PortfolioProject..Coviddeaths dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--TEST 2 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null
order by 2,3

--use CTE
With popvsvac (continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from popvsvac



-- Test
Select *
From PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date



--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
on dea.location= vac.location and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null


Select * from PercentPopulationVaccinated;

