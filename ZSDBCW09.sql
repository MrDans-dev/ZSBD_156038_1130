CREATE SCHEMA CommonTools;
GO

CREATE FUNCTION CommonTools.GetEmployeeSalary (@Employee_ID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @Salary MONEY;
    SELECT @Salary = Salary FROM Employees WHERE Employee_ID = @Employee_ID;
    RETURN @Salary;
END;
GO

CREATE PROCEDURE CommonTools.RaiseSalary
    @Employee_ID INT,
    @IncreasePercent FLOAT
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary * (1 + @IncreasePercent / 100.0)
    WHERE Employee_ID = @Employee_ID;
END;

CREATE SCHEMA RegionTools;
GO

CREATE PROCEDURE RegionTools.CreateRegion
    @RegionName NVARCHAR(100)
AS
BEGIN
    INSERT INTO Regions (Region_Name)
    VALUES (@RegionName);
END;
GO

CREATE PROCEDURE RegionTools.ReadRegions
    @Filter NVARCHAR(100) = NULL
AS
BEGIN
    SELECT * FROM Regions
    WHERE @Filter IS NULL OR Region_Name LIKE '%' + @Filter + '%';
END;
GO

CREATE PROCEDURE RegionTools.UpdateRegion
    @RegionID INT,
    @NewName NVARCHAR(100)
AS
BEGIN
    UPDATE Regions
    SET Region_Name = @NewName
    WHERE Region_ID = @RegionID;
END;
GO

CREATE PROCEDURE RegionTools.DeleteRegion
    @RegionID INT
AS
BEGIN
    DELETE FROM Regions WHERE Region_ID = @RegionID;
END;

CREATE TABLE Region_Error_Log (
    Log_ID INT IDENTITY PRIMARY KEY,
    Error_Message NVARCHAR(4000),
    Procedure_Name NVARCHAR(100),
    Logged_At DATETIME DEFAULT GETDATE()
);

CREATE PROCEDURE RegionTools.CreateRegionSafe
    @RegionName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Regions WHERE Region_Name = @RegionName)
            THROW 50001, 'Region with this name already exists.', 1;

        INSERT INTO Regions (Region_Name) VALUES (@RegionName);
    END TRY
    BEGIN CATCH
        INSERT INTO Region_Error_Log (Error_Message, Procedure_Name)
        VALUES (ERROR_MESSAGE(), 'CreateRegionSafe');
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE RegionTools.DeleteRegionSafe
    @RegionID INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Countries WHERE Region_ID = @RegionID)
            THROW 50002, 'Cannot delete region with assigned countries.', 1;

        DELETE FROM Regions WHERE Region_ID = @RegionID;
    END TRY
    BEGIN CATCH
        INSERT INTO Region_Error_Log (Error_Message, Procedure_Name)
        VALUES (ERROR_MESSAGE(), 'DeleteRegionSafe');
        THROW;
    END CATCH
END;

CREATE SCHEMA DeptStats;
GO

CREATE FUNCTION DeptStats.AvgSalaryByDepartment (@DeptID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @Avg MONEY;
    SELECT @Avg = AVG(Salary) FROM Employees WHERE Department_ID = @DeptID;
    RETURN @Avg;
END;
GO

CREATE FUNCTION DeptStats.MinMaxSalaryByJob (@JobID NVARCHAR(10))
RETURNS TABLE
AS
RETURN (
    SELECT MIN(Salary) AS MinSalary, MAX(Salary) AS MaxSalary
    FROM Employees
    WHERE Job_ID = @JobID
);
GO

CREATE PROCEDURE DeptStats.GenerateReport
AS
BEGIN
    SELECT 
        d.Department_ID,
        d.Department_Name,
        COUNT(e.Employee_ID) AS EmployeeCount,
        AVG(e.Salary) AS AverageSalary
    FROM Departments d
    LEFT JOIN Employees e ON d.Department_ID = e.Department_ID
    GROUP BY d.Department_ID, d.Department_Name;
END;

CREATE SCHEMA DataTools;
GO

CREATE PROCEDURE DataTools.FormatPhoneNumbers
AS
BEGIN
    UPDATE Employees
    SET Phone_Number = 
        CASE 
            WHEN Phone_Number NOT LIKE '+%' THEN '+48 ' + Phone_Number
            ELSE Phone_Number
        END
    WHERE Phone_Number IS NOT NULL;
END;
GO

CREATE PROCEDURE DataTools.BulkRaiseSalary
    @JobID NVARCHAR(10),
    @PercentIncrease FLOAT
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary * (1 + @PercentIncrease / 100.0)
    WHERE Job_ID = @JobID;
END;
