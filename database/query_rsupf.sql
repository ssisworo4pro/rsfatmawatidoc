select * from rsupf.transaksif_penerimaan tp where kode_reffpl  is null;
select * from rsupf.transaksif_penerimaan tp where kode_reffrenc is null;

select * from rsupf.transaksif_penerimaan tp where kode = 'T00202209000578';
select * from rsupf.transaksif_revpenerimaan tr where kode = 'T00202209000578';

select * from rsupf.transaksif_pembelian tp where kode = 'P0020228000223';
select * from rsupf.transaksif_revpembelian tp where kode = 'P0020228000223'; 

select * from rsupf.transaksif_pengadaan tp where kode = 'H00202208000292';
select * from rsupf.transaksif_perencanaan tp where kode = 'R00202208000267';

select * from rsupf.transaksif_revpemesanan;

select * from masterf_pabrik;
select * from tdetailf_penerimaan where id_katalog = '40A077' 
group by id_katalog;

select id_katalog
	from	(	select id_katalog, id_pabrik from tdetailf_penerimaan group by id_katalog, id_pabrik ) test
	group	by id_katalog
	having  count(1) > 3;

select id_pabrik, tdetailf_penerimaan.* from tdetailf_penerimaan where id_katalog = '10A059';
select id_pabrik, tdetailf_penerimaan.* from tdetailf_penerimaan where id_katalog = '40S065';

select distinct id_pabrik from tdetailf_penerimaan where id_katalog = '10A059';


select * from rsupf.transaksif_revpenerimaan tr where kode = 'T00202209000578';
select * from rsupf.tdetailf_revpenerimaan tp where kode_reff = 'T00202209000578';

select * from rsupf.transaksif_penerimaan tp where kode = 'T00202209000578';
select * from rsupf.tdetailf_penerimaan tp where kode_reff = 'T00202209000578';
select * from rsupf.tdetailf_penerimaanrinc tp where kode_reff = 'T00202209000578';
select * from relasif_revpenerimaan order by kode_reff desc; where kode_reff = 'T00202209000578';
select * from relasif_ketersediaan order by id desc;
select * from relasif_ketersediaan where kode_reff = 'T00202209000578';
select * from relasif_akuntansi;
select * from transaksif_akuntansi order by tgl_doc desc; 
where kode_reff = 'T00202209000578';

select * from relasif_katalogpbf;

select * from masterf_jenisharga;
select * from masterf_katalog order by sysdate_updt desc, sysdate_in desc ;

select * from user;
select * from user_group;
select * from group_module;
select * from `group` g 
select * from module;

select * from masterf_pbf order by sysdate_updt desc;





select * from masterf_depo;
select * from transaksif_distribusi;
select * from masterf_penerimaan;
select * from transaksif_stokkatalog order by sysdate_in desc;


-- nomor penerimaan T00202209000578
-- P0020228000223

