DROP FUNCTION IF EXISTS pembayaran.getSkripRincianTagihanKunjungan;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `pembayaran`.`getSkripRincianTagihanKunjungan`(
	`PKUNJUNGAN` CHAR(19)
) RETURNS varchar(10000) CHARSET latin1
    DETERMINISTIC
BEGIN
	RETURN CONCAT('
	/* Tindakan */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE tm.KUNJUNGAN = ''',PKUNJUNGAN,'''
	   AND rt.JENIS = 3 AND rt.STATUS = 1
	UNION
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
	  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE f.KUNJUNGAN = ''',PKUNJUNGAN,'''
	   AND rt.JENIS = 4 AND rt.STATUS = 1');
END //
DELIMITER ;
