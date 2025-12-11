select		validasiSakti.simrs_akhir as simrs_akhir,
			validasi.qty_awal + validasi.sakti_masuk as sakti_awalmasuk,
			validasi.sakti_awal_add as sakti_add,
			validasi.*
	from	(
				SELECT 		max(sakti.sakti_kode_klp) as sakti_kode_klp,
							max(sakti.sakti_kode) as sakti_kode,
							sum(1) as katalog_grp,
							sum(COALESCE(sakti.qty_group,0)) as sakti_grp,
							sum(COALESCE(sakti.qty_awal,0)) as qty_awal,
							sum(COALESCE(sakti.qty_add,0)) as sakti_awal_add,
							sum(COALESCE(sakti.qty_akhir,0)) as sakti_akhir,
							sum(COALESCE(sakti.qty_masuk,0)) as sakti_masuk,
							sum(COALESCE(simrs.akhir,0)) as simrs_akhir,
							CEILING(sum(COALESCE(simrs.akhir,0))) as pembulatan,
							sum(COALESCE(simrs.beli,0) + COALESCE(simrs.prod,0) - COALESCE(simrs.resep,0)
							+ COALESCE(simrs.resep_retur,0) - COALESCE(simrs.jual,0) + COALESCE(simrs.jual_retur,0)
							- COALESCE(simrs.tambil,0)) as simrs_trx,
							abs(sum(COALESCE(simrs.akhir,0) - COALESCE(sakti.qty_akhir,0))) as selisih_abs,
							sum(COALESCE(simrs.akhir,0) - COALESCE(sakti.qty_akhir,0)) as selisih,
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
											trx.sts_proses   = 1
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
			) validasiSakti
	where	validasiSakti.simrs_akhir > qty_awal + sakti_masuk