SELECT * 
FROM covid_deaths
ORDER BY 3, 4; -- Ordering with respect to the location and date

SELECT * 
FROM covid_vaccinations
ORDER BY 3, 4; -- Ordering with respect to the location and date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, 2;

-- Analysing the Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location = 'India'
ORDER BY 1, 2;

-- Analysing the Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases / population)*100 as covid_infection_rate
FROM covid_deaths
-- WHERE location = 'India'
ORDER BY 1, 2;

-- Analysing the countries with highest infection rate compared to population
SELECT location, max(total_cases) as highest_infection_count, population, max((total_cases / population))*100 as covid_infection_rate
FROM covid_deaths
-- WHERE location = 'India'
GROUP BY location, population
ORDER BY covid_infection_rate desc;

-- Countries with highest death count per population
SELECT location, max(cast(total_deaths as unsigned)) as total_death_count
FROM covid_deaths
WHERE continent is not null -- Because when continent is null, the country is given as the continent as a whole in the data
GROUP BY location
ORDER BY total_death_count desc;

-- Continents with highest death count per population
SELECT continent, max(cast(total_deaths as unsigned)) as total_death_count
FROM covid_deaths
WHERE continent is not null -- Because when continent is null, the country is given as the continent as a whole in the data
GROUP BY continent
ORDER BY total_death_count desc;

-- Global cases, deaths and death percentage based on the date
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from covid_deaths
where continent is not null
group by date
order by 1, 2;

-- Total global cases deaths and death percentage
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from covid_deaths
where continent is not null
-- group by date
order by 1, 2;

-- Joining the covid deaths and covid vaccinations table
select * 
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date;

-- Total population vs vaccincations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

-- Total Vaccinations in different countries by date
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location 
order by dea.location, dea.date) as rolling_vaccination_numbers
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

-- Using CTE
with vac_by_pop (continent, location, date, population, new_vaccinations, rolling_vaccination_numbers) as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location 
order by dea.location, dea.date) as rolling_vaccination_numbers
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3;
) 
select *, (rolling_vaccination_numbers/population)* 100
from vac_by_pop;

-- Creating a temp table
DROP table if exists percent_population_vaccinated;
create table percent_population_vaccinated (
continent char(255),
location char(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_vaccination_numbers numeric
);

insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location 
order by dea.location, dea.date) as rolling_vaccination_numbers
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 2, 3;

select *, (rolling_vaccination_numbers/population)* 100
from percent_population_vaccinated;

-- Creating a view to store data for future visualizations
create view percent_population_vaccinated_viewpercent_population_vaccinated_view as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location 
order by dea.location, dea.date) as rolling_vaccination_numbers
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 2, 3;


