--- FUNGSI INI DIJALANKAN SETELAH FUNGSI : proc_lap_persediaan_execute
--- catatan sebelum fungsi ini : 
	-- sebelumnya harus ada dulu :
	-- PROSES PEMBENTUKAN data penerimaan dari team
	-- dan juga fungsi :
	-- PROSES TRANSFORM penerimaan rekanan
	-- sepertinya proses diatas tidak diperlukan, tapi langsung proses rekap ke dlap_persediaan,
	-- karena sudah satu server
--- catatan setelah fungsi ini : 
	-- harus dibuat fungsi untuk :
	-- PROSES PEMBENTUKAN nilai_adjusment
--- FUNGSI TRANSFORM meliputi procedure :
	-- CALL proc_lap_persediaan_transform_opname("20220331");
	-- CALL proc_lap_persediaan_transform_saldoawal("202204","1");
	-- CALL proc_lap_persediaan_transform_trx("202204");
	-- CALL proc_lap_persediaan_transform_saldoakhir("202204");

--- SETUUP database rsfPelaporan
SET collation_connection = 'latin1_swedish_ci';
ALTER DATABASE rsfPelaporan CHARACTER SET latin1 COLLATE latin1_swedish_ci;
ALTER TABLE laporan_mutasi_bulan CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci;
ALTER TABLE laporan_mutasi_bulan_depo CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci;

--- MASTER DATA : rsfPelaporan.mlap_persediaan
	-- persiapan proses pembentukan master data untuk proses transform
insert into rsfPelaporan.mlap_persediaan ( 
				trx_jenis, 					trx_jenis_sub, 			trx_nama, 					trxsub_nama, 
				trx_tambahkurang, 			klp_pengali,			klp_kolomupd,				klp_kolomupd_depo )
		values (
				11,							0,						'stokOpname',				'--non sub--',
				'',							0,						'',							'');
insert into rsfPelaporan.mlap_persediaan ( 
				trx_jenis, 					trx_jenis_sub, 			trx_nama, 					trxsub_nama, 
				trx_tambahkurang, 			klp_pengali,			klp_kolomupd,				klp_kolomupd_depo )
	select 		qjnstrx.trx_jenis, 			qjnstrx.trx_jenis_sub, 	qjnstrx.trx_nama, 			qjnstrx.trxsub_nama,
				qjnstrx.trx_tambahkurang, 	0,						'',							''
		from	(	
					select		distinct trx_jenis, trx_jenis_sub, trx_nama, trxsub_nama, trx_tambahkurang 
						from 	rsfPelaporan.dlap_persediaan 
				) qjnstrx
				left outer join rsfPelaporan.mlap_persediaan
				on qjnstrx.trx_jenis 		= rsfPelaporan.mlap_persediaan.trx_jenis and
				   qjnstrx.trx_jenis_sub 	= rsfPelaporan.mlap_persediaan.trx_jenis_sub
		where	rsfPelaporan.mlap_persediaan.trx_jenis is null
		order	by qjnstrx.trx_jenis, qjnstrx.trx_jenis_sub;
update rsfPelaporan.mlap_persediaan set klp_pengali = 0, klp_kolomupd = '', klp_kolomupd_depo = '';
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_floorstok', klp_kolomupd_depo = 'jumlah_floorstok' where trx_jenis = 20 and trx_jenis_sub = 2;
update rsfPelaporan.mlap_persediaan set klp_pengali =  1, klp_kolomupd = 'jumlah_floorstok', klp_kolomupd_depo = 'jumlah_floorstok' where trx_jenis = 23 and trx_jenis_sub = 2;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 30;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 31;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 33;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 34;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 35;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_pembelian', klp_kolomupd_depo = 'jumlah_pembelian' where trx_jenis = 21;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_hasilproduksi', klp_kolomupd_depo = 'jumlah_hasilproduksi' where trx_jenis = 51;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_bahanproduksi', klp_kolomupd_depo = 'jumlah_bahanproduksi' where trx_jenis = 52;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_expired', klp_kolomupd_depo = 'jumlah_expired' where trx_jenis = 54 and trx_jenis_sub = 5;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 20;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 19;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 3;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 3;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 3;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 11;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 12;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 14;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 16;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan', klp_kolomupd_depo = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 20;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = '', klp_kolomupd_depo = 'jumlah_mutasimasuk' where trx_jenis = 20 and trx_jenis_sub = 1;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = '', klp_kolomupd_depo = 'jumlah_mutasikeluar' where trx_jenis = 23 and trx_jenis_sub = 1;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_expired', klp_kolomupd_depo = 'jumlah_expired' where trx_jenis = 53 and trx_jenis_sub = 5;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_expired', klp_kolomupd_depo = 'jumlah_expired' where trx_jenis = 53 and trx_jenis_sub = 10;
select * from rsfPelaporan.mlap_persediaan;
select distinct klp_kolomupd from rsfPelaporan.mlap_persediaan;

--- CATATAN PROSES pembetukan laporan persediaan
	-- proses Transform, mengolah menjadi laporan bulanan / triwulan
	-- bulan April 2022, mengambil stok awal dari SALDO AKHIR MARET 2022
	-- bulan Mei 2022
	-- bulan Juni 2022, ada proses opname pada 30 Juni 2022
	-- bulan Juli 2022, ada opsi untuk mengambil saldo awal dari stok opname akhir Juni 2022
	-- bulan Agustus 2022
	-- bulan September 2022, ada proses opname pada 30 September 2022
	-- bulan Oktober 2022
	-- bulan November 2022
	-- bulan Desember 2022

--- BERSIHKAN DATA
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan >= 4;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan >= 4;

--- PROSES EKSEKUSI PEMBENTUKAN
	-- Proses bulan 4
	-- CALL proc_lap_persediaan_transform_opname("20220331");
	-- CALL proc_lap_persediaan_transform_saldoawal("202204","1");
	-- diganti karena ambil dari saldo akhir bulan sebelumnya
	-- jadi :
CALL proc_lap_persediaan_transform_saldoawal("202204","0");

CALL proc_lap_persediaan_transform_trx("202204");
CALL proc_lap_persediaan_transform_saldoakhir("202204");

	-- Proses bulan 5 s.d 12
CALL proc_lap_persediaan_transform_saldoawal("202205","0");
CALL proc_lap_persediaan_transform_trx("202205");
CALL proc_lap_persediaan_transform_saldoakhir("202205");
CALL proc_lap_persediaan_transform_saldoawal("202206","0");
CALL proc_lap_persediaan_transform_trx("202206");
CALL proc_lap_persediaan_transform_saldoakhir("202206");
CALL proc_lap_persediaan_transform_saldoawal("202207","0");
CALL proc_lap_persediaan_transform_trx("202207");
CALL proc_lap_persediaan_transform_saldoakhir("202207");
CALL proc_lap_persediaan_transform_saldoawal("202208","0");
CALL proc_lap_persediaan_transform_trx("202208");
CALL proc_lap_persediaan_transform_saldoakhir("202208");
CALL proc_lap_persediaan_transform_saldoawal("202209","0");
CALL proc_lap_persediaan_transform_trx("202209");
CALL proc_lap_persediaan_transform_saldoakhir("202209");
CALL proc_lap_persediaan_transform_saldoawal("202210","0");
CALL proc_lap_persediaan_transform_trx("202210");
CALL proc_lap_persediaan_transform_saldoakhir("202210");
CALL proc_lap_persediaan_transform_saldoawal("202211","0");
CALL proc_lap_persediaan_transform_trx("202211");
CALL proc_lap_persediaan_transform_saldoakhir("202211");
CALL proc_lap_persediaan_transform_saldoawal("202212","0");
CALL proc_lap_persediaan_transform_trx("202212");
CALL proc_lap_persediaan_transform_saldoakhir("202212");

	-- proses stok opname bulan 6, 9, 12 sebagai referensi
CALL proc_lap_persediaan_transform_opname("20220630");
CALL proc_lap_persediaan_transform_opname("20220930");
CALL proc_lap_persediaan_transform_opname("20221218");

--- PROSES PEMBENTUKAN nilai_adjusment


-- statistik jumlah row, jmlRow semakin bertambah setiap bulannya
-- selisih jmlRow dengan bulan sebelumnya, berarti ada penambahan barang sejumlah selisih tersebut
select tahun, bulan, count(1) as jmlRow from rsfPelaporan.laporan_mutasi_bulan group by tahun, bulan

-- statistik depo ---- tambahan
select count(1) from laporan_mutasi_bulan where bulan = 3;
select count(1) from laporan_mutasi_bulan_depo where bulan = 3;
select count(1), max(nama_depo) from laporan_mutasi_bulan_depo where bulan = 3 group by id_depo;

select count(1), max(nama_depo), id_depo from laporan_mutasi_bulan_depo where bulan = 4 group by id_depo;
select * from laporan_mutasi_bulan_depo where bulan = 3 and id_depo = '101030115'
union all
select * from laporan_mutasi_bulan_depo where bulan = 4 and id_depo = '101030115';






============================================================= OLD =============================================================
--------------------------------------  proses :
CALL rsfPelaporan.proc_lap_persediaan_transform("202204");
CALL rsfPelaporan.proc_lap_persediaan_transform("202205");
CALL rsfPelaporan.proc_lap_persediaan_transform("202206");

CALL rsfPelaporan.proc_lap_persediaan_transform("202207");
CALL rsfPelaporan.proc_lap_persediaan_transform("202208");
CALL rsfPelaporan.proc_lap_persediaan_transform("202209");

select * from rsfPelaporan.laporan_mutasi_bulan where jumlah_penjualan > 0;
select * from rsfPelaporan.laporan_mutasi_bulan where jumlah_hasilproduksi > 0;
select * from rsfPelaporan.laporan_mutasi_bulan where jumlah_bahanproduksi > 0;
select * from rsfPelaporan.laporan_mutasi_bulan where jumlah_expired > 0;
select * from rsfPelaporan.laporan_mutasi_bulan where jumlah_pembelian > 0;

select tahun, bulan, count(1) from rsfPelaporan.laporan_mutasi_bulan group by tahun, bulan

-- proses pembentukan master data
insert into rsfPelaporan.mlap_persediaan ( 
				trx_jenis, 					trx_jenis_sub, 			trx_nama, 					trxsub_nama, 
				trx_tambahkurang, 			klp_pengali,			klp_kolomupd,				klp_kolomupd_depo )
		values (
				11,							0,						'stokOpname',				'--non sub--',
				'',							0,						'',							'');
insert into rsfPelaporan.mlap_persediaan ( 
				trx_jenis, 					trx_jenis_sub, 			trx_nama, 					trxsub_nama, 
				trx_tambahkurang, 			klp_pengali,			klp_kolomupd,				klp_kolomupd_depo )
	select 		qjnstrx.trx_jenis, 			qjnstrx.trx_jenis_sub, 	qjnstrx.trx_nama, 			qjnstrx.trxsub_nama,
				qjnstrx.trx_tambahkurang, 	0,						'',							''
		from	(	
					select		distinct trx_jenis, trx_jenis_sub, trx_nama, trxsub_nama, trx_tambahkurang 
						from 	rsfPelaporan.dlap_persediaan 
				) qjnstrx
				left outer join rsfPelaporan.mlap_persediaan
				on qjnstrx.trx_jenis 		= rsfPelaporan.mlap_persediaan.trx_jenis and
				   qjnstrx.trx_jenis_sub 	= rsfPelaporan.mlap_persediaan.trx_jenis_sub
		where	rsfPelaporan.mlap_persediaan.trx_jenis is null
		order	by qjnstrx.trx_jenis, qjnstrx.trx_jenis_sub;

select distinct klp_kolomupd from rsfPelaporan.mlap_persediaan;

-- update kolom proses pembentukan laporan
select * from rsfPelaporan.mlap_persediaan;

update rsfPelaporan.mlap_persediaan set klp_pengali = 0, klp_kolomupd = '';
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_floorstok' where trx_jenis = 20 and trx_jenis_sub = 2;
update rsfPelaporan.mlap_persediaan set klp_pengali =  1, klp_kolomupd = 'jumlah_floorstok' where trx_jenis = 23 and trx_jenis_sub = 2;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 30;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 31;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 33;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 34;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1, klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 35;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_pembelian' where trx_jenis = 21;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_hasilproduksi' where trx_jenis = 51;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_bahanproduksi' where trx_jenis = 52;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_expired' where trx_jenis = 54 and trx_jenis_sub = 5;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 20;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 19;
update rsfPelaporan.mlap_persediaan set klp_pengali = 1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 54 and trx_jenis_sub = 3;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 3;

update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_expired', klp_kolomupd_depo = 'jumlah_expired' where trx_jenis = 53 and trx_jenis_sub = 5;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_expired', klp_kolomupd_depo = 'jumlah_expired' where trx_jenis = 53 and trx_jenis_sub = 10;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 3;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 11;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 12;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 14;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 16;
update rsfPelaporan.mlap_persediaan set klp_pengali = -1,  klp_kolomupd = 'jumlah_penjualan' where trx_jenis = 53 and trx_jenis_sub = 20;

20
53
54
23

-- harus dipertegas barang keluar expirednya dari mana ke mana
-- kalo depo ke gudang, berarti masih di lingkungan
-- tapi kalo dari gudang keluar berarti dimusnahkan / diretur

-- statistik proses ekstrak data
select 		sp.bulan, mp.trx_nama,
			spp.prosesd_kasus1row as kasus1, 
			spp.prosesd_trxsumber - prosesd_trxdata as selisih_trx, 
			spp.prosesd_trxdata as trxproses,
			spp.prosesd_rowdata as rowproses,
			spp.* 
	from 	rsfPelaporan.slap_persediaan_proses spp,
			rsfPelaporan.slap_persediaan sp,
			( select trx_jenis, trx_nama from rsfPelaporan.mlap_persediaan 
				group by trx_jenis, trx_nama ) mp
	where   spp.id_proses = sp.id_proses and
			spp.id_jenis  = mp.trx_jenis
	order   by sp.bulan, mp.trx_jenis;

-- memastikan depo-nya depo farmasi ( cek jumlah transaksi depo vs ruangan)
select		count(1)
	from	rsfPelaporan.dlap_persediaan dp,
			rsfPelaporan.mlap_persediaan mp
	where	dp.bulan					= '202206' and
			dp.trx_jenis				= mp.trx_jenis and
			dp.trx_jenis_sub			= mp.trx_jenis_sub and
			mp.klp_kolomupd				= 'jumlah_penjualan'
select		count(1)
	from	rsfPelaporan.dlap_persediaan dp,
			rsfPelaporan.mlap_persediaan mp,
			master.ruangan_farmasi rf
	where	dp.bulan					= '202206' and
			dp.trx_jenis				= mp.trx_jenis and
			dp.trx_jenis_sub			= mp.trx_jenis_sub and
			dp.kode_depo				= rf.farmasi and
			mp.klp_kolomupd				= 'jumlah_penjualan'

-- rekap 
select		dp.bulan,
			dp.trx_jenis,
			max(mp.trx_nama) as trx_nama,
			dp.trx_jenis_sub,
			max(mp.trxsub_nama) as trxsub_nama,
			sum(dp.jml_rowtrxpersediaan) as jml_rowtrxpersediaan,
			sum(dp.jml_trxpersediaan) as jml_trxpersediaan,
			sum(dp.jml_rowtrxruangan) as jml_rowtrxruangan,
			sum(dp.jml_trxruangan) as jml_trxruangan,
			sum(dp.jml_rowtrxpersediaan) - sum(dp.jml_rowtrxruangan) as jml_rowselisih,
			sum(dp.jml_trxpersediaan) - sum(dp.jml_trxruangan) as jml_trxselisih
	from 	rsfPelaporan.mlap_persediaan mp,
			rsfPelaporan.dlap_persediaan dp 
	where 	mp.trx_jenis = dp.trx_jenis and mp.trx_jenis_sub = dp.trx_jenis_sub AND
			( mp.trx_jenis != 54 AND mp.trx_jenis != 53 )
	group 	by dp.trx_jenis, dp.trx_jenis_sub, dp.bulan
	order	by dp.trx_jenis, dp.trx_jenis_sub, dp.bulan;

-- REKAP BARANG MASUK / KELUAR
select		-- dp.bulan,
			dp.trx_jenis,
			max(mp.trx_nama) as trx_nama,
			dp.trx_jenis_sub,
			max(mp.trxsub_nama) as trxsub_nama,
			sum(dp.jml_rowtrxpersediaan) as jml_rowtrxpersediaan,
			sum(dp.jml_trxpersediaan) as jml_trxpersediaan,
			sum(dp.jml_rowtrxruangan) as jml_rowtrxruangan,
			sum(dp.jml_trxruangan) as jml_trxruangan,
			sum(dp.jml_rowtrxpersediaan) - sum(dp.jml_rowtrxruangan) as jml_rowselisih,
			sum(dp.jml_trxpersediaan) - sum(dp.jml_trxruangan) as jml_trxselisih
	from 	rsfPelaporan.mlap_persediaan mp,
			rsfPelaporan.dlap_persediaan dp 
	where 	mp.trx_jenis = dp.trx_jenis and mp.trx_jenis_sub = dp.trx_jenis_sub and
			( mp.trx_jenis = 54 or mp.trx_jenis = 53 )
	group 	by dp.trx_jenis, dp.trx_jenis_sub
	order	by dp.trx_jenis, dp.trx_jenis_sub;

select		dp.bulan,
			dp.trx_jenis,
			max(mp.trx_nama) as trx_nama,
			dp.trx_jenis_sub,
			max(mp.trxsub_nama) as trxsub_nama,
			sum(dp.jml_rowtrxpersediaan) as jml_rowtrxpersediaan,
			sum(dp.jml_trxpersediaan) as jml_trxpersediaan,
			sum(dp.jml_rowtrxpersediaan) - sum(dp.jml_rowtrxruangan) as jml_rowselisih,
			sum(dp.jml_trxpersediaan) - sum(dp.jml_trxruangan) as jml_trxselisih
			-- sum(dp.jml_rowtrxruangan) as jml_rowtrxruangan,
			-- sum(dp.jml_trxruangan) as jml_trxruangan,
	from 	rsfPelaporan.mlap_persediaan mp,
			rsfPelaporan.dlap_persediaan dp 
	where 	mp.trx_jenis = dp.trx_jenis and mp.trx_jenis_sub = dp.trx_jenis_sub  -- AND
			-- ( mp.trx_jenis = 20 OR mp.trx_jenis = 23 OR mp.trx_jenis = 23 )
	group 	by dp.trx_jenis_sub, dp.trx_jenis, dp.bulan
	order	by dp.trx_jenis_sub, dp.trx_jenis, dp.bulan;

-- statistik stokopname
select		dp.bulan,
			max(mp.trx_nama) as trx_nama,
			max(mp.trxsub_nama) as trxsub_nama,
			sum(dp.jml_opname) as jml_trxpersediaan,
			sum(dp.jml_opname) - sum(dp.jml_trxruangan) as jml_trxselisih,
			max(spp.prosesh_rowdata) as row_header,
			max(spp.prosesd_rowdata) as row_detail,
			max(spp.prosesd_trxdata) as trx_detail,
			max(spp.prosesd_kasus1row) as row_selisih
			-- sum(dp.jml_rowtrxruangan) as jml_rowtrxruangan,
			-- sum(dp.jml_trxruangan) as jml_trxruangan,
	from 	rsfPelaporan.mlap_persediaan mp,
			rsfPelaporan.dlap_persediaan_sodtl dp,
			slap_persediaan s,
			slap_persediaan_proses spp 
	where 	mp.trx_jenis = 11 and dp.id_proses = s.id_proses and dp.id_proses = spp.id_proses  and spp.id_jenis = 11
	group 	by dp.bulan
	order	by dp.bulan;
