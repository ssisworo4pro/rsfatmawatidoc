SELECT * FROM master.ruangan where substr(id,1,6) = '101030';
select * from (
SELECT		max(subsubquery.katalog_id) as katalog_id,
			max(barang.KODE_BARANG) as katalog_kode,
			max(subsubquery.katalog_nama) as katalog_nama,
			max(r.DESKRIPSI) as katalog_merk,
			sum(subsubquery.qty_opname) as qty_opname,
			sum(subsubquery.qty_masuk) as 17i,
			sum(subsubquery.qty_keluar) as 17o,
			sum(subsubquery.qty_trx) as 17t,
			sum(subsubquery.qty_opname) + sum(subsubquery.qty_masuk)
			- sum(subsubquery.qty_keluar) - sum(qty_trx) as 17s
	from	(
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							qty_opname,
							qty_trx,
							nilai_trx,
							qty_masuk,
							qty_keluar
					from	(
								SELECT		max(br.KODE_BARANG) as katalog_kode,
											max(br.ID) as katalog_id,
											max(br.NAMA) as katalog_nama,
											0 as qty_opname,
											sum(dr.JUMLAH) as qty_trx,
											sum(hb.HARGA_JUAL) as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar
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
																where RUANGAN = '101030106') and
											r.TANGGAL 		 <  '2023-01-01' AND
											r.STATUS         = 2 AND
											r.TUJUAN 		 = '101030106'
									group	by br.ID
									order by br.ID
							) subquery
				UNION ALL
				select		b.KODE_BARANG as katalog_kode,
							b.ID as katalog_id, b.NAMA as katalog_nama, 
							sod.MANUAL as qty_opname, 
							0 as qty_trx, 0 as nilai_trx,
							0 as qty_masuk,
							0 as qty_keluar
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
					where	so.id		= sod.STOK_OPNAME and
							so.TANGGAL 	> '2022-12-16' and
							sod.MANUAL  != 0 and
							so.RUANGAN 	= '101030106'
				UNION ALL
			select	*
				from	(
							select 		max(b.KODE_BARANG) as katalog_kode,
										max(br.BARANG) as katalog_id,
										max(b.NAMA) as katalog_nama,
										0 as qty_opname,
										0 as qty_trx,
										0 as nilai_trx,
										COALESCE(sum(pd.JUMLAH), 0) as qty_masuk,
										0 as qty_keluar
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
										p.TANGGAL 		     > (select max(TANGGAL_DIBUAT) 
																from inventory.stok_opname
																where RUANGAN = '101030106') and
										p.TANGGAL 		     <  '2023-01-01' AND
										pg.TUJUAN 			 = '101030106'
								GROUP	BY 	br.BARANG
							) subquery
			UNION ALL
			select	*
				from	(
							select 		max(b.KODE_BARANG) as katalog_kode,
										max(br.BARANG) as katalog_id,
										max(b.NAMA) as katalog_nama,				
										0 as qty_opname,
										0 as qty_trx,
										0 as nilai_trx,
										0 as qty_masuk,
										COALESCE(sum(pd.JUMLAH), 0) as qty_keluar
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
										p.TANGGAL 		     > (select max(TANGGAL_DIBUAT) 
																from inventory.stok_opname
																where RUANGAN = '101030106') and
										p.TANGGAL 		     <  '2023-01-01' AND
										pg.ASAL 			 = '101030106'
								GROUP	BY 	br.BARANG
							) subquery
			) subsubquery inner join
			inventory.barang barang
 			on	barang.id = subsubquery.katalog_id
			inner join master.referensi r
            on barang.MERK = r.ID 			
	where   r.JENIS = 39
	GROUP   by subsubquery.katalog_id
	ORDER 	by subsubquery.katalog_nama
) obats
where 17s < 0;


===============

-- kasus tanggal lebih dari tanggal sekarang
select * from layanan.order_resep r order by TANGGAL desc limit 10;
-- kasus tanggal lebih dari tanggal sekarang
select * from layanan.order_resep r order by TANGGAL desc limit 10;
select * from pendaftaran.kunjungan k where k.NOMOR = '1010101012212290004';
select * from pendaftaran.kunjungan k where k.NOMOR = '1010101012212220009';
select * from pendaftaran.kunjungan k where k.NOMOR = '1010101962212220004';
select * from pendaftaran.pendaftaran p where p.NOMOR = '2212290015';
select * from pendaftaran.pendaftaran p where p.NOMOR = '2212220275';
select * from pendaftaran.pendaftaran p where p.NOMOR = '2212220227';
select * 
select * from master.ruangan r where r.ID = '101030109';

-- tanggal terakhir stok opname berdasarkan kode depo
select 		max(TANGGAL_DIBUAT) 
	from 	inventory.stok_opname so 
	where 	RUANGAN = '101030107';

SELECT		max(br.KODE_BARANG) as katalog_kode,
			max(dr.FARMASI) as katalog_id,
			max(br.NAMA) as katalog_nama,
			0 as qty_opname,
			sum(dr.JUMLAH) as qty_trx,
			sum(hb.HARGA_JUAL) as nilai_trx,
			0 as qty_masuk,
			0 as qty_keluar
	FROM	layanan.order_resep r 
			LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
			LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
			LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
			layanan.order_detil_resep dr
			LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
			LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
	WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
			r.TANGGAL 		 > (	select max(TANGGAL_DIBUAT) from inventory.stok_opname so where RUANGAN = '101030107') and
			r.TANGGAL 		 <  '2022-12-18' AND
			r.TUJUAN 		 = '101030107'
	group	by br.ID
	order by br.KODE_BARANG, br.ID;

									
									select		b.KODE_BARANG as katalog_kode,
							b.ID as katalog_id, b.NAMA as katalog_nama, 
							sod.MANUAL as qty_opname, 
							0 as qty_trx, 0 as nilai_trx,
							0 as qty_masuk,
							0 as qty_keluar
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
					where	so.id		 = sod.STOK_OPNAME and
							so.TANGGAL 	>= '2022-12-17' and
							sod.MANUAL  != 0 and
							so.RUANGAN 	 = '101030107'
					order	by b.KODE_BARANG;


select 		so.ID as ID_StokOpname, r.ID as ID_Depo, r.DESKRIPSI as Nama_Depo, 
			so.TANGGAL_DIBUAT as TanggalDibuat_StokOpname, so.STATUS as Status, so.OLEH as user
	from 	inventory.stok_opname so,
			master.ruangan r
	where   so.RUANGAN = r.ID and
			SUBSTR(so.RUANGAN,1,6) = '101030'
	order 	by so.id desc;

-- tanggal terakhir stok opname berdasarkan kode depo
select 		max(TANGGAL_DIBUAT) 
	from 	inventory.stok_opname so 
	where 	RUANGAN = '101030107';

SELECT		max(br.KODE_BARANG) as katalog_kode,
			max(dr.FARMASI) as katalog_id,
			max(br.NAMA) as katalog_nama,
			0 as qty_opname,
			sum(dr.JUMLAH) as qty_trx,
			sum(hb.HARGA_JUAL) as nilai_trx,
			0 as qty_masuk,
			0 as qty_keluar
	FROM	layanan.order_resep r 
			LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
			LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
			LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
			layanan.order_detil_resep dr
			LEFT JOIN inventory.barang br ON dr.FARMASI = br.ID
			LEFT JOIN inventory.harga_barang hb ON hb.BARANG = br.ID  
	WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
			r.TANGGAL 		 > (	select max(TANGGAL_DIBUAT) from inventory.stok_opname so where RUANGAN = '101030107') and
			r.TANGGAL 		 <  '2022-12-18' AND
			r.TUJUAN 		 = '101030107'
	group	by br.ID
	order by br.KODE_BARANG, br.ID;

									
									select		b.KODE_BARANG as katalog_kode,
							b.ID as katalog_id, b.NAMA as katalog_nama, 
							sod.MANUAL as qty_opname, 
							0 as qty_trx, 0 as nilai_trx,
							0 as qty_masuk,
							0 as qty_keluar
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
					where	so.id		 = sod.STOK_OPNAME and
							so.TANGGAL 	>= '2022-12-17' and
							sod.MANUAL  != 0 and
							so.RUANGAN 	 = '101030107'
					order	by b.KODE_BARANG;


select 		so.ID as ID_StokOpname, r.ID as ID_Depo, r.DESKRIPSI as Nama_Depo, 
			so.TANGGAL_DIBUAT as TanggalDibuat_StokOpname, so.STATUS as Status, so.OLEH as user
	from 	inventory.stok_opname so,
			master.ruangan r
	where   so.RUANGAN = r.ID and
			SUBSTR(so.RUANGAN,1,6) = '101030'
	order 	by so.id desc;
