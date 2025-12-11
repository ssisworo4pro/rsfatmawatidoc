-- update laporan_opname by rincian opname
-- 2596 row from 2757 row in stok_opname_detil
insert into rsfPelaporan.laporan_opnamehitung
			( 	tahun, bulan, nomor, katalog_kode, 
				jumlah_fisik, jumlah_fisik_hitung, nilai_hpokok, nilai_fisik,
				id_inventory )
select		2022 as tahun,
			12 as bulan,
			1 as nomor,
			max(b.KODE_BARANG) as katalog_kode,
			0 as jumlah_fisik,
			sum(sod.MANUAL) as jumlah_fisik_hitung,
			0 as nilai_hpokok,
			0 as nilai_fisik,
			max(b.ID) as id_inventory
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.barang b 
			left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
			on b.id		= mapKOpname.id_inventory
	where	so.id		= sod.STOK_OPNAME and
			so.RUANGAN  = r.id and
			sod.BARANG_RUANGAN = br.id and
			br.BARANG = b.ID and
			so.TANGGAL 	> '2022-12-16' and
			sod.MANUAL  != 0 and
			so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
							'101030102', -- Depo IRJ LT 2
							'101030103', -- Depo Griya Husada
							'101030104', -- Depo IGD
							'101030105', -- Depo OK CITO
							'101030106', -- Depo Anggrek
							'101030107', -- Depo Bougenville
							'101030108', -- Depo IBS
							'101030109', -- Depo Teratai
							'101030110', -- Depo Produksi
							'101030111', -- Gudang Farmasi
							'101030112', -- Depo IRJ LT 3
							'101030113', -- Depo UKVI
							'101030114', -- Gudang Expired
							'101030115', -- Gudang Gas Medis
							'101030116', -- Gudang Konsinyasi
							'101030117', -- Gudang Rusak
							'101030118', -- Depo Metadon
							'101030119') -- Gudang Reused 
	group	by b.ID;

-- Updated Rows	2590 from 2640 rows
UPDATE		rsfPelaporan.laporan_opnamehitung as upd,
			(
				select		id_inventory as katalog_id, 
							jumlah_fisik as qty_opname
					from	laporan_opname
					where	tahun       	= 2022 and
							bulan       	= 12 and
							jumlah_fisik 	> 0
			) as updReff
	SET		upd.jumlah_fisik			= updReff.qty_opname
	WHERE	upd.id_inventory			= updReff.katalog_id;

select 		max(katalog_kode) as katalog_kode, 
			max(katalog_kategori) as katalog_kategori, 
			max(katalog_nama) as katalog_nama, 
			max(katalog_pabrik) as katalog_pabrik,
			max(katalog_satuan) as katalog_satuan, 
			max(expired) as expired,
			sum(jumlah_fisik) as jumlah_fisik, 
			max(nilai_hpokok) as nilai_hpokok, 
			sum(jumlah_fisik) * max(nilai_hpokok) as nilai_fisik
	from 	laporan_opname 
	where	jumlah_fisik 	> 0 and
			tahun 			= 2022 and
			bulan			= 12
	group 	by katalog_kode;
	
select      sum(nilai_fisik), count(1) from (
select 		max(katalog_kode) as katalog_kode, 
			max(katalog_kategori) as katalog_kategori, 
			max(katalog_nama) as katalog_nama, 
			max(katalog_pabrik) as katalog_pabrik,
			max(katalog_satuan) as katalog_satuan, 
			max(expired) as expired,
			sum(jumlah_fisik) as jumlah_fisik, 
			max(nilai_hpokok) as nilai_hpokok, 
			sum(jumlah_fisik) * max(nilai_hpokok) as nilai_fisik
	from 	laporan_opname 
	where	jumlah_fisik 	> 0 and
			tahun 			= 2022 and
			bulan			= 12
	group 	by katalog_kode
) a

-- 27,975,308,804.92050000	2646
select		COALESCE(tblBatas.sts_triwulan1only,'') as triwulan1,
			tblOpname.katalog_kode,
			tblBatas.katalog_kode as katalog_kodes,
			tblOpname.katalog_nama,
			tblOpname.jumlah_fisik
	from	(	select 	max(katalog_kode) as katalog_kode,
						max(katalog_nama) as katalog_nama,
						sum(jumlah_fisik) as jumlah_fisik
				from 	laporan_opname
				where	jumlah_fisik 	> 0 and
						tahun 			= 2022 and
						bulan			= 12
				group 	by katalog_kode
			) tblOpname left outer join
			(	select 	katalog_kode, sts_triwulan1only
				from 	laporan_mutasi_saldo_simgos
			) tblBatas
			on tblBatas.katalog_kode = tblOpname.katalog_kode
	having	katalog_kodes is null or
			triwulan1 = 1;

alter table laporan_opname add katalog_kode_proses varchar(15) null;
alter table laporan_mutasi_saldo_simgos add katalog_kode_grp varchar(15) null;
update laporan_mutasi_saldo_simgos set katalog_kode_grp = katalog_kode where katalog_kode_grp  is null;


-- update katalog_kode_proses dan validasikan hasil prosesnya
UPDATE		rsfPelaporan.laporan_opname as upd,
			(		
				select		tblOpname.katalog_kode,
							tblOpname.jumlah_fisik
					from	(	select 	max(laporan_opname.katalog_kode) as katalog_kode,
										sum(laporan_opname.jumlah_fisik) as jumlah_fisik
								from 	laporan_opname
								where	laporan_opname.jumlah_fisik 	> 0 and
										laporan_opname.tahun 			= 2022 and
										laporan_opname.bulan			= 12
								group 	by laporan_opname.katalog_kode
							) tblOpname join
							(	select 	katalog_kode, sts_triwulan1only
								from 	laporan_mutasi_saldo_simgos
								where   sts_triwulan1only = 0
							) tblBatas
							on tblBatas.katalog_kode = tblOpname.katalog_kode
			) as updReff
	SET		upd.katalog_kode_proses		= updReff.katalog_kode
	WHERE	upd.katalog_kode			= updReff.katalog_kode;

-- validasikan dan harus sesuai daftar excel finalOpnameDiluarTrack.xlsx
select count(1) from laporan_opname
where katalog_kode_proses is null and jumlah_fisik > 0;

-- update dari excel finalOpnameDiluarTrack.xlsx
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10A314' WHERE katalog_kode = '10A095';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10H099.1' WHERE katalog_kode = '14H013';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40L062' WHERE katalog_kode = '40L004.1';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40C132' WHERE katalog_kode = '40S085';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80L100.1' WHERE katalog_kode = '42L645';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80A108' WHERE katalog_kode = '80A001.4';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80F224' WHERE katalog_kode = '80F138';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80I005' WHERE katalog_kode = '80I004';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80S353.1' WHERE katalog_kode = '80S124';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80N131' WHERE katalog_kode = '80N075';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80S301' WHERE katalog_kode = '80S172';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80T145' WHERE katalog_kode = '80T111';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80J001.024' WHERE katalog_kode = '80J001.016';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '22P153' WHERE katalog_kode = '80P207';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80O035' WHERE katalog_kode = '80O016.01x';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '42D201' WHERE katalog_kode = '42D201x';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80P210' WHERE katalog_kode = '80P233';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80C001.19' WHERE katalog_kode = '80C001.19x';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80F003' WHERE katalog_kode = '80F003x';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '80U050.1' WHERE katalog_kode = '82U001';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '50C036' WHERE katalog_kode = '50C004';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '50C037' WHERE katalog_kode = '50C005';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '22S092' WHERE katalog_kode = '22S088';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '70C038' WHERE katalog_kode = '70C047.11';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '70C047.18' WHERE katalog_kode = '70C047.10';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40D108' WHERE katalog_kode = '40D093';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40F063' WHERE katalog_kode = '40F046';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '33O452' WHERE katalog_kode = '40K014';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40O049' WHERE katalog_kode = '40O029';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40O052' WHERE katalog_kode = '40O013';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40P012.7' WHERE katalog_kode = '40P012.028';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40S101' WHERE katalog_kode = '40S004.1';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10F159' WHERE katalog_kode = '40F010';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40D030' WHERE katalog_kode = '40D060';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40N005' WHERE katalog_kode = '40N004';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40C018' WHERE katalog_kode = '40C110';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40N005' WHERE katalog_kode = '40N064';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40C140.1' WHERE katalog_kode = '40C116';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40L058' WHERE katalog_kode = '40L057';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40P012.033' WHERE katalog_kode = '40P012.6';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '40I102' WHERE katalog_kode = '40U102';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '81B182' WHERE katalog_kode = '81B018';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '81C327' WHERE katalog_kode = '81C236';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '12D026' WHERE katalog_kode = '12D024';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10K093' WHERE katalog_kode = '10C001.097';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10C001.25' WHERE katalog_kode = '10C001.056';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10M187' WHERE katalog_kode = '10M057.1';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10P237' WHERE katalog_kode = '10P048.3';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10C001.003' WHERE katalog_kode = '10C152';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10V132' WHERE katalog_kode = '10V039';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10G134' WHERE katalog_kode = '10G100';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10U038' WHERE katalog_kode = '40U012';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10P236' WHERE katalog_kode = '10P011';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10H007' WHERE katalog_kode = '10H095';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10D208' WHERE katalog_kode = '10D194';
UPDATE rsfPelaporan.laporan_opname SET katalog_kode_proses = '10C019' WHERE katalog_kode = '10C001.16';

-- update dari excel finalOpnameDiluarTrack.xlsx
-- FILE : finalLaporanOpnameQueryGRP.sql

-- update jumlah opname 4716 updated rows
update 		rsfPelaporan.laporan_mutasi_saldo_simgos
	set		jumlah_opname 		= 0;

-- Updated Rows	2585 from 2585 rows on laporan_opname
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 	2022 as tahun,
						max(laporan_opname.katalog_kode_proses) as katalog_kode,
						sum(laporan_opname.jumlah_fisik) as qty
				from 	laporan_opname
				where	laporan_opname.jumlah_fisik 			> 0 and
						laporan_opname.tahun 					= 2022 and
						laporan_opname.bulan					= 12 and 
						laporan_opname.katalog_kode_proses		is not null
				group 	by laporan_opname.katalog_kode_proses
			) updReff
	set		upd.jumlah_opname 		= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;


-- ############################################  PERHITUNGAN BARU (menggunakan jumlah opname hasil hitung dari stok_opname_detil
-- ############################################  PERHITUNGAN BARU (menggunakan jumlah opname hasil hitung dari stok_opname_detil
-- ############################################  PERHITUNGAN BARU (menggunakan jumlah opname hasil hitung dari stok_opname_detil
-- sebelumnya lakukan mmapping_koreksiopname, untuk transaksi opname di luar track
-- update jumlah Opname
-- 2680 rows updated from 2699 rows opname
-- cek dulu opname di luar track (masihn ada 17 rows, dengan total qty 82, ada 2 row minus)
select 		dlap.tahun, dlap.katalog_kode, dlap.qty
	from 	(	
				select 		2022 as tahun,
							max(katalog_kode) as katalog_kode, 
							max(katalog_id) as katalog_id, 
							max(katalog_nama) as katalog_nama, 
							sum(qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											so.TANGGAL 	> '2022-12-16' and
											sod.MANUAL  > 0 and
											so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
															'101030102', -- Depo IRJ LT 2
															'101030103', -- Depo Griya Husada
															'101030104', -- Depo IGD
															'101030105', -- Depo OK CITO
															'101030106', -- Depo Anggrek
															'101030107', -- Depo Bougenville
															'101030108', -- Depo IBS
															'101030109', -- Depo Teratai
															'101030110', -- Depo Produksi
															'101030111', -- Gudang Farmasi
															'101030112', -- Depo IRJ LT 3
															'101030113', -- Depo UKVI
															'101030114', -- Gudang Expired
															'101030115', -- Gudang Gas Medis
															'101030116', -- Gudang Konsinyasi
															'101030117', -- Gudang Rusak
															'101030118', -- Depo Metadon
															'101030119') -- Gudang Reused 
							) queryOpname
					group	by katalog_kode
			) dlap left outer join
			(	
				select		tahun, katalog_kode
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos
			) subquery
			on 	dlap.tahun 			= subquery.tahun and
				dlap.katalog_kode 	= subquery.katalog_kode
	where	subquery.katalog_kode is null;

-- 2680 rows updated from 2699 rows opname
update 		rsfPelaporan.laporan_mutasi_saldo_simgos
	set		jumlah_opname 		= 0
	where	tahun 				= 2022;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							max(katalog_kode) as katalog_kode, 
							max(katalog_id) as katalog_id, 
							max(katalog_nama) as katalog_nama, 
							sum(qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											so.TANGGAL 	> '2022-12-16' and
											sod.MANUAL  > 0 and
											so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
															'101030102', -- Depo IRJ LT 2
															'101030103', -- Depo Griya Husada
															'101030104', -- Depo IGD
															'101030105', -- Depo OK CITO
															'101030106', -- Depo Anggrek
															'101030107', -- Depo Bougenville
															'101030108', -- Depo IBS
															'101030109', -- Depo Teratai
															'101030110', -- Depo Produksi
															'101030111', -- Gudang Farmasi
															'101030112', -- Depo IRJ LT 3
															'101030113', -- Depo UKVI
															'101030114', -- Gudang Expired
															'101030115', -- Gudang Gas Medis
															'101030116', -- Gudang Konsinyasi
															'101030117', -- Gudang Rusak
															'101030118', -- Depo Metadon
															'101030119') -- Gudang Reused 
							) queryOpname
					group	by katalog_kode
			) updReff
	set		upd.jumlah_opname 		= updReff.qty
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;


insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '10A311', 0, 345),
	       ( 2022, 12, '10B082', 1451, 1870);
insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '10C125', 4913, 5024),
	       ( 2022, 12, '10M041.2', 5301, 9301),
	       ( 2022, 12, '18R092', 8, 10),
	       ( 2022, 12, '22M049', 1, 4),
	       ( 2022, 12, '22O016', 32, 37),
	       ( 2022, 12, '22P081', 0, 69),
	       ( 2022, 12, '22S064', 8, 19),
	       ( 2022, 12, '22S070', 0, 30),
	       ( 2022, 12, '22S076', 0, 13),
	       ( 2022, 12, '22S077', 0, 9),
	       ( 2022, 12, '40I098', 78, 109),
	       ( 2022, 12, '42B107', 3, 6),
	       ( 2022, 12, '42C1000.27', 16, 18);
insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '42C1000.59', 5.7, 12.4);
insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '42C1000.9', 0, 8),
	       ( 2022, 12, '42C164', 0, 15),
	       ( 2022, 12, '42F095', 0, 14),
	       ( 2022, 12, '42H040', 9, 15),
	       ( 2022, 12, '42M234', 0, 5),
	       ( 2022, 12, '42M317.01', 3, 5),
	       ( 2022, 12, '42M319.01', 4.4, 7.4),
	       ( 2022, 12, '42P322', 3, 6),
	       ( 2022, 12, '42R253', 1.7, 2),
	       ( 2022, 12, '42S140', 20, 20),
	       ( 2022, 12, '42S257', 2, 4),
	       ( 2022, 12, '50A039', 0.97, 1),
	       ( 2022, 12, '50G005', 6.13, 17),
	       ( 2022, 12, '50S001.1', 0.51, 0.9),
	       ( 2022, 12, '80A114', 2, 4),
	       ( 2022, 12, '80C001.120', 54, 56),
	       ( 2022, 12, '80I022', 1, 25),
	       ( 2022, 12, '80J040', 6, 9),
	       ( 2022, 12, '80M248.1', 98, 190);
insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '80N102', 0, 45),
	       ( 2022, 12, '80P145', 1, 3),
	       ( 2022, 12, '80P184', 13, 14),
	       ( 2022, 12, '80R078', 10, 22),
	       ( 2022, 12, '80S213', 50, 122),
	       ( 2022, 12, '80S221', 2, 3),
	       ( 2022, 12, '80S222', 0, 5),
	       ( 2022, 12, '80T084', 7, 23),
	       ( 2022, 12, '80T146', 1, 2),
	       ( 2022, 12, '80V010', 151, 651),
	       ( 2022, 12, '81F058', 2, 3),
	       ( 2022, 12, '81P155', 0, 2);
insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '10A201', 20, 300),
	       ( 2022, 12, '10P050', 80, 200),
	       ( 2022, 12, '22C010', 84, 137),
	       ( 2022, 12, '40B007', 54, 117),
	       ( 2022, 12, '42M325.01', 3, 5),
	       ( 2022, 12, '80E017', 2, 26),
	       ( 2022, 12, '80E020', 0, 21),
	       ( 2022, 12, '80E129', 49, 57),
	       ( 2022, 12, '80E142', 1, 25),
	       ( 2022, 12, '80E143', 0, 12),
	       ( 2022, 12, '80E144', 0, 46),
	       ( 2022, 12, '80E150', 17, 23),
	       ( 2022, 12, '80E156', 6, 10),
	       ( 2022, 12, '80F088', 0, 4),
	       ( 2022, 12, '80F125.1', 6, 28),
	       ( 2022, 12, '80F153', 13, 18),
	       ( 2022, 12, '80L098', 0, 47),
	       ( 2022, 12, '80M247.1', 111, 597),
	       ( 2022, 12, '80N010.1', 0, 48),
	       ( 2022, 12, '80S343', 0, 501),
	       ( 2022, 12, 'PFD001', 0, 6);

delete from  rsfPelaporan.laporan_opnamekoreksi where katalog_kode in (
	'10A201', '10P050', '22C010', '40B007', '42M325.01', '80E017', '80E020', '80E129', 
	'80E142', '80E143', '80E144', '80E150', '80E156', '80F088', '80F125.1', '80F153', '80L098', '80M247.1', 
	'80N010.1', '80S343', 'PFD001');

insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '10A201', 20, 300),
	       ( 2022, 12, '10P050', 80, 200),
	       ( 2022, 12, '22C010', 24, 137),
	       ( 2022, 12, '40B007', 54, 117),
	       ( 2022, 12, '42M325.01', 3, 5),
	       ( 2022, 12, '80F153', 13, 18),
	       ( 2022, 12, '80L098', 0, 47),
	       ( 2022, 12, '80M247.1', 111, 597),
	       ( 2022, 12, '80S343', 0, 501),
		   ( 2022, 12, 'PFD001', 0, 33);
		   
insert into rsfPelaporan.laporan_opnamekoreksi ( tahun, bulan, katalog_kode, jumlah_fisik_koreksi, jumlah_fisik_awal )
	values ( 2022, 12, '80E017', 2, 26),
	       ( 2022, 12, '80E020', 0, 21),
	       ( 2022, 12, '80E129', 49, 57),
	       ( 2022, 12, '80E150', 17, 23),
	       ( 2022, 12, '80F088', 0, 4),
	       ( 2022, 12, '80F125.1', 6, 28);

		   
alter table laporan_mutasi_saldo_simgos add jumlah_opname_koreksi decimal(20,5) null;
update      laporan_mutasi_saldo_simgos set jumlah_opname_koreksi = 0 where tahun = 2022;
ALTER TABLE laporan_mutasi_saldo_simgos modify jumlah_opname_koreksi decimal(20,4) not null;

update      laporan_mutasi_saldo_simgos set jumlah_opname_koreksi = 0 where tahun = 2022;
update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		lkoreksi.tahun,
							lkoreksi.katalog_kode,
							lkoreksi.jumlah_fisik_koreksi as qty
					from	rsfPelaporan.laporan_opnamekoreksi lkoreksi
					where	lkoreksi.tahun = 2022 and
							lkoreksi.bulan = 12
			) updReff
	set		upd.jumlah_opname_koreksi 	= updReff.qty - upd.jumlah_opname
	where	upd.tahun 					= updReff.tahun and
			upd.katalog_kode 			= updReff.katalog_kode;

		   


-- ############ Proses hitung total dan hitung nilai ajusment
update 		rsfPelaporan.laporan_mutasi_saldo_simgos
	set		jumlah_akhir = jumlah_awal + jumlah_penerimaan + jumlah_produksi - jumlah_trx - jumlah_bahanprod,
			jumlah_adj   = (jumlah_awal + jumlah_penerimaan + jumlah_produksi - jumlah_trx - jumlah_bahanprod) - (jumlah_opname + jumlah_opname_koreksi);

-- ############ QUERY LAPORAN FINAL
-- per group
-- HASIL OPNAME BERMASLAH
select		case when opname > awal + pengadaan + prodHasil then 'bermasalah'
				 else '' end as status,
			subquery.*
	from	(
				select		max(lapPers.katalog_kode_grp) as katalog_kode_grp,
							max(mk.nama_barang) as katalog_nama_grp,
							max(lapPers.sts_triwulan1only) as habisDiTW1,
							sum(lapPers.qty_awal) as awal2022,
							sum(lapPers.qty_penerimaan) as pengadaanTW1,
							sum(lapPers.jumlah_awal) as awal,
							sum(lapPers.jumlah_penerimaan) as pengadaan,
							sum(lapPers.jumlah_produksi) as prodHasil,
							sum(lapPers.jumlah_bahanprod) as prodBahan,
							sum(lapPers.jumlah_trx) as transaksi_simgos,
							sum(lapPers.jumlah_adj) as adjusment,
							sum(lapPers.jumlah_opname + lapPers.jumlah_opname_koreksi) as opname
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos lapPers
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = lapPers.katalog_kode_grp
					where	lapPers.sts_triwulan1only = '0'
					group   by lapPers.katalog_kode_grp
			) subquery
	where   opname > awal + pengadaan + prodHasil;


-- Updated TW1 Laporan Produksi
alter table laporan_mutasi_saldo_simgos add qty_produksi decimal(20,4) null;
alter table laporan_mutasi_saldo_simgos add qty_bahanprod decimal(20,4) null;
update laporan_mutasi_saldo_simgos set qty_produksi = 0 where tahun = 2022;
update laporan_mutasi_saldo_simgos set qty_bahanprod = 0 where tahun = 2022;
alter table laporan_mutasi_saldo_simgos modify qty_produksi decimal(20,4) not null;
alter table laporan_mutasi_saldo_simgos modify qty_bahanprod decimal(20,4) not null;

update 		rsfPelaporan.laporan_mutasi_saldo_simgos upd,
			(
				select 		2022 as tahun,
							katalog_kode,
							sum(jumlah_hasilproduksi) as jumlah_hasilproduksi,
							sum(jumlah_bahanproduksi) as jumlah_bahanproduksi 
					from 	laporan_mutasi_bulan 
					where 	tahun = 2022 and 
							bulan <= 3 and 
							( jumlah_hasilproduksi <> 0 or
							  jumlah_bahanproduksi <> 0 )
					group   by katalog_kode			
			) updReff
	set		upd.qty_produksi 		= updReff.jumlah_hasilproduksi,
			upd.qty_bahanprod 		= updReff.jumlah_bahanproduksi
	where	upd.tahun 				= updReff.tahun and
			upd.katalog_kode 		= updReff.katalog_kode;

select		updReff.*
	from 	(
				select 		2022 as tahun,
							katalog_kode,
							sum(jumlah_hasilproduksi) as jumlah_hasilproduksi,
							sum(jumlah_bahanproduksi) as jumlah_bahanproduksi 
					from 	laporan_mutasi_bulan 
					where 	tahun = 2022 and 
							bulan <= 3 and 
							( jumlah_hasilproduksi <> 0 or
							  jumlah_bahanproduksi <> 0 )
					group   by katalog_kode			
			) updReff left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos upd
			on 	updReff.tahun 				= upd.tahun and
				updReff.katalog_kode 		= upd.katalog_kode
	where	upd.katalog_kode is null;

insert into rsfPelaporan.laporan_mutasi_saldo_simgos
			( 	tahun, katalog_kode, 
				jumlah_awal, jumlah_penerimaan,  jumlah_produksi, jumlah_bahanprod,
				jumlah_trx, jumlah_opname, jumlah_opname_koreksi, jumlah_akhir,
				jumlah_adj, qty_awal, qty_penerimaan, 
				qty_produksi, qty_bahanprod, sts_triwulan1only )
select		updReff.tahun, updReff.katalog_kode,
			0 as jumlah_awal,
			0 as jumlah_penerimaan, 0 as jumlah_produksi, 0 as jumlah_bahanprod,
			0 as jumlah_trx, 0 as jumlah_opname, 0 as jumlah_opname_koreksi, 0 as jumlah_akhir,
			0 as jumlah_adj, 0 as qty_awal, 0 as qty_penerimaan, 
			updReff.jumlah_hasilproduksi as qty_produksi, 0 as qty_bahanprod,
			'1' as sts_triwulan1only
	from 	(
				select 		2022 as tahun,
							katalog_kode,
							sum(jumlah_hasilproduksi) as jumlah_hasilproduksi
					from 	laporan_mutasi_bulan 
					where 	tahun = 2022 and 
							bulan <= 3 and 
							jumlah_hasilproduksi <> 0
					group   by katalog_kode			
			) updReff left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos upd
			on 	updReff.tahun 				= upd.tahun and
				updReff.katalog_kode 		= upd.katalog_kode
	where	upd.katalog_kode is null;


--- HASIL OPNAME BERMASLAH rinci per depo
select		case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
			end as katalog_kode,
			r.deskripsi,
			(b.ID) as katalog_id, 
			(b.NAMA) as katalog_nama, 
			(sod.MANUAL) as qty_opname
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.barang b 
			left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
			on b.id		= mapKOpname.id_inventory
	where	so.id		= sod.STOK_OPNAME and
			so.RUANGAN  = r.id and
			sod.BARANG_RUANGAN = br.id and
			br.BARANG = b.ID and
			so.TANGGAL 	> '2022-12-16' and
			sod.MANUAL  != 0 and
			so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
							'101030102', -- Depo IRJ LT 2
							'101030103', -- Depo Griya Husada
							'101030104', -- Depo IGD
							'101030105', -- Depo OK CITO
							'101030106', -- Depo Anggrek
							'101030107', -- Depo Bougenville
							'101030108', -- Depo IBS
							'101030109', -- Depo Teratai
							'101030110', -- Depo Produksi
							'101030111', -- Gudang Farmasi
							'101030112', -- Depo IRJ LT 3
							'101030113', -- Depo UKVI
							'101030114', -- Gudang Expired
							'101030115', -- Gudang Gas Medis
							'101030116', -- Gudang Konsinyasi
							'101030117', -- Gudang Rusak
							'101030118', -- Depo Metadon
							'101030119') -- Gudang Reused 
			and b.id in (
				select		id_inventory
					from	laporan_opname
					where	laporan_opname.katalog_kode_proses in
							(
								select		katalog_kode
									from	rsfPelaporan.laporan_mutasi_saldo_simgos
									where	katalog_kode_grp in 
											(
												select		subquery.katalog_kode_grp
													from	(
																select		max(lapPers.katalog_kode_grp) as katalog_kode_grp,
																			max(mk.nama_barang) as katalog_nama_grp,
																			max(lapPers.sts_triwulan1only) as habisDiTW1,
																			sum(lapPers.qty_awal) as awal2022,
																			sum(lapPers.qty_penerimaan) as pengadaanTW1,
																			sum(lapPers.jumlah_awal) as awal,
																			sum(lapPers.jumlah_penerimaan) as pengadaan,
																			sum(lapPers.jumlah_produksi) as prodHasil,
																			sum(lapPers.jumlah_bahanprod) as prodBahan,
																			sum(lapPers.jumlah_trx) as transaksi_simgos,
																			sum(lapPers.jumlah_adj) as adjusment,
																			sum(lapPers.jumlah_opname) as opname
																	from 	rsfPelaporan.laporan_mutasi_saldo_simgos lapPers
																			left outer join rsfMaster.mkatalog_farmasi mk 
																			on  mk.kode = lapPers.katalog_kode_grp
																	where	lapPers.sts_triwulan1only = '0'
																	group   by lapPers.katalog_kode_grp
															) subquery
													where   opname > awal + pengadaan + prodHasil
												)
							)
			)
	order   by case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
			end;

select		case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
			end as katalog_kode,
			r.deskripsi,
			(b.ID) as katalog_id, 
			(b.NAMA) as katalog_nama, 
			(sod.MANUAL) as qty_opname
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod,
			inventory.barang_ruangan br,
			master.ruangan r,
			inventory.barang b 
			left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
			on b.id		= mapKOpname.id_inventory
	where	so.id		= sod.STOK_OPNAME and
			so.RUANGAN  = r.id and
			sod.BARANG_RUANGAN = br.id and
			br.BARANG = b.ID and
			so.TANGGAL 	> '2022-12-16' and
			sod.MANUAL  != 0 and
			so.RUANGAN 	IN ('101030101', -- Depo IRJ LT 1
							'101030102', -- Depo IRJ LT 2
							'101030103', -- Depo Griya Husada
							'101030104', -- Depo IGD
							'101030105', -- Depo OK CITO
							'101030106', -- Depo Anggrek
							'101030107', -- Depo Bougenville
							'101030108', -- Depo IBS
							'101030109', -- Depo Teratai
							'101030110', -- Depo Produksi
							'101030111', -- Gudang Farmasi
							'101030112', -- Depo IRJ LT 3
							'101030113', -- Depo UKVI
							'101030114', -- Gudang Expired
							'101030115', -- Gudang Gas Medis
							'101030116', -- Gudang Konsinyasi
							'101030117', -- Gudang Rusak
							'101030118', -- Depo Metadon
							'101030119') -- Gudang Reused 
			-- and b.KODE_BARANG in ('10A096','10A099','10A191','10A257','10A310')
			and b.KODE_BARANG in ('10B129','10B132','10B134')
	order   by case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
			end;
-- ############ QUERY LAPORAN FINAL FINAL
-- per group

select		*
	from	(
				select		'sub total' as uraian,
							max(katalog_kode) as katalog_kode,
							max(katalog_kode_grp) as katalog_kode_grp,
							max(katalog_nama) as katalog_nama,
							sum(TW1awal) as TW1awal,
							sum(TW1beli) as TW1beli,
							sum(TW1prodHasil) as TW1prodHasil,
							sum(TW1prodBahan) as TW1prodBahan,
							sum(TW1transaksi) as TW1transaksi,
							sum(awal) as awal,
							sum(pengadaan) as pengadaan,
							sum(prodHasil) as prodHasil,
							sum(prodBahan) as prodBahan,
							sum(transaksi) as transaksi,
							sum(opname) as opname
					from 	(
								select		lapPers.katalog_kode as katalog_kode,
											lapPers.katalog_kode_grp as katalog_kode_grp,
											mk.nama_barang as katalog_nama,
											lapPers.sts_triwulan1only as habisDiTW1,
											lapPers.qty_awal as TW1awal,
											lapPers.qty_penerimaan as TW1beli,
											lapPers.qty_produksi as TW1prodHasil,
											lapPers.qty_bahanprod as TW1prodBahan,
											lapPers.qty_awal + lapPers.qty_penerimaan + lapPers.qty_produksi - lapPers.qty_bahanprod - lapPers.jumlah_awal as TW1transaksi,
											lapPers.jumlah_awal as awal,
											lapPers.jumlah_penerimaan as pengadaan,
											lapPers.jumlah_produksi as prodHasil,
											lapPers.jumlah_bahanprod as prodBahan,
											lapPers.jumlah_trx + lapPers.jumlah_adj as transaksi,
											lapPers.jumlah_opname + lapPers.jumlah_opname_koreksi as opname
									from 	rsfPelaporan.laporan_mutasi_saldo_simgos lapPers
											left outer join rsfMaster.mkatalog_farmasi mk 
											on  mk.kode = lapPers.katalog_kode
									where	lapPers.sts_triwulan1only = '1' or lapPers.sts_triwulan1only = '0'
							) subQuery
					group   by katalog_kode_grp
				union all
					select		'detail' as uraian,
								lapPers.katalog_kode as katalog_kode,
								lapPers.katalog_kode_grp as katalog_kode_grp,
								mk.nama_barang as katalog_nama,
								lapPers.qty_awal as TW1awal,
								lapPers.qty_penerimaan as TW1beli,
								lapPers.qty_produksi as TW1prodHasil,
								lapPers.qty_bahanprod as TW1prodBahan,
								lapPers.qty_awal + lapPers.qty_penerimaan + lapPers.qty_produksi - lapPers.qty_bahanprod - lapPers.jumlah_awal as TW1transaksi,
								lapPers.jumlah_awal as awal,
								lapPers.jumlah_penerimaan as pengadaan,
								lapPers.jumlah_produksi as prodHasil,
								lapPers.jumlah_bahanprod as prodBahan,
								lapPers.jumlah_trx + lapPers.jumlah_adj as transaksi,
								lapPers.jumlah_opname + lapPers.jumlah_opname_koreksi as opname
						from 	rsfPelaporan.laporan_mutasi_saldo_simgos lapPers
								left outer join rsfMaster.mkatalog_farmasi mk 
								on  mk.kode = lapPers.katalog_kode
						where	lapPers.sts_triwulan1only = '1' or lapPers.sts_triwulan1only = '0'
			) queryAll
	order 	by katalog_kode_grp, uraian desc, katalog_kode;

update rsfPelaporan.laporan_mutasi_saldo_simgos set katalog_kode_grp = katalog_kode where katalog_kode_grp is null;
								left outer join 
									( select 	max(KODE_BARANG) as katalog_kode, 
												max(NAMA) as katalog_nama 
										from 	inventory.barang barang 
										where 	KODE_BARANG is not null and
												KODE_BARANG <> ''
										group 	by KODE_BARANG ) masterBarang
								on  masterBarang.katalog_kode = lapPers.katalog_kode

-- laporan hasil produksi TW1
select 		lmb.katalog_kode, max(mf.nama_barang) as katalog_nama,
			sum(lmb.jumlah_hasilproduksi) as jml_produksi, 
			sum(lmb.nilai_hasilproduksi) as nilia_produksi
	from 	laporan_mutasi_bulan lmb
			left outer join
			rsfMaster.mkatalog_farmasi mf 
			on mf.kode = lmb.katalog_kode 
	where 	lmb.tahun = 2022 and lmb.bulan <= 3 and lmb.jumlah_hasilproduksi <> 0
	group   by lmb.katalog_kode;


select 		lap.katalog_kode, 
			mk.nama_barang as nama_barang,
			qty_awal as jumlah_awal,
			qty_penerimaan as jumlah_pengadaan,
			qty_produksi as jumlah_produksi, 
			qty_awal + qty_penerimaan + qty_produksi as jumlah_tersedia, 
			qty_awal + qty_penerimaan + qty_produksi - qty_bahanprod - jumlah_awal as jumlah_trx,
			jumlah_awal  
	from 	laporan_mutasi_saldo_simgos lap
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = lap.katalog_kode	
	where 	qty_awal + qty_penerimaan + qty_produksi - qty_bahanprod - jumlah_awal < 0
	