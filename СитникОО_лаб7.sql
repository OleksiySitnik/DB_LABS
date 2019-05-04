-- 1. Створити збережену процедуру, що при виклику буде повертати ваше прізвище, ім’я та по-батькові.
CREATE FUNCTION full_name() 
RETURNS TEXT
AS $$
BEGIN
    RETURN 'Ситник Олексій Олександрович'; 
END$$
LANGUAGE plpgsql;

SELECT * FROM full_name();


-- 2. В котексті бази Northwind створити збережену процедуру,
-- що приймає текстовий параметр мінімальної довжини.
-- У разі виклику процедури з параметром ‘F’ на екран виводяться усі співробітники-жінки,
-- у разі використання параметру ‘M’ – чоловікі.
-- У протилежному випадку вивести на екран повідомлення про те, що параметр не розпізнано.
CREATE FUNCTION employees_by_sex(sex VARCHAR(1))
RETURNS SETOF employees
AS $$
BEGIN
    IF LOWER(sex) = 'm' THEN
	RETURN QUERY
	    SELECT * FROM employees
	    WHERE "TitleOfCourtesy" IN ('Dr.', 'Mr.');
    ELSIF LOWER(sex) = 'f' THEN
	RETURN QUERY
	    SELECT * FROM employees
	    WHERE "TitleOfCourtesy" IN ('Ms.', 'Mrs.');
    ELSE RAISE EXCEPTION 'Invalid argument';
    END IF;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM employees_by_sex('m');

-- 3. В котексті бази Northwind створити збережену процедуру,
-- що виводить усі замовлення за заданий період.
-- В тому разі, якщо період не задано – вивести замовлення за поточний день.
CREATE FUNCTION orders_by_period(start_date DATE DEFAULT NULL,
				 end_date DATE DEFAULT NULL)
RETURNS SETOF orders
AS $$
BEGIN
    IF start_date IS NOT NULL AND end_date IS NOT NULL THEN
	RETURN QUERY 
	    SELECT * FROM orders
	    WHERE "OrderDate" BETWEEN start_date AND end_date;
    ELSE RETURN QUERY
	     SELECT * FROM orders
	     WHERE "OrderDate" = CURRENT_DATE;
    END IF;
END; $$
LANGUAGE plpgsql;

SELECT * FROM orders_by_period('1996-05-01','1997-02-05');

-- 4. В котексті бази Northwind створити збережену процедуру,
-- що в залежності від переданого параметру категорії
-- виводить категорію та перелік усіх продуктів за цією категорією.
-- Дозволити можливість використати від однієї до п’яти категорій.
CREATE FUNCTION products_by_categories(category1 VARCHAR(1) DEFAULT NULL,
				       category2 VARCHAR(1) DEFAULT NULL,
				       category3 VARCHAR(1) DEFAULT NULL,
				       category4 VARCHAR(1) DEFAULT NULL,
				       category5 VARCHAR(1) DEFAULT NULL)
RETURNS TABLE ("CategoryName" VARCHAR,
	       "ProductName" VARCHAR)
AS $$
BEGIN
    RETURN QUERY
	SELECT c."CategoryName", p."ProductName" FROM products AS p
	JOIN categories AS c USING("CategoryID")
	WHERE c."CategoryName" IN (category1, category2, category3, category4, category5);
END $$
LANGUAGE plpgsql;

SELECT * FROM products_by_categories('Confections');

-- 5. В котексті бази Northwind модифікувати збережену процедуру Ten Most Expensive Products
-- для виводу всієї інформації з таблиці продуктів,
-- а також імен постачальників та назви категорій.
CREATE FUNCTION ten_most_expensive_products()
RETURNS TABLE ("TenMostExpensiveProducts" VARCHAR,
	       "UnitPrice" REAL)
AS $$
BEGIN
    RETURN QUERY
	SELECT "ProductName", "UnitPrice" FROM products
	ORDER BY "UnitPrice" DESC
	LIMIT 10;
END; $$
LANGUAGE plpgsql;

DROP FUNCTION ten_most_expensive_products();

CREATE OR REPLACE FUNCTION ten_most_expensive_products()
RETURNS TABLE ("ProductID" SMALLINT,
	       "ProductName" VARCHAR,
	       "SupplierID" SMALLINT,
	       "CategoryID" SMALLINT,
	       "QuantityPerUnit" VARCHAR,
	       "UnitPrice" REAL,
	       "UnitsInStock" SMALLINT,
	       "UnitsOnOrder" SMALLINT,
	       "ReorderLevel" SMALLINT,
	       "Discontinued" INT,
	       "SupplierCompanyName" VARCHAR,
	       "CategoryName" VARCHAR)
AS $$
BEGIN
    RETURN QUERY
	SELECT p.*, c."CategoryName", s."CompanyName" FROM products AS p
	JOIN suppliers AS s USING("SupplierID")
	JOIN categories AS c USING("CategoryID")
	ORDER BY "UnitPrice" DESC
	LIMIT 10;
END; $$
LANGUAGE plpgsql;


-- 6. В котексті бази Northwind створити функцію,
-- що приймає три параметри (TitleOfCourtesy, FirstName, LastName)
-- та виводить їх єдиним текстом. Приклад: ‘Dr.’, ‘Yevhen’, ‘Nedashkivskyi’ –> ‘Dr. Yevhen Nedashkivskyi’
CREATE FUNCTION join_full_name(title_of_courtesy VARCHAR,
			       first_name VARCHAR, 
			       last_name VARCHAR)
RETURNS VARCHAR
AS $$
BEGIN
    RETURN title_of_courtesy || ' ' || first_name || ' ' ||last_name;
END; $$
LANGUAGE plpgsql;

SELECT * FROM join_full_name('Dr.', 'Yevhen', 'Nedashkivskyi');

-- 7. В контексті бази Northwind створити функцію,
-- що приймає три параметри (UnitPrice, Quantity, Discount) та виводить кінцеву ціну.
CREATE FUNCTION price(unit_price REAL, 
		      quantity INT, 
		      discount REAL)
RETURNS REAL 
AS $$
BEGIN
    RETURN unit_price * quantity * (1 - discount);
END; $$
LANGUAGE plpgsql;

SELECT * FROM price(73.5, 24, 0.2);


-- 8. Створити t, o приймає параметр текстового типу і приводить його до Pascal Case.
-- Приклад: Мій маленький поні –> МійМаленькийПоні
CREATE FUNCTION convert_to_pascal_case(input_str VARCHAR)
RETURNS VARCHAR 
AS $$
BEGIN
    RETURN REPLACE(INITCAP(input_str), ' ', '');
END; $$
LANGUAGE plpgsql;

SELECT * FROM convert_to_pascal_case('Мій маленький поні');


-- 9. В котексті бази Northwind створити функцію,
-- що в залежності від вказаної країни,
-- повертає усі дані про співробітника у вигляді таблиці.
CREATE FUNCTION employee_by_country(country VARCHAR)
RETURNS SETOF employees
AS $$
BEGIN 
    RETURN QUERY
	SELECT * FROM empoyees
	WHERE "Country" = country;
END; $$
LANGUAGE plpgsql;


-- 10. В котексті бази Northwind створити функцію,
-- що в залежності від імені транспортної компанії
-- повертає список клієнтів, якою вони обслуговуються.
CREATE FUNCTION customers_by_shipper_name(company_name VARCHAR)
RETURNS TABLE ("ShipperCompanyName" VARCHAR,
	       "CustomerName" VARCHAR)
AS $$
BEGIN
    RETURN QUERY
	SELECT s."CompanyName" AS "ShipperCompanyName",
	       c."CompanyName" AS "CustomerName"
	FROM customers AS c
	JOIN orders AS o USING("CustomerID")
	JOIN shippers AS s
	    ON o."ShipVia" = s."ShipperID"
	WHERE s."CompanyName" = company_name;
END; $$
LANGUAGE plpgsql;

SELECT * FROM customers_by_shipper_name('Speedy Express');








