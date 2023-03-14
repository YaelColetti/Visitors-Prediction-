-------------------------------------------FIRST STEP: FIX THE TABLES SO THE DATES ARE IN THE SAME YYYY/MM/DD FORMAT:

----In this section we will work with the air_visit_data table and change the date fomat from m/d/yyyy to yyyy/mm/dd:
--In SQLite there is no 'datetime' data type and dates are usually `TEXT` data type. 
--We will first copy the original table to a VIEW and then format the `visit_date` variable IN THE NEW TABLE.

SELECT * FROM air_visit_data

SELECT typeof(visit_date) FROM air_visit_data;

--add a new column:
ALTER TABLE air_visit_data ADD visit_date_formatted TEXT;

--fomatting the 'visit_date' variable: date() doesn't work on the m/d/yyyy format (only on mm/dd/yyyy), so it needs to be done manually using substr():
UPDATE air_visit_data 
SET visit_date_formatted =
CASE WHEN (length(visit_date) == 8) THEN (substr(visit_date, 5) || '-0' || substr(visit_date, 1, 1) || '-0' || substr(visit_date, 3, 1))
     WHEN ((length(visit_date) == 9) AND (length(substr(visit_date, 1, instr(visit_date, '/') - 1)) ==1)) THEN (substr(visit_date, 6) || '-0' || substr(visit_date, 1, 1) || '-' || substr(visit_date, 3, 2))
	 WHEN ((length(visit_date) == 9) AND (length(substr(visit_date, 1, instr(visit_date, '/') - 1)) ==2)) THEN (substr(visit_date, 6) || '-' || substr(visit_date, 1, 2) || '-0' || substr(visit_date, 4, 1))
	 ELSE (substr(visit_date, 7) || '-' || substr(visit_date, 1, 2) || '-' || substr(visit_date, 4, 2))
	 END;

---copy the table to a new table air_visit_data_v:
CREATE TABLE  air_visit_data_v AS
SELECT air_store_id, visit_date_formatted, visitors
FROM air_visit_data;

select * from air_visit_data_v ;


---------IN this section we will work with the 'air_reserve table':
--Add columns separating date and time from `visit_datetime` and `reserve_datetime` variables and creating a new table "air_reserve_v":
SELECT * FROM air_reserve;

--Adding new columns:
ALTER table air_reserve ADD visit_date_formatted;
ALTER table air_reserve ADD visit_time TEXT;
ALTER table air_reserve ADD reserve_date_formatted TEXT;
ALTER table air_reserve ADD reserve_time TEXT;

--adding data: since the datetime variables are in the format of yyyy-mm-dd HH:MM:SS, the date() function can work here:
UPDATE air_reserve
SET visit_date_formatted == date(visit_datetime),
 visit_time = strftime('%H:%M:%S', visit_datetime),
 reserve_date_formatted = date(reserve_datetime),
 reserve_time = strftime('%H:%M:%S', reserve_datetime); 

SELECT * FROM air_reserve;

CREATE TABLE air_reserve_v AS
SELECT air_store_id, visit_date_formatted,visit_time, reserve_date_formatted, reserve_time,reserve_visitors
FROM air_reserve;

-- Let's see the new table:
SELECT * FROM air_reserve_v;


--------------IN this section we will do the same for hpg_reserve table:
--Add columns separating date and time from `visit_datetime` and `reserve_datetime` variables and creating a new table "air_reserve_v":

SELECT * FROM hpg_reserve;

--Adding new columns:
ALTER table hpg_reserve ADD visit_date_formatted;
ALTER table hpg_reserve ADD visit_time TEXT;
ALTER table hpg_reserve ADD reserve_date_formatted TEXT;
ALTER table hpg_reserve ADD reserve_time TEXT;

--adding data: since the datetime variables are in the format of yyyy-mm-dd HH:MM:SS, the date() function can work here:
UPDATE hpg_reserve
SET visit_date_formatted == date(visit_datetime),
 visit_time = strftime('%H:%M:%S', visit_datetime),
 reserve_date_formatted = date(reserve_datetime),
 reserve_time = strftime('%H:%M:%S', reserve_datetime); 

SELECT * FROM hpg_reserve;

CREATE TABLE hpg_reserve_v AS
SELECT hpg_store_id, visit_date_formatted,visit_time, reserve_date_formatted, reserve_time,reserve_visitors
FROM hpg_reserve;

-- Let's see the new table:
SELECT * FROM hpg_reserve_v;

-----------In this section we will separate the date from ID in sample_submission table:
select * from sample_submission

--air store ID is represented as 20 character long ID + "_" + "date"
ALTER TABLE sample_submission ADD COLUMN air_store_id2 text;
ALTER TABLE sample_submission ADD COLUMN visit_date_formatted text;

--separeting the values and entering them to the new column we generated earlier: 
UPDATE sample_submission
SET air_store_id2 = SUBSTRING(air_store_id, 1, 20),
    visit_date_formatted = SUBSTRING(air_store_id, 22, 10);

--deleting the old columns:
ALTER TABLE sample_submission drop COLUMN air_store_id;
ALTER TABLE sample_submission drop COLUMN visitors;

--adding visitors column and setting it to 0 as it was:
ALTER TABLE sample_submission ADD COLUMN visitors INTEGER;

UPDATE sample_submission
SET visitors =0;

select * from sample_submission;


----IN THIS SECTION WE WILL REFORMAT THE DATES IN date_info TABLE TO MATCH THE YYYY-mm-dd FORMAT:
select * from date_info

--add a new column:
ALTER TABLE date_info add calendar_date_formatted

--fomatting the 'calendar_date' variable manually because the date() function does not work on m/d/yyyy dates and only on mm/dd/yyyy.
UPDATE date_info 
SET calendar_date_formatted =
CASE WHEN (length(calendar_date) == 8) THEN (substr(calendar_date, 5) || '-0' || substr(calendar_date, 1, 1) || '-0' || substr(calendar_date, 3, 1))
     WHEN ((length(calendar_date) == 9) AND (length(substr(calendar_date, 1, instr(calendar_date, '/') - 1)) ==1)) THEN (substr(calendar_date, 6) || '-0' || substr(calendar_date, 1, 1) || '-' || substr(calendar_date, 3, 2))
	 WHEN ((length(calendar_date) == 9) AND (length(substr(calendar_date, 1, instr(calendar_date, '/') - 1)) ==2)) THEN (substr(calendar_date, 6) || '-' || substr(calendar_date, 1, 2) || '-0' || substr(calendar_date, 4, 1))
	 ELSE (substr(calendar_date, 7) || '-' || substr(calendar_date, 1, 2) || '-' || substr(calendar_date, 4, 2))
	 END;

--drop the old column:
ALTER TABLE date_info drop COLUMN calendar_date


select * from date_info

------------------------------------SECOND STEP: LET'S SEE HOW MANY RECORDS AND UNIQUE ID'S EACH TABLE HAS:
--1:
SELECT COUNT(air_store_id) AS air_restaurants, count(hpg_store_id) as hpg_restaurants
from store_id_relation;
--150 records, same value as count(DISTINCT)

--2:
SELECT COUNT(DISTINCT(air_store_id)) AS restaurants, count((air_store_id)) as total_amount
from air_reserve_v;
--314 unique id's and 92,378 records

--3:
SELECT COUNT(DISTINCT(hpg_store_id)) AS restaurants, count((hpg_store_id)) as total_amount
from hpg_reserve_v;
--13,325 unique values and 2,000,320 records (as mentioned in the protocol, there are more than needed restaurants in hpg)

--4:
SELECT COUNT(DISTINCT(air_store_id)) AS restaurants, count(air_store_id) as total_amount
from air_visit_data_v;
--829 distinct values, 252,108 records

--5:
SELECT COUNT(DISTINCT(air_store_id)) AS restaurants, count((air_store_id)) as total_amount
from air_store_info;
--829 unique id's 

--6:
SELECT COUNT(DISTINCT(hpg_store_id)) AS restaurants, count((hpg_store_id)) as total_amount
from hpg_store_info;
--4690 unique id's 

--7:
select * from sample_submission

SELECT COUNT(DISTINCT(air_store_id2)) AS restaurants, count((air_store_id2)) as total_amount
from sample_submission;
--821 unique id's and 32,019 records
--the data omits the "GOLDEN WEEK" holidays in Japan

--8: date_info: calendar_date_f 517 days
SELECT COUNT(calendar_date_formatted) as days_total
from date_info;

	
------------------------------------THIRD STEP: LET'S SEE HOW MANY shared restaurants we have BETWEEN the tables:


--1: air_reserve_v & store_id_relation : 131 IDs less than 150
SELECT COUNT(DISTINCT store_id_relation.air_store_id)
FROM store_id_relation
INNER JOIN air_reserve_v
ON store_id_relation.air_store_id = air_reserve_v.air_store_id;

--2: hpg_reserve_v & store_id_relation: 150 IDs - makes sense
SELECT COUNT(DISTINCT store_id_relation.hpg_store_id) as shared_restaurants
FROM store_id_relation
INNER JOIN hpg_reserve_v
ON store_id_relation.hpg_store_id = hpg_reserve_v.hpg_store_id;

--3: air_reserve_v & air_store_info --314 IDs
SELECT COUNT(DISTINCT air_store_info.air_store_id) as shared_restaurants
FROM air_store_info
INNER JOIN air_reserve_v
ON air_store_info.air_store_id = air_reserve_v.air_store_id;

--4: air_reserve_v & air_visit_data_v -314 IDs
SELECT COUNT(DISTINCT air_visit_data_v.air_store_id) as shared_restaurants
FROM air_visit_data_v
INNER JOIN air_reserve_v
ON air_visit_data_v.air_store_id = air_reserve_v.air_store_id;

--5: air_visit_data_v & store_id_relation :150 IDs as expected
SELECT COUNT(DISTINCT store_id_relation.air_store_id)
FROM store_id_relation
INNER JOIN air_visit_data_v
ON store_id_relation.air_store_id = air_visit_data_v.air_store_id;

--6: air_store_info & air_visit_data_formatted :829 IDs as expected
SELECT COUNT(DISTINCT air_store_info.air_store_id)
FROM air_store_info
INNER JOIN air_visit_data_v
ON air_store_info.air_store_id = air_visit_data_v.air_store_id;

--8: air_reserve_v & sample_submission - 314  IDs
SELECT COUNT(DISTINCT sample_submission.air_store_id2) as restaurants
FROM sample_submission
INNER JOIN air_reserve_v
ON sample_submission.air_store_id2 = air_reserve_v.air_store_id;


----------------------------------------FORTH STEP: concate air_visit_data_v (train) with sample_submission (test)
---air_visit_data_formatted has 829 unique IDS and sample_submission has 821. 

select * from air_visit_data_v;

select * from sample_submission;

CREATE TABLE train_test (
   air_store_id TEXT,
   visit_date TEXT,
   visitors INTEGER
);

INSERT INTO train_test (air_store_id, visit_date, visitors)
SELECT air_store_id, visit_date_formatted, visitors
FROM air_visit_data_v;

SELECT * FROM train_test;

INSERT INTO train_test (air_store_id, visit_date, visitors)
SELECT air_store_id2, visit_date_formatted, visitors
FROM sample_submission;

SELECT * FROM train_test;


-----------------------------------------FIFTH STEP: ADD STORE INFO (genre, area, latitude, longitude) AND CALENDAR DATES 
select * from air_store_info


CREATE TABLE temp_table AS
SELECT train_test.*, air_store_info.air_genre_name, air_store_info.air_area_name, air_store_info.latitude, air_store_info.longitude
FROM train_test
LEFT JOIN air_store_info ON train_test.air_store_id = air_store_info.air_store_id;

select * from temp_table;


--adding calendar info: day of week and holiday flag
select * from date_info

CREATE TABLE my_table1 AS
SELECT temp_table.*, date_info.day_of_week, date_info.holiday_flg
FROM temp_table
LEFT JOIN date_info ON temp_table.visit_date = date_info.calendar_date_formatted;

select * from my_table1;

--------------------------------------- STEP 6: creating one reservation table using hpg_reserve_v,air_reserve_v AND store_id_relation TABLES:
select * from hpg_reserve_v;

select * from store_id_relation

--lets create a table where hpg_reserve_v contains the air_store_IDs from store_id_relation table:
CREATE TABLE hpg_res_relation1 AS
SELECT hpg_reserve_v.*, store_id_relation.*
FROM hpg_reserve_v
LEFT JOIN store_id_relation 
ON hpg_reserve_v.hpg_store_id = store_id_relation.hpg_store_id;
 
select * from hpg_res_relation1;

alter table hpg_res_relation1 DROP COLUMN "hpg_store_id:1"
 
 
----- concate air_reserve_v with hpg_res_relation1(to enrich air_reserved data)

select * from hpg_res_relation1;

select count(distinct(air_store_id)), count(air_store_id)
from hpg_res_relation1; -- 150 IDs, 28183 records with air_store_id;
 

select * from air_reserve_v;
 
--alter table hpg_res_relation1 DROP column hpg_store_id;
create table reserved_ifo (
	air_store_id TEXT,
	visit_date_formatted TEXT,
	visit_time TEXT,
	reserve_date_formatted TEXT,
	reserve_time TEXT,
	reserve_visitors INTEGER 
);

select * from reserved_ifo;

INSERT INTO reserved_ifo (air_store_id, visit_date_formatted, visit_time, reserve_date_formatted, reserve_time, reserve_visitors )
SELECT air_store_id, visit_date_formatted, visit_time, reserve_date_formatted, reserve_time, reserve_visitors
FROM air_reserve_v;

SELECT * FROM reserved_ifo;

INSERT INTO reserved_ifo (air_store_id, visit_date_formatted, visit_time, reserve_date_formatted, reserve_time, reserve_visitors)
SELECT air_store_id, visit_date_formatted, visit_time, reserve_date_formatted, reserve_time, reserve_visitors
FROM hpg_res_relation1
WHERE air_store_id is NOT NULL;

SELECT * FROM reserved_ifo;

select count(distinct(air_store_id)), count(air_store_id)
from reserved_ifo; -- 333 IDs, 148,744 records with air_store_id;


----------------------------------------SIXTH STEP: ADD RESERVATION INFO - TIME AND DATE OF RESERVATION, VISIT TIME AND DATE, AND NUMBER OF VISITORS
--*NOTE:* Since there are only 333 UNIQUE ID's in air_reserve_formatted table, we will be adding some NULLS

select * from reserved_ifo;
select * from my_table1;

select count(air_store_id) from my_table1; --284,127

CREATE TABLE my_table2 AS
SELECT my_table1.* , reserved_ifo.*
FROM my_table1
LEFT JOIN reserved_ifo
ON my_table1.air_store_id = reserved_ifo.air_store_id AND my_table1.visit_date = reserved_ifo.visit_date_formatted;

SELECT * FROM my_table2;


--Let's count how many null values have entered the train_test table:
select count(air_store_id) from my_table2; --379,482

SELECT COUNT(*)
FROM my_table2
WHERE "air_store_id:1" IS NULL; -- 247160
--247160 NULL values which is 65% of the data. 

-------------------------------------------FINAL STEP : exporting THE FLAT FILE
--JUST DO `EXPORT` TO THE 'my_table2' TABLE USING THE DB BROWSER DATABASE STRUCTURE ON THE LEFT MENU.


גכדדד
דקךקדדדזדדק