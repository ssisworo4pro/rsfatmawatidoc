SELECT
p.NORM,
mp.NAMA,
k.NOMOR Nomor_kunjungan,
r.NOMOR nomor_resep,
r.TANGGAL tanggal_resep,
k.MASUK tanggal_terima,
k.KELUAR tanggal_final,
br.NAMA nama_obat,
dr.JUMLAH qty,
hb.HARGA_JUAL nilai
FROM
layanan.order_resep r 
LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
layanan.order_detil_resep dr
LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
WHERE
r.NOMOR = dr.ORDER_ID AND r.TANGGAL BETWEEN '2022-10-25 00:00:00' AND '2022-10-25 23:59:59'

SELECT
p.NORM,
mp.NAMA,
k.NOMOR Nomor_kunjungan,
r.NOMOR nomor_resep,
r.TANGGAL tanggal_resep,
k.MASUK tanggal_terima,
k.KELUAR tanggal_final,
-- br.NAMA nama_obat,
SUM(dr.JUMLAH) QTY,
SUM(hb.HARGA_JUAL) nilai
FROM
layanan.order_resep r 
LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
layanan.order_detil_resep dr
LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
WHERE
r.NOMOR = dr.ORDER_ID AND r.TANGGAL BETWEEN '2022-10-25 00:00:00' AND '2022-10-25 23:59:59'
group by
p.NORM,
mp.NAMA,
k.NOMOR,
r.NOMOR,
r.TANGGAL,
k.MASUK,
k.KELUAR;
