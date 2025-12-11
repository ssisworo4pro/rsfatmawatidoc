DROP PROCEDURE IF EXISTS rsfPelaporan.remun_pembentukandata;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.remun_pembentukandata(
	aRincianTagihan integer,
	aBulan 			CHAR(6),
	aTglMulai 		CHAR(10),
	aTglAkhir 		CHAR(10)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- remun_pembentukandata																						-- */
	/* -- description   : merekap transaksi menurut kolom-kolom laporan persediaan sesuai settingan master 			-- */
	/* -- spesification : reset jumlah & nilai laporan_mutasi_bulan													-- */
	/* -- sysdateLast 	: 2023-05-22 14:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 15																						-- */
	/* -- revisionNote  :              					 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	-- BPJS       	: 	cara bayar BPJS dan NON GRIYA
	-- NON-BPJS		: 	cara bayar NON BPJS dan NON BEDAH PRIMA dan NON GRIYA +
	--		  			cara bayar BPJS dan GRIYA
	-- NON-BPJS-E	: 	cara bayar BEDAH PRIMA +
    --          		cara bayar NON BPJS dan NON BEDAH PRIMA dan GRIYA

	DECLARE vOounted 		integer;
	DECLARE vID 			BIGINT;
	DECLARE vTanggalAw      date;
	DECLARE vTanggalAk      date;
	
	SET vTanggalAw = DATE_ADD(aTglMulai, INTERVAL 0 DAY);
	SET vTanggalAk = DATE_ADD(aTglAkhir, INTERVAL 1 DAY);
	
	START TRANSACTION;

	-- duplikasi rincian tagihan
	IF (aRincianTagihan = 1) THEN
		truncate table rsfPelaporan.rincian_tagihanx;
		insert into rsfPelaporan.rincian_tagihanx ( TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS )
			select TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS
			from pembayaran.rincian_tagihan
			where JENIS = 3;
		delete from rsfPelaporan.rincian_tagihanx where ID in
			( 	select ID from
				( 
					select min(ID) as ID from rsfPelaporan.rincian_tagihanx
					group by TAGIHAN, REF_ID, JENIS, TARIF_ID
					having count(1) > 1
				) x
			);
	END IF;

	-- header
	select count(1), max(id) into vOounted, vID from tremun_data where tahunbulan = aBulan;
	IF vOounted = 0 THEN 
		insert into tremun_data ( tahunbulan, tgl_awal, tgl_akhir, uraian, proses_sts, proses_sysdate, proses_userid )
		values ( aBulan, aTglMulai, aTglAkhir, 'proses remun', 1, CURRENT_TIMESTAMP, 0);
		SELECT max(id) FROM tremun_data INTO vID;
	END IF;

	-- ISI
	IF vID > 0 THEN

		-- refresh data
		delete from tremun_datarinci_dft where id_remunproses = vID;
		delete from tremun_datarinci where id_remunproses = vID;
		
		-- pemeriksaan dasar
		insert into tremun_datarinci ( 
					id_remunproses, tgl_transaksi, dokter_nip, dokter_nama, dokter_ksm,
					kunj_nomor, kunj_tgl_masuk, kunj_instalasi, kunj_ruang, kunj_ruangan,
					daftar_nomor, daftar_crbyrid, daftar_crbyr, daftar_crbyr_klp, daftar_nomor_sep, daftar_ruangan,
					pasien_nomor, pasien_nama, pasien_jk, pasien_tgllahir,
					kegiatan_id, kegiatan_nama, kegiatan_trfkelas, kegiatan_petugas_jns, kegiatan_petugas_ke,
					kegiatan_petugas_sts, kegiatan_tarif, kegiatan_tarif_lyn, kegiatan_tarif_bhp, kegiatan_tarif_dokter, kegiatan_tarif_griya, kegiatan_skor,
					kegiatan_porsi_remun, 
					rumus_pengali_tarif_baru,
					rumus_porsi_dokter_dari_tarif,
					kegiatan_instalasi_grouping,
					kegiatan_instalasi_kelompok,
					dto_kegiatan_crbyr,
					dto_sts_penunjang, dto_sts_bhp, dto_sts_rawatinap, dto_sts_rawatjalan, dto_sts_executive,
					dto_rawatjalan, dto_visite, dto_penunjang, dto_tindakan, dto_tunaibedahprima, dto_executive,
					dto_kegiatan_klp, 
					dto_bpjs_qty, dto_bpjs_nilai, dto_nbpjs_qty, dto_nbpjs_nilai, dto_nbpjse_qty, dto_nbpjse_nilai,
					sts_hapus, sts_remun, sysdate_in, sysdate_updt )
		SELECT		vID as id_remunproses,
					ltm.TANGGAL as tgl_transaksi,
					IFNULL(mpeg.NIP, mpg.NIP) as dokter_nip,
					IFNULL(mpeg.NAMA, mpg.NAMA) as dokter_nama,
					IFNULL(smf.DESKRIPSI,smf2.DESKRIPSI) as dokter_ksm,
					pk.NOMOR as kunj_nomor,
					pk.MASUK as kunj_tgl_masuk,
					ir.DESKRIPSI as kunj_instalasi,
					mruang.DESKRIPSI as kunj_ruang,
					mruang.ID as kunj_ruangan,
					pp.NOMOR as daftar_nomor,
					pj.JENIS as daftar_crbyrid,
					mref2.DESKRIPSI as daftar_crbyr,
					if(pj.JENIS = 7, 'EXECUTIVE', if(pj.JENIS = 2, 'BPJS', 'NON BPJS')) as daftar_crbyr_klp,
					pj.NOMOR as daftar_nomor_sep,
					tp.RUANGAN as daftar_ruangan,
					pp.NORM as pasien_nomor,
					mps.NAMA as pasien_nama,
					ifnull(mref.DESKRIPSI,'') as pasien_jk,
					mps.TANGGAL_LAHIR as pasien_tgllahir,
					ifnull(mtin.ID, 0) as kegiatan_id,
					mtin.NAMA as kegiatan_nama,
					if(ifnull(mtf.KELAS,'9999') = '', '9999', mtf.KELAS) as kegiatan_trfkelas,
					ifnull(lptm.JENIS, 0) as kegiatan_petugas_jns,
					ifnull(lptm.KE, 1) as kegiatan_petugas_ke,
					ifnull(lptm.STATUS, 1) as kegiatan_petugas_sts,
					rsfMaster.getTrfTind(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif,
					rsfMaster.getTrfTindOPERATOR(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_lyn,
					rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_bhp,
					0 as kegiatan_tarif_dokter,
					0 as kegiatan_tarif_griya,
					mskor.skor as kegiatan_skor,
					0 as kegiatan_porsi_remun,
					0 as rumus_pengali_tarif_baru,
					0 as rumus_porsi_dokter_dari_tarif,
					ifnull(miKunjungan.remun_grouping,'') as kegiatan_instalasi_grouping,
					ifnull(miKunjungan.remun_klp,'') as kegiatan_instalasi_kelompok,
					case pj.JENIS
						when 2 then
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'JKN'
							end
						when 7 then 'EXECUTIVE'
						else
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'REGULER'
							end
					end as dto_kegiatan_crbyr,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 1, 0) as dto_sts_penunjang,
					if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 1, 0) as dto_sts_bhp,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 1, 0) as dto_sts_rawatinap,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 1, 0) as dto_sts_rawatjalan,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_sts_executive,
					9 as dto_rawatjalan,
					9 as dto_visite,
					9 as dto_penunjang,
					9 as dto_tindakan,
					if(pj.JENIS = 7, 1, 0) as dto_tunaibedahprima,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_executive,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 'penunjang', 
						if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 'tindakan', 
							if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 'visite', 
								if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 'rawatjalan', if(ifnull(miKunjungan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))) as dto_kegiatan_klp,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) as dto_bpjs_qty,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) as dto_bpjs_nilai,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjs_qty,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjs_nilai,
					if(pj.JENIS  = 7, 1, 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjse_qty,					
					if(pj.JENIS  = 7, ifnull(trf.tarif,0), 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjse_nilai,
					0 as sts_hapus,
					0 as sts_remun,
					CURRENT_TIMESTAMP() as sysdate_in,
					CURRENT_TIMESTAMP() as sysdate_updt
			FROM 	layanan.tindakan_medis ltm
					LEFT JOIN rsfPelaporan.rincian_tagihanx trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
					LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
					LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = ltm.ID and lptm.STATUS != 0 AND lptm.JENIS in (1,2)
					LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID
					LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
					LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
					LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
					LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
					LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26'			
					LEFT JOIN master.tindakan mtin ON mtin.ID = ltm.TINDAKAN
					LEFT JOIN rsfMaster.mremun_skor_smf mskor ON mskor.KODE = mtin.ID AND mskor.kode_smf = IFNULL(smf.ID,smf2.ID)
					LEFT JOIN rsfMaster.mremun_tindakan mtindVisite ON mtin.ID = mtindVisite.ID
					LEFT JOIN pendaftaran.kunjungan pk ON ltm.KUNJUNGAN = pk.NOMOR and pk.STATUS != 0
					LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN and pp.STATUS != 0
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
			WHERE   ltm.TANGGAL     		>= vTanggalAw and
					ltm.TANGGAL      	 	 < vTanggalAk and
					ltm.STATUS      		!= 0 and
					pp.STATUS 				!= 0 and
					pk.STATUS               != 0 and
					LEFT(mruang.ID,5)		!= 10107 and
					LEFT(mruang.ID,5)	    != 10113 and
					LEFT(mruang.ID,7)		!= 1010801 and
					mruang.ID				!= 101190201 and
					pj.JENIS				is not null and
					mtin.ID					is not null and
					IFNULL( mpeg.NIP, mpg.NIP) is not null;

		-- pemeriksaan kinerja_dokter_lab
		insert into tremun_datarinci ( 
					id_remunproses, tgl_transaksi, dokter_nip, dokter_nama, dokter_ksm,
					kunj_nomor, kunj_tgl_masuk, kunj_instalasi, kunj_ruang, kunj_ruangan,
					daftar_nomor, daftar_crbyrid, daftar_crbyr, daftar_crbyr_klp, daftar_nomor_sep, daftar_ruangan,
					pasien_nomor, pasien_nama, pasien_jk, pasien_tgllahir,
					kegiatan_id, kegiatan_nama, kegiatan_trfkelas, kegiatan_petugas_jns, kegiatan_petugas_ke,
					kegiatan_petugas_sts, kegiatan_tarif, kegiatan_tarif_lyn, kegiatan_tarif_bhp, kegiatan_tarif_dokter, kegiatan_tarif_griya, kegiatan_skor,
					kegiatan_porsi_remun, 
					rumus_pengali_tarif_baru,
					rumus_porsi_dokter_dari_tarif,
					kegiatan_instalasi_grouping,
					kegiatan_instalasi_kelompok,
					dto_kegiatan_crbyr,
					dto_sts_penunjang, dto_sts_bhp, dto_sts_rawatinap, dto_sts_rawatjalan, dto_sts_executive,
					dto_rawatjalan, dto_visite, dto_penunjang, dto_tindakan, dto_tunaibedahprima, dto_executive,
					dto_kegiatan_klp, dto_bpjs_qty, dto_bpjs_nilai, dto_nbpjs_qty, dto_nbpjs_nilai, dto_nbpjse_qty, dto_nbpjse_nilai,
					sts_hapus, sts_remun, sysdate_in, sysdate_updt )
		SELECT		vID as id_remunproses,
					kl.tgl_hasil as tgl_transaksi,
					kl.kd_pelaksana as dokter_nip,
					kl.nama_dokter as dokter_nama,
					'-- LAB / PATOLOGI --' as dokter_ksm,
					pk.NOMOR as kunj_nomor,
					pk.MASUK as kunj_tgl_masuk,
					ir.DESKRIPSI as kunj_instalasi,
					mruang.DESKRIPSI as kunj_ruang,
					mruang.ID as kunj_ruangan,
					pp.NOMOR as daftar_nomor,
					pj.JENIS as daftar_crbyrid,
					mref2.DESKRIPSI as daftar_crbyr,
					if(pj.JENIS = 7, 'EXECUTIVE', if(pj.JENIS = 2, 'BPJS', 'NON BPJS')) as daftar_crbyr_klp,
					pj.NOMOR as daftar_nomor_sep,
					tp.RUANGAN as daftar_ruangan,
					pp.NORM as pasien_nomor,
					mps.NAMA as pasien_nama,
					ifnull(mref.DESKRIPSI,'') as pasien_jk,
					mps.TANGGAL_LAHIR as pasien_tgllahir,
					ifnull(mtin.ID, 0) as kegiatan_id,
					mtin.NAMA as kegiatan_nama,
					if(ifnull(mtf.KELAS,'9999') = '', '9999', mtf.KELAS) as kegiatan_trfkelas,
					ifnull(lptm.JENIS, 0) as kegiatan_petugas_jns,
					ifnull(lptm.KE, 1) as kegiatan_petugas_ke,
					ifnull(lptm.STATUS, 1) as kegiatan_petugas_sts,
					rsfMaster.getTrfTind(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif,
					rsfMaster.getTrfTindOPERATOR(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_lyn,
					rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_bhp,
					0 as kegiatan_tarif_dokter,
					0 as kegiatan_tarif_griya,
					mskor.skor as kegiatan_skor,
					0 as kegiatan_porsi_remun,
					0 as rumus_pengali_tarif_baru,
					0 as rumus_porsi_dokter_dari_tarif,
					ifnull(miKunjungan.remun_grouping,'') as kegiatan_instalasi_grouping,
					ifnull(miKunjungan.remun_klp,'') as kegiatan_instalasi_kelompok,
					case pj.JENIS
						when 2 then
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'JKN'
							end
						when 7 then 'EXECUTIVE'
						else
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'REGULER'
							end
					end as dto_kegiatan_crbyr,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 1, 0) as dto_sts_penunjang,
					if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 1, 0) as dto_sts_bhp,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 1, 0) as dto_sts_rawatinap,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 1, 0) as dto_sts_rawatjalan,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_sts_executive,
					9 as dto_rawatjalan,
					9 as dto_visite,
					9 as dto_penunjang,
					9 as dto_tindakan,
					if(pj.JENIS = 7, 1, 0) as dto_tunaibedahprima,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_executive,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 'penunjang', 
						if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 'tindakan', 
							if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 'visite', 
								if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 'rawatjalan', if(ifnull(miKunjungan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))) as dto_kegiatan_klp,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) as dto_bpjs_qty,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) as dto_bpjs_nilai,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjs_qty,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjs_nilai,
					if(pj.JENIS  = 7, 1, 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjse_qty,					
					if(pj.JENIS  = 7, ifnull(trf.tarif,0), 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjse_nilai,
					0 as sts_hapus,
					0 as sts_remun,
					CURRENT_TIMESTAMP() as sysdate_in,
					CURRENT_TIMESTAMP() as sysdate_updt
			from 	lis_bridging.kinerja_dokter_lab kl
					LEFT JOIN layanan.tindakan_medis ltm ON ltm.TINDAKAN = kl.kd_tindakan_periksa and ltm.TANGGAL = kl.tgl_tindakan
					LEFT JOIN rsfPelaporan.rincian_tagihanx trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
					LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
					LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = ltm.ID and lptm.STATUS != 0 AND lptm.JENIS in (1,2)
					LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID
					LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
					LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
					LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
					LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
					LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26'			
					LEFT JOIN master.tindakan mtin ON mtin.ID = ltm.TINDAKAN
					LEFT JOIN rsfMaster.mremun_skor_smf mskor ON mskor.KODE = mtin.ID AND mskor.kode_smf = IFNULL(smf.ID,smf2.ID)
					LEFT JOIN rsfMaster.mremun_tindakan mtindVisite ON mtin.ID = mtindVisite.ID
					LEFT JOIN pendaftaran.kunjungan pk ON ltm.KUNJUNGAN = pk.NOMOR and kl.no_pendaftaran_lab = substring(pk.NOMOR,8) and pk.STATUS != 0
					LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN and pp.NOMOR = kl.no_pendaftaran and pp.STATUS != 0
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
			where	kl.tgl_hasil 			>= vTanggalAw and 
					kl.tgl_hasil 		 	 < vTanggalAk and
					kl.kd_tindakan_periksa REGEXP '^[0-9]+$' = 1 and
					pp.STATUS 				!= 0 and
					pk.STATUS               != 0 and
					ltm.STATUS              != 0 and
					LEFT(mruang.ID,7)		 = 1010701 and
					concat('',kl.kd_tindakan_periksa * 1) = kl.kd_tindakan_periksa and
					pj.JENIS				is not null and
					mtin.ID					is not null and
					kl.kd_pelaksana         is not null;

		-- pemeriksaan papsmear
		insert into tremun_datarinci ( 
					id_remunproses, tgl_transaksi, dokter_nip, dokter_nama, dokter_ksm,
					kunj_nomor, kunj_tgl_masuk, kunj_instalasi, kunj_ruang, kunj_ruangan,
					daftar_nomor, daftar_crbyrid, daftar_crbyr, daftar_crbyr_klp, daftar_nomor_sep, daftar_ruangan,
					pasien_nomor, pasien_nama, pasien_jk, pasien_tgllahir,
					kegiatan_id, kegiatan_nama, kegiatan_trfkelas, kegiatan_petugas_jns, kegiatan_petugas_ke,
					kegiatan_petugas_sts, kegiatan_tarif, kegiatan_tarif_lyn, kegiatan_tarif_bhp, kegiatan_tarif_dokter, kegiatan_tarif_griya, kegiatan_skor,
					kegiatan_porsi_remun, 
					rumus_pengali_tarif_baru,
					rumus_porsi_dokter_dari_tarif,
					kegiatan_instalasi_grouping,
					kegiatan_instalasi_kelompok,
					dto_kegiatan_crbyr,
					dto_sts_penunjang, dto_sts_bhp, dto_sts_rawatinap, dto_sts_rawatjalan, dto_sts_executive,
					dto_rawatjalan, dto_visite, dto_penunjang, dto_tindakan, dto_tunaibedahprima, dto_executive,
					dto_kegiatan_klp, dto_bpjs_qty, dto_bpjs_nilai, dto_nbpjs_qty, dto_nbpjs_nilai, dto_nbpjse_qty, dto_nbpjse_nilai,
					sts_hapus, sts_remun, sysdate_in, sysdate_updt )
		SELECT		vID as id_remunproses,
					paps.TANGGAL_IMUNO as tgl_transaksi,
					IFNULL( mpeg.NIP, mpg.NIP) as dokter_nip,
					IFNULL( mpeg.NAMA, mpg.NAMA) as dokter_nama,
					IFNULL(smf.DESKRIPSI,smf2.DESKRIPSI) as dokter_ksm,
					pk.NOMOR as kunj_nomor,
					pk.MASUK as kunj_tgl_masuk,
					ir.DESKRIPSI as kunj_instalasi,
					mruang.DESKRIPSI as kunj_ruang,
					mruang.ID as kunj_ruangan,
					pp.NOMOR as daftar_nomor,
					pj.JENIS as daftar_crbyrid,
					mref2.DESKRIPSI as daftar_crbyr,
					if(pj.JENIS = 7, 'EXECUTIVE', if(pj.JENIS = 2, 'BPJS', 'NON BPJS')) as daftar_crbyr_klp,
					pj.NOMOR as daftar_nomor_sep,
					tp.RUANGAN as daftar_ruangan,
					pp.NORM as pasien_nomor,
					mps.NAMA as pasien_nama,
					ifnull(mref.DESKRIPSI,'') as pasien_jk,
					mps.TANGGAL_LAHIR as pasien_tgllahir,
					ifnull(mtin.ID, 0) as kegiatan_id,
					mtin.NAMA as kegiatan_nama,
					if(ifnull(mtf.KELAS,'9999') = '', '9999', mtf.KELAS) as kegiatan_trfkelas,
					1 as kegiatan_petugas_jns,
					1 as kegiatan_petugas_ke,
					1 as kegiatan_petugas_sts,
					rsfMaster.getTrfTind(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif,
					rsfMaster.getTrfTindOPERATOR(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_lyn,
					rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_bhp,
					0 as kegiatan_tarif_dokter,
					0 as kegiatan_tarif_griya,
					mskor.skor as kegiatan_skor,
					0 as kegiatan_porsi_remun,
					0 as rumus_pengali_tarif_baru,
					0 as rumus_porsi_dokter_dari_tarif,
					ifnull(miKunjungan.remun_grouping,'') as kegiatan_instalasi_grouping,
					ifnull(miKunjungan.remun_klp,'') as kegiatan_instalasi_kelompok,
					case pj.JENIS
						when 2 then
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'JKN'
							end
						when 7 then 'EXECUTIVE'
						else
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'REGULER'
							end
					end as dto_kegiatan_crbyr,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 1, 0) as dto_sts_penunjang,
					if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 1, 0) as dto_sts_bhp,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 1, 0) as dto_sts_rawatinap,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 1, 0) as dto_sts_rawatjalan,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_sts_executive,
					9 as dto_rawatjalan,
					9 as dto_visite,
					9 as dto_penunjang,
					9 as dto_tindakan,
					if(pj.JENIS = 7, 1, 0) as dto_tunaibedahprima,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_executive,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 'penunjang', 
						if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 'tindakan', 
							if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 'visite', 
								if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 'rawatjalan', if(ifnull(miKunjungan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))) as dto_kegiatan_klp,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) as dto_bpjs_qty,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) as dto_bpjs_nilai,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjs_qty,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjs_nilai,
					if(pj.JENIS  = 7, 1, 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjse_qty,					
					if(pj.JENIS  = 7, ifnull(trf.tarif,0), 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjse_nilai,
					0 as sts_hapus,
					0 as sts_remun,
					CURRENT_TIMESTAMP() as sysdate_in,
					CURRENT_TIMESTAMP() as sysdate_updt
			from 	(
						select 		max(hslpas.ID) as ID
							from 	layanan.hasil_pa_papsmear hslpas,
									master.dokter mdoks
							where	hslpas.DOKTER = mdoks.ID and
									hslpas.KUNJUNGAN is not null and 
									hslpas.KUNJUNGAN  != ''
							GROUP 	BY hslpas.KUNJUNGAN 
					) papsfilter,
					layanan.hasil_pa_papsmear paps
					LEFT JOIN pendaftaran.kunjungan pk ON paps.KUNJUNGAN = pk.NOMOR and pk.STATUS != 0
					LEFT JOIN layanan.tindakan_medis ltm ON ltm.KUNJUNGAN = pk.NOMOR 
					LEFT JOIN rsfPelaporan.rincian_tagihanx trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
					LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
					LEFT JOIN master.dokter mdok ON paps.DOKTER = mdok.ID
					LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
					LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
					LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
					LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
					LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26'			
					LEFT JOIN master.tindakan mtin ON mtin.ID = ltm.TINDAKAN
					LEFT JOIN rsfMaster.mremun_skor_smf mskor ON mskor.KODE = mtin.ID AND mskor.kode_smf = IFNULL(smf.ID,smf2.ID)
					LEFT JOIN rsfMaster.mremun_tindakan mtindVisite ON mtin.ID = mtindVisite.ID
					LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN and pp.STATUS != 0
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
			where	paps.TANGGAL_IMUNO 		>= vTanggalAw and 
					paps.TANGGAL_IMUNO 		 < vTanggalAk and
					papsfilter.ID			 = paps.ID and
					pp.STATUS 				!= 0 and
					pk.STATUS               != 0 and
					ltm.STATUS              != 0 and
					LEFT(mruang.ID,7)		 = 1010702 and
					pj.JENIS				is not null and
					mtin.ID					is not null and
					IFNULL( mpeg.NIP, mpg.NIP) is not null;

		-- pemeriksaan pa
		insert into tremun_datarinci ( 
					id_remunproses, tgl_transaksi, dokter_nip, dokter_nama, dokter_ksm,
					kunj_nomor, kunj_tgl_masuk, kunj_instalasi, kunj_ruang, kunj_ruangan,
					daftar_nomor, daftar_crbyrid, daftar_crbyr, daftar_crbyr_klp, daftar_nomor_sep, daftar_ruangan,
					pasien_nomor, pasien_nama, pasien_jk, pasien_tgllahir,
					kegiatan_id, kegiatan_nama, kegiatan_trfkelas, kegiatan_petugas_jns, kegiatan_petugas_ke,
					kegiatan_petugas_sts, kegiatan_tarif, kegiatan_tarif_lyn, kegiatan_tarif_bhp, kegiatan_tarif_dokter, kegiatan_tarif_griya, kegiatan_skor,
					kegiatan_porsi_remun, 
					rumus_pengali_tarif_baru,
					rumus_porsi_dokter_dari_tarif,
					kegiatan_instalasi_grouping,
					kegiatan_instalasi_kelompok,
					dto_kegiatan_crbyr,
					dto_sts_penunjang, dto_sts_bhp, dto_sts_rawatinap, dto_sts_rawatjalan, dto_sts_executive,
					dto_rawatjalan, dto_visite, dto_penunjang, dto_tindakan, dto_tunaibedahprima, dto_executive,
					dto_kegiatan_klp, dto_bpjs_qty, dto_bpjs_nilai, dto_nbpjs_qty, dto_nbpjs_nilai, dto_nbpjse_qty, dto_nbpjse_nilai,
					sts_hapus, sts_remun, sysdate_in, sysdate_updt )
		SELECT		vID as id_remunproses,
					hslpa.TANGGAL_IMUNO as tgl_transaksi,
					IFNULL( mpeg.NIP, mpg.NIP) as dokter_nip,
					IFNULL( mpeg.NAMA, mpg.NAMA) as dokter_nama,
					IFNULL(smf.DESKRIPSI,smf2.DESKRIPSI) as dokter_ksm,
					pk.NOMOR as kunj_nomor,
					pk.MASUK as kunj_tgl_masuk,
					ir.DESKRIPSI as kunj_instalasi,
					mruang.DESKRIPSI as kunj_ruang,
					mruang.ID as kunj_ruangan,
					pp.NOMOR as daftar_nomor,
					pj.JENIS as daftar_crbyrid,
					mref2.DESKRIPSI as daftar_crbyr,
					if(pj.JENIS = 7, 'EXECUTIVE', if(pj.JENIS = 2, 'BPJS', 'NON BPJS')) as daftar_crbyr_klp,
					pj.NOMOR as daftar_nomor_sep,
					tp.RUANGAN as daftar_ruangan,
					pp.NORM as pasien_nomor,
					mps.NAMA as pasien_nama,
					ifnull(mref.DESKRIPSI,'') as pasien_jk,
					mps.TANGGAL_LAHIR as pasien_tgllahir,
					ifnull(mtin.ID, 0) as kegiatan_id,
					mtin.NAMA as kegiatan_nama,
					if(ifnull(mtf.KELAS,'9999') = '', '9999', mtf.KELAS) as kegiatan_trfkelas,
					1 as kegiatan_petugas_jns,
					1 as kegiatan_petugas_ke,
					1 as kegiatan_petugas_sts,
					rsfMaster.getTrfTind(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif,
					rsfMaster.getTrfTindOPERATOR(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_lyn,
					rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_bhp,
					0 as kegiatan_tarif_dokter,
					0 as kegiatan_tarif_griya,
					mskor.skor as kegiatan_skor,
					0 as kegiatan_porsi_remun,
					0 as rumus_pengali_tarif_baru,
					0 as rumus_porsi_dokter_dari_tarif,
					ifnull(miKunjungan.remun_grouping,'') as kegiatan_instalasi_grouping,
					ifnull(miKunjungan.remun_klp,'') as kegiatan_instalasi_kelompok,
					case pj.JENIS
						when 2 then
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'JKN'
							end
						when 7 then 'EXECUTIVE'
						else
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'REGULER'
							end
					end as dto_kegiatan_crbyr,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 1, 0) as dto_sts_penunjang,
					if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 1, 0) as dto_sts_bhp,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 1, 0) as dto_sts_rawatinap,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 1, 0) as dto_sts_rawatjalan,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_sts_executive,
					9 as dto_rawatjalan,
					9 as dto_visite,
					9 as dto_penunjang,
					9 as dto_tindakan,
					if(pj.JENIS = 7, 1, 0) as dto_tunaibedahprima,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_executive,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 'penunjang', 
						if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 'tindakan', 
							if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 'visite', 
								if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 'rawatjalan', if(ifnull(miKunjungan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))) as dto_kegiatan_klp,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) as dto_bpjs_qty,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) as dto_bpjs_nilai,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjs_qty,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjs_nilai,
					if(pj.JENIS  = 7, 1, 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjse_qty,					
					if(pj.JENIS  = 7, ifnull(trf.tarif,0), 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjse_nilai,
					0 as sts_hapus,
					0 as sts_remun,
					CURRENT_TIMESTAMP() as sysdate_in,
					CURRENT_TIMESTAMP() as sysdate_updt
			from 	(
						select 		max(hslpas.ID) as ID
							from 	layanan.hasil_pa hslpas,
									master.dokter mdoks
							where	hslpas.DOKTER = mdoks.ID and
									hslpas.KUNJUNGAN is not null and 
									hslpas.KUNJUNGAN  != ''
							GROUP 	BY hslpas.KUNJUNGAN 
					) hslpafilter,
					layanan.hasil_pa hslpa
					LEFT JOIN pendaftaran.kunjungan pk ON hslpa.KUNJUNGAN = pk.NOMOR and pk.STATUS != 0
					LEFT JOIN layanan.tindakan_medis ltm ON ltm.KUNJUNGAN = pk.NOMOR 
					LEFT JOIN rsfPelaporan.rincian_tagihanx trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
					LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
					LEFT JOIN master.dokter mdok ON hslpa.DOKTER = mdok.ID
					LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
					LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
					LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
					LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
					LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26'			
					LEFT JOIN master.tindakan mtin ON mtin.ID = ltm.TINDAKAN
					LEFT JOIN rsfMaster.mremun_skor_smf mskor ON mskor.KODE = mtin.ID AND mskor.kode_smf = IFNULL(smf.ID,smf2.ID)
					LEFT JOIN rsfMaster.mremun_tindakan mtindVisite ON mtin.ID = mtindVisite.ID
					LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN and pp.STATUS != 0
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
			where	hslpa.TANGGAL_IMUNO 	>= vTanggalAw and 
					hslpa.TANGGAL_IMUNO 	 < vTanggalAk and
					hslpafilter.ID			 = hslpa.ID and
					pp.STATUS 				!= 0 and
					pk.STATUS               != 0 and
					ltm.STATUS              != 0 and
					LEFT(mruang.ID,7)		 = 1010702 and
					pj.JENIS				is not null and
					mtin.ID					is not null and
					IFNULL( mpeg.NIP, mpg.NIP) is not null;

		-- pemeriksaan radiologi
		insert into tremun_datarinci ( 
					id_remunproses, tgl_transaksi, dokter_nip, dokter_nama, dokter_ksm,
					kunj_nomor, kunj_tgl_masuk, kunj_instalasi, kunj_ruang, kunj_ruangan,
					daftar_nomor, daftar_crbyrid, daftar_crbyr, daftar_crbyr_klp, daftar_nomor_sep, daftar_ruangan,
					pasien_nomor, pasien_nama, pasien_jk, pasien_tgllahir,
					kegiatan_id, kegiatan_nama, kegiatan_trfkelas, kegiatan_petugas_jns, kegiatan_petugas_ke,
					kegiatan_petugas_sts, kegiatan_tarif, kegiatan_tarif_lyn, kegiatan_tarif_bhp, kegiatan_tarif_dokter, kegiatan_tarif_griya, kegiatan_skor,
					kegiatan_porsi_remun, 
					rumus_pengali_tarif_baru,
					rumus_porsi_dokter_dari_tarif,
					kegiatan_instalasi_grouping,
					kegiatan_instalasi_kelompok,
					dto_kegiatan_crbyr,
					dto_sts_penunjang, dto_sts_bhp, dto_sts_rawatinap, dto_sts_rawatjalan, dto_sts_executive,
					dto_rawatjalan, dto_visite, dto_penunjang, dto_tindakan, dto_tunaibedahprima, dto_executive,
					dto_kegiatan_klp, dto_bpjs_qty, dto_bpjs_nilai, dto_nbpjs_qty, dto_nbpjs_nilai, dto_nbpjse_qty, dto_nbpjse_nilai,
					sts_hapus, sts_remun, sysdate_in, sysdate_updt )
		SELECT		vID as id_remunproses,
					hslrad.TANGGAL as tgl_transaksi,
					mpeg.NIP as dokter_nip,
					mpeg.NAMA as dokter_nama,
					smf.DESKRIPSI as dokter_ksm,
					pk.NOMOR as kunj_nomor,
					pk.MASUK as kunj_tgl_masuk,
					ir.DESKRIPSI as kunj_instalasi,
					mruang.DESKRIPSI as kunj_ruang,
					mruang.ID as kunj_ruangan,
					pp.NOMOR as daftar_nomor,
					pj.JENIS as daftar_crbyrid,
					mref2.DESKRIPSI as daftar_crbyr,
					if(pj.JENIS = 7, 'EXECUTIVE', if(pj.JENIS = 2, 'BPJS', 'NON BPJS')) as daftar_crbyr_klp,
					pj.NOMOR as daftar_nomor_sep,
					tp.RUANGAN as daftar_ruangan,
					pp.NORM as pasien_nomor,
					mps.NAMA as pasien_nama,
					ifnull(mref.DESKRIPSI,'') as pasien_jk,
					mps.TANGGAL_LAHIR as pasien_tgllahir,
					ifnull(mtin.ID, 0) as kegiatan_id,
					mtin.NAMA as kegiatan_nama,
					if(ifnull(mtf.KELAS,'9999') = '', '9999', mtf.KELAS) as kegiatan_trfkelas,
					1 as kegiatan_petugas_jns,
					1 as kegiatan_petugas_ke,
					1 as kegiatan_petugas_sts,
					rsfMaster.getTrfTind(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif,
					rsfMaster.getTrfTindOPERATOR(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_lyn,
					rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_bhp,
					0 as kegiatan_tarif_dokter,
					0 as kegiatan_tarif_griya,
					mskor.skor as kegiatan_skor,
					0 as kegiatan_porsi_remun,
					0 as rumus_pengali_tarif_baru,
					0 as rumus_porsi_dokter_dari_tarif,
					ifnull(miKunjungan.remun_grouping,'') as kegiatan_instalasi_grouping,
					ifnull(miKunjungan.remun_klp,'') as kegiatan_instalasi_kelompok,
					case pj.JENIS
						when 2 then
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'JKN'
							end
						when 7 then 'EXECUTIVE'
						else
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then 'EXECUTIVE'
								else 'REGULER'
							end
					end as dto_kegiatan_crbyr,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 1, 0) as dto_sts_penunjang,
					if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 1, 0) as dto_sts_bhp,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 1, 0) as dto_sts_rawatinap,
					if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 1, 0) as dto_sts_rawatjalan,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_sts_executive,
					9 as dto_rawatjalan,
					9 as dto_visite,
					9 as dto_penunjang,
					9 as dto_tindakan,
					if(pj.JENIS = 7, 1, 0) as dto_tunaibedahprima,
					if(ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_executive,
					if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 'penunjang', 
						if(rsfMaster.getTrfTindBHP(mtin.ID, mtf.KELAS, ltm.TANGGAL) > 0, 'tindakan', 
							if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 'visite', 
								if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 'rawatjalan', if(ifnull(miKunjungan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))) as dto_kegiatan_klp,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) as dto_bpjs_qty,
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) as dto_bpjs_nilai,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', 1, 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjs_qty,
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') != 'executive', ifnull(trf.tarif,0), 0) +
					if(pj.JENIS  = 2 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjs_nilai,
					if(pj.JENIS  = 7, 1, 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', 1, 0) as dto_nbpjse_qty,					
					if(pj.JENIS  = 7, ifnull(trf.tarif,0), 0) + 
					if(pj.JENIS != 2 and pj.JENIS != 7 and ifnull(miKunjungan.remun_klp,'') = 'executive', ifnull(trf.tarif,0), 0) as dto_nbpjse_nilai,
					0 as sts_hapus,
					0 as sts_remun,
					CURRENT_TIMESTAMP() as sysdate_in,
					CURRENT_TIMESTAMP() as sysdate_updt
			from 	layanan.hasil_rad hslrad
					LEFT JOIN layanan.tindakan_medis ltm ON hslrad.TINDAKAN_MEDIS=ltm.ID 
					LEFT JOIN pendaftaran.kunjungan pk ON ltm.KUNJUNGAN = pk.NOMOR  and pk.STATUS != 0
					LEFT JOIN rsfPelaporan.rincian_tagihanx trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
					LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
					LEFT JOIN master.dokter mdok ON hslrad.DOKTER = mdok.ID
					LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
					LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS ='26'
					LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
					-- LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
					-- LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS ='26'			
					LEFT JOIN master.tindakan mtin ON mtin.ID = ltm.TINDAKAN
					LEFT JOIN rsfMaster.mremun_skor_smf mskor ON mskor.KODE = mtin.ID AND mskor.kode_smf = smf.ID
					LEFT JOIN rsfMaster.mremun_tindakan mtindVisite ON mtin.ID = mtindVisite.ID
					LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN and pp.STATUS != 0
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
			where	hslrad.TANGGAL 			>= vTanggalAw and 
					hslrad.TANGGAL 	 		 < vTanggalAk and
					pp.STATUS 				!= 0 and
					pk.STATUS               != 0 and
					ltm.STATUS              != 0 and
					LEFT(mruang.ID,7)		 = 1010801 and
					pj.JENIS				is not null and
					mtin.ID					is not null and
					mpeg.NIP				is not null;

			-- rekap pengunjung
			insert into tremun_datarinci_dft (
							id_remunproses, id_pegawai, 	dto_kegiatan_klp,
							daftar_bpjs, 	daftar_nbpjs, 	daftar_nbpjse,
							nilai_bpjs, 	nilai_nbpjs, 	nilai_nbpjse
						)
			select		id_remunproses, id_pegawai, dto_kegiatan_klp,
						sum(if(dto_kegiatan_crbyr = 'JKN',1,0)) as daftar_bpjs, 
						sum(if(dto_kegiatan_crbyr = 'REGULER',1,0)) as daftar_nbpjs, 
						sum(if(dto_kegiatan_crbyr = 'EXECUTIVE',1,0)) as daftar_nbpjse,
						0 as nilai_bpjs, 
						0 as nilai_nbpjs, 
						0 as nilai_nbpjse
				from	(
							select 		tremun_datarinci.id_remunproses as id_remunproses, 
										mpgw.id as id_pegawai, 
										tremun_datarinci.dto_kegiatan_klp as dto_kegiatan_klp, 
										tremun_datarinci.dto_kegiatan_crbyr as dto_kegiatan_crbyr, 
										tremun_datarinci.daftar_nomor as daftar_nomor
								from	tremun_datarinci,
										rsfPelaporan.tremun_nip mpgwNip,
										rsfPelaporan.tremun_pegawai mpgw
								where	tremun_datarinci.id_remunproses 	= vID and
										mpgwNip.nip 						= tremun_datarinci.dokter_nip and
										mpgw.id 							= mpgwNip.id_pegawai
								group   by 	id_remunproses, dokter_nip, dto_kegiatan_klp, 
											dto_kegiatan_crbyr, daftar_nomor
						) tremun_datarinci_grouping
				group   by id_remunproses, id_pegawai, dto_kegiatan_klp;

		-- update ad-hoc
		-- update dto_kegiatan_klp
		-- update		rsfPelaporan.tremun_datarinci trx
		--			left outer join rsfMaster.mlokasi_ruangan miKunjungan
		--				on 	miKunjungan.id = trx.kunj_ruangan
		--	set		dto_kegiatan_klp =
		--			if(ifnull(miKunjungan.remun_klp,'') = 'penunjang', 'penunjang', 
		--				if(rsfMaster.getTrfTindBHP(kegiatan_id, trx.kegiatan_trfkelas, trx.tgl_transaksi) > 0, 'tindakan', 
		--					if(ifnull(miKunjungan.remun_klp,'') = 'rawatinap', 'visite', 
		--						if(ifnull(miKunjungan.remun_klp,'') = 'rawatjalan', 'rawatjalan', if(ifnull(miKunjungan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))),
		--			kegiatan_instalasi_grouping = ifnull(miKunjungan.remun_grouping,''),
		--			kegiatan_instalasi_kelompok = ifnull(miKunjungan.remun_klp,'') 
		--	where	trx.id_remunproses = vID;

		-- master rumus
		--		insert into tremun_rumus_tarif
		--				( 	dto_tunaibedahprima, dto_kegiatan_klp, kegiatan_instalasi_grouping, rumus_pengali_tarif_baru,
		--					sysdate_in, sysdate_last )
		--			select		trx.dto_tunaibedahprima,
		--						trx.dto_kegiatan_klp,
		--						-- trx.kegiatan_instalasi_grouping,
		--						ifnull((miKunjungan.remun_grouping),'') as kegiatan_instalasi_grouping,
		--						max(
		--						case trx.dto_tunaibedahprima
		--							when 1 then 115
		--							else
		--								case (trx.dto_kegiatan_klp)
		--									when 'penunjang' then 100
		--								when 'rawatjalan' then
		--									case ifnull((miKunjungan.remun_grouping),'')
		--										when 'executive' then 115
		--										else 110
		--									end
		--								when 'tindakan' then
		--									case ifnull((miKunjungan.remun_grouping),'')
		--										when 'executive' then 115
		--										when 'operasi' then 125
		--										when 'rawatinap' then 115
		--										when 'intensif' then 115
		--										when 'rawatjalan' then 110
		--										else 110
		--									end
		--								else 115
		--							end
		--						end)  as rumus_pengali_tarif_baru,
		--						CURRENT_TIMESTAMP(), 
		--						CURRENT_TIMESTAMP()
		--				from	rsfPelaporan.tremun_datarinci trx
		--						left outer join rsfMaster.mlokasi_ruangan miKunjungan
		--							on 	miKunjungan.id = trx.kunj_ruangan
		--				group   by 	trx.dto_tunaibedahprima,
		--							trx.dto_kegiatan_klp,
		--							ifnull((miKunjungan.remun_grouping),'')
		--				order   by 	trx.dto_tunaibedahprima,
		--							trx.dto_kegiatan_klp,
		--							ifnull((miKunjungan.remun_grouping),'');	
		
		-- UPDATE ID RUMUS
		--	update 		rsfPelaporan.tremun_datarinci upd,
		--				rsfPelaporan.tremun_rumus_tarif	updReff
		--		set		upd.rumus_pengali_tarif_baru_id = updReff.id_rumus,
		--				upd.rumus_pengali_tarif_baru    = updReff.rumus_pengali_tarif_baru
		--		where	upd.id_remunproses 				= 7 and
		--				upd.dto_tunaibedahprima			= updReff.dto_tunaibedahprima and
		--				upd.dto_kegiatan_klp			= updReff.dto_kegiatan_klp and
		--				upd.kegiatan_instalasi_grouping = updReff.kegiatan_instalasi_grouping;

		-- update
		update		rsfPelaporan.tremun_datarinci trx
					left outer join rsfPelaporan.tremun_datarinci_kunj trx_rkp
						on 	trx_rkp.id_remunproses		= trx.id_remunproses and
							trx_rkp.dokter_nip			= trx.dokter_nip and
							trx_rkp.dto_kegiatan_klp	= trx.dto_kegiatan_klp
					left outer join rsfMaster.mlokasi_ruangan miKunjungan
						on 	miKunjungan.id = trx.kunj_ruangan
					left outer join rsfPelaporan.tremun_nip mpgwNip
						on 	mpgwNip.nip = trx.dokter_nip
					left outer join rsfPelaporan.tremun_pegawai mpgw
						on 	mpgw.id = mpgwNip.id_pegawai
					left outer join rsfPelaporan.tremun_pegawai_ksm mpgwKsm
						on 	mpgw.id_ksm = mpgwKsm.id
					left outer join rsfPelaporan.tremun_pegawai_ksmgrp mpgwKsmGrp
						on 	mpgwKsmGrp.id = mpgwKsm.id_grp
					left outer join
					(
						select 		max(p.id_ksmgrp) as id_ksmgrp,
									max(p.nm_jenis_tind) as dto_kelompok,
									max(if(p.kd_petugas_jenis = 1, if(p.kd_klp_byr = 1, p.persen, 0), 0)) as persen_opr_jkn,
									max(if(p.kd_petugas_jenis = 1, if(p.kd_klp_byr = 2, p.persen, 0), 0)) as persen_opr_nonjkn,
									max(if(p.kd_petugas_jenis = 2, if(p.kd_klp_byr = 1, p.persen, 0), 0)) as persen_coopr_jkn,
									max(if(p.kd_petugas_jenis = 2, if(p.kd_klp_byr = 2, p.persen, 0), 0)) as persen_coopr_nonjkn,
									max(if(p.kd_petugas_jenis = 3, if(p.kd_klp_byr = 1, p.persen, 0), 0)) as persen_anes_jkn,
									max(if(p.kd_petugas_jenis = 3, if(p.kd_klp_byr = 2, p.persen, 0), 0)) as persen_anes_nonjkn
							from	tremun_persentase p
							group   by p.id_ksmgrp, p.nm_jenis_tind
					) persentarif
						on  persentarif.id_ksmgrp		= mpgwKsmGrp.id and
							persentarif.dto_kelompok	= trx.dto_kegiatan_klp
			set     rumus_pengali_tarif_baru = 
					case trx.dto_tunaibedahprima 
						when 1 then 115
						else
							case (trx.dto_kegiatan_klp)
								when 'penunjang' then 100
								when 'rawatjalan' then
									case ifnull((miKunjungan.remun_grouping),'')
										when 'executive' then 115
										else 110
									end
								when 'tindakan' then
									case ifnull((miKunjungan.remun_grouping),'')
										when 'executive' then 115
										when 'operasi' then 125
										when 'rawatinap' then 115
										when 'intensif' then 115
										when 'rawatjalan' then 110
										else 110
									end
								else 115
							end
					end,
					rumus_porsi_dokter_dari_tarif =
					case daftar_crbyrid
						when 2 then
							case ifnull(miKunjungan.remun_klp,'') 
								when 'executive' then
									case trx.kegiatan_petugas_jns 
										when 2 then persentarif.persen_anes_nonjkn
										else persentarif.persen_opr_nonjkn
									end
								else
									case trx.kegiatan_petugas_jns 
										when 2 then persentarif.persen_anes_jkn
										else persentarif.persen_opr_jkn
									end
							end
						else
							case trx.kegiatan_petugas_jns 
								when 2 then persentarif.persen_anes_nonjkn -- persen_anes_jkn
								else persentarif.persen_opr_nonjkn -- persen_opr_jkn
							end
					end
			where	trx.id_remunproses = vID;
	END IF;
	COMMIT;
END //
DELIMITER ;
