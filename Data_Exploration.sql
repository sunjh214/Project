use PortfolioProject

select *
from CovidDeaths

--select *
--from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths

--Looking at Total Cases vs Total Deaths
select location, date, total_deaths, total_cases, round((total_deaths/total_cases)*100, 2) DeathRate
from CovidDeaths
where location = 'china' and total_deaths is not null
order by 2

--Looking at Total Cases vs Population
select location, date, total_cases, population, round((total_cases/population)*100, 2) InfectionRate
from CovidDeaths
where location = 'japan' and total_cases is not null
order by 2

-- Looking at Countries with Highest Infection Rate
select location, population, max(total_cases) TotalInfection, max(round((total_cases/population)*100, 2)) InfectionRate
from CovidDeaths
where continent is not null
group by location, population
order by InfectionRate desc

--Showing Countries with Highest Death Rate per Population
select location, population, max(total_deaths) TotalDeath, max(round((total_deaths/population)*100, 2)) DeathRate
from CovidDeaths
where continent is not null
group by location, population
order by TotalDeath desc

--Breaking Down by Continent
select continent, max(total_deaths) TotalDeath
from CovidDeaths
where continent is not null
group by continent
order by TotalDeath desc

--Global Numbers
select date, sum(new_cases) TotalCases,sum(new_deaths) TotalDeaths,
round(sum(new_deaths)/sum(new_cases)*100, 2) as DeathRate
from CovidDeaths
where continent is not null and new_cases is not null
group by date
order by date

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) TotalVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2,3

--Create CTE
with PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) TotalVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
)

select *, round((TotalVaccinations/population)*100, 2) VaccinationRate
from PopvsVac

--Temp Table
--drop table is exists #VaccinatedRate
create table #VaccinatedRate
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric
)
insert into #VaccinatedRate
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) TotalVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null

select *, round((totalvaccinations/population)*100, 2) VaccinationRate
from #VaccinatedRate

--Create View
create view TotalVaccinations as
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) TotalVaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null