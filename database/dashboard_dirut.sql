DROP PROCEDURE IF EXISTS rsfPelaporan.dashboard_dirut;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.dashboard_dirut(
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
		IF (vMethod = "home") THEN
			select		*
				from	(
							select		count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien bayi baru lahir' as judul1,
										'sampai dengan 28 hari tahun 2022' as judul2,
										'pasien28hari' as tautan1,
										'Instalasi' as tautan2,
										'-' as tautan3,
										'-' as tautan4,
										'-' as tautan5
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasien28hari dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm
										) subquery
							UNION ALL
							select		count(1) as jumlah_pasien,
										sum(subquery2.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien anak' as judul1,
										'dirawat di perinatologi dan nicu tahun 2022' as judul2,
										'pasienNicuPicu' as tautan1,
										'Instalasi' as tautan2,
										'-' as tautan3,
										'-' as tautan4,
										'-' as tautan5
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasiennicupicu dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														-- dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm
										) subquery2
							UNION ALL
							select		count(1) as jumlah_pasien,
										sum(subquery3.jumlah_kunjungan) as jumlah_kunjungan,
										CONCAT('Pasien dengan diagnosa ', max(subquery3.penyakit_nama) ) as judul1,
										' tahun 2022' as judul2,
										'pasienDiagnosa' as tautan1,
										'Instalasi' as tautan2,
										max(subquery3.penyakit_nama) as tautan3,
										'-' as tautan4,
										'-' as tautan5
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp,
														max(diags.penyakit_nama) as penyakit_nama
												from 	rsfPelaporan.dashboardes_pasiendiagnosa dashboard,
														rsfMaster.mlokasi_instalasi r,
														rsfMaster.mdiagnosa_penyakit diags
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														dashboard.icd10_kd				 = diags.icd10_kode and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, diags.penyakit_nama
										) subquery3
								group	by  subquery3.penyakit_nama
						) dashboardDirut;
			ELSEIF (vMethod = "dashboardRawatJalan") THEN
				select		deskripsi as uraian,
							count(1)  as jml_pendaftaran
					from	(
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
											tujuandft.RUANGAN		 	 = jkr.ID AND 
											jkr.JENIS				 	 = 5 AND 
											daftar.TANGGAL				>= DATE_ADD(CURRENT_DATE(), INTERVAL 0 DAY) AND
											daftar.TANGGAL				 < DATE_ADD(CURRENT_DATE(), INTERVAL 1 DAY) AND
											daftar.STATUS 				IN (1,2) AND
											left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
									ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
							) dashboardrj
					GROUP	by deskripsi;
			ELSEIF (vMethod = "executiveSummary") THEN
			select		*
				from	(
							select		count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien bayi baru lahir' as judul1,
										'sampai dengan 28 hari tahun 2022' as judul2,
										'pasien28hari' as tautan1,
										'Instalasi' as tautan2,
										'-' as tautan3,
										'-' as tautan4,
										'-' as tautan5
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasien28hari dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm
										) subquery
							UNION ALL
							select		count(1) as jumlah_pasien,
										sum(subquery2.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien anak' as judul1,
										'dirawat di perinatologi dan nicu tahun 2022' as judul2,
										'pasienNicuPicu' as tautan1,
										'Instalasi' as tautan2,
										'-' as tautan3,
										'-' as tautan4,
										'-' as tautan5
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasiennicupicu dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														-- dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm
										) subquery2
							UNION ALL
							select		count(1) as jumlah_pasien,
										sum(subquery3.jumlah_kunjungan) as jumlah_kunjungan,
										CONCAT('Pasien dengan diagnosa ', max(subquery3.penyakit_nama) ) as judul1,
										' tahun 2022' as judul2,
										'pasienDiagnosa' as tautan1,
										'Instalasi' as tautan2,
										max(subquery3.penyakit_nama) as tautan3,
										'-' as tautan4,
										'-' as tautan5
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp,
														max(diags.penyakit_nama) as penyakit_nama
												from 	rsfPelaporan.dashboardes_pasiendiagnosa dashboard,
														rsfMaster.mlokasi_instalasi r,
														rsfMaster.mdiagnosa_penyakit diags
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														dashboard.icd10_kd				 = diags.icd10_kode and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, diags.penyakit_nama
										) subquery3
								group	by  subquery3.penyakit_nama
						) dashboardDirut;
			ELSEIF (vMethod = "pasien28hariInstalasi") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien bayi baru lahir' as judul1,
										'sampai dengan 28 hari tahun 2022' as judul2
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasien28hari dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, r.dashboard_klp
									) subquery
							group   by subquery.instalasi
							order   by subquery.instalasi
						) dashboardDirut;
		ELSEIF (vMethod = "pasien28hariInstalasiCarabayar") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien bayi baru lahir' as judul1,
										'sampai dengan 28 hari tahun 2022' as judul2
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasien28hari dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, r.dashboard_klp, dashboard.kunjungan_carabayar_klp
									) subquery
							group   by subquery.instalasi, subquery.carabayar_klp
							order   by subquery.instalasi, subquery.carabayar_klp
						) dashboardDirut;
		ELSEIF (vMethod = "pasien28hariInstalasiCarabayarKelas") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien bayi baru lahir' as judul1,
										'sampai dengan 28 hari tahun 2022' as judul2
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasien28hari dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      < DATE_ADD(dashboard.pasien_tgllahir, INTERVAL 29 DAY) AND
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, r.dashboard_klp, dashboard.kunjungan_carabayar_klp
									) subquery
							group   by subquery.instalasi, subquery.carabayar_klp, subquery.kelas_nm
							order   by subquery.instalasi, subquery.carabayar_klp, subquery.kelas_nm
						) dashboardDirut;
		ELSEIF (vMethod = "pasienNicuPicuInstalasi") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien anak' as judul1,
										'dirawat di perinatologi dan nicu tahun 2022' as judul2
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasiennicupicu dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, r.dashboard_klp
									) subquery
							group   by subquery.instalasi
							order   by subquery.instalasi
						) dashboardDirut;
		ELSEIF (vMethod = "pasienNicuPicuInstalasiCarabayar") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien anak' as judul1,
										'dirawat di perinatologi dan nicu tahun 2022' as judul2
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasiennicupicu dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, r.dashboard_klp, dashboard.kunjungan_carabayar_klp
									) subquery
							group   by subquery.instalasi, subquery.carabayar_klp
							order   by subquery.instalasi, subquery.carabayar_klp
						) dashboardDirut;
		ELSEIF (vMethod = "pasienNicuPicuInstalasiCarabayarKelas") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										'Pasien anak' as judul1,
										'dirawat di perinatologi dan nicu tahun 2022' as judul2
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp
												from 	rsfPelaporan.dashboardes_pasiennicupicu dashboard,
														rsfMaster.mlokasi_instalasi r
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal      >= '2022-01-01' and 
														dashboard.kunjungan_tanggal       < '2023-01-01'
												group   by dashboard.pasien_norm, r.dashboard_klp, dashboard.kunjungan_carabayar_klp
									) subquery
							group   by subquery.instalasi, subquery.carabayar_klp, subquery.kelas_nm
							order   by subquery.instalasi, subquery.carabayar_klp, subquery.kelas_nm
						) dashboardDirut;
		ELSEIF (vMethod = "pasienDiagnosaInstalasi") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										concat('Pasien dengan diagnosa ', vParm1) as judul1,
										'tahun 2022' as judul2,
										vParm1 as parm1
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp,
														max(diags.penyakit_nama) as penyakit_nama
												from 	rsfPelaporan.dashboardes_pasiendiagnosa dashboard,
														rsfMaster.mlokasi_instalasi r,
														rsfMaster.mdiagnosa_penyakit diags
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														dashboard.icd10_kd				 = diags.icd10_kode and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal     >= '2022-01-01' and 
														dashboard.kunjungan_tanggal      < '2023-01-01' and
														diags.penyakit_nama				 = vParm1
												group   by dashboard.pasien_norm, r.dashboard_klp
									) subquery
							group   by subquery.instalasi
							order   by subquery.instalasi
						) dashboardDirut;
		ELSEIF (vMethod = "pasienDiagnosaInstalasiCarabayar") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										concat('Pasien dengan diagnosa ', vParm1) as judul1,
										'tahun 2022' as judul2,
										vParm1 as parm1
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp,
														max(diags.penyakit_nama) as penyakit_nama
												from 	rsfPelaporan.dashboardes_pasiendiagnosa dashboard,
														rsfMaster.mlokasi_instalasi r,
														rsfMaster.mdiagnosa_penyakit diags
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														dashboard.icd10_kd				 = diags.icd10_kode and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal     >= '2022-01-01' and 
														dashboard.kunjungan_tanggal      < '2023-01-01' and
														diags.penyakit_nama				 = vParm1
												group   by dashboard.pasien_norm, r.dashboard_klp, dashboard.kunjungan_carabayar_klp
									) subquery
							group   by subquery.instalasi, subquery.carabayar_klp
							order   by subquery.instalasi, subquery.carabayar_klp
						) dashboardDirut;
		ELSEIF (vMethod = "pasienDiagnosaInstalasiCarabayarKelas") THEN
			select		*
				from	(
							select		max(subquery.instalasi) as instalasi,
										max(subquery.carabayar_klp) as carabayar_klp,
										max(subquery.kelas_nm) as kelas_nm,
										count(1) as jumlah_pasien,
										sum(subquery.jumlah_kunjungan) as jumlah_kunjungan,
										concat('Pasien dengan diagnosa ', vParm1) as judul1,
										'tahun 2022' as judul2,
										vParm1 as parm1
								from	(
											select 		max(dashboard.pasien_norm) as nomor_rm,
														count(1) as jumlah_kunjungan,
														max(r.dashboard_klp) as instalasi,
														max(dashboard.kunjungan_kelas_nm) as kelas_nm,
														max(dashboard.kunjungan_carabayar_nm) as carabayar_nm,
														max(dashboard.kunjungan_carabayar_klp) as carabayar_klp,
														max(diags.penyakit_nama) as penyakit_nama
												from 	rsfPelaporan.dashboardes_pasiendiagnosa dashboard,
														rsfMaster.mlokasi_instalasi r,
														rsfMaster.mdiagnosa_penyakit diags
												where 	dashboard.kunjungan_instalasi_kd = r.id and
														dashboard.icd10_kd				 = diags.icd10_kode and
														r.dashboard_hitung               = 1 and
														dashboard.kunjungan_tanggal     >= '2022-01-01' and 
														dashboard.kunjungan_tanggal      < '2023-01-01' and
														diags.penyakit_nama				 = vParm1
												group   by dashboard.pasien_norm, r.dashboard_klp, dashboard.kunjungan_carabayar_klp
									) subquery
							group   by subquery.instalasi, subquery.carabayar_klp, subquery.kelas_nm
							order   by subquery.instalasi, subquery.carabayar_klp, subquery.kelas_nm
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
