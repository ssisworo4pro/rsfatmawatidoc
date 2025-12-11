-- CREATE DEFINER=`rsflaporan`@`%` PROCEDURE `rsfPelaporan`.`LaporanStatistikAsuransiRawatJalan`(
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanStatistikAsuransiRawatJalan`(
-- CREATE PROCEDURE rsfPelaporan.LaporanStatistikAsuransiRawatJalan(
DROP PROCEDURE IF EXISTS rsfPelaporan.LaporanStatistikAsuransiRawatJalan;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanStatistikAsuransiRawatJalan`(
	IN `TGLAWAL` DATETIME, 
	IN `TGLAKHIR` DATETIME, 
	IN `RUANGAN` CHAR(10), 
	IN `CARABAYAR` INT, 
	IN `DOKTER` INT
)
BEGIN
	/* Rekapitulasi kegiatan Laboratorium */
	DECLARE vRUANGAN VARCHAR(11);
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @sqlText = CONCAT(
		"	
			SELECT 		max(instalasi.DESKRIPSI) as instalasi,
						max(instalasii.DESKRIPSI) as ruangan,
						max(ref.DESKRIPSI) as cara_bayar,
						'15' as label1,
						'16' as label2,
						'17' as label3,
						ifnull(sum(CASE WHEN day(pp.TANGGAL) = 15 THEN 1 ELSE 0 END ),0) as qty_1,
						ifnull(sum(CASE WHEN day(pp.TANGGAL) = 16 THEN 1 ELSE 0 END ),0) as qty_2,
						ifnull(sum(CASE WHEN day(pp.TANGGAL) = 17 THEN 1 ELSE 0 END ),0) as qty_3,
						sum(1) as qty,
						ifnull(sum(CASE WHEN day(pp.TANGGAL) = 15 THEN pt.TOTAL ELSE 0 END ),0) as nilai_1,
						ifnull(sum(CASE WHEN day(pp.TANGGAL) = 16 THEN pt.TOTAL ELSE 0 END ),0) as nilai_2,
						ifnull(sum(CASE WHEN day(pp.TANGGAL) = 17 THEN pt.TOTAL ELSE 0 END ),0) as nilai_3,
						ifnull(sum(pt.TOTAL),0) as nilai
				FROM	pendaftaran.pendaftaran pp
						LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pp.NOMOR
						left join master.ruangan instalasi ON left(tp.RUANGAN,5) = left(instalasi.ID,5) AND instalasi.JENIS = 3
						left join master.ruangan instalasii ON left(tp.RUANGAN,9) = left(instalasii.ID,9) AND instalasii.JENIS = 5
						LEFT JOIN pendaftaran.penjamin penj ON penj.NOPEN = pp.NOMOR
						LEFT JOIN `master`.referensi ref ON ref.ID = penj.JENIS AND ref.JENIS = '10'
						LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON tpp.PENDAFTARAN = pp.NOMOR AND tpp.UTAMA = '1' AND tpp.`STATUS` = '1'
						LEFT JOIN pembayaran.tagihan pt ON pt.ID = tpp.TAGIHAN
				WHERE	tp.`STATUS` = '2'
						AND (	tp.RUANGAN LIKE '10119%' OR
								tp.RUANGAN LIKE '10111%' OR
								tp.RUANGAN LIKE '10117%' OR
								tp.RUANGAN LIKE '10112%' OR
								tp.RUANGAN LIKE '10115%' OR
								tp.RUANGAN LIKE '10125%' OR			
								tp.RUANGAN LIKE '10127%' OR			
								tp.RUANGAN LIKE '10106%' OR 
								tp.RUANGAN LIKE '10101%' OR
								tp.RUANGAN LIKE '10110%' OR
								tp.RUANGAN LIKE '1010802%' OR 
								tp.RUANGAN LIKE '10114%'
						)
						AND pp.TANGGAL >= '",TGLAWAL,"'
						AND pp.TANGGAL  < DATE_ADD('",TGLAKHIR,"', INTERVAL 1 day)
						and penj.JENIS != 1
						and penj.JENIS != 2
						and penj.JENIS != 7
						and penj.JENIS != 8  /*Keringanan Karyawan*/
						and penj.JENIS != 10 /*Keringanan Ref.Lain2*/
				GROUP 	BY 	instalasi.DESKRIPSI, 
							instalasii.DESKRIPSI,
							ref.ID
				ORDER   BY 	instalasi.DESKRIPSI, 
							instalasii.DESKRIPSI,
							ref.ID
		"
	);
	-- call rsfPelaporan.LaporanStatistikAsuransiRawatJalan('2023-09-15','2023-09-17','0','0','0');
	-- IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END //
DELIMITER ;
