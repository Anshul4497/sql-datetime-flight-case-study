SELECT * FROM flight
limit 5;

-- 1. Find the month with most number of flights
SELECT  monthname(date_of_journey),COUNT(*) as 'Number_of_flights' from flight
group by monthname(date_of_journey)
order by Number_of_flights desc limit 1;

-- 2. Which Week day has most costly flights
Select Airline,dayname(date_of_journey),Price
from flight
order by price desc limit 1;

SELECT dayname(date_of_journey),avg(price)
from flight
group by dayname(date_of_journey)
order by avg(price) desc limit 1;

-- 3 Find number of Indigo flights every month
SELECT  MONTHNAME(DATE_OF_JOURNEY), count(*) from flight
where airline = 'indigo'
GROUP BY MONTHNAME(DATE_OF_JOURNEY)
ORDER BY COUNT(*) DESC;

-- 4 Find number of Indigo flight that depart between 10 AM  and 2 PM
-- from delhi to banglore
SELECT *,HOUR(DEP_TIME) FROM FLIGHT
WHERE SOURCE = 'Banglore' OR DESTINATION = 'NEW DELHI'
AND DEP_TIME between 10 and 14;


-- 5 Find number of flights that departing on weekends from banglore
SELECT count(*)  FROM flight
WHERE source = 'banglore' and dayname(date_of_journey) IN('saturday','sunday');

-- Add Column Departure time
ALTER TABLE FLIGHT ADD COLUMN departure datetime;

SELECT STR_TO_DATE(CONCAT(DATE_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i') from flight;

UPDATE flight SET departure =
		 STR_TO_DATE(CONCAT(DATE_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i');
         

ALTER TABLE FLIGHT
ADD COLUMN duration_mins INTEGER,
ADD COLUMN arrival DATETIME;

SELECT Duration, REPLACE(substring_index(Duration,' ',1),'h','')*60 +
CASE
	WHEN substring_index(Duration,' ',-1)  = substring_index(Duration,' ',1)
	THEN 0 ELSE REPLACE(substring_index(Duration,' ',-1),'m','')
    END AS 'mins'
from flight;
select * from flight;

UPDATE flight
SET duration_mins =
    CASE
        WHEN Duration LIKE '%h%' THEN
            CAST(REPLACE(SUBSTRING_INDEX(Duration, ' ', 1), 'h', '') AS UNSIGNED) * 60
            +
            CASE
                WHEN Duration LIKE '%m%' THEN
                    CAST(REPLACE(SUBSTRING_INDEX(Duration, ' ', -1), 'm', '') AS UNSIGNED)
                ELSE 0
            END
        WHEN Duration LIKE '%m%' THEN
            CAST(REPLACE(Duration, 'm', '') AS UNSIGNED)
        ELSE 0
    END;

SELECT departure,
		duration_mins,
		DATE_ADD(departure,INTERVAL duration_mins MINUTE)
from flight;

UPDATE flight
SET arrival =
			DATE_ADD(departure,INTERVAL duration_mins MINUTE);
            
            
-- 6 Calulate the arrival time for all flights 
-- by adding the duration to the departure time.
SELECT TIME(arrival) from flight;

--  7. Calculate the arrival date for all flight
SELECT DATE(arrival) from flight;

-- 8. Find the number of flights which travel on multiple dates
SELECT COUNT(*)
FROM flight
WHERE DATE(departure) != DATE(arrival);
select * from flight;
-- 9. Calculate the average duration of flights between all city pairs
SELECT 
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%Hh %im') AS 'Average_Duration',
source,destination from flight
GROUP BY source,destination; 

-- 10 Find all flights which departed before midnight but arrived at their 
-- Destination after midnight having only one stop

SELECT 
*
FROM  flight
WHERE Total_Stops = 'non-stop' AND
DATE(departure) < DATE(arrival);

-- 11 Find Quarter wise number of flights for each airline;
SELECT COUNT(*),QUARTER(departure) AS 'EACH_QUARTER',AIRLINE
FROM FLIGHT
GROUP BY EACH_QUARTER,AIRLINE
ORDER BY airline;


-- 12 Find the longest Flight distance (between cities in terms of time) in india 
SELECT MAX(duration_mins),airline from flight
group by airline;


-- 13 Average time duration for flights that have 1 stop vs more than 1 stops
WITH temp_table as (
SELECT *,
CASE 
	WHEN Total_Stops = 'non-stop' THEN 'non-stop'
    ELSE 'Withstop'
    END AS 'Temp'
FROM flight)

SELECT temp,avg(duration_mins), avg(Price) as 'Avg_Price' FROM Temp_table
group by temp;


-- 14 Find all Air India flights in a given range originating from Delhi
SELECT *  FROM flight
WHERE SOURCE = 'Delhi'
AND Airline = 'Air India';

-- 15 Find Longest Flight of each airline
SELECT Airline, MAX(duration_mins/60) 'TIME'
 FROM FLIGHT
GROUP BY AIRLINE
ORDER BY 'TIME' DESC;


select * from flight;
-- 16 FIND all the pair of cities having average time duration > 3 Hours
SELECT 
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%Hh %im') AS 'Average_Duration',
source,destination from flight
GROUP BY source,destination
HAVING AVG(duration_mins) >180; 

-- 17 Make a week day vs time grid showing frequency of flights from Banglore and Delhi

SELECT 
    DAYNAME(departure) AS day_name,

    SUM(
        CASE 
            WHEN HOUR(departure) BETWEEN 0 AND 5 
            THEN 1 
            ELSE 0 
        END
    ) AS `12AM - 6AM`,

    SUM(
        CASE 
            WHEN HOUR(departure) BETWEEN 6 AND 11 
            THEN 1 
            ELSE 0 
        END
    ) AS `6AM - 12PM`,

    SUM(
        CASE 
            WHEN HOUR(departure) BETWEEN 12 AND 17 
            THEN 1 
            ELSE 0 
        END
    ) AS `12PM - 6PM`,

    SUM(
        CASE 
            WHEN HOUR(departure) BETWEEN 18 AND 23 
            THEN 1 
            ELSE 0 
        END
    ) AS `6PM - 12AM`

FROM flight

WHERE source = 'Banglore'
  AND destination = 'Delhi'

GROUP BY 
    DAYOFWEEK(departure),
    DAYNAME(departure)

ORDER BY 
    DAYOFWEEK(departure) ASC;
    
-- 18 Make a Weekday vs times grid showing avg flight price from Banglore and Delhi
SELECT 
    DAYNAME(departure) AS day_name,

    AVG(
        CASE 
            WHEN HOUR(departure) BETWEEN 0 AND 5 
            THEN price 
        END
    ) AS `12AM - 6AM`,

    AVG(
        CASE 
            WHEN HOUR(departure) BETWEEN 6 AND 11 
            THEN price 
        END
    ) AS `6AM - 12PM`,

    AVG(
        CASE 
            WHEN HOUR(departure) BETWEEN 12 AND 17 
            THEN price 
        END
    ) AS `12PM - 6PM`,

    AVG(
        CASE 
            WHEN HOUR(departure) BETWEEN 18 AND 23 
            THEN price 
        END
    ) AS `6PM - 12AM`

FROM flight

WHERE source = 'Banglore'
  AND destination = 'Delhi'

GROUP BY 
    DAYOFWEEK(departure),
    DAYNAME(departure)

ORDER BY 
    DAYOFWEEK(departure) ASC;

