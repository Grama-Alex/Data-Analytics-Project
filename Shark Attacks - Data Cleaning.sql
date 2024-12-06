-- SQL Project - Data Cleaning & Exploration

/* This project involves cleaning and exploring the provided dataset to prepare it for further analysis in Tableau.

For the data cleaning process I've been following the upcoming approach :
1. Remove any duplicates. 
2. Standardize the data. 
3. Update null values.
4. Remove any unnesecary columns.

For this project the dataset was provided from:

https://mavenanalytics.io/data-playground?accessType=open&dataStructure=Single%20table&order=number_of_records%2Cdesc&page=4

*/

SELECT * 
FROM shark_attacks.shark_attacks;

-- Creating a backup copy of the raw data

CREATE TABLE shark_attacks.shark_attacks1
LIKE shark_attacks.shark_attacks;

INSERT shark_attacks1 
SELECT * FROM shark_attacks.shark_attacks;

/* Before proceeding with the cleaning process, 
changing the column names by replacing spaces with underscores 
will help avoid any further querying errors.
*/

ALTER TABLE shark_attacks1
CHANGE `Case Number` `Case_Number` VARCHAR(255),
CHANGE `Fatal (Y/N)` `Fatal_(Y/N)` VARCHAR(255),
CHANGE `Investigator or Source` `Investigator_or_Source` VARCHAR(255),
CHANGE `Case Number_[0]` `Case_Number_[0]` VARCHAR(255),
CHANGE `Case Number_[1]` `Case_Number_[1]` VARCHAR(255),
CHANGE `original order` `original_order` INT,
CHANGE `href formula` `href_formula` VARCHAR(255);


-- 1. Removing any duplicates
-- Creating a CTE in combination with a window function will help me identify duplicates and remove them.

SELECT * FROM shark_attacks1;

WITH shark_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY `Case_Number`, `Date`, `Year` , `Country`, `Area`, `Location`, `Activity`, `Name`, `Sex`, `Age`, `Injury`, `Time`, `Species`, `Investigator_or_Source`, `pdf`, `href_formula`, `href`, `Case_Number_[0]`, `Case_Number_[1]`, `original_order`) AS row_num
FROM shark_attacks1
)
SELECT *
FROM shark_cte
WHERE row_num > 1;


/* After creating the CTE, I will create an exact copy of my first table but this time it will include the "row_num"
   Wich is the identifier for spotting duplicates. 
*/
CREATE TABLE `shark_attacks2` (
  `Case_Number` varchar(255) DEFAULT NULL,
  `Date` text,
  `Year` text,
  `Type` text,
  `Country` text,
  `Area` text,
  `Location` text,
  `Activity` text,
  `Name` text,
  `Sex` text,
  `Age` text,
  `Injury` text,
  `Fatal_(Y/N)` varchar(255) DEFAULT NULL,
  `Time` text,
  `Species` text,
  `Investigator_or_Source` varchar(255) DEFAULT NULL,
  `pdf` text,
  `href_formula` varchar(255) DEFAULT NULL,
  `href` text,
  `Case_Number_[0]` varchar(255) DEFAULT NULL,
  `Case_Number_[1]` varchar(255) DEFAULT NULL,
  `original_order` varchar(255) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO shark_attacks2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY `Case_Number`, `Date`, `Year`, `Country`, `Area`, `Location`, `Activity`, `Name`, `Sex`, `Age`, `Injury`, `Time`, `Species`, `Investigator_or_Source`, `pdf`, `href_formula`, `href`, `Case_Number_[0]`, `Case_Number_[1]`, `original_order`) AS row_num
FROM shark_attacks1;

-- Double checking to make sure I get a duplicate in my output.
SELECT * 
FROM shark_attacks2
WHERE Activity= 'Sponge diving' AND original_order = 127;

-- Deleting the duplicates
DELETE 
FROM shark_attacks2
WHERE row_num > 1;

SELECT * 
FROM shark_attacks2;

-- 2. Standardize the data

/* Due 
i. Month to Day
ii. Formats like 20-Dec-2024 to 20/12/2024
iii. Who contained Reported and formats like 20-Dec-2024
iiii. Format the 20-12-2024 as 20/12/2024 */

-- Clearing and updating the 'Reported %' format

SELECT `Date`, TRIM(SUBSTRING(`Date`, 9))
FROM shark_attacks2
WHERE `Date` LIKE 'Reported %';

UPDATE shark_attacks2
SET `Date` = TRIM(SUBSTRING(`Date`, 9))
WHERE `Date` LIKE 'Reported %';

UPDATE shark_attacks2
SET `Date` =TRIM(`Date`);


-- Updating from the string to date value and formatting as dd/mm/yyyy type.
-- The filtered data was saved in a separate table because it contained bugs .

SELECT *, 
    `Date` AS original_date,
    COALESCE(
        CASE
            WHEN `Date` LIKE '%/%/%' THEN DATE_FORMAT(STR_TO_DATE(TRIM(`Date`), '%m/%d/%Y'), '%d/%m/%Y')
            WHEN `Date` LIKE '%-%-%' THEN DATE_FORMAT(STR_TO_DATE(TRIM(`Date`), '%d-%b-%Y'), '%d/%m/%Y')
            WHEN `Date` LIKE '%-%-%' THEN DATE_FORMAT(STR_TO_DATE(TRIM(`Date`), '%b-%d-%Y'), '%d/%m/%Y')
            ELSE 'Invalid_Format'
        END, 'Invalid_Format'
    ) AS standardized_date
    FROM shark_attacks2;
    
    
ALTER TABLE shark_attacks2 
ADD standardized_date VARCHAR(255) AFTER `Date`;

INSERT INTO shark_attacks2 (standardized_date)
SELECT new_date_v2
FROM shark_attacks.filtered_date;

ALTER TABLE shark_attacks2 
DROP COLUMN `Date`;

-- There were some inconsistencies left so I created another CASE statement.
UPDATE shark_attacks2
SET standardized_date = 
    CASE
        WHEN standardized_date REGEXP '^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$' THEN standardized_date
        ELSE 'Invalid_Format'
    END;


-- ___TYPE COLUMN___

SELECT DISTINCT `Type` 
FROM shark_attacks2;

UPDATE shark_attacks2
SET `Type` = CASE
	WHEN `Type` = 'Boating' THEN 'Boat'
    WHEN `Type` = 'Invalid' THEN 'Not_Specified'
    WHEN `Type` = '' OR `Type` IS NULL THEN 'UNKNOWN'
    ELSE `Type` 
END;

-- ___COUNTRY COLUMN___
 
SELECT Country
FROM shark_attacks2;

UPDATE shark_attacks2
SET `Country` = CASE 
    WHEN `Country` = 'ASIA?' THEN 'ASIA'
    WHEN `Country` = 'RED SEA?' THEN 'RED SEA'
    WHEN `Country` = ' TONGA' THEN 'TONGA'
    WHEN `Country` = 'UNITED ARAB EMIRATES (UAE)' THEN 'UNITED ARAB EMIRATES'
    WHEN `Country` = 'SUDAN?' THEN 'SUDAN'
    WHEN `Country` = 'ST. MAARTIN' THEN 'ST. MARTIN'
    WHEN `Country` = 'SIERRA LEONE?' THEN 'SIERRA LEONE'
    WHEN `Country` = '' OR `Country` IS NULL THEN 'UNKNOWN'
    ELSE `Country`
END;

-- ___AREA COLUMN___

SELECT DISTINCT `Area` 
FROM shark_attacks2;

UPDATE  shark_attacks2
SET `Area` = CASE 
    WHEN `Area` IN ('Guerro','Guerrrero')THEN 'Guerrero'
    WHEN `Area` IN ('Makora-Ulawa Province','Makira-Uluwa Province') THEN 'Makira-Ulawa Province'
	WHEN `Area` IN ('Vitu Levu', 'Viti Levu Island', 'Viti Levu group') THEN 'Viti Levu'
    WHEN `Area` IN ('Shat-Al-Arab River','Shatt-el-Arab River') THEN 'Shatt-al-Arab River'
    WHEN `Area` = 'Malaga' THEN 'Málaga'
    WHEN `Area` = 'South Island?' THEN 'South Island'
    WHEN `Area` = 'SIERRA LEONE?' THEN 'SIERRA LEONE'
    WHEN `Area` = 'Split-Dalmatia Count,' THEN 'Split-Dalmatia County' 
    WHEN `Area` = '' OR `Area` IS NULL THEN 'UNKNOWN'
    ELSE `Area` 
END;

-- ___LOCATION COLUMN____

SELECT DISTINCT Location
FROM shark_attacks2;

UPDATE shark_attacks2
SET `Location` = CASE 
	WHEN `Location` = '' OR `Location` IS NULL THEN 'UNKNOWN'
    ELSE `Location`
END;

-- ___SEX COLUMN___

SELECT DISTINCT Sex
FROM shark_attacks2;

UPDATE shark_attacks2
SET Sex = CASE 
    WHEN Sex IN ('', 'N', 'lli', '.') THEN 'Not_Specified'
    WHEN Sex IN ('M', 'F') THEN Sex
    ELSE 'Not_Specified'
END;

-- ___AGE COLUMN___

SELECT DISTINCT Age 
FROM shark_attacks2;

UPDATE shark_attacks2
SET Age = CASE
    WHEN Age REGEXP '^[0-9]{2}$' THEN Age
    ELSE 'UNKNOWN'
END;

-- ___INJURY COLUMN___

SELECT DISTINCT Injury 
FROM shark_attacks2;

UPDATE shark_attacks2
SET `Injury` = CASE
    WHEN `Injury` LIKE '%leg%' THEN 'LEG'
    WHEN `Injury` LIKE '%arm%' THEN 'ARM'
    WHEN `Injury` LIKE '%head%' THEN 'HEAD'
    WHEN `Injury` LIKE '%torso%' THEN 'TORSO'
    WHEN `Injury` LIKE '%foot%' THEN 'FOOT'
    WHEN `Injury` LIKE '%hand%' THEN 'HAND'
    WHEN `Injury` LIKE '%back%' THEN 'BACK'
    WHEN `Injury` LIKE '%shoulder%' THEN 'SHOULDER'
    WHEN `Injury` LIKE '%chest%' THEN 'CHEST'
    ELSE 'UNKNOWN'
END;

-- ___FATAL COLUMN___

SELECT DISTINCT `Fatal_(Y/N)`
FROM shark_attacks2;

SELECT 
    TRIM(`Fatal_(Y/N)`),
    CASE 
        WHEN TRIM(`Fatal_(Y/N)`) IN ('', '#VALUE!') THEN 'UNKNOWN'
        WHEN TRIM(`Fatal_(Y/N)`) = 'y' THEN 'Y'
        WHEN TRIM(`Fatal_(Y/N)`) = 'n' THEN 'N'
        ELSE TRIM(`Fatal_(Y/N)`) 
    END AS `Fatal_(Y/N)`
FROM shark_attacks2;

UPDATE shark_attacks2
SET `Fatal_(Y/N)`= CASE
        WHEN TRIM(`Fatal_(Y/N)`) IN ('', '#VALUE!') THEN 'UNKNOWN'
        WHEN TRIM(`Fatal_(Y/N)`) = 'y' THEN 'Y'
        WHEN TRIM(`Fatal_(Y/N)`) = 'n' THEN 'N'
        ELSE TRIM(`Fatal_(Y/N)`) 
END;

-- ___TIME COLUMN___

SELECT DISTINCT `Time` 
FROM shark_attacks2;

UPDATE shark_attacks2
SET `Time` = CASE
    WHEN `Time` REGEXP '^[0-9]{2}h[0-9]{2}$' THEN `Time`
    ELSE 'UNKNOWN'
END;

-- ___SPECIES COLUMN____

SELECT DISTINCT Species 
FROM shark_attacks;

UPDATE shark_attacks2
SET Species = CASE 
    WHEN Species LIKE '%lemon%' THEN 'Lemon Shark'
    WHEN Species LIKE '%nurse%' THEN 'Nurse Shark'
    WHEN Species LIKE '%raggedtooth%' THEN 'Raggedtooth Shark'
    WHEN Species LIKE '%white%' THEN 'Great White Shark'
    WHEN Species LIKE '%tiger%' THEN 'Tiger Shark'
    WHEN Species LIKE '%bull%' THEN 'Bull Shark'
    WHEN Species LIKE '%hammerhead%' THEN 'Hammerhead Shark'
    WHEN Species LIKE '%mako%' THEN 'Mako Shark'
    WHEN Species LIKE '%whale%' THEN 'Whale Shark'
    WHEN Species LIKE '%blacktip%' THEN 'Blacktip Shark'
    WHEN Species LIKE '%whale%' THEN 'Whale Shark'
    WHEN Species = '' OR Species IS NULL THEN 'UNKNOWN'
    ELSE 'Unknown'
END;


-- 4. Remove any unnesecary columns.

ALTER TABLE shark_attacks2
DROP COLUMN `Case_Number`,
DROP COLUMN `Name`,
DROP COLUMN `Year`,
DROP COLUMN `Activity`,
DROP COLUMN `Investigator_or_Source`,
DROP COLUMN `pdf`,
DROP COLUMN `href_formula`,
DROP COLUMN `href`,
DROP COLUMN `Case_Number_[0]`,
DROP COLUMN `Case_Number_[1]`,
DROP COLUMN `original_order`,
DROP COLUMN `row_num`;

SELECT * FROM shark_attacks2;

/* 	Furthermore I will extract key insights from what is left and proceed with the analysis.
	For improved readability and better organization, I have divided my project into two SQL files.
    The file dedicated to the Data Exploration phase is named Shark Attacks - Data Exploration.sql."
*/



























