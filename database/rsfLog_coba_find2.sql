DROP PROCEDURE IF EXISTS rsfLog.coba_find2;
DELIMITER //
CREATE PROCEDURE rsfLog.coba_find2()
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- coba_find	 			 																					-- */
	/* -- description   : destroy data access module berdasarkan object												-- */
	/* -- spesification : 						 		 															-- */
	/* -- sysdateLast 	: 2023-05-17 12:00 																			-- */
	/* -- useridLast  	: can 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vOBJ 		VARCHAR(35);
	DECLARE vNAMA		VARCHAR(150);
	DECLARE vUSENAME	VARCHAR(15);
	DECLARE vNIP		VARCHAR(19);
	DECLARE vPAGE 		INTEGER(5);
	DECLARE vNPP 		INTEGER(5);

	SET vOBJ 		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.object'));
	SET vPAGE 		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.page'));
	SET vNPP 		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.numPerPage'));

	IF (aOBJ = "pengguna-practitioner") THEN
		SET vNAMA			= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.nama'));
		SET vUSENAME		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.username'));
		SET vNIP			= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.nip'));

		SET @vQuery = '';
		SET @vQuery = CONCAT(@vQuery,' SELECT 	0 AS statcode, 1 AS rowcount, ');
		SET @vQuery = CONCAT(@vQuery,' 			up.id user_id, up.pegawai_id, up.name, up.username, up.status, up.is_active, ');
		SET @vQuery = CONCAT(@vQuery,' 			mp.nama nama, mp.nip nip, DATE_FORMAT(mp.tanggal_lahir, "%Y-%m-%d %H:%i:%s") tanggal_lahir, ');
		SET @vQuery = CONCAT(@vQuery,' 			DATE_FORMAT(up.created_at, "%Y-%m-%d %H:%i:%s") created_at, DATE_FORMAT(up.updated_at, "%Y-%m-%d %H:%i:%s") updated_at ');
		SET @vQuery = CONCAT(@vQuery,' FROM 	rsfAuth.users_practitioner up ');
		SET @vQuery = CONCAT(@vQuery,' 		LEFT JOIN master.pegawai mp ON mp.id = up.pegawai_id ');
		SET @vQuery = CONCAT(@vQuery,' WHERE	up.id IS NOT NULL '", vNama ,"' ');
		SET @vQuery = CONCAT(@vQuery,' 			'", vUSENAME ,"' ');
		SET @vQuery = CONCAT(@vQuery,' 			'", vNIP ,"' ');
		SET @vQuery = CONCAT(@vQuery,' ORDER BY	up.updated_at DESC ');
		SET @vQuery = CONCAT(@vQuery,' LIMIT 	'", vPAGE ,"', '", vNPP ,"' ');

		PREPARE stmt1 FROM @vQuery;
		EXECUTE stmt1;	

	END IF;
END //
DELIMITER ;
