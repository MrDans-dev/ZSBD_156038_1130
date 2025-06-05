SELECT Employee_ID, First_Name, Last_Name, Salary,
       RANK() OVER (ORDER BY Salary DESC) AS ranking
FROM Employees;

SELECT Employee_ID, First_Name, Last_Name, Salary,
       SUM(Salary) OVER () AS suma_calkowita
FROM Employees;

SELECT e.Last_Name, p.Product_Name,
       SUM(s.Price * s.Quantity) OVER (PARTITION BY e.Employee_ID ORDER BY s.Sale_Date) AS skumulowana_sprzedaz,
       RANK() OVER (ORDER BY s.Price * s.Quantity DESC) AS ranking_zamowien
FROM Sales s
JOIN Employees e ON s.Employee_ID = e.Employee_ID
JOIN Products p ON s.Product_ID = p.Product_ID;

SELECT e.Last_Name, p.Product_Name, s.Price,
       COUNT(*) OVER (PARTITION BY s.Product_ID, s.Sale_Date) AS liczba_transakcji,
       SUM(s.Price * s.Quantity) OVER (PARTITION BY s.Product_ID, s.Sale_Date) AS suma_zaplaty,
       LAG(s.Price) OVER (PARTITION BY s.Product_ID ORDER BY s.Sale_Date) AS poprzednia_cena,
       LEAD(s.Price) OVER (PARTITION BY s.Product_ID ORDER BY s.Sale_Date) AS kolejna_cena
FROM Sales s
JOIN Employees e ON s.Employee_ID = e.Employee_ID
JOIN Products p ON s.Product_ID = p.Product_ID;

SELECT p.Product_Name, s.Price,
       SUM(s.Price * s.Quantity) OVER (PARTITION BY FORMAT(s.Sale_Date, 'yyyy-MM')) AS suma_miesiac,
       SUM(s.Price * s.Quantity) OVER (PARTITION BY p.Product_ID, FORMAT(s.Sale_Date, 'yyyy-MM') ORDER BY s.Sale_Date) AS suma_rosnaca
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID;

SELECT p.Product_Name, c.Category_Name,
       MAX(CASE WHEN YEAR(s.Sale_Date) = 2022 THEN s.Price END) AS cena_2022,
       MAX(CASE WHEN YEAR(s.Sale_Date) = 2023 THEN s.Price END) AS cena_2023,
       MAX(CASE WHEN YEAR(s.Sale_Date) = 2023 THEN s.Price END)
         - MAX(CASE WHEN YEAR(s.Sale_Date) = 2022 THEN s.Price END) AS roznica
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
JOIN Categories c ON p.Category_ID = c.Category_ID
GROUP BY p.Product_Name, c.Category_Name, FORMAT(s.Sale_Date, 'MM-dd');

SELECT c.Category_Name, p.Product_Name, s.Price,
       MIN(s.Price) OVER (PARTITION BY c.Category_Name) AS min_cena,
       MAX(s.Price) OVER (PARTITION BY c.Category_Name) AS max_cena,
       MAX(s.Price) OVER (PARTITION BY c.Category_Name)
       - MIN(s.Price) OVER (PARTITION BY c.Category_Name) AS roznica
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
JOIN Categories c ON p.Category_ID = c.Category_ID;

SELECT p.Product_Name, s.Sale_Date, s.Price,
       ROUND(AVG(s.Price) OVER (PARTITION BY p.Product_ID ORDER BY s.Sale_Date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 2) AS srednia_kroczaca
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID;

SELECT p.Product_Name, c.Category_Name, s.Price,
       RANK() OVER (PARTITION BY c.Category_Name ORDER BY s.Price DESC) AS ranking,
       ROW_NUMBER() OVER (PARTITION BY c.Category_Name ORDER BY s.Price DESC) AS numer_wiersza,
       DENSE_RANK() OVER (PARTITION BY c.Category_Name ORDER BY s.Price DESC) AS ranking_gesty
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
JOIN Categories c ON p.Category_ID = c.Category_ID;

SELECT e.Last_Name, p.Product_Name,
       SUM(s.Price * s.Quantity) OVER (PARTITION BY e.Employee_ID ORDER BY s.Sale_Date) AS wartosc_rosnaca,
       RANK() OVER (ORDER BY s.Price * s.Quantity DESC) AS globalny_ranking
FROM Sales s
JOIN Employees e ON s.Employee_ID = e.Employee_ID
JOIN Products p ON s.Product_ID = p.Product_ID;

SELECT DISTINCT e.First_Name, e.Last_Name, e.Job_ID
FROM Employees e
JOIN Sales s ON e.Employee_ID = s.Employee_ID;
