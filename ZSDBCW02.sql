IF OBJECT_ID('v1_wynagrodzenie') IS NOT NULL DROP VIEW v1_wynagrodzenie;
GO
CREATE VIEW v1_wynagrodzenie AS
SELECT Last_Name + ' - ' + CAST(Salary AS VARCHAR) AS wynagrodzenie
FROM Employees
WHERE Department_ID IN (20, 50)
  AND Salary BETWEEN 2000 AND 7000
ORDER BY Last_Name;

IF OBJECT_ID('v2_zatrudnieni_2005') IS NOT NULL DROP VIEW v2_zatrudnieni_2005;
GO
CREATE VIEW v2_zatrudnieni_2005 AS
SELECT Hire_Date, Last_Name, Job_ID
FROM Employees
WHERE Manager_ID IS NOT NULL
  AND YEAR(Hire_Date) = 2005
ORDER BY Job_ID;

IF OBJECT_ID('v3_filtrowanie') IS NOT NULL DROP VIEW v3_filtrowanie;
GO
CREATE VIEW v3_filtrowanie AS
SELECT First_Name + ' ' + Last_Name AS imie_nazwisko,
       Salary,
       Phone_Number
FROM Employees
WHERE SUBSTRING(Last_Name, 3, 1) = 'e'
  AND LOWER(Dirst_Name) LIKE '%an%'
ORDER BY imie_nazwisko DESC, Salary ASC;

IF OBJECT_ID('v4_dodatek') IS NOT NULL DROP VIEW v4_dodatek;
GO
CREATE VIEW v4_dodatek AS
SELECT First_Name, Last_Name,
       DATEDIFF(MONTH, Hire_Date, GETDATE()) AS miesiace,
       CASE
         WHEN DATEDIFF(MONTH, Hire_Date, GETDATE()) < 150 THEN Salary * 0.1
         WHEN DATEDIFF(MONTH, Hire_Date, GETDATE()) BETWEEN 150 AND 200 THEN Salary * 0.2
         ELSE Salary * 0.3
       END AS wysokosc_dodatku
FROM Employees
ORDER BY miesiace;

IF OBJECT_ID('v5_dzialy_min_5000') IS NOT NULL DROP VIEW v5_dzialy_min_5000;
GO
CREATE VIEW v5_dzialy_min_5000 AS
SELECT Department_ID,
       SUM(Salary) AS suma_zarobkow,
       ROUND(AVG(Salary), 0) AS srednia_zarobkow
FROM Employees
GROUP BY Department_ID
HAVING MIN(Salary) > 5000;

IF OBJECT_ID('v6_pracownicy_toronto') IS NOT NULL DROP VIEW v6_pracownicy_toronto;
GO
CREATE VIEW v6_pracownicy_toronto AS
SELECT e.Last_Name, e.Department_ID, d.Department_Name, e.Job_ID
FROM Employees e
JOIN Departments d ON e.Department_ID = d.Department_ID
JOIN Locations l ON d.Location_ID = l.Location_ID
WHERE l.City = 'Toronto';

IF OBJECT_ID('v7_wspolpracownicy_jennifer') IS NOT NULL DROP VIEW v7_wspolpracownicy_jennifer;
GO
CREATE VIEW v7_wspolpracownicy_jennifer AS
SELECT e.First_Name + ' ' + e.Last_Name AS jennifer,
       c.First_Name + ' ' + c.Last_Name AS wspolpracownik
FROM Employees e
JOIN Employees c ON e.Department_ID = c.Department_ID AND e.Employee_ID <> c.Employee_ID
WHERE e.First_Name = 'Jennifer';

IF OBJECT_ID('v8_puste_dzialy') IS NOT NULL DROP VIEW v8_puste_dzialy;
GO
CREATE VIEW v8_puste_dzialy AS
SELECT Department_Name
FROM Departments d
WHERE NOT EXISTS (
  SELECT 1 FROM Employees e WHERE e.Department_ID = d.Department_ID
);

IF OBJECT_ID('v9_grade_pracownika') IS NOT NULL DROP VIEW v9_grade_pracownika;
GO
CREATE VIEW v9_grade_pracownika AS
SELECT e.First_Name, e.Last_Name, e.Job_ID, d.Department_Name, e.Salary,
       jg.Grade_Level
FROM Employees e
JOIN Departments d ON e.Department_ID = d.Department_ID
JOIN Job_Grades jg ON e.Salary BETWEEN jg.Min_Salary AND jg.Max_Salary;

IF OBJECT_ID('v10_wyzej_sredniej') IS NOT NULL DROP VIEW v10_wyzej_sredniej;
GO
CREATE VIEW v10_wyzej_sredniej AS
SELECT First_Name, Last_Name, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees)
ORDER BY Salary DESC;

IF OBJECT_ID('v11_wspolpracownicy_z_u') IS NOT NULL DROP VIEW v11_wspolpracownicy_z_u;
GO
CREATE VIEW v11_wspolpracownicy_z_u AS
SELECT DISTINCT e.Employee_ID, e.First_Name, e.Last_Name
FROM Employees e
WHERE e.Department_ID IN (
  SELECT Department_ID FROM Employees WHERE Last_Name LIKE '%u%'
);

IF OBJECT_ID('v12_dlugo_pracujacy') IS NOT NULL DROP VIEW v12_dlugo_pracujacy;
GO
CREATE VIEW v12_dlugo_pracujacy AS
SELECT Employee_ID, First_Name, Last_Name, Hire_Date
FROM Employees
WHERE DATEDIFF(MONTH, Hire_Date, GETDATE()) > (
  SELECT AVG(DATEDIFF(MONTH, Hire_Date, GETDATE())) FROM Employees
);

IF OBJECT_ID('v13_statystyki_dzialow') IS NOT NULL DROP VIEW v13_statystyki_dzialow;
GO
CREATE VIEW v13_statystyki_dzialow AS
SELECT d.Department_Name,
       COUNT(e.Employee_ID) AS liczba_pracownikow,
       ROUND(AVG(e.Salary), 0) AS srednie_wynagrodzenie
FROM Departments d
LEFT JOIN Employees e ON d.Department_ID = e.Department_ID
GROUP BY d.Department_Name
ORDER BY liczba_pracownikow DESC;

IF OBJECT_ID('v14_mniej_niz_it') IS NOT NULL DROP VIEW v14_mniej_niz_it;
GO
CREATE VIEW v14_mniej_niz_it AS
SELECT e.First_Name, e.Last_Name, e.Salary
FROM Employees e
WHERE e.Salary < (
  SELECT MIN(e2.Salary)
  FROM Employees e2
  JOIN Departments d ON e2.Department_ID = d.Department_ID
  WHERE d.Department_Name = 'IT'
);

IF OBJECT_ID('v15_dzialy_nad_srednia') IS NOT NULL DROP VIEW v15_dzialy_nad_srednia;
GO
CREATE VIEW v15_dzialy_nad_srednia AS
SELECT DISTINCT d.Department_Name
FROM Departments d
JOIN Employees e ON d.Department_ID = e.Department_ID
WHERE e.Salary > (SELECT AVG(Salary) FROM Employees);

IF OBJECT_ID('v16_top5_stanowisk') IS NOT NULL DROP VIEW v16_top5_stanowisk;
GO
CREATE VIEW v16_top5_stanowisk AS
SELECT TOP 5 Job_ID, ROUND(AVG(Salary), 0) AS srednia_zarobkow
FROM Employees
GROUP BY Job_ID
ORDER BY srednia_zarobkow DESC;

IF OBJECT_ID('v17_regiony_statystyki') IS NOT NULL DROP VIEW v17_regiony_statystyki;
GO
CREATE VIEW v17_regiony_statystyki AS
SELECT r.region_name,
       COUNT(DISTINCT c.Country_ID) AS liczba_krajow,
       COUNT(DISTINCT e.Employee_ID) AS liczba_pracownikow
FROM Regions r
JOIN countries c ON r.Region_ID = c.Region_ID
JOIN Locations l ON c.Country_ID = l.Country_ID
JOIN Departments d ON l.Location_ID = d.Location_ID
JOIN Employees e ON d.Department_ID = e.Department_ID
GROUP BY r.region_name;

IF OBJECT_ID('v18_wiecej_niz_szef') IS NOT NULL DROP VIEW v18_wiecej_niz_szef;
GO
CREATE VIEW v18_wiecej_niz_szef AS
SELECT e.First_Name, e.Last_Name, e.Salary,
       m.First_Name + ' ' + m.Last_Name AS manager,
       m.Salary AS Salary_manager
FROM Employees e
JOIN Employees m ON e.Manager_ID = m.Employee_ID
WHERE e.Salary > m.Salary;

IF OBJECT_ID('v19_zatrudnienia_miesiace') IS NOT NULL DROP VIEW v19_zatrudnienia_miesiace;
GO
CREATE VIEW v19_zatrudnienia_miesiace AS
SELECT FORMAT(Hire_Date, 'MM') AS miesiac,
       COUNT(*) AS liczba_pracownikow
FROM Employees
GROUP BY FORMAT(Hire_Date, 'MM')
ORDER BY miesiac;

IF OBJECT_ID('v20_top3_dzialy') IS NOT NULL DROP VIEW v20_top3_dzialy;
GO
CREATE VIEW v20_top3_dzialy AS
SELECT TOP 3 d.Department_Name, ROUND(AVG(e.Salary), 0) AS srednia
FROM Employees e
JOIN Departments d ON e.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY srednia DESC;