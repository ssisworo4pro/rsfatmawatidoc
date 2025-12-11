call rsfMaster.mkatalog_sync('persiapan',0);
call rsfMaster.mkatalog_sync('anggaranjns',0);
call rsfMaster.mkatalog_sync('anggaranjnssub',0);
call rsfMaster.mkatalog_sync('kelompok',0);
call rsfMaster.mkatalog_sync('kemasan',0);
call rsfMaster.mkatalog_sync('pbf',0);
call rsfMaster.mkatalog_sync('pabrik',0);
call rsfMaster.mkatalog_sync('generik',0);
call rsfMaster.mkatalog_sync('brand',0);
call rsfMaster.mkatalog_sync('analisaKatalog',0);

call rsfMaster.mkatalog_sync('farmasi',0);


call rsfMaster.mkatalog_sync('buffergudang',0);
select * from rsfMaster.mkatalog_buffer_gudang;
call rsfMaster.tkatalog_sync('penerimaan','T00202301000001');
call rsfMaster.tkatalog_sync('penerimaan','T00202301000002');

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
			left outer join rsfMaster.mkatalog_pbf pbf
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
			rsfMaster.mkatalog_farmasi mf
	where 	tp.id_katalog = mf.kode and
			tp.kode_reff = 'T00202211000576'
UNION ALL
select 		barang.NAMA, pbd.* 
	from 	inventory.penerimaan_barang_detil pbd,
			inventory.barang barang
	where 	barang.id = pbd.BARANG and 
			pbd.PENERIMAAN = 4613;
