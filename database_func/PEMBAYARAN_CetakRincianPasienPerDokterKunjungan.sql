DROP PROCEDURE IF EXISTS pembayaran.CetakRincianPasienPerDokterKunjungan;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `pembayaran`.`CetakRincianPasienPerDokterKunjungan`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PSTATUS` TINYINT
)
BEGIN
	DECLARE PTAGIHAN CHAR(10);
	DROP TEMPORARY TABLE IF EXISTS TEMP_HEADER_RINCIAN;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DETIL_RINCIAN;	
	SELECT TAGIHAN INTO PTAGIHAN
		FROM 	pendaftaran.kunjungan pKunj
				left join pembayaran.tagihan_pendaftaran tghDft
				on pKunj.NOPEN = tghDft.PENDAFTARAN and tghDft.STATUS = 1
		WHERE	pKunj.NOMOR = PKUNJUNGAN;

	CREATE TEMPORARY TABLE TEMP_HEADER_RINCIAN ENGINE=MEMORY
		SELECT t.ID NOMOR_TAGIHAN
				 , INST.KOTA, INST.NAMA NAMAINSTANSI, INST.ALAMAT ALAMATINSTANSI, INST.ID IDPPK
				 , INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
				 , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGALREG
				 , `master`.getNamaLengkap(p.NORM) NAMALENGKAP
				 , pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR
				 , p.TANGGAL_LAHIR, CONCAT(CAST(rjk.DESKRIPSI AS CHAR(15)),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') UMUR 
				 , IF(pt.OLEH=0,pt.DESKRIPSI,master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA, t.ID IDTAGIHAN
				 , w.DESKRIPSI WILAYAH
				 , pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN
				 ,  @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN
				 , @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON 
				 , @tedc:=pembayaran.getTotalEDC(t.ID) TOTALEDC 
				 ,  @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN 
				 ,  @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG
				 , @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT
				 , @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI
				 , IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
				 ,(SELECT lpp.TANGGAL FROM layanan.pasien_pulang lpp WHERE lpp.NOPEN = pd.NOMOR AND lpp.CARA IN (1,2,3,4,5,6,7,8) AND lpp.`STATUS` !=0) TGL_PULANG
			
		  FROM pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  		 LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  		 LEFT JOIN pembayaran.tagihan_pendaftaran tp ON tp.TAGIHAN = t.ID AND tp.UTAMA = 1 AND tp.`STATUS` = 1
		  		 LEFT JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = tp.PENDAFTARAN
		  		 LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		       LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS = 1
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		       LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  		, aplikasi.instansi i
			   , master.ppk ppk
			   , master.wilayah w
			   , (SELECT w.DESKRIPSI KOTA, p.NAMA, p.ALAMAT, p.ID
            	FROM aplikasi.instansi ai
              , master.ppk p
              , master.wilayah w
            	WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
			   
		 WHERE t.ID = PTAGIHAN
		   AND t.JENIS = 1
		   AND t.`STATUS` IN (1, 2)
			AND ppk.ID = i.PPK
		   AND w.ID = ppk.WILAYAH;
	  
	CREATE TEMPORARY TABLE TEMP_DETIL_RINCIAN (
		`TAGIHAN` CHAR(10),
		`KUNJUNGAN` VARCHAR(19),
		`RUANGAN` VARCHAR(250),
		`LAYANAN` VARCHAR(100),
		`TANGGAL` DATETIME,
		`JUMLAH` DECIMAL(60,2),
		`TARIF` DECIMAL(60,2),
		`JENIS_KUNJUNGAN` TINYINT(4),
		`DOKTER` VARCHAR(100),
		`DOKTERKEDUA` VARCHAR(100),
		`DOKTERANASTESI` VARCHAR(100),
		`ADMINISTRASI` DECIMAL(60,2),
		`SARANA` DECIMAL(60,2),
		`BHP` DECIMAL(60,2),
		`DOKTER_OPERATOR` DECIMAL(60,2),
		`DOKTER_ANASTESI` DECIMAL(60,2),
		`DOKTER_LAINNYA` DECIMAL(60,2),
		`PENATA_ANASTESI` DECIMAL(60,2),
		`PARAMEDIS` DECIMAL(60,2),
		`NON_MEDIS` DECIMAL(60,2),
		`STATUSTINDAKANRINCIAN` TINYINT(4),
		`LAYANAN1` VARCHAR(250),
		`LAYANAN_OK` VARCHAR(250),
		`TARIF_LAYANAN_OK` VARCHAR(250),
		`RP` VARCHAR(250)
	)
	ENGINE=MEMORY;
	
	INSERT INTO TEMP_DETIL_RINCIAN
		SELECT rt.TAGIHAN,
				kj.NOMOR,
				 CONCAT(
				 	IF(r.JENIS_KUNJUNGAN = 3,
				 		CONCAT(r.DESKRIPSI,' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), 
						IF(NOT r1.DESKRIPSI IS NULL, r1.DESKRIPSI, r2.DESKRIPSI))
				 ) RUANGAN,
				 adm.NAMA LAYANAN,
				 IF(rt.JENIS = 1, 
				 	IF(tadm.ADMINISTRASI = 1, krtp.TANGGAL, 
					 	IF(tadm.ADMINISTRASI = 2, kp.TANGGAL, kj.KELUAR)
					 ), NULL) TANGGAL,
				 rt.JUMLAH, rt.TARIF
				 , IF(r.JENIS_KUNJUNGAN = 3, r.JENIS_KUNJUNGAN, r1.JENIS_KUNJUNGAN) JENIS_KUNJUNGAN
				 , '' DOKTER
			    , '' DOKTERKEDUA
			 	 , '' DOKTERANASTESI
				 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
				 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
				 , 0 STATUSTINDAKANRINCIAN
				 , adm.NAMA LAYANAN1
				 , '' LAYANAN_OK
				 , '' TARIF_LAYANAN_OK
				 , '' RP
		  FROM pembayaran.rincian_tagihan rt
		  	    
		  		 LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rt.REF_ID	
		  		 
		  		 
				 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rt.REF_ID AND rt.JENIS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN AND p.`STATUS`!=0
		  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
		  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
		  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
		  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
		  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
		  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
		  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  		 
		  		 
				 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
		  		 LEFT JOIN `master`.ruangan r2 ON r2.ID = kj.RUANGAN
		 WHERE rt.TAGIHAN = PTAGIHAN
		   AND rt.JENIS = 1 AND rt.STATUS = 1 AND rt.TARIF != 0;
	
	
		   
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN,
			kjgn.NOMOR,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN,
			 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF - IF(rt.PERSENTASE_DISKON = 0, rt.DISKON, rt.TARIF * (rt.DISKON/100)) TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , 0 STATUSTINDAKANRINCIAN
			 , IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2 AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 2 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT * FROM (
	SELECT rt.TAGIHAN, 
			kjgn.NOMOR,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTER
	   	, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERKEDUA
		   , @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERANASTESI
		, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
		, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS
		, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
		, CONCAT(t.NAMA,@dok1) LAYANAN1
		, CONCAT(t.NAMA,'\r',
				SPACE(3),'Jasa dr. Operator ',
				@dok1,'\r',
				SPACE(3),'Jasa dr. Anastesi ',
				@dok3,'\r',
				SPACE(3),'Jasa dr. Asisten ',
				@dok2,'\r',
				SPACE(3),'Jasa Penata Anastesi ','\r'
			) LAYANAN_OK
		, CONCAT(' ','\r',
				REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),',','.'),'\r'
			) TARIF_LAYANAN_OK
		, CONCAT(' ','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.'
			) RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NULL AND rt.STATUS = 1
	 UNION
	 
	 SELECT rt.TAGIHAN, 
			kjgn.NOMOR,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 'Tindakan Keperawatan' LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, SUM(rt.TARIF)
			 , r.JENIS_KUNJUNGAN
			 , @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTER
	   	, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERKEDUA
		   , @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERANASTESI
		, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
		, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS
		, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
		, 'Tindakan Keperawatan' LAYANAN1
		, CONCAT(t.NAMA,'\r',
				SPACE(3),'Jasa dr. Operator ',
				@dok1,'\r',
				SPACE(3),'Jasa dr. Anastesi ',
				@dok3,'\r',
				SPACE(3),'Jasa dr. Asisten ',
				@dok2,'\r',
				SPACE(3),'Jasa Penata Anastesi ','\r'
			) LAYANAN_OK
		, CONCAT(' ','\r',
				REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),',','.'),'\r'
			) TARIF_LAYANAN_OK
		, CONCAT(' ','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.'
			) RP
			
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NOT NULL AND rt.STATUS = 1
	 GROUP BY RUANGAN,LAYANAN) ab
	 ORDER BY JENIS_KUNJUNGAN;
		  	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			kjgn.NOMOR,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , 0 STATUSTINDAKANRINCIAN
			 , b.NAMA LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4 AND f.`STATUS`!=0
	  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 4 AND rt.STATUS = 1;
	   	
	
	
	SELECT *
	  FROM TEMP_HEADER_RINCIAN thr
	       , TEMP_DETIL_RINCIAN tdr
	 WHERE tdr.TAGIHAN = thr.NOMOR_TAGIHAN AND tdr.KUNJUNGAN = PKUNJUNGAN
	 ORDER BY JENIS_KUNJUNGAN, tdr.TANGGAL;	
END$$
DELIMITER ;
