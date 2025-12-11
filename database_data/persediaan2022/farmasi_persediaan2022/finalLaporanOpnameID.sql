-- insert untuk mapping id
TRUNCATE TABLE laporan_opname_id;
insert into rsfPelaporan.laporan_opname_id
		( 	opname_id, opname_nama, opname_kode,
			inventory_nama, inventory_kode, inventory_id )
select 		o.id as opname_id,
   			o.katalog_nama as opname_nama,
   			o.katalog_kode as opname_kode,
   			b.NAMA as inventory_nama,
   			b.KODE_BARANG as inventory_kode,
   			b.ID as inventory_id
   	from 	laporan_opname o,
			inventory.barang b
	where	o.katalog_nama = b.NAMA and
			b.STATUS = 1;

-- id double
select 		* 
	from 	laporan_opname_id 
	where 	opname_id in ( select 	opname_id 
							from 	laporan_opname_id 
							group 	by opname_id 
							having 	count(1) > 1)
	order 	by opname_id;

-- update untuk id yang tidak double
UPDATE rsfPelaporan.laporan_opname SET id_inventory = null;
UPDATE		rsfPelaporan.laporan_opname as upd,
			(		
				select 		opname_id, inventory_id
					from 	laporan_opname_id 
					where 	opname_id in ( select 	opname_id 
											from 	laporan_opname_id 
											group 	by opname_id 
											having 	count(1) = 1 )
			) as updReff
	SET		upd.id_inventory 			= updReff.inventory_id
	WHERE	upd.id						= updReff.opname_id;

-- opname yang masih belum ada mappingnya
select * from
(
	select * from laporan_opname where id_inventory is null
	union 
	select * from laporan_opname where katalog_kode = ''
	) masalahKode
where jumlah_fisik <> 0
order by masalahKode.katalog_kode;
select * from inventory.barang b where b.NAMA like 'NOMATHIC CAPS 150MG%';
-- setting ID
update laporan_opname set id_inventory = 13213 where id = 1035;
update laporan_opname set id_inventory = 4 where id = 6671;
update laporan_opname set id_inventory = 13316 where id = 7373;
update laporan_opname set id_inventory = 1690 where id = 1485;
update laporan_opname set id_inventory = 1691 where id = 1486;
update laporan_opname set id_inventory = 2057 where id = 6577;
update laporan_opname set id_inventory = 6169 where id = 6599;
update laporan_opname set id_inventory = 2420 where id = 6578;
update laporan_opname set id_inventory = 13368 where id = 6669;
update laporan_opname set id_inventory = 1563 where id = 4831;
update laporan_opname set id_inventory = 13618 where id = 5176;
update laporan_opname set id_inventory = 4934 where id = 348;
update laporan_opname set id_inventory = 9263 where id = 520;
update laporan_opname set id_inventory = 9725 where id = 547;
update laporan_opname set id_inventory = 13312 where id = 1051;
update laporan_opname set id_inventory = 3810 where id = 274;
update laporan_opname set id_inventory = 13159 where id = 1029;
update laporan_opname set id_inventory = 13269 where id = 1046;
update laporan_opname set id_inventory = 9683 where id = 544;
update laporan_opname set id_inventory = 1511 where id = 5223;

update laporan_opname set katalog_kode = '42M340' where id = 4698;
update laporan_opname set katalog_kode = '80S013' where id = 1079;
update laporan_opname set katalog_kode = '80F118' where id = 1035;
update laporan_opname set katalog_kode = '80C043' where id = 1080;
update laporan_opname set katalog_kode = '80H140' where id = 1089;
update laporan_opname set katalog_kode = '20A014' where id = 6671;
update laporan_opname set katalog_kode = '81C327' where id = 5872;
update laporan_opname set katalog_kode = '42M339' where id = 4697;
update laporan_opname set katalog_kode = '80A126' where id = 1073;
