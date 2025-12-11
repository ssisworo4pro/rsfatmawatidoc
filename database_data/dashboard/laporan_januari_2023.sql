laporan 1 - 4 Mei 2023 .....
-------------------------------------------
master :
	insert into mremun_tindakan ( id, jenis, nama, status, remun_grp )
	select 		id, jenis, nama, status, 'visite' as remun_grp
		from 	master.tindakan
		where 	id = 3290;

	alter table rsfMaster.mlokasi_ruangan add remun_klp varchar(50) null;
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI Lt 3 - NICU';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI Lt 3 - NICU Venti';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI Lt 3 - NICU Non Venti';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI  Lt 4  - ICU';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI  Lt 3 - HCU,R.Boarding Kebid';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI  Lt 3  - PICU';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI  Lt 2 - HCU Bedah';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'IRI  Lt 2  - ICCU';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'Anggrek 6 (PICU Tkn Neg Dgn Venti)';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'Anggrek 6 (NICU Tkn Neg Tnp Venti)';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'Anggrek 6 (ICU Tkn Neg Tnp Venti)';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'intensif' where deskripsi = 'Anggrek 6 (ICU Tkn Neg Dgn Venti)';
	select deskripsi from rsfMaster.mlokasi_ruangan where remun_klp = 'intensif';

	update rsfMaster.mlokasi_ruangan set remun_klp = 'penunjang' where  dashboard_klp = 'Instalasi Radiologi Terpadu';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'penunjang' where  dashboard_klp = 'Instalasi Laboratorium';
	select deskripsi from rsfMaster.mlokasi_ruangan where remun_klp = 'penunjang';

	select * from  rsfMaster.mlokasi_ruangan where dashboard_klp = 'RJ Instalasi Rawat Jalan';
	select * from  rsfMaster.mlokasi_ruangan where dashboard_klp = 'Instalasi Rawat Jalan';
	select * from master.ruangan r where id = '10127'
	select * from rsfMaster.mlokasi_ruangan r where substring(id,1,5) = '10127'	
	
	update rsfMaster.mlokasi_ruangan set remun_klp = 'rawatjalan' where  dashboard_klp = 'RJ Instalasi Rawat Jalan';	
	update rsfMaster.mlokasi_ruangan set remun_klp = 'executive'  where  substring(id,1,5) = '10127';
	select deskripsi from rsfMaster.mlokasi_ruangan where remun_klp = 'rawatjalan';
	select deskripsi from rsfMaster.mlokasi_ruangan where remun_klp = 'executive';

	select distinct dashboard_klp from  rsfMaster.mlokasi_ruangan;
	select * from  rsfMaster.mlokasi_ruangan where dashboard_klp = 'Instalasi Bedah Sentral';
	update rsfMaster.mlokasi_ruangan set remun_klp = 'tindakan' where  dashboard_klp = 'Instalasi Bedah Sentral';
	select deskripsi from rsfMaster.mlokasi_ruangan where remun_klp = 'tindakan';


cara bayar :
SELECT		DISTINCT mref2.DESKRIPSI 
	FROM 	layanan.tindakan_medis ltm
			LEFT JOIN pembayaran.rincian_tagihan trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.`STATUS` != 0
			LEFT JOIN `master`.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
			LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = ltm.ID
			LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID AND lptm.JENIS in (1,2)
			LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
			LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
			LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID	
			LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
			LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26',
			master.tindakan mtin,
			pendaftaran.kunjungan pk
			LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
			LEFT JOIN layanan.pasien_pulang ppulang ON pk.NOMOR = ppulang.KUNJUNGAN AND ppulang.STATUS = 1
			LEFT JOIN master.pasien mps ON mps.NORM = pp.NORM
			LEFT JOIN master.referensi mref ON mps.JENIS_KELAMIN = mref.ID AND mref.JENIS = 2
			LEFT JOIN master.ruangan mruang ON mruang.ID = pk.RUANGAN
			LEFT JOIN master.ruangan ir ON ir.ID=LEFT(pk.RUANGAN,5) and ir.JENIS=3
			LEFT JOIN pendaftaran.penjamin pj ON pj.NOPEN = pp.NOMOR
			LEFT JOIN master.referensi mref2 ON pj.JENIS = mref2.ID AND mref2.JENIS = 10
			LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN=pp.NOMOR
			LEFT JOIN master.ruangan ma ON ma.ID=tp.RUANGAN
			LEFT JOIN master.ruangan ins ON ins.ID=LEFT(tp.RUANGAN,5) and ins.JENIS=3
			LEFT JOIN rsfMaster.mlokasi_ruangan miKunjungan ON miKunjungan.id = mruang.ID
	WHERE   pk.STATUS      != 0 and
			pk.MASUK       >= '2023-05-01' and
			pk.MASUK        < '2023-05-05' and
			ltm.KUNJUNGAN   = pk.NOMOR AND
			ltm.STATUS     != 0 and
			mtin.ID         = ltm.TINDAKAN and
			IFNULL( mpeg.NIP, mpg.NIP) is not null

--------------- rincian_tagihan ---------------

SELECT		IFNULL( mpeg.NIP, mpg.NIP) as nipDokter,
			IFNULL( mpeg.NAMA, mpg.NAMA) as NamaDokter,
			ir.DESKRIPSI as Instalasi,
			mruang.DESKRIPSI as Ruangan,
			IFNULL(smf.DESKRIPSI,smf2.DESKRIPSI) as ksm,
			mref2.DESKRIPSI as PendaftaranCarabayar,
			mtin.ID as KegitanID,
			mtin.NAMA as KegiatanJenis,
			if(miKunjungan.remun_klp = 'tindakan', 1, 0) as tindakan,			
			if(miKunjungan.remun_klp = 'intensif', 1, 0) as intensif,
			if(miKunjungan.remun_klp = 'penunjang', 1, 0) as penunjang,
			if(miKunjungan.remun_klp = 'rawatjalan', 1, 0) as rawatjalan,
			if(miKunjungan.remun_klp = 'executive', 1, 0) as executive,
			if(mtindVisite.remun_grp = 'visite', 1, 0) as visite,	
			if(pj.JENIS = 7, 1, 0) as TunaiBedahPrima,	
			if(miKunjungan.remun_klp = 'tindakan', 'tindakan', if(miKunjungan.remun_klp = 'intensif', 'intensif', if(miKunjungan.remun_klp = 'penunjang', 'penunjang', if(miKunjungan.remun_klp = 'rawatjalan', 'rawatjalan', if(miKunjungan.remun_klp = 'executive', 'executive', if(mtindVisite.remun_grp = 'visite', 'visite', '')))))) as kegiatan,			
			(if(pj.JENIS  = 2, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0)) as BPJS_QTY,
			(if(pj.JENIS  = 2, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0)) as BPJS_TARIF,
			-- (if(pj.JENIS != 2 and pj.JENIS != 7, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0)) as NON_BPJS_QTY,
			-- (if(pj.JENIS != 2 and pj.JENIS != 7, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0)) as NON_BPJS_TARIF,
			-- (if(pj.JENIS != 2 and pj.JENIS = 7, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0)) as NON_BPJS_E_QTY,
			-- (if(pj.JENIS != 2 and pj.JENIS = 7, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0)) as NON_BPJS_E_TARIF
			((if(pj.JENIS != 2 and pj.JENIS != 7, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 0, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) as NON_BPJS_QTY,
			((if(pj.JENIS != 2 and pj.JENIS != 7, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 0, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) as NON_BPJS_TARIF,
			((if(pj.JENIS != 2 and pj.JENIS  = 7, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) +
			((if(pj.JENIS != 2 and pj.JENIS != 7, if(miKunjungan.remun_klp = 'executive', 1, 0), 0))) as NON_BPJS_E_QTY,
			((if(pj.JENIS != 2 and pj.JENIS  = 7, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) +
			((if(pj.JENIS != 2 and pj.JENIS != 7, trf.tarif * if(miKunjungan.remun_klp = 'executive', 1, 0), 0))) as NON_BPJS_E_TARIF
	FROM 	layanan.tindakan_medis ltm
			LEFT JOIN pembayaran.rincian_tagihan trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.`STATUS` != 0
			LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
			LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = ltm.ID
			LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID AND lptm.JENIS in (1,2)
			LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
			LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
			LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
			LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
			LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26',
			master.tindakan mtin
			LEFT JOIN rsfMaster.mremun_tindakan mtindVisite on mtin.ID = mtindVisite.ID,
			pendaftaran.kunjungan pk
			LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
			LEFT JOIN layanan.pasien_pulang ppulang ON pk.NOMOR = ppulang.KUNJUNGAN AND ppulang.STATUS = 1
			LEFT JOIN master.pasien mps ON mps.NORM = pp.NORM
			LEFT JOIN master.referensi mref ON mps.JENIS_KELAMIN = mref.ID AND mref.JENIS = 2
			LEFT JOIN master.ruangan mruang ON mruang.ID = pk.RUANGAN
			LEFT JOIN master.ruangan ir ON ir.ID=LEFT(pk.RUANGAN,5) and ir.JENIS=3
			LEFT JOIN pendaftaran.penjamin pj ON pj.NOPEN = pp.NOMOR
			LEFT JOIN master.referensi mref2 ON pj.JENIS = mref2.ID AND mref2.JENIS = 10
			LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN=pp.NOMOR
			LEFT JOIN master.ruangan ma ON ma.ID=tp.RUANGAN
			LEFT JOIN master.ruangan ins ON ins.ID=LEFT(tp.RUANGAN,5) and ins.JENIS=3
			LEFT JOIN rsfMaster.mlokasi_ruangan miKunjungan ON miKunjungan.id = mruang.ID
	WHERE   pk.STATUS      != 0 and
			pk.MASUK       >= '2023-01-01' and
			pk.MASUK        < '2023-02-01' and
			ltm.KUNJUNGAN   = pk.NOMOR AND
			ltm.STATUS     != 0 and
			mtin.ID         = ltm.TINDAKAN and
			IFNULL( mpeg.NIP, mpg.NIP) is not null


SELECT		max(IFNULL( mpeg.NIP, mpg.NIP)) as nipDokter,
			max(IFNULL( mpeg.NAMA, mpg.NAMA)) as NamaDokter,
			max(ir.DESKRIPSI) as Instalasi,
			max(mruang.DESKRIPSI) as Ruangan,
			max(IFNULL(smf.DESKRIPSI,smf2.DESKRIPSI)) as ksm,
			max(if(miKunjungan.remun_klp = 'tindakan', 'tindakan', if(miKunjungan.remun_klp = 'intensif', 'intensif', if(miKunjungan.remun_klp = 'penunjang', 'penunjang', if(miKunjungan.remun_klp = 'rawatjalan', 'rawatjalan', if(miKunjungan.remun_klp = 'executive', 'rawatjalan', if(mtindVisite.remun_grp = 'visite', 'visite', ''))))))) as kegiatan,			
			sum((if(pj.JENIS  = 2, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) as BPJS_QTY,
			sum((if(pj.JENIS  = 2, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) as BPJS_TARIF,
			sum((if(pj.JENIS != 2 and pj.JENIS != 7, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 0, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) as NON_BPJS_QTY,
			sum((if(pj.JENIS != 2 and pj.JENIS != 7, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 0, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) as NON_BPJS_TARIF,
			sum((if(pj.JENIS != 2 and pj.JENIS  = 7, if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) +
			sum((if(pj.JENIS != 2 and pj.JENIS != 7, if(miKunjungan.remun_klp = 'executive', 1, 0), 0))) as NON_BPJS_E_QTY,
			sum((if(pj.JENIS != 2 and pj.JENIS  = 7, trf.tarif * if(miKunjungan.remun_klp = 'tindakan', 1, if(miKunjungan.remun_klp = 'intensif', 1, if(miKunjungan.remun_klp = 'penunjang', 1, if(miKunjungan.remun_klp = 'rawatjalan', 1, if(miKunjungan.remun_klp = 'executive', 1, if(mtindVisite.remun_grp = 'visite', 1, 0)))))), 0))) +
			sum((if(pj.JENIS != 2 and pj.JENIS != 7, trf.tarif * if(miKunjungan.remun_klp = 'executive', 1, 0), 0))) as NON_BPJS_E_TARIF
	FROM 	layanan.tindakan_medis ltm
			LEFT JOIN pembayaran.rincian_tagihan trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.`STATUS` != 0
			LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
			LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = ltm.ID
			LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID AND lptm.JENIS in (1,2)
			LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
			LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
			LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
			LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
			LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26',
			master.tindakan mtin
			LEFT JOIN rsfMaster.mremun_tindakan mtindVisite on mtin.ID = mtindVisite.ID,
			pendaftaran.kunjungan pk
			LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
			LEFT JOIN layanan.pasien_pulang ppulang ON pk.NOMOR = ppulang.KUNJUNGAN AND ppulang.STATUS = 1
			LEFT JOIN master.pasien mps ON mps.NORM = pp.NORM
			LEFT JOIN master.referensi mref ON mps.JENIS_KELAMIN = mref.ID AND mref.JENIS = 2
			LEFT JOIN master.ruangan mruang ON mruang.ID = pk.RUANGAN
			LEFT JOIN master.ruangan ir ON ir.ID=LEFT(pk.RUANGAN,5) and ir.JENIS=3
			LEFT JOIN pendaftaran.penjamin pj ON pj.NOPEN = pp.NOMOR
			LEFT JOIN master.referensi mref2 ON pj.JENIS = mref2.ID AND mref2.JENIS = 10
			LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN=pp.NOMOR
			LEFT JOIN master.ruangan ma ON ma.ID=tp.RUANGAN
			LEFT JOIN master.ruangan ins ON ins.ID=LEFT(tp.RUANGAN,5) and ins.JENIS=3
			LEFT JOIN rsfMaster.mlokasi_ruangan miKunjungan ON miKunjungan.id = mruang.ID
	WHERE   pk.STATUS      != 0 and
			pk.MASUK       >= '2023-01-01' and
			pk.MASUK        < '2023-02-01' and
			ltm.KUNJUNGAN   = pk.NOMOR AND
			ltm.STATUS     != 0 and
			mtin.ID         = ltm.TINDAKAN and
			IFNULL( mpeg.NIP, mpg.NIP) is not null
	GROUP	BY 	if(miKunjungan.remun_klp = 'tindakan', 'tindakan', if(miKunjungan.remun_klp = 'intensif', 'intensif', if(miKunjungan.remun_klp = 'penunjang', 'penunjang', if(miKunjungan.remun_klp = 'rawatjalan', 'rawatjalan', if(miKunjungan.remun_klp = 'executive', 'rawatjalan', if(mtindVisite.remun_grp = 'visite', 'visite', '')))))),
				IFNULL( mpeg.NIP, mpg.NIP)
	having  kegiatan != ''
