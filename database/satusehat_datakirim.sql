DROP PROCEDURE IF EXISTS rsfInterconn.satusehat_datakirim;
DELIMITER //
CREATE PROCEDURE rsfInterconn.satusehat_datakirim()
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- satusehat_datakirim 																						-- */
	/* -- description   : mendapatkan data yang akan di proses ke SATUSEHAT											-- */
	/* -- spesification : select from rsfInterconn.satusehat_mlocation												-- */
	/* -- sysdateLast 	: 2022-12-01 22:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
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
	select 'Condition' as object, id as id from rsfInterconn.satusehat_condition where response_stat = 0;
END //
DELIMITER ;
