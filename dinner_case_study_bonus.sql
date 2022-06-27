/* bonus Q
with t1 as (
select 
s.customer_id,
s.order_date,
m.product_name,
m.price,
me.join_date
 from sales s
join menu m
on s.product_id=m.product_id
left join members me
on s.customer_id=me.customer_id
)
SELECT customer_id,order_date,product_name,price,
(case
when order_date>=join_date then 'Y'
else 'N'
end
) as member
FROM t1;
*/
with t1 as (
select 
s.customer_id,
s.order_date,
m.product_name,
m.price,
me.join_date
 from sales s
join menu m
on s.product_id=m.product_id
left join members me
on s.customer_id=me.customer_id
),
t2 as (
SELECT customer_id,order_date,product_name,price,
(case
when order_date>=join_date then 'Y'
else 'N'
end
) as member
FROM t1 )
select *,
(case
when member = 'N' then 'NULL'
else cast(rank()  over(partition by customer_id,order_date order by customer_id ) as varchar)
end) as ranking
 from t2