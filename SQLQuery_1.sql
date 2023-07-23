CREATE DATABASE Portfolio_Covid




---displaying the counts of some essential parameters
select count(distinct date) as Number_of_distinct_days,count(distinct location) as Number_of_countries,count(distinct continent) as Number_of_continents
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'




---select country and total no. of deaths till now in dec order
SELECT location as Country, max(total_deaths) as TOTAL_DEATHS_BY_COUNTRY,max(new_deaths) as Highest_deaths_in_a_single_day,max(new_vaccinations) as Highes_vaccination_in_a_single_day
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'
group by [location]
order by TOTAL_DEATHS_BY_COUNTRY desc


        
---calculating percentage of population infected by Covid for top 10 countries
SELECT location as Country, round(max(total_cases)/avg(population)*100,2) as Percentage_infected,max(total_cases) as Total_Cases,avg(population) as Population  
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'
group by [location]
order by 2 desc



---Applying CTE to find the most populous country from each continent
WITH CTE AS (
    SELECT  location, continent, population,
           ROW_NUMBER() OVER (PARTITION BY continent ORDER BY population DESC) AS RowNum
    FROM Portfolio_Covid..[Covid-data]
    WHERE continent IS NOT NULL  -- Exclude rows where continent is NULL
)
SELECT location as Country, continent as CONTINENT, population AS POPULATION
FROM CTE
WHERE RowNum <= 1
ORDER BY POPULATION asc;




---Listing countries with most vaccinations versus cases
select iso_code as Country_code, location as Country,CONVERT(int,MAX(total_deaths)) as Deaths, (select MAX(total_cases) )as Total_Cases, MAX(people_fully_vaccinated) as Total_Vaccinations,avg(population) as Population,
round((max(people_fully_vaccinated)/max(total_cases)),2) as Vaccinations_over_cases
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'
group by [location],continent,iso_code
order by Vaccinations_over_cases desc



---the day with the highest number of deaths
SELECT date, SUM(new_deaths) as Deaths_per_day, SUM(new_cases) as Cases_per_day
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'
group by date
order by Deaths_per_day desc


---select the countries(locations) who had the highest deaths in a single day
select top 20 date,location as Highest_fatality_country, MAX(new_deaths) as Deaths_in_a_day
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'
group by date,location
having MAX(new_deaths) > 3000
order by Deaths_in_a_day desc






---classify the high income from low income countries
select location, max(gdp_per_capita) as Per_Capita_GDP , round(avg(hospital_beds_per_thousand),2) as Per_thousand_Hospital_beds,SUM(new_deaths) as Total_deaths ,
CASE when avg(gdp_per_capita) > 12000 then 'High Income Country'
when avg(gdp_per_capita) between 4000 and 12000 then 'Upper middle income country'
when avg(gdp_per_capita) between 1000 and 4000  then 'Lower middle income country'
else 'Low income country'
end as 'Country_by_development' 
from Portfolio_Covid..[Covid-data]
where continent not like 'NULL'
group by location
order by location asc



---Showing how to filter a sub set from the data table using subquery
select location, new_deaths
from 
(select * from Portfolio_Covid..[Covid-data] 
where date < '2021-01-01') C


---Applying JOIN to find the number of deaths happening in all countries at the same date over two years
select c.location as Country,c.new_deaths as Deaths_in_2020,c1.new_deaths as Deaths_in_2021,c.[date] as Day_in_2020,c1.date as Day_in_2021
from Portfolio_Covid..[Covid-data] c 
inner join Portfolio_Covid..[Covid-data] c1 
on c.location=c1.[location]
where c.date= '2021-05-01' and c1.date='2022-05-01' and c.continent not like 'NULL' and c1.continent not like 'NULL'



