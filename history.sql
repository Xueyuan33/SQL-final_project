USE voter;

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
    

CALL get_voting_record(131);



