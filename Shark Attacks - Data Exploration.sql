/* In the second part of my project, I will extract several key insights that will be crucial for my final analysis. 
    Made by : Grama Alex Ștefan

	This is my exploratory data phase, where I will dive in the cleaned dataset to help me get the accuracy of my conclusions
	and make more of a refined analysis in the end.

1.Shark Attacks Over Time

2.Countries with Most Shark Attacks (top dangerous )

3.Most Injured Body Parts

4.Shark Attacks by Time of Day

5. Most Common Shark Species in Attacks

6. Fatal vs. Non-Fatal by Species
   
7. Fatal and Non-Fatal by Age

8. Sex Categories and Fatalities
   

 */
 
-- 1.Shark Attacks Over Time
    
SELECT RIGHT(standardized_date, 4) AS `Year`, COUNT(`Type`) AS attack_count
FROM shark_attacks2
WHERE standardized_date != 'Invalid_Format'
AND `Type` != 'Not_Specified' OR 'UNKNOWN'
GROUP BY `Year`
ORDER BY `Year`;
    
-- 2. Which countries report the most shark attacks? Within those countries, which areas and locations seem to be the most dangerous?

SELECT Country, `Area`, Location, `Type`
FROM shark_attacks2
WHERE Country != 'UNKNOWN'
AND `Area` !=  'UNKNOWN'
AND Location != 'UNKNOWN'
AND `Type` != 'Not_Specified' OR 'UNKNOWN';

WITH attack_area AS (
    SELECT Country, `Area`, Location, COUNT(`Type`) AS attack_count
    FROM shark_attacks2
    WHERE Country != 'UNKNOWN'
	AND `Area` != 'UNKNOWN'                -- The first querry will count the attacks
	AND Location != 'UNKNOWN'
	AND `Type` != 'Not_Specified' OR 'UNKNOWN'
    GROUP BY Country, `Area`, Location
),
country_rank AS (
    SELECT Country, `Area`, Location, attack_count,
	RANK() OVER (PARTITION BY Country ORDER BY attack_count DESC) AS area_rank  -- The second one will assign the ranking 
    FROM attack_area
),
top_countries AS (
    SELECT Country, SUM(attack_count) AS total_attacks
    FROM attack_area
    GROUP BY Country                           -- The third one will select the top 10 countries by the total number of attacks
    ORDER BY total_attacks DESC
    LIMIT 10
)
SELECT top_countries.Country, country_rank.`Area`, country_rank.Location, country_rank.attack_count
FROM top_countries
JOIN country_rank 
ON top_countries.Country = country_rank.Country         -- The final one will join everything showing the top 10 
WHERE country_rank.area_rank <= 10 
ORDER BY top_countries.total_attacks DESC, country_rank.area_rank;


-- 3. What body parts are most often injured? 

SELECT Injury, COUNT(Injury) AS total_injuries
FROM shark_attacks2
WHERE Injury != 'UNKNOWN'
GROUP BY Injury
ORDER BY total_injuries DESC
LIMIT 10;

-- 4. Are shark attacks more common during certain parts of the day 

SELECT  `Time`, `Type`
FROM shark_attacks2
WHERE `Time` !=  'UNKNOWN'
AND `Type` != 'Not_Specified' OR 'UNKNOWN';

SELECT `Time`, COUNT(`Type`) AS total_attacks
FROM shark_attacks2
WHERE `Type` = 'Unprovoked'
	AND `Time` !=  'UNKNOWN'
    GROUP BY `TIME`
	ORDER BY COUNT(`Type`) DESC;

-- 5. Most Common Shark Species in Attacks

SELECT Species, COUNT(`Type`) AS attacks
FROM shark_attacks2
WHERE Species != 'UNKNOWN'
	AND `Type` != 'Not_Specified' OR 'UNKNOWN'
    GROUP BY Species;
	
-- 6. The shark species wich was with the most fatal injurys and with the least injurys

SELECT Species, `Type`, `Fatal_(Y/N)`
FROM shark_attacks2
WHERE Species != 'UNKNOWN'
   AND `Type` != 'Not_Specified' OR 'UNKNOWN'
   AND `Fatal_(Y/N)` != 'UNKNOWN';
   
WITH fatal_species AS
(
SELECT Species, COUNT(`Fatal_(Y/N)`) AS Fatal
FROM shark_attacks2
WHERE Species != 'UNKNOWN'
   AND `Fatal_(Y/N)` != 'UNKNOWN'
   AND `Fatal_(Y/N)` = 'Y'
   GROUP BY Species
),
non_fatal AS 
(
SELECT Species, COUNT(`Fatal_(Y/N)`) AS Non_Fatal
FROM shark_attacks2
WHERE Species != 'UNKNOWN'
   AND `Fatal_(Y/N)` != 'UNKNOWN'
   AND `Fatal_(Y/N)` = 'N'
   GROUP BY Species
)  
SELECT fatal_species.Species, fatal_species.Fatal, non_fatal.Non_Fatal 
FROM fatal_species 
JOIN non_fatal 
ON fatal_species.Species = non_fatal.Species
GROUP BY Species
ORDER BY Fatal DESC, Non_Fatal DESC;


-- 7. Fatal and Non-Fatal by Age       
        
WITH fatal AS 
(
SELECT Age, COUNT(`Fatal_(Y/N)`) AS Fatal
FROM shark_attacks2
WHERE `Age` != 'UNKNOWN'
AND `Fatal_(Y/N)` = 'Y'
GROUP BY Age
ORDER BY COUNT(`Fatal_(Y/N)`) DESC
),
non_fatal AS 
(
SELECT Age, COUNT(`Fatal_(Y/N)`) AS Not_Fatal
FROM shark_attacks2
WHERE `Age` != 'UNKNOWN'
AND `Fatal_(Y/N)` = 'N'
GROUP BY Age
ORDER BY COUNT(`Fatal_(Y/N)`) DESC
)
SELECT fatal.Age, fatal.Fatal, non_fatal.Not_Fatal
FROM fatal
JOIN non_fatal 
ON fatal.Age = non_fatal.Age
GROUP BY fatal.Age
ORDER BY fatal.Fatal DESC, non_fatal.Not_Fatal DESC;

    
-- 8. Sex Categories and Fatalities 

WITH count_sex_m AS 
(
SELECT 
COUNT(CASE WHEN Sex = 'M' 
AND Sex != 'Not_Specified' 
AND `Fatal_(Y/N)` = 'Y'
THEN 1 
ELSE NULL END) AS total_males
FROM shark_attacks2
),
count_sex_f AS 
(
SELECT 
COUNT(CASE WHEN Sex = 'F' 
AND Sex != 'Not_Specified' 
AND `Fatal_(Y/N)` = 'Y'
THEN 1 
ELSE NULL END) AS total_females
FROM shark_attacks2
)
SELECT 
    (SELECT AVG(total_males) FROM count_sex_m) AS Male_Fatalities,
    (SELECT AVG(total_females) FROM count_sex_f) AS Female_Fatalities;

/* As an enclosure this is the end of my SQL project of cleaning and exploring data.
	Everything was tested before applying my concepts with a SELECT statement
    and if you spot too many unecesary SELECT statements they are to of course
	show the begining on visualising and thought processing of the data itself.
    
	==== Thank You ! =====
*/