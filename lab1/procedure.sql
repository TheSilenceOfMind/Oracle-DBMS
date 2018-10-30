-- RDBMS, lab 1, var 700 
-- Authors: Tatiana Kliushina, Balad Kirill, P3411

CREATE OR REPLACE PROCEDURE proc
	(passedTableName IN VARCHAR2)
IS
	tableName VARCHAR2(256);
	newColumnName VARCHAR2(100);
	columnsCount NUMBER := 0;
	columnsAdded NUMBER := 0;
	isExists BOOLEAN := FALSE;
	isPK BOOLEAN := FALSE;  
	columnAlreadyExists BOOLEAN := FALSE;
	
	EMPTY_TABLE_NAME EXCEPTION;
	NO_SUCH_TABLE EXCEPTION;
	
	CURSOR table_PK_cur IS 
		SELECT cols.column_name column_name
		FROM user_constraints cons, user_cons_columns cols
		WHERE cols.table_name = tableName
		AND cons.constraint_type = 'P'           
		AND cons.constraint_name = cols.constraint_name
		AND cons.owner = cols.owner;
	table_PK_t  table_PK_cur%ROWTYPE;
	TYPE table_PK_ntt IS TABLE OF table_PK_t%TYPE; -- must use type
	l_table_PK  table_PK_ntt;
BEGIN
	DBMS_OUTPUT.enable();
    
	--tableName := '"' || passedTableName || '"';
    tableName := passedTableName;
	
    
	IF tableName IS NULL THEN
		RAISE EMPTY_TABLE_NAME;
	END IF;
	
	FOR c in (SELECT TABLE_NAME FROM ALL_TABLES WHERE TABLE_NAME=tableName) LOOP
		isExists := TRUE;
		EXIT;
	END LOOP;
	
	IF NOT isExists THEN
		RAISE NO_SUCH_TABLE;
	END IF;
	
	-- записать все колонки-первичные-ключи в l_table_PK
	OPEN  table_PK_cur;
	FETCH table_PK_cur BULK COLLECT INTO l_table_PK;
	CLOSE table_PK_cur;
	
	-- пробегаемся по всем колонкам данной таблицы
	FOR col IN (SELECT column_name, data_type, data_scale FROM all_tab_columns WHERE table_name = tableName) LOOP
		-- целочисленный тип данных у данной колонки?		
		IF col.data_type = 'NUMBER' and (col.data_scale <= 0 OR col.data_scale IS NULL) THEN
			-- DBMS_OUTPUT.PUT_LINE(col.column_name); -- just to debug
			-- Первичный ключ? Пропускаем!
			isPK := FALSE;
			FOR indx IN 1..l_table_PK.COUNT LOOP 
				IF col.column_name = l_table_PK(indx).column_name THEN
                    			-- DBMS_OUTPUT.PUT_LINE('is PK'); -- just to debug
					isPK := TRUE;
					EXIT;
				END IF;
			END LOOP;
			-- Если составной ПК - создаём все колонки, считаем, что ПК нет.
			IF l_table_PK.count > 1 THEN
				isPK := FALSE;
			END IF;
			
			IF isPK THEN
                columnsCount := columnsCount + 1;
			END IF;
			CONTINUE WHEN isPK;
            			
			-- добавляем колонку к таблице с новым именем.
			newColumnName := col.column_name || '_DATE';
			columnAlreadyExists := FALSE;
			-- проверяем наличие колонки с именем '..._DATE'
			FOR column IN (SELECT column_name FROM all_tab_columns WHERE table_name = tableName) LOOP
				IF column.column_name = newColumnName THEN
					columnAlreadyExists := TRUE;
					EXIT;
				END IF;
			END LOOP;
            
			-- если колонка с именем '..._DATE' уже существует, то обновляем счетчик и переходим на след. итерацию цикла
			IF columnAlreadyExists THEN
				columnsCount := columnsCount + 1;
			END IF;
			CONTINUE WHEN columnAlreadyExists;
            
			BEGIN
				EXECUTE IMMEDIATE 'ALTER TABLE "' || tableName || '" ADD "' || newColumnName || '" DATE';    
				-- конвертация в дату в виде секунд с начала юникс эпохи, запись в новую колонку
				EXECUTE IMMEDIATE 'UPDATE "' || tableName || '" SET "' || newColumnName || '" = TO_DATE(''19700101'',''YYYYMMDD'') + ( 1/ 24/ 60/ 60) * ' || col.column_name;
			EXCEPTION 
			WHEN OTHERS THEN raise_application_error(-20001,'Невозможно добавить значения в новый столбец в таблицу ' || tableName);
			END;
			columnsCount := columnsCount + 1;
			columnsAdded := columnsAdded + 1;
     			
		END IF;
	END LOOP;
	
	-- просто вывод
	DBMS_OUTPUT.PUT_LINE('Таблица: ' || tableName);
	DBMS_OUTPUT.PUT_LINE('Целочисленных столбцов: ' || columnsCount);
	DBMS_OUTPUT.PUT_LINE('Столбцов добавлено: ' || columnsAdded);
	
EXCEPTION
WHEN EMPTY_TABLE_NAME THEN
	raise_application_error(-20001,'Пустой ввод.');
WHEN NO_SUCH_TABLE THEN
	raise_application_error(-20001,'Не существует таблицы со следующим именем: ' 
	|| tableName);
END;
/
