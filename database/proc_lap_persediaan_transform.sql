DROP PROCEDURE IF EXISTS rsfPelaporan.proc_lap_persediaan_transform;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_lap_persediaan_transform(
	aBulan CHAR(6)
)
BEGIN
	DECLARE vTanggal CHAR(10);
	DECLARE sBulan CHAR(6);
	DECLARE vBulan integer;
	DECLARE vTahun integer;
	DECLARE vColumnName VARCHAR(75);
	DECLARE vDone int;
	DECLARE cursorStokOpname cursor for 
			select 		distinct klp_kolomupd 
				from 	rsfPelaporan.mlap_persediaan 
				where 	klp_kolomupd 		!= '' and 
						klp_pengali 		!= 0;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vDone = 1;

	SET vTanggal 	= CONCAT(SUBSTRING(aBulan, 1, 4), '-', SUBSTRING(aBulan, 5, 2), '-01');
	SET vTahun 		= CAST(SUBSTRING(aBulan, 1, 4) as UNSIGNED);
	SET vBulan 		= CAST(SUBSTRING(aBulan, 5, 2) as UNSIGNED);

	START TRANSACTION;
		delete from laporan_mutasi_bulan
			WHERE	bulan = vBulan and
					tahun = vTahun;

		insert into rsfPelaporan.laporan_mutasi_bulan 
				( 	bulan,						tahun,						
					id_katalog,					kode_barang,				nama_barang,
					id_jenisbarang,				kode_jenis,					nama_jenis,
					id_kelompokbarang,			kode_kelompok,				nama_kelompok,		tgl_create_katalog,
					jumlah_awal,				harga_awal,					nilai_awal,			tgl_updt_awal,
					jumlah_pembelian,			nilai_pembelian,			tgl_updt_pembelian,
					jumlah_hasilproduksi,		nilai_hasilproduksi,		tgl_updt_hasilproduksi,
					jumlah_koreksi,				nilai_koreksi,				tgl_updt_koreksi,
					jumlah_penjualan,			nilai_penjualan,			tgl_updt_penjualan,
					jumlah_floorstok,			nilai_floorstok,			tgl_updt_floorstok,
					jumlah_bahanproduksi,		nilai_bahanproduksi,		tgl_updt_bahanproduksi,
					jumlah_rusak,				nilai_rusak,				tgl_updt_rusak,
					jumlah_expired,				nilai_expired,				tgl_updt_expired,
					jumlah_returpembelian,		nilai_returpembelian,		tgl_updt_returpembelian,
					jumlah_koreksipenerimaan,	nilai_koreksipenerimaan,	tgl_updt_koreksipenerimaan,
					jumlah_revisipenerimaan,	nilai_revisipenerimaan,		tgl_updt_revisipenerimaan,
					jumlah_adjustment,			nilai_adjustment,			tgl_updt_adjusment,					
					jumlah_lainnya,				harga_lainnya,				nilai_lainnya,		tgl_updt_lainnya,
					jumlah_opname,				harga_opname,				nilai_opname,		tgl_updt_opname,
					jumlah_tidakterlayani,		tgl_updt_tidakterlayani,
					jumlah_akhir,				harga_akhir,				nilai_akhir,		tgl_updt_akhir,
					userid_in,					sysdate_in,					userid_updt,		sysdate_updt
				)
		select 		vBulan,						vTahun,
					qjnstrx.katalog_id, 		qjnstrx.katalog_kode, 		qjnstrx.katalog_nama,
					qjnstrx.kateg_id,			qjnstrx.kateg_kode,			qjnstrx.kateg_nama,
					qjnstrx.kateg_id,			qjnstrx.kateg_kode,			qjnstrx.kateg_nama,	CURRENT_TIMESTAMP(),
					0,							0,							0,					CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							CURRENT_TIMESTAMP(),
					0,							0,							0,					CURRENT_TIMESTAMP(),
					0,							0,							0,					CURRENT_TIMESTAMP(),
					0,							CURRENT_TIMESTAMP(),
					0,							0,							0,					CURRENT_TIMESTAMP(),
					1,							CURRENT_TIMESTAMP(),		1,					CURRENT_TIMESTAMP()
			from	(	
						select		distinct cast(katalog_id as CHAR) as katalog_id, katalog_kode, katalog_nama, 
									cast(kateg_kode as UNSIGNED) as kateg_id, kateg_kode, kateg_nama
							from 	rsfPelaporan.dlap_persediaan
							where	bulan = aBulan
					) qjnstrx
					left outer join 
					(
						select		id_katalog
							from 	rsfPelaporan.laporan_mutasi_bulan
							where	bulan = aBulan
					) lmb
					on qjnstrx.katalog_id = lmb.id_katalog
			where	lmb.id_katalog is null
			order	by qjnstrx.katalog_id;

		/*
		UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
					(		
						select		max(cast( dp.katalog_id as CHAR)) as katalog_id,
									sum(dp.jml_trxpersediaan * mp.klp_pengali) as jumlah
							from	rsfPelaporan.dlap_persediaan dp,
									rsfPelaporan.mlap_persediaan mp
							where	dp.bulan					= aBulan and
									dp.trx_jenis				= mp.trx_jenis and
									dp.trx_jenis_sub			= mp.trx_jenis_sub and
									mp.klp_trxpersediaan		= @vJnsProses
							group	by	dp.katalog_id
							order	by	dp.katalog_id
					) as persediaanlap
			SET		upd.jumlah_penjualan 		= persediaanlap.jumlah
			WHERE	upd.bulan 					= @vBulan and
					upd.tahun 					= @vTahun and
					persediaanlap.katalog_id 	= upd.id_katalog;
		*/

		SET vDone = 0;
		OPEN cursorStokOpname;
		getOpname: LOOP
			FETCH cursorStokOpname INTO vColumnName;
			IF vDone = 1 THEN 
				LEAVE getOpname;
			ELSE
				SET @vQuery = '';
				SET @vQuery = CONCAT(@vQuery,' UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd, ');
				SET @vQuery = CONCAT(@vQuery,'       		( ');
				SET @vQuery = CONCAT(@vQuery,'         		select		max(cast( dp.katalog_id as CHAR)) as katalog_id, ');
				SET @vQuery = CONCAT(@vQuery,'							sum(dp.jml_trxpersediaan * mp.klp_pengali) as jumlah ');
				SET @vQuery = CONCAT(@vQuery,'					from	rsfPelaporan.dlap_persediaan dp, ');
				SET @vQuery = CONCAT(@vQuery,'							master.ruangan_farmasi rf, ');
				SET @vQuery = CONCAT(@vQuery,'							rsfPelaporan.mlap_persediaan mp ');
				SET @vQuery = CONCAT(@vQuery,"					where	dp.bulan					= '",aBulan,"' and ");
				SET @vQuery = CONCAT(@vQuery,'							dp.trx_jenis				= mp.trx_jenis and ');
				SET @vQuery = CONCAT(@vQuery,'							dp.trx_jenis_sub			= mp.trx_jenis_sub and ');
				SET @vQuery = CONCAT(@vQuery,'							dp.depo_kode				= rf.FARMASI and ');
				SET @vQuery = CONCAT(@vQuery,"							mp.klp_kolomupd				= '",vColumnName,"' ");
				SET @vQuery = CONCAT(@vQuery,'					group	by	dp.katalog_id ');
				SET @vQuery = CONCAT(@vQuery,'					order	by	dp.katalog_id ');
				SET @vQuery = CONCAT(@vQuery,'			) as persediaanlap ');
				SET @vQuery = CONCAT(@vQuery,'	SET		upd.',vColumnName,'  						= persediaanlap.jumlah ');
				SET @vQuery = CONCAT(@vQuery,'	WHERE	upd.bulan 					= ',vBulan,' and ');
				SET @vQuery = CONCAT(@vQuery,'			upd.tahun 					= ',vTahun,' and ');
				SET @vQuery = CONCAT(@vQuery,'			persediaanlap.katalog_id 	= upd.id_katalog ');
				
				PREPARE stmt1 FROM @vQuery;
				EXECUTE stmt1;
			END IF;
		END LOOP getOpname;
		CLOSE cursorStokOpname;
	COMMIT;
END //
DELIMITER ;
