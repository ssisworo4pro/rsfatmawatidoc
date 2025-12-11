alter table rsfKatalog.mkatalog_kelompok add sts_aktif tinyint(1) null;
update rsfKatalog.mkatalog_kelompok set sts_aktif = 1;
alter table rsfKatalog.mkatalog_kelompok modify sts_aktif tinyint(1) not null;


drop table if exists rsfKatalog.mkatalog_farmasi_pabrik;
drop table if exists rsfKatalog.mkatalog_farmasi;
drop table if exists rsfKatalog.mkatalog_kelompok;

drop table if exists rsfKatalog.mkatalog_farmasi_pabrik;
alter table rsfKatalog.tkatalog_koreksi_detil DROP FOREIGN KEY fk_tkatalog_koreksi_detil_2;
drop table if exists rsfKatalog.mkatalog_farmasi;
drop table if exists rsfKatalog.mkatalog_kelompok;
create table rsfKatalog.mkatalog_kelompok
(
   id                   int(11) not null auto_increment,
   id_teamterima        int(11),
   id_inventory         int(11),
   id_hardcode          int(11),
   id_kategori_simrsgos varchar(10) not null,
   kode                 varchar(20) not null,
   kelompok_barang      varchar(255) not null,
   kode_temp            varchar(10),
   no_urut              int(11) not null default 99,
   gol                  tinyint(4),
   bid                  char(2),
   kel                  char(2),
   subkel               char(2),
   subsubkel            tinyint(4),
   sts_aktif            tinyint(1) not null,
   userid_updt          int(11) not null default 1,
   sysdate_updt         timestamp not null default CURRENT_TIMESTAMP,
   primary key (id)
);

/*==============================================================*/
/* Index: idx_mkatalog_kelompok                                 */
/*==============================================================*/
create index idx_mkatalog_kelompok on rsfKatalog.mkatalog_kelompok
(
   id_teamterima
);

/*==============================================================*/
/* Index: idx_id_kategori_simrsgos                              */
/*==============================================================*/
create unique index idx_id_kategori_simrsgos on rsfKatalog.mkatalog_kelompok
(
   id_kategori_simrsgos
);


call rsfKatalog.mkatalog_sync('kelompok',0);
call rsfKatalog.mkatalog_sync('kelompok_inv',0);
call rsfKatalog.mkatalog_sync('generik',0);
call rsfKatalog.mkatalog_sync('brand',0);
call rsfKatalog.mkatalog_sync('pabrik',0);
call rsfKatalog.mkatalog_sync('kemasan',0);
call rsfKatalog.mkatalog_sync('pbf',0);
call rsfKatalog.mkatalog_sync('anggaranjns',0);
call rsfKatalog.mkatalog_sync('anggaranjnssub',0);
call rsfKatalog.mkatalog_sync('saktihdr',0);
call rsfKatalog.mkatalog_sync('sakti',0);

truncate table rsfKatalog.mkatalog_farmasi_pabrik;
truncate table rsfKatalog.mkatalog_farmasi;
call rsfKatalog.mkatalog_sync('farmasi',0);
call rsfKatalog.mkatalog_sync('farmasi_pabrik',0);
call rsfKatalog.mkatalog_sync('farmasi_update_sakti',0);
call rsfKatalog.mkatalog_sync('analisaKatalog',0);



alter table rsfTeamterima.masterf_katalog add kode_baru2023 varchar(20) null;
update rsfTeamterima.masterf_katalog set kode_baru2023 = kode;



truncate table rsfMaster.mkatalog_sakti
truncate table rsfMaster.mkatalog_sakti_hdr
truncate table rsfMaster.mkatalog_kfa91
truncate table rsfMaster.mkatalog_kfa92
truncate table rsfMaster.mkatalog_kfa93

insert into mkatalog_sakti_hdr(id, kode, uraian, userid_updt, sysdate_updt, sysdate_in, userid_in )
select * from rsfMaster.mkatalog_sakti_hdr

insert into mkatalog_sakti(id, id_hdr, kode, uraian, userid_updt, sysdate_updt, sysdate_in, userid_in, sts_aktif )
select * from rsfMaster.mkatalog_sakti

insert into mkatalog_kfa93 (id, kode, uraian, kode_92, uraian_92, nama_dagang, satuan_kecil, sediaan, golongan, url, userid_updt, sysdate_updt)
select * from rsfMaster.mkatalog_kfa93

insert into mkatalog_kfa92 (id, kode, uraian, satuan, jns_aktual, jml_aktual, url, userid_updt, sysdate_updt)
select * from rsfMaster.mkatalog_kfa92

insert into mkatalog_kfa91 (id, kode, uraian, satuan, url, userid_updt, sysdate_updt)
select * from rsfMaster.mkatalog_kfa91


---------------------------------------

todo :
- sync 	from 	rsfKatalog.mkatalog_anggaranjnssub
		to		rsfTeamterima.masterf_subjenisanggaran ms,
				rsfTeamterima.relasif_anggaran ra 
- sync  from	rsfKatalog.mkatalog_anggaranjns
		to		rsfTeamterima.masterf_subjenisanggaran
- sync 	from 	rsfKatalog.mkatalog_kelompok
		to		rsfTeamterima.masterf_kelompokbarang
		to      inventory.kategori (sync secara manual tidak otomatis)
- sync  from	rsfKatalog.mkatalog_kemasan
		to		rsfTeamterima.masterf_kemasan
		to		inventory.satuan
- sync  from	rsfKatalog.mkatalog_pbf
		to		rsfTeamterima.masterf_pbf
		to		inventory.penyedia
- sync 	from	rsfKatalog.mkatalog_pabrik
		to		rsfTeamterima.masterf_pabrik
		to		( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
- sycn	from	rsfKatalog.mkatalog_generik
		to		rsfTeamterima.masterf_generik
- sync  from	rsfKatalog.mkatalog_brand
		to		rsfTeamterima.masterf_brand


todo interface :
- KELOMPOK 
	* mkatalog_kelompok.id_hardcode dari rsfMaster.msetting_hcode_jenis (id_hcode = 2)
- BARANG FARMASI
	* mkatalog_kelompok.id_kategori_simrsgos dari inventory.kategori

---------------------------------------------------------------

call rsfKatalog.mkatalog_sync('persiapan',0);
call rsfKatalog.mkatalog_sync('anggaranjns',0);
call rsfKatalog.mkatalog_sync('anggaranjnssub',0);
call rsfKatalog.mkatalog_sync('kelompok',0);
call rsfKatalog.mkatalog_sync('kemasan',0);
call rsfKatalog.mkatalog_sync('pbf',0);
call rsfKatalog.mkatalog_sync('pabrik',0);
call rsfKatalog.mkatalog_sync('generik',0);
call rsfKatalog.mkatalog_sync('brand',0);
call rsfKatalog.mkatalog_sync('farmasi',0);
call rsfKatalog.mkatalog_sync('farmasi_pabrik',0);

-- call rsfKatalog.mkatalog_sync('buffergudang',0);
-- select * from rsfKatalog.mkatalog_buffer_gudang;
-- call rsfKatalog.tkatalog_sync('penerimaan','T00202301000001');
-- call rsfKatalog.tkatalog_sync('penerimaan','T00202301000002');

==========================================================================================

select * from rsfTeamterima.transaksif_penerimaan order by kode desc limit 10;

select * from rsfTeamterima.tdetailf_penerimaan where kode_reff = 'T00202212000171';
select * from rsfTeamterima.tdetailf_penerimaan where kode_reff = 'T00202212000170';
select * from inventory.barang where KODE_BARANG = UPPER('12b021');
select * from inventory.barang where KODE_BARANG = '12b021';


select * from rsfTeamterima.tdetailf_penerimaan where kode_reff = 'T00202212000171';
select * from rsfTeamterima.masterf_katalog where KODE = '90B030';
select * from rsfTeamterima.masterf_katalog where KODE = '90B029';
select KODE_BARANG, barang.* from inventory.barang where KODE_BARANG = '90B030';
select * from inventory.barang where KODE_BARANG = '90B029';


select * from rsfTeamterima.masterf_katalog where KODE = '90B030';
select * from inventory.barang where KODE_BARANG = '90B029';

select 		SUBSTR('1234124',2,5);


-- kategori
select * from inventory.kategori;
select * from inventory.dagang;
select * from master.referensi r where r.JENIS = 39;
select count(1) from master.referensi r where r.JENIS = 39;
select * from master.referensi r where r.JENIS = 42;
select * from rsfLiveteamterima.masterf_pabrik


-- satuan
select * from inventory.satuan order by STATUS ;
select * from rsfTeamterima.masterf_kemasan;
select count(1) from rsfTeamterima.masterf_kemasan;
select distinct kode from rsfTeamterima.masterf_kemasan;

-- penyedia
select * from inventory.penyedia;
select * from rsfTeamterima.masterf_pbf -- where kode is null;
select count(1) from rsfTeamterima.masterf_pbf;
select kode from rsfTeamterima.masterf_pbf group by kode having count(1) > 1;


select count(1) from rsfTeamterima.masterf_katalog;
select kode from rsfTeamterima.masterf_katalog group by kode having count(1) > 1;

select * from rsfLiveteamterima.masterf_kelompokbarang;
select * from rsfLiveteamterima.masterf_kelompokbarang_kemkes;

select * from rsfLiveteamterima.masterf_kemasan;
select * from rsfLiveteamterima.masterf_satuankecil;

-- membandingkan revisike, sysydate_in, updt, ver_tglgudang, ver_tglrevisi, ver_akuntansi
select * from (
select 		0 as type, revisike, sysdate_in, sysdate_updt, ver_gudang, ver_tglgudang, 
            ver_revisi, ver_tglrevisi, ver_tglakuntansi, trxv.kode 
	from 	rsfLiveteamterima.transaksif_revpenerimaan  trxv 
	where 	kode = 'T00202211000687' or kode = 'T00202211000560' or kode = 'T00202211000543'
union all
select 		1 as type, revisike, sysdate_in, sysdate_updt, ver_gudang, ver_tglgudang, 
            ver_revisi, ver_tglrevisi, ver_tglakuntansi, trx.kode 
	from 	rsfLiveteamterima.transaksif_penerimaan trx 
	where 	revisike  > -1 and sysdate_in > '2022-11-21'
) test
order by kode, revisike, type;


--- Transaksi penerimaan
sumber dana
inventory
1. APBN
2. APBN-P
3. BLU/PNBP
teamterima
1	01	Pendapatan
2	02	Dipa
3	03	Pendapatan/Dipa
4	04	DIPA - PNBP
5	05	DIPA - APBN
6	06	DIPA - APBN - P

insert into inventory.penerimaan_barang (
			RUANGAN, NO_SP, FAKTUR, TANGGAL, TANGGAL_PENERIMAAN, REKANAN,
			KETERANGAN, PPN, SUMBER_DANA, MASA_BERLAKU, TANGGAL_DIBUAT,
			OLEH, STATUS, JENIS, -- 1 = penerimaan eksternal, 2 = penerimaan PO
			REF_PO );
select		terima.kode, terima.revisike, 0 AS id, 
			'101030111' as ruangan, pembelian.no_doc, 
			terima.no_faktur, terima.sysdate_in,
            ver_tglgudang, pbf.id_inventory, terima.no_doc, 
			case when terima.ppn = 0 then 'Tidak' else 'Ya' end as ppn,
			case terima.id_sumberdana 
				when 0 then 0 
				when 1 then 3
				when 2 then 3
				when 3 then 3
				when 4 then 3
				when 5 then 1
				when 6 then 2
			else 0 end as sumberdana,
			'2024-01-01' as masa_berlaku, ver_tglgudang, 0, 1, 1, ''
	from	rsfLiveteamterima.transaksif_penerimaan terima
			left outer join rsfLiveteamterima.transaksif_pembelian pembelian
			on terima.kode_reffpl = pembelian.kode
			left outer join rsfKatalog.mkatalog_pbf pbf
			on terima.id_pbf = pbf.id
	where   terima.no_doc = '163/OB/11/22'
union all
select 		'kode', 99, pb.* 
	from 	inventory.penerimaan_barang pb 
	where 	pb.KETERANGAN  = '163/OB/11/22';

-- 009/ALK/04/22
-- T00202211000566
-- where	terima.kode = 'T00202205000392'

insert into inventory.penerimaan_barang_detil ( 
			PENERIMAAN, BARANG, NO_BATCH,
			JUMLAH, JUMLAH_BESAR, JUMLAH_KECIL, BONUS,
			HARGA, HARGA_BESAR, DISKON, DISKON_P,
			ONGKIR, MASA_BERLAKU, STATUS, REF_PO_DETIL );
select 		mf.nama_barang, 
			9994613 as id,
			9994613 as PENERIMAAN,
			mf.id_inventory as barang, '-' as no_batch, 
			tp.jumlah_item as jumlah, tp.jumlah_kemasan as jumlah_besar, tp.jumlah_kemasan as jumlah_kecil, 0 as bonus,
			tp.hp_item as harga, tp.hp_item as harga_besar, 
			0 as diskon, 0 as diskon_p, 0 as ongkir, null as masa_berlaku,
			1, 0
	from 	rsfLiveteamterima.tdetailf_penerimaan tp,
			rsfKatalog.mkatalog_farmasi mf
	where 	tp.id_katalog = mf.kode and
			tp.kode_reff = 'T00202211000576'
UNION ALL
select 		barang.NAMA, pbd.* 
	from 	inventory.penerimaan_barang_detil pbd,
			inventory.barang barang
	where 	barang.id = pbd.BARANG and 
			pbd.PENERIMAAN = 4613;
