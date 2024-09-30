Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases , total_deaths , population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


Select location, date, total_cases,total_deaths, (total_deaths/ Nullif(total_cases,0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1, 2


Select location, date,population, total_cases, (total_cases/ Nullif (population,0))*100 as infected
From PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1, 2

--Higest infection rate compare to populations
Select location,population, max(total_cases) as HigestInfectionCount, max((total_cases/ Nullif (population,0)))*100 as Percentageinfected
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
group by location, population
order by Percentageinfected desc


--Showing Countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing the continents with the highest deathcounts
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global Number
SELECT  
    SUM(new_cases) AS TotalCases, 
    SUM(new_deaths) AS TotalDeaths, 
    (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
--GROUP BY 
--    date
ORDER BY 
  1,2

--Total population vs Vaccinations
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, TotalVaccinations) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
        AND vac.new_vaccinations IS NOT NULL
)

SELECT 
    *, 
    (TotalVaccinations / NULLIF(Population, 0)) * 100 AS VaccinationRate
FROM 
    PopvsVac;


--TEMP Table
DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarChar(255),
date dateTime,
Population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)

insert into #PercentPopulationVaccinated
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
        AND vac.new_vaccinations IS NOT NULL

SELECT 
    *, 
    (TotalVaccinations / NULLIF(Population, 0)) * 100 AS VaccinationRate
FROM 
    #PercentPopulationVaccinated


--Creating View to store for later visualisations 
Create View PrecentPopulationVaccinates as
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
        AND vac.new_vaccinations IS NOT NULL