DROP PROCEDURE IF EXISTS rsfInterconn.satusehat_datakirims;
DELIMITER //
CREATE PROCEDURE rsfInterconn.satusehat_datakirims()
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- satusehat_datakirims 																						-- */
	/* -- description   : mendapatkan data yang akan di proses ke SATUSEHAT											-- */
	/* -- spesification : select from rsfInterconn.satusehat_mlocation												-- */
	/* -- sysdateLast 	: 2022-12-01 22:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vRowcount bigint;
	DECLARE vresponse_stat INT;
	DECLARE queryobject VARCHAR(32);
	DECLARE queryid bigint;
	DECLARE querydata text;
	DECLARE vDone int;
	DECLARE cursorStokOpname cursor for 
		select 		* 
			from 	(
						select 'Organization' as object, id as id from rsfInterconn.satusehat_morganization where response_stat = 0
						UNION ALL
						select 'Location' as object, id as id from rsfInterconn.satusehat_mlocation where response_stat = 0
						UNION ALL
						select 'Practitioner' as object, id as id from rsfInterconn.satusehat_mpractitioner where response_stat = 0
						UNION ALL
						select 'Patient' as object, id as id from rsfInterconn.satusehat_mpatient where response_stat = 0
						UNION ALL
						select 'Encounter' as object, id as id from rsfInterconn.satusehat_tencounter where response_stat = 0
						UNION ALL
						select 'Condition' as object, id as id from rsfInterconn.satusehat_condition where response_stat = 0
					) subquery;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vDone = 1;

	SET vDone = 0;
	SET vRowcount = 0;
	SET querydata = '[';
	OPEN cursorStokOpname;
	getOpname: LOOP
		FETCH cursorStokOpname INTO queryobject, queryid;
		IF vDone = 1 THEN 
			LEAVE getOpname;
		ELSE
			SET vRowcount = vRowcount + 1;
			IF querydata != '[' THEN
				SET querydata = concat(querydata,',');
			END IF;
			SET querydata = concat(querydata,'{"object":"', queryobject, '","id":', cast( queryid AS UNSIGNED), '}');
		END IF;
	END LOOP getOpname;
	CLOSE cursorStokOpname;
	SET querydata = concat(querydata,']');
	
	IF (vRowcount = 0) THEN
		SELECT 		20009 as statcode,
					0 as rowcount,
					concat('DATA PREPARED, belum ada data yang akan diproses. ') as statmessage,
					'[]' as data;
	ELSE
		SELECT 		0 as statcode,
					vRowcount as rowcount,
					concat('DATA PREPARED, jumlah data ', cast(vRowcount as UNSIGNED), ' baris. ') as statmessage,
					querydata as data;
	END IF;
END //
DELIMITER ;
