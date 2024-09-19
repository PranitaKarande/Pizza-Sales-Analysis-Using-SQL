create database pizzahut;
select * from order_details;
drop table orders;
drop table order_details;
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));
create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int  not null,
primary key (order_details_id));

alter table  order_details  modify order_details_id int  primary key;

select * from orders;
select * from order_details;
select * from pizzas;
select * from pizza_types;
-- to calculate total orders
select  count(order_id) as total from orders;

-- to calculate revenue by each pizza
select sum(total )as total_revenue from 
(select pizzas.pizza_type_id, sum(order_details.quantity* pizzas.price) as total from order_details inner join pizzas on order_details.pizza_id=pizzas.pizza_id
 group by pizza_type_id) as a ;
 
 -- identify name of the highest priced pizza
 select pizza_types.name, pizzas.price from pizza_types inner join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id order by price desc limit 1;
 
 -- identify the most common pizza size ordered
 select pizzas.size, count(order_details.order_details_id) as count from pizzas inner join order_details on pizzas.pizza_id =order_details.pizza_id group by pizzas.size 
 order by count desc  ;
 
 -- list the top 5 most ordered pizza types along with their revenue
select pizza_types.name, sum(order_details.quantity) as total from pizza_types inner join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details on pizzas.pizza_id=order_details.pizza_id group by name order by total desc limit 5 ;

-- list the top 5 most ordered pizza types along with their revenue 
select pizza_types.name, sum(pizzas.price) as revenue from pizza_types inner join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details on pizzas.pizza_id=order_details.pizza_id group by name order by revenue desc limit 5 ;

-- join necessary tables to find the total quantity of each pizza category ordered
select pizza_types.category, sum(order_details.quantity) as quantity from pizza_types inner join pizzas on pizza_types.pizza_type_id= pizzas.pizza_type_id 
inner join order_details on pizzas.pizza_id=order_details.pizza_id group by category order by quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as time, count(order_id) as orders_total from orders group by time;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day. not consider order_id due to in one order_id quantity 
-- of pizzas varies
select  avg(quantity) from
(select orders.order_date as date, sum(order_details.quantity) as quantity from orders inner join order_details on orders.order_id=order_details.order_id
 group by orders.order_date) as a ;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(pizzas.price* order_details.quantity) as revenue from pizza_types inner join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details on pizzas.pizza_id=order_details.pizza_id group by  pizza_types.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza category to total revenue.
select pizza_types.category as category, sum(order_details.quantity*pizzas.price)/(select sum(total )as total_revenue from 
(select pizzas.pizza_type_id, sum(order_details.quantity* pizzas.price) as total from order_details inner join pizzas on order_details.pizza_id=pizzas.pizza_id
 group by pizza_type_id)as a  ) *100  as total_revenue from
 pizza_types  join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details on pizzas.pizza_id=order_details.pizza_id group by category order by total_revenue desc ;

-- Analyze the cumulative revenue generated over time.
select date, round(sum(revenue) over (order by date),2) as cumulative from
(select orders.order_date as date, sum(order_details.quantity*pizzas.price) as revenue from orders inner join order_details on orders.order_id=order_details.order_id
inner join pizzas on pizzas.pizza_id=order_details.pizza_id group by orders.order_date)as  sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name , category, rnk from 
(select name, category,revenue, rank() over (partition by category order by revenue desc ) as rnk from
(select pizza_types.name, pizza_types.category,sum(pizzas.price*(order_details.quantity)) as revenue from pizza_types inner join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
inner join order_details on pizzas.pizza_id=order_details.pizza_id group by category, pizza_types.name ) as a) as b
 where rnk<=3;
