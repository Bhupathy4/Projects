
-- SELECT COLUMNS FROM TWO TABLES THAT WE ARE GOING TO EXPLORE

 SELECT
       Iso_Code,Continent,Location, Date, Population, Total_Cases, New_Cases, Total_Deaths 
      FROM CovidDeaths
	  WHERE Continent IS NOT NULL
      ORDER BY 1,2
 
 SELECT 
      Iso_Code, Continent,Location, Date, New_Tests, Total_Tests, 
      Positive_Rate,Total_Vaccinations, New_Vaccinations
      FROM CovidVaccinations
	  WHERE Continent IS NOT NULL

 
----------------------------------------------------------------------------------------------------------------------------------------------------

-- LOOKING AT POPULATION VS TOTAL_CASES AND ROUND THE PERCENTAGE BY FOUR DECIMALS

 SELECT
      Location, Date, Population, Total_Cases, Total_Deaths,
      ROUND( (Total_cases/Population*100), 4) AS Cases_Percentage 
      FROM CovidDeaths
      WHERE Location like '%India%'
      ORDER BY Total_Cases DESC

------------------------------------------------------------------------------------------------------------------------------------------------------

-- POPULATION VS TOTAL_DEATHS BY GLOBAL WISE

 SELECT
      Location, Date, Population, Total_Deaths, 
      FLOOR((Total_Deaths/Population*100)) AS Death_Percentage 
      FROM CovidDeaths
	  WHERE Continent is not null
      ORDER BY 1,2

------------------------------------------------------------------------------------------------------------------------------------------------------

-- TOTAL_CASES VS TOTAL_DEATHS BY CONTINENT WISE

 SELECT
      Continent,Location, Date, Total_Deaths, Total_Cases,  
      ROUND((Total_Cases/Total_Deaths*100), 4) AS Death_PercentageBY_Continent 
      FROM CovidDeaths
      WHERE Continent is not null
      ORDER  BY total_cases

------------------------------------------------------------------------------------------------------------------------------------------------------

-- CONTRIES WITH HIGHEST INFECTION RATE COMPARE TO POPULATION

 SELECT 
      Location, Population, MAX(Total_Cases) AS Highest_Infection,
	  ROUND( MAX(Total_cases/Population*100),4) AS Infection_Percentage
	  FROM CovidDeaths
	  GROUP BY Location, Population
	  ORDER BY Location
	  
------------------------------------------------------------------------------------------------------------------------------------------------------

-- CONTRIES WITH POPULATION AND TOTAL_CASES, HOSPITAL_PATIENTS WITH ICU_PATIENTS_PERCENTAGE

 SELECT 
      Location, Population, Icu_Patients, Hosp_Patients,
	  ROUND((Population/Icu_Patients*100), 4) AS Patients_Percenage
	  FROM CovidDeaths
	  WHERE continent is not null
	  GROUP BY location,Population, Icu_Patients, Hosp_Patients
	  ORDER BY Population
  
------------------------------------------------------------------------------------------------------------------------------------------------------

-- GIVE LOCATION AND TOTAL_CASES ARE GREATER THAN 2 LAKHS BY USING SUBQUERY

 SELECT 
	  Iso_Code, continent, Location, Date, Population,
	  Total_Deaths FROM CovidDeaths 
	  WHERE  Location IN
	  (SELECT  Location FROM CovidDeaths WHERE CAST(Total_Cases AS INT)> 200000)
	  ORDER BY Total_Deaths 

 -----------------------------------------------------------------------------------------------------------------------------------------------------     

--CREATE TABLE WHERE TOTAL_DEATHS GREATER THAN 10LAKHS COLUMNS ARE LOCATION, DATE, POPULATION, TOTAL_CASES, TOTAL_DEATHS	

   CREATE TABLE Corona_Data 
      (Location VARCHAR(250),
	  Date DATETIME, 
	  Population FLOAT,
	  Total_Cases BIGINT,
	  Total_Deaths BIGINT)

      INSERT INTO Corona_Data 
	  SELECT Location, Date, Population, Total_Cases, Total_Deaths FROM CovidDeaths
	  WHERE Total_Cases > 1000000

-- SELECT CORONA_DATA WHERE LOCATION IS INDIA

 SELECT * FROM corona_data
	  WHERE LOCATION LIKE '%India%'
	  
-------------------------------------------------------------------------------------------------------------------------------------------------------

--USE JOINS FOR CovidDeaths AND CovidVaccinations

 SELECT 
      CD.Iso_Code, CD.Continent, CD.Date, CD.Population,CD.Total_Cases, CD.Total_Deaths, 
	  CV.Total_Tests,CV.Total_Vaccinations,CV.Positive_Rate, 
	  CD.Population/MAX(CV.Total_Vaccinations)*100 AS Vaccine_Percentage 
	  FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV 
      ON CD.Date=CV.Date
	  GROUP BY CD.Iso_Code, CD.Continent, CD.Date, CD.Total_Cases,CD.Total_Deaths,CD.Population,
	  CV.Total_Vaccinations,CV.Total_Tests, CV.Positive_Rate 
	  ORDER BY CV.Total_Vaccinations DESC

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- LOOKING POPULATION VS NEW_VACCINATIONS

 SELECT CD. Continent, CD.Location, CD.Date, CD.Population, CV.New_Vaccinations, 
      SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeople_Vaccine
      FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV 
	  ON CD.Location=CV.Location AND CD.Date=CV.Date 
	  WHERE CD.Continent IS NOT NULL
	  ORDER BY 2,3

--USE "CTE" FOR PERCENTAGE OF RollingPeople_Vaccine

 WITH POPU_VS_VAC( Continent, Location, Date, Population, New_Vaccinations, RollingPoeople_Vaccine)
 AS
 (
    SELECT CD. Continent, CD.Location, CD.Date, CD.Population, CV.New_Vaccinations, 
      SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeople_Vaccine
      FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV 
	  ON  CD.Location=CV.Location AND CD.Date=CV.Date 
	  WHERE CD.Continent IS NOT NULL
	  
 )
   SELECT *, RollingPoeople_Vaccine/Population*100 AS PercentageOf_RPV
   FROM POPU_VS_VAC

-----------------------------------------------------------------------------------------------------------------------------------------------------

--TEMP TABLE 
   
 CREATE TABLE #Percentage_People_Vaccine
 (
   Continent varchar(250),
   Location VARCHAR(250),
   Date DATETIME,
   Population BIGINT,
   New_Vaccinations BIGINT,
   RollingPeople_Vaccine BIGINT
   )

 INSERT INTO  #Percentage_People_Vaccine
    SELECT CD. Continent, CD.Location, CD.Date, CD.Population, CV.New_Vaccinations, 
      SUM(CONVERT(INT, CV.New_Vaccinations)) 
	  OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeople_Vaccine
      FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV 
	  ON CD.Location=CV.Location AND CD.Date=CV.Date 
	  WHERE CD.Continent IS NOT NULL

    SELECT * FROM #Percentage_People_Vaccine

----------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE A VIEW

 CREATE VIEW PercentagePeopleVaccine  AS
    SELECT CD. Continent, CD.Location, CD.Date, CD.Population, CV.New_Vaccinations, 
      SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeople_Vaccine
      FROM CovidDeaths AS CD JOIN CovidVaccinations AS CV 
	  ON CD.Location=CV.Location AND CD.Date=CV.Date 
	  WHERE CD.Continent IS NOT NULL

  SELECT * FROM   PercentagePeopleVaccine

 


	  


