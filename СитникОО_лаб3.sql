--ЗАВДАННЯ №1

-- 1. Використовуючи SELECT двічі, виведіть на екран своє ім’я, 
-- прізвище та по-батькові одним результуючим набором.

SELECT 'Sitnik'
UNION
SELECT 'Oleksiy Oleksandrovich';

-- 2. Порівнявши власний порядковий номер в групі з набором із всіх номерів в групі, 
-- вивести на екран ;-) якщо він менший за усі з них, або :-D в протилежному випадку.

SELECT 
CASE 8 < ALL (SELECT generate_series(1, 31)) 
    WHEN 'true' THEN ':-D'
    ELSE ';-)'
END;

-- 3. Не використовуючи таблиці, вивести на екран прізвище та 
-- ім’я усіх дівчат своєї групи за вийнятком тих,
-- хто має спільне ім’я з студентками іншої.
WITH "IP_71"("FirstName", "LastName") 
AS (SELECT 'Anastasiya' AS "FirstName",'Kaspruk' AS "LastName"  
    UNION SELECT 'Olga', 'Orel'
    UNION SELECT 'Diana', 'Bolotenyuk'
),"IP_72"("Name")
  AS (SELECT 'Vladyslava' AS "Name"
    UNION SELECT 'Oleksandra'
    UNION SELECT 'Olesya'
    UNION SELECT 'Viktoria'
    UNION SELECT 'Kateryna'
)

SELECT * FROM "IP_71"
WHERE "FirstName" IN (SELECT "FirstName" FROM "IP_71"
		      EXCEPT 
		      SELECT "Name" FROM "IP_72");

-- 4. Вивести усі рядки з таблиці Numbers (Number INT). 
-- Замінити цифру від 0 до 9 на її назву літерами.
-- Якщо цифра більше, або менша за названі, залишити її без змін.

SELECT CASE
	WHEN "Number" = 0 THEN 'Zero'
	WHEN "Number" = 1 THEN 'One'
	WHEN "Number" = 2 THEN 'Two'
	WHEN "Number" = 3 THEN 'Three'
	WHEN "Number" = 4 THEN 'Four'
	WHEN "Number" = 5 THEN 'Fifth'
	WHEN "Number" = 6 THEN 'Six'
	WHEN "Number" = 7 THEN 'Seven'
	WHEN "Number" = 8 THEN 'Eight'
	WHEN "Number" = 9 THEN 'Nine'
	ELSE "Number"
END
FROM "Numbers";

--5. Навести приклад синтаксису декартового об’єднання для вашої СУБД.

SELECT * FROM region CROSS JOIN territories;

--ЗАВДАННЯ №2

-- 1. Вивисти усі замовлення та їх службу доставки. В залежності від ідентифікатора 
-- служби доставки, переіменувати її на таку,
--  що відповідає вашому імені, прізвищу, або по-батькові

SELECT o.*, CASE
		WHEN "ShipperID" = 1 THEN 'Sitnik'
		WHEN "ShipperID" = 2 THEN 'Oleksiy'
		WHEN "ShipperID" = 3 THEN 'Oleksandrovich'
		ELSE "CompanyName"
	    END	
FROM orders AS o 
LEFT JOIN shippers AS s
ON o."ShipVia" = s."ShipperID"; 

-- 2. Вивести в алфавітному порядку усі країни, що фігурують 
-- в адресах клієнтів, працівників, та місцях доставки замовлень.

SELECT "Country" FROM customers
UNION
SELECT "Country" FROM employees
UNION
SELECT "ShipCountry" FROM orders
ORDER BY "Country";

-- 3. Вивести прізвище та ім’я працівника, а також кількість замовлень,
-- що він обробив за перший квартал 1998 року.

SELECT "FirstName", "LastName", "OrdersCount" FROM employees AS e
JOIN (SELECT "EmployeeID", COUNT(*) AS "OrdersCount"
      FROM orders
      WHERE DATE_PART('year',"OrderDate") = 1998
      AND DATE_PART('quarter',"OrderDate") = 1
      GROUP BY "EmployeeID") AS oc
ON oc."EmployeeID" = e."EmployeeID"; 

-- 4. Використовуючи СTE знайти усі замовлення,
--  в які входять продукти, яких на складі більше 100 одиниць,
--  проте по яким немає максимальних знижок.

WITH "sort_orders"
AS (SELECT "OrderID"
    FROM products AS p
    JOIN order_details AS od 
    ON p."ProductID" = od."ProductID"
    WHERE "UnitsInStock" > 100
    AND "Discount" <> (SELECT MAX("Discount") FROM order_details)
)

SELECT * FROM orders JOIN sort_orders
ON orders."OrderID" = sort_orders."OrderID";

-- 5. Знайти назви усіх продуктів, що не продаються в південному регіоні.
SELECT "ProductName"
FROM products AS p
	JOIN order_details USING("ProductID")
	JOIN orders USING("OrderID")
	JOIN employeeterritories USING("EmployeeID")
	JOIN territories USING("TerritoryID")
	JOIN region USING("RegionID")
WHERE region."RegionDescription" != 'Southern';

