 use dannys_diner ;
--What is the total amount each customer spent at the restaurant?
select customer_id , sum(n.price)as  tolal_spent
from sales s join menu n 
on s.product_id  =  n.product_id
group by customer_id;

--How many days has each customer visited the restaurant?
select  customer_id, count (distinct( order_date)) as visits
from sales  
group by customer_id ;

--What was the first item from the menu purchased by each customer?
with ranking as (
select customer_id,product_name,order_date ,
DENSE_RANK() over(partition by customer_id order by order_date ) as r_k
from sales s join menu n 
on s.product_id  =  n.product_id
)
select customer_id , product_name, order_date 
from ranking 
where r_k = 1 
GROUP BY customer_id, product_name, order_date;

--What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name , count(s.product_id)as total 
from sales s join menu n 
on s.product_id  =  n.product_id
group  by product_name 
order by total desc;
--Which item was the most popular for each customer?
select product_name ,customer_id, count(s.product_id)as total 
from sales s join menu n 
on s.product_id  =  n.product_id
group  by customer_id,product_name
order by customer_id asc,total desc;
--Which item was purchased just before the customer became a member?
with rank_order as (
select s.customer_id as customer  , product_name , order_date , join_date ,
dense_rank() over(partition by s.customer_id order by order_date) as r_k 
from sales s join menu  n 
on s.product_id  =  n.product_id 
join members m 

on m.customer_id = s.customer_id

)
select customer , product_name ,order_date
from rank_order 
where r_k = 1 and order_date <join_date ;
--Which item was purchased first by the customer after they became a member?
with rank_order as (
select s.customer_id as customer  , product_name , order_date , join_date ,
dense_rank() over(partition by s.customer_id order by order_date) as r_k 
from sales s join menu  n 
on s.product_id  =  n.product_id 
join members m 

on m.customer_id = s.customer_id
where order_date >=join_date
)
select customer , product_name ,order_date
from rank_order 
where r_k =1;
--What is the total items and amount spent for each member before they became a member?
select s.customer_id , count(s.product_id) as total_items , sum (price)as amount_spent
from sales s join menu  n 
on s.product_id  =  n.product_id 
join members m 
on m.customer_id = s.customer_id
where order_date < join_date
group by s.customer_id ;
  
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as (
select s.customer_id as customers , 
case when product_name = 'sushi' then price * 20
else price *10 
end as point 
from sales s join menu  n 
on s.product_id  =  n.product_id
)
select customers ,sum (point) as total_point
from points 
group by customers 
order by customers ;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?
with points as (
select s.customer_id as customers , 
case when  s.order_date between  m.join_date and  DATEADD (DAY ,6,m.join_date) THEN price * 20
     when product_name = 'sushi' then price * 20
     else price *10 
    
end as point 
from sales s join menu  n 
on s.product_id  =  n.product_id
join members m
on m.customer_id = s.customer_id 
where MONTH (s.order_date) = 1
)
select customers ,sum (point) as total_point
from points 
group by customers 
order by customers ;