DROP PROCEDURE IF EXISTS rsfKatalog.mkatalog_sync;
DELIMITER //
CREATE PROCEDURE rsfKatalog.mkatalog_sync(
	aOBJ VARCHAR(32),
	aINVinsert integer
)
BEGIN
	/* ------------------------------------------------------------------------------------------------------------------------ */
	/* -- mkatalog_sync 																							 		 -- */
	/* -- description   	: insert rsfKatalog.mkatalog_ ....															 	 -- */
	/* -- spesification 	: 																							 	 -- */
	/* -- sysdateCreated 	: 2023-05-16 16:00 																			 	 -- */
	/* -- sysdateLast 		: 2023-08-29 10:00 																			 	 -- */
	/* -- useridLast  		: ss 																						 	 -- */
	/* -- revisionCount 	: 2 																				 		 	 -- */
	/* -- revisionNote  	: - update kelompokBarang							 											 -- */
	/* ------------------------------------------------------------------------------------------------------------------------ */
	/*	mkatalog_anggaranjnssub				mkatalog_farmasi.id_jenisbarang														*/
	/*		mkatalog_anggaranjns			mkatalog_anggaranjnssub.id_jenis													*/
	/*	mkatalog_kelompok					mkatalog_farmasi.id_kelompokbarang													*/
	/*	mkatalog_kemasan 					mkatalog_farmasi.id_kemasankecil, 													*/
	/*										mkatalog_farmasi.id_kemasanbesar													*/
	/*	mkatalog_pbf						mkatalog_farmasi.id_pbf																*/
	/*	mkatalog_pabrik						mkatalog_farmasi.id_pabrik															*/
	/*	mkatalog_brand						mkatalog_farmasi.id_brand															*/
	/*		mkatalog_generik				mkatalog_brand.id_generik															*/
	/*	mkatalog_kfa91   					mkatalog_farmasi.id_kfa91															*/
	/*	mkatalog_kfa92						mkatalog_farmasi.id_kfa92															*/
	/*	mkatalog_kfa93						mkatalog_farmasi.id_kfa93															*/
	/*	mkatalog_sakti						mkatalog_farmasi.id_barang_sakti													*/
	/*		mkatalog_sakti_hdr				mkatalog_sakti.id_hdr																*/
	/*	mkatalog_dosis						mkatalog_farmasi.id_dosis															*/
	/*	_mkatalog_buffer_gudang																									*/
	/* ------------------------------------------------------------------------------------------------------------------------ */
	-- kfa91 :  579
	-- kfa92 :  794
	-- kfa93 : 1379

	-- START TRANSACTION;
		IF (aOBJ = "persiapan") THEN
			delete from rsfKatalog.mkatalog_farmasi_pabrik;
			delete from rsfKatalog.mkatalog_farmasi;
			delete from rsfKatalog.mkatalog_anggaranjnssub;
			delete from rsfKatalog.mkatalog_anggaranjns;
			delete from rsfKatalog.mkatalog_kelompok;
			delete from rsfKatalog.mkatalog_kemasan;
			delete from rsfKatalog.mkatalog_pbf;
			delete from rsfKatalog.mkatalog_pabrik;
			delete from rsfKatalog.mkatalog_brand;
			delete from rsfKatalog.mkatalog_generik;
			SELECT 		0 as statcode,
						1 as rowcount,
						concat('rsfKatalog mkatalog ... persiapan completed. ') as statmessage,
						'success' as data;
		ELSEIF (aOBJ = "selesai") THEN
			SELECT 		0 as statcode,
						1 as rowcount,
						concat('rsfKatalog mkatalog ... persiapan completed. ') as statmessage,
						'success' as data;
		ELSEIF (aOBJ = "analisaKatalog") THEN
			-- 1. Transaksi Resep Pasien
			insert into rsfKatalog.mkatalog_sync ( trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			SELECT		1 as trx_jenis,
						max(lynBarang.ID) as trx_katid,
						max(lynBarang.NAMA) as trx_katnama,
						max(lynBarang.KODE_BARANG) as trx_katkode,
						sum(ifnull(lynFarmasiRetur.JUMLAH,0)) as masuk_qty,
						sum(lynFarmasi.JUMLAH) as keluar_qty,
						count(1) as row_qty
				FROM	layanan.order_resep ordResep
						left join rsfMaster.msetting_ruangan msetting ON msetting.setting_inv = 1 and 
									msetting.status = 1 and msetting.jenis = 5 AND msetting.id = ordResep.TUJUAN
						LEFT JOIN pendaftaran.kunjungan dftKunj ON ordResep.NOMOR = dftKunj.REF
						LEFT JOIN pendaftaran.pendaftaran dftDaftar ON dftDaftar.NOMOR = dftKunj.NOPEN
						LEFT JOIN master.pasien dftPasien ON dftPasien.NORM = dftDaftar.NORM, 
						layanan.order_detil_resep ordResepDtl
						LEFT JOIN inventory.barang ordBarang ON ordResepDtl.FARMASI = ordBarang.ID
						LEFT JOIN layanan.farmasi lynFarmasi ON lynFarmasi.ID = ordResepDtl.REF
						LEFT JOIN inventory.barang lynBarang ON lynBarang.ID = lynFarmasi.FARMASI 
						LEFT JOIN (	select		max(xretur.ID_FARMASI) as ID_FARMASI,
												sum(xretur.JUMLAH) AS JUMLAH
										from	layanan.retur_farmasi xretur
										group   by xretur.ID_FARMASI 
									) lynFarmasiRetur on lynFarmasiRetur.ID_FARMASI = lynFarmasi.ID
				WHERE	ordResep.NOMOR 		 	 = ordResepDtl.ORDER_ID AND 
						ordResep.TANGGAL 			>= '2023-01-01' AND
						ordResep.STATUS         	 = 2 AND -- sudah diterima
						lynFarmasi.STATUS         	 = 2 AND -- sudah final
						ordResepDtl.FARMASI			!= 0 -- bukan barang dengan id = 0
				group	by lynBarang.ID
				having  masuk_qty != 0 or keluar_qty != 0
				order 	by lynBarang.ID;
			-- 2. Transaksi Penjualan
			insert into rsfKatalog.mkatalog_sync ( trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		2 as trx_jenis,
						max(trxJualDtl.BARANG) as trx_katid,
						max(mbarangRetur.NAMA) as trx_katnama,				
						max(COALESCE((mbarangRetur.kode_barang),'-')) as trx_katkode,
						sum(COALESCE((trxJualDtlRetur.JUMLAH), 0)) as masuk_qty,
						sum(COALESCE((trxJualDtl.JUMLAH), 0)) as keluar_qty,
						count(1) as row_qty
				from 	penjualan.penjualan trxJual
						left outer join penjualan.penjualan_detil trxJualDtl
						on trxJual.NOMOR = trxJualDtl.PENJUALAN_ID
						left outer join (
							select 		max(xRetur.PENJUALAN_ID) as PENJUALAN_ID,
										max(xRetur.PENJUALAN_DETIL_ID) as PENJUALAN_DETIL_ID,
										sum(xRetur.JUMLAH) as JUMLAH,
										max(xRetur.STATUS) as STATUS
								from	penjualan.retur_penjualan xRetur
								group   by 	xRetur.PENJUALAN_ID,
											xRetur.PENJUALAN_DETIL_ID ) trxJualDtlRetur
						on 	trxJualDtlRetur.PENJUALAN_ID = trxJual.NOMOR and
							trxJualDtlRetur.PENJUALAN_DETIL_ID = trxJualDtl.ID
						left outer join inventory.barang mbarangRetur
						on  mbarangRetur.ID = trxJualDtl.BARANG
						left outer join master.ruangan mRuang
						on mRuang.ID = trxJual.RUANGAN
				where	trxJual.TANGGAL				>= '2023-01-01' -- and 
						-- trxJual.STATUS 				= 2 -- sudah bayar
				GROUP	BY 	trxJualDtl.BARANG;
			-- 3. Hasil Produksi
			insert into rsfKatalog.mkatalog_sync ( trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		3 as trx_jenis,
						(mBarangHasil.ID) as trx_katid,
						(mBarangHasil.NAMA) as trx_katnama,
						COALESCE((mBarangHasil.kode_barang),'-') as trx_katkode,
						prod.QTY as masuk_qty,
						0 as keluar_qty,
						count(1) as row_qty
				from 	inventory.barang_produksi prod,
						inventory.barang mBarangHasil
				where	prod.BARANG 				 = mBarangHasil.ID and
						prod.STATUS     	 	     = 2 and
						prod.TANGGAL 				>= '2023-01-01'
				group 	by prod.BARANG;
			-- 4. bahan produksi
			insert into rsfKatalog.mkatalog_sync ( trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		4 as trx_jenis,
						(mRBarangBahan.BARANG) as trx_katid,
						(mBarangBahan.NAMA) as trx_katnama,
						COALESCE((mBarangBahan.kode_barang),'-') as trx_katkode,
						0 as masuk_qty,
						COALESCE((prodDetil.QTY), 0) as keluar_qty,
						count(1) as row_qty
				from 	inventory.barang_produksi prod, 
						inventory.barang_produksi_detil prodDetil,
						inventory.barang mBarangHasil,
						inventory.barang mBarangBahan,
						inventory.barang_ruangan mRBarangBahan,
						master.ruangan mRuangBahan
				where	prod.ID                		 = prodDetil.PRODUKSI and
						prod.BARANG 				 = mBarangHasil.ID and 
						mRBarangBahan.BARANG 	 	 = mBarangBahan.ID and
						mRBarangBahan.RUANGAN  		 = prod.RUANGAN and
						mRBarangBahan.BARANG   		 = prodDetil.BAHAN and
						mRuangBahan.id 				 = mRBarangBahan.ruangan AND
						prod.STATUS     	 	     = 2 and
						prod.TANGGAL 				>= '2023-01-01'
				group 	by mRBarangBahan.BARANG;
			-- 11. Transaksi Terima Pembelian
			insert into rsfKatalog.mkatalog_sync ( trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		11 as trx_jenis,
						max(teamMasterK.id)									as trx_katid,
						max(teamMasterK.nama_barang)						as trx_katnama,
						max(teamMasterK.kode)								as trx_katkode,
						sum(teamTrmxDtl.jumlah_item - 
						COALESCE(returrekanan.jumlah_item,0))				as masuk_qty,
						0 as keluar_qty,
						count(1) as row_qty
				from 	rsfTeamterima.transaksif_penerimaan teamTrmx
						left outer join
						rsfTeamterima.tdetailf_penerimaan teamTrmxDtl
						on 
						teamTrmx.kode 				 = teamTrmxDtl.kode_reff
						left outer join
						(
							select 		max(rcn.kode_refftrm) as kode_refftrm, max(rcndtl.id_katalog) as id_katalog,
										sum(rcndtl.jumlah_item) as jumlah_item, sum(rcndtl.jumlah_kemasan) as jumlah_kemasan
								from 	rsfTeamterima.tdetailf_return rcndtl, rsfTeamterima.transaksif_return rcn
								where 	rcn.kode 			= rcndtl.kode_reff AND
										rcn.ver_gudang      = 1 and
										rcn.sts_deleted		= 0
								group   by rcn.kode_refftrm, rcndtl.id_katalog
						) returrekanan
						on
						teamTrmx.kode 				= returrekanan.kode_refftrm AND
						teamTrmxDtl.id_reffkatalog  = returrekanan.id_katalog,
						rsfTeamterima.masterf_katalog teamMasterK
						left outer join rsfTeamterima.masterf_brand katBrand
						on katBrand.id = teamMasterK.id_brand
						left outer join rsfTeamterima.masterf_generik katGen
						on katGen.id = katBrand.id_generik
						left outer join rsfTeamterima.masterf_pabrik katPabrik
						on katPabrik.id = teamMasterK.id_pabrik
						left outer join rsfTeamterima.masterf_kemasan katKemasan
						on katKemasan.id = teamMasterK.id_kemasankecil,
						rsfTeamterima.masterf_pbf teamTrmxPbf
				where	teamTrmx.id_pbf 			 = teamTrmxPbf.id and
						teamMasterK.kode 			 = teamTrmxDtl.id_reffkatalog and
						teamTrmx.ver_tglgudang  	>= '2023-01-01' and 
						teamTrmx.ver_gudang 		 = 1
				group   by teamMasterK.kode;
			-- 21. Saldo Awal
			insert into rsfKatalog.mkatalog_sync ( trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		21 as trx_jenis,
						max(katalog_id) as trx_katid,
						max(katalog_nama) as trx_katnama, 
						max(katalog_kode) as trx_katkode, 
						sum(akhir) as masuk_qty,
						0 as keluar_qty,
						count(1) as row_qty
				FROM	rsfPelaporan.laporan_so_trx trx
				where   trx.sts_proses = 1
				group   by katalog_id;
		ELSEIF (aOBJ = "analisaKatalogdepo") THEN
			-- 1. Transaksi Resep Pasien
			insert into rsfKatalog.mkatalog_sync_depo ( trx_ruangan, trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			SELECT		ordResep.TUJUAN as trx_ruangan,
						1 as trx_jenis,
						max(lynBarang.ID) as trx_katid,
						max(lynBarang.NAMA) as trx_katnama,
						max(lynBarang.KODE_BARANG) as trx_katkode,
						sum(ifnull(lynFarmasiRetur.JUMLAH,0)) as masuk_qty,
						sum(lynFarmasi.JUMLAH) as keluar_qty,
						count(1) as row_qty
				FROM	layanan.order_resep ordResep
						left join rsfMaster.msetting_ruangan msetting ON msetting.setting_inv = 1 and 
									msetting.status = 1 and msetting.jenis = 5 AND msetting.id = ordResep.TUJUAN
						LEFT JOIN pendaftaran.kunjungan dftKunj ON ordResep.NOMOR = dftKunj.REF
						LEFT JOIN pendaftaran.pendaftaran dftDaftar ON dftDaftar.NOMOR = dftKunj.NOPEN
						LEFT JOIN master.pasien dftPasien ON dftPasien.NORM = dftDaftar.NORM, 
						layanan.order_detil_resep ordResepDtl
						LEFT JOIN inventory.barang ordBarang ON ordResepDtl.FARMASI = ordBarang.ID
						LEFT JOIN layanan.farmasi lynFarmasi ON lynFarmasi.ID = ordResepDtl.REF
						LEFT JOIN inventory.barang lynBarang ON lynBarang.ID = lynFarmasi.FARMASI 
						LEFT JOIN (	select		max(xretur.ID_FARMASI) as ID_FARMASI,
												sum(xretur.JUMLAH) AS JUMLAH
										from	layanan.retur_farmasi xretur
										group   by xretur.ID_FARMASI 
									) lynFarmasiRetur on lynFarmasiRetur.ID_FARMASI = lynFarmasi.ID
				WHERE	ordResep.NOMOR 		 	 = ordResepDtl.ORDER_ID AND 
						ordResep.TANGGAL 			>= '2023-01-01' AND
						ordResep.STATUS         	 = 2 AND -- sudah diterima
						lynFarmasi.STATUS         	 = 2 AND -- sudah final
						ordResepDtl.FARMASI			!= 0 -- bukan barang dengan id = 0
				group	by ordResep.TUJUAN, lynBarang.ID
				having  masuk_qty != 0 or keluar_qty != 0
				order 	by lynBarang.ID;
			-- 2. Transaksi Penjualan
			insert into rsfKatalog.mkatalog_sync_depo ( trx_ruangan, trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		trxJual.RUANGAN as trx_ruangan,
						2 as trx_jenis,
						max(trxJualDtl.BARANG) as trx_katid,
						max(mbarangRetur.NAMA) as trx_katnama,				
						max(COALESCE((mbarangRetur.kode_barang),'-')) as trx_katkode,
						sum(COALESCE((trxJualDtlRetur.JUMLAH), 0)) as masuk_qty,
						sum(COALESCE((trxJualDtl.JUMLAH), 0)) as keluar_qty,
						count(1) as row_qty
				from 	penjualan.penjualan trxJual
						left outer join penjualan.penjualan_detil trxJualDtl
						on trxJual.NOMOR = trxJualDtl.PENJUALAN_ID
						left outer join (
							select 		max(xRetur.PENJUALAN_ID) as PENJUALAN_ID,
										max(xRetur.PENJUALAN_DETIL_ID) as PENJUALAN_DETIL_ID,
										sum(xRetur.JUMLAH) as JUMLAH,
										max(xRetur.STATUS) as STATUS
								from	penjualan.retur_penjualan xRetur
								group   by 	xRetur.PENJUALAN_ID,
											xRetur.PENJUALAN_DETIL_ID ) trxJualDtlRetur
						on 	trxJualDtlRetur.PENJUALAN_ID = trxJual.NOMOR and
							trxJualDtlRetur.PENJUALAN_DETIL_ID = trxJualDtl.ID
						left outer join inventory.barang mbarangRetur
						on  mbarangRetur.ID = trxJualDtl.BARANG
						left outer join master.ruangan mRuang
						on mRuang.ID = trxJual.RUANGAN
				where	trxJual.TANGGAL				>= '2023-01-01' -- and 
						-- trxJual.STATUS 				= 2 -- sudah bayar
				GROUP	BY 	trxJual.RUANGAN, trxJualDtl.BARANG;
			-- 3. Hasil Produksi
			insert into rsfKatalog.mkatalog_sync_depo ( trx_ruangan, trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		prod.RUANGAN as trx_ruangan,
						3 as trx_jenis,
						(mBarangHasil.ID) as trx_katid,
						(mBarangHasil.NAMA) as trx_katnama,
						COALESCE((mBarangHasil.kode_barang),'-') as trx_katkode,
						prod.QTY as masuk_qty,
						0 as keluar_qty,
						count(1) as row_qty
				from 	inventory.barang_produksi prod,
						inventory.barang mBarangHasil
				where	prod.BARANG 				 = mBarangHasil.ID and
						prod.STATUS     	 	     = 2 and
						prod.TANGGAL 				>= '2023-01-01'
				group 	by prod.RUANGAN, prod.BARANG;
			-- 4. bahan produksi
			insert into rsfKatalog.mkatalog_sync_depo ( trx_ruangan, trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		prod.RUANGAN as trx_ruangan,
						4 as trx_jenis,
						(mRBarangBahan.BARANG) as trx_katid,
						(mBarangBahan.NAMA) as trx_katnama,
						COALESCE((mBarangBahan.kode_barang),'-') as trx_katkode,
						0 as masuk_qty,
						COALESCE((prodDetil.QTY), 0) as keluar_qty,
						count(1) as row_qty
				from 	inventory.barang_produksi prod, 
						inventory.barang_produksi_detil prodDetil,
						inventory.barang mBarangHasil,
						inventory.barang mBarangBahan,
						inventory.barang_ruangan mRBarangBahan,
						master.ruangan mRuangBahan
				where	prod.ID                		 = prodDetil.PRODUKSI and
						prod.BARANG 				 = mBarangHasil.ID and 
						mRBarangBahan.BARANG 	 	 = mBarangBahan.ID and
						mRBarangBahan.RUANGAN  		 = prod.RUANGAN and
						mRBarangBahan.BARANG   		 = prodDetil.BAHAN and
						mRuangBahan.id 				 = mRBarangBahan.ruangan AND
						prod.STATUS     	 	     = 2 and
						prod.TANGGAL 				>= '2023-01-01'
				group 	by prod.RUANGAN, mRBarangBahan.BARANG;
			-- 11. Transaksi Terima Pembelian
			insert into rsfKatalog.mkatalog_sync_depo ( trx_ruangan, trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		'101030111' as trx_ruangan,
						11 as trx_jenis,
						max(teamMasterK.id)									as trx_katid,
						max(teamMasterK.nama_barang)						as trx_katnama,
						max(teamMasterK.kode)								as trx_katkode,
						sum(teamTrmxDtl.jumlah_item - 
						COALESCE(returrekanan.jumlah_item,0))				as masuk_qty,
						0 as keluar_qty,
						count(1) as row_qty
				from 	rsfTeamterima.transaksif_penerimaan teamTrmx
						left outer join
						rsfTeamterima.tdetailf_penerimaan teamTrmxDtl
						on 
						teamTrmx.kode 				 = teamTrmxDtl.kode_reff
						left outer join
						(
							select 		max(rcn.kode_refftrm) as kode_refftrm, max(rcndtl.id_katalog) as id_katalog,
										sum(rcndtl.jumlah_item) as jumlah_item, sum(rcndtl.jumlah_kemasan) as jumlah_kemasan
								from 	rsfTeamterima.tdetailf_return rcndtl, rsfTeamterima.transaksif_return rcn
								where 	rcn.kode 			= rcndtl.kode_reff AND
										rcn.ver_gudang      = 1 and
										rcn.sts_deleted		= 0
								group   by rcn.kode_refftrm, rcndtl.id_katalog
						) returrekanan
						on
						teamTrmx.kode 				= returrekanan.kode_refftrm AND
						teamTrmxDtl.id_reffkatalog  = returrekanan.id_katalog,
						rsfTeamterima.masterf_katalog teamMasterK
						left outer join rsfTeamterima.masterf_brand katBrand
						on katBrand.id = teamMasterK.id_brand
						left outer join rsfTeamterima.masterf_generik katGen
						on katGen.id = katBrand.id_generik
						left outer join rsfTeamterima.masterf_pabrik katPabrik
						on katPabrik.id = teamMasterK.id_pabrik
						left outer join rsfTeamterima.masterf_kemasan katKemasan
						on katKemasan.id = teamMasterK.id_kemasankecil,
						rsfTeamterima.masterf_pbf teamTrmxPbf
				where	teamTrmx.id_pbf 			 = teamTrmxPbf.id and
						teamMasterK.kode 			 = teamTrmxDtl.id_reffkatalog and
						teamTrmx.ver_tglgudang  	>= '2023-01-01' and 
						teamTrmx.ver_gudang 		 = 1
				group   by teamMasterK.kode;
			-- 21. Saldo Awal
			insert into rsfKatalog.mkatalog_sync_depo ( trx_ruangan, trx_jenis, trx_katid, trx_katnama, trx_katkode, masuk_qty, keluar_qty, row_qty )
			select 		depo_kode as trx_ruangan,
						21 as trx_jenis,
						max(katalog_id) as trx_katid,
						max(katalog_nama) as trx_katnama, 
						max(katalog_kode) as trx_katkode, 
						sum(akhir) as masuk_qty,
						0 as keluar_qty,
						count(1) as row_qty
				FROM	rsfPelaporan.laporan_so_trx trx
				where   trx.sts_proses = 1
				group   by depo_kode, katalog_id;
		ELSEIF (aOBJ = "anggaranjns") THEN
			-- tidak ada kesetaraan anggaranjns di inventory
			insert into rsfKatalog.mkatalog_anggaranjns
						( id, kode, jenis_anggaran, sts_aktif, userid_in, sysdate_in, userid_updt,
						sysdate_updt )
			select 		id, kode, subjenis_anggaran, sts_aktif, userid_in, sysdate_in, userid_updt,
						sysdate_updt
				from	rsfTeamterima.masterf_subjenisanggaran;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog mkatalog_anggaranjns, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_anggaranjns;
		ELSEIF (aOBJ = "farmasi_update_sakti") THEN
			update      rsfKatalog.mkatalog_farmasi upd,
						(
							select 		sqSAKTI.id as id_sakti,
										frm.kode as katalog_kode
								from 	rsfKatalog.mkatalog_farmasi frm
										join 
										( 
											select		sakti.*
												from 	rsfPelaporan.tjurnal_sakti2022final sakti
												where   sakti.katalog_kode in
														(
															select 		tsf.katalog_kode
																from 	rsfPelaporan.tjurnal_sakti2022final tsf
																where   tsf.qty_akhir > 0
																group   by tsf.katalog_kode
																having  count(1) = 1
														)
										) sqSAKTI
										on sqSAKTI.katalog_kode = frm.kode
						) updReff
				SET		id_barang_sakti = updReff.id_sakti
				WHERE	upd.kode = updReff.katalog_kode;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog mapping barang sakti. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_farmasi
				WHERE	id_barang_sakti is not null;
		ELSEIF (aOBJ = "sakti") THEN
			insert into rsfKatalog.mkatalog_sakti
				(	id_hdr, kode, uraian, sts_aktif, userid_in, sysdate_in, userid_updt, sysdate_updt )
			select 		tsk.id as id_hdr,
						tsf.sakti_kode as kode,
						tsf.sakti_nama as uraian,
						case sts_mapping 
							when 1 then 1
							when 2 then 1
							else 0
						end as sts_aktif,
						0 as userid_in,
						CURRENT_TIMESTAMP() as sysdate_in,
						0 as userid_updt,
						CURRENT_TIMESTAMP() as sysdate_updt 
				from 	rsfPelaporan.tjurnal_sakti2022final tsf
						join rsfKatalog.mkatalog_sakti_hdr tsk
						on tsf.sakti_kode_klp = tsk.kode;

			-- check SAKTI double
			/*
			select tsf.katalog_kode, tsf.* from rsfPelaporan.tjurnal_sakti2022final tsf
			where tsf.katalog_kode in (
				select 		tsf.katalog_kode 
					from 	rsfPelaporan.tjurnal_sakti2022final tsf
					where   tsf.qty_akhir > 0
					group   by tsf.katalog_kode
					having  count(1) > 1
			)
			order by tsf.katalog_kode;
			*/
						
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog mkatalog_sakti, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_sakti;
		ELSEIF (aOBJ = "saktihdr") THEN
			insert into rsfKatalog.mkatalog_sakti_hdr
				(	kode, uraian, userid_in, sysdate_in, userid_updt, sysdate_updt )
			select 		tsk.sakti_kode_klp as kode, 
						tsk.sakti_nama_klp as uraian, 
						0 as userid_in, 
						CURRENT_TIMESTAMP() as sysdate_in, 
						0 as userid_updt, 
						CURRENT_TIMESTAMP() as sysdate_updt 
				from 	rsfPelaporan.tjurnal_sakti_klp tsk;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog mkatalog_sakti_hdr, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_sakti_hdr;
		ELSEIF (aOBJ = "anggaranjnssub") THEN
			-- tidak ada kesetaraan anggaranjnssub di inventory
			insert into rsfKatalog.mkatalog_anggaranjnssub
						( 	id, id_jenis, thn_aktif, kode,
							subjenis_anggaran, keterangan, sts_aktif,
							userid_in, sysdate_in, userid_updt, sysdate_updt )
				select		id, id_jenis, thn_aktif, kode,
							subjenis_anggaran, keterangan, sts_aktif,
							userid_in, sysdate_in, userid_updt, sysdate_updt 
					from	(
								select		CONCAT(RIGHT(CONCAT('00000',ms.id),5),
											RIGHT(CONCAT('00000',ra.id_subjenis),5),
											ra.thn_aktif) as akey, 
											ms.id as id, ra.id_subjenis as id_jenis,
											ra.thn_aktif as thn_aktif,
											ms.kode as kode,
											ms.subjenis_anggaran as subjenis_anggaran,
											ra.keterangan as keterangan,
											ms.sts_aktif as sts_aktif,
											ms.userid_in as userid_in,
											ms.sysdate_in as sysdate_in,
											ms.userid_updt as userid_updt,
											ms.sysdate_updt as sysdate_updt 
									from	rsfTeamterima.masterf_subjenisanggaran ms,
											rsfTeamterima.relasif_anggaran ra 
									where	ra.id_subjenis = ms.id
									order	by ms.id
							) anggaran,
							(
								select		min(CONCAT(RIGHT(CONCAT('00000',ms.id),5),
											RIGHT(CONCAT('00000',ra.id_subjenis),5),
											ra.thn_aktif)) as akey
									from	rsfTeamterima.masterf_subjenisanggaran ms,
											rsfTeamterima.relasif_anggaran ra 
									where	ra.id_subjenis = ms.id
									group   by ms.id, ra.id_subjenis
							) anggfilter
					where	anggaran.akey = anggfilter.akey
					order	by anggaran.akey;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog mkatalog_anggaranjnssub, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_anggaranjnssub;
		ELSEIF (aOBJ = "kelompok_inv") THEN
			insert into rsfKatalog.mkatalog_kelompok_inv ( jenis_inventory, kode_inventory, uraian_inventory )
			select 		case substring(id,1,1) 
							when '1' then 'Farmasi' 
							when '2' then 'Non Farmasi' 
						end as jenis_inventory, 
						id as kode_inventory,
						NAMA as uraian_inventory
				from 	inventory.kategori k where k.JENIS = 2;
				
			update 		mkatalog_kelompok upd,
						mkatalog_kelompok_inv updReff
				set		upd.id_inventory = updReff.id
				where	substring(updReff.kode_inventory,1,3) = substring(upd.id_kategori_simrsgos,1,3);

			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog kelompok_inv, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_kelompok_inv;
		ELSEIF (aOBJ = "kelompok") THEN
			insert		into rsfKatalog.mkatalog_kelompok
						( id_hardcode, kelompok_barang, kode, kode_temp, id_kategori_simrsgos, no_urut, sts_aktif, userid_updt, sysdate_updt )
			select 		1 as id_hardcode, CONCAT(invKatGrp.NAMA, ' ', invKat.NAMA) as kelompok_barang,
						'00' as kode,
						'00' as kode_temp,
						invKat.ID as id_kategori_simrsgos,
						1 as sts_aktif,
						0 as no_urut,
						9999 as userid_updt,
						CURRENT_TIMESTAMP() as sysdate_updt
				from 	inventory.kategori invKat
						join inventory.kategori invKatGrp
						on  invKatGrp.ID = substring(invKat.ID ,1,3) and invKatGrp.JENIS = 2
				where   invKat.JENIS = 3;
				
			-- mapping kelompokBarang
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  null, sts_aktif = 0, kode = '00';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  1, kode = '10', sts_aktif = 1 where id_kategori_simrsgos = '10101';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  2, kode = '12', sts_aktif = 1 where id_kategori_simrsgos = '10115';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  3, kode = '14', sts_aktif = 1 where id_kategori_simrsgos = '10116';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  4, kode = '16', sts_aktif = 1 where id_kategori_simrsgos = '10107';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  5, kode = '17', sts_aktif = 1 where id_kategori_simrsgos = '11101';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  6, kode = '20', sts_aktif = 1 where id_kategori_simrsgos = '10104';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  7, kode = '30', sts_aktif = 1 where id_kategori_simrsgos = '10105';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  8, kode = '40', sts_aktif = 1 where id_kategori_simrsgos = '10102';
			update rsfKatalog.mkatalog_kelompok set id_teamterima =  9, kode = '50', sts_aktif = 1 where id_kategori_simrsgos = '10112';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 10, kode = '60', sts_aktif = 1 where id_kategori_simrsgos = '10001';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 11, kode = '70', sts_aktif = 1 where id_kategori_simrsgos = '10113';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 12, kode = '22', sts_aktif = 1 where id_kategori_simrsgos = '10203';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 13, kode = '42', sts_aktif = 1 where id_kategori_simrsgos = '10211';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 14, kode = '80', sts_aktif = 1 where id_kategori_simrsgos = '10201';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 15, kode = '81', sts_aktif = 1 where id_kategori_simrsgos = '10801';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 16, kode = '82', sts_aktif = 1 where id_kategori_simrsgos = '10208';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 17, kode = '90', sts_aktif = 1 where id_kategori_simrsgos = '10212';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 18, kode = '25', sts_aktif = 1 where id_kategori_simrsgos = '10602';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 19, kode = '15', sts_aktif = 1 where id_kategori_simrsgos = '10503';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 20, kode = '83', sts_aktif = 1 where id_kategori_simrsgos = '10302';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 21, kode = 'BS', sts_aktif = 1 where id_kategori_simrsgos = '10114';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 22, kode = '85', sts_aktif = 1 where id_kategori_simrsgos = '10401';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 23, kode = 'PF', sts_aktif = 1 where id_kategori_simrsgos = '10204';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 25, kode = '81', sts_aktif = 1 where id_kategori_simrsgos = '10210';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 26, kode = 'KS', sts_aktif = 1 where id_kategori_simrsgos = '10901';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 28, kode = 'OB', sts_aktif = 1 where id_kategori_simrsgos = '10100';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 29, kode = '45', sts_aktif = 1 where id_kategori_simrsgos = '10209';
			update rsfKatalog.mkatalog_kelompok set id_teamterima = 30, kode = '11', sts_aktif = 1 where id_kategori_simrsgos = '10502';
			
			insert into inventory.kategori (ID, NAMA, JENIS, TANGGAL, OLEH, STATUS)
			values ('10213','BARANG REUSE', 3, current_timestamp, 9999, 1);
			
			insert		into rsfKatalog.mkatalog_kelompok
						(	id_teamterima, id_inventory, id_hardcode, id_kategori_simrsgos,
							kode, kelompok_barang, kode_temp, no_urut, gol, sts_aktif,
							bid, kel, subkel, subsubkel, userid_updt, sysdate_updt
						)
			select 		mk.id as id_teamterima, null as id_inventory, 1 as id_hardcode, '10213' as id_kategori_simrsgos,
						mk.kode, mk.kelompok_barang, mk.kode_temp, mk.no_urut, mk.gol, 1 as sts_aktif,
						mk.bid, mk.kel, mk.subkel, mk.subsubkel, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_kelompokbarang mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_kelompok ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null and id <> 31 and id <> 27;



			/*
			-- old
			-- tidak ada kesetaraan kelompok di inventory
			-- update 2023.07.17 kesetaraan kelompok di inventory di inventory.kategori
			insert		into rsfKatalog.mkatalog_kelompok
						(	id,	id_teamterima, id_inventory, id_hardcode, id_kategori_simrsgos,
							kode, kelompok_barang, kode_temp, no_urut, gol,
							bid, kel, subkel, subsubkel, userid_updt, sysdate_updt
						)
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 1 as id_hardcode, null as id_kategori_simrsgos,
						mk.kode, mk.kelompok_barang, mk.kode_temp, mk.no_urut, mk.gol,
						mk.bid, mk.kel, mk.subkel, mk.subsubkel, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_kelompokbarang mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_kelompok ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			*/
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog kelompok, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_kelompok;
		ELSEIF (aOBJ = "kemasan") THEN
			-- insert to rsfKatalog
			insert		into rsfKatalog.mkatalog_kemasan
						(	id, id_teamterima, id_inventory, kode, kode_med,
							nama_kemasan, sts_aktif, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, mk.kode, mk.kode_med,
						mk.nama_kemasan, mk.sts_aktif, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_kemasan mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_kemasan ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfKatalog.mkatalog_kemasan kemasan, inventory.satuan satuan
				SET		kemasan.id_inventory = satuan.id
				WHERE   kemasan.kode = satuan.nama and
						kemasan.id_inventory is null;
			
			/*
			-- check
			select   	* 
				from  	inventory.satuan masR
						left outer join rsfKatalog.mkatalog_kemasan masK
						on masR.ID = masK.id_inventory 
				where 	masK.id_inventory is null;
			*/
						
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into inventory.satuan ( NAMA, DESKRIPSI, TANGGAL, OLEH, STATUS )
				select 		kemasan.kode, kemasan.nama_kemasan, current_timestamp, 0, 1
					from 	rsfKatalog.mkatalog_kemasan kemasan
					where	kemasan.id_inventory is null;
				UPDATE 		rsfKatalog.mkatalog_kemasan kemasan, inventory.satuan satuan
					SET		kemasan.id_inventory = satuan.id
					WHERE   kemasan.kode = satuan.nama and
							kemasan.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog mkatalog_kemasan, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_kemasan;
		ELSEIF (aOBJ = "pbf") THEN
			-- insert to rsfKatalog
			insert		into rsfKatalog.mkatalog_pbf
						(	id, id_teamterima, id_inventory, 
							kode, nama_pbf, npwp, alamat, kota,
							kodepos, telp, fax, email, kepala_cabang,
							cp_name, cp_telp, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_pbf, mk.npwp, mk.alamat, mk.kota,
						mk.kodepos, mk.telp, mk.fax, mk.email, mk.kepala_cabang,
						mk.cp_name, mk.cp_telp, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_pbf mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_pbf ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfKatalog.mkatalog_pbf pbf, inventory.penyedia penyedia
				SET		pbf.id_inventory = penyedia.id
				WHERE   SUBSTR(pbf.nama_pbf,1,50) = penyedia.nama and
						pbf.id_inventory is null;

			/*
			-- check
			select   	* 
				from  	inventory.satuan masR
						left outer join rsfKatalog.mkatalog_kemasan masK
						on masR.ID = masK.id_inventory 
				where 	masK.id_inventory is null;
			*/

			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into inventory.penyedia ( NAMA, ALAMAT, TELEPON, FAX, TANGGAL, STATUS )
				select 		SUBSTR(pbf.nama_pbf,1,50), pbf.alamat, pbf.telp, pbf.fax, current_timestamp, 1
					from 	rsfKatalog.mkatalog_pbf pbf
					where	pbf.id_inventory is null;

				UPDATE 		rsfKatalog.mkatalog_pbf pbf, inventory.penyedia penyedia
					SET		pbf.id_inventory = penyedia.id
					WHERE   SUBSTR(pbf.nama_pbf,1,50) = penyedia.nama and
							pbf.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog pbf, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_pbf;
		ELSEIF (aOBJ = "pabrik") THEN
			-- insert to rsfKatalog
			insert		into rsfKatalog.mkatalog_pabrik
						(	id, id_teamterima, id_inventory, 
							kode, nama_pabrik, npwp, alamat, kota,
							kodepos, telp, fax, email, 
							cp_name, cp_telp, sts_aktif, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_pabrik, mk.npwp, mk.alamat, mk.kota,
						mk.kodepos, mk.telp, mk.fax, mk.email, 
						mk.cp_name, mk.cp_telp, mk.sts_aktif, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_pabrik mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_pabrik ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfKatalog.mkatalog_pabrik pabrik, 
						( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
				SET		pabrik.id_inventory = ref39pabrik.id
				WHERE   pabrik.nama_pabrik 	= ref39pabrik.deskripsi and
						pabrik.id_inventory is null;
						
			/*
			-- check
			select   	* 
				from  	master.referensi masR
						left outer join rsfKatalog.mkatalog_pabrik masK
						on masR.ID = masK.id_inventory 
				where  	JENIS = 39 and masK.id_inventory is null;
			*/
 
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into master.referensi ( JENIS, DESKRIPSI, REF_ID, STATUS )
				select 		39, pabrik.nama_pabrik, '', 9
					from 	rsfKatalog.mkatalog_pabrik pabrik
					where	pabrik.id_inventory is null;
				UPDATE 		rsfKatalog.mkatalog_pabrik pabrik, 
							( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
					SET		pabrik.id_inventory = ref39pabrik.id
					WHERE   pabrik.nama_pabrik 	= ref39pabrik.deskripsi and
							pabrik.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog pabrik, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_pabrik;
		ELSEIF (aOBJ = "generik") THEN
			-- tidak ada padanan generik id inventory
			insert		into rsfKatalog.mkatalog_generik
						(	id,	id_teamterima, id_inventory,
							kode, nama_generik, restriksi, userid_updt, sysdate_updt
						)
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_generik, mk.restriksi, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_generik mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_generik ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfKatalog.mkatalog_generik generik, 
						( select id, deskripsi from master.referensi where JENIS = 42) ref42generik
				SET		generik.id_inventory = ref42generik.id
				WHERE   generik.nama_generik = ref42generik.deskripsi and
						generik.id_inventory is null;
			UPDATE		rsfKatalog.mkatalog_generik SET id_inventory = 1313 WHERE id_teamterima = 1313;
			-- UPDATE		rsfKatalog.mkatalog_generik SET id_inventory = 1348 WHERE id_teamterima = 1348;

			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog generik, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_generik;
		ELSEIF (aOBJ = "brand") THEN
			-- tidak ada kesetaraan brand di inventory
			insert		into rsfKatalog.mkatalog_brand
						(	id,	id_teamterima, id_inventory, kode,
							id_generik, nama_dagang, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.id_generik, mk.nama_dagang, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_brand mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_brand ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog brand, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_brand;
		ELSEIF (aOBJ = "buffergudang") THEN
			-- insert to rsfKatalog
			-- select 		count(1) 
			-- 	from 	rsfTeamterima.laporan_buffer_gudang lbg,
			--			rsfTeamterima.masterf_generik mg 
			--	where 	mg.id = lbg.id_generik;
			insert		into rsfKatalog.mkatalog_buffer_gudang
						(	id_katalog, katalog_kode, id_generik, jenis_moving, lead_time, 
							persen_buffer, persen_leadtime,
							jumlah_avg, jumlah_buffer, jumlah_leadtime, jumlah_rop,
							sysdate_updt, userid_updt, status )
			select 		mf.id as id_katalog, mk.id_katalog, mg.id as id_generik,
						mk.jenis_moving, mk.lead_time, mk.persen_buffer, mk.persen_leadtime, 
						mk.jumlah_avg, mk.jumlah_buffer, mk.jumlah_leadtime, mk.jumlah_rop, 
						mk.sysdate_updt, mk.userid_updt, mk.status
				from 	rsfKatalog.mkatalog_farmasi mf,
						rsfKatalog.mkatalog_generik mg,
						rsfTeamterima.laporan_buffer_gudang mk
						left outer join
						(	select		id_katalog
								from	rsfKatalog.mkatalog_buffer_gudang ) subquery
						on 	mk.id_katalog 		= subquery.id_katalog
				where	mf.kode					= mk.id_katalog and
						mg.id_teamterima		= mk.id_generik and
						subquery.id_katalog is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog buffer gudang, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_buffer_gudang;
		ELSEIF (aOBJ = "farmasi_pabrik") THEN
			insert into rsfKatalog.mkatalog_farmasi_pabrik 
						( id, id_pabrik, id_teamterima, no_urut, sts_aktif, 
						  userid_in, sysdate_in, userid_updt, sysdate_updt )
			select		mkatalog_farmasi.id as id,
						mkatalog_farmasi.id_pabrik as id_pabrik,
						mkatalog_farmasi.id as id_teamterima,
						1 as no_urut,
						1 as sts_aktif,
						0 as userid_in,
						CURRENT_TIMESTAMP as sysdate_in,
						0 as userid_updt,
						CURRENT_TIMESTAMP as sysdate_updt
				from 	rsfKatalog.mkatalog_farmasi
				where	id_pabrik is not null and id < 14804;
			-- update id from inventory
			UPDATE 		rsfKatalog.mkatalog_farmasi_pabrik farmasi, 
						rsfKatalog.mkatalog_farmasi updReff, 
						inventory.barang barang
				SET		farmasi.id_inventory = barang.id
				WHERE   updReff.id  = farmasi.id and
						updReff.kode = barang.KODE_BARANG and
						farmasi.id_inventory is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog farmasi_pabrik, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_farmasi_pabrik;
		ELSEIF (aOBJ = "farmasi") THEN
			-- insert to rsfKatalog
			insert		into rsfKatalog.mkatalog_farmasi
						(	id, id_teamterima, id_inventory, 
							kode, nama_sediaan, nama_barang,
							id_brand, id_jenisbarang, id_kelompokbarang, id_kemasanbesar, id_kemasankecil, 
							id_sediaan, isi_kemasan, isi_sediaan, jumlah_itembeli, jumlah_itembonus,
							tgl_berlaku_bonus, tgl_berlaku_bonus_akhir, kemasan, jenis_barang, 
							id_pbf, id_pabrik, isi_dosis,
							harga_beli, harga_kemasanbeli, diskon_beli, harga_jual, diskon_jual,
							stok_adm, stok_fisik, stok_min, stok_opt,
							formularium_rs, formularium_nas, generik, live_saving, kode_barang_nasional,
							sts_frs, sts_fornas, sts_generik, sts_kronis, sts_livesaving,
							sts_produksi, sts_konsinyasi, sts_ekatalog, sts_sumbangan, sts_narkotika,
							sts_psikotropika, sts_prekursor, sts_keras, sts_bebas, sts_bebasterbatas,
							sts_part, sts_alat, sts_asset, sts_aktif, sts_hapus,
							moving, leadtime, optimum, buffer, zat_aktif, retriksi, keterangan, aktifasi,
							userid_in, sysdate_in, userid_updt, sysdate_updt, jml_max, kategori_warna, sts_pabrik )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_sediaan, mk.nama_barang,
						if(mk.id_brand = 0, null, mk.id_brand), anggaran.id as id_jenisbarang, mkelompokKatalog.id as id_kelompokbarang, 
						mkemasbesar.id as id_kemasanbesar, mkemaskecil.id as id_kemasankecil, 
						mk.id_sediaan, mk.isi_kemasan, mk.isi_sediaan, mk.jumlah_itembeli, mk.jumlah_itembonus,
						mk.tgl_berlaku_bonus, mk.tgl_berlaku_bonus_akhir, mk.kemasan, mk.jenis_barang, 
						if(mk.id_pbf = 0, null, mpbf.id), if(mk.id_pabrik = 0, null, mk.id_pabrik), 0 as isi_dosis,
						mk.harga_beli, mk.harga_kemasanbeli, mk.diskon_beli, mk.harga_jual, mk.diskon_jual,
						mk.stok_adm, mk.stok_fisik, mk.stok_min, mk.stok_opt,
						mk.formularium_rs, mk.formularium_nas, mk.generik, mk.live_saving, mk.kode_barang_nasional,
						mk.sts_frs, mk.sts_fornas, mk.sts_generik, mk.sts_kronis, mk.sts_livesaving,
						mk.sts_produksi, mk.sts_konsinyasi, mk.sts_ekatalog, mk.sts_sumbangan, mk.sts_narkotika,
						mk.sts_psikotropika, mk.sts_prekursor, mk.sts_keras, mk.sts_bebas, mk.sts_bebasterbatas,
						mk.sts_part, mk.sts_alat, mk.sts_asset, mk.sts_aktif, mk.sts_hapus,
						mk.moving, mk.leadtime, mk.optimum, mk.buffer, mk.zat_aktif, mk.retriksi, mk.keterangan, mk.aktifasi,
						mk.userid_in, mk.sysdate_in, mk.userid_updt, mk.sysdate_updt, mk.jml_max, 1, 1 as sts_pabrik
				from 	rsfTeamterima.masterf_katalog mk
						left outer join
						(	select		id_teamterima
								from	rsfKatalog.mkatalog_farmasi ) subquery
						on mk.id = subquery.id_teamterima
						left outer join rsfTeamterima.masterf_pbf mpbf
						on mpbf.id = mk.id_pbf
						left outer join rsfKatalog.mkatalog_kemasan mkemasbesar
						on mkemasbesar.id = mk.id_kemasanbesar
						left outer join rsfKatalog.mkatalog_kemasan mkemaskecil
						on mkemaskecil.id = mk.id_kemasankecil
						left outer join
						(
								select		max(id) as id
									from	(
												select		CONCAT(RIGHT(CONCAT('00000',ms.id),5),
															RIGHT(CONCAT('00000',ra.id_subjenis),5),
															ra.thn_aktif) as akey, 
															ms.id as id, ra.id_subjenis as id_jenis,
															ra.thn_aktif as thn_aktif,
															ms.kode as kode,
															ms.subjenis_anggaran as subjenis_anggaran,
															ra.keterangan as keterangan,
															ms.sts_aktif as sts_aktif,
															ms.userid_in as userid_in,
															ms.sysdate_in as sysdate_in,
															ms.userid_updt as userid_updt,
															ms.sysdate_updt as sysdate_updt 
													from	rsfTeamterima.masterf_subjenisanggaran ms,
															rsfTeamterima.relasif_anggaran ra 
													where	ra.id_subjenis = ms.id
													order	by ms.id
											) anggaranSub
									group	by id
						) anggaran
						on anggaran.id = mk.id_jenisbarang
						left outer join rsfTeamterima.masterf_kelompokbarang mkelompok
						on mkelompok.id = mk.id_kelompokbarang
						left outer join (
							select 		min(id) as id, 
										max(id_teamterima) as  id_teamterima 
								from 	rsfKatalog.mkatalog_kelompok mk
								group 	by mk.id_teamterima
						) mkelompokKatalog
						on mkelompokKatalog.id_teamterima = mk.id_kelompokbarang
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfKatalog.mkatalog_farmasi farmasi, inventory.barang barang
				SET		farmasi.id_inventory = barang.id
				WHERE   farmasi.kode = barang.KODE_BARANG and
						farmasi.id_inventory is null;
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into inventory.barang ( 
							   NAMA, KATEGORI, SATUAN, MERK, PENYEDIA, GENERIK, JENIS_GENERIK,
							   FORMULARIUM, STOK, HARGA_BELI, PPN, HARGA_JUAL,
							   MASA_BERLAKU, JENIS_PENGGUNAAN_OBAT, KLAIM_TERPISAH,
							   TANGGAL, OLEH, STATUS,
							   KODE_PSEDIA, KODE_BARANG, KODE_PERSEDIAAN, MOVING )
				select 		SUBSTR(farmasi.nama_barang,1,150), '1', kemasan.id_inventory, 
							pabrik.id_inventory, pbf.id_inventory, 
							0 as GENERIK, 
							2 as JENIS_GENERIK,   -- '1 : GENERIK, 2 : NON GENERIK',
							2 as FORMULARIUM,     -- '1 : FORMULARIUM 2: NON FORMULARIUM',
							0, 0, 0, 0, null, 0, 0,
							current_timestamp, 0, 1, '0', farmasi.kode, '', null
					from 	rsfKatalog.mkatalog_farmasi farmasi,
							rsfKatalog.mkatalog_kemasan kemasan,
							rsfKatalog.mkatalog_pbf pbf,
							rsfKatalog.mkatalog_pabrik pabrik
					where	farmasi.id_pabrik 			=  pabrik.id and
					        farmasi.id_pbf    			=  pbf.id and
							farmasi.id_kemasankecil 	=  kemasan.id and
							farmasi.id_inventory 		is null;

				UPDATE 		rsfKatalog.mkatalog_farmasi farmasi, inventory.barang barang
					SET		farmasi.id_inventory = barang.id
					WHERE   farmasi.kode = barang.KODE_BARANG and
							farmasi.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfKatalog katalog farmasi, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfKatalog.mkatalog_farmasi;
		ELSE
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('rsfKatalog, object ''', aOBJ,''' tidak ditemukan.') as statmessage,
						'' as data;
		END IF;
	-- COMMIT;
END //
DELIMITER ;
