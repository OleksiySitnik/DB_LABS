-- 1. Вивести на екран імена усіх таблиць в базі даних та кількість рядків в них.
SELECT relname, n_live_tup
FROM pg_stat_user_tables;


-- 2. Видати дозвіл на читання бази даних Northwind усім користувачам вашої СУБД.
-- Код повинен працювати в незалежності від імен існуючих користувачів.
GRANT CONNECT 
ON DATABASE "northwind" 
TO PUBLIC;

GRANT USAGE 
ON SCHEMA PUBLIC
TO PUBLIC;

GRANT SELECT 
ON ALL TABLES IN SCHEMA PUBLIC
TO PUBLIC;

-- 3. За допомогою курсору заборонити користувачеві TestUser доступ
-- до всіх таблиць поточної бази даних, імена котрих починаються на префікс ‘prod_’.
CREATE ROLE "TestUser";
CREATE OR REPLACE FUNCTION revoke_access_prod() RETURNS void AS $$
DECLARE 
 query TEXT;
 curr_table RECORD;
 cursor_tbl CURSOR FOR SELECT table_name, table_schema 
			FROM information_schema.tables
			WHERE table_name LIKE 'prod\_%';
BEGIN
    OPEN cursor_tbl;

    LOOP
        FETCH cursor_tbl INTO curr_table;
        EXIT WHEN NOT FOUND;
	query := 'REVOKE ALL ON TABLE "'|| curr_table.table_name || '.' || curr_table.table_schema ||'" FROM "TestUser"';

        EXECUTE query;

    END LOOP;
    CLOSE cursor_tbl;
END;$$
LANGUAGE plpgsql;

DO $$
 BEGIN
  PERFORM revoke_access_prod();
 END;
$$;
 


-- 4. Створити тригер на таблиці Customers, що при вставці 
--нового телефонного номеру буде видаляти усі символи крім цифер.
CREATE OR REPLACE FUNCTION valid_phone() RETURNS trigger AS $$
BEGIN
	NEW."Phone" := regexp_replace(NEW."Phone", '\D', '', 'g');
	RETURN NEW;
END;$$
LANGUAGE plpgsql;

CREATE TRIGGER valid_phone
BEFORE UPDATE OR INSERT ON customers
FOR EACH ROW EXECUTE PROCEDURE valid_phone();


-- 5. Створити таблицю Contacts (ContactId, LastName, FirstName, PersonalPhone, WorkPhone, Email, PreferableNumber).
-- Створити тригер, що при вставці даних в таблицю Contacts вставить
-- в якості PreferableNumber WorkPhone якщо він присутній,
-- або PersonalPhone, якщо робочий номер телефона не вказано.
CREATE TABLE contacts("CotactID" SERIAL PRIMARY KEY,
	      "LastName" VARCHAR NOT NULL,
	      "FirstName" VARCHAR NOT NULL,
	      "PersonalPhone" VARCHAR,
	      "WorkPhone" VARCHAR,
	      "Email" VARCHAR,
	      "PreferableNumber" VARCHAR);

CREATE OR REPLACE FUNCTION set_preferablenumber() RETURNS trigger AS $$
BEGIN 
	IF NEW."WorkPhone" IS NOT NULL THEN
	    NEW."PreferableNumber" = NEW."WorkPhone";
	ELSE 
	    NEW."PreferableNumber" = NEW."PersonalPhone";
	END IF;
	RETURN NEW;
END;$$
LANGUAGE plpgsql;

CREATE TRIGGER set_preferablenumber
BEFORE INSERT OR UPDATE ON contacts
FOR EACH ROW EXECUTE PROCEDURE set_preferablenumber();


-- 6. Створити таблицю OrdersArchive що дублює таблицію Orders та має додаткові
-- атрибути DeletionDateTime та DeletedBy. Створити тригер, що при видаленні рядків з таблиці Orders
-- буде додавати їх в таблицю OrdersArchive та заповнювати відповідні колонки.
CREATE TABLE OrdersArchive("DeletionDateTime" TIMESTAMP,
			   "DeletedBy" VARCHAR,
			   LIKE orders INCLUDING ALL);

CREATE OR REPLACE FUNCTION insert_deleted_from_orders() RETURNS trigger AS $$
BEGIN
	INSERT INTO OrdersArchive VALUES(localtimestamp, current_user, OLD.*);
	RETURN OLD;
END;$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_deleted_from_orders
AFTER DELETE ON orders
FOR EACH ROW EXECUTE PROCEDURE insert_deleted_from_orders();


-- 7. Створити три таблиці: TriggerTable1, TriggerTable2 та TriggerTable3.
-- Кожна з таблиць має наступну структуру: TriggerId(int) – первинний ключ з автоінкрементом, TriggerDate(Date).
-- Створити три тригера. Перший тригер повинен при будь-якому записі в таблицю
-- TriggerTable1 додати дату запису в таблицю TriggerTable2.
-- Другий тригер повинен при будь-якому записі в таблицю TriggerTable2 додати дату запису в таблицю TriggerTable3.
-- Третій тригер працює аналогічно за таблицями TriggerTable3 та TriggerTable1.
-- Вставте один рядок в таблицю TriggerTable1.
-- Напишіть, що відбулось в коментарі до коду. Чому це сталося?
CREATE TABLE TriggerTable1("TriggerID" SERIAL PRIMARY KEY,
		     "TriggerDate" DATE);

CREATE TABLE TriggerTable2("TriggerID" SERIAL PRIMARY KEY,
		     "TriggerDate" DATE);

CREATE TABLE TriggerTable3("TriggerID" SERIAL PRIMARY KEY,
		     "TriggerDate" DATE);

CREATE OR REPLACE FUNCTION trigger_insert() RETURNS trigger AS $$
BEGIN
	EXECUTE 'INSERT INTO ' || TG_ARGV[0] || '("TriggerDate") VALUES(current_date);';
	RETURN NEW;
END;$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_insert
AFTER INSERT ON TriggerTable1
FOR EACH ROW EXECUTE PROCEDURE trigger_insert('"TriggerTable2"');

CREATE TRIGGER trigger_insert
AFTER INSERT ON TriggerTable2
FOR EACH ROW EXECUTE PROCEDURE trigger_insert('"TriggerTable3"');

CREATE TRIGGER trigger_insert
AFTER INSERT ON TriggerTable3
FOR EACH ROW EXECUTE PROCEDURE trigger_insert('"TriggerTable1"');

INSERT INTO TriggerTable1("TriggerDate")
	 VALUES(current_date);
-- ОШИБКА:  превышен предел глубины стека
-- Помилка виникла через рекурсивний виклик тригерів. Вони виконувались доки не переповнили стек викликів.