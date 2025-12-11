Identifikasi Data Dasar Transaksi :
1. stokOpName, final dan batal final. diambil yang final. (11 & 15)
   - isu : ada detil trx yang tidak ada kartu stok
2. KOREKSI, barang keluar masuk. dengan status = 2 (mungkin final dan non final). 
   barang masuk (53), barang keluar (54), dengan rincian alasannya.
3. PERMINTAAN & PENGIRIMAN & PENERIMAAN, antar gudang/depo
   penerimaan (20), pengiriman (23), dengan rincian gudang/depo vs ruangan (non depo/gudang)
   - isu : ada detil trx yang tidak ada kartu stok
4. BARANG PRODUKSI,
   bahan (52), hasil produksi (51)
5. PENERIMAAN BARANG REKANAN, dengan status = 2 (final dan non final). 
   terima (21), batal final (24)
6. PENJUALAN, dengan status = 2 (final)
   penjualan (30)
7. RETUR PENJUALAN, dengan status = 2 (final)
   retur penjualan (31)
8. PELAYANAN, dengan transaksi ambil langsung dari kartu stok
   33	Pelayanan
   34	Retur Pelayanan
   35	Pembatalan Pelayanan
?. RESIDU, RETUR KE REKANAN
?. Alasan Koreksi
	2	Transaksi Masuk		Pinjaman Rekanan
	3	Transaksi Masuk		Salah Katalog Masuk
	9	Transaksi Masuk		Pendingan Input Fatmahost
	10	Transaksi Masuk		Obat / Alkes Pengganti
	11	Transaksi Masuk		Katalog tidak tersedia di depo (Masuk)
	12	Transaksi Masuk		Masalah Transisi Sistem (Masuk)
	13	Transaksi Masuk		Implan
	0	Transaksi Keluar	-- non sub --
	3	Transaksi Keluar	Salah Katalog Keluar
	5	Transaksi Keluar	Obat / Alkes Expired
	6	Transaksi Keluar	Pengeluaran Gas Medis
	7	Transaksi Keluar	Pengeluaran Vaksin
	9	Transaksi Keluar	Inputan RCN
	11	Transaksi Keluar	Pengembalian Ke Rekanan
	15	Transaksi Keluar	Katalog Tidak Tersedia Di Depo (Keluar)
	17	Transaksi Keluar	Masalah Transisi Sistem (Keluar)
	18	Transaksi Keluar	Pengeluaran FloorStok

LAPORAN :
1. SO 31/3, sebagai SA 1/4
2. SO 30/6, sebagai SA 1/7
3. SO 30/9, sebagai SA 1/10
4. Trx Bulanan 4,5,6,7,8,9
5. SA 1/4 === TRX 4,5,6,7,8,9 === SO 30/9 ==> NILAI ADJUSTMENT

LANGKAH KERJA :
1. Fix-ing data stokOpname
   monitor : pembandingan laporan stokOpName.
2. Fix-ing data dasar transaksi
   monitor : pembandingan laporan transaksi harian.
3. Laporan Bulanan / Triwulan
   a. Nilai Adjustment
   b. Penentuan Harga Barang
4. Dashboard Monitoring
   a. Diturunkan menjadi proses harian
   b. Transaksi harian
   c. Deteksi Dini Kasus Inkonsistensi
   d. Stok harian
5. Persiapan Perbaikan Aplikasi / Database
