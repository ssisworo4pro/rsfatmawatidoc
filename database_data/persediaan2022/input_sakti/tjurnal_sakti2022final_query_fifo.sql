truncate table tjurnal_penerimaan2022sa;
insert tjurnal_penerimaan2022sa
 (	id, no_btb, katalog_kode, katalog_kode_grp, no_dokumen,
 	klp_dokumen, tgl_terima, tgl_jurnal, tgl_vergudang,
 	pbf_id, pbf_kode, pbf_nama, no_bku, tgl_bku,
 	qty_terima, qty_retur, nilai_hp, nilai_hppb, nilai_akhir,
 	sts_proses, xsorting )
select 
 	id, no_btb, katalog_kode, katalog_kode_grp, no_dokumen,
 	klp_dokumen, tgl_terima, tgl_jurnal, tgl_vergudang,
 	pbf_id, pbf_kode, pbf_nama, no_bku, tgl_bku,
 	qty_terima, qty_retur, nilai_hp, nilai_hppb, nilai_akhir,
 	sts_proses, xsorting
 	from tjurnal_penerimaanall
 	where tgl_vergudang >= '2022-01-01';
 	
select		count(1)
	from 	(
				select		DISTINCT katalog_kode 
					from	laporan_mutasi_bulan a 
					where	bulan = 1 and tahun = 2022 and jumlah_awal > 0 
			) a;

insert tjurnal_penerimaan2022sa
 (	no_btb, katalog_kode, katalog_kode_grp, no_dokumen,
 	klp_dokumen, tgl_terima, tgl_jurnal, tgl_vergudang,
 	pbf_id, pbf_kode, pbf_nama, no_bku, tgl_bku,
 	qty_terima, qty_retur, nilai_hp, nilai_hppb, nilai_akhir,
 	sts_proses, xsorting )
select 	'SALDO_AWAL_2022' as no_btb,
		katalog_kode as katalog_kode,
		katalog_kode as katalog_kode_grp,
		'SALDO_AWAL_2022' as no_dokumen,
		'AWAL' as klp_dokumen,
		'2021-12-31' as tgl_terima,
		'2021-12-31' as tgl_jurnal,
		'2021-12-31' as tgl_vergudang,
		0 as pbf_id,
		'0000' as pbf_kode,
		'SALDO_AWAL_2022' as pbf_nama,
		'SALDO_AWAL_2022' as no_bku,
		'2021-12-31' as tgl_bku,
 		jumlah_awal as qty_terima, 
 		0 as qty_retur, 
 		harga_awal as nilai_hp,
 		harga_awal as nilai_hppb,
 		nilai_awal as nilai_akhir,
 		1 as sts_proses,
 		CONCAT('20211231_AWAL_2022_', RIGHT(CONCAT('000000',ROW_NUMBER() OVER()),6))  as xsorting
 from 	laporan_mutasi_bulan a 
 where 	bulan = 1 and tahun = 2022 and jumlah_awal > 0
 order  by katalog_kode;
 
update 		rsfPelaporan.tjurnal_penerimaan2022sa set katalog_kode_grp = katalog_kode;
UPDATE		rsfPelaporan.tjurnal_penerimaan2022sa as upd,
			(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) updReff
	SET		upd.katalog_kode_grp		= updReff.katalog_kode_grp
	WHERE	upd.katalog_kode			= updReff.katalog_kode;

select * from tjurnal_penerimaan2022sa ts where katalog_kode_grp is null;

--------------------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------------------- 

-- 4. pembentukan rsfPelaporan.laporan_fifo_grup
truncate table rsfPelaporan.laporan_fifo_grup;
insert into rsfPelaporan.laporan_fifo_grup 
			( 	katalog_kode_grp, katalog_kode, tgl_vergudang, no_btb, 
				qty_opname, qty_trx, qty, 
				qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode_grp as katalog_kode_grp,
			t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty_terima - t.qty_retur as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaan2022sa x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode_grp	 = t.katalog_kode_grp ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaan2022sa x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode_grp	 = t.katalog_kode_grp), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	tjurnal_penerimaan2022sa t
	where	sts_proses = 1 
	ORDER 	BY  t.katalog_kode_grp,
				t.xsorting desc;

-- 5. update qty_opname
update 		rsfPelaporan.laporan_fifo_grup set qty_opname = 0;
update 		rsfPelaporan.laporan_fifo_grup upd,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode_grp,
							CEILING(sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil)) as akhir
					FROM	(
								select 		grp.*
									from 	rsfPelaporan.laporan_so_grp grp
							) laporanKatalogGrpSub,
							rsfPelaporan.laporan_so_trx trx
					where   trx.katalog_kode = laporanKatalogGrpSub.katalog_kode and
							trx.sts_proses = 1
					group   by laporanKatalogGrpSub.katalog_kode_grp
			) updReff
	set		upd.qty_opname 			= updReff.akhir
	where	upd.katalog_kode_grp	= updReff.katalog_kode_grp;

--------------------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------------------- 

-- validasi qty
select      sum(qty_opname)
    from    (
				select		katalog_kode, max(qty_opname) as qty_opname
					from	rsfPelaporan.laporan_fifo_grup
					group   by katalog_kode
			) test

-- validasi barang yang belum ada mapping harga fifo-nya
select      mk.nama_barang, updReff.*
    from    (
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode,
							CEILING(sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil)) as akhir,
							max(nilaiHPT.harga_perolehan) as harga_satuan,
							max(nilaiHPT.sumber_harga) as sumber_harga,
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
			) updReff
			left outer join
			(
				select		katalog_kode_grp, max(qty_opname) as qty_opname
					from	rsfPelaporan.laporan_fifo_grup
					group   by katalog_kode_grp
			) test
			on updReff.katalog_kode = test.katalog_kode_grp
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = updReff.katalog_kode
	where	test.katalog_kode_grp is null

--- validasi kelompok dengan pembelian terakhir
				select		teamTerimaRinci.*
					from	(
								select		grpKatalog.katalog_kode_grp as katalog_kode_grp,
											terimaKatalog.katalog_kode as katalog_kode,
											terimaKatalog.xsorting as xsorting,
											terimaKatalog.nilai_hppb as nilai_hppb
									from	tjurnal_penerimaan2022sa terimaKatalog,
											(
												select		grps.katalog_kode, grps.katalog_kode_grp
													from	rsfPelaporan.laporan_so_grp grps
													where	grps.katalog_kode_grp in (
																select 		grp.katalog_kode_grp
																	from 	rsfPelaporan.laporan_so_grp grp
																	group   by grp.katalog_kode_grp 
																	having  count(1) > 1
															)
											) grpKatalog
									where   grpKatalog.katalog_kode = terimaKatalog.katalog_kode and
											terimaKatalog.nilai_hppb > 0
								) teamTerimaRinci,
								(
									select		max(grpKatalog.katalog_kode_grp) as katalog_kode_grp,
												max(terimaKatalog.xsorting) as xsorting_max
										from	tjurnal_penerimaan2022sa terimaKatalog,
												(
													select		grps.katalog_kode, grps.katalog_kode_grp
														from	rsfPelaporan.laporan_so_grp grps
														where	grps.katalog_kode_grp in (
																	select 		grp.katalog_kode_grp
																		from 	rsfPelaporan.laporan_so_grp grp
																		group   by grp.katalog_kode_grp 
																		having  count(1) > 1
																)
												) grpKatalog
										where   grpKatalog.katalog_kode = terimaKatalog.katalog_kode and
												terimaKatalog.xsorting <> '20211231_SALDO_AWAL_2022'
										group   by grpKatalog.katalog_kode_grp
										order   by grpKatalog.katalog_kode_grp
								) teamTerimaRekap
						where	teamTerimaRinci.katalog_kode_grp 	= teamTerimaRekap.katalog_kode_grp and
								teamTerimaRinci.xsorting 			= teamTerimaRekap.xsorting_max 
						having  teamTerimaRinci.katalog_kode_grp	<> teamTerimaRinci.katalog_kode


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------



-- 6. update qty_totalbeli
update 		rsfPelaporan.laporan_fifo_grup upd,
			(
				select 		katalog_kode_grp, sum(qty) as qty_beli
					from 	rsfPelaporan.laporan_fifo_grup
					group   by katalog_kode_grp
			) updReff
	set		upd.qty_totalbeli		= updReff.qty_beli
	where	upd.katalog_kode_grp	= updReff.katalog_kode_grp;

-- 7. validasi stok > jumlah_beli
select		katalog_kode_grp,
			max(qty_opname) as qty_opname, 
			max(qty_totalbeli) as qty_totalbeli
	from	rsfPelaporan.laporan_fifo_grup
	where	qty_opname > qty_totalbeli
	group	by katalog_kode_grp

-- Pembentukan Master Data FIFO selesai
---------------------------------------------------------------------------------------------------------------------
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
									where 	qty_cumulative >= qty_opname and katalog_kode_grp = f.katalog_kode_grp) and
								qty > 0
			) tfifo
	order 	by 	tfifo.katalog_kode_grp,
				tfifo.tgl_vergudang desc,
				tfifo.no_btb desc,
				tfifo.katalog_kode

select		max(tnilaififo.katalog_kode_grp), 
			max(tnilaififo.katalog_kode), 
			max(mk.nama_barang) as katalog_nama,
			max(qty_opname) as qty_opname, 
			sum(tnilaififo.qty_opname_fifo_nilai) as nilai_opname_fifo
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
													where 	qty_cumulative >= qty_opname and katalog_kode_grp = f.katalog_kode_grp) and
												qty > 0
							) tfifo
					where   tfifo.qty_opname > 0
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc
			) tnilaififo
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = tnilaififo.katalog_kode_grp
	group	by  tnilaififo.katalog_kode_grp;





















				select 		tfifo.katalog_kode, 
							mk.nama_barang as katalog_nama,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty as qty_beli, tfifo.nilai_hppb, 
							-- tfifo.qty_cumulative,
							tfifo.qty_opname,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_hitungfifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_hitungfifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = tfifo.katalog_kode
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc



				select 		tfifo.katalog_kode, tfifo.qty_opname,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_fifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_fifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
					where	tfifo.katalog_kode = '10C046'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc




'14B003.1-2022-06-09 13:47:00'
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01' and
							katalog_kode     = '14B003.1'
					order   by katalog_kode, tgl_vergudang desc



	
select 		* 
	from 	(
				select 		katalog_kode, count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) test 
	order 	by counter desc;


select		tgl_vergudang,
			no_btb,
			no_dokumen,
			katalog_kode,
			qty_terima as qty_terima,
  			qty_retur as qty_retur,
			qty_terima - qty_retur as qty,
  			nilai_hppb as nilai_hppb
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '42A080'
  	order	by 	tgl_vergudang;

select		sum(qty_terima - qty_retur) as qty
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '83P005';
  
  select * from rsfMaster.mkatalog_farmasi mf where mf.kode = '83P005';
  
  
  
  
  
  
  
  
  
 -----------------------------------------------------------------------------------------------------------------
  


truncate table rsfPelaporan.laporan_fifo_grp;
insert into rsfPelaporan.laporan_fifo_grp ( katalog_kode_grp, tgl_vergudang, no_btb, qty_opname, qty_trx, qty, qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode_grp as katalog_kode_grp,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode_grp   = t.katalog_kode_grp ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode_grp 	 = t.katalog_kode_grp), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	(
				select		tgl_vergudang,
							xsorting,
							no_btb,
							no_dokumen,
							katalog_kode_grp,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					order   by katalog_kode_grp, tgl_vergudang desc, no_btb desc
			) t
	ORDER 	BY  t.katalog_kode_grp,
				t.tgl_vergudang desc,
				t.no_btb desc;





-- Jumlah re-Pembelian
-- sample : 80V047
-- alter table laporan_fifo add qty_totalbeli decimal(20,4) null;
-- 

-- cari kasus :
select 		tcounter.katalog_kode, tcounter.counter, topname.jumlah_opname 
	from 	(
				select 		katalog_kode, 
							count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) tcounter,
			(	select 		katalog_kode, jumlah_opname 
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
			) topname
	where   tcounter.katalog_kode = topname.katalog_kode and
			topname.jumlah_opname > 10
	order 	by tcounter.counter desc;

T00202206000220
12345678901234567890
-- dapatkan fifo :
SELECT 		t.katalog_kode,
			t.tgl_vergudang,
			t.qty,
			t.nilai_hppb,
			@running_total:=@running_total + t.qty AS cumulative_sum
	FROM	(
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01'
					order	by 	tgl_vergudang desc
			) t
			JOIN 
			(	SELECT @running_total:=0	) r
	ORDER 	BY  t.katalog_kode,
				t.tgl_vergudang desc;


-- ################ Generate Table FIFO
alter table tjurnal_penerimaanall add xsorting char(27) null;

update tjurnal_penerimaanall
   set xsorting = CONCAT(DATE_FORMAT(tgl_vergudang, '%Y%m%d%H%i'), no_btb);

-- Updated Rows	14515
truncate table rsfPelaporan.laporan_fifo;
insert into rsfPelaporan.laporan_fifo ( katalog_kode, tgl_vergudang, no_btb, qty_opname, qty_trx, qty, qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode 		 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode 		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	(
				select		tgl_vergudang,
							xsorting,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					order   by katalog_kode, tgl_vergudang desc, no_btb desc
			) t
	ORDER 	BY  t.katalog_kode,
				t.tgl_vergudang desc,
				t.no_btb desc;

-- Updated Rows	25537
-- Updated Rows	37393

insert into rsfPelaporan.laporan_fifo 
			( 	katalog_kode, tgl_vergudang, no_btb, 
				qty_opname, qty_trx, qty, 
				qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty_terima - t.qty_retur as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode 		 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode 		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	tjurnal_penerimaanall t
	where	sts_proses = 1 
	ORDER 	BY  t.katalog_kode,
				t.xsorting desc;


update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, jumlah_opname + jumlah_opname_koreksi as jumlah_opname
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
			) updReff
	set		upd.qty_opname 		= updReff.jumlah_opname
	where	upd.katalog_kode 	= updReff.katalog_kode;

update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, sum(qty) as qty_beli
					from 	rsfPelaporan.laporan_fifo 
					group   by katalog_kode
			) updReff
	set		upd.qty_totalbeli	= updReff.qty_beli
	where	upd.katalog_kode 	= updReff.katalog_kode;

-- Cari kasusnya
select		katalog_kode, sum(1)
	from	(
				select		katalog_kode, nilai_hppb
				from		(
								select 		tcounter.katalog_kode, tcounter.counter, topname.jumlah_opname,
											tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative
									from 	(
												select 		katalog_kode, 
															count(1) as counter 
													from 	tjurnal_penerimaan 
													where 	sts_proses 		 = 1 and
															tgl_vergudang 	>= '2022-01-01' and
													        tgl_vergudang 	 < '2023-01-01'
													group 	by katalog_kode
											) tcounter join
											(	select 		katalog_kode, jumlah_opname 
													from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
											) topname
											on topname.katalog_kode = tcounter.katalog_kode and
											   topname.jumlah_opname > 10
											join
											(	
												select		*
														from	rsfPelaporan.laporan_fifo f
														where	qty_cumulative <=
																( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
																	where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
											) tfifo
											on tfifo.katalog_kode  = topname.katalog_kode 
									order 	by 	tcounter.counter desc,
												tcounter.katalog_kode,
												tfifo.tgl_vergudang desc,
												tfifo.no_btb desc
							) subquery
					group	by katalog_kode, nilai_hppb
			) subsubquery
	group	by katalog_kode
	having	sum(1) > 1;
	
--- validasi stok > jumlah_beli
	select		katalog_kode,
				max(qty_opname) as qty_opname, 
				max(qty_totalbeli) as qty_totalbeli
		from	rsfPelaporan.laporan_fifo
		where	qty_opname > qty_totalbeli
		group	by katalog_kode
	

--- Lihat data FIFO-nya  22 584 937 902   => 22 814 843 740
--- 26 835 168 839   28 322 393 056
--- 28 255 832 421
select		tnilaififo.katalog_kode, 
			mk.nama_barang as katalog_nama,
			sum(tnilaififo.qty_opname_fifo_nilai) as nilai_opname_fifo
	from	(
				select 		tfifo.katalog_kode, 
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
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select	min(qty_cumulative) 
													from 	rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode) and
												qty > 0
							) tfifo
					where	tfifo.katalog_kode = '10A166'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc
			) tnilaififo
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = tnilaififo.katalog_kode
	group	by  tnilaififo.katalog_kode;


				select 		tfifo.katalog_kode, 
							mk.nama_barang as katalog_nama,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty as qty_beli, tfifo.nilai_hppb, 
							-- tfifo.qty_cumulative,
							tfifo.qty_opname,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_hitungfifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_hitungfifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = tfifo.katalog_kode
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc



				select 		tfifo.katalog_kode, tfifo.qty_opname,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_fifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_fifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
					where	tfifo.katalog_kode = '10C046'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc




'14B003.1-2022-06-09 13:47:00'
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01' and
							katalog_kode     = '14B003.1'
					order   by katalog_kode, tgl_vergudang desc



	
select 		* 
	from 	(
				select 		katalog_kode, count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) test 
	order 	by counter desc;


select		tgl_vergudang,
			no_btb,
			no_dokumen,
			katalog_kode,
			qty_terima as qty_terima,
  			qty_retur as qty_retur,
			qty_terima - qty_retur as qty,
  			nilai_hppb as nilai_hppb
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '42A080'
  	order	by 	tgl_vergudang;

select		sum(qty_terima - qty_retur) as qty
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '83P005';
  
  select * from rsfMaster.mkatalog_farmasi mf where mf.kode = '83P005';
  
  

---------------------------------------------------------------------------------------------------------------------
-- Pembentukan Master Data FIFO
-- 1. insert table tjurnal_penerimaanall
-- 2. pembentukan sorting 
--		alter table tjurnal_penerimaanall add xsorting char(27) null;
--		update tjurnal_penerimaanall set xsorting = CONCAT(DATE_FORMAT(tgl_vergudang, '%Y%m%d%H%i'), no_btb);
-- 3. penambahan katalog_kode_grp

alter table tjurnal_penerimaanall add katalog_kode_grp varchar(25) null;
create index idx_idxtjurnal_penerimaanall2x on tjurnal_penerimaanall (sts_proses, xsorting, katalog_kode_grp);
update tjurnal_penerimaanall set katalog_kode_grp = katalog_kode;

UPDATE		rsfPelaporan.tjurnal_penerimaanall as upd,
			(
				select 		lmss.katalog_kode_grp, lmss.katalog_kode
					from 	laporan_mutasi_saldo_simgos lmss
					where 	tahun = 2022
			) updReff
	SET		upd.katalog_kode_grp		= updReff.katalog_kode_grp
	WHERE	upd.katalog_kode			= updReff.katalog_kode;

select * from tjurnal_penerimaanall ts where katalog_kode_grp is null;

-- 4. pembentukan rsfPelaporan.laporan_fifo_grp
truncate table rsfPelaporan.laporan_fifo_grp;
insert into rsfPelaporan.laporan_fifo_grp 
			( 	katalog_kode_grp, tgl_vergudang, no_btb, 
				qty_opname, qty_trx, qty, 
				qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode_grp as katalog_kode_grp,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty_terima - t.qty_retur as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode_grp	 = t.katalog_kode_grp ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode_grp	 = t.katalog_kode_grp), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	tjurnal_penerimaanall t
	where	sts_proses = 1 
	ORDER 	BY  t.katalog_kode_grp,
				t.xsorting desc;

-- 5. update qty_opname
update 		rsfPelaporan.laporan_fifo_grp set qty_opname = 0;
update 		rsfPelaporan.laporan_fifo_grp upd,
			(
				select 		max(katalog_kode_grp) as katalog_kode_grp, 
							sum(jumlah_opname + jumlah_opname_koreksi) as jumlah_opname
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
					group   by katalog_kode_grp
			) updReff
	set		upd.qty_opname 			= updReff.jumlah_opname
	where	upd.katalog_kode_grp 	= updReff.katalog_kode_grp;

-- 6. update qty_totalbeli
update 		rsfPelaporan.laporan_fifo_grp upd,
			(
				select 		katalog_kode_grp, sum(qty) as qty_beli
					from 	rsfPelaporan.laporan_fifo_grp 
					group   by katalog_kode_grp
			) updReff
	set		upd.qty_totalbeli		= updReff.qty_beli
	where	upd.katalog_kode_grp 	= updReff.katalog_kode_grp;

-- 7. validasi stok > jumlah_beli
select		katalog_kode_grp,
			max(qty_opname) as qty_opname, 
			max(qty_totalbeli) as qty_totalbeli
	from	rsfPelaporan.laporan_fifo_grp
	where	qty_opname > qty_totalbeli
	group	by katalog_kode_grp

-- Pembentukan Master Data FIFO selesai
---------------------------------------------------------------------------------------------------------------------
select 		tfifo.katalog_kode_grp, 
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
						from	rsfPelaporan.laporan_fifo_grp f
						where	qty_cumulative <=
								( select	min(qty_cumulative) 
									from 	rsfPelaporan.laporan_fifo_grp
									where 	qty_cumulative >= qty_opname and katalog_kode_grp = f.katalog_kode_grp) and
								qty > 0
			) tfifo
	order 	by 	tfifo.katalog_kode_grp,
				tfifo.tgl_vergudang desc,
				tfifo.no_btb desc

select		tnilaififo.katalog_kode_grp, 
			mk.nama_barang as katalog_nama,
			max(qty_opname) as qty_opname, 
			sum(tnilaififo.qty_opname_fifo_nilai) as nilai_opname_fifo
	from	(
				select 		tfifo.katalog_kode_grp, 
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
										from	rsfPelaporan.laporan_fifo_grp f
										where	qty_cumulative <=
												( select	min(qty_cumulative) 
													from 	rsfPelaporan.laporan_fifo_grp
													where 	qty_cumulative >= qty_opname and katalog_kode_grp = f.katalog_kode_grp) and
												qty > 0
							) tfifo
					-- where	tfifo.katalog_kode_grp = '10A166'
					order 	by 	tfifo.katalog_kode_grp,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc
			) tnilaififo
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = tnilaififo.katalog_kode_grp
	group	by  tnilaififo.katalog_kode_grp;



				select 		tfifo.katalog_kode, 
							mk.nama_barang as katalog_nama,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty as qty_beli, tfifo.nilai_hppb, 
							-- tfifo.qty_cumulative,
							tfifo.qty_opname,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_hitungfifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_hitungfifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = tfifo.katalog_kode
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc



				select 		tfifo.katalog_kode, tfifo.qty_opname,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_fifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_fifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
					where	tfifo.katalog_kode = '10C046'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc




'14B003.1-2022-06-09 13:47:00'
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01' and
							katalog_kode     = '14B003.1'
					order   by katalog_kode, tgl_vergudang desc



	
select 		* 
	from 	(
				select 		katalog_kode, count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) test 
	order 	by counter desc;


select		tgl_vergudang,
			no_btb,
			no_dokumen,
			katalog_kode,
			qty_terima as qty_terima,
  			qty_retur as qty_retur,
			qty_terima - qty_retur as qty,
  			nilai_hppb as nilai_hppb
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '42A080'
  	order	by 	tgl_vergudang;

select		sum(qty_terima - qty_retur) as qty
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '83P005';
  
  select * from rsfMaster.mkatalog_farmasi mf where mf.kode = '83P005';
  
  
  
  
  
  
  
  
  
 -----------------------------------------------------------------------------------------------------------------
  


truncate table rsfPelaporan.laporan_fifo_grp;
insert into rsfPelaporan.laporan_fifo_grp ( katalog_kode_grp, tgl_vergudang, no_btb, qty_opname, qty_trx, qty, qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode_grp as katalog_kode_grp,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode_grp   = t.katalog_kode_grp ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode_grp 	 = t.katalog_kode_grp), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	(
				select		tgl_vergudang,
							xsorting,
							no_btb,
							no_dokumen,
							katalog_kode_grp,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					order   by katalog_kode_grp, tgl_vergudang desc, no_btb desc
			) t
	ORDER 	BY  t.katalog_kode_grp,
				t.tgl_vergudang desc,
				t.no_btb desc;





-- Jumlah re-Pembelian
-- sample : 80V047
-- alter table laporan_fifo add qty_totalbeli decimal(20,4) null;
-- 

-- cari kasus :
select 		tcounter.katalog_kode, tcounter.counter, topname.jumlah_opname 
	from 	(
				select 		katalog_kode, 
							count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) tcounter,
			(	select 		katalog_kode, jumlah_opname 
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
			) topname
	where   tcounter.katalog_kode = topname.katalog_kode and
			topname.jumlah_opname > 10
	order 	by tcounter.counter desc;

T00202206000220
12345678901234567890
-- dapatkan fifo :
SELECT 		t.katalog_kode,
			t.tgl_vergudang,
			t.qty,
			t.nilai_hppb,
			@running_total:=@running_total + t.qty AS cumulative_sum
	FROM	(
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01'
					order	by 	tgl_vergudang desc
			) t
			JOIN 
			(	SELECT @running_total:=0	) r
	ORDER 	BY  t.katalog_kode,
				t.tgl_vergudang desc;


-- ################ Generate Table FIFO
alter table tjurnal_penerimaanall add xsorting char(27) null;

update tjurnal_penerimaanall
   set xsorting = CONCAT(DATE_FORMAT(tgl_vergudang, '%Y%m%d%H%i'), no_btb);

-- Updated Rows	14515
truncate table rsfPelaporan.laporan_fifo;
insert into rsfPelaporan.laporan_fifo ( katalog_kode, tgl_vergudang, no_btb, qty_opname, qty_trx, qty, qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode 		 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode 		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	(
				select		tgl_vergudang,
							xsorting,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					order   by katalog_kode, tgl_vergudang desc, no_btb desc
			) t
	ORDER 	BY  t.katalog_kode,
				t.tgl_vergudang desc,
				t.no_btb desc;

-- Updated Rows	25537
-- Updated Rows	37393

insert into rsfPelaporan.laporan_fifo 
			( 	katalog_kode, tgl_vergudang, no_btb, 
				qty_opname, qty_trx, qty, 
				qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty_terima - t.qty_retur as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode 		 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode 		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	tjurnal_penerimaanall t
	where	sts_proses = 1 
	ORDER 	BY  t.katalog_kode,
				t.xsorting desc;


update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, jumlah_opname + jumlah_opname_koreksi as jumlah_opname
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
			) updReff
	set		upd.qty_opname 		= updReff.jumlah_opname
	where	upd.katalog_kode 	= updReff.katalog_kode;

update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, sum(qty) as qty_beli
					from 	rsfPelaporan.laporan_fifo 
					group   by katalog_kode
			) updReff
	set		upd.qty_totalbeli	= updReff.qty_beli
	where	upd.katalog_kode 	= updReff.katalog_kode;

-- Cari kasusnya
select		katalog_kode, sum(1)
	from	(
				select		katalog_kode, nilai_hppb
				from		(
								select 		tcounter.katalog_kode, tcounter.counter, topname.jumlah_opname,
											tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative
									from 	(
												select 		katalog_kode, 
															count(1) as counter 
													from 	tjurnal_penerimaan 
													where 	sts_proses 		 = 1 and
															tgl_vergudang 	>= '2022-01-01' and
													        tgl_vergudang 	 < '2023-01-01'
													group 	by katalog_kode
											) tcounter join
											(	select 		katalog_kode, jumlah_opname 
													from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
											) topname
											on topname.katalog_kode = tcounter.katalog_kode and
											   topname.jumlah_opname > 10
											join
											(	
												select		*
														from	rsfPelaporan.laporan_fifo f
														where	qty_cumulative <=
																( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
																	where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
											) tfifo
											on tfifo.katalog_kode  = topname.katalog_kode 
									order 	by 	tcounter.counter desc,
												tcounter.katalog_kode,
												tfifo.tgl_vergudang desc,
												tfifo.no_btb desc
							) subquery
					group	by katalog_kode, nilai_hppb
			) subsubquery
	group	by katalog_kode
	having	sum(1) > 1;
	
--- validasi stok > jumlah_beli
	select		katalog_kode,
				max(qty_opname) as qty_opname, 
				max(qty_totalbeli) as qty_totalbeli
		from	rsfPelaporan.laporan_fifo
		where	qty_opname > qty_totalbeli
		group	by katalog_kode
	

--- Lihat data FIFO-nya  22 584 937 902   => 22 814 843 740
--- 26 835 168 839   28 322 393 056
--- 28 255 832 421
select		tnilaififo.katalog_kode, 
			mk.nama_barang as katalog_nama,
			sum(tnilaififo.qty_opname_fifo_nilai) as nilai_opname_fifo
	from	(
				select 		tfifo.katalog_kode, 
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
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select	min(qty_cumulative) 
													from 	rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode) and
												qty > 0
							) tfifo
					where	tfifo.katalog_kode = '10A166'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc
			) tnilaififo
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = tnilaififo.katalog_kode
	group	by  tnilaififo.katalog_kode;


				select 		tfifo.katalog_kode, 
							mk.nama_barang as katalog_nama,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty as qty_beli, tfifo.nilai_hppb, 
							-- tfifo.qty_cumulative,
							tfifo.qty_opname,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_hitungfifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_hitungfifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = tfifo.katalog_kode
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc



				select 		tfifo.katalog_kode, tfifo.qty_opname,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_fifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_fifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
					where	tfifo.katalog_kode = '10C046'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc




'14B003.1-2022-06-09 13:47:00'
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01' and
							katalog_kode     = '14B003.1'
					order   by katalog_kode, tgl_vergudang desc



	
select 		* 
	from 	(
				select 		katalog_kode, count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) test 
	order 	by counter desc;


select		tgl_vergudang,
			no_btb,
			no_dokumen,
			katalog_kode,
			qty_terima as qty_terima,
  			qty_retur as qty_retur,
			qty_terima - qty_retur as qty,
  			nilai_hppb as nilai_hppb
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '42A080'
  	order	by 	tgl_vergudang;

select		sum(qty_terima - qty_retur) as qty
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '83P005';
  
  select * from rsfMaster.mkatalog_farmasi mf where mf.kode = '83P005';

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- 4. pembentukan rsfPelaporan.laporan_fifo
truncate table rsfPelaporan.laporan_fifo;
insert into rsfPelaporan.laporan_fifo
			( 	katalog_kode, tgl_vergudang, no_btb, 
				qty_opname, qty_trx, qty, 
				qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty_terima - t.qty_retur as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode	 	 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	tjurnal_penerimaanall t
	where	sts_proses = 1 
	ORDER 	BY  t.katalog_kode,
				t.xsorting desc;

-- 5. update qty_opname
update 		rsfPelaporan.laporan_fifo set qty_opname = 0;
update 		rsfPelaporan.laporan_fifo upd,
			(
				SELECT		max(laporanKatalogGrpSub.katalog_kode_grp) as katalog_kode,
							CEILING(sum(trx.opname + trx.beli + trx.prod - trx.resep + trx.resep_retur - trx.jual + trx.jual_retur - trx.tambil)) as akhir,
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
			) updReff
	set		upd.qty_opname 			= updReff.akhir
	where	upd.katalog_kode 		= updReff.katalog_kode;

select      sum(qty_opname)
    from    (
				select		katalog_kode, max(qty_opname) as qty_opname
					from	rsfPelaporan.laporan_fifo
					group   by katalog_kode
			) test

-- 6. update qty_totalbeli
update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, sum(qty) as qty_beli
					from 	rsfPelaporan.laporan_fifo 
					group   by katalog_kode
			) updReff
	set		upd.qty_totalbeli		= updReff.qty_beli
	where	upd.katalog_kode 		= updReff.katalog_kode;

-- 7. validasi stok > jumlah_beli
select		katalog_kode,
			max(qty_opname) as qty_opname, 
			max(qty_totalbeli) as qty_totalbeli
	from	rsfPelaporan.laporan_fifo
	where	qty_opname > qty_totalbeli
	group	by katalog_kode

-- Pembentukan Master Data FIFO selesai
---------------------------------------------------------------------------------------------------------------------
select 		tfifo.katalog_kode, 
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
						from	rsfPelaporan.laporan_fifo f
						where	qty_cumulative <=
								( select	min(qty_cumulative) 
									from 	rsfPelaporan.laporan_fifo
									where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode) and
								qty > 0
			) tfifo
	order 	by 	tfifo.katalog_kode,
				tfifo.tgl_vergudang desc,
				tfifo.no_btb desc

select		tnilaififo.katalog_kode, 
			mk.nama_barang as katalog_nama,
			max(qty_opname) as qty_opname, 
			sum(tnilaififo.qty_opname_fifo_nilai) as nilai_opname_fifo
	from	(
				select 		tfifo.katalog_kode, 
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
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select	min(qty_cumulative) 
													from 	rsfPelaporan.laporan_fifo
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode) and
												qty > 0
							) tfifo
					where   tfifo.qty_opname > 0
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc
			) tnilaififo
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = tnilaififo.katalog_kode
	group	by  tnilaififo.katalog_kode;



				select 		tfifo.katalog_kode, 
							mk.nama_barang as katalog_nama,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty as qty_beli, tfifo.nilai_hppb, 
							-- tfifo.qty_cumulative,
							tfifo.qty_opname,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_hitungfifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_hitungfifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = tfifo.katalog_kode
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc



				select 		tfifo.katalog_kode, tfifo.qty_opname,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_fifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_fifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
					where	tfifo.katalog_kode = '10C046'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc




'14B003.1-2022-06-09 13:47:00'
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01' and
							katalog_kode     = '14B003.1'
					order   by katalog_kode, tgl_vergudang desc



	
select 		* 
	from 	(
				select 		katalog_kode, count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) test 
	order 	by counter desc;


select		tgl_vergudang,
			no_btb,
			no_dokumen,
			katalog_kode,
			qty_terima as qty_terima,
  			qty_retur as qty_retur,
			qty_terima - qty_retur as qty,
  			nilai_hppb as nilai_hppb
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '42A080'
  	order	by 	tgl_vergudang;

select		sum(qty_terima - qty_retur) as qty
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '83P005';
  
  select * from rsfMaster.mkatalog_farmasi mf where mf.kode = '83P005';
  
  
  
  
  
  
  
  
  
 -----------------------------------------------------------------------------------------------------------------
  


truncate table rsfPelaporan.laporan_fifo_grp;
insert into rsfPelaporan.laporan_fifo_grp ( katalog_kode_grp, tgl_vergudang, no_btb, qty_opname, qty_trx, qty, qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode_grp as katalog_kode_grp,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode_grp   = t.katalog_kode_grp ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode_grp 	 = t.katalog_kode_grp), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	(
				select		tgl_vergudang,
							xsorting,
							no_btb,
							no_dokumen,
							katalog_kode_grp,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					order   by katalog_kode_grp, tgl_vergudang desc, no_btb desc
			) t
	ORDER 	BY  t.katalog_kode_grp,
				t.tgl_vergudang desc,
				t.no_btb desc;





-- Jumlah re-Pembelian
-- sample : 80V047
-- alter table laporan_fifo add qty_totalbeli decimal(20,4) null;
-- 

-- cari kasus :
select 		tcounter.katalog_kode, tcounter.counter, topname.jumlah_opname 
	from 	(
				select 		katalog_kode, 
							count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) tcounter,
			(	select 		katalog_kode, jumlah_opname 
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
			) topname
	where   tcounter.katalog_kode = topname.katalog_kode and
			topname.jumlah_opname > 10
	order 	by tcounter.counter desc;

T00202206000220
12345678901234567890
-- dapatkan fifo :
SELECT 		t.katalog_kode,
			t.tgl_vergudang,
			t.qty,
			t.nilai_hppb,
			@running_total:=@running_total + t.qty AS cumulative_sum
	FROM	(
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01'
					order	by 	tgl_vergudang desc
			) t
			JOIN 
			(	SELECT @running_total:=0	) r
	ORDER 	BY  t.katalog_kode,
				t.tgl_vergudang desc;


-- ################ Generate Table FIFO
alter table tjurnal_penerimaanall add xsorting char(27) null;

update tjurnal_penerimaanall
   set xsorting = CONCAT(DATE_FORMAT(tgl_vergudang, '%Y%m%d%H%i'), no_btb);

-- Updated Rows	14515
truncate table rsfPelaporan.laporan_fifo;
insert into rsfPelaporan.laporan_fifo ( katalog_kode, tgl_vergudang, no_btb, qty_opname, qty_trx, qty, qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode 		 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode 		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	(
				select		tgl_vergudang,
							xsorting,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					order   by katalog_kode, tgl_vergudang desc, no_btb desc
			) t
	ORDER 	BY  t.katalog_kode,
				t.tgl_vergudang desc,
				t.no_btb desc;

-- Updated Rows	25537
-- Updated Rows	37393

insert into rsfPelaporan.laporan_fifo 
			( 	katalog_kode, tgl_vergudang, no_btb, 
				qty_opname, qty_trx, qty, 
				qty_cumulative, qty_cumulative_sblm, nilai_hppb, qty_totalbeli )
SELECT 		t.katalog_kode as katalog_kode,
			t.tgl_vergudang as tgl_vergudang,
			t.no_btb as no_btb,
			0 as qty_opname,
			0 as qty_trx,
			t.qty_terima - t.qty_retur as qty,
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			>= t.xsorting and
							x.katalog_kode 		 = t.katalog_kode ) AS qty_cumulative,
			COALESCE(
			(	SELECT 		SUM(qty_terima - qty_retur)
					FROM 	tjurnal_penerimaanall x
					WHERE 	x.sts_proses 	  	 = 1 and
							x.xsorting 			 > t.xsorting and
							x.katalog_kode 		 = t.katalog_kode), 0) AS qty_cumulative_sblm,
			t.nilai_hppb as nilai_hppb,
			0 as qty_totalbeli
	FROM	tjurnal_penerimaanall t
	where	sts_proses = 1 
	ORDER 	BY  t.katalog_kode,
				t.xsorting desc;


update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, jumlah_opname + jumlah_opname_koreksi as jumlah_opname
					from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
			) updReff
	set		upd.qty_opname 		= updReff.jumlah_opname
	where	upd.katalog_kode 	= updReff.katalog_kode;

update 		rsfPelaporan.laporan_fifo upd,
			(
				select 		katalog_kode, sum(qty) as qty_beli
					from 	rsfPelaporan.laporan_fifo 
					group   by katalog_kode
			) updReff
	set		upd.qty_totalbeli	= updReff.qty_beli
	where	upd.katalog_kode 	= updReff.katalog_kode;

-- Cari kasusnya
select		katalog_kode, sum(1)
	from	(
				select		katalog_kode, nilai_hppb
				from		(
								select 		tcounter.katalog_kode, tcounter.counter, topname.jumlah_opname,
											tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative
									from 	(
												select 		katalog_kode, 
															count(1) as counter 
													from 	tjurnal_penerimaan 
													where 	sts_proses 		 = 1 and
															tgl_vergudang 	>= '2022-01-01' and
													        tgl_vergudang 	 < '2023-01-01'
													group 	by katalog_kode
											) tcounter join
											(	select 		katalog_kode, jumlah_opname 
													from 	rsfPelaporan.laporan_mutasi_saldo_simgos 
											) topname
											on topname.katalog_kode = tcounter.katalog_kode and
											   topname.jumlah_opname > 10
											join
											(	
												select		*
														from	rsfPelaporan.laporan_fifo f
														where	qty_cumulative <=
																( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
																	where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
											) tfifo
											on tfifo.katalog_kode  = topname.katalog_kode 
									order 	by 	tcounter.counter desc,
												tcounter.katalog_kode,
												tfifo.tgl_vergudang desc,
												tfifo.no_btb desc
							) subquery
					group	by katalog_kode, nilai_hppb
			) subsubquery
	group	by katalog_kode
	having	sum(1) > 1;
	
--- validasi stok > jumlah_beli
	select		katalog_kode,
				max(qty_opname) as qty_opname, 
				max(qty_totalbeli) as qty_totalbeli
		from	rsfPelaporan.laporan_fifo
		where	qty_opname > qty_totalbeli
		group	by katalog_kode
	

--- Lihat data FIFO-nya  22 584 937 902   => 22 814 843 740
--- 26 835 168 839   28 322 393 056
--- 28 255 832 421
select		tnilaififo.katalog_kode, 
			mk.nama_barang as katalog_nama,
			sum(tnilaififo.qty_opname_fifo_nilai) as nilai_opname_fifo
	from	(
				select 		tfifo.katalog_kode, 
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
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select	min(qty_cumulative) 
													from 	rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode) and
												qty > 0
							) tfifo
					where	tfifo.katalog_kode = '10A166'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc
			) tnilaififo
			left outer join rsfMaster.mkatalog_farmasi mk 
			on  mk.kode = tnilaififo.katalog_kode
	group	by  tnilaififo.katalog_kode;


				select 		tfifo.katalog_kode, 
							mk.nama_barang as katalog_nama,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty as qty_beli, tfifo.nilai_hppb, 
							-- tfifo.qty_cumulative,
							tfifo.qty_opname,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_hitungfifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_hitungfifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
							left outer join rsfMaster.mkatalog_farmasi mk 
							on  mk.kode = tfifo.katalog_kode
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc



				select 		tfifo.katalog_kode, tfifo.qty_opname,
							tfifo.tgl_vergudang, tfifo.no_btb, tfifo.qty, tfifo.nilai_hppb, tfifo.qty_cumulative,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty
								else tfifo.qty_opname - tfifo.qty_cumulative_sblm
							end as qty_opname_fifo_qty,
							case when tfifo.qty_opname >= tfifo.qty_cumulative then tfifo.qty * tfifo.nilai_hppb
								else (tfifo.qty_opname - tfifo.qty_cumulative_sblm) * tfifo.nilai_hppb
							end as qty_opname_fifo_nilai
					from 	(	
								select		*
										from	rsfPelaporan.laporan_fifo f
										where	qty_cumulative <=
												( select min(qty_cumulative) from rsfPelaporan.laporan_fifo 
													where 	qty_cumulative >= qty_opname and katalog_kode = f.katalog_kode)
							) tfifo
					where	tfifo.katalog_kode = '10C046'
					order 	by 	tfifo.katalog_kode,
								tfifo.tgl_vergudang desc,
								tfifo.no_btb desc




'14B003.1-2022-06-09 13:47:00'
				select		tgl_vergudang,
							no_btb,
							no_dokumen,
							katalog_kode,
							qty_terima as qty_terima,
							qty_retur as qty_retur,
							qty_terima - qty_retur as qty,
							nilai_hppb as nilai_hppb
					from	tjurnal_penerimaan
					where	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
							tgl_vergudang 	 < '2023-01-01' and
							katalog_kode     = '14B003.1'
					order   by katalog_kode, tgl_vergudang desc



	
select 		* 
	from 	(
				select 		katalog_kode, count(1) as counter 
					from 	tjurnal_penerimaan 
					where 	sts_proses 		 = 1 and
							tgl_vergudang 	>= '2022-01-01' and
					        tgl_vergudang 	 < '2023-01-01'
					group 	by katalog_kode
			) test 
	order 	by counter desc;


select		tgl_vergudang,
			no_btb,
			no_dokumen,
			katalog_kode,
			qty_terima as qty_terima,
  			qty_retur as qty_retur,
			qty_terima - qty_retur as qty,
  			nilai_hppb as nilai_hppb
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '42A080'
  	order	by 	tgl_vergudang;

select		sum(qty_terima - qty_retur) as qty
  	from	tjurnal_penerimaan
  	where	sts_proses 		 = 1 and
			tgl_vergudang 	>= '2022-01-01' and
			tgl_vergudang 	 < '2023-01-01' and
			katalog_kode 	 = '83P005';

select * from rsfMaster.mkatalog_farmasi mf where mf.kode = '83P005';
