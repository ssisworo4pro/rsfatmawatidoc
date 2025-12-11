-- == ** LANGKAH 1, Data Dasar ** == --
-- == DATA TEAMTERIMA == --
-- Persiapan data pembelian
update tjurnal_penerimaan set sts_proses = 1;
update tjurnal_penerimaan set sts_proses = 0 where klp_dokumen = '';
update tjurnal_penerimaan set sts_proses = 0 where klp_dokumen = 'test';
update tjurnal_penerimaan set sts_proses = 0 where klp_dokumen = 'RU';
SELECT * FROM tjurnal_penerimaan WHERE sts_proses = 0;

-- Rekap data penerimaan
truncate table dlap_persediaan_tterima;
insert into dlap_persediaan_tterima ( bulan, tahun, katalog_kode, qty_terima, qty_retur, qty_trxterima )
select		MONTH(tgl_vergudang) as bulan,
			YEAR(tgl_vergudang) as tahun,
			katalog_kode as katalog_kode,
			sum(qty_terima) as qty_terima,
  			sum(qty_retur) as qty_retur,
  			count(1) as qty_trxterima
  	from	tjurnal_penerimaan
  	where	sts_proses = 1
  	group	by MONTH(tgl_vergudang), YEAR(tgl_vergudang), katalog_kode;

-- cross cek data
select * from dlap_persediaan_tterima where qty_retur > qty_terima;

-- == DATA PRODUKSI == --
-- masih ada katalog_id yang belum ter-mappaing
select 		sum(dlap.jml_trxpersediaan) as jml_produksi,
			mf.kode as katalog_kode,
			katalog_id as inv_katalog_id,
			katalog_nama as inv_katalog_nama,
			katalog_kode as inv_katalog_kode
	from 	rsfPelaporan.dlap_persediaan dlap left outer join
			rsfMaster.mkatalog_farmasi mf
			on	dlap.katalog_id = mf.id_inventory
	where	dlap.trx_jenis 		= 51 and
			dlap.bulan 			> '202203'
	group   by dlap.katalog_id;

select * from rsfMaster.mkatalog_farmasi mf 

-- == DATA TRANSAKSI == --
select		*
	from	(
				select 		sum(
								dlap.jml_trxpersediaan * case dlap.trx_jenis when 30 then 1 when 33 then 1 when 52 then 1 else -1 end
							) as qty_transaksi,
							mf.kode as katalog_kode,
							katalog_id as inv_katalog_id,
							katalog_nama as inv_katalog_nama,
							katalog_kode as inv_katalog_kode
					from 	rsfPelaporan.dlap_persediaan dlap left outer join
							rsfMaster.mkatalog_farmasi mf
							on	dlap.katalog_id = mf.id_inventory
					where	(	dlap.trx_jenis 		= 30 or
								dlap.trx_jenis 		= 31 or
								dlap.trx_jenis 		= 33 or
								dlap.trx_jenis 		= 34 or
								dlap.trx_jenis 		= 35 or
								dlap.trx_jenis 		= 52 ) and
							dlap.bulan 			> '202203'
					group   by dlap.katalog_id
			) trxPersediaan left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lapReff 
			on	lapReff.tahun			= 2022 and
				lapReff.katalog_kode	= trxPersediaan.katalog_kode
	where	lapReff.katalog_kode is null;
			



-- == ** LANGKAH 2, Data Pembanding ** == --
-- == PEMBENTUKAN DATA REKAP TRX SIMGOS == --
-- jumlah awal dari aplikasi lama
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

select		'data diinsert : ', count(1) 
	from	(
				select 		tahun, katalog_kode, sum(jumlah_akhir) as jumlah_awal
					from 	laporan_mutasi_bulan
					where   tahun = 2022 and bulan = 3 and jumlah_akhir != 0
					group   by tahun, katalog_kode
			) counted
union all
select		'hasil insert : ', count(1) 
	from	rsfPelaporan.laporan_mutasi_saldo_simgos;

-- crocek data
select * from dlap_persediaan_tterima where qty_terima <= 0;
delete from dlap_persediaan_tterima where qty_terima = 0;
	
-- jumlah penerimaan dari transaksi penerimaan
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
				select		max(dlap_persediaan_tterima.tahun) as tahun, 
							max(dlap_persediaan_tterima.katalog_kode) as katalog_kode
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	dlap_persediaan_tterima.tahun = 2022 and 
							dlap_persediaan_tterima.bulan > 3
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

select		count(1)
	from	(
				select 		max(tahun) as tahun, max(katalog_kode) as katalog_kode, 
							sum(qty_terima - qty_retur) as jumlah_penerimaan
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	tahun 					= 2022 and
							bulan 					> 3 and
							qty_terima - qty_retur <> 0
					group	by tahun, katalog_kode 
			) counted
union all
select		count(1)
	from	(
				select 		max(tahun) as tahun, max(katalog_kode) as katalog_kode, 
							sum(qty_terima - qty_retur) as jumlah_penerimaan
					from 	rsfPelaporan.dlap_persediaan_tterima
					where	tahun 					= 2022 and
							bulan 					> 3 and
							qty_terima - qty_retur <> 0
					group	by tahun, katalog_kode 
			) updReff,
			rsfPelaporan.laporan_mutasi_saldo_simgos upd
	where   upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

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
				














-------------------------------------------------------------------------------------

call rsfPelaporan.lappersediaan_saldoawal2022();
call rsfMaster.mruangan_sync('farmasi',0);

-- Statistik
select 		max(uraian) as uraian, 
			sum(qty_source) as qty_source, 
			sum(qty_target) as qty_target,
			sum(qty_source) - sum(qty_target) as selisih
	from	(
				select 	'Jumlah Baris' as uraian, 
						0 as qty_source, 
						count(1) as qty_target 
				from 	rsfPelaporan.laporan_mutasi_bulan
				union all
				select 	'Jumlah Baris' as uraian, 
						count(1) as qty_source, 
						0 as qty_target 
				from 	rsfTeamterima.laporan_mutasi_bulan 
				where 	tahun = 2022 and bulan < 4
			) subquery;




-- ======================================================================================
select		mk.kelompok_barang, mg.nama_generik, 
			trxPersediaan.inv_katalog_id,
			trxPersediaan.inv_katalog_kode, 
		 	trxPersediaan.inv_katalog_nama,
			mk2.nama_barang,
			trxPersediaan.qty_transaksi,
			lbg.id_generik, mf2.id_teamterima , trxPersediaan.*
	from	(
				select 		sum(
								dlap.jml_trxpersediaan * case dlap.trx_jenis when 30 then 1 when 33 then 1 when 52 then 1 else -1 end
							) as qty_transaksi,
							max(mf.kode) as katalog_kode,
							max(dlap.katalog_id) as inv_katalog_id,
							max(dlap.katalog_nama) as inv_katalog_nama,
							max(dlap.katalog_kode) as inv_katalog_kode
					from 	rsfPelaporan.dlap_persediaan dlap left outer join
							rsfMaster.mkatalog_farmasi mf
							on	dlap.katalog_id = mf.id_inventory
					where	(	dlap.trx_jenis 		= 30 or
								dlap.trx_jenis 		= 31 or
								dlap.trx_jenis 		= 33 or
								dlap.trx_jenis 		= 34 or
								dlap.trx_jenis 		= 35 or
								dlap.trx_jenis 		= 52 ) and
							dlap.bulan 			> '202203'
					group   by dlap.katalog_id
			) trxPersediaan left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lapReff 
			on	lapReff.tahun			= 2022 and
				lapReff.katalog_kode	= trxPersediaan.katalog_kode
			left outer join
			rsfMaster.mkatalog_farmasi mf2 
			on  mf2.id_teamterima = trxPersediaan.katalog_kode
			left outer join
			rsfTeamterima.masterf_katalog mk2 
			on mk2.kode = trxPersediaan.katalog_kode
			left outer join
			rsfTeamterima.masterf_kelompokbarang mk 
			on mk.id = mk2.id_kelompokbarang
			left outer join
			rsfTeamterima.laporan_buffer_gudang lbg
			on  lbg.id_katalog = trxPersediaan.katalog_kode
			left outer join
			rsfTeamterima.masterf_generik mg 
			on mg.id = lbg.id_generik 
	where	lapReff.katalog_kode is null and
			trxPersediaan.qty_transaksi <> 0 AND 
			substring(trxPersediaan.inv_katalog_kode,1,2) = '14'
	order   by mk.kelompok_barang, mg.nama_generik,
               trxPersediaan.inv_katalog_kode;

select 		lap.tahun, lap.katalog_kode, lap.jumlah_awal, lap.jumlah_penerimaan,
			lap.jumlah_produksi, lap.jumlah_akhir
	from 	laporan_mutasi_saldo_simgos lap;

				select 		sum(
								dlap.jml_trxpersediaan * case dlap.trx_jenis when 30 then 1 when 33 then 1 when 52 then 1 else -1 end
							) as qty_transaksi,
							max(mf.kode) as katalog_kode,
							max(dlap.katalog_id) as inv_katalog_id,
							max(dlap.katalog_nama) as inv_katalog_nama,
							max(dlap.katalog_kode) as inv_katalog_kode
					from 	rsfPelaporan.dlap_persediaan dlap left outer join
							rsfMaster.mkatalog_farmasi mf
							on	dlap.katalog_id = mf.id_inventory
					where	(	dlap.trx_jenis 		= 30 or
								dlap.trx_jenis 		= 31 or
								dlap.trx_jenis 		= 33 or
								dlap.trx_jenis 		= 34 or
								dlap.trx_jenis 		= 35 or
								dlap.trx_jenis 		= 52 ) and
							dlap.bulan 			> '202203'
					group   by dlap.katalog_id


-- ================== PEMBENTUKAN LAPORAN ================== --

-- refresh master barang
	UPDATE 		rsfMaster.mkatalog_farmasi farmasi
		SET		farmasi.id_inventory = null;

	UPDATE 		rsfMaster.mkatalog_farmasi farmasi, inventory.barang barang
		SET		farmasi.id_inventory = barang.id
		WHERE   farmasi.kode = barang.KODE_BARANG and
				farmasi.id_inventory is null;

------------ BARANG KELUAR TRACK ------------
select		mk.kelompok_barang as kelompok, 
			mg.nama_generik as generik, 
		 	trxPersediaan.inv_katalog_nama as nama,
			trxPersediaan.inv_katalog_kode as kode, 
			trxPersediaan.qty_transaksi as qty,
			trxPersediaan.inv_katalog_kode, 
			mf2.kode as team_katalog_kode,
		 	trxPersediaan.inv_katalog_id,
			mf2.id_teamterima as team_katalog_id,
		 	trxPersediaan.inv_katalog_nama,
			mf2.nama_barang as team_katalog_nama
	from	(
				select 		sum(
								dlap.jml_trxpersediaan * case dlap.trx_jenis when 30 then 1 when 33 then 1 when 52 then 1 else -1 end
							) as qty_transaksi,
							max(mf.kode) as katalog_kode,
							max(dlap.katalog_id) as inv_katalog_id,
							max(dlap.katalog_nama) as inv_katalog_nama,
							max(dlap.katalog_kode) as inv_katalog_kode
					from 	rsfPelaporan.dlap_persediaan dlap left outer join
							rsfMaster.mkatalog_farmasi mf
							on	dlap.katalog_id = mf.id_inventory
					where	(	dlap.trx_jenis 		= 30 or
								dlap.trx_jenis 		= 31 or
								dlap.trx_jenis 		= 33 or
								dlap.trx_jenis 		= 34 or
								dlap.trx_jenis 		= 35 or
								dlap.trx_jenis 		= 52 ) and
							dlap.bulan 			> '202203'
					group   by dlap.katalog_id
			) trxPersediaan left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lapReff 
			on	lapReff.tahun			= 2022 and
				lapReff.katalog_kode	= trxPersediaan.katalog_kode
			left outer join
			rsfMaster.mkatalog_farmasi mf2 
			on  mf2.kode = trxPersediaan.katalog_kode
			left outer join
			rsfMaster.mkatalog_kelompok mk 
			on mk.id = mf2.id_kelompokbarang
			left outer join
			rsfMaster.mkatalog_buffer_gudang lbg
			on  lbg.katalog_kode = trxPersediaan.katalog_kode
			left outer join
			rsfMaster.masterf_generik mg 
			on mg.id = lbg.id_generik 
	where	lapReff.katalog_kode is null and
			trxPersediaan.qty_transaksi <> 0
	order   by mk.kelompok_barang, mg.nama_generik,
               trxPersediaan.inv_katalog_kode;

------------ BARANG DALAM TRACK ------------
select 		mk.kelompok_barang,
			lmss.katalog_kode,
			mf.nama_barang,
			lmss.jumlah_awal,
			lmss.jumlah_penerimaan,
			-- lmss.jumlah_produksi,
			COALESCE(trxPersediaan.qty_transaksi,0) as jumlah_transaksi,
			COALESCE(trxOpname.qty_opname,0) as jumlah_opnameDesember2022
			-- lmss.jumlah_akhir 
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
			left outer join
			(
				select		max(b.KODE_BARANG) as katalog_kode,
							max(b.ID) as katalog_id, 
							max(b.NAMA) as katalog_nama, 
							sum(sod.MANUAL) as qty_opname
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
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
					group	by b.KODE_BARANG
			) trxOpname
			on	lmss.katalog_kode	= trxOpname.katalog_kode

----
select 		mf.kode as katalog_kode,
			katalog_kode as inv_katalog_kode,
			katalog_id as inv_katalog_id,
			katalog_nama as inv_katalog_nama,
			sum(dlap.jml_trxpersediaan) as jml_produksi
	from 	rsfPelaporan.dlap_persediaan dlap left outer join
			rsfMaster.mkatalog_farmasi mf
			on	dlap.katalog_id = mf.id_inventory
	where	dlap.trx_jenis 		= 51 and
			dlap.bulan 			> '202203'
	group   by dlap.katalog_id;

---- STOK OP NAME
select		max(b.KODE_BARANG) as katalog_kode,
			max(b.ID) as katalog_id, 
			max(b.NAMA) as katalog_nama, 
			sum(sod.MANUAL) as qty_opname
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod 
			left outer join inventory.barang_ruangan br 
			on	sod.BARANG_RUANGAN = br.id
			left outer join inventory.barang b 
			on br.BARANG = b.ID 
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
	group	by b.KODE_BARANG, b.id
	
	
			) trxPersediaan left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lapReff 
			on	lapReff.tahun			= 2022 and
				lapReff.katalog_kode	= trxPersediaan.katalog_kode
			left outer join
			rsfMaster.mkatalog_farmasi mf2 
			on  mf2.kode = trxPersediaan.katalog_kode
			left outer join
			rsfMaster.mkatalog_kelompok mk 
			on mk.id = mf2.id_kelompokbarang
			left outer join
			rsfMaster.mkatalog_buffer_gudang lbg
			on  lbg.katalog_kode = trxPersediaan.katalog_kode
			left outer join
			rsfMaster.masterf_generik mg 
			on mg.id = lbg.id_generik 
	where	lapReff.katalog_kode is null and
			trxPersediaan.qty_transaksi <> 0
	
--- stok opname di luar track ---
select 		trxOpname.katalog_id,
			mf.id_inventory mapping_id,
			trxOpname.katalog_kode,
			mf.kode as mapping_kode,
			trxOpname.katalog_nama,
			COALESCE(trxOpname.qty_opname,0) as jumlah_opnameDesember2022
	from 	(
				select		max(b.KODE_BARANG) as katalog_kode,
							max(b.ID) as katalog_id, 
							max(b.NAMA) as katalog_nama, 
							sum(sod.MANUAL) as qty_opname
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
					where	so.id		= sod.STOK_OPNAME and
							so.TANGGAL 	> '2022-12-16' and
							sod.MANUAL  != 0 and
							so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
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
											'101030115') -- Gudang Reused 
					group	by b.KODE_BARANG, b.ID
			) trxOpname
			left outer join
			laporan_mutasi_saldo_simgos lmss
			on	lmss.katalog_kode	= trxOpname.katalog_kode
			left outer join
			rsfMaster.mkatalog_farmasi mf
			on  mf.kode = trxOpname.katalog_kode
			left outer join
			rsfMaster.mkatalog_kelompok mk 
			on mk.id = mf.id_kelompokbarang
	where	lmss.katalog_kode is null;


----
51	0	Barang Produksi
52	0	Pemakaian Barang Produksi


SELECT		b.nama, bp.*




SELECT		*
	FROM	(
				SELECT	 	bp.id as id,
							'hasil' as status,
							bp.TANGGAL as tanggal,
							b.KODE_BARANG as barang_kode,
							b.id as barang_id,
							b.nama as barang_nama,
							bp.QTY as jumlah_produksi,
							'' as jumlah_bahan
					from 	inventory.barang_produksi bp, 
							inventory.kategori k,
							inventory.barang b,
							inventory.barang_ruangan br,
							master.ruangan r,
							inventory.jenis_transaksi_stok jts
					where	br.BARANG 	 		 = b.ID and
							b.KATEGORI 			 = k.ID and
							br.RUANGAN  		 = bp.RUANGAN and
							br.BARANG   		 = bp.BARANG and
							r.id 				 = br.ruangan AND
							jts.ID				 = 51 AND
							bp.STATUS     	 	 = 2 and 
							bp.TANGGAL 			>= '2022-04-01' and 
							bp.TANGGAL  		 < '2023-01-01'
				UNION ALL
				SELECT	 	bp.id as id,
							'bahan' as status,
							'' as tanggal,
							b.KODE_BARANG as barang_kode,
							b.id as barang_id,
							b.nama as barang_nama,
							'' as jumlah_produksi,
							COALESCE((bpd.QTY), 0) as jumlah_bahan
					from 	inventory.barang_produksi bp, 
							inventory.barang_produksi_detil bpd,
							inventory.kategori k,
							inventory.barang b,
							inventory.barang_ruangan br,
							master.ruangan r,
							inventory.jenis_transaksi_stok jts
					where	bp.ID 				 = bpd.PRODUKSI and
							br.BARANG 	 		 = b.ID and
							b.KATEGORI 			 = k.ID and
							br.RUANGAN  		 = bp.RUANGAN and
							br.BARANG   		 = bpd.BAHAN and
							r.id 				 = br.ruangan AND
							jts.ID				 = 52 AND
							bp.STATUS     	 	 = 2 and 
							bp.TANGGAL 			>= '2022-04-01' and 
							bp.TANGGAL  		 < '2023-01-01'
			) subquery
	order	by id, status desc;
