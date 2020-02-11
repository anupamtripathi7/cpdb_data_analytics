COPY (select id, incident_date from data_allegation) 
TO 'C:\Users\Omkar\Desktop\Northwestern\Fall19\496-Data_Science_Seminar\CP5\data\allegDateMap.csv' DELIMITER ',' CSV HEADER;