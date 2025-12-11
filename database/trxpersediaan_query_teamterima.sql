select * from rsfTeamterima.masterf_backupstok_so_close mbsc; 

select * from rsfTeamterima.relasif_ketersediaan rk order by id desc;

select * from rsfTeamterima.masterf_backupstok_so_close mbsc; 

select * from rsfTeamterima.transaksif_stokopname ts order by tgl_adm desc;

select 		rs.jumlah_fisik 
	from 	rsfTeamterima.transaksif_stokopname ts,
			rsfTeamterima.relasif_stokopname rs
	WHERE 	ts.tgl_adm > '2021-12-01' and
			ts.tgl_adm < '2022-01-01' and
			rs.kode_reff = ts.kode and
			rs.id_katalog = '10P225'
	order 	by ts.tgl_adm desc;

select 		sum(rs.jumlah_fisik)
	from 	rsfTeamterima.transaksif_stokopname ts,
			rsfTeamterima.relasif_stokopname rs
	WHERE 	ts.tgl_adm > '2021-12-01' and
			ts.tgl_adm < '2022-01-01' and
			rs.kode_reff = ts.kode and
			rs.id_katalog = '10P225';


select 		* 
	from 	rsfTeamterima.relasif_stokopname rs;


select * from rsfMaster.mruangan_farmasi;
select * from rsfTeamterima.masterf_depo md where upper(namaDepo) like '%KONS%';

select * from rsfTeamterima.masterf_backupstok_so_close mbsc where id_depo = 320 or id_depo = 319; 
select * from rsfTeamterima.masterf_backupstok_so_close mbsc where id_depo = 330; 
select * from rsfTeamterima.masterf_backupstok_so_close mbsc where id_depo = 321; 
select * from rsfTeamterima.masterf_backupstok_so_close mbsc where id_depo = 69; 

select * from rsfTeamterima.relasif_ketersediaan rk where id_depo = 320 or id_depo = 319
order by id desc;
select * from rsfTeamterima.relasif_ketersediaan rk where id_depo = 330
order by id desc;
select * from rsfTeamterima.relasif_ketersediaan rk where id_depo = 321
order by id desc;
select * from rsfTeamterima.relasif_ketersediaan rk where id_depo = 69
order by id desc;

select DISTINCT rk.kode_transaksi from rsfTeamterima.relasif_ketersediaan rk ;
select max(tgl_tersedia) from rsfTeamterima.relasif_ketersediaan rk where rk.kode_transaksi = '' ;

select 		count(1)
	from 	rsfTeamterima.relasif_ketersediaan rk 
	where 	rk.tgl_tersedia > '2021-12-22';


				select 		DISTINCT kode_transaksi, tipe_tersedia 
					from 	rsfTeamterima.relasif_ketersediaan rk 
					where 	rk.id_katalog = '10P225';

masterf_backupstok_so_close

-- untuk mendapatkan tanggal stok opname terakhir
select 		max(mf.nm_ruangan) as ruangan,
			max(mbsc.tgl) as tanggal
	from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
			rsfMaster.mruangan_farmasi mf
	where 	mbsc.id_depo = mf.id_teamterima and
			mbsc.tgl < '2022-09-01'
	group   by mf.id; 
select 		max(mf.nm_ruangan) as ruangan,
			max(mbsc.tgl) as tanggal
	from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
			rsfMaster.mruangan_farmasi mf
	where 	mbsc.id_depo = mf.id_teamterima and
			mbsc.tgl < '2022-01-01'
	group   by mf.id; 


select 		max(mf.nm_ruangan) as ruangan,
			max(mbsc.tgl) as tanggal,
			max(mbsc.jumlah_stokfisik) as jumlah_stokfisik,
			max(mbsc.jumlah_itemfisik) as jumlah_itemfisik,
			max(mbsc.jumlah_stokadm) as jumlah_stokadm
	from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
			rsfMaster.mruangan_farmasi mf
	where 	mbsc.id_depo = mf.id_teamterima and
			mbsc.id_katalog = '10P225' and
			mbsc.tgl < '2022-01-01'
	group   by mf.id; 

select 		'Rumah Sakit' as ruangan,
			max(mbsc.tgl) as tanggal,
			sum(mbsc.jumlah_stokfisik) as jumlah_stokfisik,
			sum(mbsc.jumlah_itemfisik) as jumlah_itemfisik,
			sum(mbsc.jumlah_stokadm) as jumlah_stokadm
	from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
			rsfMaster.mruangan_farmasi mf
	where 	mbsc.id_depo = mf.id_teamterima and
			mbsc.id_katalog = '10P225' and
			mbsc.tgl < '2022-01-01' and
			mbsc.tgl > '2021-12-01' ;

select 		max(mf.nm_ruangan) as ruangan,
			max(mbsc.tgl) as tanggal,
			max(mbsc.jumlah_stokfisik) as jumlah_stokfisik,
			max(mbsc.jumlah_itemfisik) as jumlah_itemfisik,
			max(mbsc.jumlah_stokadm) as jumlah_stokadm
	from 	rsfTeamterima.relasif_ketersediaan rk,
			rsfMaster.mruangan_farmasi mf
	where 	rk.id_depo = mf.id_teamterima and
			rk..id_katalog = '10P225' and
			mbsc.tgl < '2022-01-01'
	group   by mf.id; 


-- transaksi stelah so
select 		sum(jumlah_masuk) as masuk,
			sum(jumlah_keluar) as keluar
	from 	rsfTeamterima.relasif_ketersediaan rk 
	where 	rk.tgl_tersedia > '2021-12-22' and
			rk.tgl_tersedia < '2022-01-01' and
			rk.id_katalog = '10P225' and
			rk.tipe_tersedia != 'stokopname';

select 		rk.tipe_tersedia, rk.kode_transaksi, rk.id_depo,
			sum(jumlah_masuk) as masuk,
			sum(jumlah_keluar) as keluar
	from 	rsfTeamterima.relasif_ketersediaan rk
	where 	rk.tgl_tersedia > '2021-12-22' and
			rk.tgl_tersedia < '2022-01-01' and
			rk.id_katalog = '10P225' and
			rk.tipe_tersedia != 'stokopname' and
			rk.tipe_tersedia != 'pengiriman' and
			rk.tipe_tersedia != 'penerimaan'
	group   by rk.tipe_tersedia, rk.kode_transaksi, rk.id_depo;

		
select 		*
	from 	rsfTeamterima.relasif_ketersediaan rk 
	where 	rk.tgl_tersedia > '2021-12-22' and
			rk.tgl_tersedia < '2022-01-01' and
			rk.id_katalog = '10P225' and
			rk.tipe_tersedia = 'stokopname'
	order   by rk.id_depo ;

select 		sum(jumlah_tersedia), sum(jumlah_masuk)
	from 	rsfTeamterima.relasif_ketersediaan rk 
	where 	rk.tgl_tersedia > '2021-12-22' and
			rk.tgl_tersedia < '2022-01-01' and
			rk.id_katalog = '10P225' and
			rk.tipe_tersedia = 'stokopname';
\
masterf_backupstok_so_close
select 		kode_transaksi,
			tipe_tersedia,
			sum(jumlah_masuk) as masuk,
			sum(jumlah_keluar) as keluar
	from 	rsfTeamterima.relasif_ketersediaan rk 
	where 	rk.id_katalog = '10P225' and
			rk.tgl_tersedia > '2021-12-22' and
			rk.tgl_tersedia < '2022-01-01'and
			rk.tipe_tersedia != 'stokopname'
	group   by kode_transaksi, tipe_tersedia;


select 		* 
	from 	rsfPelaporan.laporan_mutasi_bulan lmb 
	where	katalog_kode = '10P225';
	
select * from rsfTeamterima.laporan_mutasi_bulan where tahun = 2022 and bulan = 1 and id_katalog = '10P225';

SELECT sc.jumlah_stokfisik, sc.status, sc.*,
                        id_katalog,
                        (jumlah_stokfisik) jumlah,
                        (jumlah_stokfisik * hp_item) nilai
                    FROM rsfTeamterima.masterf_backupstok_so_close sc
                    WHERE
                        MONTH(tgl) = '12'
                        AND YEAR(tgl) = '2021'
                        AND id_katalog = '10P225'
                        AND status = 1;

                       select 		'Rumah Sakit' as ruangan,
			max(mbsc.tgl) as tanggal,
			max(mbsc.jumlah_stokfisik) as jumlah_stokfisik,
			max(mbsc.jumlah_itemfisik) as jumlah_itemfisik,
			max(mbsc.jumlah_stokadm) as jumlah_stokadm
	from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
			rsfMaster.mruangan_farmasi mf
	where 	mbsc.id_depo = mf.id_teamterima and
			mbsc.id_katalog = '10P225' and
			mbsc.tgl < '2022-01-01' and
			mbsc.tgl > '2021-12-01' ;

SELECT 		* 
	FROM 	(
				select 		'A', id_depo, jumlah_stokfisik
				from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
						rsfMaster.mruangan_farmasi mf
				where 	mbsc.id_depo = mf.id_teamterima and
						mbsc.id_katalog = '10P225' and
						mbsc.tgl < '2022-01-01' and
						mbsc.tgl > '2021-12-01' 
				UNION ALL
				SELECT 		'B', sc.id_depo, sc.jumlah_stokfisik
				FROM 	rsfTeamterima.masterf_backupstok_so_close sc
				WHERE	MONTH(tgl) = '12'
				        AND YEAR(tgl) = '2021'
				        AND id_katalog = '10P225'
				        AND status = 1
			) A
	ORDER	BY A.id_depo;

select 	sum(jumlah_stokfisik)
from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
		rsfMaster.mruangan_farmasi mf
where 	mbsc.id_depo = mf.id_teamterima and
		mbsc.id_katalog = '10P225' and
		mbsc.tgl < '2022-01-01' and
		mbsc.tgl > '2021-12-01' 
UNION ALL
SELECT 	sum(sc.jumlah_stokfisik)
FROM 	rsfTeamterima.masterf_backupstok_so_close sc
WHERE	MONTH(tgl) = '12'
        AND YEAR(tgl) = '2021'
        AND id_katalog = '10P225'
        AND status = 1;

select 	sum(jumlah_stokfisik)
from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
		rsfMaster.mruangan_farmasi mf
where 	mbsc.id_depo = mf.id_teamterima and
		mbsc.id_katalog = '10P225' and
		mbsc.tgl < '2022-04-01' and
		mbsc.tgl > '2022-03-01' 
UNION ALL
SELECT 	sum(sc.jumlah_stokfisik)
FROM 	rsfTeamterima.masterf_backupstok_so_close sc
WHERE	MONTH(tgl) = '3'
        AND YEAR(tgl) = '2022'
        AND id_katalog = '10P225'
        AND status = 1;

-- Transaksi Triwulan
select		sum(saldo_awal) as saldo_awal, sum(qty_masuk) as qty_masuk, 
			sum(qty_keluar) as qty_keluar, sum(qty_adjusment) as qty_adjusment, 
			sum(saldo_akhir) as saldo_akhir,
			sum(saldo_awal) + (sum(qty_masuk) - sum(qty_keluar) + sum(qty_adjusment)) as saldo_akhir_hitung
	from	(
				select 		sum(jumlah_stokfisik) as saldo_awal, 0  as saldo_akhir,
							0 as qty_masuk, 0 as qty_keluar,
							0 as qty_adjusment
					from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
							rsfMaster.mruangan_farmasi mf
					where 	mbsc.id_depo = mf.id_teamterima and
							mbsc.id_katalog = '10P225' and
							mbsc.tgl < '2022-01-01' and
							mbsc.tgl > '2021-12-01' 
				UNION ALL
				select 		0 as saldo_awal, sum(jumlah_stokfisik) as saldo_akhir,
							0 as qty_masuk, 0 as qty_keluar,
							0 as qty_adjusment
					from 	rsfTeamterima.masterf_backupstok_so_close mbsc,
							rsfMaster.mruangan_farmasi mf
					where 	mbsc.id_depo = mf.id_teamterima and
							mbsc.id_katalog = '10P225' and
							mbsc.tgl < '2022-04-01' and
							mbsc.tgl > '2022-03-01'
				UNION ALL
				select 		0 as saldo_awal, 0 as saldo_akhir, 
							sum(jumlah_masuk) as qty_masuk, sum(jumlah_keluar) as qty_keluar,
							0 as qty_adjusment
					from 	rsfTeamterima.relasif_ketersediaan rk 
					where 	rk.tgl_tersedia >= '2022-01-01' and
							rk.tgl_tersedia  < '2022-04-01' and
							rk.id_katalog = '10P225' and
							rk.kode_transaksi = 'R' and
							rk.tipe_tersedia = 'penjualan'
				UNION ALL
				select 		0 as saldo_awal, 0 as saldo_akhir, 
							0 as qty_masuk, 0 as qty_keluar,
							sum(
								jumlah_akhir - 
								(	jumlah_awal + 
									(	jumlah_pembelian + jumlah_koreksipenerimaan + 
										jumlah_revisipenerimaan + jumlah_returpembelian ) 
									+ jumlah_hasilproduksi + jumlah_koreksi 
								) + 
								(	jumlah_penjualan + jumlah_bahanproduksi + jumlah_floorstok + 
									jumlah_expired + jumlah_rusak )
							) as qty_adjusment
					FROM 	rsfTeamterima.laporan_mutasi_triwulan
					where	tahun = 2022 and
							triwulan = 1 and
							id_katalog = '10P225'
			) subquery;

		
		
		
select 		0 as saldo_awal, 0 as saldo_akhir, sum(jumlah_masuk) as qty_masuk, sum(jumlah_keluar) as qty_keluar
	from 	rsfTeamterima.relasif_ketersediaan rk 
	where 	rk.tgl_tersedia > '2022-01-01' and
			rk.tgl_tersedia < '2022-03-19' and
			rk.id_katalog = '10P225' and
			rk.kode_transaksi = 'R' and
			rk.tipe_tersedia = 'penjualan';

select		sum(jumlah_keluar) - sum(jumlah_masuk) 
	from	rsfTeamterima.relasif_ketersediaan rk
	where	tipe_tersedia = 'penjualan' and   -- 83883.15
            kode_transaksi = 'R' and
            rk.tgl_tersedia >= '2022-01-01' and
			rk.tgl_tersedia < '2022-04-01' and
			rk.id_katalog = '10P225';

SELECT 		SUM(jumlah_keluar - jumlah_masuk) jumlah
    FROM 	rsfTeamterima.relasif_ketersediaan 
    WHERE 	kode_transaksi = 'R' AND 
    		tipe_tersedia = 'penjualan' AND 
    		MONTH(tgl_tersedia) < 4 AND
    		YEAR(tgl_tersedia) = 2022 AND 
    		status = '1' AND
			id_katalog = '10P225';

SELECT 		sum(jumlah_penjualan) - sum(jumlah_adjustment)
	FROM 	rsfPelaporan.laporan_mutasi_bulan lap
	where	lap.tahun = 2022 and
			lap.bulan < 4 and
			katalog_kode = '10P225';

SELECT 		sum(jumlah_penjualan) - sum(jumlah_adjustment)
	FROM 	rsfTeamterima.laporan_mutasi_triwulan
	where	tahun = 2022 and
			triwulan = 1 and
			id_katalog = '10P225';

		
SELECT 		sum(
				jumlah_akhir - 
				(	jumlah_awal + 
					(	jumlah_pembelian + jumlah_koreksipenerimaan + 
						jumlah_revisipenerimaan + jumlah_returpembelian ) 
					+ jumlah_hasilproduksi + jumlah_koreksi 
				) + 
				(	jumlah_penjualan + jumlah_bahanproduksi + jumlah_floorstok + 
					jumlah_expired + jumlah_rusak )
			) as jumlah_adjusment
	FROM 	rsfTeamterima.laporan_mutasi_triwulan
	where	tahun = 2022 and
			triwulan = 1 and
			id_katalog = '10P225';
		

SELECT 		sum(jumlah_penjualan) - sum(
				jumlah_akhir - 
				(	jumlah_awal + 
					(	jumlah_pembelian + jumlah_koreksipenerimaan + 
						jumlah_revisipenerimaan + jumlah_returpembelian ) 
					+ jumlah_hasilproduksi + jumlah_koreksi 
				) + 
				(	jumlah_penjualan + jumlah_bahanproduksi + jumlah_floorstok + 
					jumlah_expired + jumlah_rusak )
			) as jumlah_penjualan
	FROM 	rsfPelaporan.laporan_mutasi_bulan lap
	where	lap.tahun = 2022 and
			lap.bulan < 4 and
			katalog_kode = '10P225';



==================================

BEGIN
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) 
SELECT 		a.id_katalog, id_depo, jumlah_stokadm, 
			jumlah_stokfisik, ifnull(hp_item,0), 
			'1', 'O17202209230001', '2022-09-23 23:59:00', '3378' 
	FROM 	transaksif_stokkatalog a 
			LEFT JOIN relasif_hargaperolehan b 
			ON 	a.id_katalog = b.id_katalog AND 
				b.sts_hja = 1 AND 
				b.sts_hjapb = 1 
	WHERE 	id_depo='129';

INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O03202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='23';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O12202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='25';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O08202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='26';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O06202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='27';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O10202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='28';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O07202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='30';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O00202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='59';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O15202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='60';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O16202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='61';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O11202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='64';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O18202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='329';
INSERT INTO masterf_backupstok_so_close(id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, hp_item, status, kode_reff, tgl, user_in) SELECT a.id_katalog, id_depo, jumlah_stokadm, jumlah_stokfisik, ifnull(hp_item,0), '1', 'O09202209230001', '2022-09-23 23:59:00', '3378' FROM transaksif_stokkatalog a LEFT JOIN relasif_hargaperolehan b ON a.id_katalog = b.id_katalog AND b.sts_hja = 1 AND b.sts_hjapb = 1 WHERE id_depo='65';
END		