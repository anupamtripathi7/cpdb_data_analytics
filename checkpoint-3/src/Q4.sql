DROP TABLE IF EXISTS settlementPeriod; 
CREATE TEMP TABLE settlementPeriod AS
(
select officer.last_name, officer.rank, rankings.rank_order, officer.id, cases.case_id, all_payments.total, 
DATE_PART('day', cases_case.date_closed - cases_case.date_filed), cases_case.date_filed from data_officer as officer 
INNER JOIN officer_mappings ON officer.id = officer_mappings.cpdb_id 
INNER JOIN cops_casecop as cases ON officer_mappings.settlement_cop_id = cases.cop_id 	
INNER JOIN all_payments ON all_payments.case_id = cases.case_id
INNER JOIN cases_case ON cases_case.id = cases.case_id 
INNER JOIN rankings ON rankings.rank_name = officer.rank 
); 

DROP TABLE IF EXISTS settlementByRankAndPeriod;
CREATE TEMP TABLE settlementByRankAndPeriod AS 
(
SELECT last_name, rank, settlementPeriod.rank_order, settlementPeriod.case_id, total, settlementPeriod.date_part, 
settlementPeriod.date_filed from settlementPeriod
INNER JOIN (SELECT case_id, min(rank_order) as top_officer FROM settlementPeriod GROUP BY case_id) groupedCases
ON settlementPeriod.case_id = groupedCases.case_id AND settlementPeriod.rank_order = groupedCases.top_officer
); 

/*Average settlement time involved by rank (overall)*/
select rank, avg(date_part) as settlementAvg from settlementByRankAndPeriod 
GROUP BY rank ORDER BY settlementAvg;

/*Average settlement time involved by rank (after 2015)*/
select rank, avg(date_part) as settlementAvg from settlementByRankAndPeriod 
where EXTRACT(YEAR FROM date_filed) >= 2015
GROUP BY rank ORDER BY settlementAvg;

/*Average settlement time involved by rank (before 2015)*/
select rank, avg(date_part) as settlementAvg from settlementByRankAndPeriod 
where EXTRACT(YEAR FROM date_filed) < 2015
GROUP BY rank ORDER BY settlementAvg;