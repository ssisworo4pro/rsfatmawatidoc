DELIMITER $$
DROP TRIGGER IF EXISTS onBeforeInsertPendaftaran$$
CREATE TRIGGER onBeforeInsertPendaftaran
    BEFORE INSERT ON pendaftaran FOR EACH ROW
    BEGIN
		DECLARE VIDANTRIAN MEDIUMINT;
		select 		count(1) into VIDANTRIAN
			from 	pendaftaran.pendaftaran p,
					pendaftaran.tujuan_pasien tp 
			where 	p.NORM 				= NEW.NORM and 
					tp.NOPEN 			= p.NOMOR and
					left(tp.RUANGAN,5) 	= '10101' and
					p.TANGGAL 			> CURDATE();
	
		IF VIDANTRIAN > 0 THEN
			SIGNAL SQLSTATE '45000' set message_text='Nomor RM ini sudah didaftarkan di poli yang sama dan hari yang sama !';
		END IF;
	END$$
DELIMITER ;
