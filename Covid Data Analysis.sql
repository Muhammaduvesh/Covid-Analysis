SELECT * FROM myportfolio.coviddeaths;

UPDATE coviddeaths
SET 
    total_deaths = CASE WHEN total_deaths IS NULL THEN 0 ELSE total_deaths END,
    total_cases = CASE WHEN total_cases IS NULL THEN 0 ELSE total_cases END;


-- Select Data we are going to use
select location, date, total_cases, new_cases, total_deaths, population 
from myportfolio.coviddeaths 
where continent is not null
order by 1;


-- Total cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from myportfolio.coviddeaths
where continent is not null
order by 1;


-- Total cases per Population

select location, date, population, total_cases, (total_deaths/population)*100 as CasePercentage
from myportfolio.coviddeaths
where continent is not null
order by 1;


-- Countries with highest infection and percent of population infected

select location, population, max(total_cases) as Highest_Infection_Rate, max(total_cases/population)*100 as Population_Infected
from coviddeaths
where continent is not null
group by location, population
order by Population_Infected desc;


-- Total infection rate and percent of population infected in INDIA
select location, population, max(total_cases) as Highest_Infection_Rate, max(total_cases/population)*100 as Population_Infected
from coviddeaths
where location like '%india%'
group by location, population
order by Population_Infected desc;


-- Highest death count per population and per total cases in countries

select location, population, max(total_deaths) as Total_Deaths, max(total_cases) as Total_Cases,
 max(total_deaths/total_cases) as DeathPercent_per_TotalCases,
 max(total_deaths/population)*100 as People_Died
from coviddeaths
where continent is not null
group by location, population
order by People_Died desc;


-- Breakdown things by Continent

select continent, max(total_cases) as Total_Cases, max(total_deaths) as Total_Deaths from coviddeaths 
where continent is not null
group by continent;


-- Death per Total cases and People died by continent

select continent, max(total_deaths) as Total_Deaths, max(total_cases) as Total_Cases,
 max(total_deaths/total_cases) as DeathPercent_per_TotalCases,
 max(total_deaths/population)*100 as People_Died
from coviddeaths
where continent is not null
group by continent
order by People_Died desc;


-- Vaccinations per popuplaton by countries and continent

select death.continent, death.location, death.date, death.population, vac.new_vaccinations
from coviddeaths death
join covidvaccinations vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 1,2,3;

-- Total vaccinations by continent

select dea.continent, max(dea.total_cases) as Total_Cases, max(dea.total_deaths) as Total_Deaths, 
max(vac.new_vaccinations) as Total_Vaccinations
from coviddeaths dea
join  covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent;


-- Use CTE to perform calculation on partition by in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PopvsVac;


create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations)
over (Partition by dea.Location order by dea.location, dea.Date) as 
RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
