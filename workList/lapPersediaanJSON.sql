-- IDENTIFIKASI MASALAH :
-- 1. kemungkinan terjadi double data kode barang
--    yang dapat mengakibatkan ketidakkonsistenan transaksi

select * from inventory.barang where KODE_BARANG = '80C0414';
select * from inventory.barang where KODE_BARANG = '42M009';

select KODE_BARANG, COUNT(1) FROM inventory.barang 
GROUP BY KODE_BARANG
having count(1) > 1;

SELECT JSON_ARRAYAGG(JSON_OBJECT(
		'bulan', bulan, 
		'depo_kode', depo_kode, 
		'trx_jenis', trx_jenis, 
		'katalog_kode', katalog_kode, 
		'depo_nama', depo_nama, 
		'trx_nama', trx_nama, 
		'trx_tambahkurang', trx_tambahkurang, 
		'kateg_kode', kateg_kode, 
		'kateg_nama', kateg_nama, 
		'katalog_nama', katalog_nama, 
		'jml_transaksi', jml_transaksi, 
		'jml_katalog', jml_katalog
	))
	FROM	(

	SELECT 		DATE_FORMAT(max(transaksi_stok_ruangan.TANGGAL),'%Y%m') as bulan,
				max(inventory.barang_ruangan.ruangan) as depo_kode,
				max(transaksi_stok_ruangan.jenis) as trx_jenis,
				max(mbarang.kode_barang) as katalog_kode,
				max(master.ruangan.deskripsi) as depo_nama,
				max(jenis_transaksi_stok.deskripsi) as trx_nama,
				max(jenis_transaksi_stok.tambah_atau_kurang) as trx_tambahkurang,
				max(mbarang.KATEGORI) as kateg_kode,
				max(mkategori.NAMA) as kateg_nama,
				max(mbarang.NAMA) as katalog_nama,
				count(1) as jml_transaksi,
				sum(transaksi_stok_ruangan.jumlah) as jml_katalog
		FROM	inventory.transaksi_stok_ruangan,
				inventory.barang_ruangan,
				inventory.jenis_transaksi_stok,
				inventory.barang mbarang,
				inventory.kategori mkategori,
				master.ruangan
		WHERE	transaksi_stok_ruangan.barang_ruangan = barang_ruangan.id AND
				transaksi_stok_ruangan.jenis = jenis_transaksi_stok.id AND
				master.ruangan.id = inventory.barang_ruangan.ruangan AND
				mbarang.id = inventory.barang_ruangan.BARANG AND
				mkategori.ID = mbarang.KATEGORI AND
				transaksi_stok_ruangan.TANGGAL >= '2022-08-01' and 
				transaksi_stok_ruangan.TANGGAL < DATE_ADD('2022-08-01', INTERVAL 1 MONTH)
		GROUP	BY 	inventory.barang_ruangan.ruangan,
					transaksi_stok_ruangan.jenis,
					mbarang.KATEGORI,
					inventory.barang_ruangan.BARANG
		ORDER 	BY 	inventory.barang_ruangan.ruangan,
					transaksi_stok_ruangan.jenis,
					mbarang.KATEGORI,
					inventory.barang_ruangan.BARANG
			) TEST