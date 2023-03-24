--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4


--SELECT*
--FROM CovidVaccinations
--ORDER BY 3,4

--Select the data tha that we are going to be using

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM CovidDeaths
--ORDER BY 1,2


--Looking at total cases vs total deaths and the percentage of people who had it
--The liklihood of dying if you contact covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location = 'Africa'
ORDER BY 1,2

--Looking at total_cases vs population
--Show what percentage of population got covid

--SELECT location, date, total_cases, Population, (total_cases / population)*100 AS Cases_Percentage 
--FROM CovidDeaths
----WHERE location like '%afr%'
--ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
--SELECT location, date, population, total_cases, (total_cases/population)*100 AS Cases_percentage
--FROM CovidDeaths
--ORDER BY Cases_percentage DESC

--SELECT location, population, MAX (total_cases) AS HighestinfectionCount, MAX((total_cases/population))*100 AS Cases_percentage
--FROM CovidDeaths
--GROUP BY location, population
--ORDER BY Cases_percentage DESC

--Looking at how many people die from covid

--SELECT location, MAX(total_deaths) AS TotalDeathsCount
--FROM CovidDeaths
--GROUP BY location
--ORDER BY TotalDeathsCount DESC

----The TotalDeathsCount looks weird, we should cast it

--SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
--FROM CovidDeaths
--WHERE continent is not null
--GROUP BY location
--ORDER BY TotalDeathsCount DESC


--Break it down by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM dbo.covid
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--The number does not look accurate so I will delete the NOT null and add location

SELECT location, MAX (CAST (total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathsCount desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases), SUM(total_cases), SUM(CAST(total_deaths as int)), SUM(CAST(total_deaths as int))/SUM(total_cases)*100 AS DeathPercentage --, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS OVERALL
SELECT SUM(new_cases) AS Newcases, SUM(total_cases) AS TotalCases, SUM(CAST(total_deaths as int)) AS TotalDeaths, SUM(CAST(total_deaths as int))/SUM(total_cases)*100 AS DeathPercentage --, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

--LETS GO TO VACCINATIONS DATASET
SELECT*
FROM CovidVaccinations

--LETS JOIN THE 2 DATASET

--lOOKING FOR TOTAL POPULATION VS TOTAL VACCINATIONS
SELECT COV.continent, COV.location, COV.date, COV.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (PARTITION BY COV.location)
FROM CovidDeaths AS COV
JOIN CovidVaccinations AS VAC
ON COV.location = VAC.location
AND COV.date = VAC.date
WHERE COV.continent is not null
ORDER BY 1,2,3

--IT IS POSSIBLE TO ORDER THE PARTITION BY LOCATION AND DATE 

SELECT COV.continent, COV.location, COV.date, COV.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (PARTITION BY COV.location ORDER BY COV.LOCATION, COV.DATE) AS RollingPeepsVaccinated
FROM CovidDeaths AS COV
JOIN CovidVaccinations AS VAC
ON COV.location = VAC.location
AND COV.date = VAC.date
WHERE COV.continent is not null
ORDER BY 1,2,3

--LETS CALCULATE THE PERCENTAGE OF POPULATION VACCINATED: THE NEW NAMED COLUMN CANNOT BE USED SO WE WILL ADD CTE OR TEMP TABLE

SELECT COV.continent, COV.location, COV.date, COV.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (PARTITION BY COV.location ORDER BY COV.LOCATION, COV.DATE) AS RollingPeepsVaccinated
FROM CovidDeaths AS COV
JOIN CovidVaccinations AS VAC
ON COV.location = VAC.location
AND COV.date = VAC.date
WHERE COV.continent is not null
ORDER BY 1,2,3


--USE CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeepsVaccinated)
as
(
SELECT COV.continent, COV.location, COV.date, COV.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (PARTITION BY COV.location ORDER BY COV.LOCATION, COV.DATE) AS RollingPeepsVaccinated
FROM CovidDeaths AS COV
JOIN CovidVaccinations AS VAC
ON COV.location = VAC.location
AND COV.date = VAC.date
WHERE COV.continent is not null
--ORDER BY 1,2,3
)
SELECT*, (RollingPeepsVaccinated/population)*100 AS PercentageRollingPeeps
FROM PopVsVac


--LETS CREATE OUR VIEW FOR TOTAL DEATHS BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM dbo.covid
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--CREATE VIEW TO STORE DATA FOR LATER

CREATE VIEW TotalDeathsByCount AS
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent


--LETS VIEW THE TOTALDEATHSBY COUNT
SELECT*
FROM TotalDeathsByCount