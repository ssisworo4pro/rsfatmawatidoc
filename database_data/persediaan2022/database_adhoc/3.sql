40R066
40R047

80D008.07
80D008.01

42R297.01
83C002

10P236
10P225
10P249

80S017
80S018



truncate table rsfPelaporan.laporan_so_grp;
insert into rsfPelaporan.laporan_so_grp ( katalog_kode, katalog_kode_grp )
select 		katalog_kode, max(katalog_kode_grp) as katalog_kode_grp
	from 	laporan_mutasi_saldo_simgos lmss
	group   by katalog_kode

select * from rsfPelaporan.laporan_so_grp where katalog_kode = '40R066';
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '40R047';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '40R066' where katalog_kode = '40R066';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '40R066' where katalog_kode = '40R047';

select * from rsfPelaporan.laporan_so_grp where katalog_kode = '80D008.07';
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '80D008.01';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '80D008.01' where katalog_kode = '80D008.07';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '80D008.01' where katalog_kode = '80D008.01';

select * from rsfPelaporan.laporan_so_grp where katalog_kode = '42R297.01';
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '83C002';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '83C002' where katalog_kode = '83C002';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '83C002' where katalog_kode = '42R297.01';


10P236
10P225
10P249
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '10P236';
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '10P225';
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '10P249';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '10P236' where katalog_kode = '10P236';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '10P236' where katalog_kode = '10P225';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '10P236' where katalog_kode = '10P249';

80S017
80S018
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '80S017';
select * from rsfPelaporan.laporan_so_grp where katalog_kode = '80S018';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '80S017' where katalog_kode = '80S017';
update rsfPelaporan.laporan_so_grp set katalog_kode_grp = '80S017' where katalog_kode = '80S018';

PFH056
insert into rsfPelaporan.laporan_so_grp ( katalog_kode, katalog_kode_grp ) values ('PFH056','PFH056');
