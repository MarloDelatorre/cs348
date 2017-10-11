-- Question 1
CREATE OR REPLACE PROCEDURE pro_AvgGrade AS
	min_bin NUMBER := 0;
	max_bin NUMBER := 90;
	CURSOR school_avg IS
		SELECT sc.SchoolName, AVG(st.grade) AS AverageGrade FROM
		School sc JOIN Student st ON sc.SchoolId = st.SchoolId
		GROUP BY sc.SchoolName
		ORDER BY sc.SchoolName;
	school_avg_tuple school_avg%ROWTYPE;
	school_name VARCHAR2(10);
	school_avg_num NUMBER;
BEGIN
	SELECT MIN(low), MAX(high) INTO min_bin, max_bin FROM (
		SELECT t1.*, FLOOR(AverageGrade / 10) * 10 AS low, FLOOR(AverageGrade / 10) * 10 AS high FROM (
			SELECT sc.SchoolName, AVG(st.grade) AS AverageGrade FROM
			School sc JOIN Student st ON sc.SchoolId = st.SchoolId
			GROUP BY sc.SchoolName
		) t1
	);
	dbms_output.put(RPAD('SCHOOLNAME', 12) || RPAD('AVGGRADE:', 11));
	FOR i IN min_bin .. max_bin LOOP
		IF MOD(i, 10) = 0 THEN
			dbms_output.put('>' || i || ', <=' || (i + 10) ||'  ');
		END IF;
	END LOOP;
	dbms_output.new_line();
	dbms_output.put(RPAD('----------', 23)); 
	FOR i IN min_bin .. max_bin loop
		IF MOD(i, 10) = 0 THEN
			dbms_output.put(RPAD('---------', 11));
		END IF;
	END LOOP;
	dbms_output.new_line();
	FOR school_avg_tuple IN school_avg LOOP
		school_name := school_avg_tuple.SchoolName;
		school_avg_num := school_avg_tuple.AverageGrade;
		dbms_output.put(RPAD(school_name, 23));
		
		FOR i IN min_bin .. max_bin LOOP
			IF mod(i, 10) = 0 THEN
				IF school_avg_num > i AND school_avg_num <= (i + 10) THEN
					dbms_output.put(RPAD(LPAD('X', 5),5));
				END IF;	
				dbms_output.put(RPAD(' ', 11, ' '));
			END IF;
		END LOOP;
		dbms_output.new_line();
	END LOOP;	
END;
/


-- Question 2
CREATE OR REPLACE PROCEDURE pro_DispInternSummary AS

	type freq_array IS VARRAY(100) OF NUMBER;
	frequency freq_array := freq_array();

	min_bin NUMBER := 0;
	max_bin NUMBER := 10;

	CURSOR student_intern IS
		SELECT s.StudentId, NVL(NumOfInternship, 0) AS NumOfInternship FROM (
			SELECT StudentId, COUNT(*) AS NumOfInternship 
			FROM Internship
			GROUP BY StudentId) t1 
		RIGHT JOIN Student s ON t1.StudentId = s.StudentId;
	student_intern_tuple student_intern%ROWTYPE;

	num_of_internship NUMBER;
	iindex NUMBER;
	hasMedian BOOLEAN := TRUE;
	med NUMBER;
	medianIdx NUMBER := 0;
	internSum NUMBER := 0;
	counter NUMBER := 0;
BEGIN

	FOR i IN 1 .. 99 LOOP
		frequency.extend;
		frequency(i) := 0;
	END LOOP;

	SELECT MIN(NumOfInternship), MAX(NumOfInternship) INTO min_bin, max_bin FROM (
	SELECT s.StudentId, NVL(NumOfInternship, 0) AS NumOfInternship FROM (
		SELECT StudentId, COUNT(*) AS NumOfInternship 
		FROM Internship
		GROUP BY StudentId) t1 
	RIGHT JOIN Student s ON t1.StudentId = s.StudentId
	);

	dbms_output.put_line('numberOfInternships | #student');

	FOR student_intern_tuple IN student_intern LOOP
		iindex := student_intern_tuple.NumOfInternship;
		frequency(iindex + 1) := frequency(iindex + 1) + 1;
		internSum := internSum + 1;
	END LOOP;

	med := internSum / 2;
	IF med <> Floor(med) THEN
		hasMedian := FALSE;
	END IF;

	IF hasMedian THEN
		FOR i IN min_bin .. max_bin LOOP
			IF counter > med THEN
				medianIdx := i - 1;
				EXIT;
			ELSIF counter = med THEN
				medianIdx := i;
				EXIT;	
			END IF;
			counter := counter + frequency(i + 1);
		END LOOP;
	END IF;

	FOR i IN min_bin .. max_bin LOOP
		dbms_output.put(RPAD(i, 20));
		dbms_output.put('| ' );
		dbms_output.put(frequency(i + 1));
		IF hasMedian AND i = medianIdx THEN
			dbms_output.put_line(' <--median');
		END IF;
		dbms_output.new_line();
	END LOOP;
END;
/

--Question 3
--Question 4
--Question 5
--Question 6
