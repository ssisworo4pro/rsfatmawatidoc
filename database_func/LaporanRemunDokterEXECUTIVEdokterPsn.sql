-- CREATE DEFINER=`rsflaporan`@`%` PROCEDURE `rsfPelaporan`.`LaporanRemunDokterEXECUTIVEdokterPsn`(
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanRemunDokterEXECUTIVEdokterPsn`(
-- CREATE PROCEDURE rsfPelaporan.LaporanRemunDokterEXECUTIVEdokterPsn(
DROP PROCEDURE IF EXISTS rsfPelaporan.LaporanRemunDokterEXECUTIVEdokterPsn;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfPelaporan`.`LaporanRemunDokterEXECUTIVEdokterPsn`(
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
	/* -- rsfPelaporan.LaporanRemunDokterEXECUTIVEdokterPsn															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vRUANGAN VARCHAR(11);
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @sqlText = CONCAT(
		"	
			SELECT		max(mPegawai.nama) as dokter_nama,
						max(mPegawaiKsm.ksm_fatmawati) as dokter_ksm,
						max(ifnull(mtin.ID, 0)) as kegiatan_id,
						'tanggal' as kegiatan_tanggal,
						'norm' as pasien_nomor,
						'nama' as pasien_nama,
						max(mtin.NAMA) as kegiatan_nama,
						max(mRuangLayan.DESKRIPSI) as kegiatan_ruang,
						FORMAT(sum(tarif_griya.jasa_dr),0) as jasa_dokter_dari_jpd,
						FORMAT(sum(1),0) as kegiatan_qty,
						max(
						case pj.JENIS
							when 7 then 'bedah prima'
							else
								case LEFT(mRuangLayan.ID,5) 
									when '10118' then 'ukvi'
									when '10117' then 'ukvi'
									when '10107' then 
										case LEFT(mRuangLayan.ID,7)
											when '1010702' then 'PA'
											when '1010701' then 'lab'
											else '--'
										end
									when '10108' then 'rad'
									when '10109' then 'bougenville'
									when '10127' then 'igh'
									else mLokasiLayan.DESKRIPSI
							end
						end ) as kegiatan_kelompok,
						max(
							case pj.JENIS
								when 2 then
									case ifnull(mLokasiLayan.remun_klp,'') 
										when 'executive' then 'EXECUTIVE'
										else 'JKN'
									end
								when 7 then 'EXECUTIVE'
								else
									case LEFT(mRuangLayan.ID,5) 
										when '10118' then 'EXECUTIVE'
										when '10117' then 'EXECUTIVE'
										else
											case ifnull(mLokasiDaftar.remun_klp,'') 
												when 'executive' then 'EXECUTIVE'
												else 'REGULER'
											end
									end
							end  
						) as new_kegiatan_crbyr,
						max(
							ifnull(kegiatan_klp.dto_kegiatan_klp,
								if(ifnull(mLokasiLayan.remun_klp,'') = 'penunjang', 'penunjang', 
									if(rsfMaster.getTrfTindNonKelasBHP(lynTind.TINDAKAN, lynTind.TANGGAL) > 0, 'tindakan', 
										if(ifnull(mLokasiLayan.remun_klp,'') = 'rawatinap', 'visite', 
											if(ifnull(mLokasiLayan.remun_klp,'') = 'rawatjalan', 'rawatjalan', 
												if(ifnull(mLokasiLayan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang')))))) 
						) as dto_kegiatan_klp
				FROM 	layanan.tindakan_medis lynTind
						LEFT JOIN 	lis_bridging.kinerja_dokter_lab lynTindHasilLAB 
								ON 	lynTindHasilLAB.no_pendaftaran_lab = substring(lynTind.KUNJUNGAN,8)
									and lynTind.TINDAKAN = lynTindHasilLAB.kd_tindakan_periksa 
									and lynTind.TANGGAL = lynTindHasilLAB.tgl_tindakan
						left join layanan.hasil_rad lynTindHasilRAD on lynTindHasilRAD.TINDAKAN_MEDIS = lynTind.ID 
						LEFT OUTER JOIN (
							select 		id, tindakan_id, tindakan_nama,
										jasa_ba, jasa_rs, jasa_rs2, jasa_dr,
										jasa_umum, jasa_anes_dr, jasa_anes_umum, total_tarif,
										total_tarif_jkn,
										total_tarif_reguler,
										total_tarif_executive,
										created_at, updated_at, created_by, updated_by 
								from	rsfMaster.msetting_tarif
								where	id in (
											select 		max(id) as id
												from	rsfMaster.msetting_tarif
												group   by tindakan_id
										)
						) tarif_griya
						on  tarif_griya.tindakan_id = lynTind.TINDAKAN
						LEFT JOIN pembayaran.rincian_tagihan trf ON lynTind.ID = trf.REF_ID and trf.JENIS=3 and trf.STATUS != 0
						LEFT JOIN master.tarif_tindakan mtf on mtf.ID=trf.TARIF_ID
						LEFT JOIN layanan.petugas_tindakan_medis lptm ON lptm.TINDAKAN_MEDIS = lynTind.ID and lptm.STATUS != 0 AND lptm.JENIS in (1,2)
						LEFT JOIN master.dokter mdok ON lptm.MEDIS = mdok.ID
						LEFT JOIN master.pegawai mPegPelaksana ON mPegPelaksana.NIP = mdok.NIP
						LEFT JOIN master.referensi smf on mPegPelaksana.SMF=smf.ID and smf.JENIS ='26'
						LEFT JOIN aplikasi.pengguna ustm ON lynTind.OLEH=ustm.ID
						LEFT JOIN master.pegawai mPegInput ON ustm.NIP=mPegInput.NIP AND mPegInput.PROFESI=4
						LEFT JOIN master.referensi smf2 on mPegInput.SMF=smf2.ID and smf2.JENIS ='26'		
						LEFT JOIN master.dokter mDokterHslRAD ON lynTindHasilRAD.DOKTER = mDokterHslRAD.ID
						LEFT JOIN master.pegawai mPegHslRAD ON mPegHslRAD.NIP = mDokterHslRAD.NIP
						LEFT JOIN master.referensi mKsmHslRAD on mPegHslRAD.SMF = mKsmHslRAD.ID and mKsmHslRAD.JENIS ='26'
						LEFT JOIN master.tindakan mtin ON mtin.ID = lynTind.TINDAKAN
						LEFT JOIN rsfMaster.mremun_skor_smf mskor ON mskor.KODE = mtin.ID AND mskor.kode_smf = IFNULL(smf.ID,smf2.ID)
						LEFT JOIN rsfMaster.mremun_tindakan mtindVisite ON mtin.ID = mtindVisite.ID
						LEFT JOIN pendaftaran.kunjungan pk ON lynTind.KUNJUNGAN = pk.NOMOR and pk.STATUS != 0
						LEFT JOIN pendaftaran.pendaftaran dftDaftar ON dftDaftar.NOMOR = pk.NOPEN and dftDaftar.STATUS != 0
						LEFT JOIN layanan.pasien_pulang ppulang ON pk.NOMOR = ppulang.KUNJUNGAN AND ppulang.STATUS = 1
						LEFT JOIN master.pasien mps ON mps.NORM = dftDaftar.NORM
						LEFT JOIN master.referensi mref ON mps.JENIS_KELAMIN = mref.ID AND mref.JENIS = 2
						LEFT JOIN master.ruangan mRuangLayan ON mRuangLayan.ID = pk.RUANGAN
						LEFT JOIN master.ruangan mRuangLayanInst ON mRuangLayanInst.ID=LEFT(pk.RUANGAN,5) and mRuangLayanInst.JENIS=3
						LEFT JOIN pendaftaran.penjamin pj ON pj.NOPEN = dftDaftar.NOMOR
						LEFT JOIN master.referensi mref2 ON pj.JENIS = mref2.ID AND mref2.JENIS = 10
						LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN=dftDaftar.NOMOR
						LEFT JOIN master.ruangan mRuangDaftar ON mRuangDaftar.ID=tp.RUANGAN
						LEFT JOIN rsfMaster.mlokasi_ruangan mLokasiDaftar ON mLokasiDaftar.id = mRuangDaftar.ID
						LEFT JOIN master.ruangan ins ON ins.ID=LEFT(tp.RUANGAN,5) and ins.JENIS=3
						LEFT JOIN rsfMaster.mlokasi_ruangan mLokasiLayan ON mLokasiLayan.id = mRuangLayan.ID
						left outer join rsfPelaporan.tremun_kegiatan_klp kegiatan_klp
							on kegiatan_klp.kegiatan_id = lynTind.TINDAKAN
						left outer join rsfPelaporan.tremun_nip mPegRemunNIP
							on mPegRemunNIP.nip =	(
													case LEFT(mRuangLayan.ID,5) 
														when '10107' then 
															case LEFT(mRuangLayan.ID,7)
																when '1010702' then mPegHslRAD.NIP -- 'PA'
																when '1010701' then lynTindHasilLAB.kd_pelaksana -- 'lab'
																else mPegHslRAD.NIP -- '--'
															end
														when '10108' then mPegHslRAD.NIP -- 'rad'
														else IFNULL(mPegPelaksana.NIP, mPegInput.NIP)
													end
												)
						left outer join rsfPelaporan.tremun_pegawai mPegawai
							on 	mPegawai.id = mPegRemunNIP.id_pegawai
						left outer join rsfPelaporan.tremun_pegawai_ksm mPegawaiKsm
							on 	mPegawai.id_ksm = mPegawaiKsm.id
						left outer join rsfPelaporan.tremun_pegawai_ksmgrp mPegawaiKsmGrp
							on 	mPegawaiKsmGrp.id = mPegawaiKsm.id_grp
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
							on  persentarif.id_ksmgrp		= mPegawaiKsmGrp.id and
								persentarif.dto_kelompok	= 	(
																	ifnull(kegiatan_klp.dto_kegiatan_klp,
																		if(ifnull(mLokasiLayan.remun_klp,'') = 'penunjang', 'penunjang', 
																			if(rsfMaster.getTrfTindNonKelasBHP(lynTind.TINDAKAN, lynTind.TANGGAL) > 0, 'tindakan', 
																				if(ifnull(mLokasiLayan.remun_klp,'') = 'rawatinap', 'visite', 
																					if(ifnull(mLokasiLayan.remun_klp,'') = 'rawatjalan', 'rawatjalan', 
																						if(ifnull(mLokasiLayan.remun_klp,'') = 'executive', 'rawatjalan', 'penunjang'))))))
																)
				WHERE   lynTind.TANGGAL     				>= '",TGLAWAL,"' and
						lynTind.TANGGAL      	 	 		 < Date_ADD('",TGLAKHIR,"', INTERVAL +1 day) and
						mPegawai.id 						= ",DOKTER, " and
						lynTind.STATUS      				!= 0 and
						dftDaftar.STATUS 				!= 0 and
						pk.STATUS               		!= 0 and
						(
							(
								mRuangLayan.ID 				LIKE '10127%' and
								mRuangDaftar.ID 			LIKE '10127%' and
								pj.JENIS					is not null and
								mtin.ID						is not null and
								IFNULL( mPegPelaksana.NIP, mPegInput.NIP) is not null
							) or
							(
								mRuangLayan.ID 				NOT LIKE '10127%' and
								pj.JENIS					= 7 and
								mtin.ID						is not null and
								IFNULL( mPegPelaksana.NIP, mPegInput.NIP) is not null
							) or
							(
								mRuangLayan.ID 				LIKE '1010801%' and
								mRuangDaftar.ID 			LIKE '10127%' and
								pj.JENIS					is not null and
								mtin.ID						is not null
							) or
							(
								mRuangLayan.ID 				LIKE '1010701%' and
								mRuangDaftar.ID 			LIKE '10127%' and
								pj.JENIS					is not null and
								mtin.ID						is not null
							) or
							( 
								(	mRuangLayan.ID 			= '101180101' or 
									mRuangLayan.ID 			= '101170101' ) and
								pj.JENIS					!= 2 and
								pj.JENIS					is not null and
								mtin.ID						is not null and
								IFNULL( mPegPelaksana.NIP, mPegInput.NIP) is not null
							)
						)
				group   by mtin.ID
				order   by mtin.NAMA 
				"
	);
	-- call rsfPelaporan.LaporanRemunDokterEXECUTIVEdokterPsn('2023-09-11','2023-09-11','0','0',864);
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END //
DELIMITER ;
