-- analytics 1
USE voter;

-- constituents_submit : Get Constituents Stats.   
DROP VIEW IF EXISTS constituent_stats;
CREATE VIEW constituent_stats AS
SELECT party_cd, COUNT(*), count(*) * 100.0 / (select count(*) from person) AS percentage
FROM person
GROUP BY party_cd
ORDER BY COUNT(*) DESC;

-- SELECT * FROM constituent_stats;

-- dem_region_submit: Get Dem Regional Stats
DROP VIEW IF EXISTS dem_region_stats;
CREATE VIEW dem_region_stats AS
SELECT res_city_desc, COUNT(*), 
	count(*) * 100.0 / (select count(*) 
    FROM (city_state
		JOIN zip_city USING(res_city_desc)
		JOIN residential_address_info USING(zip_code)
        JOIN person USING(voter_reg_num))
		WHERE party_cd='DEM') AS percentage
FROM (city_state
		JOIN zip_city USING(res_city_desc)
		JOIN residential_address_info USING(zip_code)
        JOIN person USING(voter_reg_num))
WHERE party_cd='DEM'
GROUP BY res_city_desc
ORDER BY COUNT(*) DESC;

-- SELECT * FROM dem_region_stats;

-- dem_gender_submit: Get Dem Gender Stats
DROP VIEW IF EXISTS dem_gender_stats;
CREATE VIEW dem_gender_stats AS
SELECT sex_code, COUNT(sex_code), count(*) * 100.0 / (select count(*) from person ) AS percentage
FROM person
WHERE party_cd='DEM'
GROUP BY sex_code
ORDER BY COUNT(sex_code) DESC;

select * from dem_gender_stats;


-- switch procedure 
-- input party_id, election_id
DROP PROCEDURE IF EXISTS switched_election;

DElIMITER // 
CREATE PROCEDURE switched_election(
	    IN party_cd CHAR(3),
        IN election_id TINYINT(4))
BEGIN 
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE CONTINUE HANDLER FOR 1062 SET sql_error = TRUE;

	SELECT COUNT(CASE WHEN p.party_cd!=v.party_cd AND v.party_cd!='' THEN 1 END) AS first_name
    FROM person p
		 JOIN voting_history v ON p.voter_reg_num= v.voter_reg_num
	WHERE party_cd=p.party_cd AND 
		  election_id=v.election_id;

END //
DELIMITER ;
   
-- call switched_election('DEM',4);

