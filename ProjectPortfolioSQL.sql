---Altered the table to change the 
--datatype from nvarchar to float and INT 


Alter table PortfolioProject..['COVID Death info$']
Alter column total_cases FLOAT;

Alter table PortfolioProject..['COVID Death info$']
Alter column total_deaths FLOAT;

Alter table PortfolioProject..['COVID Death info$']
Alter column total_cases_per_million FLOAT;

Alter table PortfolioProject..['COVID Death info$']
Alter column total_deaths_per_million FLOAT;

Alter table PortfolioProject..['COVID vaccinations$']
ALter column new_vaccinations INT;


Select* from  PortfolioProject..['COVID Death info$']
WHERE continent is not NULL
order by 3, 4

--Select* 
--from  PortfolioProject..['COVID vaccinations$']
--order by 3, 4

--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['COVID Death info$']
order by location, date



--Looking at Total cases vs total deaths

SELECT Location, Continent,
        date, total_cases, total_deaths, 
              (total_deaths/total_cases) * 100 as DeathPercentage
          FROM PortfolioProject..['COVID Death info$']
          WHERE Location LIKE '%states%'
          ORDER BY Location, Date;


---This depicts the likelihood of dying if you catch COVID in CANADA

Select Location, continent, date, 
        total_cases, total_deaths,
		(total_deaths/total_cases) * 100 as DeathPercentage
        FROM PortfolioProject..['COVID Death info$']
        WHERE Location = 'Canada'
        ORDER BY Location, Date


---Looking at total cases vs population
---shows the percentage of population that got COVID

SELECT Location, continent, date, 
       population, total_cases, 
	   (total_deaths/population) * 100 as PercentPopulationInfected
       FROM PortfolioProject..['COVID Death info$']
       WHERE Location = 'Canada'
       ORDER BY Location, Date


--What countries with highest infection rate compared to population

Select Location, continent, population, 
       MAX(total_cases) as highestinfectionCount, 
	   MAX((total_deaths/population)) * 100 as PercentPopulationInfected
       FROM PortfolioProject..['COVID Death info$']
      --- WHERE Location = 'Canada'
	    WHERE continent is not NULL
	   GROUP BY Location, Population, Continent
       ORDER BY PercentPopulationInfected DESC

--SHowing the countries with the highest death count per population

Select Location,
       MAX(total_deaths) as TotalDeathCount
       FROM PortfolioProject..['COVID Death info$']
      --- WHERE Location = 'Canada'
	    WHERE continent is not NULL
	   GROUP BY Location
       ORDER BY TotalDeathCount DESC

---Showing the continent with the highest death count per population

Select continent,
       MAX(total_deaths) as TotalDeathCount
       FROM PortfolioProject..['COVID Death info$']
      --- WHERE Location = 'Canada'
	    WHERE continent is not NULL
	   GROUP BY continent
       ORDER BY TotalDeathCount DESC

---Global numbers

SELECT 
    date, 
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths AS BIGINT)) as total_deaths,
    CASE 
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE (SUM(CAST(new_deaths AS BIGINT)) * 100.0) / NULLIF(SUM(new_cases), 0)
    END AS DeathPercentage
    FROM PortfolioProject..['COVID Death info$']
    WHERE continent IS NOT NULL
    GROUP BY date
    ORDER BY date;

--For Canada

SELECT date, SUM(new_cases) as total_cases, new_deaths/NULLIF (New_cases, 0) as result,
              SUM(cast(new_deaths as bigint)) as total_deaths,
			  CASE
			  WHEN SUM(new_cases) = 0 THEN NULL
			  ELSE (SUM(CAST(new_deaths AS BIGINT)) * 100.0) / NULLIF(SUM(new_cases), 0)
              END AS DeathPercentage
			  FROM PortfolioProject..['COVID Death info$']
              WHERE Location = 'Canada'
			 GROUP BY Date, new_deaths,new_cases
		     ORDER BY 1,2
   
 --Total sum of Global cases
		  
SELECT SUM(new_cases) as total_cases, 
              SUM(new_deaths) as total_deaths,
			  sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage 
             FROM PortfolioProject..['COVID Death info$']
         --- WHERE Location = 'Canada'
          WHERE continent is not NULL
	      --GROUP BY Date
		  ORDER BY 1,2	  
	
	
--Total population vs Vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as RollingPeopleVAccinated
FROM PortfolioProject..['COVID Death info$'] Cd	  
  JOIN PortfolioProject..['COVID vaccinations$'] cv
  ON cd.location = cv.location
  AND cd.date = cv.date
  where cd.continent is not null
  Order by 2,3


--USE CTE

WITH PopVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVAccinated)
  as (
   SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as RollingPeopleVAccinated
FROM PortfolioProject..['COVID Death info$'] Cd	  
  JOIN PortfolioProject..['COVID vaccinations$'] cv
  ON cd.location = cv.location
  AND cd.date = cv.date
  where cd.continent is not null
  --Order by 2,3
  )
  SELECT *, (RollingPeopleVAccinated/Population) * 100
  from PopVac



 --TEMP TABLE
 DROP TABLE if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (Continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVAccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as RollingPeopleVAccinated
FROM PortfolioProject..['COVID Death info$'] Cd	  
  JOIN PortfolioProject..['COVID vaccinations$'] cv
  ON cd.location = cv.location
  AND cd.date = cv.date
   where cd.continent is not null
  --Order by 2,3
  SELECT *, (RollingPeopleVAccinated/Population) * 100
  from #PercentPopulationVaccinated


----Create view to store data for later
Create view PercentPopulationVaccinated as 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as RollingPeopleVAccinated
FROM PortfolioProject..['COVID Death info$'] Cd	  
  JOIN PortfolioProject..['COVID vaccinations$'] cv
  ON cd.location = cv.location
  AND cd.date = cv.date
   where cd.continent is not null
  --Order by 2,3

  select * from [#PercentPopulationVaccinated]