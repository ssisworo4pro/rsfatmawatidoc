SELECT REF_ID, JENIS, JUMLAH, (JUMLAH * (TARIF - IF(PERSENTASE_DISKON = 0, DISKON, (TARIF * (DISKON/100)))))
  FROM pembayaran.rincian_tagihan rt
 WHERE rt.TAGIHAN = '2307070037'
   AND rt.`STATUS` > 0;

SELECT t.JENIS
  FROM layanan.tindakan_medis tm
  		 , master.tindakan t
 WHERE tm.ID = '23070709076'
   AND tm.`STATUS` IN (1, 2)
   AND t.ID = tm.TINDAKAN
 LIMIT 1;

					SELECT LEFT(b.KATEGORI, 3) 
					  FROM layanan.farmasi f
					  		 , inventory.barang b
					 WHERE f.ID = '23070709076'
					   AND b.ID = f.FARMASI
					 LIMIT 1;

select * from inventory.kategori k where jenis = 2
select * from inventory.kategori k where jenis = 3
select * from inventory.jenis_kategori jk 
select * from inventory.barang b where b.KATEGORI = '10115'
select * from inventory.barang
