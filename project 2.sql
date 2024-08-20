-- 1  Retrieve the total number of orders placed .

select count(order_id)
 from pizzu.orders
 
 -- 2  Calculate the total revenue generated from pizza sales.
 
 with cte as 
 (select order_id, price * quantity as sales
 from pizzu.pizzas as p
 left join pizzu.order_details as o
 on p.pizza_id = o.pizza_id)
 
 select round(sum(sales),2) as revenue from cte
 
--  3 Identify the highest-priced pizza.

select pizza_type_id ,price 
from pizzu.pizzas
order by price desc
limit 1

--  4 Identify the most common pizza size ordered.

select size,count(size) as common_pizza_size
from pizzu.order_details as o
left join pizzu.pizzas as p
on o.pizza_id = p.pizza_id
group by size
order by count(order_details_id) desc 
limit 1

-- 5  List the top 5 most ordered pizza types along with their quantities.

 SELECT name,sum(quantity) as total_quantity
 from pizzu.order_details as d 
left join pizzu.pizzas  as p on d.pizza_id = p.pizza_id
left join pizzu.pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by name 
order by sum(quantity) desc 
limit 5
 
 --  6 Join the necessary tables to find the total quantity of each pizza category ordered.

 SELECT category,sum(quantity) as total_quantity
 from pizzu.order_details as d 
left join pizzu.pizzas  as p on d.pizza_id = p.pizza_id
left join pizzu.pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by category

-- 7 Determine the distribution of orders by hour of the day.

with cte as 
(select hour(order_time)as Hours,order_id from pizzu.orders)

select Hours,count(order_id) as total_orders
from cte
group by Hours
order by count(order_id) desc 

-- 8 Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) as distribution
from pizza_types
group by category

-- 9 Group the orders by date and calculate the average number of pizzas ordered per day.
with cte as 
(select order_date, sum(quantity) as tot 
from orders as o 
left join order_details as d 
on o.order_id = d.order_id
group by order_date)

select avg(tot) from cte

-- 10 Determine the top 3 most ordered pizza types based on revenue.

select name,sum(price * quantity) as revenue from order_details as d 
left join pizzas as p on d.pizza_id = p.pizza_id
left join pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by name
order by sum(price * quantity) desc
limit 3

-- 11 Calculate the percentage contribution of each pizza type to total revenue.
with cte as 
(select category,round(sum(price * quantity),2) as revenue from order_details as d 
left join pizzas as p on d.pizza_id = p.pizza_id
left join pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by category)

select category,round(revenue * 100/(select sum(revenue) from cte),2) as percent_cont
from cte

-- 12 Analyze the cumulative revenue generated over time.

with cte as 
(select order_date,ROUND(sum(price*quantity),2) as revenue
from pizzas as p 
left join order_details as d 
on p.pizza_id = d.pizza_id
left join orders as o on d.order_id = o.order_id
group by order_date)

select order_date,round(sum(revenue)over(order by order_date),1) as cumm_revenue
from cte
where order_date is not null

--  13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as 
(select category,name,sum(price*quantity) as revenue
from pizzas as p 
left join order_details as d on p.pizza_id = d.pizza_id 
left join pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by category,name)
,cte2 as 
(select *, rank()over(partition by category order by revenue desc) as rnk
from cte )

select category,name,revenue from cte2
where rnk <= 3
