select* from [Portfolio Project 1]..CovidDeaths$
order by 3,4;

Select*
FROM [Portfolio Project 1]..CovidDeaths$
Where location is not null
order by 3,4;


--select* from [Portfolio Project 1]..CovidVacinations$
--order by 3,4;


--SELECTING DATA THAT IM GOING TO USE IN MY PROJECT

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM [Portfolio Project 1]..CovidDeaths$
Where location is not null
ORDER BY 1,2;


--LIKELIHOOD OF DEATH IN SOUTH AFRICA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM [Portfolio Project 1]..CovidDeaths$
where location like '%South Africa%'
ORDER BY 1,2;

--TOTAL CASES VS POPLUATION
SELECT location , date, population, total_cases, (total_cases/population)*100 as PercentPoplulationInfected
from [Portfolio Project 1]..CovidDeaths$
where location like '%South Africa%'
order by 1,2;

select location, population, MAX (total_cases) AS highestInfectionCount , MAX ((total_cases/population))*100 as
PercentPoplulationInfected
from [Portfolio Project 1]..CovidDeaths$
--where location like '%South Africa%'
group by location, population
order by PercentPoplulationInfected DESC;

select location , MAX (CAST(total_deaths as int)) as TotalDeathCount
from [Portfolio Project 1]..CovidDeaths$
--where location like '%South Africa%'
WHERE continent is not null
group by location
order by TotalDeathCount DESC;

-- BREAK DOWN BY CONTINENT

SELECT CONTINENT , SUM (CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project 1]..CovidDeaths$
WHERE continent is not nulL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

select date , SUM (new_cases) as total_cases, SUM (CAST(new_deaths as int)) as total_deaths , SUM (CAST(new_deaths as int))/SUM 
(new_cases)*100 as death_percentage
from [Portfolio Project 1]..CovidDeaths$
WHERE continent is not null
group by date
order by 1,2;


select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations ,
sum (Convert (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
from CovidDeaths$ dea
join CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


--USE CTE 

With PopVsVac (continent, location ,date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations ,
sum (Convert (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
join CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select* , (RollingPeopleVaccinated/population)*100 
from PopVsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated int,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations ,
sum (Convert (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
join CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
select* , (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated;


DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated int,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations ,
sum (Convert (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
join CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
select* , (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated;

--Creating view for visualizations

create view PercentPopulationVaccinated
as
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
,sum (Convert (int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM CovidDeaths$ dea
join CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

select* from PercentPopulationVaccinated

