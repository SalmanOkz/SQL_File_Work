create database MISC

use MISC

create table LeftTable(
dateed date,
CountryID int,
Units int,
)


create table RightTable(
ID int,
Country varchar(20),
)

insert into LeftTable (dateed,CountryID,Units)
values
	
	('2020-01-04',7,50)



insert into RightTable (ID,Country)
values
	(1,'Pak'),
	(1,'USA'),
	(3,'Eng'),
	(4,'UAE')

	select * from RightTable;
	select * from LeftTable;

select * 
from LeftTable as l   -- only similaer ids will be shown on the output
inner join RightTable as r
on l.CountryID = r.ID;


select 
	l.CountryID,
	l.Units,
	l.dateed,
	r.Country,
	r.ID
from LeftTable as l
	inner join RightTable as r
	on l.CountryID = r.ID

select * 
from LeftTable as l
full join RightTable as r
on l.CountryID = r.ID;


select * 
	from LeftTable as l
	left join RightTable as r
	on l.CountryID = r.ID 
	where r.Country = null



select * 
from LeftTable as l
full outer join RightTable as r -- order of exicution of queries or joins
on l.CountryID = r.ID



select * 
from Customers  as c
left join Orders as o
on c.customer_id = o.order_id
where o.total_amount is null


select * 
from Customers  as c
cross join Orders as o


select first_name, city, status 
from Customers  as c
cross join Orders as o

-- self join
use Store

select 
	e.first_name + ' ' + e.last_name as employee_name,
	m.first_name + ' ' + m.last_name as manager_name
FROM [sales].[staffs] e
INNER JOIN [sales].[staffs] m
on e.staff_id = m.manager_id;


-- group by  grouping sets

select 
	state, 
	count(*) as state_count
from sales.customers
	group by state
	having count(*) > 1000;



select 
	b.brand_name as brand,
	c.category_name as category,
	p.model_year,
	ROUND(SUM (
            quantity * oi.list_price * (1 - discount)
        ),0) sales into sales.sales_summary
from sales.order_items oi
inner join production.products p
	on oi.product_id = p.product_id
inner join production.brands b
	on p.brand_id = b.brand_id
inner join production.categories c
	on p.category_id = c.category_id
group by 
	b.brand_name,
	c.category_name,
	p.model_year
order by
	b.brand_name,
	c.category_name,
	p.model_year;



	select 
		brand, sum(sales) as brand_sales
	from sales.sales_summary
	group by 
		brand, category;

select
	brand,
	category,
	sum(sales) as total_sales
from sales.sales_summary
	group by
		GROUPING SETS (
		(brand, category),
		(brand),
		(category),
		()
	)
	order by
			brand,
			category;



select 
	model_year as model,
	avg(sales) as total_sales
from sales.sales_summary s
	group by 
		GROUPING SETS (
		(model_year, sales),
		(model_year),
		(sales)
		)
	having 
		s.model_year = 2017
	order by
		model_year,
		sales
	
use Store

select 
		brand,
		category,
		sum(sales) as total_sales
from sales.sales_summary
group by 
 GROUPING sets (
	(brand,category),
	(brand),
	( category),
	()
 )




-- grouping set -- cube --roll up these are under grouping
--a,b = (),(a),(b),(a,b)

select 
		brand,
		category,
		sum(sales) as total_sales
from sales.sales_summary
group by 
 cube(brand,category)

-- Roll Ups --try simple query
select 
		brand,
		category,
		sum(sales) as total_sales
from sales.sales_summary
group by 
 rollup(brand,category)


 select brand,
		sum(sales) as total_sales
 from sales.sales_summary
 group by
 cube (brand)


 -- SUB QUERY
 select * from sales.customers where state = 'NY';

 select * from sales.orders
 where customer_id in (
	select customer_id 
	from sales.customers 
			where state = 'NY'
 );

select * from production.products 

 select product_name,list_price,category_id 
	from production.products p1 
		where list_price in (
				select max(p2.list_price) as max_price
					from production.products p2 
						where  p2.category_id = p1.category_id 
							group by p2.category_id
 )

 order by category_id, product_name;

 if not exists(
 select name from sys.databases where name = 'lol'
 )
 begin 
	create database testing
end


select product_name,category_id,list_price 
	from production.stocks s, production.products p
	where list_price in 
	(
	select max(list_price) from production.products p1 where p1.category_id = p.category_id
	group by p1.category_id
	)

	order by product_name,category_id


select   sum(list_price) from production.products as p1
where p1.product_id = p1.category_id