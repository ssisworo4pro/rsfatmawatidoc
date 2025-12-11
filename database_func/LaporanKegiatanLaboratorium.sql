-- CREATE DEFINER=`rsflaporan`@`%` PROCEDURE `rsfPelaporan`.`LaporanKegiatanLaboratorium`(
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanKegiatanLaboratorium`(
-- CREATE PROCEDURE rsfPelaporan.LaporanKegiatanLaboratorium(
DROP PROCEDURE IF EXISTS rsfPelaporan.LaporanKegiatanLaboratorium;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanKegiatanLaboratorium`(
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
		"	SELECT		MAX(t.NAMA) as layanan,
						max(t.ID) as ID,
						FORMAT(SUM( IF(tm.STATUS = 0, 0, 1) ),0) as qty,
						FORMAT(max(rsfMaster.getTrfTindNonKelas(tm.TINDAKAN, tm.TANGGAL)),0) as kegiatan_tarif,
						FORMAT(sum(IF(tm.STATUS = 0, 0, 1) * rsfMaster.getTrfTindNonKelas(tm.TINDAKAN, tm.TANGGAL)),0) as total
				FROM	layanan.tindakan_medis tm -- tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.STATUS = 1
						LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
						LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
						LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
						LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
						LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
						LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
						LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
						LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
						LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
						LEFT JOIN layanan.order_lab ol ON kjgn.REF=ol.NOMOR
						LEFT JOIN pendaftaran.kunjungan kuol ON ol.KUNJUNGAN=kuol.NOMOR
						LEFT JOIN `master`.ruang_kamar_tidur rktol ON rktol.ID = kuol.RUANG_KAMAR_TIDUR
						LEFT JOIN `master`.ruang_kamar rkol ON rkol.ID = rktol.RUANG_KAMAR
						LEFT JOIN master.ruangan ruang_asal ON ruang_asal.ID = kuol.RUANGAN 
				WHERE 	kjgn.RUANGAN LIKE '1010701%'
						AND tm.TANGGAL >= '",TGLAWAL,"' 
						AND tm.TANGGAL < DATE_ADD('",TGLAKHIR,"', INTERVAL 1 day)
				GROUP	BY	tm.TINDAKAN
				ORDER   BY  t.NAMA"
	);
	-- call rsfPelaporan.LaporanKegiatanLaboratorium('2023-09-01','2023-09-01','0','0','0');
	-- IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END //
DELIMITER ;


#2
