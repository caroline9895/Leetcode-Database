--262. Trips and Users

WITH T1 AS 
(
    SELECT  t.Request_at AS Day, 
            COUNT(*) AS Num,
            SUM( CASE WHEN t.Status != 'completed' THEN 1 ELSE 0 END ) AS Cancelled
    FROM Trips t LEFT JOIN Users u1 ON (t.Client_Id=u1.Users_Id) 
                 LEFT JOIN Users u2 ON (t.Driver_Id=u2.Users_Id)
    WHERE t.Request_at between '2013-10-01' and '2013-10-03'
      AND u1.Banned = 'No'
      AND u2.Banned = 'No'  
 GROUP BY t.Request_at 
)
SELECT Day,
       ROUND(Cancelled/Num, 2) AS 'Cancellation Rate'
FROM T1


--615. Average Salary: Departments VS Company

WITH com as
(
SELECT date_format(pay_date, '%Y-%m') AS pay_month,
       AVG(amount) AS company_avg
FROM salary
GROUP BY pay_month
), dep as
(
SELECT date_format(pay_date, '%Y-%m') AS pay_month,
       department_id,
       AVG(amount) AS depart_avg
FROM salary JOIN  employee ON (salary.employee_id=employee.employee_id )
GROUP BY department_id, pay_month
)
SELECT dep.pay_month AS pay_month,
       dep.department_id,
       (Case when dep.depart_avg > com.company_avg Then "higher"
             When dep.depart_avg < com.company_avg Then "lower"
             else "same"
        END) as comparison
FROM dep LEFT JOIN com ON (com.pay_month=dep.pay_month)
ORDER BY   dep.department_id ASC, dep.pay_month ASC


--1336. Number of Transactions per Visit

with t1 as (
select t.transaction_date, count(t.transaction_date) as transactions_count 
from Visits v left join Transactions t on v. user_id = t.user_id and v.visit_date = t.transaction_date
group by v.user_id, v.visit_date), 

row_num as (
select num from (
select 0 as num
    union 
select row_number() over() as num from Transactions
    ) a where num <= (select max(transactions_count) from t1)
)

select r.num transactions_count, 
        count(transactions_count) visits_count 
from row_num r left join t1 t on r.num=t.transactions_count 
group by r.num order by transactions_count;


--601. Human Traffic of Stadium

SELECT id,visit_date,people 
FROM(
    SELECT id, visit_date, people, 
           lead(people,1) over(order by visit_date) AS ld1, 
           lead(people,2) over(order by visit_date) ld2,
           lag(people,1) over(order by visit_date) AS lg1, 
           lag(people,2) over(order by visit_date) AS lg2
    FROM stadium) a
WHERE (people>=100 and ld1>=100 and ld2>=100) 
        OR (people>=100 and ld1>=100 and lg1>=100 ) 
        OR (people>=100 and lg1>=100 and lg2>=100)


--184. Department Highest Salary

SELECT Department, Employee, Salary
FROM (SELECT Department.Name as Department, 
             Employee.name as Employee, 
             Salary,
             RANK()OVER(PARTITION BY Employee.DepartmentId ORDER BY Salary DESC) as k
        FROM Employee JOIN Department ON (Employee.DepartmentId=Department.Id) a
 WHERE k=1

      
--1127. User Purchase Platform

WITH res AS (
    SELECT user_id, spend_date, 
           CASE WHEN COUNT(platform) > 1 THEN "both" ELSE platform END AS platform,
           SUM(amount) AS amount FROM Spending
    GROUP BY user_id,spend_date
), comb AS (
    SELECT DISTINCT(spend_date), 'desktop' AS platform FROM Spending
    UNION
    SELECT DISTINCT(spend_date), 'mobile' AS platform FROM Spending
    UNION
    SELECT DISTINCT(spend_date), 'both' AS platform FROM Spending
)
SELECT comb.spend_date, comb.platform, 
       IFNULL(SUM(amount),0) AS total_amount, 
       COUNT(user_id) AS total_users
FROM comb LEFT JOIN res ON comb.spend_date = res.spend_date AND comb.platform = res.platform
GROUP BY spend_date, platform;

      
--569. Median Employee Salary
## The solution is a little weird

WITH T1 AS(
    SELECT Id, Company, Salary,
           Rank() Over(PARTITION BY Company ORDER BY Salary ASC) AS RK,
           COUNT(1) OVER (PARTITION BY Company) AS CT 
    FROM Employee
), T2 AS(
SELECT *, CASE 
            WHEN CT/RK=2.00 THEN 1
            WHEN (CT+1)/RK=2.00 THEN 1
            WHEN (CT+2)/RK=2.00 THEN 1
            ELSE 0
            END AS 'median' FROM T1
)
SELECT Id, Company, Salary 
FROM T2
WHERE median=1
GROUP BY Company, Salary

      
--1384. Total Sales Amount by Year

WITH YS AS(
    select product_id, '2018' as report_year, 
           (greatest(datediff(least('2018-12-31',period_end), period_start)+1,0))*average_daily_sales as total_amount
    from Sales
    union
    select product_id, '2019' as report_year, 
           (greatest(datediff(least('2019-12-31',period_end), greatest('2019-01-01',period_start))+1,0))*average_daily_sales as total_amount
    from Sales
    union
    select product_id, '2020' as report_year, (greatest(datediff(period_end, greatest('2020-01-01',period_start))+1,0))*average_daily_sales as total_amount
    from Sales
)
select YS.product_id, P.product_name, report_year, total_amount 
from YS, Product P
where total_amount > 0
and YS.product_id = P.product_id
order by YS.product_id, report_year


--1412. Find the Quiet Students in All Exams

With t2 AS(
    SELECT DISTINCT student_id
    FROM (
        SELECT *,
            RANK() OVER(PARTITION BY exam_id ORDER BY score DESC) AS Mx,
            RANK() OVER(PARTITION BY exam_id ORDER BY score ASC) AS Mn
        FROM Exam
    ) t1
    WHERE t1.Mx = 1
    OR t1.Mn =1
)
SELECT DISTINCT Exam.student_id AS student_id, student_name
FROM Exam LEFT JOIN Student ON Exam.student_id = Student.student_id
          LEFT JOIN t2 ON Exam.student_id=t2.student_id
WHERE t2.student_id IS NULL


--1479. Sales by Day of the Week

WITH t1 AS(
    SELECT item_category as Category,
        DAYNAME(order_date) AS Weekday,
        IFNULL(SUM(quantity),0) AS quantity
    FROM Items a LEFT JOIN Orders b ON a.item_id=b.item_id
    GROUP BY Category, Weekday
)
SELECT Category,
       SUM(Case when Weekday='Monday' THEN quantity ELSE 0 END) AS Monday,
       SUM(Case when Weekday='Tuesday' THEN quantity ELSE 0 END) AS Tuesday, 
       SUM(Case when Weekday='Wednesday' THEN quantity ELSE 0 END) AS Wednesday, 
       SUM(Case when Weekday='Thursday' THEN quantity ELSE 0 END) AS Thursday, 
       SUM(Case when Weekday='Friday' THEN quantity ELSE 0 END) AS Friday, 
       SUM(Case when Weekday='Saturday' THEN quantity ELSE 0 END) AS Saturday,


--1225. Report Contiguous Dates

select 'failed' as period_state,
       min(fail_date) as start_date,
       max(fail_date) as end_date
from (
    select fail_date,
           dayofyear(fail_date) - row_number() over(order by fail_date) as group_rank
    from Failed
    where fail_date between '2019-01-01' and '2019-12-31'
) f
group by group_rank

union

select 'succeeded' as period_state,
       min(success_date) as start_date,
       max(success_date) as end_date
from (
    select success_date,
           dayofyear(success_date) - row_number() over(order by success_date) as group_rank
    from Succeeded
    where success_date between '2019-01-01' and '2019-12-31'
) s
group by group_rank

order by start_date  




