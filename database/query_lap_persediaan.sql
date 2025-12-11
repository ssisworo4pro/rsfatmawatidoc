------------------------------------------ Statistik ------------------------------------------
-- statistik jumlah row, jmlRow semakin bertambah setiap bulannya
-- selisih jmlRow dengan bulan sebelumnya, berarti ada penambahan barang sejumlah selisih tersebut
select tahun, bulan, count(1) as jmlRow from rsfPelaporan.laporan_mutasi_bulan group by tahun, bulan;
select tahun, bulan, nama_depo, count(1) as jmlRow from rsfPelaporan.laporan_mutasi_bulan_depo group by tahun, bulan, id_depo;

------------------------------------------ laporan bulanan rinci per depo ------------------------------------------
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

------------------------------------------ laporan triwulan 2 & 3 rinci per depo ------------------------------------------
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
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
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
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
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
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
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
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
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
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
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
							jumlah_mutasimasuk as mmasuk,
							jumlah_mutasikeluar as mkeluar,
							jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
							jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
							jumlah_akhir as akhir, jumlah_opname as opname
					from 	rsfPelaporan.laporan_mutasi_bulan_depo
					where	tahun = 2022 and 
							bulan = 9
			) subquery
	where   kode_jenis = '10101' and id_katalog = '10600'
	group   by id_katalog, nama_depo
	order	by nama_jenis, kode_barang, id_katalog, nama_depo;

------------------------------------------ kasus-kasus ------------------------------------------
-- kasus kode barang null
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
