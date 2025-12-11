DELIMITER $$
DROP TRIGGER IF EXISTS onBeforeInsertTagihanPendaftaran$$
CREATE TRIGGER onBeforeInsertTagihanPendaftaran
    BEFORE INSERT ON tagihan_pendaftaran FOR EACH ROW
    BEGIN
		DECLARE VNODAFTAR VARCHAR(10);
		
		IF NEW.UTAMA = 0 THEN
			select		PENDAFTARAN into VNODAFTAR
				from	tagihan_pendaftaran
				where	TAGIHAN = NEW.TAGIHAN AND UTAMA = 1;
						
			IF VNODAFTAR < NEW.PENDAFTARAN THEN
				SIGNAL SQLSTATE '45000' set message_text='Penggabungan gagal. proses penggabungan harus dimulai dari pendaftaran rajal / igd !';
			END IF;
		END IF;
	END$$
DELIMITER ;
