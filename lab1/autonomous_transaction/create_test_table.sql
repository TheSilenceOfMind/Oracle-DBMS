DROP TABLE emp;
CREATE TABLE emp(emp_no NUMBER PRIMARY KEY, salary NUMBER);
INSERT INTO emp VALUES (1001, 0);
INSERT INTO emp VALUES (1002, 0);
COMMIT;

SELECT * FROM emp;