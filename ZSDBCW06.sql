CREATE PROCEDURE Add_Job
    @Job_ID NVARCHAR(10),
    @Job_Title NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Jobs (Job_ID, Job_Title)
        VALUES (@Job_ID, @Job_Title);
        PRINT 'Job added successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE Update_Job_Title
    @Job_ID NVARCHAR(10),
    @New_Title NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Jobs WHERE Job_ID = @Job_ID)
        BEGIN
            UPDATE Jobs
            SET Job_Title = @New_Title
            WHERE Job_ID = @Job_ID;
            PRINT 'Job updated.';
        END
        ELSE
            THROW 51000, 'No Jobs updated – Job_ID not found.', 1;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE Delete_Job
    @Job_ID NVARCHAR(10)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Jobs WHERE Job_ID = @Job_ID)
        BEGIN
            DELETE FROM Jobs WHERE Job_ID = @Job_ID;
            PRINT 'Job deleted.';
        END
        ELSE
            THROW 51001, 'No Jobs deleted – Job_ID not found.', 1;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE Get_Employee_Salary_And_Name
    @Employee_ID INT,
    @Salary MONEY OUTPUT,
    @Last_Name NVARCHAR(50) OUTPUT
AS
BEGIN
    SELECT @Salary = Salary, @Last_Name = Last_Name
    FROM Employees
    WHERE Employee_ID = @Employee_ID;
END;

CREATE PROCEDURE Add_Employee
    @First_Name NVARCHAR(50),
    @Last_Name NVARCHAR(50),
    @Salary MONEY = 1000,
    @Job_ID NVARCHAR(10) = NULL,
    @Manager_ID INT = NULL,
    @Department_ID INT = NULL
AS
BEGIN
    BEGIN TRY
        IF @Salary > 20000
            THROW 51002, 'Salary exceeds 20000.', 1;

        INSERT INTO Employees (First_Name, Last_Name, Salary, Job_ID, Manager_ID, Department_ID)
        VALUES (@First_Name, @Last_Name, @Salary, @Job_ID, @Manager_ID, @Department_ID);

        PRINT 'Employee added.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE Get_Manager_Avg_Salary
    @Manager_ID INT,
    @Avg_Salary MONEY OUTPUT
AS
BEGIN
    SELECT @Avg_Salary = AVG(Salary)
    FROM Employees
    WHERE Manager_ID = @Manager_ID;
END;

CREATE PROCEDURE Update_Department_Salaries
    @Department_ID INT,
    @Raise_Percent FLOAT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Departments WHERE Department_ID = @Department_ID)
            THROW 2291, 'Department does not exist.', 1;

        UPDATE E
        SET E.Salary = 
            CASE 
                WHEN (E.Salary * (1 + @Raise_Percent / 100)) BETWEEN J.Min_Salary AND J.Max_Salary
                    THEN E.Salary * (1 + @Raise_Percent / 100)
                ELSE E.Salary
            END
        FROM Employees E
        JOIN Jobs J ON E.Job_ID = J.Job_ID
        WHERE E.Department_ID = @Department_ID;

        PRINT 'Salaries updated.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE Move_Employee
    @Employee_ID INT,
    @New_Department_ID INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Departments WHERE Department_ID = @New_Department_ID)
            THROW 51003, 'New department does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM Employees WHERE Employee_ID = @Employee_ID)
            THROW 51004, 'Employee does not exist.', 1;

        UPDATE Employees
        SET Department_ID = @New_Department_ID
        WHERE Employee_ID = @Employee_ID;

        PRINT 'Employee moved.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

CREATE PROCEDURE Delete_Department
    @Department_ID INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Employees WHERE Department_ID = @Department_ID)
            THROW 51005, 'Cannot delete department with assigned employees.', 1;

        DELETE FROM Departments
        WHERE Department_ID = @Department_ID;

        PRINT 'Department deleted.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
