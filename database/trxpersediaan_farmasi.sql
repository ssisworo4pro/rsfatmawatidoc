=================================== referensi detil trx 
-- transaksi resep detil
SELECT		(br.ID) as katalog_id,
			CONCAT('R',r.NOMOR) as nomor_resep,
			CONCAT('K',r.KUNJUNGAN) as nomor_kunjungan,
			CONCAT('P',p.NOMOR) as nomor_pendaftaran,
			mp.NORM as norm,
			dr.FARMASI as katalog_id_trx,
			(br.NAMA) as katalog_nama,
			0 as qty_opname,
			(dr.JUMLAH) as qty_trx,
			(hb.HARGA_JUAL) as nilai_trx
	FROM	layanan.order_resep r 
			LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
			LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
			LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
			layanan.order_detil_resep dr
			LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
			LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
	WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
			r.TANGGAL 		 > (select max(TANGGAL_DIBUAT) 
								from inventory.stok_opname
								where RUANGAN = '101030101') and
			r.TANGGAL 		 <  '2022-12-18' AND
			r.TUJUAN 		 = '101030101' AND
			r.NOMOR          = '141010205032212170004'
	order by br.NAMA

-- transaksi resep rekap berkas
SELECT		CONCAT('R',max(r.NOMOR)) as nomor_resep,
			max(r.TANGGAL ) as jam_transaksi,
			-- max(CAST(r.TANGGAL as TIME)) as jam_transaksi,
			CONCAT('K',max(r.KUNJUNGAN)) as nomor_kunjungan,
			CONCAT('P',max(p.NOMOR)) as nomor_pendaftaran,
			CONCAT('P',max(mp.NORM)) as pasien_norm,
			CONCAT('P',max(mp.NAMA)) as pasien_nama,
			sum(dr.JUMLAH) as qty_trx
	FROM	layanan.order_resep r 
			LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
			LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
			LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
			layanan.order_detil_resep dr
			LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
			LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
	WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
			r.TANGGAL 		 > (select max(TANGGAL_DIBUAT) 
								from inventory.stok_opname
								where RUANGAN = '101030107') and
			r.TANGGAL 		 <  '2022-12-18' AND
			r.TUJUAN 		 = '101030107'
	group 	by r.NOMOR
	order 	by r.NOMOR

-- mutasi masuk
select 		max(rasal.deskripsi) as depo_asal,
			max(r.deskripsi) as depo_tujuan,
			max(br.BARANG) as katalog_id,
			max(b.NAMA) as katalog_nama,
			COALESCE(sum(pd.JUMLAH), 0) as qty_masuk
	from 	inventory.penerimaan p, 
			inventory.pengiriman pg,
			inventory.pengiriman_detil pd,
			inventory.kategori k,
			inventory.barang b,
			inventory.barang_ruangan br,
			master.ruangan r,
			master.ruangan rasal,
			inventory.jenis_transaksi_stok jts
	where	p.REF 				 = pd.PENGIRIMAN and
			pg.NOMOR			 = pd.PENGIRIMAN and
			br.BARANG 	 		 = b.ID and
			b.KATEGORI 			 = k.ID and
			br.RUANGAN  		 = pg.TUJUAN and
			br.BARANG   		 = pd.BARANG and
			r.id 				 = br.ruangan AND
			pg.ASAL 		     = rasal.ID AND
			jts.ID				 = 20 AND
			p.JENIS     	 	 = 2 and 
			p.TANGGAL 			>= '2022-12-5' AND 
			p.TANGGAL 		 	 <  '2022-12-6' AND
			pg.TUJUAN 			 = '101030107'
	GROUP	BY 	br.RUANGAN,
				br.BARANG
	ORDER 	BY 	br.RUANGAN,
				br.BARANG;
-- mutasi keluar
select 		max(r.deskripsi) as depo_nama,
			max(rtujuan.deskripsi) as depo_tujuan,
			max(br.BARANG) as katalog_id,
			COALESCE(max(b.kode_barang),'-') as katalog_kode,
			max(b.NAMA) as katalog_nama,				
			COALESCE(sum(pd.JUMLAH), 0) as jml_trxpersediaan
	from 	inventory.penerimaan p, 
			inventory.pengiriman pg,
			inventory.pengiriman_detil pd,
			inventory.kategori k,
			inventory.barang b,
			inventory.barang_ruangan br,
			master.ruangan r,
			master.ruangan rtujuan,
			inventory.jenis_transaksi_stok jts
	where	p.REF 				 = pd.PENGIRIMAN and
			pg.NOMOR			 = pd.PENGIRIMAN and
			br.BARANG 	 		 = b.ID and
			b.KATEGORI 			 = k.ID and
			br.RUANGAN  		 = pg.ASAL and
			pg.TUJUAN 		     = rtujuan.ID AND
			br.BARANG   		 = pd.BARANG and
			r.id 				 = br.ruangan AND
			jts.ID				 = 23 AND
			p.JENIS     	 	 = 2 and 
			p.TANGGAL 			>= '2022-12-5' AND 
			p.TANGGAL 		 	 <  '2022-12-6' AND
			pg.ASAL 			 = '101030107'
	GROUP	BY 	br.RUANGAN,
				br.BARANG
	ORDER 	BY 	br.RUANGAN,
				br.BARANG;

=======================================================================





SELECT	p.NORM,
		mp.NAMA,
		k.NOMOR Nomor_kunjungan,
		r.NOMOR nomor_resep,
		r.TANGGAL tanggal_resep,
		k.MASUK tanggal_terima,
		k.KELUAR tanggal_final,
		br.NAMA nama_obat,
		dr.JUMLAH qty,
		hb.HARGA_JUAL nilai
FROM	layanan.order_resep r 
		LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
		layanan.order_detil_resep dr
		LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
		LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
		r.TANGGAL 		>= '2022-12-5' AND 
		r.TANGGAL 		 <  '2022-12-6' AND
		r.TUJUAN 		 = '101030107';


select		*
	from	inventory.stok_opname so 
	where	so.TANGGAL > '2022-12-1';

select		*
	from	(
				SELECT		katalog_id,
							katalog_nama,
							qty_opname,
							qty_trx,
							nilai_trx
					from	(
								SELECT		max(br.ID) as katalog_id,
											max(br.NAMA) as katalog_nama,
											0 as qty_opname,
											sum(dr.JUMLAH) as qty_trx,
											sum(hb.HARGA_JUAL) as nilai_trx
									FROM	layanan.order_resep r 
											LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
											LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
											LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
											layanan.order_detil_resep dr
											LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
											LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
									WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
											r.TANGGAL 		>= '2022-12-5' AND 
											r.TANGGAL 		 <  '2022-12-6' AND
											r.TUJUAN 		 = '101030107'
									group	by br.ID
							) subquery
				UNION ALL
				select		b.ID as katalog_id, b.NAMA as katalog_nama, sod.MANUAL as qty_opname, 0 as qty_trx, 0 as nilai_trx
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
					where	so.id		= sod.STOK_OPNAME and
							so.TANGGAL 	> '2022-12-1' and
							sod.MANUAL  != 0 and
							so.RUANGAN 	= '101030107'
			) subsubquery
	ORDER 	by qty_opname desc, katalog_nama;


				select		count(1)
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
					where	so.id		= sod.STOK_OPNAME and
							so.TANGGAL 	> '2022-12-1' and
							so.RUANGAN 	= '101030107'

							
select r.id, r.DESKRIPSI  from master.ruangan r, master.ruangan_farmasi rf where r.ID = rf.FARMASI ;





-- BOGENVILLE
-- detil sd berkas trx
SELECT	count(1)
FROM	layanan.order_resep r 
		LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN master.pasien mp ON mp.NORM = p.NORM
WHERE	r.TANGGAL 		>= '2022-12-5' AND 
		r.TANGGAL 		 <  '2022-12-6' AND
		r.TUJUAN 		 = '101030107';

	-- detil sd obat
SELECT	count(1)
FROM	layanan.order_resep r 
		LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
		layanan.order_detil_resep dr
		LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
		LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
		r.TANGGAL 		>= '2022-12-5' AND 
		r.TANGGAL 		 <  '2022-12-6' AND
		r.TUJUAN 		 = '101030107';

-- detil sd berkas trx
SELECT	count(1)
FROM	layanan.order_resep r 
		LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN master.pasien mp ON mp.NORM = p.NORM
WHERE	r.TANGGAL 		>= '2022-12-5' AND 
		r.TANGGAL 		 <  '2022-12-6' AND
		r.TUJUAN 		 = '101030101';

	-- detil sd obat
SELECT	count(1)
FROM	layanan.order_resep r 
		LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
		layanan.order_detil_resep dr
		LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
		LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
		r.TANGGAL 		>= '2022-12-5' AND 
		r.TANGGAL 		 <  '2022-12-6' AND
		r.TUJUAN 		 = '101030101';

	
	


SELECT	p.NORM,
		mp.NAMA,
		k.NOMOR Nomor_kunjungan,
		r.NOMOR nomor_resep,
		r.TANGGAL tanggal_resep,
		k.MASUK tanggal_terima,
		k.KELUAR tanggal_final,
		br.NAMA nama_obat,
		dr.JUMLAH qty,
		hb.HARGA_JUAL nilai
FROM	layanan.order_resep r 
		LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
		LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
		layanan.order_detil_resep dr
		LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
		LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
		r.TANGGAL 		>= '2022-12-5' AND 
		r.TANGGAL 		 <  '2022-12-6';




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