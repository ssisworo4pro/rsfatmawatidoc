CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `medicalrecord`.`CetakMR2`(
	IN `PNOPEN` CHAR(10)
)
BEGIN 	
	SET @nourut=0;
	SET @noobat=0;
	SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR, p.ALAMAT
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
		, rjk.DESKRIPSI JENISKELAMIN
		, rpd.DESKRIPSI PENDIDIKAN
		, rpk.DESKRIPSI PEKERJAAN
		, rag.DESKRIPSI AGAMA
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG, 
		if( pl.`STATUS`=1, DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y %H:%i:%s'),'') TGLKLR
		, pl.TANGGAL TGLKELUAR, cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR
		, ref.DESKRIPSI CARABAYAR, pj.NOMOR SEP, u.DESKRIPSI UNITPELAYANAN
		, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=3) KODEMR1
		, UPPER((master.getDiagnosa(PNOPEN,1))) DIAGNOSAUTAMA, (master.getKodeDiagnosa(PNOPEN,1)) KODEDIAGNOSAUTAMA
		, UPPER((master.getDiagnosaSblm(PNOPEN,1))) DIAGNOSAUTAMA_RAJAL, (master.getKodeDiagnosaSblm(PNOPEN,1)) KODEDIAGNOSAUTAMA_RAJAL
		, (master.getDiagnosa(PNOPEN,2)) DIAGNOSASEKUNDER, (master.getKodeDiagnosa(PNOPEN,2)) KODEDIAGNOSASEKUNDER
		, (master.getDiagnosaSblm(PNOPEN,2)) DIAGNOSASEKUNDER_RAJAL
		, (master.getKodeDiagnosaSblm(PNOPEN,2)) KODEDIAGNOSASEKUNDER_RAJAL
		, (master.getTindakanKodePenyebabKematian(PNOPEN)) DIAGNOSAKODEKEMATIAN
		, (master.getICD9CM(PNOPEN)) TINDAKAN, (master.getKodeICD9CM(PNOPEN)) KODETINDAKAN, (master.getTindakanKodeICD9CM(PNOPEN)) TINDAKAN_KODE
		, (master.getTindakanKodeICD9CMSblm(PNOPEN)) TINDAKAN_KODE_RAJAL
		, vku.VERIFIKATOR VAL_KELUHAN_UTAMA, vku.DESKRIPSI VERIFIKATOR_KELUHAN_UTAMA
		, vrps.VERIFIKATOR VAL_PENYAKIT_SEKARANG, vrps.DESKRIPSI VERIFIKATOR_PENYAKIT_SEKARANG
		, vrpd.VERIFIKATOR VAL_PENYAKIT_DAHULU, vrpd.DESKRIPSI VERIFIKATOR_PENYAKIT_DAHULU
		, vpf.VERIFIKATOR VAL_PEMERIKSAAN_FISIK, vpf.DESKRIPSI VERIFIKATOR_PEMERIKSAAN_FISIK
		, vl.VERIFIKATOR VAL_PEMERIKSAAN_LAB, vl.DESKRIPSI VERIFIKATOR_PEMERIKSAAN_LAB
		, vr.VERIFIKATOR VAL_PEMERIKSAAN_RAD, vr.DESKRIPSI VERIFIKATOR_PEMERIKSAAN_RAD
		, vdu.VERIFIKATOR VAL_DIAGNOSIS_UTAMA, vdu.DESKRIPSI VERIFIKATOR_DIAGNOSIS_UTAMA
		, vds.VERIFIKATOR VAL_DIAGNOSIS_SEKUNDER, vds.DESKRIPSI VERIFIKATOR_DIAGNOSIS_SEKUNDER
		, vo.VERIFIKATOR VAL_OBAT, vo.DESKRIPSI VERIFIKATOR_OBAT
		, vd.VERIFIKATOR VAL_DOKTER, vd.DESKRIPSI VERIFIKATOR_DOKTER
		, vt.VERIFIKATOR VAL_TINDAKAN, vt.DESKRIPSI VERIFIKATOR_TINDAKAN
		, vpk.VERIFIKATOR VAL_PENYEBAB_KEMATIAN, vpk.DESKRIPSI VERIFIKATOR_PENYEBAB_KEMATIAN
		, (SELECT REPLACE 
			(
				REPLACE (
					GROUP_CONCAT(
						CONCAT('(' ,@nourut:=@nourut+1,'). ', master.getNamaLengkapPegawai(mpdok.NIP),'\r','|')),'|,',''),'|','') DOKTEROPERATOR
			FROM 
				medicalrecord.operasi o
				LEFT JOIN master.dokter dok ON o.DOKTER=dok.ID
				LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP, 
				pendaftaran.kunjungan pk
			WHERE 
				o.`STATUS`=1 AND 
				pk.NOMOR=o.KUNJUNGAN AND 
				pk.`STATUS`!=0 AND 
				o.DOKTER!=0 AND 
				pk.NOPEN=PNOPEN
			) DOKTEROPERATOR
		, master.getNamaLengkapPegawai(mpdokdpjp.NIP) DPJP
		, 0 TOTALBIAYA
			, IFNULL(an.DESKRIPSI,
			  (SELECT a.DESKRIPSI 
			   FROM medicalrecord.anamnesis a 
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=a.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND a.`STATUS`!=0
				ORDER BY a.TANGGAL DESC LIMIT 1)) ANAMNESIS
			, (SELECT rp1.DESKRIPSI
				FROM medicalrecord.rpp rp1
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp1.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND rp1.`STATUS`!=0
				ORDER BY rp1.TANGGAL DESC LIMIT 1) RPP
			,	(SELECT ku.DESKRIPSI
				 FROM medicalrecord.keluhan_utama ku
				 LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ku.KUNJUNGAN
				 WHERE pkrp.NOPEN=pd.NOMOR AND ku.`STATUS`!=0
				 ORDER BY ku.TANGGAL DESC LIMIT 1) KELUHANUTAMA
			,	(SELECT mpf.DESKRIPSI
				 FROM medicalrecord.pemeriksaan_fisik mpf
				 LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=mpf.KUNJUNGAN
				 WHERE pkrp.NOPEN=pd.NOMOR AND mpf.`STATUS`!=0
				 ORDER BY mpf.TANGGAL DESC LIMIT 1) FISIK2
			, CONCAT((SELECT(REPLACE(REPLACE(REPLACE(REPLACE
				(pf.DESKRIPSI,'font-family: &quot;Open Sans&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif;','')
				,'Open Sans, Helvetica Neue, Helvetica, ','')
				,'face="open sans"','')
				,'style="font-family:','style="font-face:')))) FISIK 
			, (SELECT `getListRiwayatObat`(PNOPEN, '1')) LISTOBATGANJIL
			, (SELECT `getListRiwayatObat`(PNOPEN, '2')) LISTOBATGENAP					
	   , (SELECT GROUP_CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)) 
				FROM layanan.hasil_lab hlab,
					  layanan.tindakan_medis tm,
					  master.parameter_tindakan_lab ptl
					  LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35,
					  master.tindakan mt
					  LEFT JOIN master.group_tindakan_lab gtl ON mt.ID=gtl.TINDAKAN
					  LEFT JOIN master.group_lab kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.ID
					  LEFT JOIN master.group_lab ggl ON gtl.GROUP_LAB=ggl.ID,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
					  LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON pp.NOMOR=tpp.PENDAFTARAN,
					  pendaftaran.kunjungan pk 
					  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
					  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
					  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
						AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`=1
						AND tpp.TAGIHAN=tpdf.TAGIHAN 
						AND (hlab.HASIL!='' AND hlab.HASIL IS NOT NULL)
						AND pp.`STATUS`!=0 AND pk.`STATUS`!=0 AND r.JENIS_KUNJUNGAN=4
				ORDER BY ggl.ID,ptl.INDEKS) LAB
		,  (SELECT GROUP_CONCAT(t.NAMA,' = ',hrad.HASIL)
					FROM layanan.hasil_rad hrad
						, layanan.tindakan_medis tm
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						, pendaftaran.pendaftaran pp
						, pendaftaran.kunjungan pk 
				WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tm.ID 
					AND pp.NOMOR=pd.NOMOR AND hrad.`STATUS`=1 AND pp.`STATUS`!=0 AND pk.`STATUS`!=0) RAD
		, (SELECT GROUP_CONCAT(t.NAMA,' = ',hrad.KESAN)
					FROM layanan.hasil_rad hrad
						, layanan.tindakan_medis tm
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						, pendaftaran.pendaftaran pp
						  LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON pp.NOMOR=tpp.PENDAFTARAN
						, pendaftaran.kunjungan pk 
				WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tm.ID 
					AND tpp.TAGIHAN=tpdf.TAGIHAN AND hrad.`STATUS`=1 AND pp.`STATUS`!=0 AND pk.`STATUS`!=0) KESAN
		, (SELECT ee1.EDUKASI
				FROM medicalrecord.edukasi_emergency ee1
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ee1.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND ee1.`STATUS`!=0
				ORDER BY ee1.TANGGAL DESC LIMIT 1) EDUKASI
		, (SELECT ee2.KEMBALI_KE_UGD
				FROM medicalrecord.edukasi_emergency ee2
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ee2.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND ee2.`STATUS`!=0
				ORDER BY ee2.TANGGAL DESC LIMIT 1) KEMBALI_KE_UGD
  FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
		  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
		  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
		  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
		  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpdf ON pd.NOMOR=tpdf.PENDAFTARAN AND tpdf.UTAMA=1 AND tpdf.`STATUS`!=0
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pd.NOMOR=pl.NOPEN /*AND pl.`STATUS`=1*/
		  LEFT JOIN master.dokter dokdpjp ON pl.DOKTER=dokdpjp.ID
		  LEFT JOIN master.pegawai mpdokdpjp ON dokdpjp.NIP=mpdokdpjp.NIP
	 	  LEFT JOIN master.referensi cr ON pl.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON pl.KEADAAN=kd.ID AND kd.JENIS=46
		  LEFT JOIN pendaftaran.kunjungan pk ON pl.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
		  LEFT JOIN master.ruangan u ON pk.RUANGAN=u.ID AND u.JENIS=5
		  LEFT JOIN medicalrecord.anamnesis an ON pd.NOMOR=an.PENDAFTARAN AND an.`STATUS`=1
		  LEFT JOIN medicalrecord.rpp rp ON rp.KUNJUNGAN = an.KUNJUNGAN
		  LEFT JOIN medicalrecord.pemeriksaan_fisik pf ON pd.NOMOR=pf.PENDAFTARAN AND pf.`STATUS`=1
		  LEFT JOIN medicalrecord.edukasi_emergency ee ON pk.NOMOR=ee.KUNJUNGAN
		  LEFT JOIN medicalrecord.verifikator_keluhan_utama vku ON pd.NOMOR=vku.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_rps vrps ON vrps.PENDAFTARAN=pd.NOMOR
		  LEFT JOIN medicalrecord.verifikator_rpd vrpd ON pd.NOMOR=vrps.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_diagnosa_utama vdu ON pd.NOMOR=vdu.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_diagnosa_sekunder vds ON pd.NOMOR=vds.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_obat vo ON pd.NOMOR=vo.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_pemeriksaan_fisik vpf ON pd.NOMOR=vpf.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_lab vl ON pd.NOMOR=vl.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_radiologi vr ON pd.NOMOR=vr.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_dokter vd ON pd.NOMOR=vd.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_tindakan vt ON pd.NOMOR=vt.PENDAFTARAN
		  LEFT JOIN medicalrecord.verifikator_penyebab_kematian vpk ON pd.NOMOR=vpk.PENDAFTARAN
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=PNOPEN LIMIT 1;

END