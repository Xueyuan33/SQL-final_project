-- create mega table

DROP DATABASE IF EXISTS voter;
CREATE DATABASE IF NOT EXISTS voter;

USE voter;

DROP TABLE IF EXISTS myvoter;
CREATE TABLE IF NOT EXISTS myvoter(
 precinct_desc CHAR(7), 
    party_cd CHAR(4), 
    race_code CHAR(2), 
    ethnic_code CHAR(3), 
    sex_code CHAR(1), 
    age INT, 
    pct_portion DECIMAL(10, 6),
    first_name VARCHAR(50),
 middle_name VARCHAR(50), 
    last_name VARCHAR(50), 
    name_suffix_lbl VARCHAR(20), 
    full_name_mail VARCHAR(100), 
    mail_addr1 VARCHAR(100),  
    mail_addr2 VARCHAR(100),
 mail_city_state_zip VARCHAR(100), 
    house_num INT, 
    street_dir VARCHAR(5), 
    street_name VARCHAR(50), 
    street_type_cd VARCHAR(5), 
    street_sufx_cd VARCHAR(5),
 unit_num VARCHAR(10), 
    res_city_desc VARCHAR(50) , 
    state_cd CHAR(2), 
    zip_code INT, 
    registr_dt DATETIME, 
    voter_reg_num INT(15) , 
    status_cd VARCHAR(255),  
 municipality_desc VARCHAR(50), 
    ward_desc VARCHAR(100),  
    cong_dist_desc VARCHAR(100),  
    super_court_desc VARCHAR(100), 
    nc_senate_desc VARCHAR(100),
 nc_house_desc VARCHAR(100), 
    county_commiss_desc VARCHAR(100), 
    school_dist_desc VARCHAR(100), 
    E1 INT, 
    E1_date VARCHAR(20) DEFAULT NULL,  
    E1_VotingMethod VARCHAR(6),
 E1_PartyCd VARCHAR(5), 
    E2 INT, 
    E2_Date VARCHAR(20) DEFAULT NULL, 
    E2_VotingMethod VARCHAR(6), 
    E2_PartyCd VARCHAR(5),  
    E3 INT, 
    E3_Date VARCHAR(20) DEFAULT NULL, 
    E3_VotingMethod VARCHAR(6),
 E3_PartyCd VARCHAR(5), 
    E4 INT, 
    E4_Date VARCHAR(20) DEFAULT NULL, 
    E4_VotingMethod VARCHAR(6),  
    E4_PartyCd VARCHAR(5), 
    E5 INT, 
    E5_Date VARCHAR(20) DEFAULT NULL,  
    E5_VotingMethod VARCHAR(6),  
 E5_PartyCd VARCHAR(5)
);

-- load data to the mega table 
LOAD DATA INFILE '/Users/xueyuanli/Desktop/SQL/project/project part 1/voterDataF22.csv'
IGNORE INTO TABLE myvoter
FIELDS ENCLOSED BY '$' TERMINATED BY ';' LINES TERMINATED BY '\r\n' 
(precinct_desc, party_cd, race_code, ethnic_code, sex_code, age, @pct_portion, first_name,
middle_name, last_name, name_suffix_lbl, full_name_mail, mail_addr1, mail_addr2,
mail_city_state_zip, house_num, street_dir, street_name, street_type_cd, street_sufx_cd,
unit_num, res_city_desc, state_cd, zip_code, registr_dt, voter_reg_num, status_cd,  
municipality_desc, ward_desc, cong_dist_desc, super_court_desc, nc_senate_desc,
nc_house_desc, county_commiss_desc, school_dist_desc, 
E1, E1_date, @E1_VotingMethod, E1_PartyCd, 
E2, E2_Date, @E2_VotingMethod, E2_PartyCd,  
E3, E3_Date, @E3_VotingMethod, E3_PartyCd, 
E4, E4_Date, @E4_VotingMethod, E4_PartyCd, 
E5, E5_Date, @E5_VotingMethod, E5_PartyCd)
SET E1_VotingMethod = TRIM(@E1_VotingMethod), 
 E2_VotingMethod = TRIM(@E2_VotingMethod), 
 E3_VotingMethod = TRIM(@E3_VotingMethod), 
    E4_VotingMethod = TRIM(@E4_VotingMethod), 
    E5_VotingMethod = TRIM(@E5_VotingMethod),
    pct_portion = NULLIF(@pct_portion,'');
    
-- recreate database and normalized table

DROP TABLE IF EXISTS voter.person;
CREATE TABLE IF NOT EXISTS voter.person(
  party_cd varchar(255),
  race_code varchar(255),
  ethnic_code varchar(255),
  sex_code varchar(255),
  age int(3),
  first_name varchar(100),
  middle_name varchar(100),
  last_name varchar(100),
  name_suffix_lbl varchar(40),
  full_name_mail varchar(100),
  status_cd varchar(255),
  registr_dt datetime,
  voter_reg_num bigint(20),
     PRIMARY KEY (voter_reg_num));
     
DROP TABLE IF EXISTS voter.city_state;
CREATE TABLE IF NOT EXISTS voter.city_state(
  res_city_desc varchar(45),
  state_cd varchar(45),
  PRIMARY KEY(res_city_desc));
     
DROP TABLE IF EXISTS voter.zip_city;
CREATE TABLE IF NOT EXISTS voter.zip_city(
  zip_code char(5),
  res_city_desc varchar(45),
  PRIMARY KEY(zip_code),
     CONSTRAINT fk_city_state_voter_city_desc
    FOREIGN KEY (res_city_desc)
    REFERENCES voter.city_state(res_city_desc) );

DROP TABLE IF EXISTS voter.residential_address_info;
CREATE TABLE IF NOT EXISTS voter.residential_address_info(
  voter_reg_num bigint(20),
  house_num VARCHAR(45),
  street_dir varchar(45),
  street_name varchar(45),
  street_type_cd varchar(45),
  street_sufx_cd varchar(45),
  unit_num varchar(45),
     zip_code char(5),
     pct_portion varchar(255),
 INDEX index_name (zip_code, pct_portion),
 CONSTRAINT fk_zip_city_voter_zip
    FOREIGN KEY (zip_code)
    REFERENCES voter.zip_city(zip_code));

DROP TABLE IF EXISTS voter.area;
CREATE TABLE IF NOT EXISTS voter.area(
 voter_reg_num BIGINT(20),
  pct_portion varchar(255),
  precinct_desc varchar(255),
  ward_desc varchar(255),
  cong_dist_desc varchar(255),
  super_court_desc varchar(255),
  nc_senate_desc varchar(255),
  nc_house_desc varchar(255),
  county_commiss_desc varchar(255),
  school_dist_desc varchar(255),
   PRIMARY KEY (voter_reg_num));

  
DROP TABLE IF EXISTS voter.election;
CREATE TABLE IF NOT EXISTS voter.election(
election_ID TINYINT(4),
election_Name CHAR(2),
election_Date DATE DEFAULT NULL,
PRIMARY KEY(election_ID));

DROP TABLE IF EXISTS voter.voting_history;
CREATE TABLE IF NOt EXISTS voter.voting_history(
 voter_reg_num BIGINT(20),
    election_ID TINYINT(4),
    voting_method CHAR(1),
    party_cd CHAR(3),
    election_num TINYINT(4),
 CONSTRAINT fk_person_voter_reg
    FOREIGN KEY (voter_reg_num)
    REFERENCES voter.person (voter_reg_num),
    CONSTRAINT fk_election_voter_election
    FOREIGN KEY (election_ID)
    REFERENCES voter.election (election_ID)
);

-- INSERT data from mega table to new tables 

INSERT INTO voter.person (party_cd, race_code, ethnic_code, sex_code, age, first_name, middle_name, last_name, name_suffix_lbl, full_name_mail, status_cd, registr_dt, voter_reg_num)
SELECT party_cd, race_code, ethnic_code, sex_code, age, first_name, middle_name, last_name, name_suffix_lbl, full_name_mail, status_cd, registr_dt, voter_reg_num
FROM myvoter;

-- Insert data into the city_state table
INSERT INTO voter.city_state (res_city_desc, state_cd)
SELECT DISTINCT res_city_desc, state_cd
FROM myvoter;

-- Insert data into the zip_city table
INSERT INTO voter.zip_city (zip_code, res_city_desc)
SELECT DISTINCT zip_code, res_city_desc
FROM myvoter;

-- Insert data into the residential_address_info table
INSERT INTO voter.residential_address_info (voter_reg_num, house_num, street_dir, street_name, street_type_cd, street_sufx_cd, unit_num, zip_code, pct_portion)
SELECT voter_reg_num, house_num, street_dir, street_name, street_type_cd, street_sufx_cd, unit_num, zip_code, pct_portion
FROM myvoter;

-- Insert data into the area table
INSERT INTO voter.area (voter_reg_num, pct_portion, precinct_desc, ward_desc, cong_dist_desc, super_court_desc, nc_senate_desc, nc_house_desc, county_commiss_desc, school_dist_desc)
SELECT voter_reg_num, pct_portion, precinct_desc, ward_desc, cong_dist_desc, super_court_desc, nc_senate_desc, nc_house_desc, county_commiss_desc, school_dist_desc
FROM myvoter;

-- Insert data into the election table
INSERT INTO voter.election (election_ID, election_Name, election_Date)
SELECT DISTINCT 
    1 AS election_ID,
    'E1' AS election_Name,
    STR_TO_DATE(E1_Date, '%m/%d/%Y') AS election_Date
FROM myvoter
WHERE E1_date IS NOT NULL AND E1_date != ''
UNION
SELECT DISTINCT 
    2 AS election_ID,
    'E2' AS election_Name,
    STR_TO_DATE(E2_Date, '%m/%d/%Y') AS election_Date
FROM myvoter
WHERE E2_date IS NOT NULL AND E2_date != ''
UNION
SELECT DISTINCT 
    3 AS election_ID,
    'E3' AS election_Name,
    STR_TO_DATE(E3_Date, '%m/%d/%Y') AS election_Date
FROM myvoter
WHERE E3_date IS NOT NULL AND E3_date != ''
UNION
SELECT DISTINCT 
    4 AS election_ID,
    'E4' AS election_Name,
    STR_TO_DATE(E4_Date, '%m/%d/%Y') AS election_Date
FROM myvoter
WHERE E4_date IS NOT NULL AND E4_date != ''
UNION
SELECT DISTINCT 
    5 AS election_ID,
    'E5' AS election_Name,
    STR_TO_DATE(E5_Date, '%m/%d/%Y') AS election_Date
FROM myvoter
WHERE E5_date IS NOT NULL AND E5_date != '';

-- Insert data into the voting_history table

INSERT INTO voter.voting_history (voter_reg_num, election_ID, voting_method, party_cd, election_num)
SELECT voter_reg_num, 1, E1_VotingMethod, E1_PartyCd, 115
FROM myvoter
WHERE E1 IS NOT NULL AND E1_VotingMethod IS NOT NULL
UNION
SELECT voter_reg_num, 2, E2_VotingMethod, E2_PartyCd, 123
FROM myvoter
WHERE E2 IS NOT NULL AND E2_VotingMethod IS NOT NULL
UNION
SELECT voter_reg_num, 3, E3_VotingMethod, E3_PartyCd, 121
FROM myvoter
WHERE E3 IS NOT NULL AND E3_VotingMethod IS NOT NULL
UNION
SELECT voter_reg_num, 4, E4_VotingMethod, E4_PartyCd, 117
FROM myvoter
WHERE E4 IS NOT NULL AND E4_VotingMethod IS NOT NULL
UNION
SELECT voter_reg_num, 5, E5_VotingMethod, E5_PartyCd, 108
FROM myvoter
WHERE E5 IS NOT NULL AND E5_VotingMethod IS NOT NULL;


--

-- USE voter;

-- get_voting_record procedure 
DROP PROCEDURE IF EXISTS get_voting_record;

DElIMITER // 
CREATE PROCEDURE get_voting_record(
	    IN reg_num CHAR(3))
BEGIN 
	DECLARE sql_error INT DEFAULT FALSE;
	DECLARE CONTINUE HANDLER FOR 1062 SET sql_error = TRUE;

	SELECT election_num AS election_ID, voting_method, party_cd
	FROM voting_history
	WHERE reg_num= voter_reg_num 
    ORDER BY election_ID;

END //
DELIMITER ;
    


USE voter;

-- Create the audit_insert table
DROP TABLE IF EXISTS audit_insert;
CREATE TABLE IF NOT EXISTS audit_insert (
    voter_reg_num CHAR(12),
    party_cd CHAR(3),
    audit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- trigger check for party input
DROP TRIGGER IF EXISTS check_insert_voter;
DELIMITER // 
CREATE TRIGGER check_insert_voter
BEFORE INSERT ON person
FOR EACH ROW 
BEGIN 
-- unknown party cd  
        -- change party cd to N/A
	IF
	     NEW.party_cd = 'DEM' 
	  OR NEW.party_cd = 'UNA' 
	  OR NEW.party_cd = 'REP' 
	  OR NEW.party_cd = 'LIB' 
	  OR NEW.party_cd = 'CST' 
	  OR NEW.party_cd = 'GRE' THEN 
      
	  INSERT INTO audit_insert(voter_reg_num, party_cd) 
	  VALUES (NEW.voter_reg_num, NEW.party_cd);
      
      -- SET NEW.party_cd = 'N/A';
	ELSEIF NEW.party_cd <> 'DEM' 
	  OR NEW.party_cd <> 'UNA' 
	  OR NEW.party_cd <> 'REP' 
	  OR NEW.party_cd <> 'LIB' 
	  OR NEW.party_cd <> 'CST' 
	  OR NEW.party_cd <> 'GRE' THEN 
			-- insert the data into miscellaneous table
	  SET NEW.party_cd = 'N/A';
	  INSERT INTO audit_insert(voter_reg_num, party_cd) 
	  VALUES (NEW.voter_reg_num, NEW.party_cd);
	  
 END IF;
END //
DELIMITER ;

-- insertion procedure 
DROP PROCEDURE IF EXISTS insert_voter;

DElIMITER // 
CREATE PROCEDURE insert_voter(
 IN voter_reg_num CHAR(12), 
    IN frist_name VARCHAR(45), 
    IN middle_name VARCHAR(45), 
    IN last_name VARCHAR(45), 
    IN name_suffix_lbl VARCHAR(45), 
    IN p_party_cd CHAR(3),
    OUT msg VARCHAR(45))
BEGIN 
 DECLARE sql_error INT DEFAULT FALSE;
 DECLARE CONTINUE HANDLER FOR 1062 SET sql_error = TRUE;
    -- SELECT 'Duplicate key error encountered' INTO msg;
    -- DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'SQL exception encountered' INTO msg;
    
    INSERT INTO person (voter_reg_num, party_cd, first_name, middle_name, last_name, name_suffix_lbl, full_name_mail )
    VALUES (voter_reg_num, p_party_cd, frist_name, middle_name, last_name, name_suffix_lbl, 
    CONCAT(frist_name,' ', middle_name,' ', last_name, ' ', name_suffix_lbl));
    
    -- INSERT INTO demographic_data(voter_reg_num, party_cd)
    -- VALUES (voter_reg_num, party_cd);
    IF sql_error= FALSE THEN
  SELECT 'INSERTED SUCCESSFULLY' INTO msg;
    ELSE
  SELECT 'Duplicate key error encountered' INTO msg;
 END IF;
    SELECT msg;
END //
DELIMITER ;


select *
from audit_insert;


SELECT * FROM person
WHERE voter_reg_num="122123";



-- delete rows

DROP TABLE IF EXISTS audit_delete;
CREATE TABLE IF NOT EXISTS audit_delete(
	voter_reg_num CHAR(45),
    first_name VARCHAR(45),
    middle_name VARCHAR(45),
    last_name VARCHAR(45),
    audit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
    
-- select * from audit_table;


DROP TRIGGER IF EXISTS check_delete_voter;
DELIMITER // 
CREATE TRIGGER check_delete_voter
BEFORE DELETE ON person
FOR EACH ROW 
BEGIN 
       -- Insert the deleted voter's information into the audit table
    INSERT INTO audit_delete (voter_reg_num, first_name, middle_name, last_name)
    SELECT voter_reg_num, first_name, middle_name, last_name
    FROM person
    WHERE voter_reg_num=OLD.voter_reg_num;
    
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS delete_voter;
DELIMITER // 
CREATE PROCEDURE delete_voter(
  IN reg_num CHAR(12))
BEGIN 
  DECLARE sql_error INT DEFAULT FALSE;
  DECLARE CONTINUE HANDLER FOR 1062 SET sql_error = TRUE;
	SET SQL_SAFE_UPDATES = 0;
      -- Delete the voter from the voting_history table
    DELETE FROM voting_history
    WHERE reg_num  = voter_reg_num ;

    -- Delete the voter from the residential_address_info table
    DELETE FROM residential_address_info
    WHERE reg_num  = voter_reg_num ;

    -- Delete the voter from the person table
    DELETE FROM person
    WHERE reg_num =voter_reg_num ;
	
    SET SQL_SAFE_UPDATES = 1;
    
END //
DELIMITER ;



SELECT * 
FROM audit_delete;


SELECT * 
FROM person
WHERE first_name="XUEYUAN";





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
SELECT sex_code, COUNT(sex_code), count(*) * 100.0 / (select count(*) from person WHERE party_cd="DEM") AS percentage
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
   






-- Analytics 2

-- something wrong in getStats2.php:
-- $custom1_query = "SELECT * FROM rep_gender_stats;";    it should be 'rep_regional_stats'
-- $custom2_query = "SELECT * FROM rep_gender_stats;";  

 -- Custom1 Stats -> view: election1_city_stats
DROP VIEW IF EXISTS election1_city_stats;
CREATE VIEW election1_city_stats AS
SELECT res_city_desc, COUNT(res_city_desc),
    (COUNT(res_city_desc) * 100.0 / (SELECT COUNT(res_city_desc)
       FROM person 
       JOIN voting_history USING (voter_reg_num)
       JOIN residential_address_info USING (voter_reg_num)
       JOIN zip_city USING (zip_code)
       WHERE election_ID = '1')) AS percentage
FROM person 
JOIN voting_history USING (voter_reg_num)
JOIN residential_address_info USING (voter_reg_num)
JOIN zip_city USING (zip_code)
WHERE election_ID = '1'
GROUP BY res_city_desc
ORDER BY COUNT(res_city_desc) DESC;



-- Custom2 Stats - view: election1_ethnic_stats
DROP VIEW IF EXISTS election1_ethnic_stats;
CREATE VIEW election1_ethnic_stats AS
SELECT ethnic_code,COUNT(ethnic_code),
    (COUNT(ethnic_code) * 100.0 / (SELECT COUNT(ethnic_code) 
       FROM person 
       JOIN voting_history USING (voter_reg_num)
       WHERE election_ID = '1')) AS percentage
FROM person
JOIN voting_history USING (voter_reg_num)
WHERE election_ID = '1'
GROUP BY ethnic_code
ORDER BY COUNT(ethnic_code) DESC;



