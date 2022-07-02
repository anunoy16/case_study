-- What are the standard ingredients for each pizza?

-- First change the type from (text) to (var) to perform split_string on pizza_recipes
-- eather string_split or string_agg can not perform on text format
/*

alter table pizza_recipes
alter COLUMN toppings NVARCHAR(100);
alter table pizza_names
alter column pizza_name varchar(20);


with t1 as (
select p.pizza_id,p.pizza_name,r.toppings,pt.topping_name from(
select pizza_id,ltrim(value) as toppings
 from pizza_recipes
 cross apply string_split(toppings,',')) as r
 join pizza_names p
 on r.pizza_id=p.pizza_id
 join pizza_toppings pt
 on r.toppings=pt.topping_id
)
select pizza_id,pizza_name,string_agg(topping_name,' , ') as topping_name  from t1
group by pizza_id,pizza_name

*/

-- What was the most commonly added extra?

/*
alter table pizza_toppings
alter column topping_name VARCHAR(20);


select distinct(pt.topping_name) from (
select order_id,customer_id,pizza_id,ltrim(value) as extras from temp_co
cross apply string_split(extras,',') ) a
join pizza_toppings pt
on a.extras=pt.topping_id
*/

-- What was the most common exclusion?

/*
select distinct(pt.topping_name) from (
select order_id,customer_id,pizza_id,value as exclusion from temp_co
cross apply string_split(exclusion,',')
) a
join pizza_toppings pt
on a.exclusion=pt.topping_id
*/

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

/*
with exclusion as (
select order_id,customer_id,pizza_id,ltrim(value) as exclusion from temp_co
cross apply string_split(exclusion,',')
where pizza_id=1
),
extra as (
select order_id,customer_id,pizza_id,ltrim(value) as extra from temp_co
cross apply string_split(extras,',')
where pizza_id=1
),
t1 as (
select ex.order_id,ex.customer_id,ex.pizza_id,ex.exclusion,e.extra
from exclusion ex
join extra e
on ex.order_id=e.order_id
)
select *,
(case when exclusion = 0 and extra = 0 then 'Meat Lover'
when exclusion = 3 and extra=extra then 'Meat Lover - Exclude Beef'
when exclusion =exclusion and extra = 1 then 'Meat Lover-Extra Beacon'
when exclusion = 4 and exclusion =1 and extra = 6 and extra = 9 
then 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
else ''
end ) as remarks
from t1
*/

--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
--and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

/*
with t1 as (
select ex.order_id,ex.customer_id,ex.pizza_id,
(case when pt.topping_name is NULL then '' else concat('2 X ',pt.topping_name) end) as extras
from (
SELECT order_id,customer_id,pizza_id,ltrim(value) as extras
from temp_co
cross APPLY string_split(extras,',')
) ex
join pizza_toppings pt
on ex.extras=pt.topping_id
),
t2 as (
select order_id,customer_id,pizza_id,STRING_AGG(extras,',') as extras from t1
GROUP by order_id,customer_id,pizza_id
),
t3 as (
select a.pizza_id,STRING_AGG(a.topping_name,',') as topping_name 
from (
select  pr.pizza_id,pt.topping_name from (
select pizza_id,ltrim(value) as topping_id from pizza_recipes
cross APPLY string_split(toppings,',') ) pr
join pizza_toppings pt
on pr.topping_id=pt.topping_id
) a
GROUP by a.pizza_id 
)
select co.order_id,co.customer_id,co.pizza_id,co.extras,t3.topping_name,
(case when co.extras = '' then '' else t2.extras end ) as extra_toppings
from temp_co co
join t3 
on co.pizza_id=t3.pizza_id
left join t2 
on co.order_id=t2.order_id and co.customer_id=t2.customer_id 
*/

--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

/*
with t1 as (
select b.lable,b.order_id,b.customer_id,b.pizza_id,count(*) as base_topping_count from (
select a.lable,a.order_id,a.customer_id,a.pizza_id,ltrim(value) as topping from (
select ROW_NUMBER() over (order by order_id) as lable,
co.order_id,co.customer_id,co.pizza_id,pr.toppings
from temp_co co
left join pizza_recipes pr
on co.pizza_id=pr.pizza_id
) a
cross apply string_split(a.toppings,',') 
) b
group by b.lable,b.order_id,b.customer_id,b.pizza_id
),
t2 as (
select c.lable,c.order_id,c.customer_id,c.pizza_id,count(c.exclussion) as exclusion_count from (
select b.lable,b.order_id,b.customer_id,b.pizza_id,(case when b.exclusion = '' then NULL else b.exclusion end) as exclussion from (
SELECT a.lable,a.order_id,a.customer_id,a.pizza_id,LTRIM(value) as exclusion from (
select ROW_NUMBER() over(order by order_id) as lable,order_id,customer_id,pizza_id,exclusion from temp_co
) a
cross apply string_split(a.exclusion,',')
) b
) c
group by c.lable,c.order_id,c.customer_id,c.pizza_id
),
t3 as (
select c.lable,c.order_id,c.customer_id,c.pizza_id,count(c.extras) as extras_count from (
select b.lable,b.order_id,b.customer_id,b.pizza_id,(case when b.extras = '' then NULL else b.extras end) as extras from (
SELECT a.lable,a.order_id,a.customer_id,a.pizza_id,LTRIM(value) as extras from (
select ROW_NUMBER() over(order by order_id) as lable,order_id,customer_id,pizza_id,extras from temp_co
) a
cross apply string_split(a.extras,',')
) b
) c
group by c.lable,c.order_id,c.customer_id,c.pizza_id
)

SELECT t1.lable,t1.order_id,t1.customer_id,t1.pizza_id,
(t1.base_topping_count+t3.extras_count-t2.exclusion_count) as no_of_ingredients
from t1
join t2
on t1.lable=t2.lable and t1.order_id=t2.order_id and t1.customer_id=t2.customer_id
join t3
on t1.lable=t3.lable and t1.order_id=t3.order_id and t1.customer_id=t3.customer_id;

*/

