CREATE TABLE Departments_Archive (
    Department_ID INT,
    Department_Name NVARCHAR(100),
    Closed_At DATETIME,
    Last_Manager NVARCHAR(200)
);

CREATE TRIGGER trg_DepartmentDelete
ON Departments
AFTER DELETE
AS
BEGIN
    INSERT INTO Departments_Archive (Department_ID, Department_Name, Closed_At, Last_Manager)
    SELECT d.Department_ID, d.Department_Name, GETDATE(), e.First_Name + ' ' + e.Last_Name
    FROM DELETED d
    LEFT JOIN Employees e ON d.Manager_ID = e.Employee_ID;
END;

CREATE TABLE Salary_Attempts (
    Attempt_ID INT IDENTITY(1,1) PRIMARY KEY,
    Attempted_By NVARCHAR(100),
    Attempt_Time DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_CheckSalary_Insert
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM INSERTED WHERE Salary < 2000 OR Salary > 26000)
    BEGIN
        INSERT INTO Salary_Attempts (Attempted_By)
        VALUES (SYSTEM_USER);
        RAISERROR ('Salary must be between 2000 and 26000.', 16, 1);
        RETURN;
    END

    INSERT INTO Employees (Employee_ID, First_Name, Last_Name, Salary, Job_ID, Department_ID)
    SELECT Employee_ID, First_Name, Last_Name, Salary, Job_ID, Department_ID
    FROM INSERTED;
END;

CREATE TRIGGER trg_CheckSalary_Update
ON Employees
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM INSERTED WHERE Salary < 2000 OR Salary > 26000)
    BEGIN
        INSERT INTO Salary_Attempts (Attempted_By)
        VALUES (SYSTEM_USER);
        RAISERROR ('Salary must be between 2000 and 26000.', 16, 1);
        RETURN;
    END

    UPDATE e
    SET e.First_Name = i.First_Name,
        e.Last_Name = i.Last_Name,
        e.Salary = i.Salary,
        e.Job_ID = i.Job_ID,
        e.Department_ID = i.Department_ID
    FROM Employees e
    JOIN INSERTED i ON e.Employee_ID = i.Employee_ID;
END;

CREATE SEQUENCE seq_Employee_ID
    START WITH 1000
    INCREMENT BY 1;

CREATE TRIGGER trg_AutoIncrement_EmployeeID
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Employees (Employee_ID, First_Name, Last_Name, Salary, Job_ID, Department_ID)
    SELECT NEXT VALUE FOR seq_Employee_ID, First_Name, Last_Name, Salary, Job_ID, Department_ID
    FROM INSERTED;
END;

CREATE TRIGGER trg_Block_JobGrades
ON Job_Grades
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    RAISERROR ('Modifications to Job_Grades are not allowed.', 16, 1);
    ROLLBACK;
END;

CREATE TRIGGER trg_PreventSalaryChange
ON Jobs
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Min_Salary) OR UPDATE(Max_Salary)
    BEGIN
        UPDATE j
        SET j.Min_Salary = d.Min_Salary,
            j.Max_Salary = d.Max_Salary
        FROM Jobs j
        JOIN DELETED d ON j.Job_ID = d.Job_ID;

        RAISERROR ('Changing Min_Salary or Max_Salary is not allowed. Original values restored.', 16, 1);
    END
END;
