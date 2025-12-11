CREATE DEFINER=`root`@`127.0.0.1` TRIGGER `onBeforeInsertTujuanPasien` BEFORE INSERT ON `tujuan_pasien` FOR EACH ROW BEGIN
		DECLARE VIDANTRIAN MEDIUMINT;
		DECLARE VNORM INT(11);
		
		select		NORM into VNORM
			from	pendaftaran.pendaftaran
			where	NOMOR = NEW.NOPEN;
			
		select 		count(1) into VIDANTRIAN
			from 	pendaftaran.pendaftaran p,
					pendaftaran.tujuan_pasien tp 
			where 	p.NORM 				= VNORM and 
					tp.NOPEN 			= p.NOMOR and
					tp.RUANGAN          = NEW.RUANGAN AND
					tp.STATUS 			!= 0 and
					left(tp.RUANGAN,5) 	= '10101' and
					p.TANGGAL 			> CURDATE();
	
		IF VIDANTRIAN > 0 THEN
			SIGNAL SQLSTATE '45000' set message_text='Nomor RM ini sudah didaftarkan di poli yang sama dan hari yang sama !';
		ELSE
			select 		count(1) into VIDANTRIAN
				from 	pendaftaran.pendaftaran p,
						pendaftaran.tujuan_pasien tp 
				where 	p.NORM 							 = VNORM and 
						tp.NOPEN 						 = p.NOMOR and
						tp.STATUS 						!= 0 and
						left(tp.RUANGAN,5)          	 = '10102' AND
						left(NEW.RUANGAN,5) 	 		 = '10102' and
						p.TANGGAL 						 > CURDATE();
			IF VIDANTRIAN > 0 THEN
				SIGNAL SQLSTATE '45000' set message_text='Nomor RM ini sudah didaftarkan di rawat inap pada hari yang sama !';
			END IF;
		END IF;
	END