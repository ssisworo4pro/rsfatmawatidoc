-- Mendapatkan perhitungan harga perolehan
select 		dptd.BARANG as katalog_id,
			dpth.TANGGAL_DIBUAT as katalog_tanggal,
			dptd.JUMLAH as katalog_qty,
			dptd.HARGA as katalog_harga,
			dptd.DISKON as katalog_discount,
			((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON)) / dptd.JUMLAH) as katalog_hargadiscount,
			case when dpth.PPN = 'ya' then 0 else (((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON) * 11 / 100) / dptd.JUMLAH end as katalog_ppn,
			case when dpth.PPN = 'ya' 
					then CEILING((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON)) / dptd.JUMLAH * 100) / 100
					else CEILING((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON) * 111 / 100) / dptd.JUMLAH * 100) / 100
			end as katalog_hargaperolehan
	from 	rsfPelaporan.dlap_persediaan_trmrkn dpth,
			rsfPelaporan.dlap_persediaan_trmrkndtl dptd,
			inventory.barang b
	where	dpth.id_penerimaan = dptd.id_penerimaan and
			dptd.BARANG = b.ID and
			dptd.BARANG = 11497;

-- ? TMT mulai diperhitungkan, jika ada jamnya
--   misal jam 13.00 siang
--   akan diberlakukan 1 hari sesudahnya atau bgmana
--   Insert Master Katalog
insert into rsfPelaporan.mlap_katalog (	katalog_id, katalog_kode, katalog_nama, kateg_kode, kateg_nama )
	select 		qjnstrx.katalog_id, qjnstrx.katalog_kode, qjnstrx.katalog_nama, qjnstrx.kateg_kode, qjnstrx.kateg_nama
		from	(	
					select		distinct dptd.BARANG as katalog_id, b.NAMA as katalog_nama, b.KODE_BARANG as katalog_kode, 
								k.id as kateg_kode, k.nama as kateg_nama
						from 	rsfPelaporan.dlap_persediaan_trmrkndtl dptd,
								inventory.barang b,
								inventory.kategori k
						where	dptd.BARANG 		= b.ID and
								b.KATEGORI 			= k.id
				) qjnstrx
				left outer join rsfPelaporan.mlap_katalog
				on qjnstrx.katalog_id 		= rsfPelaporan.mlap_katalog.katalog_id
		where	rsfPelaporan.mlap_katalog.katalog_id is null;

-- * kasus :
-- 1. kode katalog null
-- 2. kode katalog double

--   Pembentukan Master Katalog Harga
insert into rsfPelaporan.mlap_katalog_harga (
			katalog_id,			katalog_tanggal,		penerimaan_dtl_id,		katalog_qty,
			katalog_harga,		katalog_discount,		katalog_hargadiscount,	katalog_ppn,		katalog_hargaperolehan )
select 		dptd.BARANG as katalog_id,
			date(dpth.TANGGAL_DIBUAT) as katalog_tanggal,
			dptd.id_penerimaan_dtl as penerimaan_dtl_id,
			dptd.JUMLAH as katalog_qty,
			dptd.HARGA as katalog_harga,
			dptd.DISKON as katalog_discount,
			CEILING((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON)) / dptd.JUMLAH * 10000) / 10000 as katalog_hargadiscount,
			case when dpth.PPN = 'ya' 
					then 0 
					else CEILING((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON) * 11 / 100) / dptd.JUMLAH * 10000) / 10000 end as katalog_ppn,
			case when dpth.PPN = 'ya'
					then CEILING((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON)) / dptd.JUMLAH * 100) / 100
					else CEILING((((dptd.JUMLAH * dptd.HARGA) - dptd.DISKON) * 111 / 100) / dptd.JUMLAH * 100) / 100
			end as katalog_hargaperolehan
	from 	rsfPelaporan.dlap_persediaan_trmrkn dpth,
			rsfPelaporan.dlap_persediaan_trmrkndtl dptd,
			inventory.barang b
	where	dpth.id_penerimaan = dptd.id_penerimaan and
			dptd.BARANG = b.ID;
			
select * from rsfPelaporan.mlap_katalog_harga where katalog_id = 11497;

--- update harga terakhir
update		rsfPelaporan.mlap_katalog mkh_update,
			(
				select 		* 
					from 	rsfPelaporan.mlap_katalog_harga mkh 
					where	mkh.penerimaan_dtl_id = 
							( select max(penerimaan_dtl_id) 
								from rsfPelaporan.mlap_katalog_harga mkh2
								where mkh2.katalog_id = mkh.katalog_id ) ) mkh_select
			set mkh_update.harga_perolehan_akhir = mkh_select.katalog_hargaperolehan
		where	mkh_update.katalog_id = mkh_select.katalog_id;

-- select harga hpt dan historisnya
select 		mk.*, mkh.katalog_tanggal, mkh.katalog_hargaperolehan, mkh.*
	from 	rsfPelaporan.mlap_katalog mk, 
			rsfPelaporan.mlap_katalog_harga mkh
	where	mk.katalog_id = mkh.katalog_id;

-- perhitungan stok akhir berdasarkan opname
select max(sodtl.katalog_id) as katalog_id, 
       sum(sodtl.jml_opname) as jml_opname
  from dlap_persediaan_sodtl sodtl,
       dlap_persediaan_so so
 where so.id_opname = sodtl.id_opname and
       so.tanggal = '2022-09-30 23:59:59'
	 group by sodtl.katalog_id;


-- perhitungan stok akhir berdasarkan opname bulan 9
CALL rsfPelaporan.proc_lap_persediaan_transform("202209");

UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
			(		
				select max(sodtl.katalog_id) as katalog_id, 
					   sum(sodtl.jml_opname) as jumlah
				  from dlap_persediaan_sodtl sodtl,
					   dlap_persediaan_so so
				 where so.id_opname = sodtl.id_opname and
					   so.tanggal = '2022-09-30 23:59:59'
				 group by sodtl.katalog_id
			) as persediaanlap
	SET		upd.jumlah_opname 			= persediaanlap.jumlah
	WHERE	upd.bulan 					= 9 and
			upd.tahun 					= 2022 and
			persediaanlap.katalog_id 	= upd.id_katalog;

-- dapatkan harga berdasarkan HPT
UPDATE		rsfPelaporan.laporan_mutasi_bulan as upd,
			(		
				select katalog_id as katalog_id, 
					   harga_perolehan_akhir as jumlah
				  from rsfPelaporan.mlap_katalog
			) as persediaanlap
	SET		upd.harga_opname 			= persediaanlap.jumlah,
			upd.nilai_opname 			= persediaanlap.jumlah * upd.jumlah_opname
	WHERE	upd.bulan 					= 9 and
			upd.tahun 					= 2022 and
			persediaanlap.katalog_id 	= upd.id_katalog;

select * from rsfPelaporan.laporan_mutasi_bulan where bulan= 9 and tahun = 2022;



select count(1) from dlap_persediaan where trx_jenis = 20 and trx_jenis_sub = 1;
select count(1) from dlap_persediaan where trx_jenis = 23 and trx_jenis_sub = 1;
select count(1) from dlap_persediaan where trx_jenis = 20 and trx_jenis_sub = 2;
select count(1) from dlap_persediaan where trx_jenis = 23 and trx_jenis_sub = 2;

select 		max(dp.depo_kode), max(dp.depo_nama), 
			max(case when rf.FARMASI is null then 'non farmasi' else 'depo' end)
	from 	rsfPelaporan.dlap_persediaan dp
			left outer join master.ruangan_farmasi rf
			on dp.depo_kode = rf.FARMASI
	group   by dp.depo_kode

CALL rsfPelaporan.proc_lap_persediaan_transform("202209");
select * from rsfPelaporan.laporan_mutasi_bulan where bulan= 9 and tahun = 2022;
select * from rsfPelaporan.mlap_persediaan;


CALL proc_lap_persediaan_transform_opname("20220331");
-- CALL proc_lap_persediaan_transform_saldoakhir("202203","1");
select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 3 and tahun = 2022;

CALL proc_lap_persediaan_transform_saldoawal("202204","1");
CALL proc_lap_persediaan_transform_trx("202204");
CALL proc_lap_persediaan_transform_saldoakhir("202204","0");
select * from rsfPelaporan.mlap_persediaan;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022 and jumlah_awal < 0;
select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022;
select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022 and jumlah_akhir < 0;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022 and jumlah_akhir < 0;
(388)
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 3;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 3;
(388)
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 13;




CALL proc_lap_persediaan_transform_saldoawal("202204","1");
CALL proc_lap_persediaan_transform_trx("202204");
CALL proc_lap_persediaan_transform_saldoakhir("202204","0");
CALL proc_lap_persediaan_transform_saldoawal("202205","0");
CALL proc_lap_persediaan_transform_trx("202205");
CALL proc_lap_persediaan_transform_saldoakhir("202205","0");
CALL proc_lap_persediaan_transform_saldoawal("202206","0");
CALL proc_lap_persediaan_transform_trx("202206");
CALL proc_lap_persediaan_transform_opname("20220630");
CALL proc_lap_persediaan_transform_saldoakhir("202206","0");

select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 6 and tahun = 2022;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 6 and tahun = 2022 and jumlah_akhir < 0;
select		tahun, bulan, id_katalog, kode_barang, nama_barang, nama_jenis,
			jumlah_awal, jumlah_akhir, jumlah_opname, jumlah_pembelian, jumlah_penjualan, jumlah_floorstok,
			jumlah_hasilproduksi, jumlah_bahanproduksi, jumlah_expired, jumlah_returpembelian, jumlah_akhir
	from 	rsfPelaporan.laporan_mutasi_bulan 
	where 	bulan = 6 and tahun = 2022 and id_katalog = '11269';
select		tahun, bulan, id_katalog, kode_barang, nama_barang, nama_jenis,
			jumlah_awal, jumlah_akhir, jumlah_opname, jumlah_pembelian, jumlah_penjualan, jumlah_floorstok,
			jumlah_hasilproduksi, jumlah_bahanproduksi, jumlah_expired, jumlah_returpembelian, jumlah_akhir
	from 	rsfPelaporan.laporan_mutasi_bulan 
	where 	bulan = 6 and tahun = 2022 and jumlah_opname > 0;


CALL proc_lap_persediaan_transform_saldoawal("202207","0");
CALL proc_lap_persediaan_transform_trx("202207");
CALL proc_lap_persediaan_transform_saldoakhir("202207","0");

CALL proc_lap_persediaan_transform_saldoawal("202208","0");
CALL proc_lap_persediaan_transform_trx("202208");
CALL proc_lap_persediaan_transform_saldoakhir("202208","0");

CALL proc_lap_persediaan_transform_saldoawal("202209","0");
CALL proc_lap_persediaan_transform_trx("202209");
CALL proc_lap_persediaan_transform_saldoakhir("202209","0");
CALL proc_lap_persediaan_transform_opname("20220930");

select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 9 and tahun = 2022;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 9 and tahun = 2022 and jumlah_akhir < 0;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 9 and tahun = 2022 and jumlah_akhir != jumlah_opname;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 9 and tahun = 2022 and jumlah_akhir != jumlah_opname;
select jumlah_awal, jumlah_opname, jumlah_pembelian, jumlah_penjualan, jumlah_floorstok, lmb.* from rsfPelaporan.laporan_mutasi_bulan lmb where bulan = 9 and tahun = 2022 and jumlah_akhir = jumlah_opname and jumlah_awal != jumlah_opname;
select count(1) from rsfPelaporan.laporan_mutasi_bulan lmb where bulan = 9 and tahun = 2022 and jumlah_akhir = jumlah_opname and jumlah_awal != jumlah_opname;


select tahun, bulan, count(1) from rsfPelaporan.laporan_mutasi_bulan group by tahun, bulan


-- verifikasi data
select * from rsfPelaporan.mlap_persediaan;
select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022;
select * from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022 and jumlah_akhir < 0;
select count(1) from rsfPelaporan.laporan_mutasi_bulan where bulan = 4 and tahun = 2022 and jumlah_akhir < 0;

select		tahun, bulan, id_katalog, kode_barang, nama_barang, nama_jenis,
			jumlah_awal, jumlah_pembelian, jumlah_hasilproduksi, jumlah_penjualan, jumlah_floorstok, 
			jumlah_bahanproduksi, jumlah_expired, jumlah_returpembelian, jumlah_akhir
	from 	rsfPelaporan.laporan_mutasi_bulan 
	where 	bulan = 4 and tahun = 2022 and jumlah_akhir < 0;


select		tahun, bulan, id_katalog, kode_barang, nama_barang, nama_jenis,
			jumlah_awal, jumlah_akhir, jumlah_pembelian, jumlah_penjualan, jumlah_floorstok,
			jumlah_hasilproduksi, jumlah_bahanproduksi, jumlah_expired, jumlah_returpembelian, jumlah_akhir
	from 	rsfPelaporan.laporan_mutasi_bulan 
	where 	bulan = 4 and tahun = 2022 and jumlah_akhir < 0;

select 		* 
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 10041
	order 	by tsr.TANGGAL;

select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '10041'
	
select 		*
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 11269
	order 	by tsr.TANGGAL;

select 		*
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 11269
	order 	by tsr.BARANG_RUANGAN, tsr.TANGGAL;

select 		*
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 11269 and
			tsr.JENIS = 53
	order 	by tsr.BARANG_RUANGAN, tsr.TANGGAL;

select 		tkd.*, tk.ALASAN, masref.DESKRIPSI, tk.*
	from 	inventory.transaksi_koreksi_detil tkd,
			inventory.transaksi_koreksi tk
			left outer join
			(	select		ID, DESKRIPSI
					from	master.referensi
					where 	JENIS = 900601 ) masref
			on masref.ID = tk.ALASAN
	where	tkd.BARANG = 11269 and 
			tk.ID = tkd.KOREKSI;

select 		tsr.JENIS, SUM(tsr.JUMLAH)
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 11269 and
			tsr.TANGGAL >= '2022-04-01' and
			tsr.TANGGAL <  DATE_ADD('2022-04-01', INTERVAL 1 MONTH) 
	group   by tsr.JENIS;

select 		tsr.JENIS, SUM(tsr.JUMLAH)
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 11269 and
			tsr.TANGGAL >= '2022-05-01' and
			tsr.TANGGAL <  DATE_ADD('2022-05-01', INTERVAL 1 MONTH) 
	group   by tsr.JENIS;

select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '11269'



--------------------------------------------------
--- Tracking level 2
--- terjadi selisih 5 barang pada opnme bulan 6-2022. 
--- sepertinya sih transaksi memang benar apa adanya.
--- ada jumlah penjulan -10 (koreksi transaksi sebelumnya)
--- harus ada ajustment tanggal koreksi transaksi, jika ingin tidak ada minus
--- tetapi terjadi stok akhir minus
--- harus tracking secara fisik lapangan kenapa terjadi minus
select jumlah_awal, jumlah_akhir, jumlah_opname, lmb.* from rsfPelaporan.laporan_mutasi_bulan lmb where bulan = 9 and tahun = 2022 
and jumlah_akhir != jumlah_opname and jumlah_akhir < 0 and jumlah_opname > 0;

select 		max(DATE_FORMAT(tsr.TANGGAL, '%Y%m')) as bulan, tsr.JENIS, SUM(tsr.JUMLAH)
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN   = br.ID and
			br.BARANG 			 = 10308
	group   by DATE_FORMAT(tsr.TANGGAL, '%Y%m'), tsr.JENIS
	order   by DATE_FORMAT(tsr.TANGGAL, '%Y%m'), tsr.JENIS;

select 		tkd.*, tk.ALASAN, masref.DESKRIPSI, tk.*
	from 	inventory.transaksi_koreksi_detil tkd,
			inventory.transaksi_koreksi tk
			left outer join
			(	select		ID, DESKRIPSI
					from	master.referensi
					where 	JENIS = 900601 ) masref
			on masref.ID = tk.ALASAN
	where	tkd.BARANG = 10308 and 
			tk.ID = tkd.KOREKSI;

select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '10308';

select		jml_trxpersediaan as qty, dp.*
	from	rsfPelaporan.dlap_persediaan dp 
	where	dp.bulan = '202206' and
			dp.katalog_id = '10308';

select 		dps.jml_opname, dps.jml_trxruangan, dps2.depo_nama, dps.katalog_kode, dps.katalog_nama, dps.* 
	from 	rsfPelaporan.dlap_persediaan_sodtl dps,
			rsfPelaporan.dlap_persediaan_so dps2
	where	dps.katalog_id = 10308 and
			dps.id_opname = dps2.id_opname and
			dps.bulan = '202206';

--------------------------------------------------
--- Tracking level 2
--- terjadi perbedaan nilai stok ruangan dan stokOpname pada tanggal 31-03-2022
--- dikonfirmasikan, mana nilai yang benar
select jumlah_akhir - jumlah_opname as slsh, jumlah_awal, jumlah_akhir, jumlah_opname, lmb.* from rsfPelaporan.laporan_mutasi_bulan lmb where bulan = 9 and tahun = 2022 
and jumlah_akhir != jumlah_opname and jumlah_akhir < 0 and jumlah_opname > 0;

select 		max(DATE_FORMAT(tsr.TANGGAL, '%Y%m')) as bulan, tsr.JENIS, SUM(tsr.JUMLAH)
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN   = br.ID and
			br.BARANG 			 = 10695
	group   by DATE_FORMAT(tsr.TANGGAL, '%Y%m'), tsr.JENIS
	order   by DATE_FORMAT(tsr.TANGGAL, '%Y%m'), tsr.JENIS;

select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir, jumlah_opname,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '10695';

select 		dps.jml_opname, dps.jml_trxruangan, dps2.depo_nama, dps.katalog_kode, dps.katalog_nama, dps.* 
	from 	rsfPelaporan.dlap_persediaan_sodtl dps,
			rsfPelaporan.dlap_persediaan_so dps2
	where	dps.katalog_id = 10695 and
			dps.id_opname = dps2.id_opname and
			dps.bulan = '202203';

select 		*
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br
	where 	tsr.BARANG_RUANGAN = br.ID and
			br.BARANG = 10695 and
			tsr.TANGGAL = '2022-03-31 23:59:59' and
			(tsr.JENIS = 15 or tsr.JENIS = 11);

select		sod.id as id_opname_dtl,
			so.ID as id_opname,
			tsr.ID as id_transaksi,
			if ( MONTH(sod.tanggal) = 0, cast('2022-01-01 00:00' as datetime), sod.tanggal) as tanggal,
			if ( MONTH(sod.EXD) = 0, null, sod.EXD ) as expired,
			br.BARANG as katalog_id,
			COALESCE(b.kode_barang,'-') as katalog_kode,
			b.nama as katalog_nama,
			k.id as kateg_kode,
			k.nama as kateg_nama,
			COALESCE(sod.MANUAL, 0) as jml_opname,
			COALESCE(tsr.jumlah, 0) as jml_trxruangan,
			sod.*
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod
			left outer join
				( 
					select 	tsr.ID, tsr.BARANG_RUANGAN, tsr.JUMLAH as JUMLAH
					from 	inventory.transaksi_stok_ruangan tsr,
							( 
								select 	max(ID) as ID, MAX(BARANG_RUANGAN) AS BARANG_RUANGAN 
								from 	inventory.transaksi_stok_ruangan tsrx 
								where 	REF = 4 and (JENIS = 15 or JENIS = 11) group by BARANG_RUANGAN 
							) tsrxx
					where 	tsr.REF = 4 and (tsr.JENIS = 15 or tsr.JENIS = 11) and
							tsr.BARANG_RUANGAN = tsrxx.BARANG_RUANGAN and
							tsr.ID = tsrxx.ID
					order   by tsr.BARANG_RUANGAN 
				) tsr
				on sod.BARANG_RUANGAN = tsr.BARANG_RUANGAN,
			inventory.barang b,
			inventory.kategori k,
			inventory.barang_ruangan br,
			master.ruangan r
	  where	so.id 				= sod.STOK_OPNAME and
			sod.BARANG_RUANGAN 	= br.ID and
			br.BARANG 			= b.id and
			b.KATEGORI 			= k.id and
			so.id 				= 4 and
			so.RUANGAN 			= r.id and
			br.BARANG			= 10695;

--------------------------------------------------
--- Tracking level 2
--- terjadi kasus stokOpname 0, tidak ada pembelian, tapi ada trx penjualan
--- dimana stok opname terjadi adanya nilai stok
select jumlah_akhir - jumlah_opname as slsh, jumlah_awal, jumlah_akhir, jumlah_opname, lmb.* from rsfPelaporan.laporan_mutasi_bulan lmb where bulan = 9 and tahun = 2022 
and jumlah_akhir != jumlah_opname and jumlah_akhir < 0 and jumlah_opname > 0;

select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir, jumlah_opname,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '125';

select 		max(DATE_FORMAT(tsr.TANGGAL, '%Y%m')) as bulan, tsr.JENIS, SUM(tsr.JUMLAH)
	from 	inventory.transaksi_stok_ruangan tsr,
			inventory.barang_ruangan br 
	where 	tsr.BARANG_RUANGAN   = br.ID and
			br.BARANG 			 = 125
	group   by DATE_FORMAT(tsr.TANGGAL, '%Y%m'), tsr.JENIS
	order   by DATE_FORMAT(tsr.TANGGAL, '%Y%m'), tsr.JENIS;

select		jml_trxpersediaan as qty, dp.*
	from	rsfPelaporan.dlap_persediaan dp 
	where	dp.katalog_id = '125';

select		jml_trxpersediaan as qty, dp.*
	from	rsfPelaporan.dlap_persediaan dp 
	where	dp.bulan = '202206' and
			dp.katalog_id = '125';

select 		tkd.*, tk.ALASAN, masref.DESKRIPSI, tk.*
	from 	inventory.transaksi_koreksi_detil tkd,
			inventory.transaksi_koreksi tk
			left outer join
			(	select		ID, DESKRIPSI
					from	master.referensi
					where 	JENIS = 900601 ) masref
			on masref.ID = tk.ALASAN
	where	tkd.BARANG = 125 and 
			tk.ID = tkd.KOREKSI;

----------------------------------------------------------------------------------------------------------
select 		bulan, id_katalog, kode_barang, nama_barang, nama_jenis,
			jumlah_awal as aw, 
			jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
			jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
			jumlah_akhir as akhir, jumlah_opname as opname
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.bulan = 9
	order	by nama_jenis, kode_barang;

select 		dps.jml_opname, dps.jml_trxruangan, dps2.depo_nama, dps.katalog_kode, dps.katalog_nama, dps.* 
	from 	rsfPelaporan.dlap_persediaan_sodtl dps,
			rsfPelaporan.dlap_persediaan_so dps2
	where	dps.katalog_id = 10695 and
			dps.id_opname = dps2.id_opname and
			dps.bulan = '202203';

		
select 		dps.jml_opname, dps.jml_trxruangan, dps2.depo_nama, dps.katalog_kode, dps.katalog_nama, dps.* 
select		count(1)
	from	(
				select 		count(1)
					from 	rsfPelaporan.dlap_persediaan_sodtl dps,
							rsfPelaporan.dlap_persediaan_so dps2
					where	-- dps.katalog_id = 10695 and
							dps.id_opname = dps2.id_opname and
							dps.bulan = '202203' and
							dps.jml_opname != dps.jml_trxruangan
					group   by dps.katalog_id
			) test;
		