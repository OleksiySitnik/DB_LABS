-- 1. Створити базу даних з ім’ям, що відповідає вашому прізвищу англійською мовою.
CREATE DATABASE "Sitnik";


-- 2. Створити в новій базі таблицю Student з атрибутами StudentId, SecondName, FirstName, Sex.
-- Обрати для них оптимальний тип даних в вашій СУБД.
CREATE TABLE "Student" (
	"StudentId" INT NOT NULL,
	"SecondName" VARCHAR(100) NOT NULL,
	"FirstName" VARCHAR(100) NOT NULL,
	"Sex" CHAR(1) NOT NULL
);


-- 3. Модифікувати таблицю Student. Атрибут StudentId має стати первинним ключем.
ALTER TABLE "Student"
ADD PRIMARY KEY ("StudentId");


-- 4. Модифікувати таблицю Student. Атрибут StudentId повинен
-- заповнюватися автоматично починаючи з 1 і кроком в 1.
CREATE SEQUENCE StudentIdInc
START WITH 1
INCREMENT BY 1
OWNED BY "Student"."StudentId";

ALTER TABLE "Student"
ALTER COLUMN "StudentId" SET DEFAULT nextval('StudentIdInc');


-- 5. Модифікувати таблицю Student. Додати необов’язковий атрибут BirthDate за відповідним типом даних.
ALTER TABLE "Student"
ADD COLUMN "BirthDate" DATE;


-- 6. Модифікувати таблицю Student. Додати атрибут CurrentAge,
-- що генерується автоматично на базі існуючих в таблиці даних.
ALTER TABLE "Student"
ADD COLUMN "CurrentAge" SMALLINT;

CREATE OR REPLACE FUNCTION CALCULATE_AGE()
RETURNS TRIGGER AS $$
	BEGIN
		NEW."CurrentAge" := DATE_PART('year',AGE(NEW."BirthDate"));
		RETURN NEW;
	END;$$
LANGUAGE plpgsql;

CREATE TRIGGER CALCULATE_AGE
BEFORE INSERT OR UPDATE ON "Student"
FOR EACH ROW EXECUTE PROCEDURE CALCULATE_AGE();


-- 7. Реалізувати перевірку вставлення даних. Значення атрибуту Sex може бути тільки ‘m’ та ‘f’.
ALTER TABLE "Student"
ADD CHECK("Sex" = 'f' OR "Sex" = 'm');


-- 8. В таблицю Student додати себе та двох «сусідів» у списку групи. 
INSERT INTO "Student" ("SecondName", "FirstName", "Sex", "BirthDate")
VALUES ('Rumiantsev', 'Oleksii','m' ,'1999-10-25'),
       ('Sitnik', 'Oleksii','m' ,'2000-06-11'),
       ('Teliman', 'Vasyl', 'f', '2000-02-11');


-- 9. Створити  представлення vMaleStudent та vFemaleStudent, що надають відповідну інформацію. 
CREATE VIEW "vMaleStudent" AS (
	SELECT * FROM "Student"
	WHERE "Sex" = 'm'
);

CREATE VIEW "vFemaleStudent" AS (
	SELECT * FROM "Student"
	WHERE "Sex" = 'f'
);


-- 10. Змінити тип даних первинного ключа на TinyInt (або SmallInt) не втрачаючи дані.
-- Для зміни типу даний потрібно видалити створені представлення
DROP VIEW "vMaleStudent";
DROP VIEW "vFemaleStudent";

ALTER TABLE "Student"
ALTER COLUMN "StudentId" TYPE SMALLINT;

CREATE VIEW "vMaleStudent" AS (
	SELECT * FROM "Student"
	WHERE "Sex" = 'm'
);

CREATE VIEW "vFemaleStudent" AS (
	SELECT * FROM "Student"
	WHERE "Sex" = 'f'
);




