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
  