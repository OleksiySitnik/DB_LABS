--Задача №1

-- 1. Необхідно знайти кількість рядків в таблиці, що містить більше ніж 2147483647 записів. 
-- Напишіть код для MS SQL Server та ще однієї СУБД (на власний вибір).
SELECT COUNT_BIG(*) FROM table_name;-- MS SQL
SELECT COUNT(*) FROM table_name;-- PostgreSQL

-- 2. Підрахувати довжину свого прізвища за допомогою SQL.
SELECT LENGTH('Ситник');

-- 3. У рядку з своїм прізвищем, іменем, та по-батькові замінити пробіли на знак ‘_’ (нижнє підкреслення).
SELECT REPLACE('Ситник Олексій Олександрович', ' ', '_');

-- 4. Створити генератор імені електронної поштової скриньки, що шляхом конкатенації об’єднував би 
-- дві перші літери з колонки імені, та чотири перші літери з колонки прізвища користувача, 
-- що зберігаються в базі даних, а також домену з вашим прізвищем.
SELECT CONCAT(SUBSTRING("FirstName" from 1 for 2),SUBSTRING("LastName" from 1 for 4),'@oleksiy.com') AS email
FROM Employees;

-- 5. За допомогою SQL визначити, в який день тиждня ви народилися.
SELECT DATE_PART('DOW',TIMESTAMP '2000-06-11');

-- Задача №2:

-- 1. Вивести усі данні по продуктам, їх категоріям, та постачальникам, навіть якщо останні з певних причин відсутні.
SELECT * 
FROM Products AS p
JOIN Categories AS c ON p."CategoryID" = p."CategoryID"
LEFT JOIN  Suppliers AS s ON s."SupplierID" = p."SupplierID";

-- 2. Показати усі замовлення, що були зроблені в квітні 1988 року та не були відправлені.
SELECT *
FROM Orders
WHERE DATE_PART('year', "OrderDate") = 1998 
AND  DATE_PART('month', "OrderDate") = 4
AND "ShippedDate" IS NULL;

-- 3. Відібрати усіх працівників, що відповідають за північний регіон.
SElECT "LastName", "FirstName" 
FROM Employees AS e
JOIN Employeeterritories AS et ON e."EmployeeID" = et."EmployeeID"
JOIN Territories AS t ON et."TerritoryID" = t."TerritoryID"
JOIN Region AS r ON t."RegionID" = t."RegionID"
WHERE r."RegionDescription" = 'Northern';

-- 4. Вирахувати загальну вартість з урахуванням знижки усіх замовлень, що були здійснені на непарну дату. 
SELECT SUM(od."Quantity" * od."UnitPrice" * (1 - od."Discount"))
FROM order_details AS od
JOIN Orders AS o ON o."OrderID" = od."OrderID"
WHERE DATE_PART('day',"OrderDate")::int % 2 = 1;

-- 5. Знайти адресу відправлення замовлення з найбільшою ціною 
-- (враховуючи усі позиції замовлення, їх вартість, кількість, та наявність знижки).
SELECT "ShipAddress"
FROM Orders AS o
JOIN order_details AS od ON o."OrderID" = od."OrderID"
GROUP BY "ShipAddress"
ORDER BY SUM(od."Quantity" * od."UnitPrice" * (1 - od."Discount")) DESC
LIMIT 1;


