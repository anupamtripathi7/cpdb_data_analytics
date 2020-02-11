DROP TABLE IF EXISTS weaponOfficer;
CREATE TEMP TABLE weaponOfficer AS 
(
SELECT data_allegation.incident_date::date as incidentDate, data_allegation.id as AllegationID, trr_subjectweapon.weapon_type, trr_trr.id as TRRID 
FROM data_allegation 
INNER JOIN trr_trr ON trr_trr.trr_datetime::date = data_allegation.incident_date::date
INNER JOIN trr_subjectweapon ON trr_subjectweapon.trr_id = trr_trr.id 
);

DROP TABLE IF EXISTS payConcat; 
CREATE TEMP TABLE payConcat AS 
(
SELECT cases_case.incident_date as incidentDate, all_payments.total, cases_case.id as CaseID
FROM all_payments
INNER JOIN cases_case ON cases_case.id = all_payments.case_id 
);

DROP TABLE IF EXISTS payByIncident; 
CREATE TEMP TABLE payByIncident AS 
(
select AVG(total) as total_avg, payconcat.caseid, weapon_type, EXTRACT(YEAR FROM payConcat.incidentdate) as date_year from weaponOfficer
INNER JOIN case_map on weaponOfficer.AllegationID = case_map.allegation_id 
INNER JOIN payconcat ON payconcat.CaseID = case_map.case_id 
GROUP BY payconcat.caseid, weapon_type, payConcat.incidentdate
);


/*Average amount spent on firearm*/ 
select avg(total_avg) from payByIncident where weapon_type like 'FIREARM%';
/*Average amount spent on non-firearm weapons*/ 
select avg(total_avg) from payByIncident where weapon_type not like 'FIREARM%';
/*Average amount spent on firearm before 2015*/
select avg(total_avg) from payByIncident where weapon_type like 'FIREARM%' and date_year < 2015;
/*Average amount spent on non-firearm before 2015*/
select avg(total_avg) from payByIncident where weapon_type not like 'FIREARM%' and date_year < 2015;
/*Small number of entries in last two cases*/
select count(*) from payByIncident where weapon_type like 'FIREARM%' and date_year >= 2015;
select count(*) from payByIncident where weapon_type not like 'FIREARM%' and date_year >= 2015;
/*Average amount spent on firearm after 2015*/
select avg(total_avg) from payByIncident where weapon_type like 'FIREARM%' and date_year >= 2015;
/*Average amount spent on non-firearm after 2015*/
select avg(total_avg) from payByIncident where weapon_type not like 'FIREARM%' and date_year >= 2015;


