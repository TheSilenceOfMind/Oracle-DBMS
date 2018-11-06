-- The example demonstrates execution of autonomous transaction (AT):
--		The AT is commited while the main transaction is suspended.
--		Autonomous transactions can be used for logging in the database 
--		independent of the rollback/commit of the parent transaction.
DECLARE
	l_salary NUMBER;
	PROCEDURE autonomous_block
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		UPDATE emp
		SET salary = salary + 15000
		WHERE emp_no = 1002;
		COMMIT;
	END autonomous_block;
BEGIN
	SELECT salary INTO l_salary FROM emp WHERE emp_no = 1001;
	DBMS_OUTPUT.PUT_LINE('Before: Salary of 1001 is '||l_salary);
	SELECT salary INTO l_salary FROM emp WHERE emp_no = 1002;
	DBMS_OUTPUT.PUT_LINE('Before: Salary of 1002 is '||l_salary);
	
	UPDATE emp
	SET salary = salary + 5000
	WHERE emp_no = 1001;
	autonomous_block;
	
	ROLLBACK;
	SELECT salary INTO l_salary FROM emp WHERE emp_no = 1001;
	DBMS_OUTPUT.PUT_LINE('After: Salary of 1001 is '||l_salary);
	SELECT salary INTO l_salary FROM emp WHERE emp_no = 1002;
	DBMS_OUTPUT.PUT_LINE('After: Salary of 1002 is '||l_salary);
END;
/
