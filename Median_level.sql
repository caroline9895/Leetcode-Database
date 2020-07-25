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
