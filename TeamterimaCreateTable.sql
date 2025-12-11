============================================= refresh table target

drop table if exists rsfTeamterima.tdetailf_penerimaan;
drop table if exists rsfTeamterima.tdetailf_penerimaanrinc;
drop table if exists rsfTeamterima.transaksif_penerimaan;
drop table if exists rsfTeamterima.tdetailf_pembelian;
drop table if exists rsfTeamterima.transaksif_pembelian;

drop table if exists rsfTeamterima.masterf_katalog;
drop table if exists rsfTeamterima.masterf_pbf;
drop table if exists rsfTeamterima.masterf_kemasan;
drop table if exists rsfTeamterima.masterf_carabayar;
drop table if exists rsfTeamterima.masterf_jenisharga;

============================================= data master

select count(1) from masterf_jenisharga;
select count(1) from masterf_carabayar;
select count(1) from masterf_kemasan;
select count(1) from masterf_pbf;
select count(1) from masterf_katalog;

masterf_jenisharga	    5 -     5
masterf_carabayar	   24 -    24
masterf_kemasan		  103 -   103
masterf_pbf			 1039 -  1039
masterf_katalog		13552 - 13552

select * from masterf_jenisharga;
select * from masterf_carabayar;
select * from masterf_kemasan;
select * from masterf_pbf;
select * from masterf_katalog;

============================================= data transaksi pembelian
transaksif_pembelian    :   5173 /  5173 -  5173
tdetailf_pembelian      :  18717 / 12994 - 18717
* ada tdetailf_pembelian yang tidak ada masterf_katalog

select count(1) from transaksif_pembelian;
select count(1) from tdetailf_pembelian;

select 		count(1) 
	from 	transaksif_pembelian 
	where 	thn_anggaran = 2021 or thn_anggaran = 2022;
select 		count(1) 
	from 	transaksif_pembelian,
			masterf_jenisharga,
			masterf_pbf,
			masterf_carabayar
	where 	transaksif_pembelian.id_jenisharga  = masterf_jenisharga.id and
			transaksif_pembelian.id_pbf         = masterf_pbf.id and
			transaksif_pembelian.id_carabayar   = masterf_carabayar.id and
			( transaksif_pembelian.thn_anggaran = 2021 or 
			  transaksif_pembelian.thn_anggaran = 2022);
select 		* 
	from 	transaksif_pembelian 
	where 	thn_anggaran = 2021 or thn_anggaran = 2022;

select 		count(1)
	from 	transaksif_pembelian,
			tdetailf_pembelian,
			masterf_pabrik,
			masterf_kemasan,
			masterf_kemasan masterf_kemasan_depo,
			masterf_katalog
	where 	transaksif_pembelian.kode           = tdetailf_pembelian.kode_reff and
	        tdetailf_pembelian.id_pabrik        = masterf_pabrik.id and
	        tdetailf_pembelian.id_kemasan       = masterf_kemasan.id and
	        tdetailf_pembelian.id_kemasandepo   = masterf_kemasan_depo.id and
	        tdetailf_pembelian.id_katalog       = masterf_katalog.id and
	        ( transaksif_pembelian.thn_anggaran = 2022 or 
			  transaksif_pembelian.thn_anggaran = 2021);

select 		count(1)
select 		tdetailf_pembelian.*
	from 	transaksif_pembelian,
			tdetailf_pembelian
	where 	transaksif_pembelian.kode           = tdetailf_pembelian.kode_reff and
	        ( transaksif_pembelian.thn_anggaran = 2022 or 
			  transaksif_pembelian.thn_anggaran = 2021);

============================================= data transaksi penerimaan

transaksif_penerimaan   :  12590 / 12590 - 12590
tdetailf_penerimaan     :  25255 / 18476 - 25255
* ada tdetailf_penerimaan yang tidak ada masterf_katalog
tdetailf_penerimaanrinc :          34165 - 34165

select count(1) from transaksif_penerimaan;
select count(1) from tdetailf_penerimaan;
select count(1) from tdetailf_penerimaanrinc;

select 		count(1) 
	from 	transaksif_penerimaan 
	where 	thn_anggaran = 2021 or thn_anggaran = 2022;
select 		count(1) 
	from 	transaksif_penerimaan,
			masterf_jenisharga,
			masterf_pbf,
			masterf_carabayar
	where 	transaksif_penerimaan.id_jenisharga  = masterf_jenisharga.id and
			transaksif_penerimaan.id_pbf         = masterf_pbf.id and
			transaksif_penerimaan.id_carabayar   = masterf_carabayar.id and
			( transaksif_penerimaan.thn_anggaran = 2021 or 
			  transaksif_penerimaan.thn_anggaran = 2022);
select 		* 
	from 	transaksif_penerimaan 
	where 	thn_anggaran = 2021 or thn_anggaran = 2022;

select 		count(1)
	from 	transaksif_penerimaan,
			tdetailf_penerimaan,
			masterf_pabrik,
			masterf_kemasan,
			masterf_kemasan masterf_kemasan_depo,
			masterf_katalog
	where 	transaksif_penerimaan.kode           = tdetailf_penerimaan.kode_reff and
	        tdetailf_penerimaan.id_pabrik        = masterf_pabrik.id and
	        tdetailf_penerimaan.id_kemasan       = masterf_kemasan.id and
	        tdetailf_penerimaan.id_kemasandepo   = masterf_kemasan_depo.id and
	        tdetailf_penerimaan.id_katalog       = masterf_katalog.id and
	        ( transaksif_penerimaan.thn_anggaran = 2022 or 
			  transaksif_penerimaan.thn_anggaran = 2021);

select 		count(1)
select 		tdetailf_penerimaan.*
	from 	transaksif_penerimaan,
			tdetailf_penerimaan
	where 	transaksif_penerimaan.kode           = tdetailf_penerimaan.kode_reff and
	        ( transaksif_penerimaan.thn_anggaran = 2022 or 
			  transaksif_penerimaan.thn_anggaran = 2021);

select 		count(1)
select 		tdetailf_penerimaanrinc.*
	from 	transaksif_penerimaan,
			tdetailf_penerimaanrinc
	where 	transaksif_penerimaan.kode           = tdetailf_penerimaanrinc.kode_reff and
	        ( transaksif_penerimaan.thn_anggaran = 2022 or 
			  transaksif_penerimaan.thn_anggaran = 2021);
