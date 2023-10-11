
/*
REMOVE NEGATIVE RECORDS FROM (fare_amount, extra, mta_tax, tip_amount, tolls_amount, imp_surcharge, airport_fee, total_amount, trip_distance) FIELDS
*/
 
UPDATE trips SET fare_amount=fare_amount*-1, extra=extra*-1, mta_tax=mta_tax*-1, tip_amount= tip_amount*-1,
tolls_amount= tolls_amount*-1, imp_surcharge=imp_surcharge*-1, airport_fee=airport_fee*-1, total_amount=total_amount*-1, trip_distance=trip_distance*-1
WHERE fare_amount <0 OR extra <0 OR mta_tax<0 OR tip_amount<0 OR tolls_amount<0 OR imp_surcharge<0 OR airport_fee<0 OR trip_distance<0 OR total_amount <0



---------------------------------------------------------------------------------------------------------
-- Get the avergae trip distance, average trip fare and total revenue over all provided data and per zone pair.

-- avg trip distance for overall data and per zone pair

SELECT pickup_location_id, dropoff_location_id, 
		AVG(trip_distance) OVER(PARTITION BY pickup_location_id, dropoff_location_id) AS zone_pair_avg_tripdist,
		AVG(trip_distance) OVER() AS overall_avg_tripdist
FROM trips



-- avg fare amount for overall data and per zone pair
SELECT AVG(fare_amount)
FROM trips;

SELECT pickup_location_id, dropoff_location_id, 
		ROUND(AVG(fare_amount) OVER(PARTITION BY pickup_location_id, dropoff_location_id),2) AS zone_pair_avg_fareamount,
		ROUND(AVG(fare_amount) OVER(),2) AS overall_avg_fareamount
FROM trips
;



-- total revenue for overall data and per zone pair

SELECT pickup_location_id, dropoff_location_id, 
		ROUND(SUM(total_amount) OVER(PARTITION BY pickup_location_id, dropoff_location_id),2) AS zone_pair_total_rev,
		ROUND(SUM(total_amount) OVER(),2) AS overall_total_rev
FROM trips

-------------------------

--2) Get what hour of the day that has the highest number of trips and average trip price per hour.

SELECT TOP 1 DATEPART(hour,pickup_datetime) AS day_hours, COUNT(id) AS trips_count
FROM trips
GROUP BY DATEPART(hour,pickup_datetime)
ORDER BY trips_count DESC;
-- 17:00 hour has the highest number of trips 4958 trip

SELECT DATEPART(hour,pickup_datetime) AS day_hours, ROUND(AVG(fare_amount),2) AS avg_fare_per_hr
FROM trips
GROUP BY DATEPART(hour,pickup_datetime)
ORDER BY Avg_fare_per_hr DESC;
-- 




--3) Get the most Pickup and Dropoff pair with the highst number of trips
SELECT TOP 1 pickup_location_id , dropoff_location_id, COUNT(id) AS trips_count
FROM trips
GROUP BY pickup_location_id , dropoff_location_id
ORDER BY trips_count DESC;





--4) Some observations that doesn't make sense
--a	 The second most zone pairs have the highest trips count have the same pickup and dropoff location which is JFK airport, which doesn’t make sense to have much trips in the same airport location.
--b	 In addition to the first point, although this zone pair (pickup location: JFK dropoff location: JFK) has high number of trips it comes 5th of the sum of the total amount.
--c  This means that most trip counted in the airport are either falsely counted or cancelled. Reasons for such behaviour needs to be further investigated.






-- 5) Develop a metric to measure each car performance out of the data
-- We can get develop a metric to see each car Total Revenues vs Total Trip distance

SELECT car_id, SUM(trip_distance) AS trips_dist_per_Car,
SUM(total_amount) AS total_amount_per_car
FROM trips
GROUP BY car_id
ORDER BY trips_dist_per_Car, total_amount_per_car;

SELECT car_id, SUM(trip_distance) AS total_trip_distance, SUM(total_amount) AS total_amount,
       ROUND((SUM(total_amount) / SUM(trip_distance)),2) AS amount_to_distance_ratio
FROM trips
WHERE trip_distance > 0
GROUP BY car_id
ORDER BY amount_to_distance_ratio;


