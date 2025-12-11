SELECT		max(subsubquery.katalog_id) as katalog_id,
			max(barang.KODE_BARANG) as katalog_kode,
			max(subsubquery.katalog_nama) as katalog_nama,
			max(subsubquery.katalog_satuan) as katalog_satuan,
			max(mreff.DESKRIPSI) as katalog_merk,
			sum(subsubquery.qty_opname) as qty_opname,
			sum(subsubquery.qty_beli) as qty_beli,
			sum(subsubquery.qty_masuk) as qty_mmasuk,
			sum(subsubquery.qty_keluar) as qty_mkeluar,
			sum(subsubquery.qty_prod) as qty_prod,
			sum(subsubquery.qty_trx) as qty_resep,
			sum(subsubquery.qty_trx_retur) as qty_resep_retur,
			sum(subsubquery.qty_jual) as qty_jual,
			sum(subsubquery.qty_jual_retur) as qty_jual_retur,
			sum(subsubquery.qty_opname) + sum(subsubquery.qty_masuk)
			+ sum(subsubquery.qty_beli)
			+ sum(subsubquery.qty_prod)
			- sum(subsubquery.qty_keluar) 
			- sum(qty_trx) 
			+ sum(subsubquery.qty_trx_retur)
			- sum(subsubquery.qty_jual) 
			+ sum(subsubquery.qty_jual_retur) as qty_akhir
	from	(
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							0 as qty_jual,
							0 as qty_jual_retur
					from	(
								select 		max(b.KODE_BARANG) as katalog_kode,
											max(br.BARANG) as katalog_id,
											max(b.NAMA) as katalog_nama,				
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											0 as qty_prod,
											sum(terimaRknDtl.JUMLAH) as qty_beli
									from	inventory.penerimaan_barang terimaRkn,
											inventory.penerimaan_barang_detil terimaRknDtl,
											inventory.barang b
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN,
											inventory.kategori k,
											inventory.barang_ruangan br,
											master.ruangan r
									where	terimaRkn.id 				= terimaRknDtl.PENERIMAAN and
											terimaRkn.RUANGAN 			= br.RUANGAN and
											terimaRknDtl.BARANG 		= br.BARANG and
											br.BARANG 					= b.id and
											b.KATEGORI 					= k.id and
											terimaRkn.RUANGAN 			= r.id and
											terimaRkn.TANGGAL 		    > (select max(TANGGAL_DIBUAT) 
																			from inventory.stok_opname
																			where RUANGAN = '101030115'
																			and STATUS = 3) and
											terimaRkn.TANGGAL 		    <  '2023-01-01' AND
											terimaRkn.RUANGAN           = '101030115'
									group	by terimaRknDtl.BARANG
							) subqueryBeli
				UNION ALL
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							qty_jual,
							qty_jual_retur
					from	(
								/*select 		mstRuang.DESKRIPSI as depo_nama, 
											trxJual.NOMOR as resep_nomor,
											trxJual.PENGUNJUNG as resep_nama,
											mstBarang.NAMA as katalog_nama,
											mstBarang.KODE_BARANG as katalog_kode,
											mstBarang.ID as katalog_id,
											trxJualDtl.JUMLAH as qty,
											trxJualDtl.HARGA_BARANG as harga*/
								SELECT		max(mstBarang.KODE_BARANG) as katalog_kode,
											max(mstBarang.ID) as katalog_id,
											max(mstBarang.NAMA) as katalog_nama,
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_beli,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											0 as qty_prod,
											sum(trxJualDtl.JUMLAH) as qty_jual,
											0 as qty_jual_retur
									from 	penjualan.penjualan trxJual, 
											penjualan.penjualan_detil trxJualDtl,
											master.ruangan mstRuang,
											inventory.barang mstBarang
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = mstBarang.SATUAN
									where 	trxJual.RUANGAN = mstRuang.ID and
											trxJualDtl.PENJUALAN_ID = trxJual.NOMOR and
											trxJualDtl.BARANG = mstBarang.ID and
											trxJualDtl.JUMLAH > 0 and
											trxJual.TANGGAL 		    > (select max(TANGGAL_DIBUAT) 
																			from inventory.stok_opname
																			where RUANGAN = '101030115'
																			and STATUS = 3) and
											trxJual.TANGGAL 		    <  '2023-01-01' AND
											trxJual.RUANGAN           	= '101030115'
									group	by trxJualDtl.BARANG
							) subqueryJual
				UNION ALL
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							qty_jual,
							qty_jual_retur
					from	(
								/*select 		mstRuang.DESKRIPSI as depo_nama, 
											trxJual.NOMOR as resep_nomor,
											trxJual.PENGUNJUNG as resep_nama,
											mstBarang.NAMA as katalog_nama,
											mstBarang.KODE_BARANG as katalog_kode,
											mstBarang.ID as katalog_id,
											trxJualDtl.JUMLAH as qty,
											trxJualDtlRetur.JUMLAH as qty_retur,
											trxJualDtl.HARGA_BARANG as harga*/
								SELECT		max(mstBarang.KODE_BARANG) as katalog_kode,
											max(mstBarang.ID) as katalog_id,
											max(mstBarang.NAMA) as katalog_nama,
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_beli,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											0 as qty_prod,
											0 as qty_jual,
											sum(trxJualDtlRetur.JUMLAH) as qty_jual_retur
									from 	penjualan.penjualan trxJual, 
											penjualan.penjualan_detil trxJualDtl,
											penjualan.retur_penjualan trxJualDtlRetur,
											master.ruangan mstRuang,
											inventory.barang mstBarang
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = mstBarang.SATUAN
									where 	trxJual.RUANGAN = mstRuang.ID and
											trxJualDtl.PENJUALAN_ID = trxJual.NOMOR and
											trxJualDtlRetur.PENJUALAN_DETIL_ID = trxJualDtl.ID and
											trxJualDtlRetur.BARANG = mstBarang.ID and
											trxJualDtlRetur.JUMLAH > 0 and
											trxJual.TANGGAL 		    > (select max(TANGGAL_DIBUAT) 
																			from inventory.stok_opname
																			where RUANGAN = '101030115'
																			and STATUS = 3) and
											trxJual.TANGGAL 		    <  '2023-01-01' AND
											trxJual.RUANGAN           	= '101030115'
									group	by trxJualDtl.BARANG
							) subqueryJualRetur
				UNION ALL
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							0 as qty_jual,
							0 as qty_jual_retur
					from	(
								SELECT		max(b.KODE_BARANG) as katalog_kode,
											max(farmasi.FARMASI) as katalog_id,
											max(b.NAMA) as katalog_nama,
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_beli,
											sum(farmasi.JUMLAH) as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											0 as qty_prod
									FROM	layanan.order_resep r 
											LEFT JOIN pendaftaran.kunjungan k ON r.NOMOR = k.REF
											LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
											LEFT JOIN master.pasien mp ON mp.NORM = p.NORM, 
											layanan.order_detil_resep dr
											LEFT JOIN layanan.farmasi farmasi on farmasi.ID = dr.REF
											LEFT JOIN inventory.barang b ON farmasi.FARMASI = b.ID
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN
									WHERE	r.NOMOR 		 = dr.ORDER_ID AND 
											r.TANGGAL 		 > (select max(TANGGAL_DIBUAT) 
																from inventory.stok_opname
																where RUANGAN = '101030115'
																and STATUS = 3) and
											r.TANGGAL 		 <  '2023-01-01' AND
											r.STATUS         = 2 AND
											r.TUJUAN 		 = '101030115'
									group	by farmasi.FARMASI
									order by farmasi.FARMASI
							) subquery
				UNION ALL
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							0 as qty_jual,
							0 as qty_jual_retur
					from	(
								select 		max(br.RUANGAN) as depo_kode,
											max(br.BARANG) as katalog_id,
											max(r.deskripsi) as depo_nama,
											max(b.KATEGORI) as kateg_kode,
											max(k.NAMA) as kateg_nama,
											COALESCE(max(b.kode_barang),'-') as katalog_kode,
											max(msatuan.NAMA) as katalog_satuan,
											max(b.NAMA) as katalog_nama,				
											0 as qty_opname,
											0 as qty_beli,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											COALESCE(sum(bpd.QTY), 0) * -1 as qty_prod
									from 	inventory.barang_produksi bp, 
											inventory.barang_produksi_detil bpd,
											inventory.kategori k,
											inventory.barang b
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN,
											inventory.barang_ruangan br,
											master.ruangan r
									where	bp.ID                = bpd.PRODUKSI and
											br.BARANG 	 		 = b.ID and
											b.KATEGORI 			 = k.ID and
											br.RUANGAN  		 = bp.RUANGAN and
											bp.RUANGAN			 = '101030115' AND
											br.BARANG   		 = bpd.BAHAN and
											r.id 				 = br.ruangan AND
											bp.STATUS     	 	 = 2 and 
											bp.TANGGAL       	 > (select max(TANGGAL_DIBUAT) 
																from inventory.stok_opname
																where RUANGAN = '101030115'
																and STATUS = 3) and
											bp.TANGGAL 		     <  '2023-01-01'
								group       by b.id
							) subquery
				UNION ALL
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							0 as qty_jual,
							0 as qty_jual_retur
					from	(
								select 		max(br.RUANGAN) as depo_kode,
											max(br.BARANG) as katalog_id,
											max(r.deskripsi) as depo_nama,
											max(b.KATEGORI) as kateg_kode,
											max(k.NAMA) as kateg_nama,
											COALESCE(max(b.kode_barang),'-') as katalog_kode,
											max(msatuan.NAMA) as katalog_satuan,
											max(b.NAMA) as katalog_nama,				
											0 as qty_opname,
											0 as qty_beli,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											COALESCE(sum(bp.QTY), 0) as qty_prod
									from 	inventory.barang_produksi bp, 
											inventory.kategori k,
											inventory.barang b
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN,
											inventory.barang_ruangan br,
											master.ruangan r
									where	br.BARANG 	 		 = b.ID and
											b.KATEGORI 			 = k.ID and
											br.RUANGAN  		 = bp.RUANGAN and
											br.BARANG   		 = bp.BARANG and
											r.id 				 = br.ruangan AND
											bp.RUANGAN			 = '101030115' AND
											bp.STATUS     	 	 = 2 and 
											bp.TANGGAL       	 > (select max(TANGGAL_DIBUAT) 
																from inventory.stok_opname
																where RUANGAN = '101030115'
																and STATUS = 3) and
											bp.TANGGAL 		     <  '2023-01-01'
								group       by b.id
							) subquery
				UNION ALL
				SELECT		katalog_kode,
							katalog_id,
							katalog_nama,
							katalog_satuan,
							qty_opname,
							qty_beli,
							qty_trx,
							qty_trx_retur,
							nilai_trx,
							qty_masuk,
							qty_keluar,
							qty_prod,
							0 as qty_jual,
							0 as qty_jual_retur
					from	(
								SELECT		max(b.KODE_BARANG) as katalog_kode,
											max(farmasi.FARMASI) as katalog_id,
											max(b.NAMA) as katalog_nama,
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_beli,
											sum(retur.JUMLAH) as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											0 as qty_keluar,
											0 as qty_prod
									FROM	layanan.retur_farmasi retur,
											pendaftaran.kunjungan k 
											LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
											LEFT JOIN master.ruangan mruangan ON mruangan.ID = k.RUANGAN 
											LEFT JOIN master.pasien mp ON mp.NORM = p.NORM,
											layanan.farmasi farmasi
											LEFT JOIN inventory.barang b ON farmasi.FARMASI = b.ID
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN
									WHERE	retur.ID_FARMASI = farmasi.ID AND
											farmasi.KUNJUNGAN = k.NOMOR AND
											retur.TANGGAL 	 > (select max(TANGGAL_DIBUAT) 
																from inventory.stok_opname
																where RUANGAN = '101030115'
																and STATUS = 3) and
											retur.TANGGAL 		 <  '2023-01-01' and
											k.RUANGAN = '101030115'
									group	by farmasi.FARMASI
							) subquery
				UNION ALL
				select		b.KODE_BARANG as katalog_kode,
							b.ID as katalog_id, 
							b.NAMA as katalog_nama, 
							(msatuan.NAMA) as katalog_satuan,
							sod.MANUAL as qty_opname, 
							0 as qty_beli,
							0 as qty_trx, 
							0 as qty_trx_retur,
							0 as nilai_trx,
							0 as qty_masuk,
							0 as qty_keluar,
							0 as qty_prod,
							0 as qty_jual,
							0 as qty_jual_retur
					from	inventory.stok_opname so,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
							LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN
					where	so.id		= sod.STOK_OPNAME and
							so.TANGGAL 	> '2022-12-16' and
							so.STATUS 	= 3 and
							sod.MANUAL  != 0 and
							so.RUANGAN 	= '101030115'
				UNION ALL
				select	*
					from	(
								select 		max(b.KODE_BARANG) as katalog_kode,
											max(br.BARANG) as katalog_id,
											max(b.NAMA) as katalog_nama,
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_beli,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											COALESCE(sum(pd.JUMLAH), 0) as qty_masuk,
											0 as qty_keluar,
											0 as qty_prod,
											0 as qty_jual,
											0 as qty_jual_retur
									from 	inventory.penerimaan p, 
											inventory.pengiriman pg,
											inventory.pengiriman_detil pd,
											inventory.kategori k,
											inventory.barang b
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN,
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
																	where RUANGAN = '101030115'
																	and STATUS = 3) and
											p.TANGGAL 		     <  '2023-01-01' AND
											pg.TUJUAN 			 = '101030115'
									GROUP	BY 	pd.BARANG
								) subquery
				UNION ALL
				select	*
					from	(
								select 		max(b.KODE_BARANG) as katalog_kode,
											max(br.BARANG) as katalog_id,
											max(b.NAMA) as katalog_nama,				
											max(msatuan.NAMA) as katalog_satuan,
											0 as qty_opname,
											0 as qty_beli,
											0 as qty_trx,
											0 as qty_trx_retur,
											0 as nilai_trx,
											0 as qty_masuk,
											COALESCE(sum(pd.JUMLAH), 0) as qty_keluar,
											0 as qty_prod,
											0 as qty_jual,
											0 as qty_jual_retur
									from 	inventory.penerimaan p, 
											inventory.pengiriman pg,
											inventory.pengiriman_detil pd,
											inventory.kategori k,
											inventory.barang b
											LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN,
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
																	where RUANGAN = '101030115'
																	      and STATUS = 3) and
											p.TANGGAL 		     <  '2023-01-01' AND
											pg.ASAL 			 = '101030115'
									GROUP	BY 	br.BARANG
								) subquery
			) subsubquery
			left outer join inventory.barang barang on barang.id = subsubquery.katalog_id
 			left outer join (select * from master.referensi where JENIS = 39) mreff on barang.MERK = mreff.ID
	WHERE   (subsubquery.qty_opname <> 0) or
			(subsubquery.qty_beli <> 0) or
			(subsubquery.qty_masuk <> 0) or
			(subsubquery.qty_keluar <> 0) or
			(subsubquery.qty_prod <> 0) or
			(subsubquery.qty_trx <> 0) or
			(subsubquery.qty_trx_retur <> 0) or
			(subsubquery.qty_jual <> 0) or
			(subsubquery.qty_jual_retur <> 0)
	GROUP   by subsubquery.katalog_id
	ORDER 	by subsubquery.katalog_kode
