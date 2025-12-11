alter table laporan_so_trx add sts_proses integer null;
update laporan_so_trx set sts_proses = 0;
alter table laporan_so_trx modify sts_proses integer not null;

UPDATE		rsfPelaporan.laporan_so_trx as upd,
			(
				select 		laporanKatalogGrp.katalog_kode
					from 	(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrp,
							(
								SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode
									FROM	rsfPelaporan.laporan_so_trx trx,
											(
												select 		grp.*
													from 	rsfPelaporan.laporan_so_grp grp
											) laporanKatalogGrpSub
									where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode
									group   by laporanKatalogGrpSub.katalog_kode_grp
									having  sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil) < 0
							) lstRekap
					where	laporanKatalogGrp.katalog_kode_grp = lstRekap.katalog_kode
			) updReff
	SET		upd.sts_proses				= 4
	WHERE	upd.katalog_kode			= updReff.katalog_kode;

UPDATE		rsfPelaporan.laporan_so_trx as upd,
			(
				select 		grp.katalog_kode
					from 	rsfPelaporan.laporan_so_grp grp,
							rsfPelaporan.tjurnal_sakti_include include
					where	grp.katalog_kode_grp = include.katalog_kode
			) updReff
	SET		upd.sts_proses				= 1
	WHERE	upd.katalog_kode			= updReff.katalog_kode and
			upd.sts_proses              = 0;

UPDATE		rsfPelaporan.laporan_so_trx as upd,
			(
				select 		grp.katalog_kode
					from 	rsfPelaporan.laporan_so_grp grp,
							rsfPelaporan.tjurnal_sakti_include include
					where	grp.katalog_kode_grp = include.katalog_kode
			) updReff
	SET		upd.sts_proses				= 2
	WHERE	upd.katalog_kode			= updReff.katalog_kode and
			upd.sts_proses              = 4;

UPDATE		rsfPelaporan.laporan_so_trx
	SET		sts_proses = 3
	WHERE   sts_proses = 0;


select 		sum(lstDetail.opname - lstDetail.resep - lstDetail.jual - lstDetail.tambil 
			+ lstDetail.beli + lstDetail.prod + lstDetail.resep_retur + lstDetail.jual_retur) as qty_akhir_rs
	from 	rsfPelaporan.laporan_so_trx lstDetail
	where	lstDetail.sts_proses = 1;
