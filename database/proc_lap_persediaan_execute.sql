--- Refresh Data
truncate table rsfPelaporan.dlap_persediaan_hist;
truncate table rsfPelaporan.dlap_persediaan;
truncate table rsfPelaporan.slap_persediaan_proses;
delete from rsfPelaporan.slap_persediaan;

truncate table rsfPelaporan.dlap_persediaan_sodtl_hist;
truncate table rsfPelaporan.dlap_persediaan_so_hist;
truncate table rsfPelaporan.dlap_persediaan_sodtl;
delete from rsfPelaporan.dlap_persediaan_so;

truncate table dlap_persediaan_trmrkndtl;
delete from dlap_persediaan_trmrkn;
truncate table dlap_persediaan_trmrkndtl_hist;
truncate table dlap_persediaan_trmrkn_hist;

CALL rsfPelaporan.proc_lap_persediaan("202204");
CALL rsfPelaporan.proc_lap_persediaan("202205");
CALL rsfPelaporan.proc_lap_persediaan("202206");
CALL rsfPelaporan.proc_lap_persediaan("202207");
CALL rsfPelaporan.proc_lap_persediaan("202208");
CALL rsfPelaporan.proc_lap_persediaan("202209");
CALL rsfPelaporan.proc_lap_persediaan("202210");
CALL rsfPelaporan.proc_lap_persediaan("202211");
CALL rsfPelaporan.proc_lap_persediaan("202212");



--------------------------------------  proses :



update slap_persediaan_proses set prosesh_rowdata = 0 where id_jenis = 20 or id_jenis = 11;
update rsfPelaporan.slap_persediaan_proses set prosesh_rowdata = 0 where id_jenis = 20 and id_proses >= 16;
update rsfPelaporan.slap_persediaan_proses set prosesh_rowdata = 0 where id_jenis = 20;
select * from  rsfPelaporan.slap_persediaan_proses where id_jenis = 20 and id_proses >= 36;

CALL rsfPelaporan.proc_lap_persediaan("202203");
CALL rsfPelaporan.proc_lap_persediaan("202204");
CALL rsfPelaporan.proc_lap_persediaan("202205");
CALL rsfPelaporan.proc_lap_persediaan("202206");
CALL rsfPelaporan.proc_lap_persediaan("202207");
CALL rsfPelaporan.proc_lap_persediaan("202208");
CALL rsfPelaporan.proc_lap_persediaan("202209");
CALL rsfPelaporan.proc_lap_persediaan("202210");
CALL rsfPelaporan.proc_lap_persediaan("202211");

select * from rsfPelaporan.slap_persediaan_proses order by id_proses desc;
update rsfPelaporan.slap_persediaan_proses set prosesh_rowdata = prosesh_rowsumber where id_proses = 20;

select * from  rsfPelaporan.slap_persediaan_proses where id_jenis = 20 and id_proses >= 16;
update rsfPelaporan.slap_persediaan_proses set prosesh_rowdata = 0 where id_jenis = 20 and id_proses >= 16;


select * from rsfPelaporan.slap_persediaan_proses;
select * from inventory.jenis_transaksi_stok jts;

--------------------------------------  konfirmasi :
-- * terdapat stok_opname_detil dengan exp = '0000-00-00' akan dianggap null atau tgl tertentu atau non exp
select exd from inventory.stok_opname_detil sod where cast(sod.EXD as char) = '0000-00-00';

-------------------------------------- pengecekan masalah
-- masalah :
-- 1. transaksi stokopname. sod tidak ada, tapi ada di tsr
-- 2. transaksi koreksi. transaksi_koreksi tercatat 2 kali di tsr
-- 3. pengecekan jumlah trx persedian vs trx stok ruangan

-- 1. cek transaksi vs stokopname
select * from rsfPelaporan.dlap_persediaan_sodtl where jml_opname <> jml_trxruangan;
select * from rsfPelaporan.dlap_persediaan_so where id_opname = 1;
select 'tsr' as nama, tsr.id AS ID, tsr.barang_ruangan, tsr.JENIS, tsr.JUMLAH, tsr.TANGGAL  
from inventory.transaksi_stok_ruangan tsr, inventory.barang_ruangan br  
where tsr.REF = 1 and tsr.BARANG_RUANGAN = br.id and ( br.BARANG = 318 or br.BARANG = 319 )
UNION ALL
select 'sod' as nama, cast(sod.id as char) AS ID, sod.BARANG_RUANGAN, 0 AS JENIS, sod.MANUAL as JUMLAH, sod.TANGGAL 
from inventory.stok_opname_detil sod, inventory.barang_ruangan bry
where sod.STOK_OPNAME = 1 and sod.BARANG_RUANGAN = br.id and ( br.BARANG = 318 or br.BARANG = 319 );
-- deteksi barang stok opname yang tidak tergenerate menjadi transaksi
select 		*
	from 	inventory.stok_opname so,
			inventory.stok_opname_detil sod,
			inventory.barang_ruangan br
			left outer join
            ( select * from inventory.transaksi_stok_ruangan where REF = 44 and JENIS = 11) tsr
            on br.id = tsr.BARANG_RUANGAN
	where	so.ID = sod.STOK_OPNAME and
			sod.BARANG_RUANGAN = br.ID and
			so.ID = 44
   	having	tsr.BARANG_RUANGAN is null;

-- 2. transaksi koreksi. transaksi_koreksi tercatat 2 kali di tsr
select * from inventory.transaksi_koreksi_detil tkd where id = 3810;
select * from inventory.transaksi_koreksi_detil tkd where koreksi = 575 and barang = 27;
  select 	tsr.*, br.*
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br
	where 	(tsr.REF = 3810 or tsr.REF = 3952) and -- 575 and -- (tsr.JENIS = 53 or tsr.JENIS = 54) and
			tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 27;

-- 3. pengecekan jumlah trx persedian vs trx stok ruangan
select * from rsfPelaporan.dlap_persediaan where jml_rowtrxpersediaan <> jml_rowtrxruangan;
select * from rsfPelaporan.dlap_persediaan where jml_trxpersediaan <> jml_trxruangan;

-- 4. stok opname, detil stok opname tetapi tidak ada di barang ruangan
select		sod.*,
			br.ID 
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod
			left outer join inventory.barang_ruangan br
			on sod.BARANG_RUANGAN 	= br.ID
	  where	so.id 				= sod.STOK_OPNAME and
			so.status 		    = 'Final' and
			so.TANGGAL 	       >= '2022-06-01' and 
			so.TANGGAL 		    < DATE_ADD('2022-06-01', INTERVAL 1 MONTH)
	having  br.ID 				is null

-- 4.b. barang = 0, Kepanjangan kasus 4
select		b.id,
			br.*
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod,
			inventory.barang_ruangan br
			left outer join inventory.barang b
			on br.BARANG 			= b.id,
			master.ruangan r
	  where	so.id 				= sod.STOK_OPNAME and
			sod.BARANG_RUANGAN 	= br.ID and
			so.status 		    = 'Final' and
			so.TANGGAL 	       >= '2022-06-01' and 
			so.TANGGAL 		    < DATE_ADD('2022-06-01', INTERVAL 1 MONTH) and
			so.RUANGAN 			= r.id
	having  b.id is null
select		*
	from	inventory.barang_ruangan
	  where	barang              = 0;

-- 5. transaksi distribusi. tidak ada di tsr dan barang_ruangan, sepertinya karena waktu terima br tidak terbentuk
select * from rsfPelaporan.dlap_persediaan where jml_rowtrxpersediaan <> jml_rowtrxruangan;
select * from rsfPelaporan.dlap_persediaan where jml_trxpersediaan <> jml_trxruangan;

select * from rsfPelaporan.dlap_persediaan 
where jml_trxpersediaan <> jml_trxruangan and trx_jenis = 23;
select * from rsfPelaporan.dlap_persediaan 
where jml_trxpersediaan <> jml_trxruangan and trx_jenis = 20;

select 	tsr.*
from 	inventory.transaksi_stok_ruangan tsr,
		inventory.barang_ruangan br2
where 	-- tsr.REF 				= pd.ID and 
		tsr.JENIS 				= 20 and
		tsr.BARANG_RUANGAN 		= br2.ID and
		br2.ID					= 4180 and
		br2.RUANGAN				= '101030111'


SELECT pd.*, p.*
FROM inventory.pengiriman_detil pd,
     inventory.penerimaan p 
where pd.BARANG_KIRIM = 4180 and
pd.PENGIRIMAN = p.REF and
p.RUANGAN = '101030111' and
p.TANGGAL >= '2022-06-01' AND
p.TANGGAL < '2022-07-01';

select 	tsr.*
from 	inventory.transaksi_stok_ruangan tsr
where   tsr.REF = 25429 
SELECT * FROM inventory.barang_ruangan br where ID = 9909;
select * from inventory.pengiriman_detil pd where ID = 25429
