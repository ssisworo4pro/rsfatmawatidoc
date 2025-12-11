-- koreksi
select 		tk.TANGGAL as tanggal,
			br.RUANGAN as depo_kode,
			jts.ID as trx_jenis,
			masref.ID as trx_jenis_sub,
			br.BARANG as katalog_id,
			r.deskripsi as depo_nama,
			jts.DESKRIPSI as trx_nama,
			jts.TAMBAH_ATAU_KURANG as trx_tambahkurang,
			masref.DESKRIPSI as trxsub_nama,
			b.KATEGORI as kateg_kode,
			k.NAMA as kateg_nama,
			COALESCE((b.kode_barang),'-') as katalog_kode,
			(b.NAMA) as katalog_nama,				
			COALESCE((tkd.JUMLAH), 0) as jml_trxpersediaan,
			(COALESCE(
				( 
					select 	SUM(1) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br
					where 	tsr.REF 			= tkd.ID and 
							tsr.JENIS 			= 53 and
							tsr.BARANG_RUANGAN 	= br.ID and
							tkd.BARANG 			= br.BARANG
					group   by br.BARANG
				), 0)) as jml_rowtrxruangan,
			(COALESCE(
				( 
					select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 53 THEN 1 ELSE -1 END)) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br
					where 	tsr.REF 			= tkd.ID and 
							tsr.JENIS 			= 53 and
							tsr.BARANG_RUANGAN 	= br.ID and
							tkd.BARANG 			= br.BARANG
					group   by br.BARANG
				), 0)) as jml_trxruangan
	from 	inventory.transaksi_koreksi tk
			left outer join
			(	select		ID, DESKRIPSI
					from	master.referensi
					where 	JENIS = 900601 ) masref
			on masref.ID = tk.ALASAN,
			inventory.transaksi_koreksi_detil tkd,
			inventory.kategori k,
			inventory.barang b,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.jenis_transaksi_stok jts
	where	tk.id 				 = tkd.KOREKSI and
			tkd.BARANG 			 = b.ID and
			b.KATEGORI 			 = k.ID and
			br.RUANGAN  		 = tk.RUANGAN and
			br.BARANG   		 = tkd.BARANG and
			r.id 				 = br.ruangan AND
			jts.ID				 = 53 AND
			tk.JENIS 			 = 1 AND
			tk.STATUS   		 = 2 and 
			tk.TANGGAL 			>= '2022-06-01' and 
			tk.TANGGAL  		 < DATE_ADD('2022-06-01', INTERVAL 3 MONTH) and
			b.ID                 = 784
UNION ALL
select 		tk.TANGGAL as tanggal,
			(br.RUANGAN) as depo_kode,
			(jts.ID) as trx_jenis,
			(masref.ID) as trx_jenis_sub,
			(br.BARANG) as katalog_id,
			(r.deskripsi) as depo_nama,
			(jts.DESKRIPSI) as trx_nama,
			(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
			(masref.DESKRIPSI) as trxsub_nama,
			(b.KATEGORI) as kateg_kode,
			(k.NAMA) as kateg_nama,
			COALESCE((b.kode_barang),'-') as katalog_kode,
			(b.NAMA) as katalog_nama,				
			COALESCE((tkd.JUMLAH), 0) as jml_trxpersediaan,
			(COALESCE(
				( 
					select 	SUM(1) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br
					where 	tsr.REF 			= tkd.ID and 
							tsr.JENIS 			= 54 and
							tsr.BARANG_RUANGAN 	= br.ID and
							tkd.BARANG 			= br.BARANG
					group   by br.BARANG
				), 0)) as jml_rowtrxruangan,
			(COALESCE(
				( 
					select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 54 THEN 1 ELSE -1 END)) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br
					where 	tsr.REF 			= tkd.ID and 
							tsr.JENIS 			= 54 and
							tsr.BARANG_RUANGAN 	= br.ID and
							tkd.BARANG 			= br.BARANG
					group   by br.BARANG
				), 0)) as jml_trxruangan
	from 	inventory.transaksi_koreksi tk
			left outer join
			(	select		ID, DESKRIPSI
					from	master.referensi
					where 	JENIS = 900602 ) masref
			on masref.ID = tk.ALASAN,
			inventory.transaksi_koreksi_detil tkd,
			inventory.kategori k,
			inventory.barang b,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.jenis_transaksi_stok jts
	where	tk.id 				 = tkd.KOREKSI and
			tkd.BARANG 			 = b.ID and
			b.KATEGORI 			 = k.ID and
			br.RUANGAN  		 = tk.RUANGAN and
			br.BARANG   		 = tkd.BARANG and
			r.id 				 = br.ruangan AND
			jts.ID				 = 54 AND
			tk.JENIS 			 = 2 AND
			tk.STATUS   		 = 2 and 
			tk.TANGGAL 			>= '2022-06-01' and 
			tk.TANGGAL  		 < DATE_ADD('2022-06-01', INTERVAL 3 MONTH) and
			b.ID                 = 784
UNION ALL
-- penerimaan barang rekanan
select 		pb.TANGGAL as tanggal,
			(br.RUANGAN) as depo_kode,
			(jts.ID) as trx_jenis,
			0 as trx_jenis_sub,
			(br.BARANG) as katalog_id,
			(r.deskripsi) as depo_nama,
			(jts.DESKRIPSI) as trx_nama,
			(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
			'-- non sub --' as trxsub_nama,
			(b.KATEGORI) as kateg_kode,
			(k.NAMA) as kateg_nama,
			COALESCE((b.kode_barang),'-') as katalog_kode,
			(b.NAMA) as katalog_nama,				
			COALESCE((pbd.JUMLAH), 0) as jml_trxpersediaan,
			(COALESCE(
				( 
					select 	SUM(1) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br2
					where 	tsr.REF 				= pbd.ID and 
							( tsr.JENIS 			= 21 or
							  tsr.JENIS 			= 24 ) and
							tsr.BARANG_RUANGAN 		= br2.ID and
							br.ID                   = br2.ID
					group   by br2.BARANG
				), 0)) as jml_rowtrxruangan,
			(COALESCE(
				( 
					select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 21 THEN 1 ELSE -1 END)) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br2
					where 	tsr.REF 				= pbd.ID and 
							( tsr.JENIS 			= 21 or
							  tsr.JENIS 			= 24 ) and
							tsr.BARANG_RUANGAN 		= br2.ID and
							br.ID                   = br2.ID
					group   by br2.BARANG
				), 0)) as jml_trxruangan
	from 	inventory.penerimaan_barang pb, 
			inventory.penerimaan_barang_detil pbd,
			inventory.kategori k,
			inventory.barang b,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.jenis_transaksi_stok jts
	where	pb.ID                = pbd.PENERIMAAN and
			br.BARANG 	 		 = b.ID and
			b.KATEGORI 			 = k.ID and
			br.RUANGAN  		 = pb.RUANGAN and
			br.BARANG   		 = pbd.BARANG and
			r.id 				 = br.ruangan AND
			jts.ID				 = 21 AND
			pb.STATUS     	 	 = 2 and 
			pb.TANGGAL 			>= '2022-06-01' and 
			pb.TANGGAL  		 < DATE_ADD('2022-06-01', INTERVAL 3 MONTH) and
			b.ID                 = 784;
UNION ALL
-- penjualan
select 		p.TANGGAL as tanggal,
			(br.RUANGAN) as depo_kode,
			(jts.ID) as trx_jenis,
			0 as trx_jenis_sub,
			(br.BARANG) as katalog_id,
			(r.deskripsi) as depo_nama,
			(jts.DESKRIPSI) as trx_nama,
			(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
			'-- non sub --' as trxsub_nama,
			(b.KATEGORI) as kateg_kode,
			(k.NAMA) as kateg_nama,
			COALESCE((b.kode_barang),'-') as katalog_kode,
			(b.NAMA) as katalog_nama,
			COALESCE((pd.JUMLAH), 0) as jml_trxpersediaan,
			(COALESCE(
				( 
					select 	SUM(1) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br2
					where 	tsr.REF 				= pd.ID and 
							tsr.JENIS 				= 30 and
							tsr.BARANG_RUANGAN 		= br2.ID and
							br.ID                   = br2.ID
					group   by br2.BARANG
				), 0)) as jml_rowtrxruangan,
			(COALESCE(
				( 
					select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 30 THEN 1 ELSE -1 END)) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br2
					where 	tsr.REF 				= pd.ID and 
							tsr.JENIS 				= 30 and
							tsr.BARANG_RUANGAN 		= br2.ID and
							br.ID                   = br2.ID
					group   by br2.BARANG
				), 0)) as jml_trxruangan
	from 	penjualan.penjualan p, 
			penjualan.penjualan_detil pd,
			inventory.kategori k,
			inventory.barang b,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.jenis_transaksi_stok jts
	where	p.NOMOR              = pd.PENJUALAN_ID and
			br.BARANG 	 		 = b.ID and
			b.KATEGORI 			 = k.ID and
			br.RUANGAN  		 = p.RUANGAN and
			br.BARANG   		 = pd.BARANG and
			r.id 				 = br.ruangan AND
			jts.ID				 = 30 AND
			p.STATUS     		 = 2 and
			p.TANGGAL 			>= '2022-06-01' and 
			p.TANGGAL  		     < DATE_ADD('2022-06-01', INTERVAL 3 MONTH) and
			b.ID                 = 784;
