DROP PROCEDURE IF EXISTS rsfInterconn.satusehat_json_get;
DELIMITER //
CREATE PROCEDURE rsfInterconn.satusehat_json_get(aOBJ VARCHAR(32), aID VARCHAR(32))
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- satusehat_json_get 																				    	-- */
	/* -- description   : membentuk data dalam bentuk json yang akan dikirim ke SATUSEHAT						    -- */
	/* -- spesification : select from rsfInterconn.satusehat_morganization											-- */
	/* -- sysdateLast 	: 2022-12-02 11:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vID BIGINT;
	DECLARE vCount INTEGER;
	SET vID	= CAST(aID AS UNSIGNED);
	
	IF (aOBJ = "Organization") THEN
		SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_morganization WHERE id = vID;
		IF (vCount = 0) THEN
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT Organization, id "', aID,'" tidak ditemukan.') as statmessage,
						'' as data;
		ELSE
			SELECT		0 as statcode,
						1 as rowcount,
						concat('SATUSEHAT Organization, "', nama,'" on progress ...') as statmessage,
						concat('{"resourceType": "Organization","active": true,',
						'"identifier": [{','"use": "official",',
						'"system": "http:\/\/sys-ids.kemkes.go.id\/organization\/', kode,'",',
						'"value": "R220001"','}],',
						'"type": [{','"coding": [{',
						'"system": "http:\/\/terminology.hl7.org\/CodeSystem\/organization-type",',
						'"code": "dept",','"display": "', nama, '"','}]}],',
						'"name": "', nama, '",','"telecom": [{',
						'"system": "phone",','"value": "', telpon, '",','"use": "work"',
						'},{','"system": "email",','"value": "', email, '",','"use": "work"',
						'},{','"system": "url",','"value": "', url, '",','"use": "work"','}],',
						'"address": [{','"use": "work",','"type": "both",','"line": ["', alamat_jalan, '"],',
						'"city": "', alamat_kota, '",','"postalCode": "', alamat_kodepos, '",','"country": "', alamat_kd_negara, '",','"extension": [{',
						'"url": "https:\/\/fhir.kemkes.go.id\/r4\/StructureDefinition\/administrativeCode",',
						'"extension": [{"url": "province","valueCode": "', SUBSTR( alamat_kd_kelurahan, 1, 2), '"},',
						'{"url": "city","valueCode": "', SUBSTR( alamat_kd_kelurahan, 1, 4), '"},',
						'{"url": "district","valueCode": "', SUBSTR( alamat_kd_kelurahan, 1, 6), '"},',
						'{"url": "village","valueCode": "', alamat_kd_kelurahan, '"}',']}]}],',
						'"partOf": {"reference": "Organization\/', kode, '"}}') as data
				FROM	rsfInterconn.satusehat_morganization
				WHERE	id = vID;
		END IF;
	ELSEIF (aOBJ = "Location") THEN
		SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mlocation WHERE id = vID;
		IF (vCount = 0) THEN
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT Location, id ''', aID,''' tidak ditemukan.') as statmessage,
						'' as data;
		ELSE
			SELECT		0 as statcode,
						1 as rowcount,
						concat('SATUSEHAT Location, ''', loc.loc_nama,''' on progress ...') as statmessage,
						concat('{"resourceType": "Location",',
						'"identifier": [{"system": "http://sys-ids.kemkes.go.id/location/1000001","value": "', loc.ruangan_id,'"}],',
						'"status": "active",',
						'"name": "', loc.loc_nama,'",',
						'"description": "', loc.loc_deskripsi,'",',
						'"mode": "instance",',
						'"telecom": [',
						'{"system": "phone","value": "', loc.loc_telp,'","use": "work"},',
						'{"system": "fax","value": "', loc.loc_fax,'","use": "work"},',
						'{"system": "email","value": "', loc.loc_email,'"},',
						'{"system": "url","value": "', loc.loc_url,'","use": "work"}',
						'],',
						'"address": {',
						'"use": "work",',
						'"line": ["', loc.loc_alamat, ' ', org.alamat_jalan,'"],',
						'"city": "', org.alamat_kota,'","postalCode": "', org.alamat_kodepos,'","country": "', org.alamat_kd_negara,'",',
						'"extension": [{',
						'"url": "https://fhir.kemkes.go.id/r4/StructureDefinition/administrativeCode",',
						'"extension": [{"url": "province","valueCode": "', SUBSTR( org.alamat_kd_kelurahan, 1, 2),'"},',
						'{"url": "city","valueCode": "', SUBSTR( org.alamat_kd_kelurahan, 1, 4),'"},',
						'{"url": "district","valueCode": "', SUBSTR( org.alamat_kd_kelurahan, 1, 6),'"},',
						'{"url": "village","valueCode": "', org.alamat_kd_kelurahan,'"},',
						'{"url": "rt","valueCode": "', org.alamat_rt,'"},',
						'{"url": "rw","valueCode": "', org.alamat_rw,'"}]}]},',
						'"physicalType": {"coding": [{"system": "http://terminology.hl7.org/CodeSystem/location-physical-type","code": "ro","display": "Room"}]},',
						'"position": {"longitude": ', loc.loc_longitude,',"latitude": ', loc.loc_latitude,',"altitude": ', loc.loc_altitude,'},',
						'"managingOrganization": {"reference": "Organization/', org.kode,'"}}') as data
				FROM	rsfInterconn.satusehat_morganization org,
						rsfInterconn.satusehat_mlocation loc
				WHERE	org.id		= loc.id_organization and
						loc.id 		= vID;
		END IF;
	ELSEIF (aOBJ = "Practitioner") THEN
		SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mpractitioner WHERE id = vID;
		IF (vCount = 0) THEN
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT Practitioner, id "', aID,'" tidak ditemukan.') as statmessage,
						'' as data;
		ELSE
			SELECT		0 as statcode,
						1 as rowcount,
						concat('SATUSEHAT Practitioner, "', practitioner_nik, ' a/n ', practitioner_nama,'" on progress ...') as statmessage,
						concat('Practitioner?identifier=https://fhir.kemkes.go.id/id/nik|',practitioner_nik) as data
				FROM	rsfInterconn.satusehat_mpractitioner
				WHERE	id 		= vID;
		END IF;
	ELSEIF (aOBJ = "Patient") THEN
		SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mpatient WHERE id = vID;
		IF (vCount = 0) THEN
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT Patient, id "', aID,'" tidak ditemukan.') as statmessage,
						'' as data;
		ELSE
			SELECT		0 as statcode,
						1 as rowcount,
						concat('SATUSEHAT Patient, "', patient_nik, ' a/n ', patient_nama,'" on progress ...') as statmessage,
						patient_nik as data
				FROM	rsfInterconn.satusehat_mpatient
				WHERE	id 		= vID;
		END IF;
	ELSEIF (aOBJ = "Encounter") THEN
		SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_tencounter WHERE id = vID;
		IF (vCount = 0) THEN
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT Encounter, id "', aID,'" tidak ditemukan.') as statmessage,
						'' as data;
		ELSE
			SELECT		0 as statcode,
						1 as rowcount,
						concat('SATUSEHAT Encounter, "', patient.patient_nama, '@', loc.loc_deskripsi, ' by ', pract.practitioner_nama , '" on progress ...') as statmessage,
						concat(
						'{"resourceType": "Encounter","status": "arrived",',
						' "class": {"system": "http://terminology.hl7.org/CodeSystem/v3-ActCode","code": "AMB","display": "ambulatory"},',
						' "subject": {"reference": "Patient/', patient.response_id, '","display": "', patient.patient_nama, '"},',
						' "participant": [{"type": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType","code": "ATND","display": "attender"}]}],',
						' "individual": {"reference": "Practitioner/', pract.response_id, '","display": "', pract.practitioner_nama, '"}}],',
						' "period": {"start": "', DATE_FORMAT(trx.kunjungan_tanggal, '%Y-%m-%dT%T+07:00'), '"},',
						' "location": [{"location": {"reference": "Location/', loc.response_id, '","display": "', loc.loc_deskripsi, '"}}],',
						' "statusHistory": [{"status": "arrived","period": {"start": "', DATE_FORMAT(trx.kunjungan_tanggal, '%Y-%m-%dT%T+07:00'), '"}}],',
						' "serviceProvider": {"reference": "Organization/', org.kode, '"},',
						' "identifier": [{"system": "http://sys-ids.kemkes.go.id/encounter/', org.kode, '","value": "', patient.response_id, '"}]}'
						) as data
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
		SELECT count(1) INTO vCount FROM rsfInterconn.satusehat_mlocation WHERE id = vID;
		IF (vCount = 0) THEN
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('SATUSEHAT Condition, id ''', aID,''' tidak ditemukan.') as statmessage,
						'' as data;
		ELSE
			SELECT		0 as statcode,
						1 as rowcount,
						concat('SATUSEHAT Condition, ''', patient.patient_nama, ' icd-10 ', cond.icd10_keterangan, ' (', cond.icd10_kode , ')'' on progress ...') as statmessage,
						concat(
						'{"resourceType": "Condition",',
						'   "clinicalStatus": {"coding": [{"system": "http://terminology.hl7.org/CodeSystem/condition-clinical","code": "active","display": "Active"}]},',
						'   "category": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/condition-category","code": "encounter-diagnosis","display": "Encounter Diagnosis"}]}],',
						'   "code": {"coding": [{"system": "http://hl7.org/fhir/sid/icd-10","code": "', cond.icd10_kode, '","display": "', cond.icd10_keterangan, '"}]},',
						'   "subject": {"reference": "Patient/', patient.response_id, '","display": "', patient.patient_nama, '"},',
						'   "encounter": {"reference": "Encounter/', trx.response_id, '","display": "Kunjungan ', patient.patient_nama, 
						' di hari ', CASE DAYOFWEEK(trx.kunjungan_tanggal) when 1 then 'Minggu' when 2 then 'Senin' when 3 then 'Selasa'
									when 4 then 'Rabu' when 5 then 'Kamis' when 6 then 'Jumat' else 'Sabtu' end, 
						', ', DATE_FORMAT(trx.kunjungan_tanggal,"%e %M %Y"), '"}}'
						) as data
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
					concat('SATUSEHAT json GET, object ''', aOBJ,''' tidak ditemukan.') as statmessage,
					'' as data;
	END IF;
END //
DELIMITER ;
