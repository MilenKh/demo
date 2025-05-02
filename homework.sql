-- 0. Drop and recreate schema to avoid conflicts
DROP SCHEMA IF EXISTS Homework;
CREATE SCHEMA Homework;
USE Homework;

-- 1. Create tables
CREATE TABLE Company (
  ID_comp INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE Passenger (
  ID_psg INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE Trip (
  trip_no INT PRIMARY KEY,
  ID_comp INT NOT NULL,
  plane VARCHAR(100),
  town_from VARCHAR(100),
  town_to VARCHAR(100),
  time_out DATETIME,
  time_in DATETIME,
  FOREIGN KEY (ID_comp) REFERENCES Company(ID_comp)
);

CREATE TABLE Pass_in_trip (
  trip_no INT,
  date DATE,
  ID_psg INT,
  place VARCHAR(5),
  PRIMARY KEY (trip_no, date, ID_psg),
  FOREIGN KEY (trip_no) REFERENCES Trip(trip_no),
  FOREIGN KEY (ID_psg) REFERENCES Passenger(ID_psg)
);

-- 1.5 Load your data
SOURCE airport_scheme_script.sql;

-- 2. Find all dates of the Paris–London trip
SELECT DISTINCT
  t.trip_no,
  pit.date
FROM Pass_in_trip AS pit
JOIN Trip AS t ON pit.trip_no = t.trip_no
WHERE t.town_from = 'Paris'
  AND t.town_to   = 'London'
ORDER BY t.trip_no, pit.date;

-- 3. Passengers whose surname starts with 'B'
SELECT *
FROM Passenger
WHERE SUBSTRING_INDEX(name, ' ', -1) LIKE 'B%';

-- 4. Number of passengers per flight per day
SELECT
  trip_no,
  date,
  COUNT(*) AS passenger_count
FROM Pass_in_trip
GROUP BY trip_no, date
ORDER BY trip_no, date;

-- 5. Passengers who traveled more than twice
SELECT
  p.ID_psg,
  p.name,
  COUNT(*) AS trips_count
FROM Pass_in_trip AS pit
JOIN Passenger AS p ON pit.ID_psg = p.ID_psg
GROUP BY pit.ID_psg
HAVING trips_count > 2;

-- 6. Flight directions for each company
SELECT
  c.ID_comp,
  c.name AS company_name,
  CONCAT(t.town_from, ' - ', t.town_to) AS direction
FROM Trip AS t
JOIN Company AS c ON t.ID_comp = c.ID_comp
GROUP BY c.ID_comp, direction
ORDER BY c.ID_comp, direction;

-- 7. Passengers who flew the same direction on more than two dates
SELECT
  p.ID_psg,
  p.name,
  CONCAT(t.town_from, ' - ', t.town_to) AS direction,
  COUNT(DISTINCT pit.date) AS dates_count
FROM Pass_in_trip AS pit
JOIN Trip      AS t ON pit.trip_no = t.trip_no
JOIN Passenger AS p ON pit.ID_psg  = p.ID_psg
GROUP BY pit.ID_psg, direction
HAVING dates_count > 2;
