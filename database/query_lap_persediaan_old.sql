-- statistik jumlah row, jmlRow semakin bertambah setiap bulannya
-- selisih jmlRow dengan bulan sebelumnya, berarti ada penambahan barang sejumlah selisih tersebut
select tahun, bulan, count(1) as jmlRow from rsfPelaporan.laporan_mutasi_bulan group by tahun, bulan;
select tahun, bulan, nama_depo, count(1) as jmlRow from rsfPelaporan.laporan_mutasi_bulan_depo group by tahun, bulan, id_depo;

------------------------------------------ laporan bulanan / triwulan ------------------------------------------

-- query laporan bulanan
select 		bulan, id_katalog, kode_barang, nama_barang, nama_jenis,
			jumlah_awal as aw, 
			jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
			jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
			jumlah_akhir as akhir, jumlah_opname as opname
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.tahun = 2022 and lmb.bulan = 9
	order	by nama_jenis, kode_barang;

-- query laporan bulanan rekap dan per depo
select 		*
	from	(
				select 		'------- Rumah Sakit -------' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang, 
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and lmb.bulan = 9
					having  jumlah_awal != 0 or jumlah_awal != 0 or jumlah_pembelian != 0 or
							jumlah_hasilproduksi != 0 or jumlah_penjualan != 0 or jumlah_bahanproduksi != 0 or
							jumlah_floorstok != 0 or jumlah_expired != 0 or jumlah_akhir != 0 or jumlah_opname != 0
				UNION ALL
				select 		nama_depo as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo lmb
					where	lmb.tahun = 2022 and lmb.bulan = 9
					having  jumlah_awal != 0 or jumlah_awal != 0 or jumlah_pembelian != 0 or
							jumlah_hasilproduksi != 0 or jumlah_penjualan != 0 or jumlah_bahanproduksi != 0 or
							jumlah_floorstok != 0 or jumlah_expired != 0 or jumlah_akhir != 0 or jumlah_opname != 0
			) depo
	where   kode_jenis = '10101'
	order	by nama_jenis, id_katalog, nama_depo;
select kode_jenis, max(nama_jenis), sum(1) from rsfPelaporan.laporan_mutasi_bulan lmb where bulan = 9 group by kode_jenis;

-- query laporan triwulan
select		'tahun 2022 triwulan 3' as judul,
			max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
			max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
			sum(aw) as aw, 
			sum(beli) as beli, sum(prod) as prod,
			sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
			sum(akhir) as akhir, sum(opname) as opname
	from	(
				select 		bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 7
				UNION ALL
				select 		bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 8
				UNION ALL
				select 		bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 9
			) subquery
	group   by id_katalog
	order	by nama_jenis, kode_barang, id_katalog;

-- query laporan triwulan rekap dan per depo
select		'tahun 2022 triwulan 2' as judul,
			max(nama_depo) as nama_depo,
			max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
			max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
			sum(aw) as aw, 
			sum(mmasuk) as mmasuk,
			sum(mkeluar) as mkeluar,
			sum(beli) as beli, sum(prod) as prod,
			sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
			sum(akhir) as akhir, sum(opname) as opname
	from	(
				select 		'--- Rumah Sakit ---' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan
					where	tahun = 2022 and 
							bulan = 4
				UNION ALL
				select 		nama_depo as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 4
				UNION ALL
				select 		'--- Rumah Sakit ---' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 5
				UNION ALL
				select 		nama_depo as nama_depo,
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 5
				UNION ALL
				select 		'--- Rumah Sakit ---' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 6
				UNION ALL
				select 		nama_depo as nama_depo,
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 6
			) subquery
	group   by id_katalog, nama_depo
	order	by nama_jenis, kode_barang, id_katalog, nama_depo;

select		'tahun 2022 triwulan 3' as judul,
			max(nama_depo) as nama_depo,
			max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
			max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
			sum(aw) as aw, 
			sum(mmasuk) as mmasuk,
			sum(mkeluar) as mkeluar,
			sum(beli) as beli, sum(prod) as prod,
			sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
			sum(akhir) as akhir, sum(opname) as opname
	from	(
				select 		'--- Rumah Sakit ---' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan
					where	tahun = 2022 and 
							bulan = 7
				UNION ALL
				select 		nama_depo as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							jumlah_awal as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 7
				UNION ALL
				select 		'--- Rumah Sakit ---' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 8
				UNION ALL
				select 		nama_depo as nama_depo,
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							0 as akhir, 0 as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 8
				UNION ALL
				select 		'--- Rumah Sakit ---' as nama_depo, 
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan lmb
					where	lmb.tahun = 2022 and 
							lmb.bulan = 9
				UNION ALL
				select 		nama_depo as nama_depo,
							bulan, id_katalog, kode_barang, nama_barang,
							kode_jenis,
							nama_jenis,
							0 as aw, 
							0 as mmasuk,
							0 as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 9
			) subquery
	group   by id_katalog, nama_depo
	order	by nama_jenis, kode_barang, id_katalog, nama_depo;

------------------------------------------ kasus-kasus ------------------------------------------
-- query kasus-kasus
-- kasus kode barang null
select 		*
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.tahun = 2022 and lmb.bulan = 9 and lmb.kode_barang is null;

-- kasus kode barang null
select 		lmb.kode_barang, count(1)
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.tahun = 2022 and lmb.bulan = 9
	group   by lmb.kode_barang
	having  count(1) > 1;

-- kasus jumlah akhir <> jumlah opname
select 		count(1)
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.tahun = 2022 and lmb.bulan = 9 and
			jumlah_akhir != jumlah_opname
	order	by nama_jenis, kode_barang;

-- kasus jumlah akhir minus
select 		count(1)
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.tahun = 2022 and lmb.bulan = 9 and
			jumlah_akhir < 0
	order	by nama_jenis, kode_barang;


------------------------------------------ detail tracking sampling kasus ------------------------------------------
--- kasus 1 :
--- sampling kode barang double
select 		*
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.tahun = 2022 and lmb.bulan = 9 and
			kode_barang in (
			select 		max(lmb.kode_barang)
				from 	rsfPelaporan.laporan_mutasi_bulan lmb
				where	lmb.tahun = 2022 and lmb.bulan = 9
				group   by lmb.kode_barang
				having  count(1) > 1
			)
	order by kode_barang;

--- kasus 2 :
--- * uraian kasus A, terjadi selisih 5 barang pada opnme bulan 6-2022. 
---   # Cari solusi untuk selisih 5 barang ini akan diperlakukan seperti apa
---   bulan 6, terjadi selisih hasil perhitungan jumlah_akhir vs jumlah_opname 
---   bulan 7, menggunakan jumlah_akhir dari bulan 6 sebagai stok awal
select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir, jumlah_opname,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '10308';

---   untuk DEPO yang melakukan stokOpName
select 		dps.jml_opname, dps.jml_trxruangan, dps2.depo_nama, dps.katalog_kode, dps.katalog_nama, dps.* 
	from 	rsfPelaporan.dlap_persediaan_sodtl dps,
			rsfPelaporan.dlap_persediaan_so dps2
	where	dps.katalog_id = 10308 and
			dps.id_opname = dps2.id_opname and
			dps2.tanggal = '2022-06-30 23:59:59' and
			dps.bulan = '202206';

--- uraian kasus B
--- * uraian kasus B, terlihat pada bulan 6-2022, ada penjualan -10
---   # pilihan solusi :
---     - dibuat transaksi untuk mengeser penjualan minus ke bulan sebelumnnya misalnya, agar tidak minus
---     - dibiarkan minus, maka dilaporan akan ada minus,
---       jika secara triwulan angkanya bisa jadi positif, tapi jika diturunkan jadi bulan bisa negatif
---       tetapi ini baru kasus minus di dalam 1 triwulan, mungkin juga akan terjadi kasus lewat triwulan 
---       yang mengakibatkan laporan triwulannya minus, akan diperlakukan seperti apa
---
select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir, jumlah_opname,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '10308';

---   untuk rincian trx
select		dp.jml_trxpersediaan as qty, 
			dp.bulan,
			dp.depo_nama,
			dp.trx_nama,
			dp.trxsub_nama,
			mp.klp_pengali,
			mp.klp_kolomupd,
			dp.depo_kode 
	from	rsfPelaporan.dlap_persediaan dp,
			rsfPelaporan.mlap_persediaan mp
	where	dp.katalog_id 			 = '10308' and 
			dp.trx_jenis 			 = mp.trx_jenis and
			dp.trx_jenis_sub 		 = mp.trx_jenis_sub and
			mp.klp_pengali 			!= 0;

--- kasus 3 :
--- terjadi kasus stokOpname 0, tidak ada pembelian, tapi ada trx penjualan minus dan plus
--- dimana stok opname terjadi adanya nilai stok
select 		bulan, jumlah_awal, jumlah_pembelian, jumlah_penjualan, jumlah_akhir, jumlah_opname,
			lmb.* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb
	where	lmb.id_katalog = '125';

---   untuk rincian trx
select		dp.jml_trxpersediaan as qty, 
			dp.bulan,
			dp.depo_nama,
			dp.trx_nama,
			dp.trxsub_nama,
			mp.klp_pengali,
			mp.klp_kolomupd,
			dp.depo_kode 
	from	rsfPelaporan.dlap_persediaan dp,
			rsfPelaporan.mlap_persediaan mp
	where	dp.katalog_id 			 = '125' and 
			dp.trx_jenis 			 = mp.trx_jenis and
			dp.trx_jenis_sub 		 = mp.trx_jenis_sub and
			mp.klp_pengali 			!= 0;
