-- dibandingkan dengan data SIMRS
SELECT 		sakti_add.*, simrs.katalog_kode
	from	(
				select 		katalog_kode, sakti_nama, qty_add
					from 	tjurnal_sakti_add
			) sakti_add
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simrs
			on simrs.katalog_kode = sakti_add.katalog_kode
order by simrs.katalog_kode;

-- dibandingkan dengan data sesama SAKTI
SELECT 		sakti_add.*, sakti.katalog_kode, sakti.sakti_nama, sakti.qty_awal
	from	(
				select 		katalog_kode, sakti_nama, qty_add
					from 	tjurnal_sakti_add
			) sakti_add
			left outer join
			(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			on sakti.katalog_kode = sakti_add.katalog_kode;
