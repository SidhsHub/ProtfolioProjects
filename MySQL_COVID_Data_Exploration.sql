USE covid;

SELECT 
    *
FROM
    covidvaccinations;
    
SELECT 
    *
FROM
    coviddeaths;
 
-- Standardize Date Format

SELECT 
    date, STR_TO_DATE(date, '%d-%m-%Y')
FROM
    coviddeaths;
  
 Alter table coviddeaths add DateConverted date;
 
UPDATE coviddeaths 
SET 
    DateConverted = STR_TO_DATE(date, '%d-%m-%Y');
    
Alter table covidvaccinations add DateConverted date;

UPDATE covidvaccinations 
SET 
    DateConverted = STR_TO_DATE(date, '%d-%m-%Y');
---------------------------------------------------------------------------------------------------------------------------------

-- Looking at total cases vs total deaths
-- DeathPercentage  = Liklihood of dyning if you contract covid in your country
SELECT 
    location,
    DateConverted,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%india%'
        AND continent IS NOT NULL
ORDER BY 1 , 2 DESC;

---------------------------------------------------------------------------------------------------------------------------------

-- Looking at total cases vs population
-- InfectionRate - % of total population infected by COVID

SELECT 
    location,
    DateConverted,
    population,
    total_cases,
    ROUND((total_cases / population) * 100, 2) AS InfectionRate
FROM
    coviddeaths
WHERE
    location LIKE '%india%'
        AND continent IS NOT NULL
ORDER BY 1 , 2 DESC;

---------------------------------------------------------------------------------------------------------------------------------

-- Looking at countries with highest infection rate compared to population

SELECT 
    location,
    population,
    MAX(total_cases),
    MAX(ROUND((total_cases / population) * 100, 2)) AS InfectionRate
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location , population
ORDER BY InfectionRate DESC;

---------------------------------------------------------------------------------------------------------------------------------

-- Showing contries with highest death count

SELECT 
    location, 
    max(total_deaths) as DeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY DeathCount DESC;

---------------------------------------------------------------------------------------------------------------------------------
-- Death count by continent

SELECT 
    location, 
    max(total_deaths) as DeathCount
FROM
    coviddeaths
WHERE
    continent IS NULL
GROUP BY location
ORDER BY DeathCount DESC;

---------------------------------------------------------------------------------------------------------------------------------
-- Per day deaths percentage

 SELECT 
    DateConverted,
    sum(covid.coviddeaths.new_deaths) as NewDeath,
    sum(new_cases) as NewCases,
    round((sum(covid.coviddeaths.new_deaths) / sum(new_cases))*100, 2) as DethPercent
FROM
    coviddeaths
WHERE
    continent IS NULL
GROUP BY DateConverted
ORDER BY DateConverted DESC;

---------------------------------------------------------------------------------------------------------------------------------
-- Running total of vaccinations as per location
-- Rate of vaccination is number of people vaccinated divide by population

WITH vaccinatio_running_total_cte AS
(
SELECT 
    cd.continent,
    cd.location,
    cd.DateConverted,
    cd.population,
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.DateConverted) as running_total_of_vaccinations
FROM
    coviddeaths cd
        JOIN
    covidvaccinations cv ON cd.location = cv.location
        AND cd.DateConverted = cv.DateConverted
WHERE
    cd.continent IS NOT NULL
        AND cd.location LIKE '%india%'
-- ORDER BY 2 , 3
)
SELECT 
    *, round((running_total_of_vaccinations / population) * 100, 2) rate_of_vaccinations
FROM
    vaccinatio_running_total_cte;
    
---------------------------------------------------------------------------------------------------------------------------------
-- Create a view

CREATE VIEW percent_population_vaccinated AS
SELECT 
    cd.continent,
    cd.location,
    cd.DateConverted,
    cd.population,
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.DateConverted) as running_total_of_vaccinations
FROM
    coviddeaths cd
        JOIN
    covidvaccinations cv ON cd.location = cv.location
        AND cd.DateConverted = cv.DateConverted
WHERE
    cd.continent IS NOT NULL;

SELECT 
    *
FROM
    percent_population_vaccinated;