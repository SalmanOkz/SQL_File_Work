-- To get the maximum salary
use Shop

CREATE TABLE employees (
    employee_id INT PRIMARY KEY  ,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    position VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);

INSERT INTO employees (employee_id,first_name, last_name, department, position, salary, hire_date) VALUES
(1,'John', 'Doe', 'IT', 'Software Engineer', 85000, '2020-03-15'),
(2,'Jane', 'Smith', 'Finance', 'Accountant', 78000, '2019-06-10'),
(3,'Alice', 'Johnson', 'IT', 'Data Analyst', 72000, '2021-02-22'),
(4,'Bob', 'Brown', 'HR', 'HR Manager', 69000, '2018-11-05'),
(5,'Charlie', 'Davis', 'IT', 'DevOps Engineer', 95000, '2019-08-18'),
(6,'Emily', 'Clark', 'Marketing', 'Marketing Manager', 88000, '2020-10-01'),
(7,'Frank', 'Wright', 'Finance', 'Financial Analyst', 77000, '2022-01-14'),
(8,'Grace', 'Miller', 'Sales', 'Sales Executive', 82000, '2019-05-20'),
(9,'Henry', 'Wilson', 'Sales', 'Sales Manager', 91000, '2017-04-10'),
(10,'Ivy', 'Moore', 'IT', 'System Administrator', 86000, '2021-07-30'),
(11,'Jack', 'Taylor', 'IT', 'Senior Developer', 102000, '2016-09-25'),
(12,'Karen', 'Anderson', 'HR', 'Recruiter', 63000, '2020-11-12'),
(13,'Leo', 'Thomas', 'Finance', 'Finance Director', 120000, '2015-12-01'),
(14,'Mia', 'Martin', 'Marketing', 'Content Strategist', 73000, '2022-06-07'),
(15,'Noah', 'Lee', 'Sales', 'Sales Representative', 68000, '2021-04-16');


SELECT MAX(salary) AS Max_Salary FROM employees;


SELECT employee_id, first_name, last_name, department, salary
FROM employees
ORDER BY salary DESC;

SELECT employee_id,
       first_name,
       last_name,
       department,
       salary
FROM employees
ORDER BY salary DESC
LIMIT 10;


SELECT 
    Department,
    SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY ROLLUP(Department);


SELECT 
    employee_id,
    first_name,
    last_name,
    Department,
    Salary,
    FIRST_VALUE(Salary) OVER (
        PARTITION BY Department 
        ORDER BY Salary ASC
    ) AS First_Salary,
    LAST_VALUE(Salary) OVER (
        PARTITION BY Department 
        ORDER BY Salary ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS Last_Salary
FROM Employees
ORDER BY Department, Salary;


SELECT 
    employee_id,
    first_name,
    last_name,
    Department,
    Salary,
    LAG(Salary) OVER (ORDER BY Salary) AS Previous_Salary,
    LEAD(Salary) OVER (ORDER BY Salary) AS Next_Salary
FROM Employees
ORDER BY Salary;


