-- 175. Combine Two Tables

SELECT FirstName, LastName, City, State
FROM Person LEFT JOIN Address ON Person.PersonId = Address.PersonId


-- 176. Second Highest Salary

SELECT Max(Salary)  as SecondHighestSalary
From Employee
Where salary <( select Max(salary) from Employee)


-- 181. Employees Earning More Than Their Managers

Select a.Name as Employee
From Employee a Left JOIN Employee b ON (a.ManagerId=b.ID)
WHERE a.Salary > b.Salary


-- 182. Duplicate Emails

Select Distinct Email
From Person
Group By Email
Having Count(Email)>1


-- 183. Customers Who Never Order

SELECT Name as Customers
FROM Customers 
Left JOIN Orders On Customers.Id=Orders.CustomerId 
WHERE CustomerId is null


-- 1179. Reformat Department Table

SELECT id,
    [Jan] as Jan_Revenue,
    [Feb] as Feb_Revenue,
    [Mar] as Mar_Revenue,
    [Apr] as Apr_Revenue,
    [May] as May_Revenue,
    [Jun] as Jun_Revenue,
    [Jul] as Jul_Revenue,
    [Aug] as Aug_Revenue,
    [Sep] as Sep_Revenue,
    [Oct] as Oct_Revenue,
    [Nov] as Nov_Revenue,
    [Dec] as Dec_Revenue
From (Select id, revenue, month 
        From Department) as DT
PIVOT(
Sum(revenue)
FOR month 
    IN ([Jan],
       [Feb],
        [Mar],
        [Apr],
        [May],
        [Jun],
        [Jul],
        [Aug],
        [Sep],
        [Oct],
        [Nov],
        [Dec]
)) as Pvt
ORDER BY Pvt.id


-- 196. Delete Duplicate Emails

DELETE FROM Person 
WHERE Id NOT IN (SELECT Id 
                   FROM (SELECT MIN(Id) as Id
                           FROM Person
                       GROUP BY Email) as p)


-- 1241. Number of Comments per Post

SELECT DISTINCT x.sub_id as post_id, 
       Count(Distinct y.sub_id) as number_of_comments
FROM Submissions x LEFT JOIN Submissions y ON x.sub_id=y.parent_id
Where x.parent_id is NULL
GROUP BY x.sub_id


-- 197. Rising Temperature

select b.id from Weather a, Weather b
where b.Recorddate = dateadd(day,1,a.recorddate)
and a.temperature < b.temperature


-- 1173. Immediate Food Delivery I

SELECT ROUND(
       sum( case When order_date=customer_pref_delivery_date Then 1 ELSE 0 END)*100.00 / MAX(delivery_id),2) as immediate_percentage
FROM Delivery


-- 1142. User Activity for the Past 30 Days II

SELECT Round(ifnull (Count(m. session_id) /COUNT( distinct m.user_id),0),2)  as average_sessions_per_user
From( 
    SELECT DISTINCT user_id, session_id
    FROM Activity
    WHERE datediff('2019-07-27', activity_date)<30
) m


-- 603. Consecutive Available Seats

select distinct c1.seat_id
from cinema c1, cinema c2
where c1.free = 1 and c2.free = 1 
    and ((c1.seat_id = c2.seat_id + 1) 
         or (c1.seat_id = c2.seat_id - 1))


-- 1350. Students With Invalid Departments

SELECT Students.id, Students.name
FROM Students LEFT JOIN Departments ON Students.department_id=Departments.id
WHERE Departments.name is null


--597. Friend Requests I: Overall Acceptance Rate

SELECT ROUND( ifnull( (t2.b / t1.a), 0), 2) AS accept_rate
FROM (SELECT COUNT(DISTINCT CONCAT(sender_id, '-', send_to_id)) as a FROM friend_request) as t1
     JOIN
     (SELECT COUNT(DISTINCT CONCAT(requester_id, '-', accepter_id)) as b FROM request_accepted) as t2
     ON 1=1


-- 610. Triangle Judgement

SELECT x, y, z, 
      (case when x+y>z and x+z>y and y+z>x 
            then 'Yes' 
            else 'No' end)  as triangle
FROM triangle


-- 1327. List the Products Ordered in a Period

SELECT x.product_name as PRODUCT_NAME,
       sum(y.unit) as UNIT
FROM Products x RIGHT JOIN Orders y ON x.product_id=y.product_id 
WHERE datediff(y.order_date, '2020-02-01')>=0
      And datediff(y.order_date, '2020-02-01') <=28
Group by x.product_name
having sum(y.unit)>=100


-- 1083. Sales Analysis II

SELECT DISTINCT buyer_id
FROM Sales LEFT JOIN Product ON Sales.product_id=Product.product_id
WHERE buyer_id IN (SELECT DISTINCT buyer_id 
                   FROM Sales LEFT JOIN Product ON Sales.product_id=Product.product_id
                   WHERE product_name='S8')
AND buyer_id NOT IN (SELECT DISTINCT buyer_id 
                   FROM Sales LEFT JOIN Product ON Sales.product_id=Product.product_id
                   WHERE product_name='iPhone')


-- 1068. Product Sales Analysis I

SELECT product_name, year, price
FROM Sales LEFT JOIN Product ON Sales.product_id=Product.Product_id


-- 1050. Actors and Directors Who Cooperated At Least Three Times

SELECT actor_id, director_id
FROM ActorDirector
Group by actor_id, director_id
Having COUNT(timestamp)>=3


-- 584. Find Customer Referee

SELECT name
FROM customer
WHERE IFNULL(referee_id,0)<>2


-- 1075. Project Employees I

SELECT a.project_id as project_id, 
       ROUND( SUM( b.experience_years)/ COUNT(*),2) as average_years
FROM Project a LEFT JOIN Employee b ON a.employee_id =b.employee_id
GROUP BY a.project_id


-- 1251. Average Selling Price

SELECT u.product_id as product_id,
        ROUND( SUM( p.price * u.units)/(sum(u.units)),2)  as average_price
FROM Prices p 
      RIGHT JOIN 
     UnitsSold u 
      ON (p.product_id=u.product_id AND u.purchase_date between p.start_date and p.end_date)
GROUP BY u.product_id


-- 512. Game Play Analysis II

SELECT player_id, device_id
FROM Activity x
Where event_date <= all(SELECT event_date
                        FROM Activity y
                        WHERE x.player_id = y.player_id)


-- 586. Customer Placing the Largest Number of Orders

SELECT T1.customer_number AS customer_number
FROM(
    SELECT  customer_number, COUNT(*) as orders
    FROM orders
    GROUP BY customer_number
) T1
ORDER BY T1.orders DESC 
limit 1

-- 1378. Replace Employee ID With The Unique Identifier

SELECT IFNULL(unique_id, NULL) AS unique_id, name
FROM Employees LEFT JOIN EmployeeUNI ON employees.id= EmployeeUNI.id


-- 1303. Find the Team Size

SELECT employee_id, z.team_size as team_size
FROM employee x 
   LEFT JOIN 
    (SELECT team_id, COUNT(*) as team_size
                            FROM employee y
                            GROUP BY team_id ) z 
      ON
     x.team_id = z. team_id


-- 596. Classes More Than 5 Students

SELECT class
FROM (SELECT DISTINCT student, class FROM courses) T1
GROUP BY class
HAVING COUNT(*)>=5


-- 627. Swap Salary

UPDATE salary
SET
    sex = CASE sex
        WHEN 'm' THEN 'f'
        ELSE 'm'
    END;


-- 620. Not Boring Movies

SELECT *
FROM cinema
WHERE id%2=1 
      AND description NOT LIKE 'boring'
ORDER BY rating DESC


-- 595. Big Countries

SELECT name, population, area
FROM World
WHERE area > 3000000
      OR population > 25000000


-- 1495. Friendly Movies Streamed Last Month

SELECT DISTINCT title
FROM TVProgram LEFT JOIN Content ON TVProgram.content_id=Content.content_id
WHERE kids_content="Y"
      AND content_type='movies'
      AND program_date BETWEEN '2020-06-01' AND '2020-06-30'


-- 1484. Group Sold Products By The Date

SELECT sell_date,
       COUNT( distinct product) AS num_sold,
       GROUP_CONCAT( DISTINcT product ORDER BY product ASC SEPARATOR ',') AS products 
FROM activities
GROUP BY sell_date;


-- 1435. Create a Session Bar Chart

# Write your MySQL query statement below
select bin, ifnull(total, 0) as total 
from (
    select '[0-5>' as bin
    union
    select '[5-10>' as bin
    union
    select '[10-15>' as bin
    union
    select '15 or more' as bin) as ref
left join
    (select bin, count(bin) as total 
     from (
    select case when duration/60 between 0 and 5 then '[0-5>'
            when duration/60 between 5 and 10  then '[5-10>'
            when duration/60 between 10 and 15 then '[10-15>'
            when duration/60 >= 15 then '15 or more' end as bin from Sessions) as t
    group by bin) as counts
using (bin);


-- 1407. Top Travellers

SELECT DISTINCT name, ifnull(SUM(distance),0) as travelled_distance
FROM Users LEFT JOIN Rides ON Users.id= Rides.user_id
GROUP BY name
ORDER BY travelled_distance DESC, name ASC


-- 1322. Ads Performance

SELECT ad_id,
       ROUND(CASE WHEN clicked=0 AND viewed=0 THEN 0 ELSE clicked*100/(clicked+viewed) END, 2) AS ctr
FROM(
     SELECT ad_id,
             SUM(CASE WHEN action = 'Clicked' THEN 1 ELSE 0 END) AS clicked,
             SUM(CASE WHEN action = 'Viewed' THEN 1 ELSE 0 END) AS viewed 
     FROM Ads
     GROUP BY ad_id
) T1
ORDER BY ctr DESC, ad_id ASC


-- 1294. Weather Type in Each Country

SELECT  country_name,
        (CASE  WHEN AVG( weather_state) <=15 THEN 'Cold'
             WHEN AVG( weather_state)  >=25 THEN 'Hot'
             ELSE 'Warm' 
        END) AS weather_type
FROM Countries RIGHT JOIN Weather ON Countries.country_id = Weather.country_id
WHERE Weather.day BETWEEN '2019-11-01' AND '2019-11-30'
GROUP BY country_name


-- 1280. Students and Examinations

SELECT Students.student_id AS student_id,
       Students.student_name AS student_name,
       Subjects.subject_name AS subject_name,
       ifnull(E.attended_exams,0) AS attended_exams
FROM 
    Students 
    CROSS JOIN 
    Subjects
    LEFT JOIN  (SELECT student_id, subject_name, COUNT(*) AS attended_exams
                 FROM Examinations
                 GROUP BY student_id, subject_name) E
    ON (Students.student_id=E.student_id AND Subjects.subject_name=E.subject_name)
ORDER BY Students.student_id ASC, Subjects.subject_name ASC


-- 1211. Queries Quality and Percentage

SELECT query_name, 
       ROUND( AVG(rating/position),2) AS quality,
       ROUND( SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END)*100/ COUNT(*),2) AS poor_query_percentage
FROM Queries
GROUP BY query_name


-- 1148. Article Views I

SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id=viewer_id
ORDER BY author_id


-- 1141. User Activity for the Past 30 Days I

SELECT activity_date AS day,
       COUNT(DISTINCT user_id) AS  active_users
FROM Activity
WHERE DATEDIFF('2019-07-27', activity_date) between 0 and 29
GROUP BY activity_date


-- 1082. Sales Analysis I

SELECT seller_id
FROM sales
GROUP BY seller_id
HAVING SUM(price)=(SELECT SUM(price)
                     FROM sales
                 GROUP BY seller_id
                 ORDER BY SUM( price) DESC
                    LIMIT 1)


-- 1084. Sales Analysis III

SELECT distinct Sales.product_id as product_id, product_name
FROM Sales LEFT JOIN Product ON Sales.product_id=Product.product_id
WHERE sale_date between '2019-01-01' and '2019-03-31'
AND Sales.product_id not in (SELECT DISTINCT product_id
                               FROM Sales
                              WHERE sale_date>'2019-03-31' OR sale_date <'2019-01-01')


-- 511. Game Play Analysis I

SELECT player_id, MIN( event_date) AS first_login
FROM Activity
GROUP BY player_id


-- 1113. Reported Posts

SELECT extra AS report_reason, COUNT(distinct post_id) AS report_count
FROM Actions
WHERE DATEDIFF('2019-07-05',action_date)=1
AND action='report'
AND extra IS NOT NULL


-- 1076. Project Employees II

SELECT project_id
FROM Project
GROUP BY project_id
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM Project
                       GROUP BY project_id)


-- 1069. Product Sales Analysis II

SELECT product_id, SUM(quantity) AS total_quantity
FROM Sales
GROUP BY product_id


-- 619. Biggest Single Number

SELECT (
    SELECT num
    FROM my_numbers
    GROUP BY num
    HAVING count(num) = 1
    ORDER BY num DESC
    LIMIT 1
) as num;


-- 613. Shortest Distance in a Line

SELECT MIN(ABS(p1.x-p2.x)) AS shortest
FROM point p1 CROSS JOIN point p2
WHERE p1.x <> p2.x


-- 607. Sales Person

SELECT s.name as name
FROM salesperson s
WHERE s.name NOT IN (
                    SELECT DISTINCT s.name
                    FROM orders o LEFT JOIN company c using(com_id)
                    LEFT JOIN salesperson s using(sales_id)
                    WHERE c.name='RED'
                     )


-- 577. Employee Bonus

SELECT Employee.name AS name,
       Bonus.bonus AS bonus
FROM Employee LEFT JOIN Bonus using( empId )
WHERE IFNULL(Bonus.bonus,0) < 1000
