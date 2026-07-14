create database zomato_database;
use zomato_database;

CREATE TABLE zomato (
    RestaurantID TEXT,
    RestaurantName TEXT,
    CountryCode TEXT,
    City TEXT,
    Address TEXT,
    Locality TEXT,
    LocalityVerbose TEXT,
    Longitude TEXT,
    Latitude TEXT,
    Cuisines TEXT,
    Currency TEXT,
    Has_Table_booking TEXT,
    Has_Online_delivery TEXT,
    Is_delivering_now TEXT,
    Switch_to_order_menu TEXT,
    Price_range TEXT,
    Votes TEXT,
    Average_Cost_for_two TEXT,
    rating TEXT,
    datekey_opening varchar(50)
);

LOAD DATA  INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Zomato.csv"
INTO TABLE zomato
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET sql_mode = '';



select count(*) from zomato;
select * from zomato;

ALTER TABLE zomato
MODIFY CountryCode INT,
MODIFY Longitude DECIMAL(11,8),
MODIFY Latitude DECIMAL(11,8),
MODIFY Average_Cost_for_two INT,
MODIFY Price_range INT,
MODIFY rating DECIMAL(3,2),
MODIFY Votes INT,
modify datekey_opening DATE;

    

-- Q1.Build a country Map Table

CREATE TABLE Country_map(
     countrycode int,
     countryName varchar(200));
	
insert into Country_map values
           (1,"India"),
           (14,"Australia"),
           (30,"Brazil"),
           (37,"Canada"),
		   (94,"Indonesia"),
           (148,"New Zealand"),
		   (162,"Phillipines"),
           (166,"Qatar"),
           (184,"Singapore"),
		   (189,"South Africa"),
           (191,"Sri Lanka"),
           (208,"Turkey"),
           (214,"UAE"),
           (215,"United Kingdom"),
		   (216,"United States");
select * from Country_map;

select distinct countrycode, countryname from zomato join country_map using(countrycode); 


-- Q2. Calendar Table

create table calendar AS
select distinct DATE(datekey_opening) AS datekey,
  Year(DateKey_opening) as year,
  month(datekey_opening) as Month_no,
  Monthname(datekey_opening) as month_name,
  concat("Q",quarter(datekey_opening)) as quarter,
  date_format(datekey_opening,"%Y-%b") as yearmonth,
  dayofweek(datekey_opening) as weekdayNumber,
  dayname(datekey_opening) as weekdayName,
  CASE
    WHEN month(datekey_opening) = 4 then "FM1"
    WHEN month(datekey_opening) = 5 then "FM2"
    WHEN month(datekey_opening) = 6 then "FM3"
    WHEN month(datekey_opening) = 7 then "FM4"
	WHEN month(datekey_opening) = 8 then "FM5"
	WHEN month(datekey_opening) = 9 then "FM6"
	WHEN month(datekey_opening) = 10 then "FM7"
	WHEN month(datekey_opening) = 11 then "FM8"
	WHEN month(datekey_opening) = 12 then "FM9"
	WHEN month(datekey_opening) = 1 then "FM10"
	WHEN month(datekey_opening) = 2 then "FM11"
	WHEN month(datekey_opening) = 3 then "FM12"
    end as FinancialMonth,
    
    CASE
       WHEN month(datekey_opening) in (4,5,6) then "FQ1"
       WHEN MONTH(DATEKEY_opening) IN (7,8,9) THEN "FQ2"
       WHEN MONTH(datekey_opening) IN (10,11,12) THEN "FQ3"
       WHEN MONTH(DATEKEY_opening) IN (1,2,3) THEN "FQ4"
       END AS FinancialQuarter
from zomato;

select * from calendar;


-- Q3 .Find the Numbers of Resturants based on City and Country.

-- 	Number of Restaurants based on country
SELECT  COUNTRYNAME,COUNT(*) AS RESTAURANT_COUNT
FROM ZOMATO JOIN COUNTRY_MAP USING(COUNTRYCODE)
GROUP BY COUNTRYNAME
ORDER BY RESTAURANT_COUNT DESC ;

-- Number of Restaurants based on city
SELECT CITY , COUNT(*) AS RESTAURANT_COUNT 
FROM ZOMATO JOIN COUNTRY_MAP USING(COUNTRYCODE)
GROUP BY CITY
ORDER BY RESTAURANT_COUNT DESC;

-- Q4..Numbers of Resturants opening based on Year , Quarter , Month

-- Number of Restaurants opening based on Year
select year(datekey_opening) as Year ,count(restaurantid) as rest_count 
from zomato
group by year
order by rest_count desc;

-- Number of Resturants opening based on Quarter 
select  quarter(datekey_opening) as quarter , count(restaurantid) as rest_count
from zomato
group by quarter
order by rest_count desc;
-- .Numbers of Resturants opening based on Month
select monthname(datekey_opening) as month, count(restaurantid) as rest_count
from zomato
group by month
order by rest_count desc;

-- Q5.  Count of Resturants based on Average Ratings

select * from zomato;
select rating as average_rating, count(*) as restaurant_count
from zomato
group by rating 
order by rating desc
limit 10 ;

-- Q6 Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
select
  CASE
  WHEN Average_Cost_for_two BETWEEN 0 AND 500 THEN "Low"
  WHEN Average_Cost_for_two BETWEEN 501 AND 1000 THEN "Medium"
  WHEN Average_Cost_for_two BETWEEN 1001 AND 1500 THEN " High"
  WHEN Average_Cost_for_two BETWEEN 1501 AND 3000 THEN "Premiun"
  ELSE "Luxury"
  end as "price_bucket", 
  count(*) as  rest_count  from zomato
  group by price_bucket
  order by rest_count desc;
  
 -- Q7. .Percentage of Resturants based on "Has_Table_booking"
SELECT COUNT(*) AS RESTAURANT_COUNT, HAS_TABLE_BOOKING,
concat(ROUND(COUNT(*)*100/ (SELECT COUNT(*) FROM ZOMATO),2),"%") AS Percentage
FROM ZOMATO
group by has_table_booking;

-- Q8. Percentage of Resturants based on "Has_Online_delivery"
SELECT COUNT(*) AS RESTAURANT_COUNT, HAS_ONLINE_DELIVERY,
CONCAT(ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM ZOMATO),2),"%") AS PERCENTAGE
FROM ZOMATO
GROUP BY HAS_ONLINE_DELIVERY;

-- Q9. Develop Charts based on Cusines, City, Ratings

-- TOP 10 CUSINIES BY RESTAURANT COUNT
SELECT DISTINCT CUISINES,COUNT(*) AS TOTAL_RESTAURANTS
FROM ZOMATO
GROUP BY CUISINES
ORDER BY TOTAL_RESTAURANTS DESC
LIMIT 10;

-- TOP 10 CITY BY RESTAURANT COUNT
SELECT CITY , COUNT(*) AS TOTAL_RESTAURANT
FROM zomato
GROUP BY CITY
ORDER BY TOTAL_RESTAURANT DESC
LIMIT 10;

-- TOP 10 RESTURANT BY RATING
SELECT  RestaurantName,RATING, COUNT(*) AS TOTAL_RESTAURANT
FROM zomato
GROUP BY RATING
ORDER BY RATING DESC
LIMIT 10;

-- some more KPIs
-- total country
select count(distinct countrycode) as total_country from zomato;

-- total city
select count(distinct city) as total_city from zomato;

-- total restaurant
select count(distinct restaurantid) as total_restaurant from zomato;

-- total cuisines
select count(distinct cuisines) as total_cuisines from zomato;

-- total votes by city
select city, sum(votes) as total_votes 
from zomato
group by city
order by total_votes desc;