	SELECT		max(tableTransaksi.depo_nama) as depo_nama,
				max(tableTransaksi.ruangan_kode) as ruangan_kode,
				max(barang.NAMA) as katalog_nama,
				max(msatuan.NAMA) as katalog_satuan,
				max(laporanSOdepoREKON.katalog_kode_asal) as katalog_kode_asal,
				max(laporanSOdepoREKON.katalog_kode_koreksi) as katalog_kode_koreksi,
				max(laporanSOdepoREKON.katalog_kode) as katalog_kode,
				max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp,
				max(laporanSOdepoREKON.koreksi_keterangan) as koreksi_keterangan,
				sum(tableTransaksi.qty_opname) as qty_opname,
				sum(tableTransaksi.qty_beli) as qty_beli,
				sum(tableTransaksi.qty_mmasuk) as qty_mmasuk,
				sum(tableTransaksi.qty_mkeluar) as qty_mkeluar,
				sum(tableTransaksi.qty_prod) as qty_prod,
				sum(tableTransaksi.qty_resep) as qty_resep,
				sum(tableTransaksi.qty_resep_retur) as qty_resep_retur,
				sum(tableTransaksi.qty_jual) as qty_jual,
				sum(tableTransaksi.qty_jual_retur) as qty_jual_retur,
				sum(tableTransaksi.qty_tambil) as qty_tambil,
				sum(tableTransaksi.qty_akhir) as qty_akhir
		FROM	(
					SELECT		max(laporanSOdepoLIST.depo_nama) as depo_nama,
								max(laporanSOdepoLIST.ruangan_kode) as ruangan_kode,
								max(subsubquery.katalog_id) as katalog_id,
								max(subsubquery.katalog_kode) as katalog_kode,
								max(subsubquery.katalog_nama) as katalog_nama,
								max(subsubquery.katalog_satuan) as katalog_satuan,
								sum(subsubquery.qty_opname) as qty_opname,
								sum(subsubquery.qty_beli) as qty_beli,
								sum(subsubquery.qty_masuk) as qty_mmasuk,
								sum(subsubquery.qty_keluar) as qty_mkeluar,
								sum(subsubquery.qty_prod) as qty_prod,
								sum(subsubquery.qty_trx) as qty_resep,
								sum(subsubquery.qty_trx_retur) as qty_resep_retur,
								sum(subsubquery.qty_jual) as qty_jual,
								sum(subsubquery.qty_jual_retur) as qty_jual_retur,
								sum(subsubquery.qty_tambil) as qty_tambil,
								sum(subsubquery.qty_opname) 
								+ sum(subsubquery.qty_beli)
								+ sum(subsubquery.qty_prod)
								- sum(qty_trx) 
								+ sum(subsubquery.qty_trx_retur)
								- sum(subsubquery.qty_jual) 
								- sum(subsubquery.qty_tambil) 
								+ sum(subsubquery.qty_jual_retur) as qty_akhir
						from	(
									select		convert(
												case depo_nama 	when 'anggrek' then '101030106'
																when 'bougenvile' then '101030107'
																when 'gasmedis' then '101030115'
																when 'griya' then '101030103'
																when 'gudang' then '101030111'
																when 'ibs' then '101030108'
																when 'igd' then '101030104'
																when 'irj1' then '101030101'
																when 'irj3' then '101030112'
																when 'okcito' then '101030105'
																when 'produksi' then '101030110'
																when 'teratai' then '101030109'
												else '000000000000000' end, char(15)) as ruangan_kode,
												depo_nama
										from	rsfPelaporan.laporan_so_depo
										group   by depo_nama
								) laporanSOdepoLIST,
								(
									SELECT		ruangan_kode,
												katalog_kode,
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
												0 as qty_tambil,
												0 as qty_jual_retur
										from	(
													select 		max(terimaRkn.RUANGAN) as ruangan_kode,
																max(b.KODE_BARANG) as katalog_kode,
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
																terimaRkn.TANGGAL 		    > (select 	max(TANGGAL_DIBUAT) 
																								from 	inventory.stok_opname
																								where 	RUANGAN = terimaRkn.RUANGAN
																										and STATUS = 3
																										and TANGGAL < '2023-01-01') and
																terimaRkn.TANGGAL 		    <  '2023-01-01'
														group	by terimaRknDtl.BARANG, terimaRkn.RUANGAN
												) subqueryBeli
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												qty_tambil,
												qty_jual_retur
										from	(
													SELECT		max(trxJual.RUANGAN) as ruangan_kode,
																max(mstBarang.KODE_BARANG) as katalog_kode,
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
																0 as qty_tambil,
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
																								where RUANGAN = trxJual.RUANGAN
																								and STATUS = 3
																								and TANGGAL < '2023-01-01') and
																trxJual.TANGGAL 		    <  '2023-01-01'
														group	by trxJualDtl.BARANG, trxJual.RUANGAN
												) subqueryJual
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												qty_tambil,
												qty_jual_retur
										from	(
													SELECT		max(trxKoreksi.RUANGAN) as ruangan_kode,
																max(mstBarang.KODE_BARANG) as katalog_kode,
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
																sum(trxKoreksiDtl.JUMLAH) as qty_tambil,
																0 as qty_jual_retur
														from 	inventory.transaksi_koreksi trxKoreksi
																left outer join
																(	select		ID, DESKRIPSI
																		from	master.referensi
																		where 	JENIS = 900602 ) masref
																on masref.ID = trxKoreksi.ALASAN,
																inventory.transaksi_koreksi_detil trxKoreksiDtl,
																inventory.barang mstBarang
																LEFT JOIN inventory.satuan msatuan ON msatuan.ID = mstBarang.SATUAN,
																master.ruangan mstRuang
														where	trxKoreksi.id 				 = trxKoreksiDtl.KOREKSI and
																trxKoreksiDtl.BARANG 		 = mstBarang.ID and
																mstRuang.id 				 = trxKoreksi.RUANGAN AND
																trxKoreksi.ALASAN            = 20 AND
																trxKoreksi.JENIS 			 = 2 AND
																trxKoreksi.STATUS   		 = 2 and 
																trxKoreksi.TANGGAL 			 > (select max(TANGGAL_DIBUAT) 
																								from inventory.stok_opname
																								where RUANGAN = trxKoreksi.RUANGAN
																								and STATUS = 3
																								and TANGGAL < '2023-01-01') and
																trxKoreksi.TANGGAL  		 < '2023-01-01'
														group	by trxKoreksiDtl.BARANG, trxKoreksi.RUANGAN
												) subqueryKoreksiTA
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												qty_tambil,
												qty_jual_retur
										from	(
													SELECT		max(trxJual.RUANGAN) as ruangan_kode,
																max(mstBarang.KODE_BARANG) as katalog_kode,
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
																0 as qty_tambil,
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
																								where RUANGAN = trxJual.RUANGAN
																								and STATUS = 3
																								and TANGGAL < '2023-01-01') and
																trxJual.TANGGAL 		    <  '2023-01-01'
														group	by trxJualDtl.BARANG, trxJual.RUANGAN
												) subqueryJualRetur
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												0 as qty_tambil,
												0 as qty_jual_retur
										from	(
													SELECT		max(r.TUJUAN) as ruangan_kode,
																max(b.KODE_BARANG) as katalog_kode,
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
																					where RUANGAN = r.TUJUAN
																					and STATUS = 3
																					and TANGGAL < '2023-01-01') and
																r.TANGGAL 		 <  '2023-01-01' AND
																r.STATUS         = 2 
														group	by farmasi.FARMASI, r.TUJUAN
														order by farmasi.FARMASI
												) subquery
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												0 as qty_tambil,
												0 as qty_jual_retur
										from	(
													select 		max(bp.RUANGAN) as ruangan_kode,
																max(br.RUANGAN) as depo_kode,
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
																br.BARANG   		 = bpd.BAHAN and
																r.id 				 = br.ruangan AND
																bp.STATUS     	 	 = 2 and 
																bp.TANGGAL       	 > (select max(TANGGAL_DIBUAT) 
																					from inventory.stok_opname
																					where RUANGAN = bp.RUANGAN
																					and STATUS = 3
																					and TANGGAL < '2023-01-01') and
																bp.TANGGAL 		     <  '2023-01-01'
													group       by b.id, bp.RUANGAN
												) subquery
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												0 as qty_tambil,
												0 as qty_jual_retur
										from	(
													select 		max(bp.RUANGAN) as ruangan_kode,
																max(br.RUANGAN) as depo_kode,
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
																bp.STATUS     	 	 = 2 and 
																bp.TANGGAL       	 > (select max(TANGGAL_DIBUAT) 
																					from inventory.stok_opname
																					where RUANGAN = bp.RUANGAN
																					and STATUS = 3
																					and TANGGAL < '2023-01-01') and
																bp.TANGGAL 		     <  '2023-01-01'
													group       by b.id, bp.RUANGAN
												) subquery
									UNION ALL
									SELECT		ruangan_kode,
												katalog_kode,
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
												0 as qty_tambil,
												0 as qty_jual_retur
										from	(
													SELECT		max(k.RUANGAN) as ruangan_kode,
																max(b.KODE_BARANG) as katalog_kode,
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
																					where RUANGAN = k.RUANGAN
																					and STATUS = 3
																					and TANGGAL < '2023-01-01') and
																retur.TANGGAL 		 <  '2023-01-01'
														group	by farmasi.FARMASI, k.RUANGAN
												) subquery
									UNION ALL
									select		so.RUANGAN as ruangan_kode,
												b.KODE_BARANG as katalog_kode,
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
												0 as qty_tambil,
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
												sod.MANUAL  != 0 
												and so.TANGGAL < '2023-01-01'
									UNION ALL
									select	*
										from	(
													select 		max(pg.TUJUAN) as ruangan_kode,
																max(b.KODE_BARANG) as katalog_kode,
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
																0 as qty_tambil,
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
																p.TANGGAL 		     >  (select max(TANGGAL_DIBUAT) 
																							from inventory.stok_opname
																							where RUANGAN = pg.TUJUAN
																								and STATUS = 3
																								and TANGGAL < '2023-01-01') and
																p.TANGGAL 		     <  '2023-01-01'
														GROUP	BY 	pd.BARANG, pg.TUJUAN
													) subquery
									UNION ALL
									select	*
										from	(
													select 		max(pg.ASAL) as ruangan_kode,
																max(b.KODE_BARANG) as katalog_kode,
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
																0 as qty_tambil,
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
																p.TANGGAL 		     >  (select max(TANGGAL_DIBUAT) 
																							from inventory.stok_opname
																							where RUANGAN = pg.ASAL
																								and STATUS = 3
																								and TANGGAL < '2023-01-01') and
																p.TANGGAL 		     <  '2023-01-01'
														GROUP	BY 	br.BARANG, pg.ASAL
													) subquery
								) subsubquery 
						WHERE	subsubquery.ruangan_kode = laporanSOdepoLIST.ruangan_kode and
								subsubquery.katalog_id   <> 0 and
								(
									(subsubquery.qty_opname <> 0) or
									(subsubquery.qty_beli <> 0) or
									(subsubquery.qty_masuk <> 0) or
									(subsubquery.qty_keluar <> 0) or
									(subsubquery.qty_prod <> 0) or
									(subsubquery.qty_trx <> 0) or
									(subsubquery.qty_trx_retur <> 0) or
									(subsubquery.qty_jual <> 0) or
									(subsubquery.qty_tambil <> 0) or
									(subsubquery.qty_jual_retur <> 0)
								)
						GROUP 	by subsubquery.ruangan_kode, subsubquery.katalog_id
						ORDER 	by subsubquery.ruangan_kode, subsubquery.katalog_id
				) tableTransaksi,
				(
					select		case depo_nama 	when 'anggrek' then '101030106'
												when 'bougenvile' then '101030107'
												when 'gasmedis' then '101030115'
												when 'griya' then '101030103'
												when 'gudang' then '101030111'
												when 'ibs' then '101030108'
												when 'igd' then '101030104'
												when 'irj1' then '101030101'
												when 'irj3' then '101030112'
												when 'okcito' then '101030105'
												when 'produksi' then '101030110'
												when 'teratai' then '101030109'
								else '00000000' end as ruangan_kode,
								depo_nama,
								katalog_id,
								katalog_kode as katalog_kode_asal,
								koreksi_kode as katalog_kode_koreksi,
								case COALESCE(koreksi_kode, '')
									when '' then katalog_kode
									else koreksi_kode end as katalog_kode,
								katalog_nama as katalog_nama_asal,
								koreksi_keterangan
						from	laporan_so_depo
						where   koreksi_kode <> '.GHE' and koreksi_kode <> '.PINJAM' and koreksi_kode <> '0000000'
								and koreksi_kode <> '.BILLING' and koreksi_kode <> '.TAMBIL' and
								koreksi_kode2 <> '.GHE' and koreksi_kode2 <> '.PINJAM' and koreksi_kode2 <> '0000000'
								and koreksi_kode2 <> '.BILLING' and koreksi_kode2 <> '.TAMBIL'
						order   by case COALESCE(koreksi_kode, '')
									when '' then katalog_kode
									else koreksi_kode end
				) laporanSOdepoREKON
				left outer join (
					select 		*
						from 	rsfPelaporan.laporan_so_grp
				) laporanKatalogGrp
				on  laporanKatalogGrp.katalog_kode = laporanSOdepoREKON.katalog_kode
				left outer join (
					select * from inventory.barang where id in 
					(select min(id) from inventory.barang where KODE_BARANG is not null group by KODE_BARANG)
				) barang
					on barang.KODE_BARANG = laporanKatalogGrp.katalog_kode_grp
				left outer join inventory.satuan msatuan ON msatuan.ID = barang.SATUAN
				left outer join (select * from master.referensi where JENIS = 39) mreff on barang.MERK = mreff.ID
		WHERE	laporanSOdepoREKON.ruangan_kode = tableTransaksi.ruangan_kode and
				laporanSOdepoREKON.katalog_id = tableTransaksi.katalog_id
		GROUP   BY  laporanKatalogGrp.katalog_kode_grp
