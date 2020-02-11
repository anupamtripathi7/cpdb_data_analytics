select * from data_officerallegation 
select * from data_officer

/*Allegation table before 2015*/ 
DROP TABLE IF EXISTS offAllegB2015; 
CREATE TEMP TABLE offAllegB2015 AS 
(
SELECT * FROM data_officerallegation WHERE EXTRACT(YEAR FROM start_date) < 2015
); 

/*Allegation table after 2015*/ 
DROP TABLE IF EXISTS offAllegA2015; 
CREATE TEMP TABLE offAllegA2015 AS 
(
SELECT * FROM data_officerallegation WHERE EXTRACT(YEAR FROM start_date) >= 2015
); 

/*Good cops before 2015*/
 DROP TABLE IF EXISTS goodCopsB2015; 
 CREATE TEMP TABLE goodCopsB2015 AS 
 (
	 SELECT * FROM data_officer WHERE NOT EXISTS 
	 (
		 SELECT da.officer_id FROM offAllegB2015 as da WHERE da.officer_id = data_officer.id 
	 )
 ); 
 
 /*Good cops after 2015*/ 
 DROP TABLE IF EXISTS goodCopsA2015; 
 CREATE TEMP TABLE goodCopsA2015 AS 
 (
	 SELECT * FROM data_officer WHERE NOT EXISTS 
	 (
		 SELECT da.officer_id FROM offAllegA2015 as da WHERE da.officer_id = data_officer.id 
	 )
 ); 
 
 /*Bad Cops before 2015*/ 
 DROP TABLE IF EXISTS badCopsB2015; 
 CREATE TEMP TABLE badCopsB2015 AS 
 (
	 SELECT DISTINCT d_o.id, d_o.gender, d_o.race, d_o.appointed_date, d_o.rank, d_o.birth_year, d_o.complaint_percentile
	 from data_officer as d_o 
	 INNER JOIN offAllegB2015 ON offAllegB2015.officer_id = d_o.id
 ); 
 
 /*Bad cops after 2015*/ 
 DROP TABLE IF EXISTS badCopsA2015; 
 CREATE TEMP TABLE badCopsA2015 AS 
 (
	 SELECT DISTINCT d_o.id, d_o.gender, d_o.race, d_o.appointed_date, d_o.rank, d_o.birth_year, d_o.complaint_percentile
	 from data_officer as d_o 
	 INNER JOIN offAllegA2015 ON offAllegA2015.officer_id = d_o.id
 ); 
 
/*Table with officers and their total count of awards*/ 
DROP TABLE IF EXISTS offAwards; 
CREATE TEMP TABLE offAwards AS 
(
SELECT officer_id, count(*) FROM data_award
GROUP BY officer_id 
); 

/*Create CSV Files for all tables*/ 
COPY goodCopsB2015
TO 'C:\Users\Omkar\Desktop\Northwestern\Fall19\496-Data_Science_Seminar\CP5\data\goodCopsB2015.csv' DELIMITER ',' CSV HEADER;

COPY goodCopsA2015
TO 'C:\Users\Omkar\Desktop\Northwestern\Fall19\496-Data_Science_Seminar\CP5\data\goodCopsA2015.csv' DELIMITER ',' CSV HEADER;

COPY badCopsB2015
TO 'C:\Users\Omkar\Desktop\Northwestern\Fall19\496-Data_Science_Seminar\CP5\data\badCopsB2015.csv' DELIMITER ',' CSV HEADER;

COPY badCopsA2015
TO 'C:\Users\Omkar\Desktop\Northwestern\Fall19\496-Data_Science_Seminar\CP5\data\badCopsA2015.csv' DELIMITER ',' CSV HEADER;

COPY offAwards
TO 'C:\Users\Omkar\Desktop\Northwestern\Fall19\496-Data_Science_Seminar\CP5\data\offAwards.csv' DELIMITER ',' CSV HEADER;
