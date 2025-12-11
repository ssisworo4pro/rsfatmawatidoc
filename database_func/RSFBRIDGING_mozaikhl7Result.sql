DROP PROCEDURE IF EXISTS rsfBridging.mozaikhl7Result;
DELIMITER //
CREATE DEFINER=`admin`@`%` PROCEDURE `rsfBridging`.`mozaikhl7Result`(dataResponse text)
BEGIN
	DECLARE aRowcount INTEGER(5);
	/*
	update 	rsfBridging.tmozaik_pasien tMozaik
		set send_sts = 1
	  where send_sts = 0;
	SET aRowcount = JSON_UNQUOTE(JSON_EXTRACT(dataResponse, '$.rowcount'));
	IF (aRowcount != 0) THEN
		insert into rsfLog.tlog_dump(message_log)
		select dataResponse;
	END IF;
	commit;
	 */
	SELECT 	1 as statcode,
			0 as rowcount,
			'success' as message,
			aRowcount as data;
END //
DELIMITER ;
