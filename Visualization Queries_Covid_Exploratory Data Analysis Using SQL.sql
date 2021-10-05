-- SQL Queries for Tableau Visualization part of the Covid-19 SQL Exploratory Data Analytics project

-- Global Death Ratio 
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 as death_percentage
from covid_deaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- Death count with respect to every continent
select location, SUM(new_deaths) as total_death_count
from covid_deaths
-- Where location like '%states%'
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location
order by total_death_count desc;

-- Infection Ratio with respect to every country
select Location, Population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
from covid_deaths
-- Where location like '%states%'
group by Location, Population
order by percent_population_infected desc;

-- Infection Ratio with respect to every country and date
select Location, Population, date, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
from covid_deaths
-- Where location like '%states%'
group by Location, Population, date
order by percent_population_infected desc;