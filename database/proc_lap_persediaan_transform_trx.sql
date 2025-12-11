DROP PROCEDURE IF EXISTS rsfPelaporan.proc_lap_persediaan_transform_trx;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_lap_persediaan_transform_trx(
	aBulan CHAR(6)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- proc_lap_persediaan_transform_trx																			-- */
	/* -- description   : merekap transaksi menurut kolom-kolom laporan persediaan sesuai settingan master 			-- */
	/* -- spesification : reset jumlah & nilai laporan_mutasi_bulan													-- */
	/* --                 reset jumlah & nilai laporan_mutasi_bulan_depo											-- */
	/* --                 add laporan_mutasi_bulan by transaksi														-- */
	/* -- 				  add laporan_mutasi_bulan_depo by transaksi												-- */
	/* -- 				  update laporan_mutasi_bulan jumlah & nilai with transaksi									-- */
	/* -- 				  update laporan_mutasi_bulan_depo jumlah & nilai with transaksi							-- */
	/* -- sysdateLast 	: 2022-10-21 16:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : add laporan_mutasi_bulan_depo 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
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
	DECLARE cursorStokOpnameDepo cursor for 
			select 		distinct klp_kolomupd_depo
				from 	rsfPelaporan.mlap_persediaan 
				where 	klp_kolomupd_depo	!= '' and 
						klp_pengali 		!= 0;
						
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vDone = 1;

	SET vTanggal 	= CONCAT(SUBSTRING(aBulan, 1, 4), '-', SUBSTRING(aBulan, 5, 2), '-01');
	SET vTahun 		= CAST(SUBSTRING(aBulan, 1, 4) as UNSIGNED);
	SET vBulan 		= CAST(SUBSTRING(aBulan, 5, 2) as UNSIGNED);

	START TRANSACTION;
		update      rsfPelaporan.laporan_mutasi_bulan
			set		jumlah_pembelian			= 0, nilai_pembelian			= 0,
					jumlah_hasilproduksi		= 0, nilai_hasilproduksi		= 0,
					jumlah_koreksi				= 0, nilai_koreksi				= 0,
					jumlah_penjualan			= 0, nilai_penjualan			= 0,
					jumlah_floorstok			= 0, nilai_floorstok			= 0,
					jumlah_bahanproduksi		= 0, nilai_bahanproduksi		= 0,
					jumlah_rusak				= 0, nilai_rusak				= 0,
					jumlah_expired				= 0, nilai_expired				= 0,
					jumlah_returpembelian		= 0, nilai_returpembelian		= 0,
					jumlah_koreksipenerimaan	= 0, nilai_koreksipenerimaan	= 0,
					jumlah_revisipenerimaan		= 0, nilai_revisipenerimaan		= 0,
					jumlah_adjustment			= 0, nilai_adjustment			= 0,
					jumlah_lainnya				= 0, harga_lainnya				= 0, nilai_lainnya				= 0,
					jumlah_opname				= 0, harga_opname				= 0, nilai_opname				= 0,
					jumlah_tidakterlayani		= 0,
					jumlah_akhir				= 0, harga_akhir				= 0, nilai_akhir				= 0,
					userid_updt					= 0, sysdate_updt				= CURRENT_TIMESTAMP()
			WHERE	bulan = vBulan and
					tahun = vTahun;

		update      rsfPelaporan.laporan_mutasi_bulan_depo
			set		jumlah_mutasimasuk			= 0, nilai_mutasimasuk			= 0,
					jumlah_mutasikeluar			= 0, nilai_mutasikeluar			= 0,
					jumlah_pembelian			= 0, nilai_pembelian			= 0,
					jumlah_hasilproduksi		= 0, nilai_hasilproduksi		= 0,
					jumlah_koreksi				= 0, nilai_koreksi				= 0,
					jumlah_penjualan			= 0, nilai_penjualan			= 0,
					jumlah_floorstok			= 0, nilai_floorstok			= 0,
					jumlah_bahanproduksi		= 0, nilai_bahanproduksi		= 0,
					jumlah_rusak				= 0, nilai_rusak				= 0,
					jumlah_expired				= 0, nilai_expired				= 0,
					jumlah_returpembelian		= 0, nilai_returpembelian		= 0,
					jumlah_koreksipenerimaan	= 0, nilai_koreksipenerimaan	= 0,
					jumlah_revisipenerimaan		= 0, nilai_revisipenerimaan		= 0,
					jumlah_adjustment			= 0, nilai_adjustment			= 0,
					jumlah_lainnya				= 0, harga_lainnya				= 0, nilai_lainnya				= 0,
					jumlah_opname				= 0, harga_opname				= 0, nilai_opname				= 0,
					jumlah_tidakterlayani		= 0,
					jumlah_akhir				= 0, harga_akhir				= 0, nilai_akhir				= 0,
					userid_updt					= 0, sysdate_updt				= CURRENT_TIMESTAMP()
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
							WHERE	tahun 		= vTahun and
									bulan 		= vBulan
					) lmb
					on qjnstrx.katalog_id = lmb.id_katalog
			where	lmb.id_katalog is null
			order	by qjnstrx.katalog_id;

		insert into rsfPelaporan.laporan_mutasi_bulan_depo
				( 	bulan,						tahun,
					id_depo,					nama_depo,
					id_katalog,					kode_barang,				nama_barang,
					id_jenisbarang,				kode_jenis,					nama_jenis,
					id_kelompokbarang,			kode_kelompok,				nama_kelompok,		tgl_create_katalog,
					jumlah_awal,				harga_awal,					nilai_awal,			tgl_updt_awal,
					jumlah_mutasimasuk,			nilai_mutasimasuk,
					jumlah_mutasikeluar,		nilai_mutasikeluar,
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
					qjnstrx.id_depo,			qjnstrx.nama_depo,
					qjnstrx.katalog_id, 		qjnstrx.katalog_kode, 		qjnstrx.katalog_nama,
					qjnstrx.kateg_id,			qjnstrx.kateg_kode,			qjnstrx.kateg_nama,
					qjnstrx.kateg_id,			qjnstrx.kateg_kode,			qjnstrx.kateg_nama,	CURRENT_TIMESTAMP(),
					0,							0,							0,					CURRENT_TIMESTAMP(),
					0,							0,
					0,							0,
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
						select		max(depo_kode) as id_depo,
									max(depo_nama) as nama_depo,
									max(cast(katalog_id as CHAR)) as katalog_id, 
									max(katalog_kode) as katalog_kode, 
									max(katalog_nama) as katalog_nama, 
									max(cast(kateg_kode as UNSIGNED)) as kateg_id, 
									max(kateg_kode) as kateg_kode, 
									max(kateg_nama) as kateg_nama
							from 	rsfPelaporan.dlap_persediaan
							where	bulan = aBulan
							group   by depo_kode, katalog_id
							order   by depo_kode, katalog_id
					) qjnstrx
					left outer join 
					(
						select		id_katalog, id_depo
							from 	rsfPelaporan.laporan_mutasi_bulan_depo
							WHERE	tahun 		= vTahun and
									bulan 		= vBulan
					) lmb
					on qjnstrx.katalog_id = lmb.id_katalog and
					   qjnstrx.id_depo = lmb.id_depo
			where	lmb.id_katalog is null
			order	by qjnstrx.id_depo, qjnstrx.katalog_id;

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
				-- SET @vQuery = CONCAT(@vQuery,'							master.ruangan_farmasi rf, ');
				SET @vQuery = CONCAT(@vQuery,'							rsfPelaporan.mlap_persediaan mp ');
				SET @vQuery = CONCAT(@vQuery,"					where	dp.bulan					= '",aBulan,"' and ");
				SET @vQuery = CONCAT(@vQuery,'							dp.trx_jenis				= mp.trx_jenis and ');
				SET @vQuery = CONCAT(@vQuery,'							dp.trx_jenis_sub			= mp.trx_jenis_sub and ');
				-- SET @vQuery = CONCAT(@vQuery,'							dp.depo_kode				= rf.FARMASI and ');
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
		
		SET vDone = 0;
		OPEN cursorStokOpnameDepo;
		getOpnameDepo: LOOP
			FETCH cursorStokOpnameDepo INTO vColumnName;
			IF vDone = 1 THEN 
				LEAVE getOpnameDepo;
			ELSE
				SET @vQuery = '';
				SET @vQuery = CONCAT(@vQuery,' UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd, ');
				SET @vQuery = CONCAT(@vQuery,'       		( ');
				SET @vQuery = CONCAT(@vQuery,'         		select		max(dp.depo_kode) as id_depo, ');
				SET @vQuery = CONCAT(@vQuery,'         					max(cast( dp.katalog_id as CHAR)) as katalog_id, ');
				SET @vQuery = CONCAT(@vQuery,'							sum(dp.jml_trxpersediaan * mp.klp_pengali) as jumlah ');
				SET @vQuery = CONCAT(@vQuery,'					from	rsfPelaporan.dlap_persediaan dp, ');
				-- SET @vQuery = CONCAT(@vQuery,'							master.ruangan_farmasi rf, ');
				SET @vQuery = CONCAT(@vQuery,'							rsfPelaporan.mlap_persediaan mp ');
				SET @vQuery = CONCAT(@vQuery,"					where	dp.bulan					= '",aBulan,"' and ");
				SET @vQuery = CONCAT(@vQuery,'							dp.trx_jenis				= mp.trx_jenis and ');
				SET @vQuery = CONCAT(@vQuery,'							dp.trx_jenis_sub			= mp.trx_jenis_sub and ');
				-- SET @vQuery = CONCAT(@vQuery,'							dp.depo_kode				= rf.FARMASI and ');
				SET @vQuery = CONCAT(@vQuery,"							mp.klp_kolomupd_depo		= '",vColumnName,"' ");
				SET @vQuery = CONCAT(@vQuery,'					group	by	dp.depo_kode, dp.katalog_id ');
				SET @vQuery = CONCAT(@vQuery,'					order	by	dp.depo_kode, dp.katalog_id ');
				SET @vQuery = CONCAT(@vQuery,'			) as persediaanlap ');
				SET @vQuery = CONCAT(@vQuery,'	SET		upd.',vColumnName,'  						= persediaanlap.jumlah ');
				SET @vQuery = CONCAT(@vQuery,'	WHERE	upd.bulan 					= ',vBulan,' and ');
				SET @vQuery = CONCAT(@vQuery,'			upd.tahun 					= ',vTahun,' and ');
				SET @vQuery = CONCAT(@vQuery,'			persediaanlap.id_depo    	= upd.id_depo and ');
				SET @vQuery = CONCAT(@vQuery,'			persediaanlap.katalog_id 	= upd.id_katalog ');
				
				PREPARE stmt2 FROM @vQuery;
				EXECUTE stmt2;
			END IF;
		END LOOP getOpnameDepo;
		CLOSE cursorStokOpnameDepo;		
	COMMIT;
END //
DELIMITER ;
