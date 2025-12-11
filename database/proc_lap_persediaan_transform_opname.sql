DROP PROCEDURE IF EXISTS rsfPelaporan.proc_lap_persediaan_transform_opname;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_lap_persediaan_transform_opname(
	aTanggal CHAR(8)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- proc_lap_persediaan_transform_opname 																		-- */
	/* -- description   : membentuk laporan persediaan bulanan berdasarkan transaksi opname							-- */
	/* -- spesification : add laporan_mutasi_bulan by dlap_persediaan_sodtl 										-- */
	/* -- 				  add laporan_mutasi_bulan_depo by dlap_persediaan_sodtl 									-- */
	/* -- 				  update laporan_mutasi_bulan.jumlah_opname with spesial column source for 20220331			-- */
	/* -- 				  update laporan_mutasi_bulan_depo.jumlah_opname with spesial column source for 20220331	-- */
	/* -- sysdateLast 	: 2022-10-21 14:30 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : add laporan_mutasi_bulan_depo 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vTanggal CHAR(10);
	DECLARE aBulan CHAR(6);
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

	SET aBulan 		= SUBSTRING(aTanggal, 1, 6);
	SET vTanggal 	= CONCAT(SUBSTRING(aTanggal, 1, 4), '-', SUBSTRING(aTanggal, 5, 2), '-', SUBSTRING(aTanggal, 7, 2));
	SET vTahun 		= CAST(SUBSTRING(aTanggal, 1, 4) as UNSIGNED);
	SET vBulan 		= CAST(SUBSTRING(aTanggal, 5, 2) as UNSIGNED);

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
						select		max(cast(sodtl.katalog_id as CHAR)) as katalog_id, 
									max(b.KODE_BARANG) as katalog_kode, 
									max(b.NAMA) as katalog_nama, 
									max(b.KATEGORI) as kateg_id, 
									max(cast(b.KATEGORI as CHAR)) kateg_kode, 
									max(k.NAMA) as kateg_nama
							from 	rsfPelaporan.dlap_persediaan_so so,
									rsfPelaporan.dlap_persediaan_sodtl sodtl,
									inventory.barang b,
									inventory.kategori k
							where 	so.id_opname 			= sodtl.id_opname and
									sodtl.katalog_id		= b.ID and
									b.KATEGORI 				= k.id and
									so.tanggal 				> vTanggal and
									so.tanggal      		< DATE_ADD(vTanggal, INTERVAL 1 DAY)
							group	by sodtl.katalog_id
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
			
		UPDATE		rsfPelaporan.laporan_mutasi_bulan 
			SET		jumlah_opname 				= 0,
					harga_opname 				= 0,
					nilai_opname 				= 0
			WHERE	bulan 						= vBulan and
					tahun 						= vTahun;

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
						select		max(so.depo_kode) as depo_kode,
									max(so.depo_nama) as depo_nama,
									max(cast(sodtl.katalog_id as CHAR)) as katalog_id, 
									max(b.KODE_BARANG) as katalog_kode, 
									max(b.NAMA) as katalog_nama, 
									max(b.KATEGORI) as kateg_id, 
									max(cast(b.KATEGORI as CHAR)) kateg_kode, 
									max(k.NAMA) as kateg_nama
							from 	rsfPelaporan.dlap_persediaan_so so,
									rsfPelaporan.dlap_persediaan_sodtl sodtl,
									inventory.barang b,
									inventory.kategori k
							where 	so.id_opname 			= sodtl.id_opname and
									sodtl.katalog_id		= b.ID and
									b.KATEGORI 				= k.id and
									so.tanggal 				> vTanggal and
									so.tanggal      		< DATE_ADD(vTanggal, INTERVAL 1 DAY)
							group	by sodtl.katalog_id, so.depo_kode
					) qjnstrx
					left outer join 
					(
						select		id_depo, id_katalog
							from 	rsfPelaporan.laporan_mutasi_bulan_depo
							WHERE	bulan 	= vBulan and
									tahun 	= vTahun
					) lmb
					on qjnstrx.katalog_id = lmb.id_katalog and
					   qjnstrx.depo_kode  = lmb.id_depo
			where	lmb.id_katalog is null
			order	by qjnstrx.katalog_id;

		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo
			SET		jumlah_opname 				= 0,
					harga_opname 				= 0,
					nilai_opname 				= 0
			WHERE	bulan 						= vBulan and
					tahun 						= vTahun;

		IF (aTanggal = '20220331') THEN
			UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
						(		
							select		max(sodtl.katalog_id) as katalog_id, 
										sum(sodtl.jml_trxruangan) as jumlah
								from	dlap_persediaan_sodtl sodtl,
										dlap_persediaan_so so
								where	so.id_opname 			= sodtl.id_opname and
										so.tanggal 				> vTanggal and
										so.tanggal      		< DATE_ADD(vTanggal, INTERVAL 1 DAY)
								group 	by sodtl.katalog_id
						) as persediaanlap
				SET		upd.jumlah_opname 			= persediaanlap.jumlah
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						persediaanlap.katalog_id 	= upd.id_katalog;

			UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
						(		
							select		max(so.depo_kode) as depo_kode,
										max(sodtl.katalog_id) as katalog_id, 
										sum(sodtl.jml_trxruangan) as jumlah
								from	dlap_persediaan_sodtl sodtl,
										dlap_persediaan_so so
								where	so.id_opname 			= sodtl.id_opname and
										so.tanggal 				> vTanggal and
										so.tanggal      		< DATE_ADD(vTanggal, INTERVAL 1 DAY)
								group 	by sodtl.katalog_id, so.depo_kode
						) as persediaanlap
				SET		upd.jumlah_opname 			= persediaanlap.jumlah
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						upd.id_depo					= persediaanlap.depo_kode and
						upd.id_katalog				= persediaanlap.katalog_id;
		ELSE
			UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
						(		
							select		max(sodtl.katalog_id) as katalog_id, 
										sum(sodtl.jml_opname) as jumlah
								from	dlap_persediaan_sodtl sodtl,
										dlap_persediaan_so so
								where	so.id_opname 			= sodtl.id_opname and
										so.tanggal 				> vTanggal and
										so.tanggal      		< DATE_ADD(vTanggal, INTERVAL 1 DAY)
								group 	by sodtl.katalog_id
						) as persediaanlap
				SET		upd.jumlah_opname 			= persediaanlap.jumlah
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						persediaanlap.katalog_id 	= upd.id_katalog;

			UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
						(		
							select		max(so.depo_kode) as depo_kode,
										max(sodtl.katalog_id) as katalog_id, 
										sum(sodtl.jml_opname) as jumlah
								from	dlap_persediaan_sodtl sodtl,
										dlap_persediaan_so so
								where	so.id_opname 			= sodtl.id_opname and
										so.tanggal 				> vTanggal and
										so.tanggal      		< DATE_ADD(vTanggal, INTERVAL 1 DAY)
								group 	by sodtl.katalog_id, so.depo_kode
						) as persediaanlap
				SET		upd.jumlah_opname 			= persediaanlap.jumlah
				WHERE	upd.bulan 					= vBulan and
						upd.tahun 					= vTahun and
						upd.id_depo					= persediaanlap.depo_kode and
						upd.id_katalog				= persediaanlap.katalog_id;
		END IF;
		/*
		UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
					(		
						select katalog_id as katalog_id, 
							   harga_perolehan_akhir as jumlah
						  from rsfPelaporan.mlap_katalog
					) as persediaanlap
			SET		upd.harga_opname 			= persediaanlap.jumlah,
					upd.nilai_opname 			= persediaanlap.jumlah * upd.jumlah_opname
			WHERE	upd.bulan 					= vBulan and
					upd.tahun 					= vTahun and
					persediaanlap.katalog_id 	= upd.id_katalog;
		*/
	COMMIT;
END //
DELIMITER ;
