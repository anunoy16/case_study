-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
/*
select 
DATEPART(week,registration_date) as registration_week,
count(runner_id) as sign_up
 from runners
 GROUP by DATEPART(week,registration_date)
*/

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

/*
with t1 as (
select 
distinct(r.order_id),r.runner_id,r.distance,r.duration,
c.customer_id,DATEDIFF(MINUTE,c.order_time,r.pickup_time) as pickup_duration
from temp_ro r
left join temp_co c
on r.order_id=c.order_id
where r.distance <>0
)
select avg(pickup_duration) as avg_pickup
from t1
*/

--  Is there any relationship between the number of pizzas and how long the order takes to prepare?
/*
with t1 as (
select r.order_id,r.pickup_time,r.distance,r.duration,
DATEDIFF(MINUTE,order_time,pickup_time) as making_time, c.exclusion,c.extras
from temp_ro r
join temp_co c
on r.order_id=c.order_id
where r.distance <> 0
)

select order_id,making_time,COUNT(order_id) as no_of_pizza_ordered from t1
GROUP by order_id,making_time
order by order_id
*/

-- What was the average distance travelled for each customer?

/*
with t1 as (
select 
c.order_id,c.customer_id,r.distance
from temp_co c
join temp_ro r
on c.order_id=r.order_id
WHERE distance<>0
)

SELECT customer_id,avg(distance) as avg_distance
from t1
group by customer_id
*/

 -- What was the difference between the longest and shortest delivery times for all orders?

/*
with t1 as (
select  max(duration) as mx_d, min(duration) as min_d from temp_ro
where distance <> 0)

select (mx_d - min_d) as delevery_time_diffeerence  from t1
*/

--What was the average speed for each runner for each delivery? 
/*
with t1 as (
select c.order_id,c.customer_id,r.runner_id,r.distance,
ROUND((r.distance/r.duration)*60,2) as avg_speed
from temp_co c
join temp_ro r
on c.order_id=r.order_id
WHERE distance != 0
)
select runner_id,round(avg(avg_speed),3) as runner_avg_speed from t1
GROUP by runner_id
*/

--What is the successful delivery percentage for each runner?

/*
with t1 as (
select r.runner_id,sum(case when r.distance = 0 then 1 else 0 end) as cancel,
sum(case when r.distance != 0 then 1 else 0 end ) as delivered
from temp_co c
join temp_ro r
on c.order_id=r.order_id
GROUP by r.runner_id
)
SELECT runner_id, (delivered*100)/(cancel+delivered) as success_percentang from t1

*/

