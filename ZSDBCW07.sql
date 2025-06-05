CREATE FUNCTION Get_Job_Title (@Job_ID NVARCHAR(10))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Title NVARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM Jobs WHERE Job_ID = @Job_ID)
        THROW 60000, 'Job ID not found.', 1;

    SELECT @Title = Job_Title FROM Jobs WHERE Job_ID = @Job_ID;
    RETURN @Title;
END;

CREATE FUNCTION Get_Annual_Income (@Employee_ID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @Salary MONEY, @Commission_Pct FLOAT;

    SELECT @Salary = Salary, @Commission_Pct = ISNULL(Commission_Pct, 0)
    FROM Employees
    WHERE Employee_ID = @Employee_ID;

    RETURN @Salary * (12 + @Commission_Pct);
END;

CREATE FUNCTION Get_Area_Code (@Phone VARCHAR(20))
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN SUBSTRING(@Phone, CHARINDEX('(', @Phone) + 1, CHARINDEX(')', @Phone) - CHARINDEX('(', @Phone) - 1);
END;

CREATE FUNCTION Format_String (@Input NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Len INT = LEN(@Input);
    IF @Len = 0 RETURN '';
    IF @Len = 1 RETURN UPPER(@Input);
    RETURN UPPER(LEFT(@Input,1)) + LOWER(SUBSTRING(@Input, 2, @Len - 2)) + UPPER(RIGHT(@Input,1));
END;

CREATE FUNCTION Pesel_To_Birthdate (@Pesel CHAR(11))
RETURNS DATE
AS
BEGIN
    DECLARE @Year INT, @Month INT, @Day INT;
    SET @Year = CAST(SUBSTRING(@Pesel, 1, 2) AS INT);
    SET @Month = CAST(SUBSTRING(@Pesel, 3, 2) AS INT);
    SET @Day = CAST(SUBSTRING(@Pesel, 5, 2) AS INT);

    IF @Month BETWEEN 1 AND 12
        SET @Year = 1900 + @Year;
    ELSE IF @Month BETWEEN 21 AND 32
    BEGIN
        SET @Year = 2000 + @Year;
        SET @Month = @Month - 20;
    END

    RETURN CAST(CONCAT(@Year, '-', FORMAT(@Month, '00'), '-', FORMAT(@Day, '00')) AS DATE);
END;

CREATE FUNCTION Get_Employee_Dept_Count (@Country_Name NVARCHAR(50))
RETURNS TABLE
AS
RETURN
    SELECT 
        (SELECT COUNT(*) 
         FROM Employees E
         WHERE E.Department_ID IN (
             SELECT D.Department_ID
             FROM Departments D
             JOIN Locations L ON D.Location_ID = L.Location_ID
             JOIN Countries C ON L.Country_ID = C.Country_ID
             WHERE C.Country_Name = @Country_Name)) AS Employee_Count,

        (SELECT COUNT(*)
         FROM Departments D
         JOIN Locations L ON D.Location_ID = L.Location_ID
         JOIN Countries C ON L.Country_ID = C.Country_ID
         WHERE C.Country_Name = @Country_Name) AS Department_Count;

CREATE FUNCTION Generate_Access_ID (
    @First_Name NVARCHAR(50),
    @Last_Name NVARCHAR(50),
    @Phone VARCHAR(20)
)
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN UPPER(LEFT(@Last_Name, 3)) + RIGHT(@Phone, 4) + UPPER(LEFT(@First_Name, 1));
END;
