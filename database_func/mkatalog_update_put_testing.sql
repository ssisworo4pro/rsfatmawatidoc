select * from mkatalog_farmasi_pabrik mfp where id = 14783;
select * from inventory.barang b where b
select * from mkatalog_farmasi mf where mf.id = 14783;
select * from inventory.barang b where b.id = 13754;

select id, kode, nama_barang, id_pabrik  from rsfTeamterima.masterf_katalog mk where mk.kode like '15F005%';
select id, nama, PENYEDIA, KODE_BARANG from inventory.barang b where b.KODE_BARANG like '15F005%';
select id, id_teamterima, id_inventory, kode, id_pabrik  from rsfKatalog.mkatalog_farmasi b where b.kode like '15F005%';
select * from rsfKatalog.mkatalog_farmasi_pabrik where id = 
(select id from rsfKatalog.mkatalog_farmasi b where b.kode like '15F005%');

select 		kat.id, kat.kode, kat.id_teamterima, kat.id_inventory, kat.id_pabrik, kat.nama_barang 
	from 	rsfKatalog.mkatalog_farmasi kat
			left outer join rsfKatalog.mkatalog_farmasi_pabrik pab 
			on kat.id = pab.id 
	where 	pab.id is null;


select mp.nama_pabrik, mKemasan.nama_kemasan, mk.* from rsfTeamterima.masterf_katalog mk
left outer join rsfTeamterima.masterf_pabrik mp  
on mk.id_pabrik = mp.id 
left outer join rsfTeamterima.masterf_kemasan mKemasan
on mKemasan.id = mk.id_kemasankecil 
where mk.nama_barang like CONCAT('%','1/3 TUBULLAR','%');
select mp.nama_pabrik, mKemasan.nama_kemasan, mk.* from rsfTeamterima.masterf_katalog mk
left outer join rsfTeamterima.masterf_pabrik mp  
on mk.id_pabrik = mp.id 
left outer join rsfTeamterima.masterf_kemasan mKemasan
on mKemasan.id = mk.id_kemasankecil 
where mk.kode like CONCAT('%','PFF','%');

-- select * from inventory.barang b where b.ID = 2940;
-- update inventory.barang set STATUS = 0 where ID in (2940,2745,14858,13674,11601,11766,1985,11449, 13353, );
update inventory.barang set KODE_BARANG = '421047' WHERE ID = 4570;

select * from inventory.barang b where b.NAMA like CONCAT('%','TUBULAR 9 HOLE','%');
select 		barang.KODE_BARANG, barang.NAMA, barang.ID, barang.SATUAN as id_satuan, 
			satuan.NAMA as satuan, barang.MERK as id_merk, ref39pabrik.deskripsi as merk, barang.STATUS
	FROM	inventory.barang barang
			left outer join inventory.satuan satuan
			on satuan.ID = barang.SATUAN
			left outer join ( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
			on ref39pabrik.id = barang.MERK
	where   barang.nama like CONCAT('%','TUBULAR 9 HOLE','%')
	ORDER	BY barang.KODE_BARANG, barang.NAMA;


--------------------------

select count(1) from rsfKatalog.mkatalog_farmasi mf where mf.id_inventory is null; 
select count(1) from rsfKatalog.mkatalog_farmasi mf where mf.id_inventory is null; 
select * from rsfKatalog.mkatalog_sync ms;
select 		max(ms.trx_katkode) as trx_katkode, 
			sum(ms.masuk_qty) as masuk_qty, 
			sum(ms.keluar_qty) as keluar_qty, 
			sum(ms.row_qty) as row_qty 
	from 	rsfKatalog.mkatalog_sync ms
	group   by ms.trx_katkode;

select 		KODE_BARANG
	FROM	( select b.KODE_BARANG, count(1) 
				from inventory.barang b 
				group by b.KODE_BARANG 
				having count(1) > 1
			) tblA
			left outer join rsfKatalog.mkatalog_sync mFarm
			on mFarm.trx_katkode = tblA.KODE_BARANG
	WHERE	mFarm.trx_katkode is null;


select 		barang.KODE_BARANG, barang.NAMA, barang.ID, barang.SATUAN as id_satuan, 
			satuan.NAMA as satuan, barang.MERK as id_merk, ref39pabrik.deskripsi as merk, barang.STATUS,
			tblB.trx_katkode, 
			tblB.masuk_qty, 
			tblB.keluar_qty, 
			tblB.row_qty 
	FROM	( select b.KODE_BARANG, count(1) 
				from inventory.barang b 
				where b.KODE_BARANG != '' and STATUS = 1
				group by b.KODE_BARANG 
				having count(1) > 1
			) tblA
			join inventory.barang barang
			on barang.KODE_BARANG = tblA.KODE_BARANG
			left outer join inventory.satuan satuan
			on satuan.ID = barang.SATUAN
			left outer join ( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
			on ref39pabrik.id = barang.MERK
			left outer join
			(	select 		max(ms.trx_katkode) as trx_katkode, 
							sum(ms.masuk_qty) as masuk_qty, 
							sum(ms.keluar_qty) as keluar_qty, 
							sum(ms.row_qty) as row_qty 
					from 	rsfKatalog.mkatalog_sync ms
					group   by ms.trx_katkode
			) tblB
			on tblB.trx_katkode = tblA.KODE_BARANG
	ORDER	BY barang.KODE_BARANG, barang.NAMA;
