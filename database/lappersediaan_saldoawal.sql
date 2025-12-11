DROP PROCEDURE IF EXISTS rsfPelaporan.lappersediaan_saldoawal2022;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.lappersediaan_saldoawal2022()
BEGIN
	START TRANSACTION;
		-- refresh insert laporan_mutasi_bulan dengan default jumlah dan nilai = 0
		delete from		rsfPelaporan.laporan_mutasi_bulan;
		insert into		rsfPelaporan.laporan_mutasi_bulan ( bulan, tahun, 
						katalog_kode, katalog_id, nama_barang, id_jenisbarang, kode_jenis, nama_jenis,
						id_kelompokbarang, kode_kelompok, nama_kelompok, tgl_create_katalog,
						jumlah_awal, harga_awal, nilai_awal,
						jumlah_pembelian, nilai_pembelian, jumlah_hasilproduksi, nilai_hasilproduksi,
						jumlah_koreksi, nilai_koreksi,
						jumlah_penjualan, nilai_penjualan, jumlah_floorstok, nilai_floorstok,
						jumlah_bahanproduksi, nilai_bahanproduksi, jumlah_rusak, nilai_rusak,
						jumlah_expired, nilai_expired, jumlah_returpembelian, nilai_returpembelian,
						jumlah_koreksipenerimaan, nilai_koreksipenerimaan, jumlah_revisipenerimaan, nilai_revisipenerimaan,
						jumlah_adjustment, nilai_adjustment,
						jumlah_tidakterlayani,
						jumlah_akhir, harga_akhir, nilai_akhir,
						jumlah_lainnya, harga_lainnya, nilai_lainnya,
						jumlah_opname, harga_opname, nilai_opname,
						userid_in, sysdate_in, userid_updt, sysdate_updt )
			select		bulan, tahun, id_katalog, '0', nama_barang, id_jenisbarang, kode_jenis, nama_jenis,
						id_kelompokbarang, kode_kelompok, nama_kelompok, tgl_create_katalog,
						jumlah_awal, harga_awal, nilai_awal,
						jumlah_pembelian, nilai_pembelian, jumlah_hasilproduksi, nilai_hasilproduksi,
						jumlah_koreksi, nilai_koreksi,
						jumlah_penjualan, nilai_penjualan, jumlah_floorstok, nilai_floorstok,
						jumlah_bahanproduksi, nilai_bahanproduksi, jumlah_rusak, nilai_rusak,
						jumlah_expired, nilai_expired, jumlah_returpembelian, nilai_returpembelian,
						jumlah_koreksipenerimaan, nilai_koreksipenerimaan, jumlah_revisipenerimaan, nilai_revisipenerimaan,
						jumlah_adjustment, nilai_adjustment,
						jumlah_tidakterlayani,
						jumlah_akhir, harga_akhir, nilai_akhir,
						0, 0, 0,
						0, 0, 0,
						userid_in, sysdate_in, userid_updt, sysdate_updt
				from	rsfTeamterima.laporan_mutasi_bulan
				where	tahun = 2022 and
						bulan < 4;

		-- refresh insert laporan_mutasi_bulan_depo dengan default jumlah dan nilai = 0
		delete from		rsfPelaporan.laporan_mutasi_bulan_depo;
		insert into		rsfPelaporan.laporan_mutasi_bulan_depo ( bulan, tahun, 
						depo_id, depo_nama,
						katalog_kode, katalog_id, nama_barang, id_jenisbarang, kode_jenis, nama_jenis,
						id_kelompokbarang, kode_kelompok, nama_kelompok, tgl_create_katalog,
						jumlah_awal, harga_awal, nilai_awal,
						jumlah_pembelian, nilai_pembelian, jumlah_hasilproduksi, nilai_hasilproduksi,
						jumlah_koreksi, nilai_koreksi,
						jumlah_penjualan, nilai_penjualan, jumlah_floorstok, nilai_floorstok,
						jumlah_bahanproduksi, nilai_bahanproduksi, jumlah_rusak, nilai_rusak,
						jumlah_expired, nilai_expired, jumlah_returpembelian, nilai_returpembelian,
						jumlah_koreksipenerimaan, nilai_koreksipenerimaan, jumlah_revisipenerimaan, nilai_revisipenerimaan,
						jumlah_adjustment, nilai_adjustment,
						jumlah_tidakterlayani,
						jumlah_akhir, harga_akhir, nilai_akhir,
						jumlah_lainnya, harga_lainnya, nilai_lainnya,
						jumlah_opname, harga_opname, nilai_opname,
						jumlah_mmasuk, harga_mmasuk, jumlah_mkeluar, harga_mkeluar,
						userid_in, sysdate_in, userid_updt, sysdate_updt )
			select		bulan, tahun, 
						mdepo.id, mdepo.nm_ruangan,
						id_katalog, '0', nama_barang, id_jenisbarang, kode_jenis, nama_jenis,
						id_kelompokbarang, kode_kelompok, nama_kelompok, tgl_create_katalog,
						0, 0, 0,
						0, 0, 0, 0,
						0, 0,
						0, 0, 0, 0,
						0, 0, 0, 0,
						0, 0, 0, 0,
						0, 0, 0, 0,
						0, 0,
						0,
						0, 0, 0,
						0, 0, 0,
						0, 0, 0,
						0, 0, 0, 0,
						userid_in, sysdate_in, userid_updt, sysdate_updt
				from	rsfTeamterima.laporan_mutasi_bulan lmb,
						(
							select		id, id_teamterima, nm_ruangan
								from	rsfMaster.mruangan_farmasi
								where	id_teamterima in ( select distinct id_depo from rsfTeamterima.masterf_backupstok_so_close where tgl >= '2021-12-21')
						) mdepo
				where	lmb.tahun = 2022 and
						lmb.bulan < 4;

		-- update saldo awal
		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
					(		
						select 		soc.id_katalog as katalog_kode,
									mf.id as depo_id,
									soc.jumlah_stokfisik as saldo_awal
							from 	rsfMaster.mruangan_farmasi mf,
									( select * from rsfTeamterima.masterf_backupstok_so_close
										where tgl >= '2021-12-21' and tgl < '2021-12-22' ) soc
							where 	mf.id_teamterima 	 = soc.id_depo
					) as trxPersediaan
			SET		upd.jumlah_awal 			= trxPersediaan.saldo_awal
			WHERE	upd.bulan 					= 1 and
					upd.tahun 					= 2022 and
					upd.katalog_kode			= trxPersediaan.katalog_kode and
					upd.depo_id					= trxPersediaan.depo_id;

		-- update saldo akhir
		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
					(		
						select 		soc.id_katalog as katalog_kode,
									mf.id as depo_id,
									soc.jumlah_stokfisik as saldo_akhir
							from 	rsfMaster.mruangan_farmasi mf,
									( select * from rsfTeamterima.masterf_backupstok_so_close
										where tgl >= '2022-03-18' and tgl < '2022-03-19' ) soc
							where 	mf.id_teamterima 	 = soc.id_depo
					) as trxPersediaan
			SET		upd.jumlah_akhir 			= trxPersediaan.saldo_akhir
			WHERE	upd.bulan 					= 3 and
					upd.tahun 					= 2022 and
					upd.katalog_kode			= trxPersediaan.katalog_kode and
					upd.depo_id					= trxPersediaan.depo_id;
					
		-- update nilai transaksi
		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
					(		
						select 		katalog_kode,
									mf.id as depo_id,
									jumlah_pembelian
							from 	rsfMaster.mruangan_farmasi mf,
									(	select	max(rksub.id_katalog) as katalog_kode,
												max(rksub.id_depo) as id_depo,
												sum(jumlah_masuk - jumlah_keluar) as jumlah_pembelian
										from	rsfTeamterima.relasif_ketersediaan rksub
										where 	tgl_tersedia 	>= '2022-01-01' and
												tgl_tersedia  	 < '2022-02-01' and
												tipe_tersedia    = 'penerimaan' and 
												kode_transaksi   = 'T'
										group   by rksub.id_katalog, rksub.id_depo
									) rk
							where 	mf.id_teamterima 	 = rk.id_depo
					) as trxPersediaan
			SET		upd.jumlah_pembelian 			= trxPersediaan.jumlah_pembelian
			WHERE	upd.bulan 						= 1 and
					upd.tahun 						= 2022 and
					upd.katalog_kode				= trxPersediaan.katalog_kode and
					upd.depo_id						= trxPersediaan.depo_id;


		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
					(		
						select 		katalog_kode,
									mf.id as depo_id,
									jumlah_pembelian, jumlah_hasilproduksi, jumlah_koreksipenerimaan, 
									jumlah_revisipenerimaan, jumlah_penjualan, jumlah_bahanproduksi, 
									jumlah_returpembelian, jumlah_adjustment
							from 	rsfMaster.mruangan_farmasi mf,
									(	select	max(rksub.id_katalog) as katalog_kode,
												max(rksub.id_depo) as id_depo,
												sum(case when rksub.tipe_tersedia = 'penerimaan' and rksub.kode_transaksi = 'T' then  rksub.jumlah_masuk - rksub.jumlah_keluar else 0 end) as jumlah_pembelian,
												sum(case when rksub.tipe_tersedia = 'produksi1' then rksub.jumlah_masuk - rksub.jumlah_keluar else 0 end) as jumlah_hasilproduksi,
												sum(case when rksub.tipe_tersedia = 'penerimaan' and rksub.kode_transaksi = 'K' then  rksub.jumlah_keluar - rksub.jumlah_masuk else 0 end) as jumlah_koreksipenerimaan,
												sum(case when rksub.tipe_tersedia = 'penerimaan' and rksub.kode_transaksi = 'K' then  rksub.jumlah_masuk - rksub.jumlah_keluar else 0 end) as jumlah_revisipenerimaan,
												sum(case when rksub.tipe_tersedia = 'penjualan' then rksub.jumlah_keluar - rksub.jumlah_masuk else 0 end) as jumlah_penjualan,
												sum(case when rksub.tipe_tersedia = 'produksi2' then rksub.jumlah_keluar - rksub.jumlah_masuk else 0 end) as jumlah_bahanproduksi,
												sum(case when rksub.tipe_tersedia = 'return'    then rksub.jumlah_masuk - rksub.jumlah_keluar else 0 end) as jumlah_returpembelian,
												0 as jumlah_adjustment
										from	rsfTeamterima.relasif_ketersediaan rksub
										where 	tgl_tersedia 	>= '2022-01-01' and
												tgl_tersedia  	 < '2022-02-01' 
										group   by rksub.id_katalog, rksub.id_depo
									) rk
							where 	mf.id_teamterima 	 = rk.id_depo and
									mf.id                = 1
					) as trxPersediaan
			SET		upd.jumlah_pembelian 			= trxPersediaan.jumlah_pembelian,
					upd.jumlah_hasilproduksi 		= trxPersediaan.jumlah_hasilproduksi,
					upd.jumlah_koreksipenerimaan 	= trxPersediaan.jumlah_koreksipenerimaan,
					upd.jumlah_revisipenerimaan 	= trxPersediaan.jumlah_revisipenerimaan,
					upd.jumlah_penjualan 			= trxPersediaan.jumlah_penjualan,
					upd.jumlah_bahanproduksi 		= trxPersediaan.jumlah_bahanproduksi,
					upd.jumlah_returpembelian 		= trxPersediaan.jumlah_returpembelian
			WHERE	upd.bulan 						= 1 and
					upd.tahun 						= 2022 and
					upd.katalog_kode				= trxPersediaan.katalog_kode and
					upd.depo_id						= trxPersediaan.depo_id;
					
		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
					(		
						select 		max(mf.id) as depo_id,
									sum(case when rk.tipe_tersedia = 'penerimaan' and rk.kode_transaksi = 'T' then  jumlah_masuk - jumlah_keluar else 0 end) as jumlah_pembelian,
									sum(case when rk.tipe_tersedia = 'produksi1' then jumlah_masuk - jumlah_keluar else 0 end) as jumlah_hasilproduksi,
									sum(case when rk.tipe_tersedia = 'penerimaan' and rk.kode_transaksi = 'K' then  jumlah_keluar - jumlah_masuk else 0 end) as jumlah_koreksipenerimaan,
									sum(case when rk.tipe_tersedia = 'penerimaan' and rk.kode_transaksi = 'K' then  jumlah_masuk - jumlah_keluar else 0 end) as jumlah_revisipenerimaan,
									sum(case when rk.tipe_tersedia = 'penjualan' then jumlah_keluar - jumlah_masuk else 0 end) as jumlah_penjualan,
									sum(case when rk.tipe_tersedia = 'produksi2' then jumlah_keluar - jumlah_masuk else 0 end) as jumlah_bahanproduksi,
									sum(case when rk.tipe_tersedia = 'return' then jumlah_masuk - jumlah_keluar else 0 end) as jumlah_returpembelian,
									0 as jumlah_adjustment
							from 	rsfTeamterima.relasif_ketersediaan rk,
									rsfMaster.mruangan_farmasi mf
							where 	rk.tgl_tersedia 	>= '2022-02-01' and
									rk.tgl_tersedia  	 < '2022-03-01' and
									mf.id_teamterima 	 = rk.id_depo
							group 	by rk.id_depo
					) as trxPersediaan
			SET		upd.jumlah_akhir 			= trxPersediaan.saldo_akhir
			WHERE	upd.bulan 					= 2 and
					upd.tahun 					= 2022 and
					upd.katalog_kode			= trxPersediaan.katalog_kode and
					upd.depo_id					= trxPersediaan.depo_id;

		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo as upd,
					(		
						select 		max(mf.id) as depo_id,
									sum(case when rk.tipe_tersedia = 'penerimaan' and rk.kode_transaksi = 'T' then  jumlah_masuk - jumlah_keluar else 0 end) as jumlah_pembelian,
									sum(case when rk.tipe_tersedia = 'produksi1' then jumlah_masuk - jumlah_keluar else 0 end) as jumlah_hasilproduksi,
									sum(case when rk.tipe_tersedia = 'penerimaan' and rk.kode_transaksi = 'K' then  jumlah_keluar - jumlah_masuk else 0 end) as jumlah_koreksipenerimaan,
									sum(case when rk.tipe_tersedia = 'penerimaan' and rk.kode_transaksi = 'K' then  jumlah_masuk - jumlah_keluar else 0 end) as jumlah_revisipenerimaan,
									sum(case when rk.tipe_tersedia = 'penjualan' then jumlah_keluar - jumlah_masuk else 0 end) as jumlah_penjualan,
									sum(case when rk.tipe_tersedia = 'produksi2' then jumlah_keluar - jumlah_masuk else 0 end) as jumlah_bahanproduksi,
									sum(case when rk.tipe_tersedia = 'return' then jumlah_masuk - jumlah_keluar else 0 end) as jumlah_returpembelian,
									0 as jumlah_adjustment
							from 	rsfTeamterima.relasif_ketersediaan rk,
									rsfMaster.mruangan_farmasi mf
							where 	rk.tgl_tersedia 	>= '2022-03-01' and
									rk.tgl_tersedia  	 < '2022-04-01' and
									mf.id_teamterima 	 = rk.id_depo
							group 	by rk.id_depo
					) as trxPersediaan
			SET		upd.jumlah_akhir 			= trxPersediaan.saldo_akhir
			WHERE	upd.bulan 					= 3 and
					upd.tahun 					= 2022 and
					upd.katalog_kode			= trxPersediaan.katalog_kode and
					upd.depo_id					= trxPersediaan.depo_id;

	COMMIT;
END //
DELIMITER ;
