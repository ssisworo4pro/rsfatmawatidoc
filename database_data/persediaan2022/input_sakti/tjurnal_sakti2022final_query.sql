-- verifikasi total yang masuk ke database
select 		count(1) as jml_baris,
            sum(qty_awal) as awal_qty, 
			sum(nilai_awal) as awal_nilai,
			sum(qty_akhir) as akhir_qty, 
			sum(nilai_akhir) as akhir_nilai
	from 	tjurnal_sakti2022final;

5076	7084287	44563627004	3377864	29919873428
4685	7084287	44563627004	3377864	29919873428

-- MASTERING grp_sakti
select 		distinct ts.sakti_nama_klp as sakti, '' as klp, '' as kode
	from 	tjurnal_sakti2022final ts left outer join
			tjurnal_sakti_kelompok tsk
			on ts.sakti_nama_klp = tsk.sakti_nama_klp
	where	tsk.sakti_kode_klp  is null

-- update grp_sakti
UPDATE		rsfPelaporan.tjurnal_sakti2022final as upd,
			(
				select 		ts.sakti_kode,
							ts.sakti_nama_klp,
							tsk.sakti_kode_klp
					from 	tjurnal_sakti2022final ts,
							tjurnal_sakti_kelompok tsk
					where	ts.sakti_nama_klp = tsk.sakti_nama_klp
			) updReff
	SET		upd.sakti_kode_klp		= updReff.sakti_kode_klp
	WHERE	upd.sakti_kode			= updReff.sakti_kode and
			upd.sakti_nama_klp		= updReff.sakti_nama_klp;
select * from tjurnal_sakti2022final where sakti_kode_klp is null;

-- update tjurnal_sakti2022final
UPDATE		rsfPelaporan.tjurnal_sakti2022final as upd,
			(
				select 		ts.sakti_kode_klp,
							ts.sakti_kode,
							ts.katalog_kode,
							ts.sts_mapping,
							ts.stat_mapsaldoawal
					from 	tjurnal_sakti2022 ts
			) updReff
	SET		upd.katalog_kode		= updReff.katalog_kode,
			upd.sts_mapping			= updReff.sts_mapping,
			upd.stat_mapsaldoawal	= updReff.stat_mapsaldoawal
	WHERE	upd.sakti_kode_klp		= updReff.sakti_kode_klp and
			upd.sakti_kode			= updReff.sakti_kode;

-- verifikasi total yang masuk ke database dengan status
select 		count(1) as jml_baris,
            sum(qty_awal) as awal_qty, 
			sum(nilai_awal) as awal_nilai,
			sum(qty_akhir) as akhir_qty, 
			sum(nilai_akhir) as akhir_nilai
	from 	tjurnal_sakti2022final
	where	katalog_kode is not null and
			(sts_mapping = 1 or sts_mapping = 2)

4685	7084287	44563627004	3377864	29919873428					

-- yang harus di nol-kan
SELECT 		sakti_kode_klp,
			sakti_kode,
			1 as katalog_grp,
			1 as sakti_grp,
			qty_awal,
			qty_masuk,
			0 as sakti_awal_add,
			qty_akhir as sakti_akhir,
			null as simrs_akhir,
			null as pembulatan,
			null as simrs_trx,
			null as selisih_abs,
			null as selisih,
			katalog_kode as katalog_kode,
			'' as katalog_nama,
			sakti_nama as sakti_nama,
			sakti_nama_klp as sakti_nama_klp
	from 	tjurnal_sakti2022final
	where	( katalog_kode is null or
			  (sts_mapping <> 1 and sts_mapping <> 2)) and
			nilai_akhir <> 0;

-- pembentukan data excel untuk kertas kerja SAKTI
SELECT 		max(sakti.sakti_kode_klp) as sakti_kode_klp,
			max(sakti.sakti_kode) as sakti_kode,
			sum(1) as katalog_grp,
			sum(COALESCE(sakti.qty_group,0)) as sakti_grp,
			sum(COALESCE(sakti.qty_awal,0)) as sakti_awal,
			sum(COALESCE(sakti.qty_masuk,0)) as sakti_masuk,
			sum(COALESCE(sakti.qty_add,0)) as sakti_awal_add,
			sum(COALESCE(sakti.qty_akhir,0)) as sakti_akhir,
			sum(COALESCE(simrs.akhir,0)) as simrs_akhir,
			CEILING(sum(COALESCE(simrs.akhir,0))) as pembulatan,
			sum(COALESCE(simrs.beli,0) + COALESCE(simrs.prod,0) - COALESCE(simrs.resep,0)
			+ COALESCE(simrs.resep_retur,0) - COALESCE(simrs.jual,0) + COALESCE(simrs.jual_retur,0)
			- COALESCE(simrs.tambil,0)) as simrs_trx,
			abs(CEILING(sum(COALESCE(simrs.akhir,0))) - SUM(COALESCE(sakti.qty_akhir,0))) as selisih_abs,
			CEILING(sum(COALESCE(simrs.akhir,0))) - SUM(COALESCE(sakti.qty_akhir,0)) as selisih,
			max(sakti.katalog_kode) as katalog_kode,
			max(mk.katalog_nama) as katalog_nama,
			max(sakti.sakti_nama) as sakti_nama,
			max(sakti.sakti_nama_klp) as sakti_nama_klp
	from	(
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
															min(ts.sakti_kode_klp) as sakti_kode_klp,
															min(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti2022final ts
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
													group   by addsakti.katalog_kode
											) union2
							) tblSaktiWithAdd,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub
					where   tblSaktiWithAdd.katalog_kode = laporanKatalogGrpSub.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) sakti
			left outer join
			(
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
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							trx.sts_proses = 1
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) simrs
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
			on sakti.katalog_kode = mk.katalog_kode
	group 	by sakti.katalog_kode
	order 	by sakti.katalog_kode
	
--- SAKTI DUPLIKASI
SELECT 		grp.katalog_kode_grp,
			sakti.katalog_kode,
			sakti.qty_akhir,
			sakti.qty_awal,
			sakti.qty_masuk,
			sakti.sakti_kode_klp,
			sakti.sakti_kode,
			sakti.sakti_nama,
			sakti.sakti_nama_klp
	FROM 	tjurnal_sakti2022 sakti,
			rsfPelaporan.laporan_so_grp grp
	where 	sakti.katalog_kode = grp.katalog_kode and
			grp.katalog_kode_grp in ('80M246.1')
	order   by grp.katalog_kode_grp, case when sakti.katalog_kode = grp.katalog_kode_grp then 0 else 1 end;

--- harga hpt
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

-- Perbandiangan dengan HPT
SELECT 		max(sakti.sakti_kode_klp) as sakti_kode_klp,
			max(sakti.sakti_kode) as sakti_kode,
			sum(COALESCE(sakti.qty_akhir,0)) as sakti_akhir,
			sum(COALESCE(sakti.nilai_akhir,0)) as sakti_akhir_nilai,
			CEILING(sum(COALESCE(simrs.akhir,0))) as simrs_akhir,
			max(COALESCE(simrs.harga_satuan,0)) *
			CEILING(sum(COALESCE(simrs.akhir,0))) as simrs_akhir_nilai,
			( sum(COALESCE(sakti.nilai_akhir,0))) -
			( max(COALESCE(simrs.harga_satuan,0)) *
			  CEILING(sum(COALESCE(simrs.akhir,0)))) as selisih_nilai,
			max(sakti.katalog_kode) as katalog_kode,
			max(mk.katalog_nama) as katalog_nama
	from	(
				select		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.nilai_akhir) as nilai_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															min(ts.sakti_kode_klp) as sakti_kode_klp,
															min(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															sum(ts.nilai_akhir) as nilai_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti2022final ts
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
							) tblSaktiWithAdd,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub
					where   tblSaktiWithAdd.katalog_kode = laporanKatalogGrpSub.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) sakti
			left outer join
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode,
							sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) as akhir,
							max(nilaiHPT.harga_perolehan) as harga_satuan,
							sum(trx.opname) as opname,
							sum(trx.beli) as beli,
							sum(trx.prod) as prod,
							sum(trx.resep) as resep,
							sum(trx.resep_retur) as resep_retur,
							sum(trx.jual) as jual,
							sum(trx.jual_retur) as jual_retur,
							sum(trx.tambil) as tambil
					FROM	(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							rsfPelaporan.laporan_so_trx trx
							left outer join
							(
								select 		max(laporanKatalogGrp.katalog_kode) as katalog_kode,
											case min(hpt.sts_prod) when 1 then 'input'
															 when 0 then 'btb terakhir'
															 else 'input'
											end as sumber_harga,
											max(hpt.no_dokumen) as no_dokumen,
											max(hpt.tgl_vergudang) as tgl_vergudang,
											max(hpt.nilai_hppb_max) as harga_perolehan
									from 	(
												select 		grp.*
													from 	rsfPelaporan.laporan_so_grp grp
											) laporanKatalogGrp,
											rsfPelaporan.laporan_hpt hpt
									where	hpt.katalog_kode = laporanKatalogGrp.katalog_kode
									group   by laporanKatalogGrp.katalog_kode
									order   by laporanKatalogGrp.katalog_kode
							) nilaiHPT
							on trx.katalog_kode = nilaiHPT.katalog_kode 
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							trx.sts_proses = 1
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) simrs
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
			on sakti.katalog_kode = mk.katalog_kode
	group 	by sakti.katalog_kode
	order 	by sakti.katalog_kode

-- Perbandiangan dengan FIFO grup
SELECT 		max(sakti.sakti_kode_klp) as sakti_kode_klp,
			max(sakti.sakti_kode) as sakti_kode,
			sum(COALESCE(sakti.qty_akhir,0)) as sakti_akhir,
			sum(COALESCE(sakti.nilai_akhir,0)) as sakti_akhir_nilai,
			CEILING(sum(COALESCE(simrs.qty_akhir,0))) as simrs_akhir,
			( sum(COALESCE(simrs.nilai_akhir,0))) as simrs_akhir_nilai,
			( sum(COALESCE(sakti.nilai_akhir,0))) -
			( sum(COALESCE(simrs.nilai_akhir,0))) as selisih_nilai,
			max(sakti.katalog_kode) as katalog_kode,
			max(mk.katalog_nama) as katalog_nama
	from	(
				select		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode, 
							max(tblSaktiWithAdd.sakti_nama) as sakti_nama, 
							max(tblSaktiWithAdd.sakti_nama_klp) as sakti_nama_klp, 
							max(tblSaktiWithAdd.sakti_kode_klp) as sakti_kode_klp, 
							max(tblSaktiWithAdd.sakti_kode) as sakti_kode,
							sum(tblSaktiWithAdd.qty_awal) as qty_awal, 
							sum(tblSaktiWithAdd.qty_masuk) as qty_masuk, 
							sum(tblSaktiWithAdd.qty_keluar) as qty_keluar, 
							sum(tblSaktiWithAdd.qty_akhir) as qty_akhir, 
							sum(tblSaktiWithAdd.nilai_akhir) as nilai_akhir, 
							sum(tblSaktiWithAdd.qty_add) as qty_add, 
							sum(tblSaktiWithAdd.qty_group) as qty_group
					from	(
								select		*
									from	(
												select 		max(ts.katalog_kode) as katalog_kode, 
															max(ts.sakti_nama) as sakti_nama, 
															max(ts.sakti_nama_klp) as sakti_nama_klp,
															min(ts.sakti_kode_klp) as sakti_kode_klp,
															min(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, 
															sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, 
															sum(ts.qty_akhir) as qty_akhir, 
															sum(ts.nilai_akhir) as nilai_akhir, 
															0 as qty_add, 
															count(1) as qty_group
													from 	tjurnal_sakti2022final ts
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) union1
							) tblSaktiWithAdd,
							(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub
					where   tblSaktiWithAdd.katalog_kode = laporanKatalogGrpSub.katalog_kode
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) sakti
			left outer join
			(
				select		max(tnilaififo.katalog_kode_grp) as katalog_kode, 
							max(tnilaififo.qty_opname) as qty_akhir, 
							sum(tnilaififo.qty_opname_fifo_nilai) as nilai_akhir
					from	(
								select 		tfifo.katalog_kode_grp, 
											tfifo.katalog_kode, 
											tfifo.qty_opname,
											tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
											case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
												else tfifo.qty_opname - tfifo.qty_cumulative_sblm
											end as qty_opname_fifo_qty,
											case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
												else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
											end as qty_opname_fifo_nilai
									from 	(	
												select		*
														from	rsfPelaporan.laporan_fifo_grup f
														where	qty_cumulative <=
																( select	min(qty_cumulative) 
																	from 	rsfPelaporan.laporan_fifo_grup
																	where 	qty_cumulative >= qty_opname and 
																			katalog_kode_grp = f.katalog_kode_grp) and
																qty > 0
											) tfifo
									where   tfifo.qty_opname > 0
									order 	by 	tfifo.katalog_kode,
												tfifo.tgl_vergudang desc,
												tfifo.no_btb desc
							) tnilaififo
					group	by  tnilaififo.katalog_kode_grp
			) simrs
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
			on sakti.katalog_kode = mk.katalog_kode
	group 	by sakti.katalog_kode
	order 	by sakti.katalog_kode
