
/*  1. What is the total amount each customer spent at the restaurant?

with t1 as (
select 
s.customer_id,s.order_date,s.product_id,m.product_name,m.price
from sales s
join menu m
on s.product_id=m.product_id
)
select customer_id,sum(price) as total_sales from t1
group by customer_id;

*/

/* 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) visit from sales
group by customer_id;

*/

/* 3. What was the first item from the menu purchased by each customer?

select 
customer_id,
order_date 
from
(select *,
ROW_NUMBER() over(partition by customer_id order by order_date) as first_visit
 from sales) rn
 WHERE rn.first_visit = 1;

*/

/* 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select a.product_name, count(a.product_name) as purchased
from (
select s.customer_id,s.order_date,s.product_id,m.product_name,m.price 
from sales s
join menu m
on s.product_id=m.product_id
) a
group by product_name
order by purchased desc;

*/

/* 5. Which item was the most popular for each customer? 

with t1 as
(select 
s.customer_id,
m.product_name
 from sales s, menu m
where s.product_id=m.product_id) 

select top(1) product_name, count(product_name) as popular_item
from t1
group by product_name
order by popular_item DESC;

*/

/* 6. Which item was purchased first by the customer after they became a member?  

with t1 as (
select 
s.customer_id,
s.order_date,
m2.product_name
from sales s
left join members m
on s.customer_id=m.customer_id
join menu m2
on s.product_id=m2.product_id
where order_date>join_date    ),
t2 as (
select *,
ROW_NUMBER() over(partition by customer_id order by order_date) as rn 
from t1)
select customer_id,product_name from t2
where rn=1;
 */

/* 7. Which item was purchased just before the customer became a member?

with t1 as (
    select 
    s.customer_id,
    s.order_date,
    m.join_date,
    mm.product_name
     from sales s
    left join members m
    on s.customer_id=m.customer_id
    join menu mm
    on s.product_id=mm.product_id
),
t2 as(
select *,
dense_rank() over(partition by customer_id order by order_date desc) as rn
from t1
where order_date<join_date 
)
select customer_id,product_name from t2
where rn=1;
*/

/* 8 . What is the total items and amount spent for each member before they became a member?

with t1 as (
select 
s.customer_id,
s.product_id,
m.product_name,
m.price
from sales s
join menu m
on s.product_id=m.product_id
)
select customer_id,product_name,sum(price) as total_sales
from t1
group by customer_id,product_name
order by customer_id;
*/

/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with t1 as (
select 
s.customer_id,
s.product_id,
m.product_name,
m.price
from sales s
join menu m
on s.product_id=m.product_id
),
t2 as (
select *,
(case
when product_name='sushi' then price*20
when product_name='curry' then price*10
when product_name='ramen' then price*10
end ) as points 
from t1
)
select customer_id,SUM(points) total_points
from t2
group by customer_id;

*/

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
       not just sushi - how many points do customer A and B have at the end of January?

with t1 as (
select *,
DATEADD(day,6,join_date) as valid_date,
EOMONTH('2021-01-31') as last_date
from members ),

t2 as (
select 
s.customer_id,s.order_date,t1.join_date,t1.valid_date,t1.last_date,m.product_name,m.price,
sum(case 
when m.product_name='sushi' then 2*10*m.price
when s.order_date BETWEEN t1.join_date and t1.valid_date then 2*10*price
else 10*m.price
end ) as points
from sales s
left join t1
on s.customer_id=t1.customer_id
join menu m
on s.product_id=m.product_id
where s.order_date<t1.last_date
group by s.customer_id,s.order_date,t1.join_date,t1.valid_date,t1.last_date,m.product_name,m.price 
)
select customer_id,
sum(points) as total_points
 from t2
 group by customer_id;
   
                            --OR

 with t1 as 
(
select *,
DATEADD(day,6,join_date) valid_date,
EOMONTH('2021-01-31') last_date
from members
),
t2 as (
select s.customer_id,s.order_date,t1.join_date,t1.valid_date,t1.last_date,M.product_name,M.price from sales s
left join t1
on s.customer_id=t1.customer_id
join menu m
on s.product_id=m.product_id
where s.order_date<t1.last_date
)
select 
customer_id, sum( case when order_date between join_date and valid_date then 2*10*price
when product_name='sushi' then 2*10*price 
else 10*price 
end) as total_points
from t2
group by customer_id;

*/