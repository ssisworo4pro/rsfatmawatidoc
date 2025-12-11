DROP PROCEDURE IF EXISTS pendaftaran.autoInsertPendaftaranIfpj;
DELIMITER //
CREATE PROCEDURE pendaftaran.autoInsertPendaftaranIfpj(aNorm bigint)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- autoinsert_pendaftaranifpj 																				-- */
	/* -- description   : pendaftaran otomatis ke ifpj untuk pasien meninggal										-- */
	/* -- spesification : 																							-- */
	/* -- sysdateLast 	: 2022-12-12 12:00 																			-- */
	/* -- useridLast  	:  																							-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vNomorPendaftaran varchar(10);

	-- Generate nomor pendaftaran
	INSERT INTO generator.no_pendaftaran (TANGGAL) VALUES (current_date());

	-- Dapatkan nomor pendaftaran terakhir
	select 		CONCAT(DATE_FORMAT((TANGGAL),'%y%m%d'), RIGHT(CONCAT('0000',(NOMOR)),4))
		into 	vNomorPendaftaran 
		from 	generator.no_pendaftaran 
		order 	by tanggal desc, nomor desc limit 1;

	-- insert pendaftaran.pendaftaran
	INSERT INTO pendaftaran.pendaftaran 
			(	NOMOR, NORM, TANGGAL, DIAGNOSA_MASUK, 
				RUJUKAN, PAKET, BERAT_BAYI, PANJANG_BAYI, 
				CITO, RESIKO_JATUH, OLEH, STATUS ) 
		VALUES (vNomorPendaftaran, aNorm, CURRENT_TIMESTAMP, 1, 
				'1', 0, 0, 0, 
				 0, 0, 1, 1);

	-- insert pendaftaran.tujuan_pasien
	INSERT INTO pendaftaran.tujuan_pasien 
			(	NOPEN, RUANGAN, RESERVASI, SMF, DOKTER, IKUT_IBU, KUNJUNGAN_IBU, STATUS) 
		VALUES
			(	vNomorPendaftaran, '101120101', '', 0, 0, 0, '', 1);

END //
DELIMITER ;
