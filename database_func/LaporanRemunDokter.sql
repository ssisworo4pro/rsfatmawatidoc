-- CREATE DEFINER=`rsflaporan`@`%` PROCEDURE `rsfPelaporan`.`LaporanRemunDokter`(
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanRemunDokter`(
-- CREATE PROCEDURE rsfPelaporan.LaporanRemunDokter(
DROP PROCEDURE IF EXISTS rsfPelaporan.LaporanRemunDokter;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanRemunDokter`(
	IN `TGLAWAL` DATETIME, 
	IN `TGLAKHIR` DATETIME, 
	IN `RUANGAN` CHAR(10), 
	IN `CARABAYAR` INT, 
	IN `DOKTER` INT
)
	-- aOBJ VARCHAR(32) CHARSET utf8mb4,
	-- aKODE VARCHAR(35) CHARSET utf8mb4
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- rsfPelaporan.LaporanRemunDokter																			-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vRUANGAN VARCHAR(11);
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @sqlText = CONCAT(
		'	SELECT		ltm.id as id_transaksi, 
						lptm.id as id_transaksi_detail,
						ltm.TANGGAL as tgl_transaksi,
						IFNULL(mpeg.NIP, mpg.NIP) as dokter_nip,
						IFNULL(mpeg.NAMA, mpg.NAMA) as dokter_nama,
						IFNULL(smf.DESKRIPSI,smf2.DESKRIPSI) as dokter_ksm,
						pk.MASUK as kunj_tgl_masuk,
						ir.DESKRIPSI as kunj_instalasi,
						mruang.DESKRIPSI as kunj_ruang,
						mruang.ID as kunj_ruangan,
						pp.NOMOR as daftar_nomor,
						pj.JENIS as daftar_crbyrid,
						mref2.DESKRIPSI as daftar_crbyr,
						tp.RUANGAN as daftar_ruangan,
						ma.DESKRIPSI as daftar_ruang,
						pp.NORM as pasien_nomor,
						mps.NAMA as pasien_nama,
						ifnull(mtin.ID, 0) as kegiatan_id,
						mtin.NAMA as kegiatan_nama,
						rsfMaster.getTrfTind(mtin.ID, mtf.KELAS, ltm.TANGGAL) as kegiatan_tarif_rs,
						(tarif_griya.jasa_rs2) as kegiatan_tarif_griya_rs2,
						(tarif_griya.jasa_dr) as kegiatan_tarif_griya_dr,
						tarif_griya.total_tarif as kegiatan_tarif_griya_total,
						case pj.JENIS
							when 2 then
								case ifnull(miKunjungan.remun_klp,'' '') 
									when ''executive'' then ''EXECUTIVE''
									else ''JKN''
								end
							when 7 then ''EXECUTIVE''
							else
								case ifnull(miKunjungan.remun_klp,'' '') 
									when ''executive'' then ''EXECUTIVE''
									else ''REGULER''
								end
						end as dto_kegiatan_crbyr,
						CURRENT_TIMESTAMP() as sysdate_in,
						CURRENT_TIMESTAMP() as sysdate_updt
				FROM 	layanan.tindakan_medis ltm
						LEFT OUTER JOIN (
							select 		id, tindakan_id, tindakan_nama,
										jasa_ba, jasa_rs, jasa_rs2, jasa_dr,
										jasa_umum, jasa_anes_dr, jasa_anes_umum, total_tarif,
										created_at, updated_at, created_by, updated_by 
								from	rsfMaster.msetting_tarif
								where	id in (
											select 		max(id) as id
												from	rsfMaster.msetting_tarif
												group   by tindakan_id
										)
						) tarif_griya
						on  tarif_griya.tindakan_id = ltm.TINDAKAN
						LEFT JOIN pembayaran.rincian_tagihan trf ON ltm.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
						LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
						LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = ltm.ID and lptm.STATUS != 0 AND lptm.JENIS in (1,2)
						LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID
						LEFT JOIN master.pegawai mpeg ON mpeg.NIP = mdok.NIP
						LEFT JOIN master.referensi smf on mpeg.SMF=smf.ID and smf.JENIS =''26''
						LEFT JOIN aplikasi.pengguna ustm ON ltm.OLEH=ustm.ID
						LEFT JOIN master.pegawai mpg ON ustm.NIP=mpg.NIP AND mpg.PROFESI=4
						LEFT JOIN master.referensi smf2 on mpg.SMF=smf2.ID and smf2.JENIS =''26''			
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
				WHERE   ltm.TANGGAL     		>= ''',TGLAWAL,''' and
						ltm.TANGGAL      	 	 < ''',TGLAKHIR,''' and
						ltm.STATUS      		!= 0 and
						pp.STATUS 				!= 0 and
						pk.STATUS               != 0 and
						mruang.ID LIKE ''10127%'' and
						ma.ID LIKE ''10127%'' and
						pj.JENIS				is not null and
						mtin.ID					is not null and
						IFNULL( mpeg.NIP, mpg.NIP) is not null
				order   by ir.DESKRIPSI , IFNULL(mpeg.NAMA, mpg.NAMA)
		');
	-- call rsfPelaporan.LaporanRemunDokter('2023-06-01','2023-08-23','0','0','0');
	-- IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END //
DELIMITER ;
