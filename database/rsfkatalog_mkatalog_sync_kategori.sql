select kode, count(1) from rsfKatalog.mkatalog_kelompok group by kode;
select id, kode, kelompok_barang from rsfKatalog.mkatalog_kelompok;
select * from inventory.kategori k where left(k.id,1) = '1' and jenis = 3;
select * from inventory.kategori k where left(k.id,1) = '1' and jenis = 2;

select 		katJenis.NAMA, katRinci.* 
	from 	inventory.kategori katRinci,
			( select MAX(NAMA) as NAMA, max(ID) as ID from inventory.kategori where jenis = 2 and left(ID,1) = '1' group by left(ID,3) ) katJenis
	where 	left(katRinci.id,3) = left(katJenis.id,3) and
			left(katRinci.id,1) = '1' and 
			katRinci.jenis = 3;
		
select * from rsfKatalog.mkatalog_anggaranjns;
select * from rsfKatalog.mkatalog_anggaranjnssub;

select * from masterf_katalog mk where id_kelompokbarang = 32;
