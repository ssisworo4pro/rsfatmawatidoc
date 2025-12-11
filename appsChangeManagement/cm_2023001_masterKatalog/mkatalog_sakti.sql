insert into rsfMaster.mkatalog_sakti_hdr
(	kode, uraian, userid_updt, sysdate_updt )
select 		sakti_kode_klp as kode,
      		sakti_nama_klp as uraian,
      		0,
      		SYSDATE()
	from	rsfPelaporan.tjurnal_sakti_klp;

insert into  mkatalog_sakti ( id_hdr, kode, uraian, userid_updt, sysdate_updt )
select 		( select	hdr.id 
				from	rsfMaster.mkatalog_sakti_hdr hdr
				where	hdr.kode = sakti.sakti_kode_klp ) as id_hdr,
			sakti.sakti_kode as kode, sakti.sakti_nama as uraian,
			0 as userid_updt, SYSDATE() as sysdate_updt
	from 	rsfPelaporan.tjurnal_sakti2022 sakti;


select * from tjurnal_sakti2022;

insert into  mkatalog_sakti ( id_hdr, kode, uraian, userid_updt, sysdate_updt )
select 		( select	hdr.id 
				from	rsfMaster.mkatalog_sakti_hdr hdr
				where	hdr.kode = sakti.sakti_kode_klp ) as id_hdr,
			sakti.sakti_kode as kode, sakti.sakti_nama as uraian,
			0 as userid_updt, SYSDATE() as sysdate_updt
	from 	rsfPelaporan.tjurnal_sakti2022 sakti
	where	sakti.sakti_kode != '' 
	having  id_hdr is not null;


delete from rsfMaster.mkatalog_sakti where id =
	(	select max(id) from
			( 
				select 		max(id) as id 
					from 	rsfMaster.mkatalog_sakti
					group 	by id_hdr, kode
					having 	count(1) > 1 
			) 
	);


alter table mkatalog_farmasi add id_barang_sakti int(11) null;

mkatalog_farmasi.id_barang_sakti = mkatalog_sakti.id
mkatalog_sakti.id_hdr = mkatalog_sakti_hdr.id


