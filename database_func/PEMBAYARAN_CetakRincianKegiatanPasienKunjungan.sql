DROP PROCEDURE IF EXISTS pembayaran.CetakRincianKegiatanPasienKunjungan;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `pembayaran`.`CetakRincianKegiatanPasienKunjungan`(IN `PKUNJUNGAN` CHAR(19), IN `PSTATUS` TINYINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT * FROM (
		SELECT 2 IDPAKET, ''LUAR PAKET'' PAKET, r.QID,r.TAGIHAN, r.REF_ID, r.RUANGAN, r.LAYANAN, r.JENIS, r.JENIS_RINCIAN, r.TANGGAL, r.JUMLAH, r.TARIF, 
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, pt.TANGGAL TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 w.DESKRIPSI WILAYAH,
			 (SELECT GROUP_CONCAT(master.getNamaLengkapPegawai(mpdok.NIP))
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN) PETUGASMEDIS
		  FROM (', pembayaran.getSkripRincianTagihanKunjungan(PKUNJUNGAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS = 1
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		WHERE r.JENIS !=5
		  AND ppk.ID = i.PPK 
		  AND w.ID = ppk.WILAYAH ) subquery
		');
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
