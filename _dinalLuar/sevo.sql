route add 192.168.5.0 mask 255.255.255.0 10.81.234.1
route delete 0.0.0.0 mask 128.0.0.0
route delete 128.0.0.0 mask 128.0.0.0

kasus sevofluren... harga perolehannnya jomplang ...
select * from inventory.barang b where b.KODE_BARANG = '40S102';
select * from tjurnal_penerimaanall tp where tp.katalog_kode = '40S100';
select * from tjurnal_penerimaanall tp where tp.katalog_kode = '40S098';
select * from inventory.barang b where b.KODE_BARANG = '40S098';
select 		grp.*
	from 	rsfPelaporan.laporan_so_grp grp 
	where   katalog_kode = '40S100' or
			katalog_kode  = '40S098' 

select * from inventory.barang b where b.KODE_BARANG = '40S102' or b.KODE_BARANG = '40S098' or b.KODE_BARANG = '40S100';

update      rsfPelaporan.laporan_so_grp 
	set     katalog_kode_grp = '40S100'
	where   katalog_kode = '40S098';
	
update      rsfPelaporan.laporan_so_grp 
	set     katalog_kode_grp = '40S098'
	where   katalog_kode = '40S098';

select * from rsfPelaporan.laporan_so_trx where katalog_kode = '40S100';


insert into tjurnal_sakti_include(katalog_kode) values ('40S100');
delete from tjurnal_sakti_include where katalog_kode = '40S100';

select * from laporan_hpt
where katalog_kode = '40S098' or katalog_kode = '40S100';
update laporan_hpt set nilai_hppb = 3574.2, nilai_hppb_max = 3574.2 
where katalog_kode = '40S098' or katalog_kode = '40S100';


------ harga perolehan terakhir -------
42C020	PCS     CANCELLOUS SCREW 216.95	      343.524,53
42C029	PCS     CANCELLOUS SCREW 217.85	      343.524,53
42C164	BUAH    CORTEX SCREW 4.5 MM 214.048   335.880,00

PFA048	BOTOL   ALKOHOL 95% 100ML	            2.047,63
PFD001	BKS     DEXTROSE MONOHYDRATE 1 KG      32.000,00

14H013	TAB     HYDROCLOROQUIN 200MG TAB (COVID-19)
14L012	TAB     LIANHUA QINGWEN CAPSULES @12 TABLET	
14N004	TAB     NORMUDAL 2MG TABLET BNPB	
14P014	PAKET   PAKET DLBS (P)



