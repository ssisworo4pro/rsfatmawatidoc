DROP PROCEDURE IF EXISTS rsfMaster.masterreferensi_sync;
DELIMITER //
CREATE PROCEDURE rsfMaster.masterreferensi_sync(
	aOBJ VARCHAR(99)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- masterreferensi_sync 																				-- */
	/* -- description   : insert rsfMaster.mkatalog_ ....															-- */
	/* -- spesification : 																							-- */
	/* -- sysdateLast 	: 2022-12-28 19:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	START TRANSACTION;
		IF (aOBJ = "lokasi.instalasi") THEN
			delete from rsfMaster.mlokasi_instalasi;
			insert into rsfMaster.mlokasi_instalasi
						(id, jenis, jenis_kunjungan, ref_id, deskripsi, status, dashboard_klp, dashboard_hitung)
			select 		id, jenis, jenis_kunjungan, ref_id, deskripsi, status, 'Rawat Jalan' as dashboard_klp, 1 as dashboard_hitung
				from	master.ruangan r 
				where 	JENIS = 3;
			update rsfMaster.mlokasi_instalasi set dashboard_klp = 'Rawat Inap' where id = '10102';
			update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where jenis_kunjungan = 0;
			update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where jenis_kunjungan > 5;
			update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where id = '10113';
			update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where id = '10119';
			
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'IRJ' where id = '10101';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'IRNA' where id = '10102';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'FARMASI' where id = '10103';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'IGD' where id = '10106';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'LAB' where id = '10107';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'RAD' where id = '10108';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'BOUG.DIAG' where id = '10109';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'IRM' where id = '10110';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'MCU' where id = '10111';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'IFPJ' where id = '10112';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'KHEMO' where id = '10114';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'HEMO' where id = '10115';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'BPRIMA' where id = '10116';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'CacthLAB' where id = '10117';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'Kardio' where id = '10118';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'Amb' where id = '10119';
			update rsfMaster.mlokasi_instalasi set dashboard_nickname = 'Gizi' where id = '10120';

			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster ', aOBJ, ', insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mlokasi_instalasi;
		ELSEIF (aOBJ = "lokasi.nicupicu") THEN
			delete from rsfMaster.mlokasi_nicupicu;
			insert into rsfMaster.mlokasi_nicupicu
						(id, jenis, jenis_kunjungan, ref_id, deskripsi, status, dashboard_klp, dashboard_hitung)
			select 		id, jenis, jenis_kunjungan, ref_id, deskripsi, status, 'Rawat Inap' as dashboard_klp, 1 as dashboard_hitung
				from 	master.ruangan r 
				where 	(	DESKRIPSI like '%NICU%' or
							DESKRIPSI like '%PICU%' ) and 
						SUBSTR(id,1,5) = '10102';
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster ', aOBJ, ', insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mlokasi_nicupicu;
		ELSEIF (aOBJ = "icd10.penyakit") THEN
			-- COVID19 : 'U07.1','U07.2'
			-- KUSTA   : 'A30.9'
			-- DYFTERY : 'A36.8','A36.9'
			-- HIV     : 'B20','B20.0','B20.1','B20.2','B20.3','B20.4','B20.5','B20.6','B20.7','B20.8','B20.9'
			-- DBD     : 'A90','A91','A91.0','A91.1','A91.9'
			-- DM      : 'E10','E11','E12','E13','E14','E15'
			delete from rsfMaster.mdiagnosa_penyakit;
			insert into rsfMaster.mdiagnosa_penyakit ( penyakit_nama, icd10_kode )
				values  ('COVID19','U07.1'),('COVID19','U07.2'),
						('KUSTA','A30.9'),
						('DYFTERY','A36.8'),('DYFTERY','A36.9'),
						('HIV','B20'),('HIV','B20.0'),('HIV','B20.1'),('HIV','B20.2'),('HIV','B20.3'),('HIV','B20.4'),
						('HIV','B20.5'),('HIV','B20.6'),('HIV','B20.7'),('HIV','B20.8'),('HIV','B20.9'),
						('DBD','A90'),('DBD','A91'),('DBD','A91.0'),('DBD','A91.1'),('DBD','A91.9'),
						('DM','E10'),('DM','E11'),('DM','E12'),('DM','E13'),('DM','E14'),('DM','E15');
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster ', aOBJ, ', insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mdiagnosa_penyakit;
		ELSE
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('rsfMaster, object ''', aOBJ,''' tidak ditemukan.') as statmessage,
						'' as data;
		END IF;
	COMMIT;
END //
DELIMITER ;
