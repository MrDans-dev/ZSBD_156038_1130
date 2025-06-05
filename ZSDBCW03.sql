IF OBJECT_ID('v_wysokie_pensje') IS NOT NULL DROP VIEW v_wysokie_pensje;
GO
CREATE VIEW v_wysokie_pensje AS
SELECT * FROM Employees WHERE Salary > 6000;

IF OBJECT_ID('v_wysokie_pensje') IS NOT NULL DROP VIEW v_wysokie_pensje;
GO
CREATE VIEW v_wysokie_pensje AS
SELECT * FROM Employees WHERE Salary > 12000;

IF OBJECT_ID('v_wysokie_pensje') IS NOT NULL DROP VIEW v_wysokie_pensje;
GO

IF OBJECT_ID('v_finance') IS NOT NULL DROP VIEW v_finance;
GO
CREATE VIEW v_finance AS
SELECT e.Employee_ID, e.Last_Name, e.First_Name
FROM Employees e
JOIN Departments d ON e.Department_ID = d.Department_ID
WHERE d.Department_Name = 'Finance';

IF OBJECT_ID('v_pracownicy_sredni_zarobek') IS NOT NULL DROP VIEW v_pracownicy_sredni_zarobek;
GO
CREATE VIEW v_pracownicy_sredni_zarobek AS
SELECT Employee_ID, Last_Name, First_Name, Salary, Job_ID, Email, Hire_Date
FROM Employees
WHERE Salary BETWEEN 5000 AND 12000;

IF OBJECT_ID('v_statystyki_dzialow_4plus') IS NOT NULL DROP VIEW v_statystyki_dzialow_4plus;
GO
CREATE VIEW v_statystyki_dzialow_4plus AS
SELECT d.Department_ID, d.Department_Name,
       COUNT(e.Employee_ID) AS liczba_pracownikow,
       AVG(e.Salary) AS srednia_pensja,
       MAX(e.Salary) AS maks_pensja
FROM Departments d
JOIN Employees e ON d.Department_ID = e.Department_ID
GROUP BY d.Department_ID, d.Department_Name
HAVING COUNT(e.Employee_ID) >= 4;

IF OBJECT_ID('v_pracownicy_sredni_zarobek_check') IS NOT NULL DROP VIEW v_pracownicy_sredni_zarobek_check;
GO
CREATE VIEW v_pracownicy_sredni_zarobek_check AS
SELECT Employee_ID, Last_Name, First_Name, Salary, Job_ID, Email, Hire_Date
FROM Employees
WHERE Salary BETWEEN 5000 AND 12000
WITH CHECK OPTION;

IF OBJECT_ID('v_managerowie') IS NOT NULL DROP VIEW v_managerowie;
GO
CREATE VIEW v_managerowie
WITH SCHEMABINDING
AS
SELECT e.Manager_ID, m.First_Name, m.Last_Name, d.Department_Name
FROM dbo.Employees AS e
JOIN dbo.Employees AS m ON e.Manager_ID = m.Employee_ID
JOIN dbo.Departments AS d ON m.Department_ID = d.Department_ID;

IF OBJECT_ID('v_najlepiej_oplacani') IS NOT NULL DROP VIEW v_najlepiej_oplacani;
GO
CREATE VIEW v_najlepiej_oplacani AS
SELECT TOP 10 *
FROM Employees
ORDER BY Salary DESC;
