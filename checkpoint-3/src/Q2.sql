DROP TABLE IF EXISTS all_payments; 
CREATE TEMP TABLE all_payments AS 
(
select case_id, sum(payment) as total from cases_payment GROUP BY case_id  
); 

DROP TABLE IF EXISTS rankings; 
CREATE TEMP TABLE rankings AS 
(
SELECT rank as rank_name, COUNT(rank), DENSE_RANK() OVER (ORDER BY COUNT(rank)) as rank_order from data_officer group by rank 
);

DROP TABLE IF EXISTS officer_mappings; 
CREATE TEMP TABLE officer_mappings AS 
(
select cpdb_id, settlement_cop_id from settlement_officer_map
group by cpdb_id, settlement_cop_id
);

DROP TABLE IF EXISTS combined_table; 
CREATE TEMP TABLE combined_table AS 
(
select officer.last_name, officer.rank, rankings.rank_order, officer.id, cases.case_id, all_payments.total, 
EXTRACT(YEAR FROM cases_case.date_filed::date) from data_officer as officer 
INNER JOIN officer_mappings ON officer.id = officer_mappings.cpdb_id 
INNER JOIN cops_casecop as cases ON officer_mappings.settlement_cop_id = cases.cop_id 	
INNER JOIN all_payments ON all_payments.case_id = cases.case_id
INNER JOIN cases_case ON cases_case.id = cases.case_id 
INNER JOIN rankings ON rankings.rank_name = officer.rank 
);

DROP TABLE IF EXISTS settlementByRank; 
CREATE TEMP TABLE settlementByRank AS 
(
SELECT last_name, rank, combined_table.rank_order, combined_table.case_id, total, combined_table.date_part from combined_table INNER JOIN
(SELECT case_id, min(rank_order) as top_officer FROM combined_table GROUP BY case_id) groupedCases
ON combined_table.case_id = groupedCases.case_id AND combined_table.rank_order = groupedCases.top_officer
);

DROP TABLE IF EXISTS settlementByRank_B2015; 
CREATE TEMP TABLE settlementByRank_B2015 AS 
(
select * from settlementByRank where settlementByRank.date_part < 2015
);

DROP TABLE IF EXISTS settlementByRank_A2015; 
CREATE TEMP TABLE settlementByRank_A2015 AS 
(
select * from settlementByRank where settlementByRank.date_part >= 2015
);

/*Combined results (All years)*/ 
select rank, avg(total) as settlementAvg from settlementByRank GROUP BY rank ORDER BY settlementAvg;

/*Result of average by rank before 2015*/
select rank, avg(total) as settlementAvg from settlementByRank_B2015 GROUP BY rank ORDER BY settlementAvg;

/*Result of average by rank after 2015*/
select rank, avg(total) as settlementAvg from settlementByRank_A2015 GROUP BY rank ORDER BY settlementAvg;




