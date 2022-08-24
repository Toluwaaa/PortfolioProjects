SELECT *
FROM PortfolioProject..Coviddeaths
ORDER BY 3,4
Where continent is not null
--SELECT *
--FROM PortfolioProject..Covidvaccination
--ORDER BY 3,4

--Selecting the Data we needed
Select Location, date, total_cases, total_deaths, population
From PortfolioProject..Coviddeaths
Order by 1,2
Where continent is not null
--Total cases vs Total Deaths (% of people in a country that died from the covid)
--Likelihood of dying of covid in Nigeria
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
Where location = 'Nigeria' AND continent is not null
Order by 1,2

--Total Cases vs Population
--Shows % of population has been infected with Covid 19
--1% of Nigerians did not get covid19
Select Location, date,population, total_cases, (total_cases/population)*100 as CovidInfected_percentage
From PortfolioProject..Coviddeaths
Where location = 'Nigeria'  
Order by 1,2
Where continent is not null
--Countries with the highest infection rate in comparison to the population
Select Location,population, MAX(total_cases) as Highestinfection, MAX((total_cases/population))*100 as CovidInfected_percentage
From PortfolioProject..Coviddeaths
--Where location = 'Nigeria'  
Where continent is not null
Group by Location, population
Order by CovidInfected_percentage desc

--Highest deathcount per population

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..Coviddeaths
Where continent is not null
--Where location = 'Nigeria'  
Group by Location 
Order by TotalDeathcount desc

--Break down by Continent
Select Continent,MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..Coviddeaths
Where continent is not null
--Where location = 'Nigeria'  
Group by Continent
Order by TotalDeathcount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as WorldDeathPercentage_perday 
From PortfolioProject..Coviddeaths
Where continent is not null
--Group by date
Order by 1,2

--Joining the two tables together
SELECT *
FROM PortfolioProject..Coviddeaths dea --(shortform)
Join PortfolioProject..Covidvaccination vac --(shortform)
 On dea.location = vac.location
  and dea.date = vac.date

-- Total vaccination vs total vaccination.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as VacinatedPeopleCounting
 , 
FROM PortfolioProject..Coviddeaths dea --(shortform)
Join PortfolioProject..Covidvaccination vac --(shortform)
 On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2, 3

  --USING A CTE

  WITH PopvsVac (Continent, Location, DAte, Population, New_Vaccination, VacinatedPeopleCounting)
  as
  (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccination as int)) OVER (Partition by dea.location order by dea.location, dea.date) as VacinatedPeopleCounting
FROM PortfolioProject..Coviddeaths dea --(shortform)
Join PortfolioProject..Covidvaccination vac --(shortform)
 On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 -- order by 2, 3
  )
  SELECT *, (VacinatedPeopleCounting/Population) * 100
  FROM PopvsVac

  --using Temp table
  DROP TABLE if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  VaccinatedPeopleCounting numeric
  )
  Insert into #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS VaccinatedPeopleCounting
FROM PortfolioProject..Coviddeaths dea --(shortform)
Join PortfolioProject..Covidvaccination vac --(shortform)
 On dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null
 -- order by 2, 3
  )

  SELECT *, (VaccinatedPeopleCounting / Population) * 100
  FROM #PercentPopulationVaccinated

  --Creating view to store data for later visualisations

  Create view Vacinatedpopulationinpercentage as 
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS VaccinatedPeopleCounting
FROM PortfolioProject..Coviddeaths dea --(shortform)
Join PortfolioProject..Covidvaccination vac --(shortform)
 On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
 --order by 2, 3