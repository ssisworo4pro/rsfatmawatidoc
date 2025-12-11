DROP PROCEDURE IF EXISTS rsfInterconn.satusehat_json_set;
DELIMITER //
CREATE PROCEDURE rsfInterconn.satusehat_json_set(
	aOBJ VARCHAR(32),
	aID VARCHAR(32),
	aJsonData TEXT
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- satusehat_json_set 																				-- */
	/* -- description   : mencatat respon data organization dari SATUSEHAT											-- */
	/* -- spesification : select from rsfInterconn.satusehat_mlocation											-- */
	/* -- sysdateLast 	: 2022-12-01 22:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vID BIGINT;
	DECLARE vResponseId varchar(75);
	DECLARE vResponseTotal BIGINT;
	DECLARE vCount INTEGER;

	START TRANSACTION;
		SET vID	= CAST(aID AS UNSIGNED);
		IF (aOBJ = "Organization") THEN
			SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_morganization WHERE id = vID;
			IF (vCount = 0) THEN
				SELECT 		20002 as statcode,
							0 as rowcount,
							concat('SATUSEHAT Organization, update id ''', aID,''' tidak ditemukan.') as statmessage,
							'' as data;
			ELSE
				SET vResponseId = JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.id'));
				UPDATE		satusehat_morganization
					SET		response_json 		= aJsonData,
							response_id   		= vResponseId,
							response_stat 		= 1,
							response_sysdate	= current_timestamp
					WHERE	id = vID;
					
				SELECT 		0 as statcode,
							1 as rowcount,
							concat('SATUSEHAT Organization, ''', nama,''' complete with respond id ''', response_id, '''') as statmessage,
							vResponseId as data
					FROM	satusehat_morganization
					WHERE	id = vID;
			END IF;
		ELSEIF (aOBJ = "Location") THEN
			SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mlocation WHERE id = vID;
			IF (vCount = 0) THEN
				SELECT 		20002 as statcode,
							0 as rowcount,
							concat('SATUSEHAT Location, update id ''', aID,''' tidak ditemukan.') as statmessage,
							'' as data;
			ELSE
				SET vResponseId = JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.id'));
				UPDATE		satusehat_mlocation
					SET		response_json 		= aJsonData,
							response_id   		= vResponseId,
							response_stat 		= 1,
							response_sysdate	= current_timestamp
					WHERE	id = vID;
					
				SELECT 		0 as statcode,
							1 as rowcount,
							concat('SATUSEHAT Location, ''', loc_deskripsi,''' complete with respond id ''', response_id, '''') as statmessage,
							vResponseId as data
					FROM	satusehat_mlocation
					WHERE	id = vID;
			END IF;
		ELSEIF (aOBJ = "Practitioner") THEN
			SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mpractitioner WHERE id = vID;
			IF (vCount = 0) THEN
				SELECT 		20002 as statcode,
							0 as rowcount,
							concat('SATUSEHAT Practitioner, update id ''', aID,''' tidak ditemukan.') as statmessage,
							'' as data;
			ELSE
				SET vResponseTotal	= CAST(JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.total')) AS UNSIGNED);
				IF vResponseTotal = 0 THEN
					UPDATE		satusehat_mpractitioner
						SET		response_json 		= aJsonData,
								response_stat 		= 9,
								response_sysdate	= current_timestamp
						WHERE	id = vID;
						
					SELECT 		20003 as statcode,
								0 as rowcount,
								concat('SATUSEHAT Practitioner, ''', practitioner_nik, ' a/n ', practitioner_nama,''' not found in SATUSEHAT.') as statmessage,
								'' as data
						FROM	satusehat_mpractitioner
						WHERE	id = vID;
				ELSE
					SET vResponseId 	= JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.entry[0].resource.id'));
					UPDATE		satusehat_mpractitioner
						SET		response_json 		= aJsonData,
								response_id   		= vResponseId,
								response_stat 		= 1,
								response_sysdate	= current_timestamp
						WHERE	id = vID;
						
					SELECT 		0 as statcode,
								1 as rowcount,
								concat('SATUSEHAT Practitioner, ''', practitioner_nik, ' a/n ', practitioner_nama,''' complete with respond id ''', response_id, '''') as statmessage,
								vResponseId as data
						FROM	satusehat_mpractitioner
						WHERE	id = vID;
				END IF;
			END IF;
		ELSEIF (aOBJ = "Patient") THEN
			SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mpatient WHERE id = vID;
			IF (vCount = 0) THEN
				SELECT 		20002 as statcode,
							0 as rowcount,
							concat('SATUSEHAT Patient, update id ''', aID,''' tidak ditemukan.') as statmessage,
							'' as data;
			ELSE
				SET vResponseTotal	= CAST(JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.total')) AS UNSIGNED);
				IF vResponseTotal = 0 THEN
					UPDATE		satusehat_mpatient
						SET		response_json 		= aJsonData,
								response_stat 		= 9,
								response_sysdate	= current_timestamp
						WHERE	id = vID;
						
					SELECT 		20003 as statcode,
								0 as rowcount,
								concat('SATUSEHAT Patient, ''', patient_nik, ' a/n ', patient_nama,''' not found in SATUSEHAT.') as statmessage,
								'' as data
						FROM	satusehat_mpatient
						WHERE	id = vID;
				ELSE
					SET vResponseId 	= JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.entry[0].resource.id'));
					UPDATE		satusehat_mpatient
						SET		response_json 		= aJsonData,
								response_id   		= vResponseId,
								response_stat 		= 1,
								response_sysdate	= current_timestamp
						WHERE	id = vID;
						
					SELECT 		0 as statcode,
								1 as rowcount,
								concat('SATUSEHAT Patient, ''', patient_nik, ' a/n ', patient_nama,''' complete with respond id ''', response_id, '''') as statmessage,
								vResponseId as data
						FROM	satusehat_mpatient
						WHERE	id = vID;
				END IF;
			END IF;
		ELSEIF (aOBJ = "Encounter") THEN
			SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_tencounter WHERE id = vID;
			IF (vCount = 0) THEN
				SELECT 		20002 as statcode,
							0 as rowcount,
							concat('SATUSEHAT Encounter, update id ''', aID,''' tidak ditemukan.') as statmessage,
							'' as data;
			ELSE
				SET vResponseId 	= JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.id'));
				UPDATE		satusehat_tencounter
					SET		response_json 		= aJsonData,
							response_id   		= vResponseId,
							response_stat 		= 1,
							response_sysdate	= current_timestamp
					WHERE	id = vID;
					
				SELECT 		0 as statcode,
							1 as rowcount,
							concat('SATUSEHAT Encounter, ''', patient.patient_nama, '@', loc.loc_deskripsi, ' by ', pract.practitioner_nama , ''' complete in SATUSEHAT with respond id ', vResponseId) as statmessage,
							vResponseId as data
					FROM	rsfInterconn.satusehat_morganization org,
							rsfInterconn.satusehat_mlocation loc,
							rsfInterconn.satusehat_mpatient patient,
							rsfInterconn.satusehat_mpractitioner pract,
							rsfInterconn.satusehat_tencounter trx
					WHERE	org.id		= loc.id_organization and
							loc.id		= trx.id_location and
							patient.id  = trx.id_patient and
							pract.id    = trx.id_practitioner and
							trx.id 		= vID;
			END IF;
		ELSEIF (aOBJ = "Condition") THEN
			SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_condition WHERE id = vID;
			IF (vCount = 0) THEN
				SELECT 		20002 as statcode,
							0 as rowcount,
							concat('SATUSEHAT Condition, update id ''', aID,''' tidak ditemukan.') as statmessage,
							'' as data;
			ELSE
				SET vResponseId 	= JSON_UNQUOTE(JSON_EXTRACT(aJsonData, '$.id'));
				UPDATE		satusehat_condition
					SET		response_json 		= aJsonData,
							response_id   		= vResponseId,
							response_stat 		= 1,
							response_sysdate	= current_timestamp
					WHERE	id = vID;
					
				SELECT 		0 as statcode,
							1 as rowcount,
							concat('SATUSEHAT Condition, ''', patient.patient_nama, ' icd-10 ', cond.icd10_keterangan, ' (', cond.icd10_kode , ')'' complete in SATUSEHAT with respond id ', vResponseId) as statmessage,
							vResponseId as data
					FROM	rsfInterconn.satusehat_morganization org,
							rsfInterconn.satusehat_mlocation loc,
							rsfInterconn.satusehat_mpatient patient,
							rsfInterconn.satusehat_mpractitioner pract,
							rsfInterconn.satusehat_tencounter trx,
							rsfInterconn.satusehat_condition cond
					WHERE	org.id		= loc.id_organization and
							loc.id		= trx.id_location and
							patient.id  = trx.id_patient and
							pract.id    = trx.id_practitioner and
							trx.id      = cond.id_encounter and
							cond.id 	= vID;
			END IF;
		ELSE
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT json SET, object ''', aOBJ,''' tidak ditemukan.') as statmessage,
						'' as data;
		END IF;
	COMMIT;
END //
DELIMITER ;
