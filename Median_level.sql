-- 177. Nth Highest Salary

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      SELECT DISTINCT Salary
      FROM (SELECT Salary, 
                   DENSE_RANK() OVER( ORDER BY Salary DESC) SRANK
            FROM Employee) t1
      Where t1.SRANK=N
  );
END


-- 178. Rank Scores

SELECT score, 
       DENSE_RANK()
       OVER (ORDER BY score DESC) AS 'Rank'
FROM Scores


-- 185. Department Top Three Salaries

SELECT Department, Employee, Salary
FROM (
    SELECT Department.Name AS Department, 
       Employee.Name AS Employee, 
       Salary,
       DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS SRank
    FROM Employee JOIN Department ON (Employee.DepartmentId=Department.Id)
) t1
WHERE SRank<=3 


--1270. All People Report to the Given Manager

SELECT a.employee_id
FROM Employees a LEFT JOIN Employees b ON a.manager_id=b.employee_id
                 LEFT JOIN Employees c ON b.manager_id=c.employee_id
WHERE a.employee_id !=1 and c.manager_id=1


--626. Exchange Seats

select s1.id, 
      ifnull(s2.student,s1.student) as student 
from seat s1 left join seat s2 on (case when s1.id % 2 = 1 
                                        then s1.id+1 
                                        else s1.id-1 end) = s2.id 
order by s1.id;


--180. Consecutive Numbers

SELECT DISTINCT L1.Num As ConsecutiveNums
FROM Logs  L1 JOIN Logs L2 ON L1.Id=L2.Id+1
              Join Logs L3 ON L2.Id=L3.Id+1
WHERE L1.Num=L2.Num
AND L1.Num=L3.Num


--1132. Reported Posts II

WITH A AS(
    SELECT Actions.action_date, 
           COUNT(DISTINCT Removals.post_id) AS Re,
           COUNT(DISTINCT Actions.post_id) AS Sp
      FROM Actions LEFT JOIN Removals ON Actions.post_id=Removals.post_id
     WHERE Actions.extra='spam'
  GROUP BY ActionS.action_date
)
SELECT ROUND(AVG(Re/Sp)*100, 2) average_daily_percent
FROM A 


--1098. Unpopular Books

WITH b1 AS(
    SELECT book_id, SUM(quantity) as quantity
      FROM Orders 
     WHERE DATEDIFF("2019-06-23", dispatch_date)<=365
  GROUP BY book_id
) 
SELECT Books.book_id as book_id, Books.name as name
FROM Books LEFT JOIN b1 ON Books.book_id=b1.book_id
WHERE DATEDIFF("2019-06-23", available_from)>31
GROUP BY Books.book_id
Having SUM(ifnull(quantity,0))<10

                  
--1355. Activity Participants

WITH t AS (
    SELECT activity, COUNT(*) as Num
    FROM Friends
    GROUP BY activity
)
SELECT activity
FROM t
WHERE Num < (SELECT Max(Num) FROM t)
  AND Num > (SELECT Min(Num) FROM t)

                  
--1393. Capital Gain/Loss

---method 1
WITH T1 AS(
    SELECT stock_name, price, 
           ROW_NUMBER() over(ORDER BY stock_name, operation_day) AS id
    FROM  Stocks
    WHERE operation="Buy" 
), T2 AS(
    SELECT stock_name, price, 
           ROW_NUMBER() over(ORDER BY stock_name, operation_day) AS id
    FROM  Stocks
    WHERE operation="Sell" 
)
SELECT stock_name, SUM(gain) AS capital_gain_loss
FROM (SELECT T1.stock_name AS stock_name,
             (T2.price-T1.price) AS gain
        FROM T1 JOIN T2 ON T1.id=T2.id) t
GROUP BY stock_name

--- method 2
SELECT stock_name, SUM(CASE WHEN operation = "Buy" THEN price * (-1) ELSE price END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name


--1454. Active Users

---method 1
SELECT DISTINCT id, name 
 FROM (
    SELECT DISTINCT a.id, a.login_date 
      FROM logins a JOIN logins b ON (datediff(a.login_date, b.login_date) between 0 and 4) 
                                 AND a.id=b.id
GROUP BY 1, 2
 HAVING COUNT(DISTINCT b.login_date) >= 5
 ) tmp1 JOIN Accounts USING(id)
 ORDER BY id

---method 2
select distinct a.id, (select name 
                       from accounts 
                       where id= a.id) as name 
from (select distinct *, 
             dense_rank() over(partition by id order by login_date) as row_num
        from logins) a
    group by 1,2, (date_add(a.login_date, interval -row_num day))
having count(a.login_date)>=5

                        
--1398. Customers Who Bought Products A and B but Not C

## Method1
WITH T1 AS (
    SELECT DISTINCT a.customer_id as customer_id
    FROM Orders a, Orders b, Orders c
    WHERE ( a.customer_id=b.customer_id AND a.customer_id=c.customer_id )
      AND a.product_name='A'
      AND b.product_name='B'
      AND c.product_name='C'
), T2 AS(
    SELECT DISTINCT a.customer_id as customer_id
    FROM Orders a, Orders b
   WHERE  a.customer_id=b.customer_id
     AND a.product_name='A'
     AND b.product_name='B'
)
SELECT T2.customer_id AS customer_ID, customer_name
 FROM T2 JOIN Customers ON T2.customer_id=Customers.customer_id
 WHERE T2.customer_id NOT IN (SELECT customer_id FROM T1)

## Method2
SELECT DISTINCT O.customer_id, C.customer_name
FROM Orders O
LEFT JOIN customers C ON O.customer_id = C.customer_id
WHERE 
    C.customer_id IN (SELECT customer_id FROM orders WHERE product_name = 'A') AND
    C.customer_id IN (SELECT customer_id FROM orders WHERE product_name = 'B') AND
    C.customer_id NOT IN (SELECT customer_id FROM orders WHERE product_name = 'C')

## Method3
SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME
FROM
    (
        SELECT
            C.CUSTOMER_ID,
            CUSTOMER_NAME,
            SUM(CASE WHEN PRODUCT_NAME = 'A' THEN 1 ELSE 0 END) BOUGHT_A,
            SUM(CASE WHEN PRODUCT_NAME = 'B' THEN 1 ELSE 0 END) BOUGHT_B,
            SUM(CASE WHEN PRODUCT_NAME = 'C' THEN 1 ELSE 0 END) BOUGHT_C
        FROM
            ORDERS O
            JOIN CUSTOMERS C ON (O.CUSTOMER_ID = C.CUSTOMER_ID)
        GROUP BY
            C.CUSTOMER_ID,
            CUSTOMER_NAME
    ) X
WHERE
    BOUGHT_A > 0 AND
    BOUGHT_B > 0 AND
    BOUGHT_C = 0

--1445. Apples & Oranges

SELECT t1.sale_date as sale_date, SUM(t1.sold_num) AS diff
FROM (
    SELECT sale_date, fruit, CASE WHEN fruit='oranges' THEN sold_num *(-1)
                                                       ELSE sold_num END as sold_num
    FROM Sales
) t1
GROUP BY t1.sale_date

/*
SELECT sale_date, SUM(CASE WHEN fruit ='apples' THEN sold_num ELSE -sold_num END) as diff
FROM Sales
Group by sale_date
*/

                            
--1212. Team Scores in Football Tournament

WITH T1 AS (
SELECT match_id, host_team AS team,
       CASE WHEN host_goals > guest_goals THEN 3 
            WHEN host_goals = guest_goals THEN 1
            ELSE 0 END AS score
FROM Matches
UNION
SELECT match_id, guest_team AS team, 
       CASE WHEN host_goals < guest_goals THEN 3 
            WHEN host_goals = guest_goals THEN 1
            ELSE 0 END AS score
FROM Matches
)
SELECT team_id, team_name, IFNULL(SUM(score),0) AS num_points
FROM T1 RIGHT JOIN Teams ON T1.team=Teams.team_id
GROUP BY team_name
ORDER BY num_points DESC,team_id ASC


--1341. Movie Rating

(SELECT user_name AS results
FROM (
    SELECT Users.name AS user_name, COUNT(*) AS Rate_time
    FROM Movie_Rating t1 LEFT JOIN users ON t1.user_id=Users.user_id
    GROUP BY user_name
    ORDER BY Rate_time DESC,user_name ASC
) t2
LIMIT 1)
UNION
(SELECT movie_title AS result
FROM (
    SELECT Movies.title AS movie_title, ROUND(AVG(rating),2) AS Rating_score
    FROM Movie_Rating t3 JOIN Movies ON t3.movie_id=Movies.movie_id
    WHERE DATEDIFF(created_at, "2020-02-01") between 0 and 28
    GROUP BY movie_title
    ORDER BY Rating_score DESC, movie_title ASC
) t4
LIMIT 1)


--1112. Highest Grade For Each Student

SELECT student_id, course_id, grade
FROM (
    SELECT *, 
          ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC, course_id ASC) as rk
    FROM Enrollments
) T1
WHERE rk=1


--1045. Customers Who Bought All Products

SELECT customer_id
FROM Customer 
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (
    SELECT COUNT(DISTINCT product_key)
      FROM Product)


--574. Winning Candidate

SELECT Name
FROM (
    SELECT Name, COUNT(*)OVER(PARTITION BY Name) AS vote_ticket
    FROM Vote LEFT JOIN Candidate ON Vote.CandidateId=Candidate.id
    ORDER BY vote_ticket DESC
) t1
LIMIT 1


--602. Friend Requests II: Who Has the Most Friends

With t2 AS(
    SELECT id 
    FROM (
        SELECT ROW_NUMBER()OVER()AS id
        FROM request_accepted
    ) t1
    WHERE id<=(SELECT GREATEST(MAX(requester_id), MAX(accepter_id)) 
               FROM request_accepted)
),
t3 AS(
    SELECT DISTINCT requester_id AS id , COUNT(*)OVER(PARTITION BY requester_id) AS num
    FROM request_accepted
), 
t4 AS(
    SELECT DISTINCT accepter_id AS id, COUNT(*)OVER(PARTITION BY accepter_id) AS num
    FROM request_accepted
)
SELECT t2.id as id, SUM(IFNULL(t3.num,0) + IFNULL(t4.num,0)) as num
FROM t2 LEFT JOIN t3 ON t2.id=t3.id
        LEFT JOIN t4 ON t2.id=t4.id
GROUP BY id
ORDER BY num DESC
LIMIT 1

/*here we can use union all, then coding will be simpler*/
SELECT id, SUM(num) AS num
FROM(
    SELECT DISTINCT requester_id AS id , COUNT(*)OVER(PARTITION BY requester_id) AS num
    FROM request_accepted
    UNION ALL
    SELECT DISTINCT accepter_id AS id, COUNT(*)OVER(PARTITION BY accepter_id) AS num
    FROM request_accepted
) T1
GROUP BY id
ORDER BY num DESC
LIMIT 1


--534. Game Play Analysis III
--Method 1
SELECT a.player_id AS player_id, a.event_date AS event_date,
       (SELECT SUM(games_played)
       FROM Activity b
       WHERE b.player_id=a.player_id
       AND a.event_date>=b.event_date) as games_played_so_far
FROM Activity a

--Method2
select player_id,event_date,
	sum(games_played) over(partition by player_id order by event_date) as games_played_so_far 
from Activity
order by player_id,event_date;
