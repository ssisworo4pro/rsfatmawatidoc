SELECT		pasien.NORM as pasien_norm, 
			SUBSTR(kunj.RUANGAN,1,5) as kujungan_instalasi_kd,
			COALESCE(mkelas.deskripsi, '') as kunjungan_kelas_nm,
			case pjamin.carabayar_id when 2 then 'BJPS' else 'NON BPJS' end as kunjungan_carabayar_klp,
			kunj.MASUK as kunjungan_tanggal,
			kunj.KELUAR as kunjungan_selesai,
			mcarabayar.deskripsi as kunjungan_carabayar_nm,
			kunj.RUANGAN as kunjungan_ruangan_id,
			kunj.NOMOR as kunjungan_nomor,
			r.deskripsi as kunjungan_instalasi_nm,
			daftar.NOMOR as pendaftaran_nomor,
			daftar.TANGGAL as pendaftaran_tanggal,
			pasien.TANGGAL_LAHIR as pasien_tgllahir,
			pasien.nama as pasien_nama,
			IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin, 
			DATE_FORMAT(kunj_b.KELUAR,'%d/%m/%Y %H:%i:%s') as kunjungan_tanggal_keluar,
			smf.ID as ksm_id, 
			smf.DESKRIPSI as ksm_nm, 
			concat(pgw.GELAR_DEPAN,'. ',pgw.NAMA,', ', pgw.GELAR_BELAKANG) as ksm_dpjp, 
			mrdiag.KODE as icd10_kd,
			((SELECT 		CONCAT(ms.CODE,'[',ms.STR,']')
					FROM 	master.mrconso ms 
					WHERE 	ms.SAB   = 'ICD10_1998' AND 
							TTY 	IN ('PX', 'PT') AND 
							ms.CODE	 = mrdiag.KODE LIMIT 1)) as icd10_nm,
			IF ( mrdiag.KODE='' OR mrdiag.KODE ='0' ,'Semua', 
				( 	SELECT		CONCAT(ms.CODE,'-',ms.STR)
						FROM 	master.mrconso ms 
						WHERE 	ms.SAB='ICD10_1998' AND
								TTY IN ('PX', 'PT') AND
								ms.CODE=mrdiag.KODE LIMIT 1)) icd10_nm_header
	FROM 	pendaftaran.kunjungan kunj
			left outer join master.ruang_kamar_tidur rkt  on kunj.RUANG_KAMAR_TIDUR = rkt.ID
			left outer join master.ruang_kamar rk on rkt.RUANG_KAMAR = rk.ID
			left outer join ( select * from master.referensi where JENIS = 19 ) mkelas on mkelas.id = rk.KELAS
			LEFT JOIN master.ruangan r ON kunj.RUANGAN=r.ID AND r.JENIS=5
			LEFT JOIN pendaftaran.kunjungan kunj_b ON kunj.NOPEN=kunj_b.NOPEN AND kunj_b.`STATUS` IN (1,2)
			LEFT JOIN master.dokter mdokter on kunj.DPJP = mdokter.ID,
			pendaftaran.pendaftaran daftar
			left outer join ( select pp.NOPEN, MAX(pp.JENIS) as carabayar_id, COUNT(1) as carabayar_qty
									from pendaftaran.penjamin pp, master.referensi mr
									where pp.JENIS = mr.ID and mr.JENIS = 10 group by pp.NOPEN
							) pjamin on pjamin.NOPEN = daftar.NOMOR
			left outer join ( select * from master.referensi where JENIS = 10 ) mcarabayar on mcarabayar.id = pjamin.carabayar_id
			LEFT JOIN master.pasien pasien ON daftar.NORM=pasien.NORM
			LEFT JOIN pendaftaran.penjamin pj ON daftar.NOMOR=pj.NOPEN,
			(	SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID =3 AND jk.JENIS=15 ) jk,
			medicalrecord.diagnosa mrdiag,
			pendaftaran.tujuan_pasien tujPasien,
			(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM 	aplikasi.instansi ai, master.ppk p
					WHERE 	ai.PPK=p.ID ) INST,
			master.pegawai pgw
			LEFT JOIN master.referensi smf ON pgw.SMF=smf.ID AND smf.JENIS=26,
			rsfMaster.mlokasi_instalasi instalasi
	WHERE	kunj.NOPEN					 = mrdiag.NOPEN AND 
			mrdiag.STATUS				 = 1 AND 
			mrdiag.INA_GROUPER			 = 0 AND 
			SUBSTR(kunj.RUANGAN,1,5) 	 = instalasi.id and
			daftar.NOMOR				 = tujPasien.NOPEN AND 
			kunj.RUANGAN				 = tujPasien.RUANGAN AND 
			mdokter.NIP 				 = pgw.NIP AND
			kunj.NOPEN					 = daftar.NOMOR AND
			daftar.TANGGAL 				>= '2022-04-01' AND
			daftar.TANGGAL               < '2023-01-01' AND
			mrdiag.UTAMA				 = '1' AND
			mrdiag.KODE 				in ( select icd10_kode from rsfMaster.mdiagnosa_penyakit )
	GROUP 	BY kunj.NOMOR;
