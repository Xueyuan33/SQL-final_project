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
