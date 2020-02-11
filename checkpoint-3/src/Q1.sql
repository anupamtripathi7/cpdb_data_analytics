DROP TABLE IF EXISTS Arrests; 
CREATE TEMP TABLE Arrests AS 
(
SELECT CONCAT(data_officerarrest.officer_id, EXTRACT(MONTH FROM data_officerarrest.arrest_date)) as concatID, data_officerarrest.arrest_date FROM data_officerarrest 
WHERE data_officerarrest.arrest_date is not null and data_officerarrest.officer_id is not null
);

DROP TABLE IF EXISTS categoryByDate; 
CREATE TEMP TABLE categoryByDate AS 
(
SELECT data_allegation.id, data_allegation.incident_date, CONCAT(data_officerallegation.officer_id, EXTRACT(MONTH FROM data_allegation.incident_date::date)) as concatID, 
data_allegationcategory.category FROM data_allegation 
INNER JOIN data_officerallegation ON data_officerallegation.allegation_id = data_allegation.id 
INNER JOIN data_allegationcategory ON data_allegationcategory.id = data_officerallegation.allegation_category_id 
);

/*For all years*/
SELECT category, COUNT(*) FROM Arrests
INNER JOIN categoryByDate ON Arrests.concatID = categoryByDate.concatID
GROUP BY category ORDER BY COUNT(*);

/*Before 2015*/
SELECT category, COUNT(*) FROM Arrests
INNER JOIN categoryByDate ON Arrests.concatID = categoryByDate.concatID
WHERE EXTRACT(YEAR FROM arrest_date) < 2015
GROUP BY category ORDER BY COUNT(*);

/*Allegation category and number of arrests associated with that category*/
SELECT category, COUNT(*) FROM Arrests
INNER JOIN categoryByDate ON Arrests.concatID = categoryByDate.concatID
WHERE EXTRACT(YEAR FROM arrest_date) >= 2015
GROUP BY category ORDER BY COUNT(*);


