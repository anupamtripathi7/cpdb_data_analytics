DROP TABLE IF EXISTS t1; 
CREATE TEMP TABLE t1 AS
(
	select id, 'Taser' as w_type from trr_weapondischarge
	where weapon_type like '%TASER%' or weapon_type_description like '%TASER%' or firearm_make like '%TASER%'
	union 
	select id, 'Gun' as w_type from trr_weapondischarge
	where weapon_type = 'RIFLE' or weapon_type = 'SEMI-AUTO PISTOL' or weapon_type = 'SHOTGUN' or weapon_type = 'REVOLVER'
	union
	select id, 'Chemical Weapon' as w_type from trr_weapondischarge
	where weapon_type = 'CHEMICAL WEAPON'
	union 
	select id, 'Hand' as w_type from trr_weapondischarge where weapon_type_description like '%HANDS%' OR weapon_type_description LIKE '%BATON%'
); 

DROP TABLE IF EXISTS weaponWithDate; 
CREATE TEMP TABLE weaponWithDate AS 
(
SELECT t1.id as trr_id, t1.w_type, EXTRACT(YEAR FROM t2.trr_datetime) as inDate FROM t1 
INNER JOIN trr_trr as t2 ON t1.id = t2.id 
); 

/*After 2015*/
SELECT w_type, count(*) from weaponWithDate 
WHERE indate >= 2015 
GROUP BY w_type;

/*Before 2015*/
SELECT w_type, count(*) from weaponWithDate 
WHERE indate < 2015 
GROUP BY w_type;


