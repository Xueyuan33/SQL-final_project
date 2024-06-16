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
    
  -- IF sql_error= FALSE THEN
  -- SELECT 'DELETE SUCCESSFULLY' INTO msg;
  --   ELSE
  -- SELECT 'Duplicate key error encountered' INTO msg;
 -- END ;
  
  -- SELECT msg;
END //
DELIMITER ;





SELECT * 
FROM audit_delete;


SELECT * 
FROM person
WHERE first_name="XUEYUAN";




