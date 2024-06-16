-- create mega table

DROP DATABASE IF EXISTS voter;
CREATE DATABASE IF NOT EXISTS voter;

USE voter;

DROP TABLE IF EXISTS myvoter;
CREATE TABLE myvoter(
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