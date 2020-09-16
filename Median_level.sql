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
