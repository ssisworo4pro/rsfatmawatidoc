DROP PROCEDURE IF EXISTS rsfPelaporan.dashboard_ranap;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.dashboard_ranap(
	aToken   	TEXT,
	aParam		TEXT
)
BEGIN
	DECLARE	vValid			integer;
	DECLARE	vMethod			varchar(75);
	DECLARE	vErrorMsg		varchar(255);

	DECLARE	vParm1			varchar(75);
	DECLARE	vParm2			varchar(75);
	DECLARE	vParm3			varchar(75);
	DECLARE vTanggalAw      date;
	DECLARE vTanggalAk      date;
	
	SET		vValid = JSON_VALID(aParam);
	IF (vVAlid) THEN
		SET vMethod 	= JSON_EXTRACT(aParam,'$[0].method');
		SET vMethod 	= REPLACE(vMethod,'"','');
		SET vParm1  	= JSON_EXTRACT(aParam,'$[0].parm1');
		SET vParm1 		= REPLACE(vParm1,'"','');
		SET vParm2   	= JSON_EXTRACT(aParam,'$[0].parm2');
		SET vParm2 		= REPLACE(vParm2,'"','');
		SET vParm3		= JSON_EXTRACT(aParam,'$[0].parm3');
		SET vParm3 		= REPLACE(vParm3,'"','');
		
		IF (vParm1 = "H-1") THEN
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL 0 DAY);
		ELSEIF (vParm1 = "H-2") THEN
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY);
		ELSEIF (vParm1 = "H-3") THEN
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL -3 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY);
		ELSEIF (vParm1 = "H") THEN
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL -272 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL -271 DAY);
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL 0 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL 1 DAY);
		ELSE
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL 0 DAY);
		END IF;
		
		IF (vMethod = "home") THEN
			select		*
				from	(
							select		max(instalasi) as instalasi,
										sum(jumlah_kunjungan) as jumlah_kunjungan,
										sum(jumlah_pulang) as jumlah_pulang,
										sum(jumlah_berkasLengkap) as jumlah_berkasLengkap,
										sum(jumlah_berkasKurang) as jumlah_berkasKurang,
										'Dashboard Pendaftaran Rawat Inap' as judul1,
										Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
										'ranap' as parm0,
										'token' as parm1,
										'pendaftaran' as tautan1,
										'Detil' as tautan2,
										'DetilPulang' as tautan2b,
										vParm1 as tautan3,
										max(tautan4) as tautan4,
										max(tautan5) as tautan5
								from	(
											select		instalasi,
														jumlah_kunjungan,
														jumlah_pulang,
														jumlah_berkasLengkap,
														jumlah_berkasKurang,
														judul1,
														judul2,
														parm0,
														parm1,
														tautan1,
														tautan2,
														tautan3,
														tautan4,
														tautan5
												from	(
															select		deskripsi as instalasi,
																		count(1)  as jumlah_kunjungan,
																		0 as jumlah_pulang,
																		0 as jumlah_berkasLengkap,
																		0 as jumlah_berkasKurang,
																		'Dashboard Pendaftaran Rawat Inap' as judul1,
																		Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
																		'ranap' as parm0,
																		'token' as parm1,
																		'pendaftaran' as tautan1,
																		'Detil' as tautan2,
																		vParm1 as tautan3,
																		tautan1 as tautan4,
																		'-' as tautan5
																from	(
																			SELECT		pasien.NORM as pasien_norm, 
																						pasien.NAMA as pasien_nama,
																						left(tujuandft.RUANGAN,7) as tautan1,
																						DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
																						IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
																						IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
																						bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
																						bpjs.kdKelas as bpjs_kelas,
																						daftar.NOMOR as daftar_nomor,
																						DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
																						DATE_FORMAT((SELECT tk.MASUK
																										FROM	pendaftaran.kunjungan tk
																										WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
																						DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																												FROM 	pendaftaran.kunjungan tk
																												WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
																						ref.DESKRIPSI as daftar_carabayar, 
																						stt.DESKRIPSI as daftar_keterangan,
																						IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
																						pjamin.NOMOR as NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
																						r.DESKRIPSI UNITPELAYANAN, 
																						ruanginap.deskripsi as deskripsi,
																						srp.DOKTER,
																						INST.NAMAINST, INST.ALAMATINST 
																				FROM	master.pasien pasien
																						LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
																						pendaftaran.pendaftaran daftar
																						LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
																						LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
																						LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
																						LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
																						LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
																						LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
																						LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
																						LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
																						pendaftaran.tujuan_pasien tujuandft
																						LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
																						LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
																						LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
																						LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
																						LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
																						LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
																						LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
																						(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																								FROM 	aplikasi.instansi ai, master.ppk p
																								WHERE 	ai.PPK=p.ID ) INST
																				WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
																						daftar.NOMOR			 	 = tujuandft.NOPEN AND 
																						daftar.STATUS 				IN (1,2) AND 
																						tujuandft.STATUS 			IN (0,2) AND 
																						tujuandft.RUANGAN		 	 = jkr.ID AND 
																						jkr.JENIS				 	 = 5 AND 
																						daftar.TANGGAL				>= vTanggalAw AND
																						daftar.TANGGAL				 < vTanggalAk AND
																						daftar.STATUS 				IN (1,2) AND
																						left(tujuandft.RUANGAN,5)  	in ('10102')
																				ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
																		) dashboardrj
																GROUP	by deskripsi
														) perInstalasi
											UNION ALL
											select		instalasi,
														jumlah_kunjungan,
														jumlah_pulang,
														jumlah_berkasLengkap,
														jumlah_berkasKurang,
														judul1,
														judul2,
														parm0,
														parm1,
														tautan1,
														tautan2,
														tautan3,
														tautan4,
														tautan5
												from	(
															select		deskripsi as instalasi,
																		0 as jumlah_kunjungan,
																		count(1) as jumlah_pulang,
																		0 as jumlah_berkasLengkap,
																		0 as jumlah_berkasKurang,
																		'Dashboard Pendaftaran Rawat Inap' as judul1,
																		Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
																		'ranap' as parm0,
																		'token' as parm1,
																		'pendaftaran' as tautan1,
																		'DetilPulang' as tautan2,
																		vParm1 as tautan3,
																		tautan1 as tautan4,
																		'-' as tautan5
																from	(
																			SELECT		pasien.NORM as pasien_norm, 
																						pasien.NAMA as pasien_nama,
																						left(kunj.RUANGAN,7) as tautan1,
																						DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
																						IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
																						IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
																						bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
																						bpjs.kdKelas as bpjs_kelas,
																						daftar.NOMOR as daftar_nomor,
																						DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
																						DATE_FORMAT((SELECT tk.MASUK
																										FROM	pendaftaran.kunjungan tk
																										WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
																						DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																												FROM 	pendaftaran.kunjungan tk
																												WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
																						ref.DESKRIPSI as daftar_carabayar, 
																						stt.DESKRIPSI as daftar_keterangan,
																						IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
																						pjamin.NOMOR as NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
																						r.DESKRIPSI UNITPELAYANAN, 
																						ruanginapKunj.deskripsi as deskripsi,
																						srp.DOKTER,
																						INST.NAMAINST, INST.ALAMATINST 
																				FROM	layanan.pasien_pulang pasienPulang,
																						pendaftaran.kunjungan kunj,
																						master.ruangan ruanginapKunj,
																						master.pasien pasien
																						LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
																						pendaftaran.pendaftaran daftar
																						LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
																						LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
																						LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
																						LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
																						LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
																						LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
																						LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
																						LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
																						pendaftaran.tujuan_pasien tujuandft
																						LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
																						LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
																						LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
																						LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
																						LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
																						LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, 
																						master.ruangan jkr  
																						LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
																						(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																								FROM 	aplikasi.instansi ai, master.ppk p
																								WHERE 	ai.PPK=p.ID ) INST
																				WHERE 	kunj.NOMOR					 = pasienPulang.KUNJUNGAN and
																						left(kunj.RUANGAN,7)		 = ruanginapKunj.ID AND 
																						ruanginapKunj.JENIS			 = 4 AND
																						pasienPulang.NOPEN           = daftar.NOMOR and
																						pasien.NORM 			 	 = daftar.NORM AND 
																						daftar.NOMOR			 	 = tujuandft.NOPEN AND 
																						daftar.STATUS 				IN (1,2) AND 
																						tujuandft.STATUS 			IN (0,2) AND 
																						tujuandft.RUANGAN		 	 = jkr.ID AND 
																						jkr.JENIS				 	 = 5 AND 
																						pasienPulang.TANGGAL		>= vTanggalAw AND
																						pasienPulang.TANGGAL		 < vTanggalAk AND
																						pasienPulang.STATUS          = 1 AND
																						left(kunj.RUANGAN,5)  	in ('10102')
																				ORDER 	BY daftar.NOMOR, kunj.RUANGAN
																		) dashboardrj
																GROUP	by deskripsi
														) perInstalasiPulang
										) sqMain
								group 	by	instalasi
							/*
							union all
							select		instalasi,
										jumlah_kunjungan,
										jumlah_berkasLengkap,
										jumlah_berkasKurang,
										judul1,
										judul2,
										parm0,
										parm1,
										tautan1,
										tautan2,
										tautan3,
										tautan4,
										tautan5
								from	(
											select		'BPJS' as instalasi,
														count(1)  as jumlah_kunjungan,
														'-' as jumlah_berkasLengkap,
														'-' as jumlah_berkasKurang,
														'Dashboard Pendaftaran Rawat Jalan' as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'Bpjs' as tautan2,
														vParm1 as tautan3,
														tautan1 as tautan4,
														'-' as tautan5
												from	(
															SELECT		pasien.NORM as pasien_norm, 
																		pasien.NAMA as pasien_nama,
																		left(tujuandft.RUANGAN,5) as tautan1,
																		DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
																		IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
																		IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
																		bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
																		bpjs.kdKelas as bpjs_kelas,
																		daftar.NOMOR as daftar_nomor,
																		DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
																		DATE_FORMAT((SELECT tk.MASUK
																						FROM	pendaftaran.kunjungan tk
																						WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
																		DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																								FROM 	pendaftaran.kunjungan tk
																								WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
																		ref.DESKRIPSI as daftar_carabayar, 
																		stt.DESKRIPSI as daftar_keterangan,
																		IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
																		pjamin.NOMOR as NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
																		r.DESKRIPSI UNITPELAYANAN, 
																		instalasi.deskripsi,
																		srp.DOKTER,
																		INST.NAMAINST, INST.ALAMATINST 
																FROM	master.pasien pasien
																		LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
																		pendaftaran.pendaftaran daftar
																		LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
																		LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
																		LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
																		LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
																		LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
																		LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
																		LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
																		LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
																		pendaftaran.tujuan_pasien tujuandft
																		LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
																		LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
																		LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
																		LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
																		LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
																		LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
																		(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																				FROM 	aplikasi.instansi ai, master.ppk p
																				WHERE 	ai.PPK=p.ID ) INST
																WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
																		daftar.NOMOR			 	 = tujuandft.NOPEN AND 
																		daftar.STATUS 				IN (1,2) AND 
																		tujuandft.STATUS 			IN (0,2) AND 
																		tujuandft.RUANGAN		 	 = jkr.ID AND 
																		jkr.JENIS				 	 = 5 AND 
																		daftar.TANGGAL				>= vTanggalAw AND
																		daftar.TANGGAL				 < vTanggalAk AND
																		daftar.STATUS 				IN (1,2) AND
																		pjamin.JENIS				 = 2 AND
																		left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
																ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
														) dashboardrj
										) khususBpjs
							union all
							select		instalasi,
										jumlah_kunjungan,
										jumlah_berkasLengkap,
										jumlah_berkasKurang,
										judul1,
										judul2,
										parm0,
										parm1,
										tautan1,
										tautan2,
										tautan3,
										tautan4,
										tautan5
								from	(
											select		'SEP Tidak Terbit' as instalasi,
														count(1)  as jumlah_kunjungan,
														'-' as jumlah_berkasLengkap,
														'-' as jumlah_berkasKurang,
														'Dashboard Pendaftaran Rawat Jalan' as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'BpjsSepgagal' as tautan2,
														vParm1 as tautan3,
														tautan1 as tautan4,
														'-' as tautan5
												from	(
															SELECT		pasien.NORM as pasien_norm, 
																		pasien.NAMA as pasien_nama,
																		left(tujuandft.RUANGAN,5) as tautan1,
																		DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
																		IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
																		IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
																		bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
																		bpjs.kdKelas as bpjs_kelas,
																		daftar.NOMOR as daftar_nomor,
																		DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
																		DATE_FORMAT((SELECT tk.MASUK
																						FROM	pendaftaran.kunjungan tk
																						WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
																		DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																								FROM 	pendaftaran.kunjungan tk
																								WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
																		ref.DESKRIPSI as daftar_carabayar, 
																		stt.DESKRIPSI as daftar_keterangan,
																		IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
																		pjamin.NOMOR as daftar_nomorsep, 
																		kap.NOMOR daftar_nomorkartu, 
																		ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
																		r.DESKRIPSI UNITPELAYANAN, 
																		instalasi.deskripsi,
																		srp.DOKTER,
																		INST.NAMAINST, INST.ALAMATINST 
																FROM	master.pasien pasien
																		LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
																		pendaftaran.pendaftaran daftar
																		LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
																		LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
																		LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
																		LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
																		LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
																		LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
																		LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
																		LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
																		pendaftaran.tujuan_pasien tujuandft
																		LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
																		LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
																		LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
																		LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
																		LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
																		LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
																		(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																				FROM 	aplikasi.instansi ai, master.ppk p
																				WHERE 	ai.PPK=p.ID ) INST
																WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
																		daftar.NOMOR			 	 = tujuandft.NOPEN AND 
																		daftar.STATUS 				IN (1,2) AND 
																		tujuandft.STATUS 			IN (0,2) AND 
																		tujuandft.RUANGAN		 	 = jkr.ID AND 
																		jkr.JENIS				 	 = 5 AND 
																		daftar.TANGGAL				>= vTanggalAw AND
																		daftar.TANGGAL				 < vTanggalAk AND
																		daftar.STATUS 				IN (1,2) AND
																		pjamin.JENIS				 = 2 AND
																		left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
																ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
														) dashboardrj
												where	length(daftar_nomorsep) < 19 or daftar_nomorsep like '%K%'
										) khususBpjs2
							*/
						) dashboardDirut;
		ELSEIF (vMethod = "homeChart") THEN
			SET vTanggalAw = DATE_ADD(CURRENT_DATE(), INTERVAL -7 DAY);
			SET vTanggalAk = DATE_ADD(CURRENT_DATE(), INTERVAL 0 DAY);
			select		dataChart,
						Concat('Grafik Pendaftaran Pasien Rawat Inap','') as judul1,
						Concat('dalam 7 hari terakhir ','') as judul2,
						'ranap' as parm0,
						'token' as parm1,
						'pendaftaran' as tautan1,
						'Detil' as tautan2,
						vParm1 as tautan3,
						'-' as tautan4,
						'-' as tautan5
				from	(
			select		JSON_OBJECT(
							'tanggal', JSON_ARRAYAGG(tanggal),
							'jumlah_kunjungan', JSON_ARRAYAGG(jumlah_kunjungan),
							'jumlah_pulang', JSON_ARRAYAGG(jumlah_pulang),
							'jumlah_berkasLengkap', JSON_ARRAYAGG(jumlah_berkasLengkap)
						) as dataChart
				from	(
							select		max(tanggal) as tanggal,
										sum(jumlah_kunjungan) as jumlah_kunjungan,
										sum(jumlah_pulang) as jumlah_pulang,
										sum(jumlah_berkasLengkap) as jumlah_berkasLengkap
								from	(
											select		*
												from	(
															select		daftar_tanggals as tanggal,
																		count(1)  as jumlah_kunjungan,
																		0 as jumlah_berkasLengkap,
																		0 as jumlah_pulang
																from	(
																			SELECT		DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y') daftar_tanggals, 
																						pasien.NORM as pasien_norm, 
																						pasien.NAMA as pasien_nama,
																						left(tujuandft.RUANGAN,5) as tautan1,
																						DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
																						IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
																						IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
																						bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
																						bpjs.kdKelas as bpjs_kelas,
																						daftar.NOMOR as daftar_nomor,
																						DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
																						DATE_FORMAT((SELECT tk.MASUK
																										FROM	pendaftaran.kunjungan tk
																										WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
																						DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																												FROM 	pendaftaran.kunjungan tk
																												WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
																						ref.DESKRIPSI as daftar_carabayar, 
																						stt.DESKRIPSI as daftar_keterangan,
																						IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
																						pjamin.NOMOR as NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
																						r.DESKRIPSI UNITPELAYANAN, 
																						ruanginap.deskripsi as deskripsi,
																						srp.DOKTER,
																						INST.NAMAINST, INST.ALAMATINST 
																				FROM	master.pasien pasien
																						LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
																						pendaftaran.pendaftaran daftar
																						LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
																						LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
																						LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
																						LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
																						LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
																						LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
																						LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
																						LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
																						pendaftaran.tujuan_pasien tujuandft
																						LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
																						LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
																						LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
																						LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
																						LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
																						LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
																						LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
																						(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																								FROM 	aplikasi.instansi ai, master.ppk p
																								WHERE 	ai.PPK=p.ID ) INST
																				WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
																						daftar.NOMOR			 	 = tujuandft.NOPEN AND 
																						daftar.STATUS 				IN (1,2) AND 
																						tujuandft.RUANGAN		 	 = jkr.ID AND 
																						tujuandft.STATUS 			IN (0,2) AND 
																						jkr.JENIS				 	 = 5 AND 
																						pjamin.JENIS				 = 2 AND
																						daftar.TANGGAL				>= vTanggalAw AND
																						daftar.TANGGAL				 < vTanggalAk AND
																						daftar.STATUS 				IN (1,2) AND
																						left(tujuandft.RUANGAN,5)  	in ('10102')
																				ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
																		) dashboardrj
																GROUP	by daftar_tanggals
														) sqMain
											UNION ALL
											select		*
												from	(
															select		daftar_tanggals as tanggal,
																		0 as jumlah_kunjungan,
																		count(1) / 10 * 8 as jumlah_berkasLengkap,
																		count(1) as jumlah_pulang
																from	(
																			SELECT		DATE_FORMAT(pasienPulang.TANGGAL,'%d-%m-%Y') daftar_tanggals, 
																						pasien.NORM as pasien_norm, 
																						pasien.NAMA as pasien_nama,
																						left(tujuandft.RUANGAN,5) as tautan1,
																						DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
																						IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
																						IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
																						bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
																						bpjs.kdKelas as bpjs_kelas,
																						daftar.NOMOR as daftar_nomor,
																						DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
																						DATE_FORMAT((SELECT tk.MASUK
																										FROM	pendaftaran.kunjungan tk
																										WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
																						DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																												FROM 	pendaftaran.kunjungan tk
																												WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
																						ref.DESKRIPSI as daftar_carabayar, 
																						stt.DESKRIPSI as daftar_keterangan,
																						IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
																						pjamin.NOMOR as NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
																						r.DESKRIPSI UNITPELAYANAN, 
																						ruanginapKunj.deskripsi as deskripsi,
																						srp.DOKTER,
																						INST.NAMAINST, INST.ALAMATINST 
																				FROM	layanan.pasien_pulang pasienPulang,
																						pendaftaran.kunjungan kunj
																						LEFT JOIN master.ruangan ruanginapKunj ON left(kunj.RUANGAN,7)=left(ruanginapKunj.ID,7) AND ruanginapKunj.JENIS=4,
																						master.pasien pasien
																						LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
																						pendaftaran.pendaftaran daftar
																						LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
																						LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
																						LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
																						LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
																						LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
																						LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
																						LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
																						LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
																						pendaftaran.tujuan_pasien tujuandft
																						LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
																						LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
																						LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
																						LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
																						LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
																						LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
																						LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
																						(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																								FROM 	aplikasi.instansi ai, master.ppk p
																								WHERE 	ai.PPK=p.ID ) INST
																				WHERE 	kunj.NOMOR					 = pasienPulang.KUNJUNGAN and
																						pasienPulang.NOPEN           = daftar.NOMOR and
																						pasien.NORM 			 	 = daftar.NORM AND 
																						daftar.NOMOR			 	 = tujuandft.NOPEN AND 
																						daftar.STATUS 				IN (1,2) AND 
																						tujuandft.RUANGAN		 	 = jkr.ID AND 
																						tujuandft.STATUS 			IN (0,2) AND 
																						jkr.JENIS				 	 = 5 AND 
																						pjamin.JENIS				 = 2 AND
																						pasienPulang.TANGGAL		>= vTanggalAw AND
																						pasienPulang.TANGGAL		 < vTanggalAk AND
																						pasienPulang.STATUS          = 1 AND
																						left(kunj.RUANGAN,5)  		in ('10102')
																				ORDER 	BY daftar.NOMOR, kunj.RUANGAN
																		) dashboardrj
																GROUP	by daftar_tanggals
														) sqMainPulang
										) perInstalasi
								group	by  tanggal
						) dashboardDirut
						) jsondata;
		ELSEIF (vMethod = "pendaftaranDetil") THEN
			SET @counter = 0;
			select		*
				from	(
											SELECT		@counter := @counter+1 AS row_counter,
														pasien.NORM as pasien_norm, 
														pasien.NAMA as pasien_nama,
														DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
														IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
														IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
														bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
														bpjs.kdKelas as bpjs_kelas,
														daftar.NOMOR as daftar_nomor,
														DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
														DATE_FORMAT((SELECT tk.MASUK
																		FROM	pendaftaran.kunjungan tk
																		WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
														DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																				FROM 	pendaftaran.kunjungan tk
																				WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
														ref.DESKRIPSI as daftar_carabayar, 
														stt.DESKRIPSI as daftar_keterangan,
														IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
														pjamin.NOMOR as daftar_nomorsep, 
														kap.NOMOR as daftar_nomorkartu, 
														r.DESKRIPSI as instalasi_unit, 
														ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
														instalasi.deskripsi instalasi_nama,
														srp.DOKTER,
														INST.NAMAINST, INST.ALAMATINST,
														Concat('Pendaftaran Pasien Masuk ke Ruang ',ruanginap.deskripsi) as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'Detil' as tautan2,
														vParm1 as tautan3,
														'-' as tautan4,
														'-' as tautan5
												FROM	master.pasien pasien
														LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
														pendaftaran.pendaftaran daftar
														LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
														LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
														LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
														LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
														LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
														LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
														LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
														LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
														pendaftaran.tujuan_pasien tujuandft
														LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
														LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
														LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
														LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
														LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
														LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
														LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
														(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																FROM 	aplikasi.instansi ai, master.ppk p
																WHERE 	ai.PPK=p.ID ) INST
												WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
														daftar.NOMOR			 	 = tujuandft.NOPEN AND 
														daftar.STATUS 				IN (1,2) AND 
														tujuandft.STATUS 			IN (0,2) AND 
														tujuandft.RUANGAN		 	 = jkr.ID AND 
														jkr.JENIS				 	 = 5 AND 
														daftar.TANGGAL				>= vTanggalAw AND
														daftar.TANGGAL				 < vTanggalAk AND
														daftar.STATUS 				IN (1,2) AND
														-- left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
														left(tujuandft.RUANGAN,7)  	in (vParm2)
												ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
						) dashboardDirut;
		ELSEIF (vMethod = "pendaftaranDetilPulang") THEN
			SET @counter = 0;
			select		@counter := @counter+1 AS row_counter,
						dashboardDirut.*							
				from	(
											/*SELECT		pasien.NORM as pasien_norm, 
														pasien.NAMA as pasien_nama,
														DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
														IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
														IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
														bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
														bpjs.kdKelas as bpjs_kelas,
														daftar.NOMOR as daftar_nomor,
														DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
														DATE_FORMAT((SELECT tk.MASUK
																		FROM	pendaftaran.kunjungan tk
																		WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
														DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																				FROM 	pendaftaran.kunjungan tk
																				WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
														ref.DESKRIPSI as daftar_carabayar, 
														stt.DESKRIPSI as daftar_keterangan,
														IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
														pjamin.NOMOR as daftar_nomorsep, 
														kap.NOMOR as daftar_nomorkartu, 
														r.DESKRIPSI as instalasi_unit, 
														ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
														instalasi.deskripsi instalasi_nama,
														srp.DOKTER,
														INST.NAMAINST, INST.ALAMATINST,
														Concat('Pasien Pulang Dari Ruang ',ruanginapKunj.deskripsi) as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'DetilPulang' as tautan2,
														vParm1 as tautan3,
														'-' as tautan4,
														'-' as tautan5
												FROM	layanan.pasien_pulang pasienPulang,
														pendaftaran.kunjungan kunj
														LEFT JOIN master.ruangan ruanginapKunj ON left(kunj.RUANGAN,7)=left(ruanginapKunj.ID,7) AND ruanginapKunj.JENIS=4,
														master.pasien pasien
														LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
														pendaftaran.pendaftaran daftar
														LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
														LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
														LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
														LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
														LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
														LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
														LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
														LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
														pendaftaran.tujuan_pasien tujuandft
														LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
														LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
														LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
														LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
														LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
														LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
														LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
														(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																FROM 	aplikasi.instansi ai, master.ppk p
																WHERE 	ai.PPK=p.ID ) INST
												WHERE 	kunj.NOMOR					 = pasienPulang.KUNJUNGAN and
														pasienPulang.NOPEN           = daftar.NOMOR and
														pasien.NORM 			 	 = daftar.NORM AND 
														daftar.NOMOR			 	 = tujuandft.NOPEN AND 
														--daftar.STATUS 				IN (1,2) AND 
														--tujuandft.STATUS 			IN (0,2) AND 
														--tujuandft.RUANGAN		 	 = jkr.ID AND 
														--jkr.JENIS				 	 = 5 AND 
														pasienPulang.TANGGAL		>= vTanggalAw AND
														pasienPulang.TANGGAL		 < vTanggalAk AND
														pasienPulang.STATUS          = 1 AND
														-- left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
														left(kunj.RUANGAN,7)  	in (vParm2)
												ORDER 	BY daftar.NOMOR, kunj.RUANGAN*/
												
											SELECT		pasien.NORM as pasien_norm, 
														pasien.NAMA as pasien_nama,
														DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
														IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
														IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
														bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
														bpjs.kdKelas as bpjs_kelas,
														daftar.NOMOR as daftar_nomor,
														DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
														DATE_FORMAT((SELECT tk.MASUK
																		FROM	pendaftaran.kunjungan tk
																		WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
														DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																				FROM 	pendaftaran.kunjungan tk
																				WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
														ref.DESKRIPSI as daftar_carabayar, 
														stt.DESKRIPSI as daftar_keterangan,
														IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
														pjamin.NOMOR as daftar_nomorsep, 
														kap.NOMOR as daftar_nomorkartu, 
														r.DESKRIPSI as instalasi_unit, 
														ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
														instalasi.deskripsi instalasi_nama,
														ruanginapKunj.deskripsi as deskripsi,
														srp.DOKTER,
														INST.NAMAINST, INST.ALAMATINST,
														Concat('Pasien Pulang Dari Ruang ',ruanginapKunj.deskripsi) as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'DetilPulang' as tautan2,
														vParm1 as tautan3,
														'-' as tautan4,
														'-' as tautan5
												FROM	layanan.pasien_pulang pasienPulang,
														pendaftaran.kunjungan kunj
														LEFT JOIN master.ruangan ruanginapKunj ON left(kunj.RUANGAN,7)=left(ruanginapKunj.ID,7) AND ruanginapKunj.JENIS=4
														LEFT JOIN master.ruangan r ON kunj.RUANGAN=r.ID AND r.JENIS=5,
														master.pasien pasien
														LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
														pendaftaran.pendaftaran daftar
														LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
														LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
														LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
														LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
														LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
														LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
														LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
														LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
														pendaftaran.tujuan_pasien tujuandft
														LEFT JOIN master.ruangan ruanginap ON left(tujuandft.RUANGAN,7)=left(ruanginap.ID,7) AND ruanginap.JENIS=4
														LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND i.JENIS=3
														LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
														LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
														LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, 
														master.ruangan jkr  
														LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
														(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																FROM 	aplikasi.instansi ai, master.ppk p
																WHERE 	ai.PPK=p.ID ) INST
												WHERE 	kunj.NOMOR					 = pasienPulang.KUNJUNGAN and
														pasienPulang.NOPEN           = daftar.NOMOR and
														pasien.NORM 			 	 = daftar.NORM AND 
														daftar.NOMOR			 	 = tujuandft.NOPEN AND 
														daftar.STATUS 				IN (1,2) AND 
														tujuandft.STATUS 			IN (0,2) AND 
														tujuandft.RUANGAN		 	 = jkr.ID AND 
														jkr.JENIS				 	 = 5 AND 
														pasienPulang.TANGGAL		>= vTanggalAw AND
														pasienPulang.TANGGAL		 < vTanggalAk AND
														pasienPulang.STATUS          = 1 AND
														left(kunj.RUANGAN,7)  		in (vParm2)
												ORDER 	BY daftar.NOMOR, kunj.RUANGAN
												
						) dashboardDirut;
		ELSEIF (vMethod = "pendaftaranBpjs") THEN
			SET @counter = 0;
			select		*
				from	(
											SELECT		@counter := @counter+1 AS row_counter,
														pasien.NORM as pasien_norm, 
														pasien.NAMA as pasien_nama,
														DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
														IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
														IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
														bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
														bpjs.kdKelas as bpjs_kelas,
														daftar.NOMOR as daftar_nomor,
														DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
														DATE_FORMAT((SELECT tk.MASUK
																		FROM	pendaftaran.kunjungan tk
																		WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
														DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																				FROM 	pendaftaran.kunjungan tk
																				WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
														ref.DESKRIPSI as daftar_carabayar, 
														stt.DESKRIPSI as daftar_keterangan,
														IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
														pjamin.NOMOR as daftar_nomorsep, 
														kap.NOMOR as daftar_nomorkartu, 
														r.DESKRIPSI as instalasi_unit, 
														ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
														instalasi.deskripsi instalasi_nama,
														srp.DOKTER,
														INST.NAMAINST, INST.ALAMATINST,
														'Daftar Pasien BPJS' as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'Detil' as tautan2,
														vParm1 as tautan3,
														'-' as tautan4,
														'-' as tautan5
												FROM	master.pasien pasien
														LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
														pendaftaran.pendaftaran daftar
														LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
														LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
														LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
														LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
														LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
														LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
														LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
														LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
														pendaftaran.tujuan_pasien tujuandft
														LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
														LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
														LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
														LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
														LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
														LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
														(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																FROM 	aplikasi.instansi ai, master.ppk p
																WHERE 	ai.PPK=p.ID ) INST
												WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
														daftar.NOMOR			 	 = tujuandft.NOPEN AND 
														daftar.STATUS 				IN (1,2) AND 
														tujuandft.RUANGAN		 	 = jkr.ID AND 
														jkr.JENIS				 	 = 5 AND 
														daftar.TANGGAL				>= vTanggalAw AND
														daftar.TANGGAL				 < vTanggalAk AND
														daftar.STATUS 				IN (1,2) AND
														pjamin.JENIS				 = 2 AND
														left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
														-- left(tujuandft.RUANGAN,5)  	in (vParm2)
												ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
						) dashboardDirut;
		ELSEIF (vMethod = "pendaftaranBpjsSepgagal") THEN
			SET @counter = 0;
			select		*
				from	(
											SELECT		@counter := @counter+1 AS row_counter,
														pasien.NORM as pasien_norm, 
														pasien.NAMA as pasien_nama,
														DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
														IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
														IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
														bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
														bpjs.kdKelas as bpjs_kelas,
														daftar.NOMOR as daftar_nomor,
														DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
														DATE_FORMAT((SELECT tk.MASUK
																		FROM	pendaftaran.kunjungan tk
																		WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
														DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
																				FROM 	pendaftaran.kunjungan tk
																				WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
														ref.DESKRIPSI as daftar_carabayar, 
														stt.DESKRIPSI as daftar_keterangan,
														IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
														pjamin.NOMOR as daftar_nomorsep, 
														kap.NOMOR as daftar_nomorkartu, 
														r.DESKRIPSI as instalasi_unit, 
														ppk.NAMA RUJUKAN, i.DESKRIPSI instalasi_desc, 
														instalasi.deskripsi instalasi_nama,
														instalasi.dashboard_nickname instalasi_nickname,
														srp.DOKTER,
														INST.NAMAINST, INST.ALAMATINST,
														'Daftar Pasien BPJS' as judul1,
														Concat('Tanggal ',DATE_FORMAT(vTanggalAw,'%d-%m-%Y')) as judul2,
														'rajal' as parm0,
														'token' as parm1,
														'pendaftaran' as tautan1,
														'Detil' as tautan2,
														vParm1 as tautan3,
														'-' as tautan4,
														'-' as tautan5
												FROM	master.pasien pasien
														LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
														pendaftaran.pendaftaran daftar
														LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
														LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
														LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
														LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
														LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
														LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
														LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
														LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
														pendaftaran.tujuan_pasien tujuandft
														LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
														LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
														LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
														LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
														LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
														LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
														(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
																FROM 	aplikasi.instansi ai, master.ppk p
																WHERE 	ai.PPK=p.ID ) INST
												WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
														daftar.NOMOR			 	 = tujuandft.NOPEN AND 
														daftar.STATUS 				IN (1,2) AND 
														tujuandft.STATUS 			IN (1,2) AND 
														tujuandft.RUANGAN		 	 = jkr.ID AND 
														jkr.JENIS				 	 = 5 AND 
														daftar.TANGGAL				>= vTanggalAw AND
														daftar.TANGGAL				 < vTanggalAk AND
														daftar.STATUS 				IN (1,2) AND
														pjamin.JENIS				 = 2 AND
														(
															length(pjamin.NOMOR) 	 	 < 19 or
															pjamin.NOMOR			like '%K%'
														) AND
														left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
														-- left(tujuandft.RUANGAN,5)  	in (vParm2)
												ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
						) dashboardDirut;
		ELSE
			SET vErrorMsg = CONCAT('invalid method.', vMethod);
			SIGNAL SQLSTATE '30001'
			SET MESSAGE_TEXT = vErrorMsg;
		END IF;
	ELSE
		SIGNAL SQLSTATE '20001'
		SET MESSAGE_TEXT = 'invalid JSON parameter';
	END IF;
END //
DELIMITER ;
