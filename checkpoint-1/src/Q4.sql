DROP TABLE IF EXISTS invegRace; 
CREATE TEMP TABLE invegRace AS 
(
    select d_i_a.allegation_id as allegation_id, d_o.race, EXTRACT(YEAR FROM da.incident_date) as inDate from data_officer as d_o
    INNER JOIN data_investigator as d_i ON d_i.officer_id = d_o.id
	INNER JOIN data_investigatorallegation as d_i_a ON d_i.id = d_i_a.investigator_id 
	INNER JOIN data_allegation as da ON da.id = allegation_id 
); 

DROP TABLE IF EXISTS offRace; 
CREATE TEMP TABLE offRace AS 
(
	  select d_o2.race as race, d_o_a2.allegation_id as allegation_id, d_o_a2.final_outcome as final_outcome from 
      data_officer as d_o2,
      data_officerallegation as d_o_a2
      where d_o2.id = d_o_a2.officer_id
); 

DROP TABLE IF EXISTS combinedResult; 
CREATE TEMP TABLE combinedResult AS (
	SELECT invegRace.race as inRace, offRace.race as ofRace, invegRace.allegation_id, invegRace.inDate, offRace.final_outcome
	FROM invegRace
	INNER JOIN offRace ON offRace.allegation_id = invegRace.allegation_id 
); 

/*Same Race*/ 
/*All*/ 
select count(*), final_outcome from combinedResult
WHERE inrace = ofrace 
GROUP BY final_outcome; 
/*Before 2015*/ 
select count(*), final_outcome from combinedResult
WHERE inrace = ofrace AND inDate < 2015
GROUP BY final_outcome; 

select count(*), final_outcome from combinedResult
WHERE inrace != ofrace AND inDate < 2015
GROUP BY final_outcome; 

select count(*), final_outcome from combinedResult
WHERE inrace = ofrace AND inDate >= 2015
GROUP BY final_outcome; 

select count(*), final_outcome from combinedResult
WHERE inrace != ofrace AND inDate >= 2015
GROUP BY final_outcome; 


select count(*), final_outcome from combinedResult
WHERE inrace = ofrace 
GROUP BY final_outcome; 


/*All different race*/
select count(*), final_outcome from combinedResult
WHERE inrace != ofrace 
GROUP BY final_outcome; 

