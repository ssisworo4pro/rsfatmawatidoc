DROP PROCEDURE IF EXISTS rsfPelaporan.proc_lap_persediaan_transform_saldoakhir;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_lap_persediaan_transform_saldoakhir(
	aBulan CHAR(6)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- proc_lap_persediaan_transform_saldoakhir																	-- */
	/* -- description   : menjumlahkan nilai transaksi menjadi nilai akhir											-- */
	/* -- spesification : update laporan_mutasi_bulan jumlah_akhir with calculate trx column						-- */
	/* -- 				  update laporan_mutasi_bulan_depo jumlah_akhir with calculate trx column					-- */
	/* -- sysdateLast 	: 2022-10-21 16:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : add laporan_mutasi_bulan_depo 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vTanggal 		CHAR(10);
	DECLARE vBulan 			integer;
	DECLARE vTahun 			integer;

	SET vTanggal 		= CONCAT(SUBSTRING(aBulan, 1, 4), '-', SUBSTRING(aBulan, 5, 2), '-', '01');
	SET vBulan 			= CAST(SUBSTRING(vTanggal, 6, 2) as UNSIGNED);
	SET vTahun 			= CAST(SUBSTRING(vTanggal, 1, 4) as UNSIGNED);

	START TRANSACTION;
		UPDATE		rsfPelaporan.laporan_mutasi_bulan 
			SET		jumlah_akhir 	= jumlah_awal + jumlah_pembelian + jumlah_hasilproduksi + jumlah_koreksi +
									  - jumlah_penjualan - jumlah_floorstok - jumlah_bahanproduksi
									  - jumlah_rusak - jumlah_expired
									  + jumlah_returpembelian
									  + jumlah_koreksipenerimaan + jumlah_revisipenerimaan + jumlah_lainnya,
					harga_akhir 	= harga_awal,
					nilai_akhir 	= nilai_awal + nilai_pembelian + nilai_hasilproduksi + nilai_koreksi
									  - nilai_penjualan - nilai_floorstok - nilai_bahanproduksi
									  - nilai_rusak - nilai_expired
									  + nilai_returpembelian
									  + nilai_koreksipenerimaan + nilai_revisipenerimaan + nilai_lainnya
			WHERE	bulan 			= vBulan and
					tahun 			= vTahun;
					
		UPDATE		rsfPelaporan.laporan_mutasi_bulan_depo
			SET		jumlah_akhir 	= jumlah_awal + jumlah_pembelian + jumlah_hasilproduksi + jumlah_koreksi +
									  - jumlah_penjualan - jumlah_floorstok - jumlah_bahanproduksi
									  - jumlah_rusak - jumlah_expired
									  + jumlah_returpembelian
									  + jumlah_koreksipenerimaan + jumlah_revisipenerimaan + jumlah_lainnya
									  + jumlah_mutasimasuk - jumlah_mutasikeluar,
					harga_akhir 	= harga_awal,
					nilai_akhir 	= nilai_awal + nilai_pembelian + nilai_hasilproduksi + nilai_koreksi
									  - nilai_penjualan - nilai_floorstok - nilai_bahanproduksi
									  - nilai_rusak - nilai_expired
									  + nilai_returpembelian
									  + nilai_koreksipenerimaan + nilai_revisipenerimaan + nilai_lainnya
									  + nilai_mutasimasuk - nilai_mutasikeluar
			WHERE	bulan 			= vBulan and
					tahun 			= vTahun;
	COMMIT;
END //
DELIMITER ;
