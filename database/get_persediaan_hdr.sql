DROP PROCEDURE IF EXISTS rsfPelaporan.get_persediaan_hdr;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.get_persediaan_hdr(
	aToken   	TEXT,
	aParam		TEXT
)
BEGIN
	DECLARE	vValid			integer;
	DECLARE	vMethod			varchar(75);
	DECLARE	vErrorMsg		varchar(255);
	DECLARE vTahun			integer;
	DECLARE vBulan			integer;
	DECLARE vType			integer;
	DECLARE vBulan2			integer;
	DECLARE vBulan3			integer;
	DECLARE vTriwulan		integer;
	DECLARE	vKodeJenis		varchar(15);
	DECLARE	vKodeDepo		varchar(15);
	DECLARE sBulan			char(6);
	DECLARE sBulan3			char(6);
	DECLARE sJenisTrx       varchar(75);
	DECLARE vTrxJenis		integer;
	DECLARE vTrxJenisSub	integer;
	DECLARE vJudulTriwulan  varchar(75);
	DECLARE vTanggalAwal    date;
	DECLARE vTanggalAkhir   date;
	DECLARE sTriwulan       varchar(25);
	
	SET		vValid = JSON_VALID(aParam);
	IF (vVAlid) THEN
		SET vMethod = JSON_EXTRACT(aParam,'$[0].method');
		SET vMethod = REPLACE(vMethod,'"','');
		SET vTahun  = JSON_EXTRACT(aParam,'$[0].tahun');
		SET vType   = JSON_EXTRACT(aParam,'$[0].type');
		SET vTriwulan = JSON_EXTRACT(aParam,'$[0].triwulan');
		IF (vType = 1) THEN
			IF (vTriwulan = 1) THEN
				SET vBulan 		= 1;
				SET vBulan2 	= 2;
				SET vBulan3 	= 3;
			ELSEIF (vTriwulan = 2) THEN
				SET vBulan 		= 4;
				SET vBulan2 	= 5;
				SET vBulan3 	= 6;
			ELSEIF (vTriwulan = 3) THEN
				SET vBulan 		= 7;
				SET vBulan2 	= 8;
				SET vBulan3 	= 9;
			ELSEIF (vTriwulan = 4) THEN
				SET vBulan 		= 10;
				SET vBulan2 	= 11;
				SET vBulan3 	= 12;
			END IF;
		ELSE
			SET vBulan  = JSON_EXTRACT(aParam,'$[0].triwulan');
		END IF;
		IF (vMethod = "hdrPersediaan") THEN
			select		*
				from	(
							select		'Laporan Persediaan' as judul1,
										concat(' Rumah Sakit', '') as judul2,
										1 as type,
										tahun as tahun,
										triwulan as triwulan,
										'' as nama_depo,
										max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
										max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
										max(kode_jenis) as kode_jenis,
										'' as id,
										concat(tahun, triwulan) as kode,
										concat('tahun ', tahun, ' triwulan ', triwulan) as nama,
										format(sum(aw),0) as aw, 
										'' as mmasuk,
										'' as mkeluar,
										format(sum(beli),0) as beli, format(sum(prod),0) as prod,
										format(sum(jual),0) as jual, format(sum(bahan),0) as bahan, 
										format(sum(floors),0) as floors, format(sum(expr),0) as expr,
										format(sum(akhir),0) as akhir, format(sum(opname),0) as opname
								from	(
											select 		'--- Rumah Sakit ---' as nama_depo, 
														bulan, id_katalog, kode_barang, nama_barang,
														tahun as tahun,
														CEILING (bulan / 3) as triwulan,
														kode_jenis,
														nama_jenis,
														jumlah_awal as aw, 
														0 as mmasuk,
														0 as mkeluar,
														jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
														jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
														0 as akhir, 0 as opname
												from 	rsfPelaporan.laporan_mutasi_bulan
												where	(bulan = 1) or (bulan = 4) or (bulan = 7) or (bulan = 10)
											UNION ALL
											select 		'--- Rumah Sakit ---' as nama_depo, 
														bulan, id_katalog, kode_barang, nama_barang,
														tahun as tahun,
														CEILING (bulan / 3) as triwulan,
														kode_jenis,
														nama_jenis,
														0 as aw, 
														0 as mmasuk,
														0 as mkeluar,
														jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
														jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
														0 as akhir, 0 as opname
												from 	rsfPelaporan.laporan_mutasi_bulan lmb
												where	(bulan = 2) or (bulan = 5) or (bulan = 8) or (bulan = 11)
											UNION ALL
											select 		'--- Rumah Sakit ---' as nama_depo, 
														bulan, id_katalog, kode_barang, nama_barang,
														tahun as tahun,
														CEILING (bulan / 3) as triwulan,
														kode_jenis,
														nama_jenis,
														0 as aw, 
														0 as mmasuk,
														0 as mkeluar,
														jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
														jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
														jumlah_akhir as akhir, jumlah_opname as opname
												from 	rsfPelaporan.laporan_mutasi_bulan lmb
												where	(bulan = 3) or (bulan = 6) or (bulan = 9) or (bulan = 12)
										) subquery
								group   by tahun, triwulan
								order	by tahun, triwulan
						) seluruhTriwulan
			UNION ALL
			select		*
				from	(
							select		'Laporan Persediaan' as judul1,
										concat(' Rumah Sakit', '') as judul2,
										2 as type,
										tahun as tahun,
										bulan as triwulan,
										'' as nama_depo,
										max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
										max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
										max(kode_jenis) as kode_jenis,
										'' as id,
										concat(tahun, bulan) as kode,
										concat('tahun ', tahun, ' bulan ', bulan) as nama,
										format(sum(aw),0) as aw, 
										'' as mmasuk,
										'' as mkeluar,
										format(sum(beli),0) as beli, format(sum(prod),0) as prod,
										format(sum(jual),0) as jual, format(sum(bahan),0) as bahan, 
										format(sum(floors),0) as floors, format(sum(expr),0) as expr,
										format(sum(akhir),0) as akhir, format(sum(opname),0) as opname
								from	(
											select 		'--- Rumah Sakit ---' as nama_depo, 
														bulan, id_katalog, kode_barang, nama_barang,
														tahun as tahun,
														CEILING (bulan / 3) as triwulan,
														kode_jenis,
														nama_jenis,
														jumlah_awal as aw, 
														0 as mmasuk,
														0 as mkeluar,
														jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
														jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
														jumlah_akhir as akhir, jumlah_opname as opname
												from 	rsfPelaporan.laporan_mutasi_bulan lmb
										) subquery
								group   by tahun, bulan
								order	by tahun, bulan
						) seluruhBulanan;
		ELSEIF (vMethod = "hdrTriwulanJenis") THEN
			SET vKodeJenis = JSON_EXTRACT(aParam,'$[0].kode_jenis');
			SET vKodeJenis = REPLACE(vKodeJenis,'"','');
			IF (vType = 1) THEN
				select		concat('Laporan Persediaan Kelompok Barang ', max(nama_jenis)) as judul1,
							concat('tahun ', vTahun, ' triwulan ', vTriwulan) as judul2,
							vTahun as tahun,
							vTriwulan as triwulan,
							1 as type,
							max(nama_depo) as nama_depo,
							max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
							max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
							max(kode_jenis) as kode_jenis,
							max(id_katalog) as id,
							max(kode_barang) as kode,
							max(nama_barang) as nama,
							sum(aw) as aw, 
							sum(mmasuk) as mmasuk,
							sum(mkeluar) as mkeluar,
							sum(beli) as beli, sum(prod) as prod,
							sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
							sum(akhir) as akhir, sum(opname) as opname
					from	(
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan
									where	tahun = vTahun and 
											bulan = vBulan
								UNION ALL
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan lmb
									where	lmb.tahun = vTahun and 
											lmb.bulan = vBulan2
								UNION ALL
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan lmb
									where	lmb.tahun = vTahun and 
											lmb.bulan = vBulan3
							) subquery
					where   kode_jenis = vKodeJenis
					group   by id_katalog, nama_depo
					order	by nama_jenis, kode_barang, id_katalog, nama_depo;
			ELSE
				select		concat('Laporan Persediaan Kelompok Barang ', max(nama_jenis)) as judul1,
							concat('tahun ', vTahun, ' bulan ', max(bulan)) as judul2,
							vTahun as tahun,
							bulan as triwulan,
							2 as type,
							max(nama_depo) as nama_depo,
							max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
							max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
							max(kode_jenis) as kode_jenis,
							max(id_katalog) as id,
							max(kode_barang) as kode,
							max(nama_barang) as nama,
							sum(aw) as aw, 
							sum(mmasuk) as mmasuk,
							sum(mkeluar) as mkeluar,
							sum(beli) as beli, sum(prod) as prod,
							sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
							sum(akhir) as akhir, sum(opname) as opname
					from	(
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan
									where	tahun = vTahun and 
											bulan = vBulan
							) subquery
					where   kode_jenis = vKodeJenis
					group   by id_katalog, nama_depo
					order	by nama_jenis, kode_barang, id_katalog, nama_depo;
			END IF;
		ELSEIF (vMethod = "hdrTriwulanJenisKatalog") THEN
			SET vKodeJenis = JSON_EXTRACT(aParam,'$[0].id_katalog');
			SET vKodeJenis = REPLACE(vKodeJenis,'"','');
			IF (vType = 1) THEN
				select		concat('Laporan Persediaan ', max(nama_barang)) as judul1,
							concat('tahun ', vTahun, ' triwulan ', vTriwulan) as judul2,
							vTahun as tahun,
							vTriwulan as triwulan,
							1 as type,
							max(nama_depo) as nama_depo,
							max(kode_depo) as kode_depo,
							max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
							max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
							max(kode_jenis) as kode_jenis,
							max(id_katalog) as id,
							max(kode_barang) as kode,
							max(nama_barang) as nama,
							sum(aw) as aw, 
							sum(mmasuk) as mmasuk,
							sum(mkeluar) as mkeluar,
							sum(beli) as beli, sum(prod) as prod,
							sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
							sum(akhir) as akhir, sum(opname) as opname
					from	(
								select 		'--- Rumah Sakit ---' as nama_depo,
											'' as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan
									where	tahun = vTahun and 
											bulan = vBulan
								UNION ALL
								select 		nama_depo as nama_depo, 
											id_depo as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											jumlah_mutasimasuk as mmasuk,
											jumlah_mutasikeluar as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan_depo
									where	tahun = vTahun and 
											bulan = vBulan
								UNION ALL
								select 		'--- Rumah Sakit ---' as nama_depo, 
											'' as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan lmb
									where	lmb.tahun = vTahun and 
											lmb.bulan = vBulan2
								UNION ALL
								select 		nama_depo as nama_depo,
											id_depo as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											jumlah_mutasimasuk as mmasuk,
											jumlah_mutasikeluar as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan_depo
									where	tahun = vTahun and 
											bulan = vBulan2
								UNION ALL
								select 		'--- Rumah Sakit ---' as nama_depo, 
											'' as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan lmb
									where	lmb.tahun = vTahun and 
											lmb.bulan = vBulan3
								UNION ALL
								select 		nama_depo as nama_depo,
											id_depo as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											jumlah_mutasimasuk as mmasuk,
											jumlah_mutasikeluar as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan_depo
									where	tahun = vTahun and 
											bulan = vBulan3
							) subquery
					where   id_katalog = vKodeJenis -- '10101' -- and id_katalog = '10600'
					group   by id_katalog, nama_depo
					order	by nama_jenis, kode_barang, id_katalog, nama_depo;
			ELSE
				select		concat('Laporan Persediaan ', max(nama_barang)) as judul1,
							concat('tahun ', vTahun, ' bulan ', max(bulan)) as judul2,
							vTahun as tahun,
							bulan as triwulan,
							2 as type,
							max(nama_depo) as nama_depo,
							max(kode_depo) as kode_depo,
							max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
							max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
							max(kode_jenis) as kode_jenis,
							max(id_katalog) as id,
							max(kode_barang) as kode,
							max(nama_barang) as nama,
							sum(aw) as aw, 
							sum(mmasuk) as mmasuk,
							sum(mkeluar) as mkeluar,
							sum(beli) as beli, sum(prod) as prod,
							sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
							sum(akhir) as akhir, sum(opname) as opname
					from	(
								select 		'--- Rumah Sakit ---' as nama_depo,
											'' as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan
									where	tahun = vTahun and 
											bulan = vBulan
								UNION ALL
								select 		nama_depo as nama_depo, 
											id_depo as kode_depo,
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											jumlah_mutasimasuk as mmasuk,
											jumlah_mutasikeluar as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan_depo
									where	tahun = vTahun and 
											bulan = vBulan
							) subquery
					where   id_katalog = vKodeJenis -- '10101' -- and id_katalog = '10600'
					group   by id_katalog, nama_depo
					order	by nama_jenis, kode_barang, id_katalog, nama_depo;
			END IF;
		ELSEIF (vMethod = "hdrTriwulanJenisKatalogDepo") THEN
			SET vKodeJenis = JSON_EXTRACT(aParam,'$[0].id_katalog');
			SET vKodeJenis = REPLACE(vKodeJenis,'"','');
			SET vKodeDepo  = JSON_EXTRACT(aParam,'$[0].kode_depo');
			SET vKodeDepo  = REPLACE(vKodeDepo,'"','');
			SET sBulan	   = concat(cast(vTahun as char), RIGHT(concat('00', cast(vBulan as char)),2));
			SET sBulan3	   = concat(cast(vTahun as char), RIGHT(concat('00', cast(vBulan3 as char)),2));
			SET sJenisTrx  = 'jumlah_penjualan';
			SET sJenisTrx  = JSON_EXTRACT(aParam,'$[0].jenis_kolom');
			SET sJenisTrx  = REPLACE(sJenisTrx ,'"','');
			
			IF (vType = 1) THEN
				IF (vKodeDepo = '') THEN
					select		concat('', sJenisTrx, ' === ', (nama_barang)) as judul1,
								concat('tahun ', vTahun, ' triwulan ', vTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								bulan as tahunbulan,
								nama_depo,
								vKodeDepo as kode_depo,
								id_katalog, 
								kode_barang, 
								nama_barang, 
								qty,
								trx_nama,
								trxsub_nama,
								trx_jenis,
								trx_jenis_sub,
								klp_pengali
						from	(
									select		sum(dp.jml_trxpersediaan) as qty, 
												max(dp.bulan) as bulan,
												max(dp.depo_nama) as nama_depo,
												max(dp.depo_kode) as kode_depo,
												max(dp.katalog_id) as id_katalog,
												max(dp.katalog_kode) as kode_barang,
												max(dp.katalog_nama) as nama_barang,
												max(dp.trx_nama) as trx_nama,
												max(dp.trxsub_nama) as trxsub_nama,
												max(dp.trx_jenis) as trx_jenis,
												max(dp.trx_jenis_sub) as trx_jenis_sub,
												max(mp.klp_pengali) as klp_pengali,
												max(mp.klp_kolomupd_depo) as klp_kolomupd_depo,
												max(dp.depo_kode) as depo_kode
										from	rsfPelaporan.dlap_persediaan dp,
												rsfPelaporan.mlap_persediaan mp
										where	dp.katalog_id 			 	 = vKodeJenis and
												dp.trx_jenis 			 	 = mp.trx_jenis and
												dp.trx_jenis_sub 		 	 = mp.trx_jenis_sub and
												mp.klp_kolomupd_depo 		 = sJenisTrx and
												dp.bulan 					>= sBulan and
												dp.bulan 					<= sBulan3
										group   by dp.bulan, dp.trx_jenis, dp.trx_jenis_sub, dp.katalog_id
								) subquery;
				ELSE
					select		concat('', sJenisTrx, ' === ', (nama_barang), ' === ', nama_depo) as judul1,
								concat('tahun ', vTahun, ' triwulan ', vTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								bulan as tahunbulan,
								nama_depo,
								vKodeDepo as kode_depo,
								id_katalog, 
								kode_barang, 
								nama_barang, 
								qty,
								trx_nama,
								trxsub_nama,
								trx_jenis,
								trx_jenis_sub,
								klp_pengali
						from	(
									select		dp.jml_trxpersediaan as qty, 
												dp.bulan,
												dp.depo_nama as nama_depo,
												dp.depo_kode as kode_depo,
												dp.katalog_id as id_katalog,
												dp.katalog_kode as kode_barang,
												dp.katalog_nama as nama_barang,
												dp.trx_nama,
												dp.trxsub_nama,
												dp.trx_jenis,
												dp.trx_jenis_sub,
												mp.klp_pengali,
												mp.klp_kolomupd_depo,
												dp.depo_kode 
										from	rsfPelaporan.dlap_persediaan dp,
												rsfPelaporan.mlap_persediaan mp
										where	dp.katalog_id 			 	 = vKodeJenis and
												dp.depo_kode 				 = vKodeDepo and
												dp.trx_jenis 			 	 = mp.trx_jenis and
												dp.trx_jenis_sub 		 	 = mp.trx_jenis_sub and
												mp.klp_kolomupd_depo 		 = sJenisTrx and
												dp.bulan 					>= sBulan and
												dp.bulan 					<= sBulan3
								) subquery;
				END IF;
			ELSEIF (vType = 2) THEN
				IF (vKodeDepo = '') THEN
					select		concat('', sJenisTrx, ' === ', (nama_barang)) as judul1,
								concat('tahun ', vTahun, ' bulan ', vBulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								bulan as tahunbulan,
								nama_depo,
								vKodeDepo as kode_depo,
								id_katalog, 
								kode_barang, 
								nama_barang, 
								qty,
								trx_nama,
								trxsub_nama,
								trx_jenis,
								trx_jenis_sub,
								klp_pengali
						from	(
									select		sum(dp.jml_trxpersediaan) as qty, 
												max(dp.bulan) as bulan,
												max(dp.depo_nama) as nama_depo,
												max(dp.depo_kode) as kode_depo,
												max(dp.katalog_id) as id_katalog,
												max(dp.katalog_kode) as kode_barang,
												max(dp.katalog_nama) as nama_barang,
												max(dp.trx_nama) as trx_nama,
												max(dp.trxsub_nama) as trxsub_nama,
												max(dp.trx_jenis) as trx_jenis,
												max(dp.trx_jenis_sub) as trx_jenis_sub,
												max(mp.klp_pengali) as klp_pengali,
												max(mp.klp_kolomupd_depo) as klp_kolomupd_depo,
												max(dp.depo_kode) as depo_kode
										from	rsfPelaporan.dlap_persediaan dp,
												rsfPelaporan.mlap_persediaan mp
										where	dp.katalog_id 			 	 = vKodeJenis and
												dp.trx_jenis 			 	 = mp.trx_jenis and
												dp.trx_jenis_sub 		 	 = mp.trx_jenis_sub and
												mp.klp_kolomupd_depo 		 = sJenisTrx and
												dp.bulan 					 = sBulan 
										group   by dp.bulan, dp.trx_jenis, dp.trx_jenis_sub, dp.katalog_id
								) subquery;
				ELSE
					select		concat('', sJenisTrx, ' === ', (nama_barang), ' === ', nama_depo) as judul1,
								concat('tahun ', vTahun, ' bulan ', vBulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								bulan as tahunbulan,
								nama_depo,
								vKodeDepo as kode_depo,
								id_katalog, 
								kode_barang, 
								nama_barang, 
								qty,
								trx_nama,
								trxsub_nama,
								trx_jenis,
								trx_jenis_sub,
								klp_pengali
						from	(
									select		dp.jml_trxpersediaan as qty, 
												dp.bulan as bulan,
												dp.depo_nama as nama_depo,
												dp.depo_kode as kode_depo,
												dp.katalog_id as id_katalog,
												dp.katalog_kode as kode_barang,
												dp.katalog_nama as nama_barang,
												dp.trx_nama as trx_nama,
												dp.trxsub_nama as trxsub_nama,
												dp.trx_jenis as trx_jenis,
												dp.trx_jenis_sub as trx_jenis_sub,
												mp.klp_pengali as klp_pengali,
												mp.klp_kolomupd_depo as klp_kolomupd_depo,
												dp.depo_kode as depo_kode
										from	rsfPelaporan.dlap_persediaan dp,
												rsfPelaporan.mlap_persediaan mp
										where	dp.katalog_id 			 	 = vKodeJenis and
												dp.depo_kode 				 = vKodeDepo and
												dp.trx_jenis 			 	 = mp.trx_jenis and
												dp.trx_jenis_sub 		 	 = mp.trx_jenis_sub and
												mp.klp_kolomupd_depo 		 = sJenisTrx and
												dp.bulan 					 = sBulan
								) subquery;
				END IF;
			ELSE
				IF (vKodeDepo = '') THEN
					select		concat('', sJenisTrx, ' === ', (nama_barang)) as judul1,
								concat('') as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								bulan as tahunbulan,
								nama_depo,
								vKodeDepo as kode_depo,
								id_katalog, 
								kode_barang, 
								nama_barang, 
								qty,
								trx_nama,
								trxsub_nama,
								trx_jenis,
								trx_jenis_sub,
								klp_pengali
						from	(
									select		sum(dp.jml_trxpersediaan) as qty, 
												max(dp.bulan) as bulan,
												max(dp.depo_nama) as nama_depo,
												max(dp.depo_kode) as kode_depo,
												max(dp.katalog_id) as id_katalog,
												max(dp.katalog_kode) as kode_barang,
												max(dp.katalog_nama) as nama_barang,
												max(dp.trx_nama) as trx_nama,
												max(dp.trxsub_nama) as trxsub_nama,
												max(dp.trx_jenis) as trx_jenis,
												max(dp.trx_jenis_sub) as trx_jenis_sub,
												max(mp.klp_pengali) as klp_pengali,
												max(mp.klp_kolomupd_depo) as klp_kolomupd_depo,
												max(dp.depo_kode) as depo_kode
										from	rsfPelaporan.dlap_persediaan dp,
												rsfPelaporan.mlap_persediaan mp
										where	dp.katalog_id 			 	 = vKodeJenis and
												dp.trx_jenis 			 	 = mp.trx_jenis and
												dp.trx_jenis_sub 		 	 = mp.trx_jenis_sub and
												mp.klp_kolomupd_depo 		 = sJenisTrx 
										group   by dp.bulan, dp.trx_jenis, dp.trx_jenis_sub, dp.katalog_id
								) subquery;
				ELSE
					select		concat('', sJenisTrx, ' === ', (nama_barang), ' === ', nama_depo) as judul1,
								concat('') as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								bulan as tahunbulan,
								nama_depo,
								vKodeDepo as kode_depo,
								id_katalog, 
								kode_barang, 
								nama_barang, 
								qty,
								trx_nama,
								trxsub_nama,
								trx_jenis,
								trx_jenis_sub,
								klp_pengali
						from	(
									select		dp.jml_trxpersediaan as qty, 
												dp.bulan,
												dp.depo_nama as nama_depo,
												dp.depo_kode as kode_depo,
												dp.katalog_id as id_katalog,
												dp.katalog_kode as kode_barang,
												dp.katalog_nama as nama_barang,
												dp.trx_nama,
												dp.trxsub_nama,
												dp.trx_jenis,
												dp.trx_jenis_sub,
												mp.klp_pengali,
												mp.klp_kolomupd_depo,
												dp.depo_kode 
										from	rsfPelaporan.dlap_persediaan dp,
												rsfPelaporan.mlap_persediaan mp
										where	dp.katalog_id 			 	 = vKodeJenis and
												dp.depo_kode 				 = vKodeDepo and
												dp.trx_jenis 			 	 = mp.trx_jenis and
												dp.trx_jenis_sub 		 	 = mp.trx_jenis_sub and
												mp.klp_kolomupd_depo 		 = sJenisTrx 
								) subquery;
				END IF;
			END IF;
		ELSEIF (vMethod = "hdrTriwulanJenisKatalogDepoTrx") THEN
			SET vKodeJenis 		= JSON_EXTRACT(aParam,'$[0].id_katalog');
			SET vKodeJenis 		= REPLACE(vKodeJenis,'"','');
			SET vKodeDepo  		= JSON_EXTRACT(aParam,'$[0].kode_depo');
			SET vKodeDepo  		= REPLACE(vKodeDepo,'"','');
			SET sBulan	   		= concat(cast(vTahun as char), RIGHT(concat('00', cast(vBulan as char)),2));
			SET sBulan3	   		= concat(cast(vTahun as char), RIGHT(concat('00', cast(vBulan3 as char)),2));
			SET sJenisTrx  		= 'jumlah_penjualan';
			SET sJenisTrx  		= JSON_EXTRACT(aParam,'$[0].jenis_kolom');
			SET sJenisTrx  		= REPLACE(sJenisTrx ,'"','');
			SET sBulan 	   		= REPLACE(JSON_EXTRACT(aParam,'$[0].tahunbulan'),'"','');
			-- SET sBulan     		= REPLACE(sBulan,'"','');
			SET vTrxJenis  		= JSON_EXTRACT(aParam,'$[0].trx_jenis');
			SET vTrxJenisSub	= JSON_EXTRACT(aParam,'$[0].trx_jenis_sub');

			IF (vType = 1) THEN
				SET vJudulTriwulan = 'triwulan';
				SET vTanggalAwal   = STR_TO_DATE(concat(sBulan,'01'), '%Y%m%d');
				SET vTanggalAkhir  = DATE_ADD(STR_TO_DATE(concat(sBulan,'01'), '%Y%m%d'), INTERVAL 3 MONTH);
				SET sTriwulan      = vTriwulan;
			ELSEIF (vType = 2) THEN
				SET vJudulTriwulan = 'bulan';
				SET vTanggalAwal   = STR_TO_DATE(concat(sBulan,'01'), '%Y%m%d');
				SET vTanggalAkhir  = DATE_ADD(STR_TO_DATE(concat(sBulan,'01'), '%Y%m%d'), INTERVAL 1 MONTH);
				SET sTriwulan      = substring(sBulan,5,2);
			ELSE
				SET vJudulTriwulan = 'bulan';
				SET vTanggalAwal   = STR_TO_DATE(concat('200001','01'), '%Y%m%d');
				SET vTanggalAkhir  = DATE_ADD(STR_TO_DATE(concat('204001','01'), '%Y%m%d'), INTERVAL 1 MONTH);
				SET vTanggalAwal   = STR_TO_DATE(concat(sBulan,'01'), '%Y%m%d');
				SET vTanggalAkhir  = DATE_ADD(STR_TO_DATE(concat(sBulan,'01'), '%Y%m%d'), INTERVAL 1 MONTH);
				SET sTriwulan      = substring(sBulan,5,2);
			END IF;
			
			IF (vTrxJenis = 54) THEN
				IF (vType = 3) THEN
					select		concat(jts.DESKRIPSI, ' === ', (b.NAMA)) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								tk.ID as trxid,
								DATE_FORMAT(tk.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								CONCAT( (case when (mp.klp_kolomupd_depo = sJenisTrx) then '' else '* ' end), masref.DESKRIPSI,' --> ',tk.KET) as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((tk.TANGGAL),'%Y%m') as tahunbulan,
								'' as kode_depo,
								(jts.ID) as trx_jenis,
								(masref.ID) as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as nama_depo,
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
								on masref.ID = tk.ALASAN
								left outer join rsfPelaporan.mlap_persediaan mp
								on  mp.trx_jenis		 = 54 AND
									mp.trx_jenis_sub	 = masref.ID,
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
								tk.TANGGAL 			>= vTanggalAwal and 
								tk.TANGGAL  		 < vTanggalAkhir and
								tkd.BARANG			 = cast(vKodeJenis as unsigned);
				ELSE
					select		concat(jts.DESKRIPSI, ' === ', (b.NAMA), ' === ', r.deskripsi) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								tk.ID as trxid,
								DATE_FORMAT(tk.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								CONCAT( (case when (mp.klp_kolomupd_depo = sJenisTrx) then '' else '* ' end), masref.DESKRIPSI,' --> ',tk.KET) as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((tk.TANGGAL),'%Y%m') as tahunbulan,
								(br.RUANGAN) as kode_depo,
								(jts.ID) as trx_jenis,
								(masref.ID) as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as nama_depo,
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
								on masref.ID = tk.ALASAN
								left outer join rsfPelaporan.mlap_persediaan mp
								on  mp.trx_jenis		 = 54 AND
									mp.trx_jenis_sub	 = masref.ID,
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
								tk.TANGGAL 			>= vTanggalAwal and 
								tk.TANGGAL  		 < vTanggalAkhir and
								tkd.BARANG			 = cast(vKodeJenis as unsigned) AND
								tk.RUANGAN 			 = vKodeDepo;
				END IF;
			ELSEIF (vTrxJenis = 53) THEN
				IF (vType = 3) THEN
					select		concat(jts.DESKRIPSI, ' === ', (b.NAMA)) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								tk.ID as trxid,
								DATE_FORMAT(tk.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								CONCAT( (case when (mp.klp_kolomupd_depo = sJenisTrx) then '' else '* ' end), masref.DESKRIPSI,' --> ',tk.KET) as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((tk.TANGGAL),'%Y%m') as tahunbulan,
								'' as kode_depo,
								(jts.ID) as trx_jenis,
								(masref.ID) as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as nama_depo,
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
								on masref.ID = tk.ALASAN
								left outer join rsfPelaporan.mlap_persediaan mp
								on  mp.trx_jenis		 = 53 AND
									mp.trx_jenis_sub	 = masref.ID,
								inventory.transaksi_koreksi_detil tkd,
								inventory.kategori k,
								inventory.barang b,
								inventory.barang_ruangan br,
								inventory.jenis_transaksi_stok jts,
								master.ruangan r
						where	tk.id 				 = tkd.KOREKSI and
								tkd.BARANG 			 = b.ID and
								b.KATEGORI 			 = k.ID and
								br.RUANGAN  		 = tk.RUANGAN and
								br.BARANG   		 = tkd.BARANG and
								r.id 				 = br.ruangan AND
								jts.ID				 = 53 AND
								tk.JENIS 			 = 1 AND
								tk.STATUS   		 = 2 and 
								tk.TANGGAL 			>= vTanggalAwal and 
								tk.TANGGAL  		 < vTanggalAkhir and
								tkd.BARANG			 = cast(vKodeJenis as unsigned); 
				ELSE
					select		concat(jts.DESKRIPSI, ' === ', (b.NAMA), ' === ', r.deskripsi) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								tk.ID as trxid,
								DATE_FORMAT(tk.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								CONCAT( (case when (mp.klp_kolomupd_depo = sJenisTrx) then '' else '* ' end), masref.DESKRIPSI,' --> ',tk.KET) as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((tk.TANGGAL),'%Y%m') as tahunbulan,
								(br.RUANGAN) as kode_depo,
								(jts.ID) as trx_jenis,
								(masref.ID) as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as nama_depo,
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
								on masref.ID = tk.ALASAN
								left outer join rsfPelaporan.mlap_persediaan mp
								on  mp.trx_jenis		 = 53 AND
									mp.trx_jenis_sub	 = masref.ID,
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
								tk.TANGGAL 			>= vTanggalAwal and 
								tk.TANGGAL  		 < vTanggalAkhir and
								tkd.BARANG			 = cast(vKodeJenis as unsigned) AND
								tk.RUANGAN 			 = vKodeDepo;
				END IF;
			ELSEIF (vTrxJenis = 23) THEN
				IF (vType = 3) THEN
					select 		concat(jts.DESKRIPSI, ' === ', (b.NAMA)) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								p.NOMOR as trxid,
								DATE_FORMAT(p.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								concat(rtuj.deskripsi, ' (', case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 'ruang farmasi' else 'ruang non farmasi' end,')') as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((p.TANGGAL),'%Y%m') as tahunbulan,
								'' as kode_depo,
								(r.deskripsi) as nama_depo,
								
								DATE_FORMAT((p.TANGGAL),'%Y%m') as bulan,
								(br.RUANGAN) as depo_kode,
								(jts.ID) as trx_jenis,
								(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 1 else 2 end)  as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as depo_nama,
								(jts.DESKRIPSI) as trx_nama,
								(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
								(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 'ruang farmasi' else 'ruang non farmasi' end)  as trxsub_nama,
								(b.KATEGORI) as kateg_kode,
								(k.NAMA) as kateg_nama,
								COALESCE((b.kode_barang),'-') as katalog_kode,
								(b.NAMA) as katalog_nama,				
								(1) as jml_rowtrxpersediaan,
								COALESCE((pd.JUMLAH), 0) as jml_trxpersediaan,
								(COALESCE(
									( 
										select 	SUM(1) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 23 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_rowtrxruangan,
								(COALESCE(
									( 
										select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 23 THEN 1 ELSE -1 END)) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 23 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_trxruangan
						from 	inventory.penerimaan p, 
								inventory.pengiriman pg
								left outer join master.ruangan rtuj
								on pg.TUJUAN = rtuj.id,
								inventory.pengiriman_detil pd,
								inventory.permintaan_detil pmd,
								inventory.kategori k,
								inventory.barang b,
								inventory.barang_ruangan br,
								master.ruangan r,
								inventory.jenis_transaksi_stok jts
						where	p.REF 				 = pd.PENGIRIMAN and
								pmd.ID			 	 = pd.PERMINTAAN_BARANG_DETIL and
								pg.NOMOR			 = pd.PENGIRIMAN and
								br.BARANG 	 		 = b.ID and
								b.KATEGORI 			 = k.ID and
								br.RUANGAN  		 = pg.ASAL and
								br.BARANG   		 = pmd.BARANG and
								r.id 				 = br.ruangan AND
								jts.ID				 = 23 AND
								p.JENIS     	 	 = 2 and 
								p.TANGGAL 			>= vTanggalAwal and 
								p.TANGGAL  		 	 < vTanggalAkhir and
								br.BARANG			 = cast(vKodeJenis as unsigned);
				ELSE
					select 		concat(jts.DESKRIPSI, ' === ', (b.NAMA), ' === ', r.deskripsi) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								p.NOMOR as trxid,
								DATE_FORMAT(p.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								concat(rtuj.deskripsi, ' (', case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 'ruang farmasi' else 'ruang non farmasi' end,')') as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((p.TANGGAL),'%Y%m') as tahunbulan,
								(br.RUANGAN) as kode_depo,
								(r.deskripsi) as nama_depo,
								
								DATE_FORMAT((p.TANGGAL),'%Y%m') as bulan,
								(br.RUANGAN) as depo_kode,
								(jts.ID) as trx_jenis,
								(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 1 else 2 end)  as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as depo_nama,
								(jts.DESKRIPSI) as trx_nama,
								(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
								(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 'ruang farmasi' else 'ruang non farmasi' end)  as trxsub_nama,
								(b.KATEGORI) as kateg_kode,
								(k.NAMA) as kateg_nama,
								COALESCE((b.kode_barang),'-') as katalog_kode,
								(b.NAMA) as katalog_nama,				
								(1) as jml_rowtrxpersediaan,
								COALESCE((pd.JUMLAH), 0) as jml_trxpersediaan,
								(COALESCE(
									( 
										select 	SUM(1) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 23 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_rowtrxruangan,
								(COALESCE(
									( 
										select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 23 THEN 1 ELSE -1 END)) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 23 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_trxruangan
						from 	inventory.penerimaan p, 
								inventory.pengiriman pg
								left outer join master.ruangan rtuj
								on pg.TUJUAN = rtuj.id,
								inventory.pengiriman_detil pd,
								inventory.permintaan_detil pmd,
								inventory.kategori k,
								inventory.barang b,
								inventory.barang_ruangan br,
								master.ruangan r,
								inventory.jenis_transaksi_stok jts
						where	p.REF 				 = pd.PENGIRIMAN and
								pmd.ID			 	 = pd.PERMINTAAN_BARANG_DETIL and
								pg.NOMOR			 = pd.PENGIRIMAN and
								br.BARANG 	 		 = b.ID and
								b.KATEGORI 			 = k.ID and
								br.RUANGAN  		 = pg.ASAL and
								br.BARANG   		 = pmd.BARANG and
								r.id 				 = br.ruangan AND
								jts.ID				 = 23 AND
								p.JENIS     	 	 = 2 and 
								p.TANGGAL 			>= vTanggalAwal and 
								p.TANGGAL  		 	 < vTanggalAkhir and
								br.BARANG			 = cast(vKodeJenis as unsigned) AND
								br.RUANGAN 			 = vKodeDepo;
				END IF;
			ELSEIF (vTrxJenis = 20) THEN
				IF (vType = 3) THEN
					select 		concat(jts.DESKRIPSI, ' === ', (b.NAMA)) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								p.NOMOR as trxid,
								DATE_FORMAT(p.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								concat(rtuj.deskripsi, ' (', case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 'ruang farmasi' else 'ruang non farmasi' end,')') as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((p.TANGGAL),'%Y%m') as tahunbulan,
								'' as kode_depo,
								(r.deskripsi) as nama_depo,
								
								DATE_FORMAT((p.TANGGAL),'%Y%m') as bulan,
								(br.RUANGAN) as depo_kode,
								(jts.ID) as trx_jenis,
								(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 1 else 2 end)  as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as depo_nama,
								(jts.DESKRIPSI) as trx_nama,
								(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
								(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 'ruang farmasi' else 'ruang non farmasi' end)  as trxsub_nama,
								(b.KATEGORI) as kateg_kode,
								(k.NAMA) as kateg_nama,
								COALESCE((b.kode_barang),'-') as katalog_kode,
								(b.NAMA) as katalog_nama,				
								(1) as jml_rowtrxpersediaan,
								COALESCE((pd.JUMLAH), 0) as jml_trxpersediaan,
								(COALESCE(
									( 
										select 	SUM(1) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 20 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_rowtrxruangan,
								(COALESCE(
									( 
										select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 20 THEN 1 ELSE -1 END)) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 20 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_trxruangan
						from 	inventory.penerimaan p, 
								inventory.pengiriman pg
								left outer join master.ruangan rtuj
								on pg.ASAL = rtuj.id,
								inventory.pengiriman_detil pd,
								inventory.permintaan_detil pmd,
								inventory.kategori k,
								inventory.barang b,
								inventory.barang_ruangan br,
								master.ruangan r,
								inventory.jenis_transaksi_stok jts
						where	p.REF 				 = pd.PENGIRIMAN and
								pmd.ID			 	 = pd.PERMINTAAN_BARANG_DETIL and
								pg.NOMOR			 = pd.PENGIRIMAN and
								br.BARANG 	 		 = b.ID and
								b.KATEGORI 			 = k.ID and
								br.RUANGAN  		 = pg.TUJUAN and
								br.BARANG   		 = pmd.BARANG and
								r.id 				 = br.ruangan AND
								jts.ID				 = 20 AND
								p.JENIS     	 	 = 2 and 
								p.TANGGAL 			>= vTanggalAwal and 
								p.TANGGAL  		 	 < vTanggalAkhir and
								br.BARANG			 = cast(vKodeJenis as unsigned);
				ELSE
					select 		concat(jts.DESKRIPSI, ' === ', (b.NAMA), ' === ', r.deskripsi) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								p.NOMOR as trxid,
								DATE_FORMAT(p.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								concat(rtuj.deskripsi, ' (', case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 'ruang farmasi' else 'ruang non farmasi' end,')') as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((p.TANGGAL),'%Y%m') as tahunbulan,
								(br.RUANGAN) as kode_depo,
								(r.deskripsi) as nama_depo,
								
								DATE_FORMAT((p.TANGGAL),'%Y%m') as bulan,
								(br.RUANGAN) as depo_kode,
								(jts.ID) as trx_jenis,
								(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 1 else 2 end)  as trx_jenis_sub,
								(br.BARANG) as katalog_id,
								(r.deskripsi) as depo_nama,
								(jts.DESKRIPSI) as trx_nama,
								(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
								(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 'ruang farmasi' else 'ruang non farmasi' end)  as trxsub_nama,
								(b.KATEGORI) as kateg_kode,
								(k.NAMA) as kateg_nama,
								COALESCE((b.kode_barang),'-') as katalog_kode,
								(b.NAMA) as katalog_nama,				
								(1) as jml_rowtrxpersediaan,
								COALESCE((pd.JUMLAH), 0) as jml_trxpersediaan,
								(COALESCE(
									( 
										select 	SUM(1) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 20 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_rowtrxruangan,
								(COALESCE(
									( 
										select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 20 THEN 1 ELSE -1 END)) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= pd.ID and 
												tsr.JENIS 				= 20 and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_trxruangan
						from 	inventory.penerimaan p, 
								inventory.pengiriman pg
								left outer join master.ruangan rtuj
								on pg.ASAL = rtuj.id,
								inventory.pengiriman_detil pd,
								inventory.permintaan_detil pmd,
								inventory.kategori k,
								inventory.barang b,
								inventory.barang_ruangan br,
								master.ruangan r,
								inventory.jenis_transaksi_stok jts
						where	p.REF 				 = pd.PENGIRIMAN and
								pmd.ID			 	 = pd.PERMINTAAN_BARANG_DETIL and
								pg.NOMOR			 = pd.PENGIRIMAN and
								br.BARANG 	 		 = b.ID and
								b.KATEGORI 			 = k.ID and
								br.RUANGAN  		 = pg.TUJUAN and
								br.BARANG   		 = pmd.BARANG and
								r.id 				 = br.ruangan AND
								jts.ID				 = 20 AND
								p.JENIS     	 	 = 2 and 
								p.TANGGAL 			>= vTanggalAwal and 
								p.TANGGAL  		 	 < vTanggalAkhir and
								br.BARANG			 = cast(vKodeJenis as unsigned) AND
								br.RUANGAN 			 = vKodeDepo;
				END IF;
			ELSEIF ((vTrxJenis = 33) or (vTrxJenis = 33) or (vTrxJenis = 35)) THEN
				IF (vType = 3) THEN
					select 		concat(jts.DESKRIPSI, ' === ', (mbarang.NAMA)) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								inventory.transaksi_stok_ruangan.id as trxid,
								DATE_FORMAT(transaksi_stok_ruangan.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								concat('kunjungan : ', dft_k.NOMOR, ', norm : ' ,mst_p.NORM, ' a/n ', mst_p.NAMA) as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((transaksi_stok_ruangan.TANGGAL),'%Y%m') as tahunbulan,
								'' as kode_depo,
								(master.ruangan.deskripsi) as nama_depo,
								DATE_FORMAT((transaksi_stok_ruangan.TANGGAL),'%Y%m') as bulan,
								(inventory.barang_ruangan.ruangan) as depo_kode,
								(transaksi_stok_ruangan.jenis) as trx_jenis,
								0 as trx_jenis_sub,
								(inventory.barang_ruangan.BARANG) as katalog_id,
								(master.ruangan.deskripsi) as depo_nama,
								(jenis_transaksi_stok.deskripsi) as trx_nama,
								(jenis_transaksi_stok.tambah_atau_kurang) as trx_tambahkurang,
								'-- non sub --' as trxsub_nama,
								(mbarang.KATEGORI) as kateg_kode,
								(mkategori.NAMA) as kateg_nama,
								(COALESCE(mbarang.kode_barang,'-')) as katalog_kode,
								(mbarang.NAMA) as katalog_nama,
								(transaksi_stok_ruangan.jumlah) as jml_trxpersediaan,
								(1) as jml_rowtrxruangan,
								(transaksi_stok_ruangan.jumlah) as jml_trxruangan
						FROM	inventory.transaksi_stok_ruangan,
								inventory.barang_ruangan,
								inventory.jenis_transaksi_stok,
								inventory.barang mbarang,
								inventory.kategori mkategori,
								inventory.jenis_transaksi_stok jts,
								master.ruangan,
								layanan.order_detil_resep lyn_odr,
								layanan.order_resep lyn_or,
								pendaftaran.kunjungan dft_k,
								pendaftaran.pendaftaran dft_p,
								master.pasien mst_p
						WHERE	transaksi_stok_ruangan.barang_ruangan 	= barang_ruangan.id AND
								transaksi_stok_ruangan.jenis 			= jenis_transaksi_stok.id AND
								jts.ID				 					= transaksi_stok_ruangan.jenis AND
								jts.ID				 					= vTrxJenis AND
								master.ruangan.id 						= inventory.barang_ruangan.ruangan AND
								mbarang.id 								= inventory.barang_ruangan.BARANG AND
								mkategori.ID 							= mbarang.KATEGORI AND
								transaksi_stok_ruangan.TANGGAL 		   >= vTanggalAwal and 
								transaksi_stok_ruangan.TANGGAL  		< vTanggalAkhir and
								inventory.barang_ruangan.BARANG			= cast(vKodeJenis as unsigned) and
								lyn_odr.ref = transaksi_stok_ruangan.ref and
								lyn_odr.ORDER_ID = lyn_or.NOMOR and
								lyn_or.KUNJUNGAN = dft_k.NOMOR and
								dft_k.NOPEN = dft_p.NOMOR and
								dft_p.NORM = mst_p.NORM;
				ELSE
					select 		concat(jts.DESKRIPSI, ' === ', (mbarang.NAMA)) as judul1,
								concat('tahun ', vTahun, ' ', vJudulTriwulan, ' ', sTriwulan) as judul2,
								vTahun as tahun,
								vTriwulan as triwulan,
								vType as type,
								vKodeJenis as id, 
								sJenisTrx as jenis_kolom,
								inventory.transaksi_stok_ruangan.id as trxid,
								DATE_FORMAT(transaksi_stok_ruangan.TANGGAL, '%d-%m-%Y %H:%i') as tanggal,
								concat('kunjungan : ', dft_k.NOMOR, ', norm : ' ,mst_p.NORM, ' a/n ', mst_p.NAMA) as ket,
								sJenisTrx as jenis_kolom,
								DATE_FORMAT((transaksi_stok_ruangan.TANGGAL),'%Y%m') as tahunbulan,
								(inventory.barang_ruangan.ruangan) as kode_depo,
								(master.ruangan.deskripsi) as nama_depo,
								DATE_FORMAT((transaksi_stok_ruangan.TANGGAL),'%Y%m') as bulan,
								(inventory.barang_ruangan.ruangan) as depo_kode,
								(transaksi_stok_ruangan.jenis) as trx_jenis,
								0 as trx_jenis_sub,
								(inventory.barang_ruangan.BARANG) as katalog_id,
								(master.ruangan.deskripsi) as depo_nama,
								(jenis_transaksi_stok.deskripsi) as trx_nama,
								(jenis_transaksi_stok.tambah_atau_kurang) as trx_tambahkurang,
								'-- non sub --' as trxsub_nama,
								(mbarang.KATEGORI) as kateg_kode,
								(mkategori.NAMA) as kateg_nama,
								(COALESCE(mbarang.kode_barang,'-')) as katalog_kode,
								(mbarang.NAMA) as katalog_nama,
								(transaksi_stok_ruangan.jumlah) as jml_trxpersediaan,
								(1) as jml_rowtrxruangan,
								(transaksi_stok_ruangan.jumlah) as jml_trxruangan
						FROM	inventory.transaksi_stok_ruangan,
								inventory.barang_ruangan,
								inventory.jenis_transaksi_stok,
								inventory.barang mbarang,
								inventory.kategori mkategori,
								inventory.jenis_transaksi_stok jts,
								master.ruangan,
								layanan.order_detil_resep lyn_odr,
								layanan.order_resep lyn_or,
								pendaftaran.kunjungan dft_k,
								pendaftaran.pendaftaran dft_p,
								master.pasien mst_p
						WHERE	transaksi_stok_ruangan.barang_ruangan 	= barang_ruangan.id AND
								transaksi_stok_ruangan.jenis 			= jenis_transaksi_stok.id AND
								jts.ID				 					= transaksi_stok_ruangan.jenis AND
								jts.ID				 					= vTrxJenis AND
								master.ruangan.id 						= inventory.barang_ruangan.ruangan AND
								mbarang.id 								= inventory.barang_ruangan.BARANG AND
								mkategori.ID 							= mbarang.KATEGORI AND
								transaksi_stok_ruangan.TANGGAL 		   >= vTanggalAwal and 
								transaksi_stok_ruangan.TANGGAL  		< vTanggalAkhir and
								inventory.barang_ruangan.BARANG			= cast(vKodeJenis as unsigned) and
								inventory.barang_ruangan.RUANGAN 		= vKodeDepo and
								lyn_odr.ref = transaksi_stok_ruangan.ref and
								lyn_odr.ORDER_ID = lyn_or.NOMOR and
								lyn_or.KUNJUNGAN = dft_k.NOMOR and
								dft_k.NOPEN = dft_p.NOMOR and
								dft_p.NORM = mst_p.NORM;
				END IF;
			ELSE
				SET vErrorMsg = CONCAT('Jenis Transaksi belum didefinisikan.', '');
				SIGNAL SQLSTATE '31001'
				SET MESSAGE_TEXT = vErrorMsg;
			END IF;
		ELSEIF (vMethod = "hdrTriwulan") THEN
			IF (vType = 1) THEN
				select		'Laporan Persediaan per Kelompok Barang' as judul1,
							concat('tahun ', vTahun, ' triwulan ', vTriwulan) as judul2,
							vTahun as tahun,
							vTriwulan as triwulan,
							vType as type,
							'' as nama_depo,
							max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
							max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
							max(kode_jenis) as kode_jenis,
							'' as id,
							max(kode_jenis) as kode,
							max(nama_jenis) as nama,
							format(sum(aw),0) as aw, 
							'' as mmasuk,
							'' as mkeluar,
							format(sum(beli),0) as beli, format(sum(prod),0) as prod,
							format(sum(jual),0) as jual, format(sum(bahan),0) as bahan, 
							format(sum(floors),0) as floors, format(sum(expr),0) as expr,
							format(sum(akhir),0) as akhir, format(sum(opname),0) as opname
					from	(
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan
									where	tahun = vTahun and 
											bulan = vBulan
								UNION ALL
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											0 as akhir, 0 as opname
									from 	rsfPelaporan.laporan_mutasi_bulan lmb
									where	lmb.tahun = vTahun and 
											lmb.bulan = vBulan2
								UNION ALL
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											0 as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan lmb
									where	lmb.tahun = vTahun and 
											lmb.bulan = vBulan3
							) subquery
					group   by kode_jenis
					order	by nama_jenis;
			ELSE
				select		'Laporan Persediaan per Kelompok Barang' as judul1,
							concat('tahun ', vTahun, ' bulan ', bulan) as judul2,
							vTahun as tahun,
							vTriwulan as triwulan,
							vType as type,
							'' as nama_depo,
							max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
							max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
							max(kode_jenis) as kode_jenis,
							'' as id,
							max(kode_jenis) as kode,
							max(nama_jenis) as nama,
							format(sum(aw),0) as aw, 
							'' as mmasuk,
							'' as mkeluar,
							format(sum(beli),0) as beli, format(sum(prod),0) as prod,
							format(sum(jual),0) as jual, format(sum(bahan),0) as bahan, 
							format(sum(floors),0) as floors, format(sum(expr),0) as expr,
							format(sum(akhir),0) as akhir, format(sum(opname),0) as opname
					from	(
								select 		'--- Rumah Sakit ---' as nama_depo, 
											bulan, id_katalog, kode_barang, nama_barang,
											kode_jenis,
											nama_jenis,
											jumlah_awal as aw, 
											0 as mmasuk,
											0 as mkeluar,
											jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
											jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
											jumlah_akhir as akhir, jumlah_opname as opname
									from 	rsfPelaporan.laporan_mutasi_bulan
									where	tahun = vTahun and 
											bulan = vBulan
							) subquery
					group   by kode_jenis
					order	by nama_jenis;
			END IF;
		ELSEIF (vMethod = "kasusMinus") THEN
			select 		'Monitoring Barang Depo' as judul1,
						concat('') as judul2,
						id_depo as kode_depo, (nama_depo) as nama_depo, tahun, bulan,
						2 as type,
						(select 	count(1) 
							from 	rsfPelaporan.laporan_mutasi_bulan_depo subs
							where 	subs.bulan   		= lmbd.bulan and
									subs.tahun   		= lmbd.tahun and
									subs.id_depo 		= lmbd.id_depo and
									subs.jumlah_akhir 	< 0  ) as jmlminus, 
						(select 	count(1) 
							from 	rsfPelaporan.laporan_mutasi_bulan_depo subs
							where 	subs.bulan   		= lmbd.bulan and
									subs.tahun   		= lmbd.tahun and
									subs.id_depo 		= lmbd.id_depo ) as jmlbarang
				from 	( select 	id_depo, nama_depo, tahun, bulan
							from 	rsfPelaporan.laporan_mutasi_bulan_depo
							where 	substring(id_depo,1,5) = '10103' and length(id_depo) = 9
							group	by id_depo, nama_depo, tahun, bulan 
							order	by tahun desc, bulan desc, id_depo, nama_depo
						) lmbd ;
		ELSEIF (vMethod = "kasusMinusDepo") THEN
			SET vKodeDepo  		= JSON_EXTRACT(aParam,'$[0].kode_depo');
			SET vKodeDepo  		= REPLACE(vKodeDepo,'"','');
			select		concat('Daftar Barang dengan Jml Akhir minus ', max(nama_depo)) as judul1,
						concat('tahun ', vTahun, ' bulan ', max(bulan)) as judul2,
						vTahun as tahun,
						bulan as triwulan,
						2 as type,
						max(nama_depo) as nama_depo,
						max(kode_depo) as kode_depo,
						max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
						max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
						max(kode_jenis) as kode_jenis,
						max(id_katalog) as id,
						max(kode_barang) as kode,
						max(nama_barang) as nama,
						sum(aw) as aw, 
						sum(mmasuk) as mmasuk,
						sum(mkeluar) as mkeluar,
						sum(beli) as beli, sum(prod) as prod,
						sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
						sum(akhir) as akhir, sum(opname) as opname
				from	(
							select 		nama_depo as nama_depo, 
										id_depo as kode_depo,
										bulan, id_katalog, kode_barang, nama_barang,
										kode_jenis,
										nama_jenis,
										jumlah_awal as aw, 
										jumlah_mutasimasuk as mmasuk,
										jumlah_mutasikeluar as mkeluar,
										jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
										jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
										jumlah_akhir as akhir, jumlah_opname as opname
								from 	rsfPelaporan.laporan_mutasi_bulan_depo
								where	tahun = vTahun and 
										bulan = vBulan and
										id_depo = vKodeDepo and
										jumlah_akhir < 0
						) subquery
				group   by id_katalog, nama_depo
				order	by nama_jenis, kode_barang, id_katalog, nama_depo;
		ELSEIF (vMethod = "monitorDepo") THEN
			SET vKodeDepo  		= JSON_EXTRACT(aParam,'$[0].kode_depo');
			SET vKodeDepo  		= REPLACE(vKodeDepo,'"','');
			select		concat('Daftar Barang dengan Jml Akhir minus ', max(nama_depo)) as judul1,
						concat('tahun ', vTahun, ' bulan ', max(bulan)) as judul2,
						vTahun as tahun,
						bulan as triwulan,
						2 as type,
						max(nama_depo) as nama_depo,
						max(kode_depo) as kode_depo,
						max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
						max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
						max(kode_jenis) as kode_jenis,
						max(id_katalog) as id,
						max(kode_barang) as kode,
						max(nama_barang) as nama,
						sum(aw) as aw, 
						sum(mmasuk) as mmasuk,
						sum(mkeluar) as mkeluar,
						sum(beli) as beli, sum(prod) as prod,
						sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
						sum(akhir) as akhir, sum(opname) as opname
				from	(
							select 		nama_depo as nama_depo, 
										id_depo as kode_depo,
										bulan, id_katalog, kode_barang, nama_barang,
										kode_jenis,
										nama_jenis,
										jumlah_awal as aw, 
										jumlah_mutasimasuk as mmasuk,
										jumlah_mutasikeluar as mkeluar,
										jumlah_pembelian as beli, jumlah_hasilproduksi as prod,
										jumlah_penjualan as jual, jumlah_bahanproduksi as bahan, jumlah_floorstok as floors, jumlah_expired as expr,
										jumlah_akhir as akhir, jumlah_opname as opname
								from 	rsfPelaporan.laporan_mutasi_bulan_depo
								where	tahun = vTahun and 
										bulan = vBulan and
										id_depo = vKodeDepo
						) subquery
				group   by id_katalog, nama_depo
				order	by nama_jenis, kode_barang, id_katalog, nama_depo;
		ELSEIF (vMethod = "monitorPersediaanMasterSettingKolom") THEN
			select		concat('Setting Mapping Kolom Transaksi') as judul1,
						concat('') as judul2,
						mlap_persediaan.*
				from	mlap_persediaan;
		ELSEIF (vMethod = "kasusKodebarang") THEN
			select		concat('Kasus Duplikasi Kode Katalog ') as judul1,
						concat('') as judul2,
						vTahun as tahun,
						bulan as triwulan,
						3 as type,
						max(nama_depo) as nama_depo,
						max(kode_depo) as kode_depo,
						max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, 
						max(nama_barang) as nama_barang, max(nama_jenis) as nama_jenis,
						max(kode_jenis) as kode_jenis,
						max(id_katalog) as id,
						max(kode_barang) as kode,
						max(nama_barang) as nama,
						sum(aw) as aw, 
						sum(mmasuk) as mmasuk,
						sum(mkeluar) as mkeluar,
						sum(beli) as beli, sum(prod) as prod,
						sum(jual) as jual, sum(bahan) as bahan, sum(floors) as floors, sum(expr) as expr,
						sum(akhir) as akhir, sum(opname) as opname
				from	(
							select 		'--- Rumah Sakit ---' as nama_depo,
										'' as kode_depo,
										max(bulan) as bulan, max(id_katalog) as id_katalog, max(kode_barang) as kode_barang, max(nama_barang) as nama_barang,
										max(kode_jenis) as kode_jenis,
										max(nama_jenis) as nama_jenis,
										sum(jumlah_awal) as aw, 
										sum(jumlah_mutasimasuk) as mmasuk,
										sum(jumlah_mutasikeluar) as mkeluar,
										sum(jumlah_pembelian) as beli, sum(jumlah_hasilproduksi) as prod,
										sum(jumlah_penjualan) as jual, sum(jumlah_bahanproduksi) as bahan, 
										sum(jumlah_floorstok) as floors, sum(jumlah_expired) as expr,
										sum(jumlah_akhir) as akhir, sum(jumlah_opname) as opname
								from 	rsfPelaporan.laporan_mutasi_bulan_depo lmb
								where	kode_barang in (
										select 		max(lmb.kode_barang)
											from 	rsfPelaporan.laporan_mutasi_bulan lmb
											where	lmb.tahun = vTahun and 
													lmb.bulan = vBulan
											group   by lmb.kode_barang
											having  count(1) > 1
										)
								group by id_katalog, kode_barang
								order by kode_barang
						) subquery
				group   by id_katalog, nama_depo
				order	by kode_barang, id_katalog, nama_depo;
		ELSE
			SET vErrorMsg = CONCAT('invalid method.', vMethod);
			SIGNAL SQLSTATE '30001'
			SET MESSAGE_TEXT = vErrorMsg;
		END IF;
	ELSE
		SIGNAL SQLSTATE '20001'
		SET MESSAGE_TEXT = 'invalid JSON parameter';
	END IF;
END //
DELIMITER ;
