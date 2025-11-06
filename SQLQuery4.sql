select * from [store].[sales].[customers]; 


select first_name, last_name from [Store].[sales].[customers];


select * from [Store].[sales].[customers] where state = 'NY'

select * from [Store].[sales].[customers] where phone <> 'NY'; -- <> reprasent null

--operator (AND OR NOT BETWEEN)

select * from [Store].[sales].[customers] where customer_id > 100 and state = 'NY'
select * from [Store].[sales].[customers] where phone is not null;
select * from [Store].[sales].[customers] where phone <> 'NULL';
select * from [Store].[sales].[customers] where customer_id between 101 and 155;
select * from [Store].[sales].[customers] where last_name = 'Bates' or first_name = 'Marget';

--LIKE (wildcard)
select 
	* 
from 
	[Store].[sales].[customers] 
where	
	FIRST_NAME like 'Aa%';


select 
	* 
from 
	[Store].[sales].[customers] 
where	
	email like '%@yahoo.com';


select 
	* 
from 
	[Store].[sales].[customers] 
where	
	first_name like '[A_X]%';

select 
	* 
from 
	[Store].[sales].[customers] 
where	
	first_name like '[^A-X]%';


-- concatinate any thing 

select 
	concat (first_name, ' ' ,last_name)
	as full_name

from 
	sales.customers





--sorting 

select * from [Store].[sales].[customers] order by first_name;
select * from [Store].[sales].[customers] order by first_name,state;
select * from [Store].[sales].[customers] order by state, first_name;

select * from [Store].[sales].[customers] order by state asc, first_name desc ;

--limiting (TOP, OFFSET/FETCH)
select top(15) * from [Store].[sales].[customers]; -- we will get top 15 data from the table 

select * from [Store].[sales].[customers] order by first_name OFFSET 10 ROWS;


select * from [Store].[sales].[customers] order by first_name offset 0 rows fetch next 10 rows only;



