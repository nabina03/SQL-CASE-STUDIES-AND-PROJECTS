                        
					   https://8weeksqlchallenge.com/case-study-1/
                           Case Study #1 - Danny's Diner


CREATE DATABASE dannys_diner;
USE dannys_diner;
Show Databases 
Show Tables from  dannys_diner

describe sales
CREATE TABLE sales (
  customer_id varchar(10),
  order_date DATE,
  product_id int
);

DROP TABLE sales

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
 

CREATE TABLE menu (
  product_id int,
  product_name VARCHAR(10),
  price int
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  

CREATE TABLE members (
  customer_id VARCHAR(10),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'); 
  
Select *From sales
 
Select *From menu
Select * From members 

### What is the total amount each customer spent at the restaurant?

Select customer_id,sum(price) as Total_Price  from
(Select S.customer_id,S.product_id,M.product_name ,M.price From sales S
Join menu M
ON S.product_id=M.product_id) as CTE
group by customer_id 

with cte as(Select S.customer_id,S.product_id,M.product_name ,M.price From sales S
Join menu M
ON S.product_id=M.product_id)
Select customer_id,sum(price) as Total_Price  from cte group by customer_id 

## How many days has each customer visited the restaurant?

Select customer_id, count(Distinct order_date) as Total_days from sales group by customer_id

## What was the first item from the menu purchased by each customer? 
Select customer_id,order_date,product_name from 
(with xyz as (Select S.customer_id,S.order_date,S.product_id,M.product_name From sales S
Join menu M
ON S.product_id=M.product_id) 
Select customer_id,order_date,product_name,dense_rank() over(partition by customer_id order by order_date) as RR 
from xyz) as PDF 
where RR=1

##What is the most purchased item on the menu and how many times was it purchased by all customers?,
Select product_name , count(product_name) as Total_count from
(Select S.customer_id,S.product_id,M.product_name ,M.price From sales S
Join menu M
ON S.product_id=M.product_id) as PDF
group by product_name
order by Total_count desc limit 1 

###Which item was the most popular for each customer?
Select customer_id,product_name from (With CTE as (
Select customer_id, product_name, count(product_name) as TC from 
(Select S.customer_id,S.product_id,M.product_name ,M.price From sales S
Join menu M
ON S.product_id=M.product_id 
) as XYZ 
group by customer_id ,product_name )
Select customer_id, product_name,dense_rank() over(partition by customer_id order by TC desc) as RR
from CTE )as PDF where RR=1


###Which item was purchased first by the customer after they became a member?
Select customer_id,product_id from (
With CTE as (
Select customer_id,product_id,DS from(
Select customer_id , product_id, datediff(order_date,join_date) as DS from
(Select S.customer_id, S.product_id,S.order_date,M.join_date from sales s 
join members M
ON S.customer_id=M.customer_id) as PF) as XYZ
where DS>=0) 
Select customer_id, product_id ,DS, dense_rank() over(partition by customer_id order by DS) as RR from CTE) as ITEM
where RR=1

####Which item was purchased just before the customer became a member?
Select customer_id,product_name from(
With CTE AS (
Select customer_id,product_name,DS from(
Select customer_id,product_name,order_date,join_date,datediff(order_date,join_date) as DS from(
Select S.customer_id,S.product_id,M.product_name ,M.price,S.order_date,Me.join_date From sales S
Join menu M
ON S.product_id=M.product_id
Join members Me 
On S.customer_id=Me.customer_id
order by S.customer_id) as PDF) as XYZ 
where DS<0)
Select customer_id,product_name,DS,dense_rank() over(partition by customer_id order by DS desc) as RR from CTE) as PF
where RR=1

###What is the total items and amount spent for each member before they became a member? 

With CTE AS (
Select customer_id,product_name,price,DS from(
Select customer_id,product_name,price,order_date,join_date,datediff(order_date,join_date) as DS from(
Select S.customer_id,S.product_id,M.product_name ,M.price,S.order_date,Me.join_date From sales S
Join menu M
ON S.product_id=M.product_id
Left Join members Me 
On S.customer_id=Me.customer_id
order by S.customer_id) as PDF) as XYZ
where DS<0)
Select customer_id,product_name,sum(price) as Total_Price,count(product_name) as Total_Item from CTE
group by product_name,customer_id
order by customer_id 

##If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
 how many points would each customer have?  

 
 Select * ,count(product_id) as PP From
 Select customer_id, sum(PP) as Total_Points from
 (Select *,(points*PNC) as PP from(
With CTE AS( Select S.customer_id,K.points,K.product_name ,K.price from sales S
 Join
 ( Select *, Case 
 when product_name not in ("sushi") then price*10
 else
 price*20
 End as points 
 from menu ) K
 ON S.product_id=K.product_id)
 Select customer_id, product_name,count(product_name) as PNC ,points ,price from CTE
 group by product_name,customer_id) as PDF)BOU
 group by customer_id 
 
 ###In the first week after a customer joins the program (including their join date) 
 they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?




Select customer_id ,sum(point) as Total_Point from
 (
With CTE as(
Select *,datediff(order_date,join_date) as Date_Differnce from(
Select S.customer_id,S.order_date,S.product_id ,ME.join_date
from sales S
Join members ME 
ON S.customer_id=ME.customer_id
where S.order_date<="2021-01-31"
) PDF 
)
Select CT.*,PK.price,Pk.product_name, case 
when CT.Date_Differnce not in (0,1,2,3,4,5,6,7) and PK.product_name not in("sushi") then 10*PK.price
else 
20*PK.price 
End as point
from CTE CT
Join 
menu PK
on CT.product_id=PK.product_id 
order by CT.customer_id
) as YOU
group by customer_id 

####################  Bonus Questions ########################

###### Join All The Things


With CTE As (
Select S.customer_id,S.order_date,M.product_name,M.price,ME.join_date
from sales S
join menu M on S.product_id=M.product_id 
 Left Join members ME
on S.customer_id=ME.customer_id 
)
Select customer_id,order_date, product_name ,price ,case 
when datediff(order_date,join_date)>=0 then 'Y'
else 'N'
end as member
from CTE 
order by customer_id,price desc 

###### Rank All The Things 

With PQZ As (
With CTE As (
Select S.customer_id,S.order_date,M.product_name,M.price,ME.join_date
from sales S
join menu M on S.product_id=M.product_id 
 Left Join members ME
on S.customer_id=ME.customer_id 
)
Select customer_id,order_date, product_name ,price ,case 
when datediff(order_date,join_date)>=0 then 'Y'
else 'N'
end as member
from CTE 
order by customer_id,price desc )

Select *,case 
when member in ('Y') then row_number() over(order by price desc) 
else Null
end as ranking 
from PQZ