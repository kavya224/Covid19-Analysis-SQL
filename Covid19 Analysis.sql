create database portfolioproject


select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

---Total cases vs Total death (percentage of death )

	select location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 [DeathPercentage] from CovidDeaths
	order by 1,2

---Total cases vs Total Population (percentage of population got covid)

	select location ,date,population,total_cases,(total_cases/population )*100 [PercentPopulationInfected] from CovidDeaths
	order by 1,2

---Countries with highest infection rate
    
	select location ,population,max(total_cases)[HighInfectionCount],max((total_cases/population ))*100 [PercentPopulationInfected] from CovidDeaths
	group by location,population
	order by PercentPopulationInfected desc

---Countries with highest death

    select location ,max(cast(total_deaths as int)) [Total_Death_Count]from CovidDeaths
	where continent is not null
	group by location
	order by [Total_Death_Count] desc

---Total death count per continent
	
	select continent ,max(cast(total_deaths as int)) [Total_Death_Count]from CovidDeaths
	where continent is not null
	group by continent
	order by [Total_Death_Count] desc
	
   
---Total cases and total deaths
    
	select sum(new_cases) [Total_Cases],sum(cast( total_deaths as int)),sum(new_cases)/sum(cast( total_deaths as int))*100 [Death_percentage] 
	from CovidDeaths
	where continent is not null

---Total population vs Vaccinations
 
	Select d.continent, d.location, d.date, d.population,v.new_vaccinations,
	sum(convert(int,v.new_vaccinations))over (partition by d.location order by d.location,d.date )[Rolling_count_of_vaccinated_people]
	from CovidDeaths d join CovidVaccinations v on
	d.location=v.location and d.date=v.date
	where d.continent is not  null
	order by 2,3 


---Use cte

    With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_count_of_vaccinated_people)
	as
	(
	Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) [ Rolling_count_of_vaccinated_people]
	From CovidDeaths d
	Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
	where d.continent is not null
	)
	Select *, ( Rolling_count_of_vaccinated_people/Population)*100 as PercentPeopleVaccinated
	From PopvsVac


---TEMP TABLE
   

   DROP Table if exists #PercentPeopleVaccinated
   create table #PercentPeopleVaccinated
   (
   Continent nvarchar(225),
   Location nvarchar(225), 
   Date datetime, 
   Population numeric,
   New_Vaccinations numeric, 
   Rolling_count_of_vaccinated_people numeric
   )

   insert into #PercentPeopleVaccinated 
   
   Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
   SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) [ Rolling_count_of_vaccinated_people]
   From CovidDeaths d
   Join CovidVaccinations v
   On d.location = v.location
   and d.date = v.date
   where d.continent is not null
   
   select *, ( Rolling_count_of_vaccinated_people/Population)*100   as PercentPeopleVaccinated 
   from #PercentPeopleVaccinated



	