CREATE DEFINER=`admin`@`%` PROCEDURE `rsfKatalog`.`mkatalog_update_put`(aJson TEXT)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- mkatalog_update_put 		 			 																	-- */
	/* -- description   : update data master katalog berdasarkan object												-- */
	/* -- spesification : 						 		 															-- */
	/* -- sysdateLast 	: 2023-07-27 15:00 																			-- */
	/* -- useridLast  	: can 																						-- */
	/* -- revisionCount : 2 																						-- */
	/* -- revisionNote  : Finalisaksi Fungsi								 										-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- revisionCount : 3 																						-- */
	/* -- revisionDate  : 31-08-2023 10:24 																			-- */
	/* -- revisionNote  : update rsfTeamterima.masterf_pbf			 												-- */
	/* -- 				  update inventory.penyedia			 														-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- revisionCount : 4 																						-- */
	/* -- revisionDate  : 06-09-2023 15:00 																			-- */
	/* -- revisionNote  : aOBJ = "farmasi-kode-katalog"																-- */
	/* -- 				  update sts_pabrik = 0			 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- revisionCount : 5 																						-- */
	/* -- revisionDate  : 11-09-2023 15:00 																			-- */
	/* -- revisionNote  : aOBJ = "farmasi"																			-- */
	/* -- 				  insert rsfTeamterima.masterf_katalog		 												-- */
	/* -- 				  insert inventory.barang		 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE aBODY				TEXT;
	DECLARE aOBJ 				VARCHAR(35);
	DECLARE aID					INTEGER(11);
	DECLARE aCOUNT				INTEGER(3);
	/**pabrik*/
	DECLARE vpbrkKODE 			VARCHAR(15);
	DECLARE vpbrkPABRIK 		VARCHAR(255);
	DECLARE vpbrkNPWP	 		VARCHAR(50);
	DECLARE vpbrkALAMAT	 		VARCHAR(255);
	DECLARE vpbrkKOTA	 		VARCHAR(255);
	DECLARE vpbrkKDPOS	 		INTEGER(10);
	DECLARE vpbrkTELP	 		VARCHAR(15);
	DECLARE vpbrkFAX	 		VARCHAR(15);
	DECLARE vpbrkEMAIL	 		VARCHAR(100);
	DECLARE vpbrkCPNAME	 		VARCHAR(255);
	DECLARE vpbrkCPTELP	 		VARCHAR(15);
	DECLARE vpbrkAKTIF	 		TINYINT(1);
	DECLARE vpbrkUSER	 		INTEGER(11);
	/**kemasan*/
	DECLARE vkmsnKODE 			VARCHAR(20);
	DECLARE vkmsnKDMED 			VARCHAR(20);
	DECLARE vkmsnNAMA	 		VARCHAR(255);
	DECLARE vkmsnAKTIF	 		TINYINT(1);
	DECLARE vkmsnUSER	 		INTEGER(11);
	/**pbf*/
	DECLARE vpbfKODE 			VARCHAR(15);
	DECLARE vpbfNAMA			VARCHAR(255);
	DECLARE vpbfNPWP	 		VARCHAR(50);
	DECLARE vpbfALAMAT	 		VARCHAR(255);
	DECLARE vpbfKOTA	 		VARCHAR(255);
	DECLARE vpbfKDPOS	 		INTEGER(10);
	DECLARE vpbfTELP	 		VARCHAR(255);
	DECLARE vpbfFAX	 			VARCHAR(255);
	DECLARE vpbfEMAIL	 		VARCHAR(255);
	DECLARE vpbfKPLCABANG		VARCHAR(255);
	DECLARE vpbfCPNAME	 		VARCHAR(255);
	DECLARE vpbfCPTELP	 		VARCHAR(255);
	DECLARE vpbfUSER	 		INTEGER(11);
	/**generik*/
	DECLARE vgnrKODE 			VARCHAR(20);
	DECLARE vgnrNAMA 			TEXT;
	DECLARE vgnrRESTRIKSI		TEXT;
	DECLARE vgnrUSER	 		INTEGER(11);
	/**kelompok barang*/
	DECLARE vklpbrgIDINV 		INTEGER(11);
	DECLARE vklpbrgIDHARCD 		INTEGER(11);
	DECLARE vklpbrgIDKATSIMG 	INTEGER(11);
	DECLARE vklpbrgKODE 		VARCHAR(20);
	DECLARE vklpbrgKLPBRG		VARCHAR(255);
	DECLARE vklpbrgKDTEMP 		VARCHAR(10);
	DECLARE vklpbrgNOURUT		INTEGER(11);
	DECLARE vklpbrgGOL	 		TINYINT(4);
	DECLARE vklpbrgStsAktf	 	TINYINT(1);
	DECLARE vklpbrgBID			CHAR(2);
	DECLARE vklpbrgKEL	 		CHAR(2);
	DECLARE vklpbrgSUBKEL 		CHAR(2);
	DECLARE vklpbrgSSKEL		TINYINT(4);
	DECLARE vklpbrgUSER	 		INTEGER(11);
	/**brand*/
	DECLARE vbrndKODE 			VARCHAR(20);
	DECLARE vbrndID 			INTEGER(11);
	DECLARE vbrndNAMA			VARCHAR(255);
	DECLARE vbrndUSER	 		INTEGER(11);
	/**buffer-gudang*/
	DECLARE vbffgdngID 			INTEGER(11);
	DECLARE vbffgdngKODE 		VARCHAR(20);
	DECLARE vbffgdngIDGNR		INTEGER(11);
	DECLARE vbffgdngJNS 		CHAR(2);
	DECLARE vbffgdngLEAD		INTEGER(10);
	DECLARE vbffgdngPERBFF	 	INTEGER(10);
	DECLARE vbffgdngPERLT		INTEGER(10);
	DECLARE vbffgdngJMLAVG	 	INTEGER(10);
	DECLARE vbffgdngJMLBFF 		INTEGER(10);
	DECLARE vbffgdngJMLLT		INTEGER(10);
	DECLARE vbffgdngJMLRP		INTEGER(10);
	DECLARE vbffgdngAKTIF		TINYINT(1);
	DECLARE vbffgdngUSER	 	INTEGER(11);
	/**jenis-anggaran*/
	DECLARE vjnsangKODE 		VARCHAR(5);
	DECLARE vjnsangJNS 			VARCHAR(255);
	DECLARE vjnsangAKTIF		INTEGER(11);
	DECLARE vjnsangUSERIN	 	INTEGER(11);
	DECLARE vjnsangDTIN	 		DATETIME;
	DECLARE vjnsangUSERUP	 	INTEGER(11);
	/**sub-jenis-anggaran*/
	DECLARE vsbjnsangID	 		INTEGER(11);
	DECLARE vsbjnsangTHN	 	INTEGER(4);
	DECLARE vsbjnsangKODE 		VARCHAR(6);
	DECLARE vsbjnsangSBJNS 		VARCHAR(255);
	DECLARE vsbjnsangKET 		TEXT;
	DECLARE vsbjnsangAKTIF		INTEGER(11);
	DECLARE vsbjnsangUSERIN	 	INTEGER(11);
	DECLARE vsbjnsangDTIN	 	DATETIME;
	DECLARE vsbjnsangUSERUP	 	INTEGER(11);
	/**sakti*/
	DECLARE vsaktiIDHDR	 		INTEGER(11);
	DECLARE vsaktiKODE 			VARCHAR(6);
	DECLARE vsaktiURAIAN 		VARCHAR(255);
	DECLARE vsaktiAKTIF 		INTEGER(11);
	DECLARE vsaktiUSERIN	 	BIGINT(20);
	DECLARE vsaktiDTIN	 		DATETIME;
	DECLARE vsaktiUSERUP	 	INTEGER(11);
	/**sakti-hdr*/
	DECLARE vsaktihdrKODE 		CHAR(10);
	DECLARE vsaktihdrURAIAN 	VARCHAR(255);
	DECLARE vsaktihdrUSERIN	 	BIGINT(20);
	DECLARE vsaktihdrDTIN	 	DATETIME;
	DECLARE vsaktihdrUSERUP	 	INTEGER(11);
	/**dosis*/
	DECLARE vdosisKODE 			CHAR(4);
	DECLARE vdosisNAMA 			VARCHAR(255);
	DECLARE vdosisAKTIF 		TINYINT(1);
	DECLARE vdosisUSERIN	 	INTEGER(11);
	DECLARE vdosisDTIN		 	DATETIME;
	DECLARE vdosisUSERUP	 	INTEGER(11);
	/**farmasi*/
	DECLARE vsts_pabrik         TINYINT(1);
	DECLARE vid_pabrik_teamterima		INTEGER(11);
	DECLARE vid_pabrik_inventory		INTEGER(11);
	DECLARE vfarmasi  			TEXT;
	DECLARE vfrmKODE 			VARCHAR(15);
	DECLARE vfrmxKODE 			VARCHAR(15);
	DECLARE vfrmBARANG 			VARCHAR(255);
	DECLARE vfrmIDBRND			INTEGER(11);
	DECLARE vfrmIDJNSBRG	 	INTEGER(11);
	DECLARE vfrmIDKLPBRG		INTEGER(11);
	DECLARE vfrmIDKMSBSR 		INTEGER(11);
	DECLARE vfrmIDKMSKCL		INTEGER(11);
	DECLARE vfrmISIKMS			DECIMAL(11,2);
	DECLARE vfrmKMS 			VARCHAR(255);
	DECLARE vfrmIDPBF			INTEGER(11);
	-- DECLARE vfrmIDPABRIK  		INTEGER(11);
	DECLARE vfrmHRGBELI  		DECIMAL(15,2);
	DECLARE vfrmDISKBELI  		DECIMAL(4,2);
	DECLARE vfrmFRMULARS  		TINYINT(1);
	DECLARE vfrmFRMULANAS  		TINYINT(1);
	DECLARE vfrmGENERIK  		TINYINT(1);
	DECLARE vfrmLVSAVING  		TINYINT(1);
	DECLARE vfrmSTSKRONIS  		TINYINT(1);
	DECLARE vfrmMOVING  		VARCHAR(5);
	DECLARE vfrmLEADTM  		INTEGER(11);
	DECLARE vfrmBUFFER  		DECIMAL(10,0);
	DECLARE vfrmZATAKTIF  		TEXT;
	DECLARE vfrmRETRIKSI  		TEXT;
	DECLARE vfrmKET		  		TEXT;
	DECLARE vfrmIDKFA91  		INTEGER(11);
	DECLARE vfrmIDKFA92  		INTEGER(11);
	DECLARE vfrmIDSAKTI  		INTEGER(11);
	DECLARE vfrmIDDOSIS  		INTEGER(11);
	DECLARE vfrmISIDOSIS  		INTEGER(11);
	DECLARE vfrmAKTIF		  	TINYINT(1);
	DECLARE vfrmxSTSPABRIK		TINYINT(1);
	-- DECLARE vfrmUSERIN		  	INTEGER(11);
	-- DECLARE vfrmDTIN		  	DATETIME;
	DECLARE vfrmUSERUP		  	INTEGER(11);
	DECLARE vfrmKATWRN		  	TINYINT(2);
	/**farmasi-pabrik*/
	DECLARE vpabrik  			TEXT;
	DECLARE i 					INTEGER DEFAULT 0;
	DECLARE vid_pabrik			INTEGER(11);
	DECLARE vfrmIDKFA93  		INTEGER(11);
	DECLARE vno_urut			INTEGER(11);
	DECLARE vsts_aktif			INTEGER(11);
	DECLARE vupdated_by			BIGINT(20);
	DECLARE vmaxurut			BIGINT(20);
	DECLARE exit handler for SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SELECT 	20001 as statcode,
                0 as rowcount,
                concat('SYSTEM ERROR : ', @full_error,'') as message;
        ROLLBACK;
	END;

	START TRANSACTION;
		SET aBODY 		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.body'));
		SET aOBJ		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.object'));
		SET aID			= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.id'));
	
		IF (aOBJ = "pabrik") THEN
			SET vpbrkKODE 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vpbrkPABRIK 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.nama_pabrik'));
			SET vpbrkNPWP 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.npwp'));
			SET vpbrkALAMAT 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.alamat'));
			SET vpbrkKOTA	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kota'));
			SET vpbrkKDPOS	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kodepos'));
			SET vpbrkTELP	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.telp'));
			SET vpbrkFAX	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.fax'));
			SET vpbrkEMAIL	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.email'));
			SET vpbrkCPNAME	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.cp_name'));
			SET vpbrkCPTELP	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.cp_telp'));
			SET vpbrkAKTIF	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
			SET vpbrkUSER	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_pabrik 
			SET 	id_teamterima=0, id_inventory=0, kode=vpbrkKODE, nama_pabrik=vpbrkPABRIK, npwp=vpbrkNPWP, alamat=vpbrkALAMAT, kota=vpbrkKOTA, kodepos=vpbrkKDPOS, 
					telp=vpbrkTELP, fax=vpbrkFAX, email=vpbrkEMAIL, cp_name=vpbrkCPNAME, cp_telp=vpbrkCPTELP, sts_aktif=vpbrkAKTIF, userid_updt=vpbrkUSER, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_pabrik WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "kemasan") THEN
			SET vkmsnKODE 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vkmsnKDMED	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode_med'));
			SET vkmsnNAMA 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.nama_kemasan'));
			SET vkmsnAKTIF	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
			SET vkmsnUSER	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_kemasan 
			SET 	kode=vkmsnKODE, id_teamterima=0, id_inventory=0, kode_med=vkmsnKDMED, nama_kemasan=vkmsnNAMA, sts_aktif=vkmsnAKTIF, userid_updt=vkmsnUSER, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_kemasan WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "pbf") THEN
			SET vpbfKODE 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vpbfNAMA	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.nama_pbf'));
			SET vpbfNPWP 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.npwp'));
			SET vpbfALAMAT 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.alamat'));
			SET vpbfKOTA	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kota'));
			SET vpbfKDPOS	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kodepos'));
			SET vpbfTELP	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.telp'));
			SET vpbfFAX	 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.fax'));
			SET vpbfEMAIL	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.email'));
			SET vpbfKPLCABANG	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kepala_cabang'));
			SET vpbfCPNAME	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.cp_name'));
			SET vpbfCPTELP	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.cp_telp'));
			SET vpbfUSER	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 		rsfKatalog.mkatalog_pbf 
				SET 	kode			= vpbfKODE, 		nama_pbf	= vpbfNAMA, 	npwp	= vpbfNPWP, 
						alamat			= vpbfALAMAT, 		kota		= vpbfKOTA, 	kodepos	= vpbfKDPOS, 
						telp			= vpbfTELP, 		fax			= vpbfFAX, 		email	= vpbfEMAIL, 
						kepala_cabang	= vpbfKPLCABANG, 	cp_name		= vpbfCPNAME, 	cp_telp	= vpbfCPTELP, 
						userid_updt		= vpbfUSER, 		sysdate_updt= CURRENT_TIMESTAMP 
				WHERE 	id=aID;
		
			update		rsfTeamterima.masterf_pbf upd,
						rsfKatalog.mkatalog_pbf updReff
				SET 	upd.kode			= vpbfKODE, 		upd.nama_pbf	= vpbfNAMA, 	upd.npwp	= vpbfNPWP, 
						upd.alamat			= vpbfALAMAT, 		upd.kota		= vpbfKOTA, 	upd.kodepos	= vpbfKDPOS, 
						upd.telp			= vpbfTELP, 		upd.fax			= vpbfFAX, 		upd.email	= vpbfEMAIL, 
						upd.kepala_cabang	= vpbfKPLCABANG, 	upd.cp_name		= vpbfCPNAME, 	upd.cp_telp	= vpbfCPTELP, 
						upd.userid_updt		= 9999, 			upd.sysdate_updt= CURRENT_TIMESTAMP 
				WHERE 	upd.id 			= updReff.id_teamterima and
						updReff.id 		= aID;
		
			update		inventory.penyedia upd,
						rsfKatalog.mkatalog_pbf updReff
				SET 	upd.NAMA			= SUBSTR(vpbfNAMA,1,50),
						upd.ALAMAT			= vpbfALAMAT,
						upd.TELEPON			= vpbfTELP,
						upd.FAX				= vpbfFAX,
						upd.TANGGAL 		= CURRENT_TIMESTAMP,
						upd.STATUS 			= 9
				WHERE 	upd.id 			= updReff.id_inventory and
						updReff.id 		= aID;

			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_pbf WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "generik") THEN
			SET vgnrKODE 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vgnrNAMA	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.nama_generik'));
			SET vgnrRESTRIKSI 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.restriksi'));
			SET vgnrUSER	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_generik 
			SET 	id_teamterima=0, id_inventory=0, kode=vgnrKODE, nama_generik=vgnrNAMA, restriksi=vgnrRESTRIKSI, userid_updt=vgnrUSER, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_generik WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "kelompok") THEN
			SET vklpbrgIDINV 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_inventory'));
			SET vklpbrgIDHARCD 		= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_hardcode')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.id_hardcode')));
			SET vklpbrgIDKATSIMG 	= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_kategori_simrsgos')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.id_kategori_simrsgos')));
			SET vklpbrgKODE 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vklpbrgKLPBRG	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kelompok_barang'));
			SET vklpbrgKDTEMP 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode_temp'));
			SET vklpbrgNOURUT 		= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.no_urut')) = '', 0, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.no_urut')));
			SET vklpbrgGOL	 		= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.gol')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.gol')));
			SET vklpbrgBID	 		= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.bid')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.bid')));
			SET vklpbrgKEL	 		= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kel')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.kel')));
			SET vklpbrgSUBKEL	 	= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.subkel')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.subkel')));
			SET vklpbrgSSKEL	 	= IF(JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.subsubkel')) = '', null, JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.subsubkel')));
			SET vklpbrgUSER	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
			SET vklpbrgStsAktf	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
	
			UPDATE 	rsfKatalog.mkatalog_kelompok
			SET 	id_teamterima=0, id_inventory=vklpbrgIDINV, id_hardcode=vklpbrgIDHARCD, id_kategori_simrsgos=vklpbrgIDKATSIMG, kode=vklpbrgKODE, kelompok_barang=vklpbrgKLPBRG, kode_temp=vklpbrgKDTEMP, no_urut=vklpbrgNOURUT, gol=vklpbrgGOL, bid=vklpbrgBID, 
					kel=vklpbrgKEL, subkel=vklpbrgSUBKEL, subsubkel=vklpbrgSSKEL, userid_updt=vklpbrgUSER, sysdate_updt=CURRENT_TIMESTAMP, sts_aktif=vklpbrgStsAktf 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_kelompok WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "brand") THEN
			SET vbrndKODE 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vbrndID	 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_generik'));
			SET vbrndNAMA 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.nama_dagang'));
			SET vbrndUSER	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_brand 
			SET 	id_teamterima=0, id_inventory=0, kode=vbrndKODE, id_generik=vbrndID, nama_dagang=vbrndNAMA, userid_updt=vbrndUSER, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_brand WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "buffer-gudang") THEN
			SET vbffgdngID 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_katalog'));
			SET vbffgdngKODE	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.katalog_kode'));
			SET vbffgdngIDGNR 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_generik'));
			SET vbffgdngJNS	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.jenis_moving'));
			SET vbffgdngLEAD	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.lead_time'));
			SET vbffgdngPERBFF	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.persen_buffer'));
			SET vbffgdngPERLT	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.persen_leadtime'));
			SET vbffgdngJMLAVG	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.jumlah_avg'));
			SET vbffgdngJMLBFF	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.jumlah_buffer'));
			SET vbffgdngJMLLT	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.jumlah_leadtime'));
			SET vbffgdngJMLRP	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.jumlah_rop'));
			SET vbffgdngAKTIF	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.status'));
			SET vbffgdngUSER	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_buffer_gudang 
			SET 	id_katalog=vbffgdngID, katalog_kode=vbffgdngKODE, id_generik=vbffgdngIDGNR, jenis_moving=vbffgdngJNS, lead_time=vbffgdngLEAD, persen_buffer=vbffgdngPERBFF, 
					persen_leadtime=vbffgdngPERLT, jumlah_avg=vbffgdngJMLAVG, jumlah_buffer=vbffgdngJMLBFF, jumlah_leadtime=vbffgdngJMLLT, jumlah_rop=vbffgdngJMLRP, 
					sysdate_updt=CURRENT_TIMESTAMP, userid_updt=vbffgdngUSER, status=vbffgdngAKTIF 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_buffer_gudang WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "jenis-anggaran") THEN
			SET vjnsangKODE 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vjnsangJNS	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.jenis_anggaran'));
			SET vjnsangAKTIF	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
			SET vjnsangUSERIN	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_in'));
			SET vjnsangDTIN		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sysdate_in'));
			SET vjnsangUSERUP	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_anggaranjns 
			SET 	kode=vjnsangKODE, jenis_anggaran=vjnsangJNS, sts_aktif=vjnsangAKTIF, userid_in=vjnsangUSERIN, sysdate_in=vjnsangDTIN, userid_updt=vjnsangUSERUP, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_anggaranjns WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "sub-jenis-anggaran") THEN
			SET vsbjnsangID 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_jenis'));
			SET vsbjnsangTHN 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.thn_aktif'));
			SET vsbjnsangKODE 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vsbjnsangSBJNS	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.subjenis_anggaran'));
			SET vsbjnsangKET	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.keterangan'));
			SET vsbjnsangAKTIF		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
			SET vsbjnsangUSERIN		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_in'));
			SET vsbjnsangDTIN		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sysdate_in'));
			SET vsbjnsangUSERUP		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_anggaranjnssub 
			SET 	id_jenis=vsbjnsangID, thn_aktif=vsbjnsangTHN, kode=vsbjnsangKODE, subjenis_anggaran=vsbjnsangSBJNS, keterangan=vsbjnsangKET, sts_aktif=vsbjnsangAKTIF, 
					userid_in=vsbjnsangUSERIN, sysdate_in=vsbjnsangDTIN, userid_updt=vsbjnsangUSERUP, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_anggaranjnssub WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "sakti") THEN
			SET vsaktiIDHDR 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.id_hdr'));
			SET vsaktiKODE 			= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vsaktiURAIAN 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.uraian'));
			SET vsaktiAKTIF 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
			SET vsaktiUSERIN	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_in'));
			SET vsaktiDTIN	 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sysdate_in'));
			SET vsaktiUSERUP		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_sakti 
			SET 	id_hdr=vsaktiIDHDR, kode=vsaktiKODE, uraian=vsaktiURAIAN, userid_updt=vsaktiUSERUP, sysdate_updt=CURRENT_TIMESTAMP, sysdate_in=vsaktiDTIN, userid_in=vsaktiUSERIN, sts_aktif=vsaktiAKTIF
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_sakti WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "sakti-hdr") THEN
			SET vsaktihdrKODE 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vsaktihdrURAIAN 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.uraian'));
			SET vsaktihdrUSERIN 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_in'));
			SET vsaktihdrDTIN 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sysdate_in'));
			SET vsaktihdrUSERUP	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_sakti_hdr 
			SET 	kode=vsaktihdrKODE, uraian=vsaktihdrURAIAN, userid_updt=vsaktihdrUSERUP, sysdate_updt=CURRENT_TIMESTAMP, sysdate_in=vsaktihdrDTIN, userid_in=vsaktihdrUSERIN 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_sakti_hdr WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "dosis") THEN
			SET vdosisKODE 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vdosisNAMA 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.nama'));
			SET vdosisAKTIF 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sts_aktif'));
			SET vdosisUSERIN 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_in'));
			SET vdosisDTIN	 	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.sysdate_in'));
			SET vdosisUSERUP	= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_updt'));
	
			UPDATE 	rsfKatalog.mkatalog_dosis 
			SET 	kode=vdosisKODE, nama=vdosisNAMA, sts_aktif=vdosisAKTIF, userid_in=vdosisUSERIN, sysdate_in=vdosisDTIN, userid_updt=vdosisUSERUP, sysdate_updt=CURRENT_TIMESTAMP 
			WHERE 	id=aID;
	
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_dosis WHERE id = aID;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, dengan ID "', aID,'" berhasil') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, dengan ID "', aID,'" gagal') as message;
			END IF;
	
		ELSEIF (aOBJ = "farmasi") THEN
			SET vfarmasi 		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.farmasi'));
			SET vfrmKODE		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.kode'));
			SET vfrmBARANG		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.nama_barang'));
			SET vfrmIDBRND		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_brand'));
			SET vfrmIDJNSBRG	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_jenisbarang'));
			SET vfrmIDKLPBRG	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_kelompokbarang'));
			SET vfrmIDKMSBSR	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_kemasanbesar'));
			SET vfrmIDKMSKCL	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_kemasankecil'));
			SET vfrmISIKMS		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.isi_kemasan'));
			SET vfrmKMS			= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.kemasan'));
			SET vfrmIDPBF		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_pbf'));
			-- SET vfrmIDPABRIK	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_pabrik'));
			SET vfrmHRGBELI		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.harga_beli'));
			SET vfrmDISKBELI	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.diskon_beli'));
			SET vfrmFRMULARS	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.formularium_rs'));
			SET vfrmFRMULANAS	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.formularium_nas'));
			SET vfrmGENERIK		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.generik'));
			SET vfrmLVSAVING	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.live_saving'));
			SET vfrmSTSKRONIS	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.sts_kronis'));
			SET vfrmMOVING		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.moving'));
			SET vfrmLEADTM		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.leadtime'));
			SET vfrmBUFFER		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.buffer'));
			SET vfrmZATAKTIF	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.zat_aktif'));
			SET vfrmRETRIKSI	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.retriksi'));
			SET vfrmKET			= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.keterangan'));
			SET vfrmIDKFA91		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_kfa91'));
			SET vfrmIDKFA92		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_kfa92'));
-- 			SET vfrmIDKFA93		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_kfa93'));
			SELECT 	CASE JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_barang_sakti'))
					WHEN 0 THEN NULL WHEN '' THEN NULL ELSE JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_barang_sakti')) END INTO vfrmIDSAKTI;
			SET vfrmIDDOSIS		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.id_dosis'));
			SET vfrmISIDOSIS	= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.isi_dosis'));
			SET vfrmAKTIF		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.aktifasi'));
			-- SET vfrmUSERIN		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.userid_in'));
			-- SET vfrmDTIN		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.sysdate_in'));
			SET vfrmUSERUP		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.userid_updt'));
			SET vfrmKATWRN		= JSON_UNQUOTE(JSON_EXTRACT(vfarmasi, '$.kategori_warna'));
	
			SELECT		sts_pabrik
				INTO	vsts_pabrik
				FROM	rsfKatalog.mkatalog_farmasi
				WHERE	id = aID;
			UPDATE 	rsfKatalog.mkatalog_farmasi 
			SET 	kode=vfrmKODE, nama_sediaan='', nama_barang=vfrmBARANG, id_brand=vfrmIDBRND, id_jenisbarang=vfrmIDJNSBRG, id_kelompokbarang=vfrmIDKLPBRG, id_kemasanbesar=vfrmIDKMSBSR, id_kemasankecil=vfrmIDKMSKCL, 
					isi_kemasan=vfrmISIKMS, 
					-- id_sediaan=0, 
					-- isi_sediaan='', 
					-- jumlah_itembeli=1, 
					-- jumlah_itembonus=0, 
					-- tgl_berlaku_bonus=null, 
					-- tgl_berlaku_bonus_akhir=null, 
					-- id_pabrik=NULL, 
					-- harga_kemasanbeli=0.00, 
					-- harga_jual=0.00, diskon_jual=0.00, stok_adm=0, stok_fisik=0, stok_min=0, stok_opt=0, 
					-- kode_barang_nasional='', sts_frs=0, sts_fornas=0, sts_generik=0, 
					-- sts_livesaving=0, 
					-- sts_produksi=0, sts_konsinyasi=0, sts_ekatalog=0, sts_sumbangan=0, sts_narkotika=0, sts_psikotropika=0, sts_prekursor=0, sts_keras=0, sts_bebas=0, 
					-- sts_bebasterbatas=0, sts_part=0, sts_alat=0, sts_asset=0, sts_aktif=0, sts_hapus=0, optimum=0.00,
					-- jml_max=0, 
					kemasan=vfrmKMS, id_pbf=vfrmIDPBF, harga_beli=vfrmHRGBELI, diskon_beli=vfrmDISKBELI, 
					formularium_rs=vfrmFRMULARS, formularium_nas=vfrmFRMULANAS, generik=vfrmGENERIK, 
					live_saving=vfrmLVSAVING, sts_kronis=vfrmSTSKRONIS, moving=vfrmMOVING, leadtime=vfrmLEADTM, 
					buffer=vfrmBUFFER, 
					zat_aktif=vfrmZATAKTIF, retriksi=vfrmRETRIKSI, keterangan=vfrmKET, aktifasi=vfrmAKTIF, /**userid_in=vfrmUSERIN, sysdate_in=vfrmDTIN,*/ 
					userid_updt=vfrmUSERUP, sysdate_updt=CURRENT_TIMESTAMP, 
					id_kfa91=vfrmIDKFA91, id_kfa92=vfrmIDKFA92, id_kfa93=vfrmIDKFA93, id_barang_sakti=vfrmIDSAKTI, id_dosis=vfrmIDDOSIS, isi_dosis=vfrmISIDOSIS, kategori_warna=vfrmKATWRN
			WHERE 	id=aID;
			
			SELECT ifnull(max(mfb.no_urut),0) INTO vmaxurut FROM rsfKatalog.mkatalog_farmasi_pabrik mfb WHERE mfb.id=aID;
		
			SET vpabrik  		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.pabrik'));
			
			WHILE i < JSON_LENGTH(vpabrik) DO
					SELECT 	JSON_UNQUOTE(JSON_EXTRACT(vpabrik,CONCAT('$[',i,'].id_pabrik'))) INTO vid_pabrik;
					SELECT 	CASE JSON_UNQUOTE(JSON_EXTRACT(vpabrik,CONCAT('$[',i,'].id_kfa93'))) 
							WHEN 0 THEN NULL WHEN '' THEN NULL ELSE JSON_UNQUOTE(JSON_EXTRACT(vpabrik,CONCAT('$[',i,'].id_kfa93'))) END INTO vfrmIDKFA93;
					SELECT 	JSON_UNQUOTE(JSON_EXTRACT(vpabrik,CONCAT('$[',i,'].no_urut'))) INTO vno_urut;
					SELECT 	JSON_UNQUOTE(JSON_EXTRACT(vpabrik,CONCAT('$[',i,'].sts_aktif'))) INTO vsts_aktif;
					SELECT 	JSON_UNQUOTE(JSON_EXTRACT(vpabrik,CONCAT('$[',i,'].updated_by'))) INTO vupdated_by;
		
					IF (vno_urut != 0) THEN
						UPDATE 	rsfKatalog.mkatalog_farmasi_pabrik 
						SET 	id_kfa93=vfrmIDKFA93, no_urut=vno_urut, sts_aktif=vsts_aktif, userid_updt=vupdated_by, sysdate_updt=CURRENT_TIMESTAMP 
						WHERE 	id=aID AND id_pabrik=vid_pabrik;
					ELSE
						SET vmaxurut = vmaxurut+1;
					
						INSERT INTO rsfKatalog.mkatalog_farmasi_pabrik 
							(	id, id_pabrik, id_kfa93, no_urut, sts_aktif, userid_in, sysdate_in, userid_updt, sysdate_updt 	) 
						VALUES
							(	aID, vid_pabrik, vfrmIDKFA93, vmaxurut, vsts_aktif, vupdated_by, CURRENT_TIMESTAMP, vupdated_by, CURRENT_TIMESTAMP 	);
						
						select		id_teamterima, id_inventory 
							into	vid_pabrik_teamterima, vid_pabrik_inventory
							from 	rsfKatalog.mkatalog_pabrik mp where mp.id = vid_pabrik;
						
						IF (vsts_pabrik = 1) THEN
							UPDATE		rsfKatalog.mkatalog_farmasi
								SET		id_pabrik = vid_pabrik
								WHERE	id = aID;
							UPDATE		inventory.barang upd,
										rsfKatalog.mkatalog_farmasi updReff
								SET		upd.PENYEDIA = vid_pabrik_inventory
								WHERE	upd.id = updReff.id_inventory and
										updReff.id = aID;
							UPDATE		rsfTeamterima.masterf_katalog upd,
										rsfKatalog.mkatalog_farmasi updReff
								SET		upd.id_pabrik = vid_pabrik_inventory
								WHERE	upd.id = updReff.id_teamterima and
										updReff.id = aID;
						ELSE
							-- simrsgos
							insert into inventory.barang ( 
										NAMA, KATEGORI, SATUAN, MERK, PENYEDIA, GENERIK, JENIS_GENERIK,
										FORMULARIUM, STOK, HARGA_BELI, PPN, HARGA_JUAL,
										MASA_BERLAKU, JENIS_PENGGUNAAN_OBAT, KLAIM_TERPISAH,
										TANGGAL, OLEH, STATUS,
										KODE_PSEDIA, KODE_BARANG, KODE_PERSEDIAAN, MOVING )
						 	select 		SUBSTR(farmasi.nama_barang,1,150) as NAMA, 
						 				kelompok.id_kategori_simrsgos as KATEGORI, kemasan.id_inventory as SATUAN, 
							 			vid_pabrik_inventory as MERK, pbf.id_inventory as PENYEDIA, 
							 			farmasi.generik as GENERIK,
							 			case farmasi.generik when 1 then 1 else 2 end as JENIS_GENERIK,   -- '1 : GENERIK, 2 : NON GENERIK',
							 			case farmasi.formularium_nas when 1 then 1 else 2 end  as FORMULARIUM,     -- '1 : FORMULARIUM 2: NON FORMULARIUM',
							 			0 as STOK, 0 as HARGA_BELI, 0 as PPN, 0 as HARGA_JUAL, null as MASA_BERLAKU, 0 as JENIS_PENGGUNAAN_OBAT, 0 as KLAIM_TERPISAH,
							 			current_timestamp as TANGGAL, 9999 as OLEH, 1 as STATUS, 
							 			'0' as KODE_PSEDIA, concat(farmasi.kode,'.',vmaxurut+1) as KODE_BARANG, '' as KODE_PERSEDIAAN, null as MOVING
							 	from 	rsfKatalog.mkatalog_farmasi farmasi
							 			left outer join rsfKatalog.mkatalog_kemasan kemasan
							 			on farmasi.id_kemasankecil = kemasan.id
							 			left outer join rsfKatalog.mkatalog_kelompok kelompok
							 			on farmasi.id_kelompokbarang = kelompok.id
							 			left outer join rsfKatalog.mkatalog_pbf pbf
							 	        on farmasi.id_pbf = pbf.id
							 	where	farmasi.id = aID;
							UPDATE 		rsfKatalog.mkatalog_farmasi_pabrik farmasiPabrik, 
										rsfKatalog.mkatalog_farmasi farmasi,
							 			inventory.barang barang
							 	SET		farmasiPabrik.id_inventory 	= barang.id
							 	WHERE   farmasi.kode 				= vfrmKODE and
							 			farmasi.id					= farmasiPabrik.id and
							 			farmasiPabrik.id_pabrik 	= vid_pabrik and
							 			farmasiPabrik.id			= aID and
							 			barang.KODE_BARANG 			= concat(farmasi.kode,'.',vmaxurut+1);
							UPDATE 		rsfKatalog.mkatalog_farmasi farmasi, 
							 			inventory.barang barang
							 	SET		farmasi.id_inventory 		= barang.id
							 	WHERE   farmasi.id					= aID and
							 			barang.KODE_BARANG 			= concat(farmasi.kode,'.',vmaxurut+1);
							-- teamterima
							insert      into rsfTeamterima.masterf_katalog
							 			(	kode, kode_baru2023, nama_sediaan, nama_barang, id_brand, id_jenisbarang, id_kelompokbarang,
							 				id_kemasanbesar, id_kemasankecil, id_sediaan, isi_kemasan, isi_sediaan, 
							 				jumlah_itembeli, jumlah_itembonus, tgl_berlaku_bonus, tgl_berlaku_bonus_akhir,
							 				kemasan, id_pbf, id_pabrik, jenis_barang,
							 				harga_beli, harga_kemasanbeli, diskon_beli, harga_jual, diskon_jual,
							 				stok_adm, stok_fisik, stok_min, stok_opt,
							 				formularium_rs, formularium_nas, generik, live_saving, kode_barang_nasional,
							 				sts_frs, sts_fornas, sts_generik, sts_kronis, sts_livesaving, sts_produksi,
							 				sts_konsinyasi, sts_ekatalog, sts_sumbangan, sts_narkotika, sts_psikotropika,
							 				sts_prekursor, sts_keras, sts_bebas, sts_bebasterbatas, sts_part,
							 				sts_alat, sts_asset, sts_aktif, sts_hapus, moving, leadtime, optimum, buffer,
							 				zat_aktif, retriksi, keterangan, aktifasi, userid_in, sysdate_in, userid_updt, sysdate_updt, jml_max )
							 	select		concat(mk.kode,'.',vmaxurut+1), concat(mk.kode,'.',vmaxurut+1), mk.nama_sediaan, mk.nama_barang,
							 				mk.id_brand, mk.id_jenisbarang, mKatKelompok.id_teamterima as id_kelompokbarang,
							 				mk.id_kemasanbesar, mk.id_kemasankecil, 
							 				mk.id_sediaan, mk.isi_kemasan, mk.isi_sediaan, 
							 				mk.jumlah_itembeli, mk.jumlah_itembonus, mk.tgl_berlaku_bonus, mk.tgl_berlaku_bonus_akhir, 
							 				mk.kemasan, mk.id_pbf, vid_pabrik_teamterima, 'pembelian',
							 				mk.harga_beli, mk.harga_kemasanbeli, mk.diskon_beli, mk.harga_jual, mk.diskon_jual,
							 				mk.stok_adm, mk.stok_fisik, mk.stok_min, mk.stok_opt,
							 				mk.formularium_rs, mk.formularium_nas, mk.generik, mk.live_saving, mk.kode_barang_nasional,
							 				mk.sts_frs, mk.sts_fornas, mk.sts_generik, mk.sts_kronis, mk.sts_livesaving, mk.sts_produksi, 
							 				mk.sts_konsinyasi, mk.sts_ekatalog, mk.sts_sumbangan, mk.sts_narkotika, mk.sts_psikotropika, 
							 				mk.sts_prekursor, mk.sts_keras, mk.sts_bebas, mk.sts_bebasterbatas, mk.sts_part, 
							 				mk.sts_alat, mk.sts_asset, mk.sts_aktif, mk.sts_hapus,
							 				mk.moving, mk.leadtime, mk.optimum, mk.buffer, 
							 				mk.zat_aktif, mk.retriksi, mk.keterangan, mk.aktifasi,
							 				mk.userid_in, mk.sysdate_in, 9999 as userid_updt, mk.sysdate_updt, mk.jml_max
							 	from        rsfKatalog.mkatalog_farmasi mk
							 				left outer join  rsfKatalog.mkatalog_kelompok mKatKelompok
							 				on mKatKelompok.id = mk.id_kelompokbarang 
							 		where	mk.id = aID;
							UPDATE 		rsfKatalog.mkatalog_farmasi_pabrik farmasiPabrik, 
										rsfKatalog.mkatalog_farmasi farmasi,
							 			rsfTeamterima.masterf_katalog barang
							 	SET		farmasiPabrik.id_teamterima	= barang.id
							 	WHERE   farmasi.kode 				= vfrmKODE and
							 			farmasi.id					= farmasiPabrik.id and
							 			farmasiPabrik.id_pabrik 	= vid_pabrik and
							 			farmasiPabrik.id			= aID and
							 			barang.kode 				= concat(farmasi.kode,'.',vmaxurut+1);
							UPDATE 		rsfKatalog.mkatalog_farmasi farmasi, 
							 			rsfTeamterima.masterf_katalog barang
							 	SET		farmasi.id_teamterima		= barang.id
							 	WHERE   farmasi.id 					= aID and
							 			barang.kode 				= concat(farmasi.kode,'.',vmaxurut+1);
						END IF;
					END IF;
				    SET i = i+1;
			END WHILE;
		
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_farmasi WHERE kode = vfrmKODE AND id_brand = vfrmIDBRND AND id_jenisbarang = vfrmIDJNSBRG;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE ', vfrmBARANG,' berhasil.') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE ', vfrmBARANG,' gagal.') as message;
			END IF;

		ELSEIF (aOBJ = "farmasi-kode-katalog") THEN
			SET vfrmKODE		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.kode'));
			SET vfrmUSERUP		= JSON_UNQUOTE(JSON_EXTRACT(aBODY, '$.userid_in'));
			SELECT mf.kode, mf.sts_pabrik  INTO vfrmxKODE, vfrmxSTSPABRIK FROM rsfKatalog.mkatalog_farmasi mf WHERE mf.id = aID;
			UPDATE 		rsfKatalog.mkatalog_farmasi 
				SET 	kode 		= vfrmKODE,
						sts_pabrik 	= 0
				WHERE 	id 			= aID;
			IF (vfrmxSTSPABRIK = 1) THEN
				UPDATE 		rsfTeamterima.masterf_katalog upd,
							rsfKatalog.mkatalog_farmasi updReff
					SET 	upd.kode_baru2023	= vfrmKODE
					WHERE 	upd.id 				= updReff.id_teamterima and
							updReff.id			= aID;
				UPDATE 		inventory.barang upd,
							rsfKatalog.mkatalog_farmasi updReff
					SET 	upd.KODE_BARANG 	= vfrmKODE
					WHERE 	upd.id 				= updReff.id_inventory and
							updReff.id			= aID;
			ELSE
				UPDATE 		rsfTeamterima.masterf_katalog upd,
							rsfKatalog.mkatalog_farmasi_pabrik updReff
					SET 	upd.kode_baru2023	= concat(vfrmKODE,'.',updReff.no_urut)
					WHERE 	upd.id 				= updReff.id_teamterima and
							updReff.id			= aID;
				UPDATE 		inventory.barang upd,
							rsfKatalog.mkatalog_farmasi_pabrik updReff
					SET 	upd.KODE_BARANG 	= concat(vfrmKODE,'.',updReff.no_urut)
					WHERE 	upd.id 				= updReff.id_inventory and
							updReff.id			= aID;
			END IF;
			
			INSERT INTO rsfKatalog.mkatalog_farmasi_kode 
				(	kode, kode_baru, userid_in, sysdate_in 	) 
			VALUES
				(	vfrmxKODE, vfrmKODE, vfrmUSERUP, CURRENT_TIMESTAMP	);
			SELECT COUNT(*) INTO aCOUNT FROM rsfKatalog.mkatalog_farmasi WHERE kode = vfrmKODE;
			IF (aCOUNT > 0) THEN
				SELECT 	0 AS statcode,	
						1 AS rowcount,
						concat('UPDATE, "', vfrmKODE,'" berhasil.') as message;
			ELSE
				SELECT 	20001 as statcode,
		                0 as rowcount,
		                concat('UPDATE, "', vfrmKODE,'" gagal.') as message;
			END IF;
		ELSE 
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('Objek tidak ditemukan') as message,
	                '' as data;
               
		END IF;
	COMMIT;
END