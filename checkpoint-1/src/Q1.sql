DROP TABLE IF EXISTS AllegDate; 
CREATE TEMP TABLE AllegDate AS (
SELECT da.id as allegID, EXTRACT(YEAR FROM da.incident_date) as inDate, doa.officer_id, d_o.rank FROM data_allegation as da
INNER JOIN data_officerallegation as doa ON doa.allegation_id = da.id 
INNER JOIN data_officer as d_o ON d_o.id = doa.officer_id 
); 

DROP TABLE IF EXISTS countOfRanks; 
CREATE TEMP TABLE countOfRanks AS
(
select count(d_o_2.id) as count_2, d_o_2.rank from data_officer as d_o_2
 group by d_o_2.rank
);

DROP TABLE IF EXISTS countOfAlleg; 
CREATE TEMP TABLE countOfAlleg AS 
(
select AllegDate.rank, count(*) as count_1 from AllegDate
group by AllegDate.rank
); 

DROP TABLE IF EXISTS countOfAlleg_B2015; 
CREATE TEMP TABLE countOfAlleg_B2015 AS 
(
select AllegDate.rank, count(*) as count_1 from AllegDate
WHERE AllegDate.inDate < 2015
group by AllegDate.rank
); 

DROP TABLE IF EXISTS countOfAlleg_A2015; 
CREATE TEMP TABLE countOfAlleg_A2015 AS 
(
select AllegDate.rank, count(*) as count_1 from AllegDate
WHERE AllegDate.inDate >= 2015
group by AllegDate.rank
); 

/* For everything */ 
SELECT countOfAlleg.count_1*(1.0/countOfRanks.count_2) as normalized_count, countOfAlleg.rank FROM countOfAlleg, countOfRanks
WHERE countOfAlleg.rank = countOfRanks.rank
ORDER BY normalized_count DESC; 

/*Before 2015*/ 
SELECT countOfAlleg_B2015.count_1*(1.0/countOfRanks.count_2) as normalized_count, countOfAlleg_B2015.rank FROM countOfAlleg_B2015, countOfRanks
WHERE countOfAlleg_B2015.rank = countOfRanks.rank
ORDER BY normalized_count DESC;

/*After 2015*/
SELECT countOfAlleg_A2015.count_1*(1.0/countOfRanks.count_2) as normalized_count, countOfAlleg_A2015.rank FROM countOfAlleg_A2015, countOfRanks
WHERE countOfAlleg_A2015.rank = countOfRanks.rank
ORDER BY normalized_count DESC;
