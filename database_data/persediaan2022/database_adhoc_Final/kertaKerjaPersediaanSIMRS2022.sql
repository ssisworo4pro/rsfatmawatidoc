insert into rsfPelaporan.tjurnal_sakti_include(katalog_kode)
SELECT 		max(simrs.katalog_kode) as katalog_kode
	from	(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode,
							sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) as akhir,
							sum(trx.opname) as opname,
							sum(trx.beli) as beli,
							sum(trx.prod) as prod,
							sum(trx.resep) as resep,
							sum(trx.resep_retur) as resep_retur,
							sum(trx.jual) as jual,
							sum(trx.jual_retur) as jual_retur,
							sum(trx.tambil) as tambil
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) simrs
			left outer join
			(
				select		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															min(tsk.sakti_kode_klp) as sakti_kode_klp,
															min(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
															left outer join tjurnal_sakti_klp tsk
															on ts.sakti_nama_klp = tsk.sakti_nama_klp
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
								UNION ALL
								select		*
									from	(
												select 		max(addsakti.katalog_kode) as katalog_kode,
															max(addsakti.sakti_nama) as sakti_nama,
															max(addsakti.sakti_nama_klp) as sakti_nama_klp, 
															max(tsk.sakti_kode_klp) as sakti_kode_klp,
															'' as sakti_kode,
															0 as qty_awal, 
															0 as qty_masuk, 
															0 as qty_keluar, 
															0 as qty_akhir, 
															sum(qty_add) as qty_add, 
															0 as qty_group
													from 	tjurnal_sakti_add addsakti
															left outer join tjurnal_sakti_klp tsk
															on addsakti.sakti_nama_klp = tsk.sakti_nama_klp
													group   by katalog_kode
											) union2
							) tblSaktiWithAdd,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub
					where   tblSaktiWithAdd.katalog_kode = laporanKatalogGrpSub.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) sakti
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		NAMA as katalog_nama,
							KODE_BARANG as katalog_kode
					from 	inventory.barang 
					where 	id in 
							(select 	min(id) 
								from 	inventory.barang 
								where 	KODE_BARANG is not null group by KODE_BARANG )
			) mk
			on simrs.katalog_kode = mk.katalog_kode
	where   sakti.katalog_kode is not null
	group 	by simrs.katalog_kode
	order 	by simrs.katalog_kode

-- generate data rinci per depo
select 		lstDetail.depo_nama,
			lstDetail.katalog_id,
			lstDetail.katalog_kode,
			lstDetail.katalog_nama,
			lstDetail.katalog_satuan,
			lstDetail.opname,
			lstDetail.beli,
			lstDetail.mmasuk,
			lstDetail.mkeluar,
			lstDetail.prod,
			lstDetail.resep - lstDetail.resep_retur as resep,
			lstDetail.jual - lstDetail.jual_retur as jual,
			lstDetail.tambil,
			lstDetail.opname - lstDetail.mkeluar - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.mmasuk + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur as qty_akhir,
			lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur as qty_akhir_rs,
			lsimgos.katalog_kode as lsimgos
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode;

-- rincian barang
select 		lstDetail.depo_nama,
			lstDetail.katalog_id,
			lstDetail.katalog_kode,
			lstDetail.katalog_nama,
			lstDetail.katalog_satuan,
			lstDetail.opname,
			lstDetail.beli,
			lstDetail.mmasuk,
			lstDetail.mkeluar,
			lstDetail.prod,
			lstDetail.resep - lstDetail.resep_retur as resep,
			lstDetail.jual - lstDetail.jual_retur as jual,
			lstDetail.tambil,
			lstDetail.opname - lstDetail.mkeluar - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.mmasuk + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur as qty_akhir,
			lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur as qty_akhir_rs,
			lsimgos.katalog_kode as lsimgos
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			lstDetail.sts_proses = 1;

-- rekap seluruh depo tanpa group
select 		max(lstDetail.katalog_kode) as katalog_kode,
			max(lstDetail.katalog_nama) as katalog_nama,
			max(lstDetail.katalog_satuan) as katalog_satuan,
			sum(lstDetail.opname) as opname,
			sum(lstDetail.beli) as beli,
			sum(lstDetail.prod) as produksi,
			sum(lstDetail.resep - lstDetail.resep_retur) as resep,
			sum(lstDetail.jual - lstDetail.jual_retur) as jual,
			sum(lstDetail.tambil) as tambil,
			sum(lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur) as qty_akhir_rs
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode
	group   by lstDetail.katalog_kode;
			

--- grouping
select 		max(lstDetail.katalog_kode) as katalog_kode,
			max(lstDetail.katalog_nama) as katalog_nama,
			max(lstDetail.katalog_satuan) as katalog_satuan,
			max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode
	group   by laporanKatalogGrp.katalog_kode;

---- Generate Data Rekap Rumah Sakit
select 		-- max(lstDetail.katalog_kode) as katalog_kode,
			max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode,
			max(lstDetail.katalog_nama) as katalog_nama,
			max(lstDetail.katalog_satuan) as katalog_satuan,
			sum(lstDetail.opname) as opname,
			sum(lstDetail.beli) as beli,
			sum(lstDetail.prod) as prod,
			sum(lstDetail.resep - lstDetail.resep_retur) as resep,
			sum(lstDetail.jual - lstDetail.jual_retur) as jual,
			sum(lstDetail.tambil) as tambil,
			sum(lstDetail.opname - lstDetail.mkeluar - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.mmasuk + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur) as qty_akhir,
			sum(lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur) as qty_akhir_rs,
			max(laporan_hpt.nilai_hppb) as harga_perolehan_ori,
			max(laporan_hpt.nilai_hppb_max) as harga_perolehan,
			max(laporan_hpt.nilai_hppb_min) as harga_perolehan_min
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join laporan_hpt
			on lstDetail.katalog_kode = laporan_hpt.katalog_kode
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode
	group   by laporanKatalogGrp.katalog_kode_grp;

--- validasi grouping rinci
select 		(lstDetail.katalog_kode) as katalog_kode,
			(lstDetail.katalog_nama) as katalog_nama,
			(lstDetail.katalog_satuan) as katalog_satuan,
			laporanKatalogGrp.katalog_kode
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp
			left outer join rsfPelaporan.laporan_so_trx lstDetail
			on  lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode
	where   laporanKatalogGrp.katalog_kode is null;

--- validasi grouping rekap
select 		(lstRekap.katalog_kode) as katalog_kode,
			laporanKatalogGrp.katalog_kode
	from 	(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
			left outer join
			(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp
			on  lstRekap.katalog_kode = laporanKatalogGrp.katalog_kode_grp
	where   laporanKatalogGrp.katalog_kode is null;

-- validasi detail vs rekap
select 		sum(lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur) as qty_akhir_rs,
			laporanKatalogGrp.katalog_kode_grp
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode
	group   by laporanKatalogGrp.katalog_kode_grp;


select 		sum(lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur) as qty_akhir_rs,
			laporanKatalogGrp.katalog_kode_grp
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_so_trx lstDetail
			left outer join
			rsfPelaporan.laporan_mutasi_saldo_simgos lsimgos
			on lstDetail.katalog_kode = lsimgos.katalog_kode,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
					FROM	rsfPelaporan.laporan_so_trx trx,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							tjurnal_sakti_include
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							laporanKatalogGrpSub.katalog_kode_grp = tjurnal_sakti_include.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
					having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) >= 0
			) lstRekap
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode and
			laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode
	group   by laporanKatalogGrp.katalog_kode_grp;

-- katalog harga kertasKerjaPersediaanSMRS2022_masterharga.xlsx
select 		(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp,
			(lstDetail.katalog_kode) as katalog_kode,
			(lstDetail.katalog_nama) as katalog_nama,
			(lstDetail.katalog_satuan) as katalog_satuan,
			(laporan_hpt.nilai_hppb) as harga_perolehan,
			case sts_prod when 1 then 'input'
							 when 0 then 'btb terakhir'
							 else 'input'
			end as sumber_harga,
			laporan_hpt.no_dokumen as no_dokumen,
			laporan_hpt.tgl_vergudang as tgl_vergudang,
			(laporan_hpt.nilai_hppb_max) as harga_perolehan_max,
			(laporan_hpt.nilai_hppb_min) as harga_perolehan_min
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			(
				select 		max(lstDtl.katalog_kode) as katalog_kode,
							max(lstDtl.katalog_nama) as katalog_nama,
							max(lstDtl.katalog_satuan) as katalog_satuan
					from	rsfPelaporan.laporan_so_trx lstDtl
					where	sts_proses = 1
					group   by lstDtl.katalog_kode
			) lstDetail
			left outer join laporan_hpt
			on lstDetail.katalog_kode = laporan_hpt.katalog_kode
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode
	order   by laporanKatalogGrp.katalog_kode_grp

select 		(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp,
			(lstDetail.katalog_kode) as katalog_kode,
			(lstDetail.katalog_nama) as katalog_nama,
			(lstDetail.katalog_satuan) as katalog_satuan,
			(laporan_hpt.nilai_hppb) as harga_perolehan,
			case sts_prod when 1 then 'input'
							 when 0 then 'btb terakhir'
							 else 'input'
			end as sumber_harga,
			laporan_hpt.no_dokumen as no_dokumen,
			laporan_hpt.tgl_vergudang as tgl_vergudang,
			(laporan_hpt.nilai_hppb_max) as harga_perolehan_max,
			(laporan_hpt.nilai_hppb_min) as harga_perolehan_min
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			(
				select 		max(lstDtl.katalog_kode) as katalog_kode,
							max(lstDtl.katalog_nama) as katalog_nama,
							max(lstDtl.katalog_satuan) as katalog_satuan
					from	rsfPelaporan.laporan_so_trx lstDtl
					where	sts_proses = 1
					group   by lstDtl.katalog_kode
			) lstDetail
			left outer join laporan_hpt
			on lstDetail.katalog_kode = laporan_hpt.katalog_kode
	where	lstDetail.katalog_kode = laporanKatalogGrp.katalog_kode
	order   by laporanKatalogGrp.katalog_kode_grp

--- HPT REKAP
select 		max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp,
			case min(hpt.sts_prod) when 1 then 'input'
							 when 0 then 'btb terakhir'
							 else 'input'
			end as sumber_harga,
			max(hpt.no_dokumen) as no_dokumen,
			max(hpt.tgl_vergudang) as tgl_vergudang,
			max(hpt.nilai_hppb_max) as harga_perolehan_max
	from 	(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) laporanKatalogGrp,
			rsfPelaporan.laporan_hpt hpt
	where	hpt.katalog_kode = laporanKatalogGrp.katalog_kode
	group   by laporanKatalogGrp.katalog_kode_grp
	order   by laporanKatalogGrp.katalog_kode_grp

