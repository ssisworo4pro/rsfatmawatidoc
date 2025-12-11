DROP PROCEDURE IF EXISTS rsfPelaporan.proc_lap_persediaan_transform_saldoawal;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_lap_persediaan_transform_saldoawal(
	aBulan CHAR(6),
	aOpname CHAR(1)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- proc_lap_persediaan_transform_saldoawal																	-- */
	/* -- description   : membentuk saldo awal laporan persediaan bulanan berdasarkan								-- */
	/* --                 transaksi opname atau jumlah_akhir dari periode bulan sebelumnya							-- */
	/* -- spesification : add laporan_mutasi_bulan by laporan_mutasi_bulan sebelumnya								-- */
	/* -- 				  add laporan_mutasi_bulan_depo by laporan_mutasi_bulan_depo sebelumnya						-- */
	/* -- 				  update laporan_mutasi_bulan.jumlah_awal with jumlah_akhir / jumlah_opname by aOpname		-- */
	/* -- 				  update laporan_mutasi_bulan_depo.jumlah_awal with jumlah_akhir / jumlah_opname by aOpname	-- */
	/* -- sysdateLast 	: 2022-10-21 16:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : add laporan_mutasi_bulan_depo 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vTanggal 		CHAR(10);
	DECLARE vBulan 			integer;
	DECLARE vTahun 			integer;
	DECLARE vTanggalSeblm 	CHAR(10);
	DECLARE aBulanSebelum 	CHAR(10);
	DECLARE vBulanSebelum 	integer;
	DECLARE vTahunSebelum 	integer;

	SET vTanggal 		= CONCAT(SUBSTRING(aBulan, 1, 4), '-', SUBSTRING(aBulan, 5, 2), '-', '01');
	SET vBulan 			= CAST(SUBSTRING(vTanggal, 6, 2) as UNSIGNED);
	SET vTahun 			= CAST(SUBSTRING(vTanggal, 1, 4) as UNSIGNED);

	SET vTanggalSeblm	= DATE_ADD(vTanggal, INTERVAL -1 DAY);
	SET aBulanSebelum 	= CONCAT(SUBSTRING(vTanggalSeblm, 1, 4), SUBSTRING(vTanggalSeblm, 6, 2));
	SET vBulanSebelum   = CAST(SUBSTRING(vTanggalSeblm, 6, 2) as UNSIGNED);
	SET vTahunSebelum	= CAST(SUBSTRING(vTanggalSeblm, 1, 4) as UNSIGNED);

	START TRANSACTION;
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
						select		id_katalog as katalog_id, 
									kode_barang as katalog_kode, 
									nama_barang as katalog_nama, 
									id_jenisbarang as kateg_id, 
									kode_jenis as kateg_kode, 
									nama_jenis as kateg_nama
							from 	rsfPelaporan.laporan_mutasi_bulan
							WHERE	bulan 	= vBulanSebelum and
									tahun 	= vTahunSebelum
					) qjnstrx
					left outer join 
					(
						select		id_katalog
							from 	rsfPelaporan.laporan_mutasi_bulan
							WHERE	bulan 	= vBulan and
									tahun 	= vTahun
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
					qjnstrx.depo_kode,			qjnstrx.depo_nama,
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
						select		id_depo as depo_kode,
									nama_depo as depo_nama,
									id_katalog as katalog_id, 
									kode_barang as katalog_kode, 
									nama_barang as katalog_nama, 
									id_jenisbarang as kateg_id, 
									kode_jenis as kateg_kode, 
									nama_jenis as kateg_nama
							from 	rsfPelaporan.laporan_mutasi_bulan_depo
							WHERE	bulan 	= vBulanSebelum and
									tahun 	= vTahunSebelum
					) qjnstrx
					left outer join 
					(
						select		id_katalog, id_depo
							from 	rsfPelaporan.laporan_mutasi_bulan_depo
							WHERE	bulan 	= vBulan and
									tahun 	= vTahun
					) lmb
					on qjnstrx.katalog_id = lmb.id_katalog and
					   qjnstrx.depo_kode = lmb.id_depo
			where	lmb.id_katalog is null
			order	by qjnstrx.depo_kode, qjnstrx.katalog_id;
	
		IF aOpname = '1' THEN
			UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
						(		
							select		id_katalog, 
										jumlah_opname,
										harga_opname,
										nilai_opname
								from 	rsfPelaporan.laporan_mutasi_bulan
								WHERE	bulan 		= vBulanSebelum and
										tahun 		= vTahunSebelum
						) as persediaanlap
				SET		upd.jumlah_awal 			= persediaanlap.jumlah_opname,
						upd.harga_awal 				= persediaanlap.harga_opname,
						upd.nilai_awal	 			= persediaanlap.nilai_opname
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						upd.id_katalog				= persediaanlap.id_katalog;

			UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
						(		
							select		id_depo, 
										id_katalog, 
										jumlah_opname,
										harga_opname,
										nilai_opname
								from 	rsfPelaporan.laporan_mutasi_bulan_depo
								WHERE	bulan 		= vBulanSebelum and
										tahun 		= vTahunSebelum
						) as persediaanlap
				SET		upd.jumlah_awal 			= persediaanlap.jumlah_opname,
						upd.harga_awal 				= persediaanlap.harga_opname,
						upd.nilai_awal	 			= persediaanlap.nilai_opname
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						upd.id_depo					= persediaanlap.id_depo and
						upd.id_katalog				= persediaanlap.id_katalog;
		ELSE
			UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
						(		
							select		id_katalog, 
										jumlah_akhir,
										harga_akhir,
										nilai_akhir
								from 	rsfPelaporan.laporan_mutasi_bulan
								WHERE	bulan 		= vBulanSebelum and
										tahun 		= vTahunSebelum
						) as persediaanlap
				SET		upd.jumlah_awal 			= persediaanlap.jumlah_akhir,
						upd.harga_awal 				= persediaanlap.harga_akhir,
						upd.nilai_awal	 			= persediaanlap.nilai_akhir
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						upd.id_katalog				= persediaanlap.id_katalog;

			UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
						(		
							select		id_depo,
										id_katalog, 
										jumlah_akhir,
										harga_akhir,
										nilai_akhir
								from 	rsfPelaporan.laporan_mutasi_bulan_depo
								WHERE	bulan 		= vBulanSebelum and
										tahun 		= vTahunSebelum
						) as persediaanlap
				SET		upd.jumlah_awal 			= persediaanlap.jumlah_akhir,
						upd.harga_awal 				= persediaanlap.harga_akhir,
						upd.nilai_awal	 			= persediaanlap.nilai_akhir
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						upd.id_depo					= persediaanlap.id_depo and
						upd.id_katalog				= persediaanlap.id_katalog;
		END IF;
	COMMIT;
END //
DELIMITER ;
