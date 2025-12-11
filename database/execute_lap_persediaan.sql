SET collation_connection = 'latin1_swedish_ci';
ALTER DATABASE rsfPelaporan CHARACTER SET latin1 COLLATE latin1_swedish_ci;
ALTER TABLE laporan_mutasi_bulan CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci;
ALTER TABLE laporan_mutasi_bulan_depo CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci;


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

-- proses Transform, mengolah menjadi laporan bulanan / triwulan
-- bulan Maret 2022, stokOpName 31 Maret 2022 (khusus so ini, mengambil data dari jml_trxruangan)
-- bulan April 2022, mengambil stok awal dari hasil stokOpName 31 Maret 2022
-- bulan Mei 2022
-- bulan Juni 2022, ada proses opname pada 30 Juni 2022
-- bulan Juli 2022, ada opsi untuk mengambil saldo awal dari stok opname akhir Juni 2022
-- bulan Agustus 2022
-- bulan September 2022, ada proses opname pada 30 September 2022
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 3;
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 4;
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 5;
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 6;
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 7;
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 8;
delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 9;

delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 3;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 4;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 5;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 6;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 7;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 8;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 9;

delete from rsfPelaporan.laporan_mutasi_bulan where tahun = 2022 and bulan = 11;
delete from rsfPelaporan.laporan_mutasi_bulan_depo where tahun = 2022 and bulan = 11;

CALL proc_lap_persediaan_transform_opname("20220331");
CALL proc_lap_persediaan_transform_saldoawal("202204","1");
CALL proc_lap_persediaan_transform_trx("202204");
CALL proc_lap_persediaan_transform_saldoakhir("202204");

CALL proc_lap_persediaan_transform_saldoawal("202205","0");
CALL proc_lap_persediaan_transform_trx("202205");
CALL proc_lap_persediaan_transform_saldoakhir("202205");

CALL proc_lap_persediaan_transform_saldoawal("202206","0");
CALL proc_lap_persediaan_transform_trx("202206");
CALL proc_lap_persediaan_transform_saldoakhir("202206");
CALL proc_lap_persediaan_transform_opname("20220630");

CALL proc_lap_persediaan_transform_saldoawal("202207","1");
CALL proc_lap_persediaan_transform_trx("202207");
CALL proc_lap_persediaan_transform_saldoakhir("202207");

CALL proc_lap_persediaan_transform_saldoawal("202208","0");
CALL proc_lap_persediaan_transform_trx("202208");
CALL proc_lap_persediaan_transform_saldoakhir("202208");
CALL proc_lap_persediaan_transform_saldoawal("202209","0");
CALL proc_lap_persediaan_transform_trx("202209");
CALL proc_lap_persediaan_transform_saldoakhir("202209");
CALL proc_lap_persediaan_transform_opname("20220930");

CALL proc_lap_persediaan_transform_saldoawal("202210","1");
CALL proc_lap_persediaan_transform_trx("202210");
CALL proc_lap_persediaan_transform_saldoakhir("202210");

CALL proc_lap_persediaan_transform_saldoawal("202211","0");
CALL proc_lap_persediaan_transform_trx("202211");
CALL proc_lap_persediaan_transform_saldoakhir("202211");

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
