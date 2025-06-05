DECLARE @Max_Department_ID INT;
DECLARE @New_Department_Name NVARCHAR(50) = 'EDUCATION';

SELECT @Max_Department_ID = MAX(Department_ID) FROM Departments;

INSERT INTO Departments (Department_ID, Department_Name)
VALUES (@Max_Department_ID + 10, @New_Department_Name);

CREATE TABLE New_Table (
    Number_Value VARCHAR(10)
);

DECLARE @i INT = 1;

WHILE @i <= 10
BEGIN
    IF @i NOT IN (4, 6)
        INSERT INTO New_Table VALUES (CAST(@i AS VARCHAR(10)));
    SET @i += 1;
END;

DECLARE @Country_ID CHAR(2) = 'CA';
DECLARE @Country_Name NVARCHAR(40);
DECLARE @Region_ID INT;

SELECT @Country_Name = Country_Name, @Region_ID = Region_ID
FROM Countries
WHERE Country_ID = @Country_ID;

PRINT 'Country: ' + @Country_Name + ', Region ID: ' + CAST(@Region_ID AS VARCHAR);

UPDATE Jobs
SET Min_Salary = Min_Salary * 1.05
WHERE Job_Title LIKE '%Manager%';

-- Wy?wietlenie liczby zaktualizowanych rekordów:
PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' records updated.';

-- Cofni?cie zmian
ROLLBACK;

SELECT TOP 1 *
FROM Jobs
ORDER BY Max_Salary DESC;

DECLARE @Country_ID CHAR(2), @Country_Name NVARCHAR(40), @Employee_Count INT;

DECLARE Country_Cursor CURSOR FOR
SELECT C.Country_ID, C.Country_Name
FROM Countries C
WHERE C.Region_ID = 1;

OPEN Country_Cursor;
FETCH NEXT FROM Country_Cursor INTO @Country_ID, @Country_Name;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @Employee_Count = COUNT(*)
    FROM Employees
    WHERE Department_ID IN (
        SELECT Department_ID FROM Departments WHERE Location_ID IN (
            SELECT Location_ID FROM Locations WHERE Country_ID = @Country_ID
        )
    );

    PRINT @Country_Name + ': ' + CAST(@Employee_Count AS VARCHAR);

    FETCH NEXT FROM Country_Cursor INTO @Country_ID, @Country_Name;
END;

CLOSE Country_Cursor;
DEALLOCATE Country_Cursor;

DECLARE Salary_Cursor CURSOR FOR
SELECT Last_Name, Salary
FROM Employees
WHERE Department_ID = 50;

DECLARE @Last_Name NVARCHAR(50), @Salary DECIMAL(10,2);

OPEN Salary_Cursor;
FETCH NEXT FROM Salary_Cursor INTO @Last_Name, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Salary > 3100
        PRINT @Last_Name + ' – nie dawa? podwy?ki';
    ELSE
        PRINT @Last_Name + ' – da? podwy?k?';

    FETCH NEXT FROM Salary_Cursor INTO @Last_Name, @Salary;
END;

CLOSE Salary_Cursor;
DEALLOCATE Salary_Cursor;

DECLARE @Min_Salary INT = 1000, @Max_Salary INT = 5000, @Name_Part NVARCHAR(50) = 'a';

SELECT First_Name, Last_Name, Salary
FROM Employees
WHERE Salary BETWEEN @Min_Salary AND @Max_Salary
  AND First_Name LIKE '%' + @Name_Part + '%' COLLATE Latin1_General_CI_AI;

SET @Min_Salary = 5000;
SET @Max_Salary = 20000;
SET @Name_Part = 'u';

SELECT First_Name, Last_Name, Salary
FROM Employees
WHERE Salary BETWEEN 5000 AND 20000
  AND First_Name COLLATE Latin1_General_CI_AI LIKE '%u%';

CREATE TABLE Manager_Stats (
    Manager_ID INT,
    Subordinate_Count INT,
    Salary_Diff DECIMAL(10,2)
);

INSERT INTO Manager_Stats (Manager_ID, Subordinate_Count, Salary_Diff)
SELECT 
    Manager_ID,
    COUNT(*) AS Subordinate_Count,
    MAX(Salary) - MIN(Salary) AS Salary_Diff
FROM Employees
WHERE Manager_ID IS NOT NULL
GROUP BY Manager_ID;
