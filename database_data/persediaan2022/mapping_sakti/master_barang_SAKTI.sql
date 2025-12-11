1. laporan persediaan per 31 desember
   kode, nama barang, qty, nilai akhir
2. laporan rincian persediaan
   kode, nama barang, trx-in, trx-out, saldo-akhir, nilai-akhir
3. buku persediaan
   trx per barang   
4. neraca persediaan
   kelompok barang, saldo-akhir, nilai-akhir
5. Laporan Fifo saldo-akhir
6. Mapping sakti




alter table tjurnal_sakti add sts_mapping int null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_lama 	varchar(15) null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_baru    varchar(15) null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_primer  char(1) null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_aksi    varchar(255) null;

-- reset status jurnal sakti
update 	tjurnal_sakti 
	set sts_mapping 		= '1', 
		katalog_kode_lama 	= null, 
		katalog_kode_baru 	= null, 
		katalog_kode_primer = null,
		katalog_kode_aksi 	= null,
	 	katalog_kode 		= null,
		katalog_nama 		= null;

-- keluarkan master barang sakti yang tidak terpakai / digunakan
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%terpakai%';
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%gunakan%';

-- keluarkan master barang sakti yang ada
select * from tjurnal_sakti ts where sts_mapping = 0 order by qty_akhir desc, qty_awal desc;
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '000758' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '001138' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';		

-- statistik
-- Jumlah Baris						5066
-- Jumlah Baris Tidak Digunakan		 311
-- Jumlah Baris diMapping			4755
select 'Jumlah Baris' as uraian, count(1) as jumlah from tjurnal_sakti ts
union all
select 'Jumlah Baris Tidak Digunakan' as uraian, count(1) as jumlah from tjurnal_sakti ts where sts_mapping = 0
union all
select 'Jumlah Baris diMapping' as uraian, count(1) as jumlah from tjurnal_sakti ts where sts_mapping = 1;

-- update dulu yang double			  41
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					where    sts_mapping = 1
					group   by tjs.sakti_nama
					having  count(1) > 1
			) updReff
	SET		upd.sts_mapping				= 2
	WHERE	upd.sakti_nama				= updReff.sakti_nama;
select * from tjurnal_sakti ts where sts_mapping = 2 order by sakti_nama;

-- sweeping double dan UPDATE
-- master_barang_SAKTI_Double.sql

-- update untuk nama sama
-- 4404
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- saldo awal beda (bandingkan data)
SELECT 		sakti.katalog_kode, sakti.sakti_nama, sakti.qty_awal, simgos.jumlah_awal
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	having  sakti.qty_awal <> simgos.jumlah_awal;

-- sweeping beda saldo awal
-- master_barang_SAKTI_bedaSaldoawal.sql

-- update hasil sweping
update rsfPelaporan.tjurnal_sakti set katalog_kode_lama = katalog_kode;
select * from rsfPelaporan.tjurnal_sakti where katalog_kode_baru <> '';
update 		rsfPelaporan.tjurnal_sakti 
	set 	katalog_kode = katalog_kode_baru
	where 	katalog_kode_baru <> '';

-- sweeing katalog_kode masih kosong 250
-- master_barang_SAKTI_kodeMasihKosong.sql
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

-- update hasil sweping
select * from rsfPelaporan.tjurnal_sakti where katalog_kode_baru <> '';
update 		rsfPelaporan.tjurnal_sakti 
	set 	katalog_kode = katalog_kode_baru
	where 	katalog_kode_baru <> '';

-- keluarkan lagi yang tidak digunakan
select * from tjurnal_sakti ts where UPPER(katalog_kode_primer) = 'X';
update 		rsfPelaporan.tjurnal_sakti 
	set 	sts_mapping = '9'
	where 	UPPER(katalog_kode_primer) = 'X';

-- cek ulang
select * from tjurnal_sakti ts where (sts_mapping = 1 or sts_mapping = 2) and katalog_kode is null;

-- update by case
SELECT * FROM tjurnal_sakti WHERE katalog_kode  like  '40E029%';
update tjurnal_sakti set katalog_kode = '40E029.1' where id = '2321';

SELECT * FROM tjurnal_sakti WHERE katalog_kode  like  '42C370%' OR  katalog_kode  like  '42C028%';
update tjurnal_sakti set katalog_kode = '42C028' where id = 1794;
update tjurnal_sakti set katalog_kode = '42C370' where id = 4926;
update tjurnal_sakti set katalog_kode = '' where id = 4926;

SELECT * FROM tjurnal_sakti where katalog_kode is null and qty_awal <> 0;
select * from tjurnal_sakti  where id = 883;
select * from tjurnal_sakti  where id = 2701;
update tjurnal_sakti set sts_mapping = 1, sakti_nama = 'BISOPROLOL 5 MG TAB' where sakti_nama = 'BISOPROLOL 5 MG TAB - tdk dipakai'
update tjurnal_sakti set sts_mapping = 1, sakti_nama = 'ATRACURIUM BESYLATE INJ 10MG/ML' where sakti_nama = 'ATRACURIUM BESYLATE INJ 10MG/ML-tdk terpakai'
update tjurnal_sakti set katalog_kode = '10B129' where id = 883;
update tjurnal_sakti set katalog_kode = '40A137' where id = 2701;


insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401006','Alat/Obat Kontrasepsi Keluarga Berencana(Persediaan Lainnya)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401001','Obat Cair(Persediaan Lainnya)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401003','Obat Gas(Persediaan Lainnya)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401005','Obat Gel/Salep(Persediaan Lainnya)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401999','Obat Lainnya(Persediaan Lainnya)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401002','Obat Padat(Persediaan Lainnya)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401004','Obat Serbuk/Tepung(Persediaan Lainnya)');

truncate table tjurnal_sakti_klp;
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401006','ALAT/ OBAT KONTRASEPSI KELUARGA BERENCANA(PERSEDIAAN  LAINNYA)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401001','OBAT CAIR (PERSEDIAAN LAINNYA)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401003','OBAT GAS (PERSEDIAAN LAINNYA)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401005','OBAT GEL/SALEP (PERSEDIAAN LAINNYA)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401999','OBAT LAINNYA (PERSEDIAAN LAINNYA)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401002','OBAT PADAT (PERSEDIAAN LAINNYA)');
insert into tjurnal_sakti_klp ( sakti_kode_klp, sakti_nama_klp ) values ('1010401004','OBAT SERBUK/TEPUNG (PERSEDIAAN LAINNYA)');


alter table tjurnal_sakti add stat_mapsaldoawal char(1) null;
update tjurnal_sakti set stat_mapsaldoawal = '0';

81P131


----------------------------------------------------------------------------------------------------------
-- saldo awal beda (bandingkan data) : simrs 4718 vs sakti 4548 = 170, selisih 203
SELECT 		simrs.katalog_kode, simrs.katalog_kode_grp, simrs.qty_group as simrs_grp, 
			COALESCE(sakti_add.qty_add,0) as simrs_awal_add, 
			simrs.jumlah_awal_ceil - simrs.jumlah_awal as simrs_awal_pembulatan, 
			simrs.jumlah_awal_ceil - COALESCE(sakti_add.qty_add,0) as simrs_awal, 
			simrs.jumlah_pengadaan as simrs_beli,
			simrs.jumlah_produksi as simrs_produksi,
			simrs.jumlah_masuk as simrs_masuk,
			simrs.jumlah_keluar as simrs_keluar,
			simrs.jumlah_akhir as simrs_akhir,
			sakti.qty_awal as sakti_awal,
			sakti.qty_masuk as sakti_masuk, 
			sakti.qty_keluar as sakti_kelar, 
			sakti.qty_akhir as sakti_akhir, 
			sakti.qty_group as sakti_grp,
			sakti.sakti_nama, mk.katalog_nama
	from	(
				select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
							sum(qty_awal) as jumlah_awal,
							sum(CEILING(qty_awal)) as jumlah_awal_ceil,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
							sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
							sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir,
							count(1) as qty_group
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by lmss.katalog_kode
			) simrs
			left outer join
			(
				select 		max(katalog_kode) as katalog_kode, sum(qty_add) as qty_add
					from 	tjurnal_sakti_add
					group   by katalog_kode
			) sakti_add
			on sakti_add.katalog_kode = simrs.katalog_kode
			left outer join
			(
				select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
							max(ts.sakti_kode) as sakti_kode,
							sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
							sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
							count(1) as qty_group
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							(sts_mapping = 1 or sts_mapping = 2)
					group   by ts.katalog_kode
			) sakti
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		max(b.NAMA) as katalog_nama,
							max(b.KODE_BARANG) as katalog_kode
					from 	inventory.barang b
					group   by b.KODE_BARANG
			) mk
			on simrs.katalog_kode_grp = mk.katalog_kode
	order 	by sakti.katalog_kode, simrs.katalog_kode_grp

select		*
	from	(
				SELECT 		max(simrs.katalog_kode_grp) as katalog_kode, 
							sum(simrs.qty_group) as simrs_grp, 
							COALESCE(sakti_add.qty_add,0) as simrs_awal_add, 
							sum(simrs.jumlah_awal_ceil) - sum(simrs.jumlah_awal) as simrs_awal_pembulatan, 
							sum(simrs.jumlah_awal_ceil) - sum(COALESCE(sakti_add.qty_add,0)) as simrs_awal, 
							sum(simrs.jumlah_pengadaan) as simrs_beli,
							sum(simrs.jumlah_produksi) as simrs_produksi,
							sum(simrs.jumlah_masuk) as simrs_masuk,
							sum(simrs.jumlah_keluar) as simrs_keluar,
							sum(simrs.jumlah_akhir) as simrs_akhir,
							max(sakti.qty_awal) as sakti_awal,
							max(sakti.qty_masuk) as sakti_masuk, 
							max(sakti.qty_keluar) as sakti_kelar, 
							max(sakti.qty_akhir) as sakti_akhir, 
							max(sakti.qty_group) as sakti_grp,
							case when max(sakti.sakti_kode) is null then 0 else 1 end as sakti_mapping,
							max(mk.katalog_nama) as katalog_nama
					from	(
								select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
											sum(qty_awal) as jumlah_awal,
											sum(CEILING(qty_awal)) as jumlah_awal_ceil,
											sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
											sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
											sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
											sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
											sum(jumlah_opname) as jumlah_akhir,
											count(1) as qty_group
									FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
									group   by lmss.katalog_kode
							) simrs
							left outer join
							(
								select 		max(katalog_kode) as katalog_kode, sum(qty_add) as qty_add
									from 	tjurnal_sakti_add
									group   by katalog_kode
							) sakti_add
							on sakti_add.katalog_kode = simrs.katalog_kode
							left outer join
							(
								select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
											max(ts.sakti_kode) as sakti_kode,
											sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
											sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
											count(1) as qty_group
									from 	tjurnal_sakti ts
									where   katalog_kode is not null and
											(sts_mapping = 1 or sts_mapping = 2)
									group   by ts.katalog_kode
							) sakti
							on sakti.katalog_kode = simrs.katalog_kode
							left outer join 
							(
								select 		max(b.NAMA) as katalog_nama,
											max(b.KODE_BARANG) as katalog_kode
									from 	inventory.barang b
									group   by b.KODE_BARANG
							) mk
							on simrs.katalog_kode_grp = mk.katalog_kode
					group   by simrs.katalog_kode_grp
			) tblPerbandingan
	order	by  sakti_mapping, katalog_kode

-- sakti belum input
select		*
	from	(
				select		max(tblSaktiWithAdd.katalog_kode) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp, 
															max(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
								UNION ALL
								select		*
									from	(
												select 		max(addsakti.katalog_kode) as katalog_kode,
															max(addsakti.sakti_nama) as sakti_nama,
															max(addsakti.sakti_nama_klp) as sakti_nama_klp, 
															'' as sakti_kode,
															0 as qty_awal, 
															0 as qty_masuk, 
															0 as qty_keluar, 
															0 as qty_akhir, 
															sum(qty_add) as qty_add, 
															0 as qty_group
													from 	tjurnal_sakti_add addsakti
													group   by katalog_kode
											) union2
							) tblSaktiWithAdd
					group   by tblSaktiWithAdd.katalog_kode
			) sakti_kodecheck
	where	sakti_kode = '';
		

-- sakti vs simrs
SELECT 		sakti.katalog_kode as sakti_kode,
			sakti.qty_group as sakti_grp,
			sakti.qty_awal, 
			sakti.qty_masuk, 
			sakti.qty_keluar, 
			sakti.qty_akhir, 
			simrs.katalog_kode, 
			simrs.katalog_kode_grp, 
			COALESCE(sakti_add.qty_add,0) as simrs_awal_add,
			simrs.jumlah_awal_ceil - simrs.jumlah_awal as simrs_awal_pembulatan, 
			simrs.jumlah_awal_ceil - COALESCE(sakti_add.qty_add,0) as simrs_awal, 
			sakti.qty_awal as sakti_awal,
			simrs.qty_group as simrs_grp, 
			sakti.sakti_nama, mk.katalog_nama
	from	(
				select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
							max(ts.sakti_kode) as sakti_kode,
							sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
							sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
							count(1) as qty_group
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							(sts_mapping = 1 or sts_mapping = 2)
					group   by ts.katalog_kode
			) sakti
			left outer join
			(
				select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
							sum(qty_awal) as jumlah_awal,
							sum(CEILING(qty_awal)) as jumlah_awal_ceil,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
							sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
							sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir,
							count(1) as qty_group
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by lmss.katalog_kode
			) simrs
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join
			(
				select 		max(katalog_kode) as katalog_kode, sum(qty_add) as qty_add
					from 	tjurnal_sakti_add
					group   by katalog_kode
			) sakti_add
			on sakti_add.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		NAMA as katalog_nama,
							KODE_BARANG as katalog_kode
					from 	inventory.barang 
					where 	id in 
							(select 	min(id) 
								from 	inventory.barang 
								where 	KODE_BARANG is not null group by KODE_BARANG )
			) mk
			on simrs.katalog_kode = mk.katalog_kode
	order 	by simrs.katalog_kode, simrs.katalog_kode
	
	
---- SAKTI vs SIMRS tanpa group
SELECT 		sakti.sakti_kode_klp as sakti_kode_klp, 
			sakti.sakti_kode as sakti_kode,
			sakti.qty_group as sakti_grp,
			sakti.qty_awal + sakti.qty_add as qty_awal,
			sakti.qty_add as qty_awal_add, 
			sakti.qty_masuk, 
			sakti.qty_keluar, 
			sakti.qty_akhir, 
			simrs.jumlah_awal_ceil - simrs.jumlah_awal as simrs_awal_pembulatan, 
			simrs.jumlah_awal_ceil as simrs_awal, 
			sakti.qty_awal + sakti.qty_add - simrs.jumlah_awal_ceil as selisih,
			simrs.katalog_kode as katalog_kode, 
			mk.katalog_nama as katalog_nama,
			sakti.sakti_nama, 
			sakti.sakti_nama_klp
	from	(
				select		max(tblSaktiWithAdd.katalog_kode) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															max(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
															left outer join tjurnal_sakti_klp tsk
															on ts.sakti_nama_klp = tsk.sakti_nama_klp
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
								UNION ALL
								select		*
									from	(
												select 		max(addsakti.katalog_kode) as katalog_kode,
															max(addsakti.sakti_nama) as sakti_nama,
															max(addsakti.sakti_nama_klp) as sakti_nama_klp, 
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															'' as sakti_kode,
															0 as qty_awal, 
															0 as qty_masuk, 
															0 as qty_keluar, 
															0 as qty_akhir, 
															sum(qty_add) as qty_add, 
															0 as qty_group
													from 	tjurnal_sakti_add addsakti
															left outer join tjurnal_sakti_klp tsk
															on addsakti.sakti_nama_klp = tsk.sakti_nama_klp
													group   by katalog_kode
											) union2
							) tblSaktiWithAdd
					group   by tblSaktiWithAdd.katalog_kode
			) sakti
			left outer join
			(
				select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
							sum(qty_awal) as jumlah_awal,
							sum(CEILING(qty_awal)) as jumlah_awal_ceil,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
							sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
							sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir,
							count(1) as qty_group
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by lmss.katalog_kode
			) simrs
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		NAMA as katalog_nama,
							KODE_BARANG as katalog_kode
					from 	inventory.barang 
					where 	id in 
							(select 	min(id) 
								from 	inventory.barang 
								where 	KODE_BARANG is not null group by KODE_BARANG )
			) mk
			on simrs.katalog_kode = mk.katalog_kode
	order 	by simrs.katalog_kode, simrs.katalog_kode
	
-- UPDATE yang terMapping saldo awal
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				SELECT 		simrs.katalog_kode as katalog_kode
					from	(
								select		max(tblSaktiWithAdd.katalog_kode) as katalog_kode
									from	(
												select		*
													from	(
																select 		max(ts.katalog_kode) as katalog_kode
																	from 	tjurnal_sakti ts
																	where   katalog_kode is not null and
																			(sts_mapping = 1 or sts_mapping = 2)
																	group   by ts.katalog_kode
															) union1
												UNION ALL
												select		*
													from	(
																select 		max(addsakti.katalog_kode) as katalog_kode
																	from 	tjurnal_sakti_add addsakti
																	group   by katalog_kode
															) union2
											) tblSaktiWithAdd
									group   by tblSaktiWithAdd.katalog_kode
							) sakti,
							(
								select		max(katalog_kode) as katalog_kode
									FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
									group   by lmss.katalog_kode
							) simrs
					WHERE	sakti.katalog_kode = simrs.katalog_kode
			) as updReff
	SET		upd.stat_mapsaldoawal		= '1'
	WHERE	upd.katalog_kode			= updReff.katalog_kode;
	
-- double
select 		(ts.katalog_kode) as katalog_kode, 
			(ts.sakti_nama) as sakti_nama, 
			(ts.sakti_nama_klp) as sakti_nama_klp,
			(tsk.sakti_kode_klp) as sakti_kode_klp,
			(ts.sakti_kode) as sakti_kode,
			(ts.qty_awal) as qty_awal, 
			(ts.qty_masuk) as qty_masuk, 
			(ts.qty_keluar) as qty_keluar, 
			(ts.qty_akhir) as qty_akhir 
	from 	tjurnal_sakti ts
			left outer join tjurnal_sakti_klp tsk
			on ts.sakti_nama_klp = tsk.sakti_nama_klp
	where 	ts.katalog_kode in
			(
				select 		katalog_kode
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							(sts_mapping = 1 or sts_mapping = 2)
					group   by katalog_kode 
					having  sum(1) > 1
			)
	order by ts.katalog_kode 
select * from tjurnal_sakti where katalog_kode = '90P097';
update tjurnal_sakti set katalog_kode = '90S007', stat_mapsaldoawal = '1' where id = 1357 and katalog_kode = '90P097';

81P131

-------------------------------------------------------------------------------------------------------------
---- SAKTI vs SIMRS saldo akhir
SELECT 		sakti.sakti_kode_klp as sakti_kode_klp, 
			sakti.sakti_kode as sakti_kode,
			sakti.qty_group as sakti_grp,
			sakti.qty_add as qty_awal_add, 
			sakti.qty_akhir, 
			simrs.akhir as simrs_akhir, 
			sakti.qty_akhir - simrs.akhir as selisih,
			simrs.katalog_kode as katalog_kode, 
			mk.katalog_nama as katalog_nama,
			sakti.sakti_nama, 
			sakti.sakti_nama_klp
	from	(
				select		max(tblSaktiWithAdd.katalog_kode) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															max(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
															left outer join tjurnal_sakti_klp tsk
															on ts.sakti_nama_klp = tsk.sakti_nama_klp
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
								UNION ALL
								select		*
									from	(
												select 		max(addsakti.katalog_kode) as katalog_kode,
															max(addsakti.sakti_nama) as sakti_nama,
															max(addsakti.sakti_nama_klp) as sakti_nama_klp, 
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															'' as sakti_kode,
															0 as qty_awal, 
															0 as qty_masuk, 
															0 as qty_keluar, 
															0 as qty_akhir, 
															sum(qty_add) as qty_add, 
															0 as qty_group
													from 	tjurnal_sakti_add addsakti
															left outer join tjurnal_sakti_klp tsk
															on addsakti.sakti_nama_klp = tsk.sakti_nama_klp
													group   by katalog_kode
											) union2
							) tblSaktiWithAdd
					group   by tblSaktiWithAdd.katalog_kode
			) sakti
			left outer join
			(
				select		katalog_kode,
							akhir
					FROM 	rsfPelaporan.laporan_so_trxrsn
			) simrs
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		NAMA as katalog_nama,
							KODE_BARANG as katalog_kode
					from 	inventory.barang 
					where 	id in 
							(select 	min(id) 
								from 	inventory.barang 
								where 	KODE_BARANG is not null group by KODE_BARANG )
			) mk
			on simrs.katalog_kode = mk.katalog_kode
	order 	by simrs.katalog_kode, simrs.katalog_kode

---- SIMRS vs SAKTI saldo akhir GRP
SELECT 		min(sakti.sakti_kode_klp) as sakti_kode_klp, 
			min(sakti.sakti_kode) as sakti_kode,
			sum(1) as katalog_grp,
			sum(sakti.qty_group) as sakti_grp,
			sum(sakti.qty_add) as sakti_awal_add, 
			sum(sakti.qty_akhir) as sakti_akhir, 
			sum(simrs.akhir + simrs.beli + simrs.prod - simrs.resep + simrs.resep_retur - simrs.jual + simrs.jual_retur - simrs.tambil) as simrs_trx,
			abs(sum(simrs.akhir - COALESCE(sakti.qty_akhir,0))) as selisih_abs,
			sum(simrs.akhir - COALESCE(sakti.qty_akhir,0)) as selisih,
			max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode, 
			max(mk.katalog_nama) as katalog_nama,
			max(sakti.sakti_nama) as sakti_nama,
			max(sakti.sakti_nama_klp) as sakti_nama_klp
	from	(
				select		max(tblSaktiWithAdd.katalog_kode) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															max(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
															left outer join tjurnal_sakti_klp tsk
															on ts.sakti_nama_klp = tsk.sakti_nama_klp
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
								UNION ALL
								select		*
									from	(
												select 		max(addsakti.katalog_kode) as katalog_kode,
															max(addsakti.sakti_nama) as sakti_nama,
															max(addsakti.sakti_nama_klp) as sakti_nama_klp, 
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															'' as sakti_kode,
															0 as qty_awal, 
															0 as qty_masuk, 
															0 as qty_keluar, 
															0 as qty_akhir, 
															sum(qty_add) as qty_add, 
															0 as qty_group
													from 	tjurnal_sakti_add addsakti
															left outer join tjurnal_sakti_klp tsk
															on addsakti.sakti_nama_klp = tsk.sakti_nama_klp
													group   by katalog_kode
											) union2
							) tblSaktiWithAdd
					group   by tblSaktiWithAdd.katalog_kode
			) sakti
			left outer join
			(
				select		trx.katalog_kode,
							trx.akhir,
							trx.beli,
							trx.prod,
							trx.resep,
							trx.resep_retur,
							trx.jual,
							trx.jual_retur,
							trx.tambil
					FROM 	rsfPelaporan.laporan_so_trxrsn trx
			) simrs
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join (
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp
			on  laporanKatalogGrp.katalog_kode = sakti.katalog_kode
			left outer join 
			(
				select 		NAMA as katalog_nama,
							KODE_BARANG as katalog_kode
					from 	inventory.barang 
					where 	id in 
							(select 	min(id) 
								from 	inventory.barang 
								where 	KODE_BARANG is not null group by KODE_BARANG )
			) mk
			on laporanKatalogGrp.katalog_kode_grp = mk.katalog_kode
	group 	by laporanKatalogGrp.katalog_kode_grp
	order 	by laporanKatalogGrp.katalog_kode_grp

-------------------------------------------------------------------------------------------------------------
SELECT 		*
	from	(
				select		max(tblSaktiWithAdd.id) as id, 
							max(tblSaktiWithAdd.katalog_kode) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.id) as id, 
															max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															max(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
															left outer join tjurnal_sakti_klp tsk
															on ts.sakti_nama_klp = tsk.sakti_nama_klp
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
								UNION ALL
								select		*
									from	(
												select 		0 as id,
															max(addsakti.katalog_kode) as katalog_kode,
															max(addsakti.sakti_nama) as sakti_nama,
															max(addsakti.sakti_nama_klp) as sakti_nama_klp, 
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															'' as sakti_kode,
															0 as qty_awal, 
															0 as qty_masuk, 
															0 as qty_keluar, 
															0 as qty_akhir, 
															sum(qty_add) as qty_add, 
															0 as qty_group
													from 	tjurnal_sakti_add addsakti
															left outer join tjurnal_sakti_klp tsk
															on addsakti.sakti_nama_klp = tsk.sakti_nama_klp
													group   by katalog_kode
											) union2
							) tblSaktiWithAdd
					group   by tblSaktiWithAdd.katalog_kode
			) sakti
			left outer join (
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp
			on  laporanKatalogGrp.katalog_kode = sakti.katalog_kode
	where   laporanKatalogGrp.katalog_kode is null
			and sakti.qty_akhir <> 0;





update 
select * from tjurnal_sakti where katalog_kode = '40E029'
select * from tjurnal_sakti_add where katalog_kode = '40E029'
select * from tjurnal_sakti where katalog_kode = '40E029.1'
select * from tjurnal_sakti where katalog_kode = '40E029.1'



CANNULATED HEADLESS SCREW 2.0X20MM 317.2020



-- cek yang masih kosong
-- 310 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;







select 		tjs.sakti_nama, tjs.katalog_nama 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama = tjs.katalog_nama 

select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama <> tjs.katalog_nama
	 		and tjs.katalog_kode is not null
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%terpakai%'
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%gunakan%'
	order   by qty_akhir desc, qty_awal desc
	
	KASA POUCHES ISI 10 (10 X 10 CM + INDIKATOR)-td digunakan
	
	
-- validasi barang tidak diproses, tetapi masih ada qty_akhir	
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sts_mapping = 0
	order   by qty_awal desc, qty_akhir desc;
	
-- data yang akan diproses
-- 4779 row
select * from tjurnal_sakti ts where sts_mapping = 1;

-- kosongkan kode
update 		tjurnal_sakti  
	set 	katalog_kode = null,
			katalog_nama = null;

-- update untuk nama sama
-- 4412
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- cek yang masih kosong
-- 367 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

-- update katalog_kode
-- 215 row
update tjurnal_sakti set katalog_kode = '70C034' where id = 95 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70P014' where id = 131 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70B012' where id = 164 and katalog_kode is null;
....

-- update berdasarkan kode stelah sweeping
-- 210 row
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.katalog_kode			= updReff.kode and
			upd.katalog_nama           is null;

-- query 5 barang yang tidak masuk
select * from tjurnal_sakti ts where katalog_nama is null and katalog_kode is not null;

-- row data yang masih belum ketemu mapping
-- 152 row
select * from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;
select sum(nilai_akhir) from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;










---------------------------------------------------------------------------------------------------------------

-- daftar barang yang double
-- double secara keseluruhan
-- double untuk nama yang berelasi
select 		nama_barang, count(1) as qtyDouble
	from 	rsfMaster.mkatalog_farmasi
	group   by nama_barang
	having  count(1) > 1

select		katf.id_teamterima,
			katf.id_inventory,
			katf.kode,
			katf.nama_barang,
			katf.kemasan
	from	rsfMaster.mkatalog_farmasi katf,
			(
				select		*
					from 	(
								select		nama_barang, count(1) as qtyDouble
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang in (
												select 		tjs.sakti_nama
													from 	rsfPelaporan.tjurnal_sakti tjs,
															rsfMaster.mkatalog_farmasi mf
													where	tjs.sakti_nama = mf.nama_barang
													group   by tjs.sakti_nama
													having  count(1) > 1
											)
									group   by nama_barang
							) mKatalog left outer join
							(
								select 		tjs.sakti_nama, count(1) as sakti_qtyDouble
									from 	rsfPelaporan.tjurnal_sakti tjs
									group   by tjs.sakti_nama
							) tSakti
							on  mKatalog.nama_barang = tSakti.sakti_nama
					having  mKatalog.qtyDouble > 1 and
							mKatalog.qtyDouble <> coalesce(tSakti.sakti_qtyDouble,0)
			) tDouble
	where	katf.nama_barang = tDouble.nama_barang


-- daftar barang yang double di SAKTI
select 		tjs.sakti_nama, count(1) as qtyDouble
	from 	rsfPelaporan.tjurnal_sakti tjs
	group   by tjs.sakti_nama
	having  count(1) > 1

select		sakti_nama_klp, sakti_kode, sakti_nama,
			qty_awal, qty_masuk, qty_keluar, qty_akhir
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama in (
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					group   by tjs.sakti_nama
					having  count(1) > 1
			)
	order	by sakti_nama;


--- update semua kode
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang;

-- yang masih null
-- 645
select		count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null;

select		substring(upd.sakti_nama,1,35), count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null
	group   by substring(upd.sakti_nama,1,35)
	having  count(1) > 1;

-- update pakai substring 50 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,50) = substring(mkatalogs.nama_barang,1,50)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,50)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,50) 	= substring(updReff.nama_barang,1,50) and
			upd.katalog_kode 				is null;

-- update pakai substring 40 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,40) = substring(mkatalogs.nama_barang,1,40)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,40)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,40) 	= substring(updReff.nama_barang,1,40) and
			upd.katalog_kode 				is null;

-- update pakai substring 35 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,35) = substring(mkatalogs.nama_barang,1,35)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,35)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,35) 	= substring(updReff.nama_barang,1,35) and
			upd.katalog_kode 				is null;


-- update pakai substring 30 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,30) = substring(mkatalogs.nama_barang,1,30)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,30)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,30) 	= substring(updReff.nama_barang,1,30) and
			upd.katalog_kode 				is null;

-- update pakai substring 25 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,25) = substring(mkatalogs.nama_barang,1,25)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,25)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,25) 	= substring(updReff.nama_barang,1,25) and
			upd.katalog_kode 				is null;

-- update pakai substring 20 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,20) = substring(mkatalogs.nama_barang,1,20)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,20)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,20) 	= substring(updReff.nama_barang,1,20) and
			upd.katalog_kode 				is null;

select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama <> katalog_nama;
	
select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	katalog_kode is null and 
			( qty_awal > 0 or qty_akhir > 0);


UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		* 
					from
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog,
											(
												select		sakti_nama_klp, sakti_kode, sakti_nama,
															qty_awal, qty_masuk, qty_keluar, qty_akhir
													from	rsfPelaporan.tjurnal_sakti
													where	sakti_nama in (
																select 		tjs.sakti_nama
																	from 	rsfPelaporan.tjurnal_sakti tjs
																	group   by tjs.sakti_nama
																	having  count(1) = 1
															)
											) tSakti
									where	mKatalog.nama_barang = tSakti.sakti_nama
							) test
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang;




UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		nama_barang, kode
					from	rsfMaster.mkatalog_farmasi
					where	nama_barang not in (
								select 		nama_barang
									from 	rsfMaster.mkatalog_farmasi
									group   by nama_barang
									having  count(1) > 1
							)
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sakti_nama in (
									select 		tjs.sakti_nama
										from 	rsfPelaporan.tjurnal_sakti tjs
										group   by tjs.sakti_nama
										having  count(1) = 1
								)






update rsfPelaporan.tjurnal_sakti set katalog_kode_lama = katalog_kode;
select * from rsfPelaporan.tjurnal_sakti where katalog_kode_baru <> '';
update 		rsfPelaporan.tjurnal_sakti 
	set 	katalog_kode = katalog_kode_baru
	where 	katalog_kode_baru <> '';

update 		rsfPelaporan.tjurnal_sakti 
	set 	sts_mapping = '3'
	where 	UPPER(katalog_kode_primer) <> 'X';

katalog_kode_primer



select * from rsfPelaporan.tjurnal_sakti  where sts_mapping = 1 and katalog_kode is null;
select * from rsfPelaporan.tjurnal_sakti  where upper(katalog_kode_primer) = 'X';

select katalog_kode_aksi, ts.* from rsfPelaporan.tjurnal_sakti  ts where sts_mapping = 1 and katalog_kode_aksi is not null;

SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   sts_mapping = 1 and katalog_kode is null
			) sakti
			left outer join
			(
				select		katalog_kode, qty_awal as jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode;

-- MASTER BARANG
-- cek duplikasi kode
select 		kode
	from 	rsfMaster.mkatalog_farmasi 
	where 	kode is not null
	group   by kode
	having  count(1) > 1;

-- keluarkan master barang dan kodenya
select 		kode as katalog_kd, nama_barang as katalog_nm
	from 	rsfMaster.mkatalog_farmasi 
	order   by kode

-- keluarkan master barang sakti yang ada
select * from tjurnal_sakti ts where sts_mapping = 0 order by qty_akhir desc, qty_awal desc;
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '000758' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '001138' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';		
SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, qty_awal as jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode;



select count(1) from rsfPelaporan.tjurnal_sakti;
select count(1) from rsfPelaporan.tjurnal_saktix;
select sum(nilai_akhir)  from tjurnal_sakti;
select sum(nilai_akhir)  from tjurnal_saktix;

UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		*
					from 	rsfPelaporan.tjurnal_saktix
			) as updReff
	SET		upd.qty_awal				= updReff.qty_awal,
			upd.qty_masuk				= updReff.qty_masuk,
			upd.qty_keluar				= updReff.qty_keluar,
			upd.qty_akhir				= updReff.qty_akhir,
			upd.nilai_awal				= updReff.nilai_awal,
			upd.nilai_akhir				= updReff.nilai_akhir
	WHERE	upd.sakti_kode				= updReff.sakti_kode and
			upd.sakti_nama_klp          = updReff.sakti_nama_klp;

------- saldo awal beda (bandingkan data)
SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, qty_awal as jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	having  sakti.qty_awal <> simgos.jumlah_awal;

SELECT 		* -- sum(sakti.qty_akhir), sum(simgos.jumlah_akhir)
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
			) sakti
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	 having  sakti.qty_akhir <> simgos.jumlah_akhir;

SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		max(katalog_kode_grp) as katalog_kode_grp, 
							max(katalog_kode) as katalog_kode, 
							sum(jumlah_awal) as jumlah_awal,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan)) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by katalog_kode
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
			left outer join
			(
				select 		katalog_kode, max(nilai_hppb) as nilai_hppb
					from 	tjurnal_penerimaan tp 
					where   CONCAT(katalog_kode,'tgl', DATE_FORMAT((tgl_terima),'%Y%m%d')) in
							(
								select 		CONCAT(katalog_kode,'tgl', DATE_FORMAT(max(tgl_terima),'%Y%m%d'))
									from 	tjurnal_penerimaan
									group   by katalog_kode
							)
					group   by katalog_kode
			) harga
			on sakti.katalog_kode = harga.katalog_kode
	having  sakti.qty_akhir <> simgos.jumlah_akhir
    order   by simgos.katalog_kode_grp;
			

--------------------------------------------------------------------- proses -----------------------------

-- 5066 ROW
--  183 ROW - td dipakai
--  130 ROW - td digunakan
--   41 row - double
-- 4712
--  308 row - mapping tidak cocok
-- 4404 row - terMapping berdasarkan nama

1. laporan persediaan per 31 desember
   kode, nama barang, qty, nilai akhir
2. laporan rincian persediaan
   kode, nama barang, trx-in, trx-out, saldo-akhir, nilai-akhir
3. buku persediaan
   trx per barang   
4. neraca persediaan
   kelompok barang, saldo-akhir, nilai-akhir
5. Laporan Fifo saldo-akhir
6. Mapping sakti
   
---------------
-- 4779 row

update tjurnal_sakti  set sts_mapping = '1';
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%terpakai%';
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%gunakan%';
select * from tjurnal_sakti ts where sts_mapping = 0 order by qty_akhir desc, qty_awal desc;
select * from tjurnal_sakti ts where sts_mapping = 1;

-- update dulu yang double2
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					where    sts_mapping = 1
					group   by tjs.sakti_nama
					having  count(1) > 1
			) updReff
	SET		upd.sts_mapping				= 2
	WHERE	upd.sakti_nama				= updReff.sakti_nama;
select * from tjurnal_sakti ts where sts_mapping = 2 order by sakti_nama;

-- update yang nama sesuai
-- kosongkan kode
update 		tjurnal_sakti  
	set 	katalog_kode = null,
			katalog_nama = null;

-- update untuk nama sama
-- 4412
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- cek yang masih kosong
-- 367 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

------- saldo awal beda (bandingkan data)
SELECT 		sakti.katalog_kode, sakti.sakti_nama, sakti.qty_awal, simgos.jumlah_awal
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	having  sakti.qty_awal <> simgos.jumlah_awal;










select 		tjs.sakti_nama, tjs.katalog_nama 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama = tjs.katalog_nama 

select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama <> tjs.katalog_nama
	 		and tjs.katalog_kode is not null
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%terpakai%'
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%gunakan%'
	order   by qty_akhir desc, qty_awal desc
	
	KASA POUCHES ISI 10 (10 X 10 CM + INDIKATOR)-td digunakan
	
	
-- validasi barang tidak diproses, tetapi masih ada qty_akhir	
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sts_mapping = 0
	order   by qty_awal desc, qty_akhir desc;
	
-- data yang akan diproses
-- 4779 row
select * from tjurnal_sakti ts where sts_mapping = 1;

-- kosongkan kode
update 		tjurnal_sakti  
	set 	katalog_kode = null,
			katalog_nama = null;

-- update untuk nama sama
-- 4412
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- cek yang masih kosong
-- 367 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

-- update katalog_kode
-- 215 row
update tjurnal_sakti set katalog_kode = '70C034' where id = 95 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70P014' where id = 131 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70B012' where id = 164 and katalog_kode is null;
....

-- update berdasarkan kode stelah sweeping
-- 210 row
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.katalog_kode			= updReff.kode and
			upd.katalog_nama           is null;

-- query 5 barang yang tidak masuk
select * from tjurnal_sakti ts where katalog_nama is null and katalog_kode is not null;

-- row data yang masih belum ketemu mapping
-- 152 row
select * from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;
select sum(nilai_akhir) from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;










---------------------------------------------------------------------------------------------------------------

-- daftar barang yang double
-- double secara keseluruhan
-- double untuk nama yang berelasi
select 		nama_barang, count(1) as qtyDouble
	from 	rsfMaster.mkatalog_farmasi
	group   by nama_barang
	having  count(1) > 1

select		katf.id_teamterima,
			katf.id_inventory,
			katf.kode,
			katf.nama_barang,
			katf.kemasan
	from	rsfMaster.mkatalog_farmasi katf,
			(
				select		*
					from 	(
								select		nama_barang, count(1) as qtyDouble
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang in (
												select 		tjs.sakti_nama
													from 	rsfPelaporan.tjurnal_sakti tjs,
															rsfMaster.mkatalog_farmasi mf
													where	tjs.sakti_nama = mf.nama_barang
													group   by tjs.sakti_nama
													having  count(1) > 1
											)
									group   by nama_barang
							) mKatalog left outer join
							(
								select 		tjs.sakti_nama, count(1) as sakti_qtyDouble
									from 	rsfPelaporan.tjurnal_sakti tjs
									group   by tjs.sakti_nama
							) tSakti
							on  mKatalog.nama_barang = tSakti.sakti_nama
					having  mKatalog.qtyDouble > 1 and
							mKatalog.qtyDouble <> coalesce(tSakti.sakti_qtyDouble,0)
			) tDouble
	where	katf.nama_barang = tDouble.nama_barang


-- daftar barang yang double di SAKTI
select 		tjs.sakti_nama, count(1) as qtyDouble
	from 	rsfPelaporan.tjurnal_sakti tjs
	group   by tjs.sakti_nama
	having  count(1) > 1

select		sakti_nama_klp, sakti_kode, sakti_nama,
			qty_awal, qty_masuk, qty_keluar, qty_akhir
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama in (
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					group   by tjs.sakti_nama
					having  count(1) > 1
			)
	order	by sakti_nama;


--- update semua kode
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang;

-- yang masih null
-- 645
select		count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null;

select		substring(upd.sakti_nama,1,35), count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null
	group   by substring(upd.sakti_nama,1,35)
	having  count(1) > 1;

-- update pakai substring 50 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,50) = substring(mkatalogs.nama_barang,1,50)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,50)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,50) 	= substring(updReff.nama_barang,1,50) and
			upd.katalog_kode 				is null;

-- update pakai substring 40 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,40) = substring(mkatalogs.nama_barang,1,40)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,40)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,40) 	= substring(updReff.nama_barang,1,40) and
			upd.katalog_kode 				is null;

-- update pakai substring 35 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,35) = substring(mkatalogs.nama_barang,1,35)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,35)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,35) 	= substring(updReff.nama_barang,1,35) and
			upd.katalog_kode 				is null;


-- update pakai substring 30 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,30) = substring(mkatalogs.nama_barang,1,30)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,30)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,30) 	= substring(updReff.nama_barang,1,30) and
			upd.katalog_kode 				is null;

-- update pakai substring 25 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,25) = substring(mkatalogs.nama_barang,1,25)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,25)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,25) 	= substring(updReff.nama_barang,1,25) and
			upd.katalog_kode 				is null;

-- update pakai substring 20 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,20) = substring(mkatalogs.nama_barang,1,20)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,20)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,20) 	= substring(updReff.nama_barang,1,20) and
			upd.katalog_kode 				is null;

select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama <> katalog_nama;
	
select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	katalog_kode is null and 
			( qty_awal > 0 or qty_akhir > 0);


UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		* 
					from
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog,
											(
												select		sakti_nama_klp, sakti_kode, sakti_nama,
															qty_awal, qty_masuk, qty_keluar, qty_akhir
													from	rsfPelaporan.tjurnal_sakti
													where	sakti_nama in (
																select 		tjs.sakti_nama
																	from 	rsfPelaporan.tjurnal_sakti tjs
																	group   by tjs.sakti_nama
																	having  count(1) = 1
															)
											) tSakti
									where	mKatalog.nama_barang = tSakti.sakti_nama
							) test
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang;




UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		nama_barang, kode
					from	rsfMaster.mkatalog_farmasi
					where	nama_barang not in (
								select 		nama_barang
									from 	rsfMaster.mkatalog_farmasi
									group   by nama_barang
									having  count(1) > 1
							)
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sakti_nama in (
									select 		tjs.sakti_nama
										from 	rsfPelaporan.tjurnal_sakti tjs
										group   by tjs.sakti_nama
										having  count(1) = 1
								)

