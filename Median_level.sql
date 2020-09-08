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
