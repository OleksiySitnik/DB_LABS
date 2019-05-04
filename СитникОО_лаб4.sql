-- 1. Додати себе як співробітника компанії на позицію Intern.
INSERT INTO employees ("EmployeeID", 
		       "FirstName", 
		       "LastName", 
		       "Title")
VALUES ((SELECT MAX("EmployeeID") + 1 FROM employees),
	'Oleksiy',
        'Sitnik',
        'Intern');

-- 2. Змінити свою посаду на Director.
UPDATE employees 
SET "Title" = 'Director'
WHERE ("FirstName" = 'Oleksiy' AND "LastName" = 'Sitnik');

-- 3. Скопіювати таблицю Orders в таблицю OrdersArchive.
SELECT * 
INTO ordersarchive
FROM orders;

-- 4. Очистити таблицю OrdersArchive.
TRUNCATE TABLE ordersarchive;

-- 5. Не видаляючи таблицю OrdersArchive, наповнити її інформацією повторно.
INSERT INTO ordersarchive
SELECT * FROM orders;

-- 6. З таблиці OrdersArchive видалити усі замовлення, що були зроблені замовниками із Берліну.
DELETE FROM ordersarchive 
WHERE "CustomerID" IN
(
	SELECT "CustomerID"
	FROM customers
	WHERE "City" = 'Berlin'
);

-- 7. Внести в базу два продукти з власним іменем та іменем групи.
INSERT INTO products ("ProductID", "ProductName", "Discontinued")
VALUES 
       (((SELECT MAX("ProductID") FROM products) + 1), 'Oleksiy', 0),
       (((SELECT MAX("ProductID") FROM products) + 2), 'ip71', 0);

-- 8. Помітити продукти, що не фігурують в замовленнях, як такі, що більше не виробляються.
UPDATE products 
SET "Discontinued" = 1
WHERE "ProductID" NOT IN
(
	SELECT DISTINCT "ProductID"
	FROM order_details
);

-- 9. Видалити таблицю OrdersArchive.
DROP TABLE ordersarchive;

-- 10. Видатили базу Northwind.
DROP DATABASE northwind;
