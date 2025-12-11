PEMBENTUKAN laporan_mutasi_saldo_simgos
-----------------------------------------------------------------------
drop table if exists rsfPelaporan.laporan_mutasi_saldo_simgos;
create table rsfPelaporan.laporan_mutasi_saldo_simgos
(
   tahun                int not null,
   katalog_kode         varchar(15) not null,
   jumlah_awal          decimal(20,4) not null,
   jumlah_penerimaan    decimal(20,4) not null,
   jumlah_produksi      decimal(20,4) not null,
   jumlah_bahanprod     decimal(20,4) not null,
   jumlah_trx           decimal(20,4) not null,
   jumlah_opname        decimal(20,4) not null,
   jumlah_akhir         decimal(20,4) not null,
   jumlah_adj           decimal(20,4) not null,
   qty_awal             decimal(20,4) not null,
   qty_penerimaan       decimal(20,4) not null,
   sts_triwulan1only    char(1) not null,
   primary key (tahun, katalog_kode)
);

truncate table laporan_mutasi_saldo_simgos;
-- jumlah penerimaan dari laporan triwulan 1 yang jumlah_akhir <> 0
-- 2728 rows
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan,  jumlah_produksi, jumlah_bahanprod,
				jumlah_trx, jumlah_opname, jumlah_akhir,
				jumlah_adj, qty_awal, qty_penerimaan, sts_triwulan1only )
select 		tahun, katalog_kode, 
			sum(jumlah_akhir) as jumlah_awal,
			0 as jumlah_penerimaan, 0 as jumlah_produksi, 0 as jumlah_bahanprod,
			0 as jumlah_trx, 0 as jumlah_opname, 0 as jumlah_akhir,
			0 as jumlah_adj, 0 as qty_awal, 0 as qty_penerimaan, 
			'0' as sts_triwulan1only
	from 	laporan_mutasi_bulan
	where   tahun = 2022 and bulan = 3 and jumlah_akhir != 0
	group   by tahun, katalog_kode;

-- jumlah penerimaan dari transaksi penerimaan
-- 1590 rows inserted from 3075 rows dlap_persediaan_tterima
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan,  jumlah_produksi, jumlah_bahanprod,
				jumlah_trx, jumlah_opname, jumlah_akhir,
				jumlah_adj, qty_awal, qty_penerimaan, sts_triwulan1only )
select 		dlap.tahun, dlap.katalog_kode, 
			0 as jumlah_awal,
			0 as jumlah_penerimaan, 0 as jumlah_produksi, 0 as jumlah_bahanprod,
			0 as jumlah_trx, 0 as jumlah_opname, 0 as jumlah_akhir,
			0 as jumlah_adj, 0 as qty_awal, 0 as qty_penerimaan, 
			'0' as sts_triwulan1only
	from 	(	
				select		max(dlap_persediaan_tterima.tahun) as tahun, 
							max(dlap_persediaan_tterima.katalog_kode) as katalog_kode
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	dlap_persediaan_tterima.tahun = 2022 and 
							dlap_persediaan_tterima.bulan > 3 and
							qty_terima - qty_retur <> 0
					group	by	dlap_persediaan_tterima.tahun, 
								dlap_persediaan_tterima.katalog_kode
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

-- 3075 rows updated
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		max(tahun) as tahun, max(katalog_kode) as katalog_kode, 
							sum(qty_terima - qty_retur) as jumlah_penerimaan
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	tahun 					= 2022 and
							bulan 					> 3 and
							qty_terima - qty_retur <> 0
					group	by tahun, katalog_kode 
			) updReff
	set		upd.jumlah_penerimaan 	= updReff.jumlah_penerimaan
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- jumlah produksi dari transaksi produksi
-- 8 rows inserted from 29 rows mmapping_koreksiproduksi
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan,  jumlah_produksi, jumlah_bahanprod,
				jumlah_trx, jumlah_opname, jumlah_akhir,
				jumlah_adj, qty_awal, qty_penerimaan, sts_triwulan1only )
select 		dlap.tahun, dlap.katalog_kode, 
			0 as jumlah_awal,
			0 as jumlah_penerimaan, 0 as jumlah_produksi, 0 as jumlah_bahanprod,
			0 as jumlah_trx, 0 as jumlah_opname, 0 as jumlah_akhir,
			0 as jumlah_adj, 0 as qty_awal, 0 as qty_penerimaan, 
			'0' as sts_triwulan1only
	from 	(	
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd
							left outer join
							inventory.barang invBarang
							on mapProd.id_inventory = invBarang.ID
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'hasil'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

-- 29 rows updated
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
							inventory.barang invBarang
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	mapProd.id_inventory = invBarang.ID and
							( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'hasil'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) updReff
	set		upd.jumlah_produksi 	= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- update jumlah bahan produksi
-- 49 rows
-- cek dulu bahan di luar track
select 		dlap.tahun, dlap.katalog_kode
	from 	(	
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
							inventory.barang invBarang
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	mapProd.id_inventory = invBarang.ID and
							( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'bahan'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
							inventory.barang invBarang
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	mapProd.id_inventory = invBarang.ID and
							( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'bahan'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) updReff
	set		upd.jumlah_bahanprod 	= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- update jumlah Opname
-- 2681 rows updated from 2699 rows opname
-- cek dulu opname di luar track (ada 18 rows, sejumlah 83)
select 		dlap.tahun, dlap.katalog_kode, dlap.qty
	from 	(	
				select 		2022 as tahun,
							max(katalog_kode) as katalog_kode, 
							max(katalog_id) as katalog_id, 
							max(katalog_nama) as katalog_nama, 
							sum(qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											so.TANGGAL 	> '2022-12-16' and
											sod.MANUAL  != 0 and
											so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
															'101030102', -- Depo IRJ LT 2
															'101030103', -- Depo Griya Husada
															'101030104', -- Depo IGD
															'101030105', -- Depo OK CITO
															'101030106', -- Depo Anggrek
															'101030107', -- Depo Bougenville
															'101030108', -- Depo IBS
															'101030109', -- Depo Teratai
															'101030110', -- Depo Produksi
															'101030111', -- Gudang Farmasi
															'101030112', -- Depo IRJ LT 3
															'101030113', -- Depo UKVI
															'101030114', -- Gudang Expired
															'101030115', -- Gudang Gas Medis
															'101030116', -- Gudang Konsinyasi
															'101030117', -- Gudang Rusak
															'101030118', -- Depo Metadon
															'101030119') -- Gudang Reused 
							) queryOpname
					group	by katalog_kode
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							max(katalog_kode) as katalog_kode, 
							max(katalog_id) as katalog_id, 
							max(katalog_nama) as katalog_nama, 
							sum(qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											so.TANGGAL 	> '2022-12-16' and
											sod.MANUAL  != 0 and
											so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
															'101030102', -- Depo IRJ LT 2
															'101030103', -- Depo Griya Husada
															'101030104', -- Depo IGD
															'101030105', -- Depo OK CITO
															'101030106', -- Depo Anggrek
															'101030107', -- Depo Bougenville
															'101030108', -- Depo IBS
															'101030109', -- Depo Teratai
															'101030110', -- Depo Produksi
															'101030111', -- Gudang Farmasi
															'101030112', -- Depo IRJ LT 3
															'101030113', -- Depo UKVI
															'101030114', -- Gudang Expired
															'101030115', -- Gudang Gas Medis
															'101030116', -- Gudang Konsinyasi
															'101030117', -- Gudang Rusak
															'101030118', -- Depo Metadon
															'101030119') -- Gudang Reused 
							) queryOpname
					group	by katalog_kode
			) updReff
	set		upd.jumlah_opname 		= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;


-- ############ Proses untuk menabahkan data saldo triwulan 1 
-- insert / update from laporan_mutasi_bulan 2022/1
-- 230 rows inserted from 2687 rows opname
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan, 
				jumlah_produksi, jumlah_bahanprod, jumlah_trx,
				jumlah_opname, jumlah_adj, jumlah_akhir,
                qty_awal, qty_penerimaan, sts_triwulan1only
			)
select 		dlap.tahun, dlap.katalog_kode,
			0 as jumlah_awal, 0 as jumlah_penerimaan, 
			0 as jumlah_produksi, 0 as jumlah_bahanprod, 0 as jumlah_trx,
			0 as jumlah_opname, 0 as jumlah_adj, 0 as jumlah_akhir,
            0 as qty_awal, 0 as qty_penerimaan, '1' as sts_triwulan1only
	from 	(	
				select 		tahun, katalog_kode, 
							sum(jumlah_awal) as jumlah_awal
					from 	laporan_mutasi_bulan
					where   tahun = 2022 and bulan = 1 and jumlah_awal <> 0
					group   by tahun, katalog_kode
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

-- 2687 rows updated
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		tahun, katalog_kode, 
							sum(jumlah_awal) as jumlah_awal
					from 	laporan_mutasi_bulan
					where   tahun = 2022 and bulan = 1 and jumlah_awal <> 0
					group   by tahun, katalog_kode
			) updReff
	set		upd.qty_awal 			= updReff.jumlah_awal
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- ############ Proses untuk menabahkan data penerimaan triwulan 1 
-- insert / update from dlap_persediaan_tterima 2022 triwulan 1
-- 160 rows inserted from 1870 rows opname
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan,  jumlah_produksi, jumlah_bahanprod,
				jumlah_trx, jumlah_opname, jumlah_akhir,
				jumlah_adj, qty_awal, qty_penerimaan, sts_triwulan1only )
select 		dlap.tahun, dlap.katalog_kode, 
			0 as jumlah_awal,
			0 as jumlah_penerimaan, 0 as jumlah_produksi, 0 as jumlah_bahanprod,
			0 as jumlah_trx, 0 as jumlah_opname, 0 as jumlah_akhir,
			0 as jumlah_adj, 0 as qty_awal, 0 as qty_penerimaan, 
			'1' as sts_triwulan1only
	from 	(	
				select		max(dlap_persediaan_tterima.tahun) as tahun, 
							max(dlap_persediaan_tterima.katalog_kode) as katalog_kode
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	dlap_persediaan_tterima.tahun = 2022 and 
							dlap_persediaan_tterima.bulan < 4 and
							qty_terima - qty_retur <> 0
					group	by	dlap_persediaan_tterima.tahun, 
								dlap_persediaan_tterima.katalog_kode
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

-- 1870 rows updated
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select		max(dlap_persediaan_tterima.tahun) as tahun, 
							max(dlap_persediaan_tterima.katalog_kode) as katalog_kode,
							sum(qty_terima - qty_retur) as jumlah_penerimaan
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	dlap_persediaan_tterima.tahun = 2022 and 
							dlap_persediaan_tterima.bulan < 4 and
							qty_terima - qty_retur <> 0
					group	by	dlap_persediaan_tterima.tahun, 
								dlap_persediaan_tterima.katalog_kode
			) updReff
	set		upd.qty_penerimaan 		= updReff.jumlah_penerimaan
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- ############ Proses update jumlah transaksi
-- update from dlap_persediaan.trx_jenis = 30,33,52 (+) 34,35,31 (-) setelah bulan 3
-- cek dulu bahan di luar track
-- 360 rows diluar track dari 4716 rows, jika sts_triwulan1only = '0'
-- 0 rows diluar track dari 4716 rows, jika tidak filter sts_triwulan1only
select 		dlap.tahun, dlap.katalog_kode
	from 	(	
				select		2022 as tahun,
							max(katalog_kode) as katalog_kode,
							sum(qty) as qty
					from	(
								select 		mk.kelompok_barang as kelompok_barang,
											lmss.katalog_kode as katalog_kode,
											mf.nama_barang as katalog_nama,
											COALESCE(trxPersediaan.qty_transaksi,0) as qty
									from 	laporan_mutasi_saldo_simgos lmss
											left outer join
											rsfMaster.mkatalog_farmasi mf
											on  mf.kode = lmss.katalog_kode
											left outer join
											rsfMaster.mkatalog_kelompok mk 
											on mk.id = mf.id_kelompokbarang
											left outer join
											(
												select 		sum(
																dlap.jml_trxpersediaan * case dlap.trx_jenis 
																	when 30 then 1 
																	when 33 then 1 
																	when 52 then 1 
																	else -1 
																end
															) as qty_transaksi,
															max(mf.kode) as katalog_kode,
															max(dlap.katalog_id) as inv_katalog_id,
															max(dlap.katalog_nama) as inv_katalog_nama,
															max(dlap.katalog_kode) as inv_katalog_kode
													from 	rsfPelaporan.dlap_persediaan dlap left outer join
															rsfMaster.mkatalog_farmasi mf
															on	dlap.katalog_id 	= mf.id_inventory
													where	(	dlap.trx_jenis 		= 30 or
																dlap.trx_jenis 		= 31 or
																dlap.trx_jenis 		= 33 or
																dlap.trx_jenis 		= 34 or
																dlap.trx_jenis 		= 35 or
																dlap.trx_jenis 		= 52 ) and
															dlap.bulan 			> '202203'
													group   by dlap.katalog_id
											) trxPersediaan
											on	lmss.katalog_kode	= trxPersediaan.katalog_kode
							) trxPersediaan
					group	by katalog_kode
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
					where	sts_triwulan1only = '0' or sts_triwulan1only = '1'
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select		2022 as tahun,
							max(katalog_kode) as katalog_kode,
							sum(qty) as qty
					from	(
								select 		mk.kelompok_barang as kelompok_barang,
											lmss.katalog_kode as katalog_kode,
											mf.nama_barang as katalog_nama,
											COALESCE(trxPersediaan.qty_transaksi,0) as qty
									from 	laporan_mutasi_saldo_simgos lmss
											left outer join
											rsfMaster.mkatalog_farmasi mf
											on  mf.kode = lmss.katalog_kode
											left outer join
											rsfMaster.mkatalog_kelompok mk 
											on mk.id = mf.id_kelompokbarang
											left outer join
											(
												select 		sum(
																dlap.jml_trxpersediaan * case dlap.trx_jenis 
																	when 30 then 1 
																	when 33 then 1 
																	when 52 then 1 
																	else -1 
																end
															) as qty_transaksi,
															max(mf.kode) as katalog_kode,
															max(dlap.katalog_id) as inv_katalog_id,
															max(dlap.katalog_nama) as inv_katalog_nama,
															max(dlap.katalog_kode) as inv_katalog_kode
													from 	rsfPelaporan.dlap_persediaan dlap left outer join
															rsfMaster.mkatalog_farmasi mf
															on	dlap.katalog_id 	= mf.id_inventory
													where	(	dlap.trx_jenis 		= 30 or
																dlap.trx_jenis 		= 31 or
																dlap.trx_jenis 		= 33 or
																dlap.trx_jenis 		= 34 or
																dlap.trx_jenis 		= 35 or
																dlap.trx_jenis 		= 52 ) and
															dlap.bulan 			> '202203'
													group   by dlap.katalog_id
											) trxPersediaan
											on	lmss.katalog_kode	= trxPersediaan.katalog_kode
							) trxPersediaan
					group	by katalog_kode
			) updReff
	set		upd.jumlah_trx 			= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- ############ Proses hitung total dan hitung nilai ajusment
update 		rsfPelaporan.laporan_mutasi_saldo_simgos
	set		jumlah_akhir = jumlah_awal + jumlah_penerimaan + jumlah_produksi - jumlah_trx - jumlah_bahanprod,
			jumlah_adj   = (jumlah_awal + jumlah_penerimaan + jumlah_produksi - jumlah_trx - jumlah_bahanprod) - jumlah_opname;

-- LAPORAN FINAL
--------------------------------------
-- QUERY LAPORAN FINAL


select		cast((lapPers.jumlah_adj * 100 / lapPers.jumlah_trx) AS SIGNED) as persen_adj,
			lapPers.katalog_kode as katalog_kode,
			mk.nama_barang as katalog_nama,
			lapPers.sts_triwulan1only as habisDiTW1,
			lapPers.qty_awal as awal2022,
			lapPers.qty_penerimaan as pengadaanTW1,
			lapPers.jumlah_awal as awal,
			lapPers.jumlah_penerimaan as pengadaan,
			lapPers.jumlah_produksi as prodHasil,
			lapPers.jumlah_bahanprod as prodBahan,
			lapPers.jumlah_trx as transaksi_simgos,
			lapPers.jumlah_trx + lapPers.jumlah_adj as transaksi,
			lapPers.jumlah_adj,
			lapPers.jumlah_opname as opname
	from 	rsfPelaporan.laporan_mutasi_saldo_simgos lapPers
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = lapPers.katalog_kode
	where	lapPers.sts_triwulan1only = '1' or lapPers.sts_triwulan1only = '0'
 


==================================================================================================
==================================================================================================
==================================================================================================





				
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		tahun, katalog_kode, 
							sum(jumlah_akhir) as jumlah_awal
					from 	laporan_mutasi_bulan
					where   tahun = 2022 and bulan = 3 and jumlah_akhir != 0
					group   by tahun, katalog_kode
			) updReff
	set		upd.sts_triwulan1only 	= '0'
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;




truncate table laporan_mutasi_saldo_simgos;
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan, 
				jumlah_produksi, jumlah_akhir )
select 		tahun, katalog_kode, 
			sum(jumlah_akhir) as jumlah_awal,
			0 as jumlah_penerimaan,
			0 as jumlah_produksi,
			0 as jumlah_akhir
	from 	laporan_mutasi_bulan
	where   tahun = 2022 and bulan = 3 and jumlah_akhir != 0
	group   by tahun, katalog_kode;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		max(tahun) as tahun, max(katalog_kode) as katalog_kode, 
							sum(qty_terima - qty_retur) as jumlah_penerimaan
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	tahun 					= 2022 and
							bulan 					> 3 and
							qty_terima - qty_retur <> 0
					group	by tahun, katalog_kode 
			) updReff
	set		upd.jumlah_penerimaan 	= updReff.jumlah_penerimaan
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;
				



Pembentukan laporan persediaan
---------------------------------
-- 1. Sweeping kode
-- a. keluarkan koreksi produksi yang uraiannya tidak jelas
-- 
update mmapping_koreksiproduksi set sts_proses = '0';
select * from mmapping_koreksiproduksi where uraian <> ''
update mmapping_koreksiproduksi set sts_proses = '2' where uraian = '';
select * from mmapping_koreksiproduksi where sts_proses = '0';
update mmapping_koreksiproduksi set sts_proses = '3' where id_produksi = 14;
update mmapping_koreksiproduksi set sts_proses = '3' where id_produksi = 119;
update mmapping_koreksiproduksi set sts_proses = '3' where id_produksi = 177;
update mmapping_koreksiproduksi set sts_proses = '3' where id_produksi = 187;
update mmapping_koreksiproduksi set sts_proses = '3' where id_produksi = 298;
update mmapping_koreksiproduksi set sts_proses = '3' where id_produksi = 269;
update mmapping_koreksiproduksi set sts_proses = '4', katalog_kode = uraian where sts_proses = '0';
select * from mmapping_koreksiproduksi where uraian <> ''

-- cek kode barang bahan produksi di luar track
-- kode 50C005, bahan tidak diproses karena kode di luar track DAN nama barang DOUBLE
-- kode PFA047, di proses karena ada hasil produksi dengan kode yang sama
select 		invBarang.NAMA as katalog_nama, invBarang.KODE_BARANG as katalog_kode, 
			mapProd.id_produksi, mapProd.id_inventory,
			mapProd.hsl_produksi, mapProd.qty
	from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
			inventory.barang invBarang
			left outer join laporan_mutasi_saldo_simgos lap2022
			on lap2022.katalog_kode = invBarang.KODE_BARANG 
	where	mapProd.id_inventory = invBarang.ID and
			( mapProd.sts_proses = '2' or
			  mapProd.sts_proses = '4' ) and
			mapProd.hsl_produksi = 'bahan' and
			lap2022.katalog_kode  is null;
update mmapping_koreksiproduksi set sts_proses = '5' where id_produksi = 6 and id_inventory = 257;

-- cek kode barang hasil produksi di luar track
update 		mmapping_koreksiproduksi 
	set 	sts_proses 	= '6' 
	where 	id_produksi in (
				select		id_produksi
					from	(
								select 		invBarang.NAMA as katalog_nama, 
											case mapProd.katalog_kode
												when '' then invBarang.KODE_BARANG 
												else mapProd.katalog_kode end as katalog_kode,
											mapProd.id_produksi, mapProd.id_inventory,
											mapProd.hsl_produksi, mapProd.qty
									from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
											inventory.barang invBarang
											left outer join laporan_mutasi_saldo_simgos lap2022
											on lap2022.katalog_kode = invBarang.KODE_BARANG 
									where	mapProd.id_inventory = invBarang.ID and
											( mapProd.sts_proses = '2' or
											  mapProd.sts_proses = '4' ) and
											mapProd.hsl_produksi = 'hasil'
							) hasilProduksi
					where	hasilProduksi.katalog_kode = ''
			);
			
-- jumlah produksi dari transaksi produksi
insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan, 
				jumlah_produksi, jumlah_akhir )
select 		dlap.tahun, dlap.katalog_kode,
			0 as jumlah_awal,
			0 as jumlah_penerimaan,
			0 as jumlah_produksi,
			0 as jumlah_akhir
	from 	(	
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd
							left outer join
							inventory.barang invBarang
							on mapProd.id_inventory = invBarang.ID
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'hasil'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
							inventory.barang invBarang
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	mapProd.id_inventory = invBarang.ID and
							( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'hasil'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) updReff
	set		upd.jumlah_produksi 	= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;


-- b. keluarkan koreksi opname yang uraiannya tidak jelas
-- 
update mmapping_koreksiopname set sts_proses = '0';

select * from mmapping_koreksiopname where uraian <> '';
-- 40A076/40A107
select * from mmapping_koreksiopname where uraian = '40A076/40A107';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40A107','40A076');
update mmapping_koreksiopname set katalog_kode = '40A076' where uraian = '40A076/40A107';
-- 40D099.1/40D099/40D108/40D101
select * from mmapping_koreksiopname where uraian = '40D099.1/40D099/40D108/40D101';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40D099.1','40D099','40D108','40D101');
update mmapping_koreksiopname set katalog_kode = '40D099.1' where uraian = '40D099.1/40D099/40D108/40D101';
-- 12D026/12D030
select * from mmapping_koreksiopname where uraian = '12D026/12D030';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('12D026','12D030');
update mmapping_koreksiopname set katalog_kode = '12D026' where uraian = '12D026/12D030';
-- 40O049/40O050
select * from mmapping_koreksiopname where uraian = '40O049/40O050';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40O049','40O050');
update mmapping_koreksiopname set katalog_kode = '40O049' where uraian = '40O049/40O050';
-- 40O056/40O044/40O052/40O054
select * from mmapping_koreksiopname where uraian = '40O056/40O044/40O052/40O054';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40O056','40O044','40O052','40O054');
update mmapping_koreksiopname set katalog_kode = '40O056' where uraian = '40O056/40O044/40O052/40O054';
-- 10P225/10P236
select * from mmapping_koreksiopname where uraian = '10P225/10P236';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('10P225','10P236');
update mmapping_koreksiopname set katalog_kode = '10P225' where uraian = '10P225/10P236';
-- 40P012.7/40P012.71
select * from mmapping_koreksiopname where uraian = '40P012.7/40P012.71';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40P012.7','40P012.71');
update mmapping_koreksiopname set katalog_kode = '40P012.7' where uraian = '40P012.7/40P012.71';
-- 40S101/40S072/40S100
select * from mmapping_koreksiopname where uraian = '40S101/40S072/40S100';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40S101','40S072','40S100');
update mmapping_koreksiopname set katalog_kode = '40S101' where uraian = '40S101/40S072/40S100';
-- 10V132/10V136
select * from mmapping_koreksiopname where uraian = '10V132/10V136';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('10V132','10V136');
update mmapping_koreksiopname set katalog_kode = '10V132' where uraian = '10V132/10V136';
-- 80E171/80E120
select * from mmapping_koreksiopname where uraian = '80E171/80E120';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('80E171','80E120');
update mmapping_koreksiopname set katalog_kode = '80E171' where uraian = '80E171/80E120';
-- 40N076/40N005
select * from mmapping_koreksiopname where uraian = '40N076/40N005';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40N076','40N005');
update mmapping_koreksiopname set katalog_kode = '40N076' where uraian = '40N076/40N005';
-- 40C018/40C099
select * from mmapping_koreksiopname where uraian = '40C018/40C099';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40C018','40C099');
update mmapping_koreksiopname set katalog_kode = '40C018' where uraian = '40C018/40C099';
-- 10H101/10H099.2
select * from mmapping_koreksiopname where uraian = '10H101/10H099.2';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('10H101','10H099.2');
update mmapping_koreksiopname set katalog_kode = '10H101' where uraian = '10H101/10H099.2';
-- 10H101/10H099.2
select * from mmapping_koreksiopname where uraian = '40P012.033/40P013';
select * from laporan_mutasi_saldo_simgos where katalog_kode in ('40P012.033','40P013');
update mmapping_koreksiopname set katalog_kode = '40P012.033' where uraian = '40P012.033/40P013';

select * from mmapping_koreksiopname where uraian <> '' and katalog_kode is null;
update 		mmapping_koreksiopname 
	set 	katalog_kode = uraian
	where	uraian 			<> '' and 
			katalog_kode 	is null;


-- daftar barang opname yang masih di luar track
select 		dlap.katalog_kode, dlap.katalog_nama, dlap.id_inventory
	from 	(	
				select 		2022 as tahun,
							max(invBarang.NAMA) as katalog_nama,
							max(mapProd.id_inventory) as id_inventory,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiopname mapProd
							left outer join
							inventory.barang invBarang
							on mapProd.id_inventory = invBarang.ID
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

alter table laporan_mutasi_saldo_simgos add jumlah_opname decimal(20,4) null;
alter table laporan_mutasi_saldo_simgos add jumlah_bahanprod decimal(20,4) null;
alter table laporan_mutasi_saldo_simgos add jumlah_trx decimal(20,4) null;
alter table laporan_mutasi_saldo_simgos add jumlah_adj decimal(20,4) null;
update		laporan_mutasi_saldo_simgos
	set		jumlah_opname = 0,
			jumlah_bahanprod = 0,
			jumlah_trx = 0,
			jumlah_adj = 0;

-- c. update jumlah bahan produksi
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							case mapProd.katalog_kode
								when '' then invBarang.KODE_BARANG 
								else mapProd.katalog_kode end as katalog_kode,
							sum(mapProd.qty) as qty
					from 	rsfPelaporan.mmapping_koreksiproduksi mapProd,
							inventory.barang invBarang
							left outer join laporan_mutasi_saldo_simgos lap2022
							on lap2022.katalog_kode = invBarang.KODE_BARANG 
					where	mapProd.id_inventory = invBarang.ID and
							( mapProd.sts_proses = '2' or
							  mapProd.sts_proses = '4' ) and
							mapProd.hsl_produksi = 'bahan'
					group	by	case mapProd.katalog_kode
									when '' then invBarang.KODE_BARANG 
									else mapProd.katalog_kode end
			) updReff
	set		upd.jumlah_bahanprod 	= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- d. update jumlah opname
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							max(katalog_kode) as katalog_kode, 
							max(katalog_id) as katalog_id, 
							max(katalog_nama) as katalog_nama, 
							sum(qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											so.TANGGAL 	> '2022-12-16' and
											sod.MANUAL  != 0 and
											so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
															'101030102', -- Depo IRJ LT 2
															'101030103', -- Depo Griya Husada
															'101030104', -- Depo IGD
															'101030105', -- Depo OK CITO
															'101030106', -- Depo Anggrek
															'101030107', -- Depo Bougenville
															'101030108', -- Depo IBS
															'101030109', -- Depo Teratai
															'101030110', -- Depo Produksi
															'101030111', -- Gudang Farmasi
															'101030112', -- Depo IRJ LT 3
															'101030113', -- Depo UKVI
															'101030114', -- Gudang Expired
															'101030115', -- Gudang Gas Medis
															'101030116', -- Gudang Konsinyasi
															'101030117', -- Gudang Rusak
															'101030118', -- Depo Metadon
															'101030119') -- Gudang Reused 
							) queryOpname
					group	by katalog_kode
			) updReff
	set		upd.jumlah_opname 		= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- croscek ulang dengan rsfPelaporan.mmapping_koreksiopname
-- harusnya mapKOpname.id_inventory tidak null
select 		updReff.*
	from 	(
				select 		2022 as tahun,
							max(katalog_kode) as katalog_kode, 
							max(katalog_id) as katalog_id, 
							max(katalog_nama) as katalog_nama, 
							sum(qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											(mapKOpname.id_inventory) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											so.TANGGAL 	> '2022-12-16' and
											sod.MANUAL  != 0 and
											so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
															'101030102', -- Depo IRJ LT 2
															'101030103', -- Depo Griya Husada
															'101030104', -- Depo IGD
															'101030105', -- Depo OK CITO
															'101030106', -- Depo Anggrek
															'101030107', -- Depo Bougenville
															'101030108', -- Depo IBS
															'101030109', -- Depo Teratai
															'101030110', -- Depo Produksi
															'101030111', -- Gudang Farmasi
															'101030112', -- Depo IRJ LT 3
															'101030113', -- Depo UKVI
															'101030114', -- Gudang Expired
															'101030115', -- Gudang Gas Medis
															'101030116', -- Gudang Konsinyasi
															'101030117', -- Gudang Rusak
															'101030118', -- Depo Metadon
															'101030119') -- Gudang Reused 
							) queryOpname
					group	by katalog_kode, katalog_id
			) updReff
			left outer join rsfPelaporan.laporan_mutasi_saldo_simgos upd
			on 	upd.tahun 				= updReff.tahun and
				upd.katalog_kode 		= updReff.katalog_kode
	where	upd.katalog_kode is null;

-- e. update jumlah transaksi
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select		2022 as tahun,
							max(katalog_kode) as katalog_kode,
							sum(qty) as qty
					from	(
								select 		mk.kelompok_barang as kelompok_barang,
											lmss.katalog_kode as katalog_kode,
											mf.nama_barang as katalog_nama,
											COALESCE(trxPersediaan.qty_transaksi,0) as qty
									from 	laporan_mutasi_saldo_simgos lmss
											left outer join
											rsfMaster.mkatalog_farmasi mf
											on  mf.kode = lmss.katalog_kode
											left outer join
											rsfMaster.mkatalog_kelompok mk 
											on mk.id = mf.id_kelompokbarang
											left outer join
											(
												select 		sum(
																dlap.jml_trxpersediaan * case dlap.trx_jenis 
																	when 30 then 1 
																	when 33 then 1 
																	when 52 then 1 
																	else -1 
																end
															) as qty_transaksi,
															max(mf.kode) as katalog_kode,
															max(dlap.katalog_id) as inv_katalog_id,
															max(dlap.katalog_nama) as inv_katalog_nama,
															max(dlap.katalog_kode) as inv_katalog_kode
													from 	rsfPelaporan.dlap_persediaan dlap left outer join
															rsfMaster.mkatalog_farmasi mf
															on	dlap.katalog_id 	= mf.id_inventory
													where	(	dlap.trx_jenis 		= 30 or
																dlap.trx_jenis 		= 31 or
																dlap.trx_jenis 		= 33 or
																dlap.trx_jenis 		= 34 or
																dlap.trx_jenis 		= 35 or
																dlap.trx_jenis 		= 52 ) and
															dlap.bulan 			> '202203'
													group   by dlap.katalog_id
											) trxPersediaan
											on	lmss.katalog_kode	= trxPersediaan.katalog_kode
							) trxPersediaan
					group	by katalog_kode
			) updReff
	set		upd.jumlah_trx 			= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

-- f. hitung total dan hitung nilai ajusment
	update 		rsfPelaporan.laporan_mutasi_saldo_simgos
		set		jumlah_akhir = jumlah_awal + jumlah_penerimaan + jumlah_produksi - jumlah_trx - jumlah_bahanprod,
				jumlah_adj   = (jumlah_awal + jumlah_penerimaan + jumlah_produksi - jumlah_trx - jumlah_bahanprod) - jumlah_opname;
				
				
LAPORAN FINAL
--------------------------------------
-- QUERY LAPORAN FINAL

select		cast((lapPers.jumlah_adj * 100 / lapPers.jumlah_trx) AS SIGNED) as persen_adj,
			lapPers.katalog_kode as katalog_kode,
			mk.nama_barang as katalog_nama,
			lapPers.jumlah_awal as awal,
			lapPers.jumlah_penerimaan as pengadaan,
			lapPers.jumlah_produksi as prodHasil,
			lapPers.jumlah_bahanprod as prodBahan,
			lapPers.jumlah_trx + lapPers.jumlah_adj as transaksi,
			lapPers.jumlah_adj,
			lapPers.jumlah_opname as opname
	from 	rsfPelaporan.laporan_mutasi_saldo_simgos lapPers
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = lapPers.katalog_kode;
