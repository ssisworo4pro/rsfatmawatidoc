1. laporan persediaan per 31 desember
   kode, nama barang, qty, nilai akhir
2. laporan real persediaan per 31 desember
   - rekap rs
   - rinci depo
   - pengelompokan katalog barang
   - adjusment untuk input SAKTI
3. laporan rincian persediaan
   kode, nama barang, trx-in, trx-out, saldo-akhir, nilai-akhir

4. laporan real transaksi per katalog
   - per depo
  
6. neraca persediaan
   kelompok barang, saldo-akhir, nilai-akhir
7. Laporan Fifo saldo-akhir
8. Mapping sakti
---------------------------------------------------------------------------------- 
-- 1. laporan persediaan
select		laporanPersediaan.katalog_kode, 
			laporanPersediaan.katalog_nama, 
			laporanPersediaan.simrs_grp as qty_grp,
			laporanPersediaan.simrs_akhir as qty,
			laporanFifo.qty as qty_fifo,
			laporanFifo.nilai as nilai
	from	(
				select		katalog_kode, katalog_nama, simrs_grp, simrs_akhir
					from	(
								SELECT 		max(simrs.katalog_kode_grp) as katalog_kode, 
											sum(simrs.qty_group) as simrs_grp, 
											sum(simrs.jumlah_awal) as simrs_awal, 
											sum(simrs.jumlah_pengadaan) as simrs_beli,
											sum(simrs.jumlah_produksi) as simrs_produksi,
											sum(simrs.jumlah_masuk) as simrs_masuk,
											sum(simrs.jumlah_keluar) as simrs_keluar,
											sum(simrs.jumlah_akhir) as simrs_akhir,
											max(sakti.qty_awal) as sakti_awal,
											max(sakti.qty_masuk) as sakti_masuk, 
											max(sakti.qty_keluar) as sakti_kelar, 
											max(sakti.qty_akhir) as sakti_akhir, 
											max(sakti.qty_group) as sakti_grp,
											case when max(sakti.sakti_kode) is null then 0 else 1 end as sakti_mapping,
											max(mk.katalog_nama) as katalog_nama
									from	(
												select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
															sum(qty_awal) as jumlah_awal,
															sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
															sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
															sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
															sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
															sum(jumlah_opname + jumlah_opname_koreksi) as jumlah_akhir,
															count(1) as qty_group
													FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
													group   by lmss.katalog_kode
											) simrs
											left outer join
											(
												select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
															max(ts.sakti_kode) as sakti_kode,
															sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
															sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
															count(1) as qty_group
													from 	tjurnal_sakti ts
													where   katalog_kode is not null and
															(sts_mapping = 1 or sts_mapping = 2)
													group   by ts.katalog_kode
											) sakti
											on sakti.katalog_kode = simrs.katalog_kode
											left outer join 
											(
												select 		max(b.NAMA) as katalog_nama,
															max(b.KODE_BARANG) as katalog_kode
													from 	inventory.barang b
													group   by b.KODE_BARANG
											) mk
											on simrs.katalog_kode_grp = mk.katalog_kode
									group   by simrs.katalog_kode_grp
							) tblPerbandingan
					order	by  katalog_kode
			) laporanPersediaan
			left outer join
			(
				select		tnilaififo.katalog_kode_grp as katalog_kode, 
							mk.nama_barang as katalog_nama,
							max(qty_opname) as qty, 
							sum(tnilaififo.qty_opname_fifo_nilai) as nilai
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
					group	by  tnilaififo.katalog_kode_grp
			) laporanFifo
			on laporanPersediaan.katalog_kode = laporanFifo.katalog_kode
	order 	by  abs(laporanPersediaan.simrs_akhir - laporanFifo.qty) desc,
				laporanPersediaan.katalog_kode;

-- untuk mengetahui kasus selisih rinci FIFO dan rekap
-- ubah query diatas dengan ganti left outer join jadi right outer join dan
-- ganti select nya menjadi :
select		laporanFifo.katalog_kode,
			laporanFifo.nilai as nilai


-- 2. Laporan Real Persediaan
-- rinci
select		case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
			end as katalog_kode,
			r.DESKRIPSI as depo,
			(b.ID) as katalog_id, 
			(b.NAMA) as katalog_nama, 
			(sod.MANUAL) as qty_opname
	from	inventory.stok_opname so,
			master.ruangan r,
			inventory.stok_opname_detil sod 
			left outer join inventory.barang_ruangan br 
			on	sod.BARANG_RUANGAN = br.id
			left outer join inventory.barang b 
			on br.BARANG = b.ID 
			left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
			on b.id		= mapKOpname.id_inventory
	where	so.id		= sod.STOK_OPNAME and
			r.ID     	= so.RUANGAN and
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
	order	by r.DESKRIPSI,
				case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
				end;

-- rekap
select 		max(katalog_kode) as katalog_kode, 
			max(katalog_id) as katalog_id, 
			max(katalog_nama) as katalog_nama, 
			max(satuan) as satuan, 
			sum(qty_opname) as qty
	from	(
				select		case COALESCE(mapKOpname.katalog_kode,'')
									when '' then b.KODE_BARANG
									else mapKOpname.katalog_kode
							end as katalog_kode,
							r.DESKRIPSI as depo,
							(b.ID) as katalog_id, 
							(b.NAMA) as katalog_nama, 
							(sod.MANUAL) as qty_opname,
							(s.NAMA) as satuan
					from	inventory.stok_opname so,
							master.ruangan r,
							inventory.stok_opname_detil sod 
							left outer join inventory.barang_ruangan br 
							on	sod.BARANG_RUANGAN = br.id
							left outer join inventory.barang b 
							on br.BARANG = b.ID 
							left outer join inventory.satuan s
							on b.SATUAN = s.ID
							left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
							on b.id		= mapKOpname.id_inventory
					where	so.id		= sod.STOK_OPNAME and
							r.ID     	= so.RUANGAN and
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
					order	by r.DESKRIPSI,
								case COALESCE(mapKOpname.katalog_kode,'')
									when '' then b.KODE_BARANG
									else mapKOpname.katalog_kode
								end 			
			) queryOpname
	group	by katalog_kode;

-- nilai adjusment
select		opnameReport.*,
			lmss.jumlah_opname + lmss.jumlah_opname_koreksi as qty_adj,
			masterHPT.nilai_hppb as beli_nilai_hppb,
			masterHPT.tgl_vergudang as beli_tgl_terimagudang,
			masterHPT.no_btb as beli_no_btb,
			masterHPT.no_dokumen as beli_no_dokumen
	from	(
				select 		max(queryOpname.katalog_kode) as katalog_kode, 
							max(queryOpname.katalog_id) as katalog_id, 
							max(queryOpname.katalog_nama) as katalog_nama, 
							max(queryOpname.satuan) as satuan, 
							sum(queryOpname.qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											r.DESKRIPSI as depo,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(s.NAMA) as satuan,
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											master.ruangan r,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join inventory.satuan s
											on b.SATUAN = s.ID
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											r.ID     	= so.RUANGAN and
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
									order	by r.DESKRIPSI,
												case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
												end 			
							) queryOpname
					group	by queryOpname.katalog_kode
			) opnameReport
			left outer join laporan_mutasi_saldo_simgos lmss
			on lmss.katalog_kode = opnameReport.katalog_kode
			left outer join
			(
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
					where	concat((xsorting),(katalog_kode)) in
							(
								select		concat(max(xsorting),max(katalog_kode))
									from	tjurnal_penerimaanall
									where	sts_proses 		 = 1 
											-- and tgl_vergudang    >= '2022-01-01'
									group   by katalog_kode
							) and
							-- qty_terima - qty_retur <> 0 
					order   by katalog_kode
			) masterHPT
			on masterHPT.katalog_kode = opnameReport.katalog_kode
	order	by	abs(opnameReport.qty - (lmss.jumlah_opname + lmss.jumlah_opname_koreksi)) desc,
				opnameReport.katalog_kode

-- pengelompokan barang
select		lmss.katalog_kode_grp, lmss.katalog_kode, COALESCE(b.NAMA, mbarang.katalog_nama) as nama 
	from	laporan_mutasi_saldo_simgos lmss
			left outer join inventory.barang b
			on lmss.katalog_kode = b.KODE_BARANG
			left outer join
			(
				select 		mk.nama_barang as katalog_nama, mk.kode as katalog_kode
					from	rsfMaster.masterf_katalog mk 
					group	by mk.kode 
			) mbarang
			on lmss.katalog_kode = mbarang.katalog_kode
	where	katalog_kode_grp in (
				select		katalog_kode_grp
					from	laporan_mutasi_saldo_simgos lmss
					group   by katalog_kode_grp
					having  count(1) > 1
			)
	order	by katalog_kode_grp;




-- 3 HPT
-- master HPT
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
	where	concat((xsorting),(katalog_kode)) in
			(
				select		concat(max(xsorting),max(katalog_kode))
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 and
							tgl_vergudang    >= '2022-01-01'
					group   by katalog_kode
			) and
			qty_terima - qty_retur <> 0 
	order   by katalog_kode
							
-- trx lookup ke HPT
select		case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
			end as katalog_kode,
			r.DESKRIPSI as depo,
			(b.ID) as katalog_id, 
			(b.NAMA) as katalog_nama, 
			(sod.MANUAL) as qty_opname
	from	inventory.stok_opname so,
			master.ruangan r,
			inventory.stok_opname_detil sod 
			left outer join inventory.barang_ruangan br 
			on	sod.BARANG_RUANGAN = br.id
			left outer join inventory.barang b 
			on br.BARANG = b.ID 
			left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
			on b.id		= mapKOpname.id_inventory
			left outer join
			(
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
					where	concat((xsorting),(katalog_kode)) in
							(
								select		concat(max(xsorting),max(katalog_kode))
									from	tjurnal_penerimaanall
									where	sts_proses 		 = 1 
									group   by katalog_kode
							)
			) hargaPerolehanTerakhir
			on hargaPerolehanTerakhir.katalog_kode = b.KODE_BARANG
	where	so.id		= sod.STOK_OPNAME and
			r.ID     	= so.RUANGAN and
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
	order	by r.DESKRIPSI,
				case COALESCE(mapKOpname.katalog_kode,'')
					when '' then b.KODE_BARANG
					else mapKOpname.katalog_kode
				end;

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
	where	concat((xsorting),(katalog_kode)) in
			(
				select		concat(max(xsorting),max(katalog_kode))
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					group   by katalog_kode
			)
			
			
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
	where	concat((xsorting),(katalog_kode)) in
			(
				select		concat(max(xsorting),max(katalog_kode))
					from	tjurnal_penerimaanall
					where	sts_proses 		 = 1 
					group   by katalog_kode
			)




			
	order   by katalog_kode, tgl_vergudang desc, no_btb desc

select		concat(max(xsorting),max(katalog_kode)) as data
	from	tjurnal_penerimaanall
	where	sts_proses 		 = 1 
	group   by katalog_kode
					



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
				select			*
						from	rsfPelaporan.laporan_fifo f
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
















==============================================================	
	
	
			left outer join laporan_mutasi_saldo_simgos lmss
			on lmss.katalog_kode = opnameReport.katalog_kode



select		*
	from	(
				select 		max(queryOpname.katalog_kode) as katalog_kode, 
							max(queryOpname.katalog_id) as katalog_id, 
							max(queryOpname.katalog_nama) as katalog_nama, 
							sum(queryOpname.qty_opname) as qty,
							max(lmss.jumlah_opname + lmss.jumlah_opname_koreksi) as qty_adj
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											r.DESKRIPSI as depo,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											master.ruangan r,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											r.ID     	= so.RUANGAN and
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
									order	by r.DESKRIPSI,
												case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
												end 			
							) queryOpname
							left outer join laporan_mutasi_saldo_simgos lmss
							on lmss.katalog_kode = queryOpname.katalog_kode and
							   lmss.tahun        = 2022
					group	by queryOpname.katalog_kode
			) opnameReport
	order	by	abs(opnameReport.qty - qty_adj) desc,
				opnameReport.katalog_kode

select		opnameReport.*
			lmss.jumlah_opname + lmss.jumlah_opname_koreksi as qty_adj
	from	(
				select 		max(queryOpname.katalog_kode) as katalog_kode, 
							max(queryOpname.katalog_id) as katalog_id, 
							max(queryOpname.katalog_nama) as katalog_nama, 
							sum(queryOpname.qty_opname) as qty
					from	(
								select		case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
											end as katalog_kode,
											r.DESKRIPSI as depo,
											(b.ID) as katalog_id, 
											(b.NAMA) as katalog_nama, 
											(sod.MANUAL) as qty_opname
									from	inventory.stok_opname so,
											master.ruangan r,
											inventory.stok_opname_detil sod 
											left outer join inventory.barang_ruangan br 
											on	sod.BARANG_RUANGAN = br.id
											left outer join inventory.barang b 
											on br.BARANG = b.ID 
											left outer join rsfPelaporan.mmapping_koreksiopname mapKOpname
											on b.id		= mapKOpname.id_inventory
									where	so.id		= sod.STOK_OPNAME and
											r.ID     	= so.RUANGAN and
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
									order	by r.DESKRIPSI,
												case COALESCE(mapKOpname.katalog_kode,'')
													when '' then b.KODE_BARANG
													else mapKOpname.katalog_kode
												end 			
							) queryOpname
					group	by lmss.katalog_kode
			) opnameReport
			left outer join laporan_mutasi_saldo_simgos lmss
			on lmss.katalog_kode = queryOpname.katalog_kode
	order	by	abs(opnameReport.qty - (lmss.jumlah_opname + lmss.jumlah_opname_koreksi))) desc,
				opnameReport.katalog_kode





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




















alter table tjurnal_sakti add sts_mapping int null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_lama 	varchar(15) null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_baru    varchar(15) null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_primer  char(1) null;
alter table rsfPelaporan.tjurnal_sakti add katalog_kode_aksi    varchar(255) null;

-- reset status jurnal sakti
update 	tjurnal_sakti 
	set sts_mapping 		= '1', 
		katalog_kode_lama 	= null, 
		katalog_kode_baru 	= null, 
		katalog_kode_primer = null,
		katalog_kode_aksi 	= null,
	 	katalog_kode 		= null,
		katalog_nama 		= null;

-- keluarkan master barang sakti yang tidak terpakai / digunakan
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%terpakai%';
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%gunakan%';

-- keluarkan master barang sakti yang ada
select * from tjurnal_sakti ts where sts_mapping = 0 order by qty_akhir desc, qty_awal desc;
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '000758' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '001138' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';		

-- statistik
-- Jumlah Baris						5066
-- Jumlah Baris Tidak Digunakan		 311
-- Jumlah Baris diMapping			4755
select 'Jumlah Baris' as uraian, count(1) as jumlah from tjurnal_sakti ts
union all
select 'Jumlah Baris Tidak Digunakan' as uraian, count(1) as jumlah from tjurnal_sakti ts where sts_mapping = 0
union all
select 'Jumlah Baris diMapping' as uraian, count(1) as jumlah from tjurnal_sakti ts where sts_mapping = 1;

-- update dulu yang double			  41
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					where    sts_mapping = 1
					group   by tjs.sakti_nama
					having  count(1) > 1
			) updReff
	SET		upd.sts_mapping				= 2
	WHERE	upd.sakti_nama				= updReff.sakti_nama;
select * from tjurnal_sakti ts where sts_mapping = 2 order by sakti_nama;

-- sweeping double dan UPDATE
-- master_barang_SAKTI_Double.sql

-- update untuk nama sama
-- 4404
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- saldo awal beda (bandingkan data)
SELECT 		sakti.katalog_kode, sakti.sakti_nama, sakti.qty_awal, simgos.jumlah_awal
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	having  sakti.qty_awal <> simgos.jumlah_awal;

-- sweeping beda saldo awal
-- master_barang_SAKTI_bedaSaldoawal.sql

-- update hasil sweping
update rsfPelaporan.tjurnal_sakti set katalog_kode_lama = katalog_kode;
select * from rsfPelaporan.tjurnal_sakti where katalog_kode_baru <> '';
update 		rsfPelaporan.tjurnal_sakti 
	set 	katalog_kode = katalog_kode_baru
	where 	katalog_kode_baru <> '';

-- sweeing katalog_kode masih kosong 250
-- master_barang_SAKTI_kodeMasihKosong.sql
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

-- update hasil sweping
select * from rsfPelaporan.tjurnal_sakti where katalog_kode_baru <> '';
update 		rsfPelaporan.tjurnal_sakti 
	set 	katalog_kode = katalog_kode_baru
	where 	katalog_kode_baru <> '';

-- keluarkan lagi yang tidak digunakan
select * from tjurnal_sakti ts where UPPER(katalog_kode_primer) = 'X';
update 		rsfPelaporan.tjurnal_sakti 
	set 	sts_mapping = '9'
	where 	UPPER(katalog_kode_primer) = 'X';

-- cek ulang
select * from tjurnal_sakti ts where (sts_mapping = 1 or sts_mapping = 2) and katalog_kode is null;



----------------------------------------------------------------------------------------------------------
-- saldo awal beda (bandingkan data) : simrs 4718 vs sakti 4548 = 170, selisih 203
SELECT 		simrs.katalog_kode, simrs.katalog_kode_grp, simrs.qty_group as simrs_grp, 
			simrs.jumlah_awal as simrs_awal, 
			simrs.jumlah_pengadaan as simrs_beli,
			simrs.jumlah_produksi as simrs_produksi,
			simrs.jumlah_masuk as simrs_masuk,
			simrs.jumlah_keluar as simrs_keluar,
			simrs.jumlah_akhir as simrs_akhir,
			sakti.qty_awal as sakti_awal,
			sakti.qty_masuk as sakti_masuk, 
			sakti.qty_keluar as sakti_kelar, 
			sakti.qty_akhir as sakti_akhir, 
			sakti.qty_group as sakti_grp,
			sakti.sakti_nama, mk.katalog_nama
	from	(
				select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
							sum(qty_awal) as jumlah_awal,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
							sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
							sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir,
							count(1) as qty_group
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by lmss.katalog_kode
			) simrs
			left outer join
			(
				select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
							max(ts.sakti_kode) as sakti_kode,
							sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
							sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
							count(1) as qty_group
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							(sts_mapping = 1 or sts_mapping = 2)
					group   by ts.katalog_kode
			) sakti
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		max(b.NAMA) as katalog_nama,
							max(b.KODE_BARANG) as katalog_kode
					from 	inventory.barang b
					group   by b.KODE_BARANG
			) mk
			on simrs.katalog_kode_grp = mk.katalog_kode
	order 	by sakti.katalog_kode, simrs.katalog_kode_grp

select		*
	from	(
				SELECT 		max(simrs.katalog_kode_grp) as katalog_kode, 
							sum(simrs.qty_group) as simrs_grp, 
							sum(simrs.jumlah_awal) as simrs_awal, 
							sum(simrs.jumlah_pengadaan) as simrs_beli,
							sum(simrs.jumlah_produksi) as simrs_produksi,
							sum(simrs.jumlah_masuk) as simrs_masuk,
							sum(simrs.jumlah_keluar) as simrs_keluar,
							sum(simrs.jumlah_akhir) as simrs_akhir,
							max(sakti.qty_awal) as sakti_awal,
							max(sakti.qty_masuk) as sakti_masuk, 
							max(sakti.qty_keluar) as sakti_kelar, 
							max(sakti.qty_akhir) as sakti_akhir, 
							max(sakti.qty_group) as sakti_grp,
							case when max(sakti.sakti_kode) is null then 0 else 1 end as sakti_mapping,
							max(mk.katalog_nama) as katalog_nama
					from	(
								select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
											sum(qty_awal) as jumlah_awal,
											sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
											sum(jumlah_penerimaan + qty_penerimaan) as jumlah_pengadaan,
											sum(jumlah_produksi + qty_produksi) as jumlah_produksi,
											sum(( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) - jumlah_opname) as jumlah_keluar,
											sum(jumlah_opname) as jumlah_akhir,
											count(1) as qty_group
									FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
									group   by lmss.katalog_kode
							) simrs
							left outer join
							(
								select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
											max(ts.sakti_kode) as sakti_kode,
											sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
											sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
											count(1) as qty_group
									from 	tjurnal_sakti ts
									where   katalog_kode is not null and
											(sts_mapping = 1 or sts_mapping = 2)
									group   by ts.katalog_kode
							) sakti
							on sakti.katalog_kode = simrs.katalog_kode
							left outer join 
							(
								select 		max(b.NAMA) as katalog_nama,
											max(b.KODE_BARANG) as katalog_kode
									from 	inventory.barang b
									group   by b.KODE_BARANG
							) mk
							on simrs.katalog_kode_grp = mk.katalog_kode
					group   by simrs.katalog_kode_grp
			) tblPerbandingan
	order	by  sakti_mapping, katalog_kode

SELECT 		sakti.katalog_kode as sakti_kode,
			sakti.qty_group as sakti_grp,
			sakti.qty_awal, sakti.qty_masuk, sakti.qty_keluar, sakti.qty_akhir, 
			simrs.katalog_kode, simrs.katalog_kode_grp, simrs.jumlah_awal as simrs_awal, sakti.qty_awal as sakti_awal,
			simrs.qty_group as simrs_grp, 
			sakti.sakti_nama, mk.katalog_nama
	from	(
				select 		max(ts.katalog_kode) as katalog_kode, max(ts.sakti_nama) as sakti_nama, max(ts.sakti_nama_klp) as sakti_nama_klp, 
							max(ts.sakti_kode) as sakti_kode,
							sum(ts.qty_awal) as qty_awal, sum(ts.qty_masuk) as qty_masuk, 
							sum(ts.qty_keluar) as qty_keluar, sum(ts.qty_akhir) as qty_akhir, 
							count(1) as qty_group
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							(sts_mapping = 1 or sts_mapping = 2)
					group   by ts.katalog_kode
			) sakti
			left outer join
			(
				select		max(katalog_kode) as katalog_kode, max(katalog_kode_grp) as katalog_kode_grp, 
							sum(qty_awal) as jumlah_awal,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan)) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir,
							count(1) as qty_group
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by lmss.katalog_kode
			) simrs
			on sakti.katalog_kode = simrs.katalog_kode
			left outer join 
			(
				select 		max(b.NAMA) as katalog_nama,
							max(b.KODE_BARANG) as katalog_kode
					from 	inventory.barang b
					group   by b.KODE_BARANG
			) mk
			on simrs.katalog_kode_grp = mk.katalog_kode
	order 	by simrs.katalog_kode, simrs.katalog_kode_grp
--------------------------------------------------------------------------------------------------------------




-- cek yang masih kosong
-- 310 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;







select 		tjs.sakti_nama, tjs.katalog_nama 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama = tjs.katalog_nama 

select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama <> tjs.katalog_nama
	 		and tjs.katalog_kode is not null
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%terpakai%'
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%gunakan%'
	order   by qty_akhir desc, qty_awal desc
	
	KASA POUCHES ISI 10 (10 X 10 CM + INDIKATOR)-td digunakan
	
	
-- validasi barang tidak diproses, tetapi masih ada qty_akhir	
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sts_mapping = 0
	order   by qty_awal desc, qty_akhir desc;
	
-- data yang akan diproses
-- 4779 row
select * from tjurnal_sakti ts where sts_mapping = 1;

-- kosongkan kode
update 		tjurnal_sakti  
	set 	katalog_kode = null,
			katalog_nama = null;

-- update untuk nama sama
-- 4412
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- cek yang masih kosong
-- 367 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

-- update katalog_kode
-- 215 row
update tjurnal_sakti set katalog_kode = '70C034' where id = 95 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70P014' where id = 131 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70B012' where id = 164 and katalog_kode is null;
....

-- update berdasarkan kode stelah sweeping
-- 210 row
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.katalog_kode			= updReff.kode and
			upd.katalog_nama           is null;

-- query 5 barang yang tidak masuk
select * from tjurnal_sakti ts where katalog_nama is null and katalog_kode is not null;

-- row data yang masih belum ketemu mapping
-- 152 row
select * from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;
select sum(nilai_akhir) from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;










---------------------------------------------------------------------------------------------------------------

-- daftar barang yang double
-- double secara keseluruhan
-- double untuk nama yang berelasi
select 		nama_barang, count(1) as qtyDouble
	from 	rsfMaster.mkatalog_farmasi
	group   by nama_barang
	having  count(1) > 1

select		katf.id_teamterima,
			katf.id_inventory,
			katf.kode,
			katf.nama_barang,
			katf.kemasan
	from	rsfMaster.mkatalog_farmasi katf,
			(
				select		*
					from 	(
								select		nama_barang, count(1) as qtyDouble
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang in (
												select 		tjs.sakti_nama
													from 	rsfPelaporan.tjurnal_sakti tjs,
															rsfMaster.mkatalog_farmasi mf
													where	tjs.sakti_nama = mf.nama_barang
													group   by tjs.sakti_nama
													having  count(1) > 1
											)
									group   by nama_barang
							) mKatalog left outer join
							(
								select 		tjs.sakti_nama, count(1) as sakti_qtyDouble
									from 	rsfPelaporan.tjurnal_sakti tjs
									group   by tjs.sakti_nama
							) tSakti
							on  mKatalog.nama_barang = tSakti.sakti_nama
					having  mKatalog.qtyDouble > 1 and
							mKatalog.qtyDouble <> coalesce(tSakti.sakti_qtyDouble,0)
			) tDouble
	where	katf.nama_barang = tDouble.nama_barang


-- daftar barang yang double di SAKTI
select 		tjs.sakti_nama, count(1) as qtyDouble
	from 	rsfPelaporan.tjurnal_sakti tjs
	group   by tjs.sakti_nama
	having  count(1) > 1

select		sakti_nama_klp, sakti_kode, sakti_nama,
			qty_awal, qty_masuk, qty_keluar, qty_akhir
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama in (
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					group   by tjs.sakti_nama
					having  count(1) > 1
			)
	order	by sakti_nama;


--- update semua kode
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang;

-- yang masih null
-- 645
select		count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null;

select		substring(upd.sakti_nama,1,35), count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null
	group   by substring(upd.sakti_nama,1,35)
	having  count(1) > 1;

-- update pakai substring 50 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,50) = substring(mkatalogs.nama_barang,1,50)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,50)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,50) 	= substring(updReff.nama_barang,1,50) and
			upd.katalog_kode 				is null;

-- update pakai substring 40 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,40) = substring(mkatalogs.nama_barang,1,40)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,40)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,40) 	= substring(updReff.nama_barang,1,40) and
			upd.katalog_kode 				is null;

-- update pakai substring 35 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,35) = substring(mkatalogs.nama_barang,1,35)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,35)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,35) 	= substring(updReff.nama_barang,1,35) and
			upd.katalog_kode 				is null;


-- update pakai substring 30 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,30) = substring(mkatalogs.nama_barang,1,30)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,30)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,30) 	= substring(updReff.nama_barang,1,30) and
			upd.katalog_kode 				is null;

-- update pakai substring 25 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,25) = substring(mkatalogs.nama_barang,1,25)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,25)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,25) 	= substring(updReff.nama_barang,1,25) and
			upd.katalog_kode 				is null;

-- update pakai substring 20 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,20) = substring(mkatalogs.nama_barang,1,20)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,20)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,20) 	= substring(updReff.nama_barang,1,20) and
			upd.katalog_kode 				is null;

select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama <> katalog_nama;
	
select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	katalog_kode is null and 
			( qty_awal > 0 or qty_akhir > 0);


UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		* 
					from
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog,
											(
												select		sakti_nama_klp, sakti_kode, sakti_nama,
															qty_awal, qty_masuk, qty_keluar, qty_akhir
													from	rsfPelaporan.tjurnal_sakti
													where	sakti_nama in (
																select 		tjs.sakti_nama
																	from 	rsfPelaporan.tjurnal_sakti tjs
																	group   by tjs.sakti_nama
																	having  count(1) = 1
															)
											) tSakti
									where	mKatalog.nama_barang = tSakti.sakti_nama
							) test
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang;




UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		nama_barang, kode
					from	rsfMaster.mkatalog_farmasi
					where	nama_barang not in (
								select 		nama_barang
									from 	rsfMaster.mkatalog_farmasi
									group   by nama_barang
									having  count(1) > 1
							)
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sakti_nama in (
									select 		tjs.sakti_nama
										from 	rsfPelaporan.tjurnal_sakti tjs
										group   by tjs.sakti_nama
										having  count(1) = 1
								)






update rsfPelaporan.tjurnal_sakti set katalog_kode_lama = katalog_kode;
select * from rsfPelaporan.tjurnal_sakti where katalog_kode_baru <> '';
update 		rsfPelaporan.tjurnal_sakti 
	set 	katalog_kode = katalog_kode_baru
	where 	katalog_kode_baru <> '';

update 		rsfPelaporan.tjurnal_sakti 
	set 	sts_mapping = '3'
	where 	UPPER(katalog_kode_primer) <> 'X';

katalog_kode_primer



select * from rsfPelaporan.tjurnal_sakti  where sts_mapping = 1 and katalog_kode is null;
select * from rsfPelaporan.tjurnal_sakti  where upper(katalog_kode_primer) = 'X';

select katalog_kode_aksi, ts.* from rsfPelaporan.tjurnal_sakti  ts where sts_mapping = 1 and katalog_kode_aksi is not null;

SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   sts_mapping = 1 and katalog_kode is null
			) sakti
			left outer join
			(
				select		katalog_kode, qty_awal as jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode;

-- MASTER BARANG
-- cek duplikasi kode
select 		kode
	from 	rsfMaster.mkatalog_farmasi 
	where 	kode is not null
	group   by kode
	having  count(1) > 1;

-- keluarkan master barang dan kodenya
select 		kode as katalog_kd, nama_barang as katalog_nm
	from 	rsfMaster.mkatalog_farmasi 
	order   by kode

-- keluarkan master barang sakti yang ada
select * from tjurnal_sakti ts where sts_mapping = 0 order by qty_akhir desc, qty_awal desc;
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '000758' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';
update 		tjurnal_sakti 
	set 	sts_mapping = 1 
	where 	sakti_kode = '001138' and 
			sakti_nama_klp = 'OBAT LAINNYA (PERSEDIAAN LAINNYA)';		
SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, qty_awal as jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode;



select count(1) from rsfPelaporan.tjurnal_sakti;
select count(1) from rsfPelaporan.tjurnal_saktix;
select sum(nilai_akhir)  from tjurnal_sakti;
select sum(nilai_akhir)  from tjurnal_saktix;

UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		*
					from 	rsfPelaporan.tjurnal_saktix
			) as updReff
	SET		upd.qty_awal				= updReff.qty_awal,
			upd.qty_masuk				= updReff.qty_masuk,
			upd.qty_keluar				= updReff.qty_keluar,
			upd.qty_akhir				= updReff.qty_akhir,
			upd.nilai_awal				= updReff.nilai_awal,
			upd.nilai_akhir				= updReff.nilai_akhir
	WHERE	upd.sakti_kode				= updReff.sakti_kode and
			upd.sakti_nama_klp          = updReff.sakti_nama_klp;

------- saldo awal beda (bandingkan data)
SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, qty_awal as jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	having  sakti.qty_awal <> simgos.jumlah_awal;

SELECT 		* -- sum(sakti.qty_akhir), sum(simgos.jumlah_akhir)
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
			) sakti
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	 having  sakti.qty_akhir <> simgos.jumlah_akhir;

SELECT 		*
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		max(katalog_kode_grp) as katalog_kode_grp, 
							max(katalog_kode) as katalog_kode, 
							sum(jumlah_awal) as jumlah_awal,
							sum(jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_masuk,
							sum(jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan)) as jumlah_keluar,
							sum(jumlah_opname) as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
					group   by katalog_kode
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
			left outer join
			(
				select 		katalog_kode, max(nilai_hppb) as nilai_hppb
					from 	tjurnal_penerimaan tp 
					where   CONCAT(katalog_kode,'tgl', DATE_FORMAT((tgl_terima),'%Y%m%d')) in
							(
								select 		CONCAT(katalog_kode,'tgl', DATE_FORMAT(max(tgl_terima),'%Y%m%d'))
									from 	tjurnal_penerimaan
									group   by katalog_kode
							)
					group   by katalog_kode
			) harga
			on sakti.katalog_kode = harga.katalog_kode
	having  sakti.qty_akhir <> simgos.jumlah_akhir
    order   by simgos.katalog_kode_grp;
			

--------------------------------------------------------------------- proses -----------------------------

-- 5066 ROW
--  183 ROW - td dipakai
--  130 ROW - td digunakan
--   41 row - double
-- 4712
--  308 row - mapping tidak cocok
-- 4404 row - terMapping berdasarkan nama

1. laporan persediaan per 31 desember
   kode, nama barang, qty, nilai akhir
2. laporan rincian persediaan
   kode, nama barang, trx-in, trx-out, saldo-akhir, nilai-akhir
3. buku persediaan
   trx per barang   
4. neraca persediaan
   kelompok barang, saldo-akhir, nilai-akhir
5. Laporan Fifo saldo-akhir
6. Mapping sakti
   
---------------
-- 4779 row

update tjurnal_sakti  set sts_mapping = '1';
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%terpakai%';
update tjurnal_sakti  set sts_mapping = 0 
	where   sakti_nama like '%gunakan%';
select * from tjurnal_sakti ts where sts_mapping = 0 order by qty_akhir desc, qty_awal desc;
select * from tjurnal_sakti ts where sts_mapping = 1;

-- update dulu yang double2
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					where    sts_mapping = 1
					group   by tjs.sakti_nama
					having  count(1) > 1
			) updReff
	SET		upd.sts_mapping				= 2
	WHERE	upd.sakti_nama				= updReff.sakti_nama;
select * from tjurnal_sakti ts where sts_mapping = 2 order by sakti_nama;

-- update yang nama sesuai
-- kosongkan kode
update 		tjurnal_sakti  
	set 	katalog_kode = null,
			katalog_nama = null;

-- update untuk nama sama
-- 4412
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- cek yang masih kosong
-- 367 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

------- saldo awal beda (bandingkan data)
SELECT 		sakti.katalog_kode, sakti.sakti_nama, sakti.qty_awal, simgos.jumlah_awal
	from	(
				select 		ts.katalog_kode, ts.sakti_nama, ts.sakti_nama_klp, ts.sakti_kode,
							ts.qty_awal, ts.qty_masuk, ts.qty_keluar, ts.qty_akhir 
					from 	tjurnal_sakti ts
					where   katalog_kode is not null and
							sts_mapping = 1
			) sakti
			left outer join
			(
				select		katalog_kode, jumlah_awal,
							jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan as jumlah_masuk,
							jumlah_opname - ( qty_awal + jumlah_produksi + jumlah_penerimaan + qty_produksi + qty_penerimaan) as jumlah_keluar,
							jumlah_opname as jumlah_akhir
					FROM 	rsfPelaporan.laporan_mutasi_saldo_simgos lmss
			) simgos
			on sakti.katalog_kode = simgos.katalog_kode
	having  sakti.qty_awal <> simgos.jumlah_awal;










select 		tjs.sakti_nama, tjs.katalog_nama 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama = tjs.katalog_nama 

select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama <> tjs.katalog_nama
	 		and tjs.katalog_kode is not null
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%terpakai%'
	 		
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sakti_nama like '%gunakan%'
	order   by qty_akhir desc, qty_awal desc
	
	KASA POUCHES ISI 10 (10 X 10 CM + INDIKATOR)-td digunakan
	
	
-- validasi barang tidak diproses, tetapi masih ada qty_akhir	
select 		tjs.sakti_nama, tjs.katalog_nama, tjs.qty_awal, tjs.qty_akhir 
	from 	rsfPelaporan.tjurnal_sakti tjs
	where   tjs.sts_mapping = 0
	order   by qty_awal desc, qty_akhir desc;
	
-- data yang akan diproses
-- 4779 row
select * from tjurnal_sakti ts where sts_mapping = 1;

-- kosongkan kode
update 		tjurnal_sakti  
	set 	katalog_kode = null,
			katalog_nama = null;

-- update untuk nama sama
-- 4412
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sts_mapping             = 1;

-- cek yang masih kosong
-- 367 row
select * from tjurnal_sakti ts where sts_mapping = 1 and katalog_kode is null;

-- update katalog_kode
-- 215 row
update tjurnal_sakti set katalog_kode = '70C034' where id = 95 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70P014' where id = 131 and katalog_kode is null;
update tjurnal_sakti set katalog_kode = '70B012' where id = 164 and katalog_kode is null;
....

-- update berdasarkan kode stelah sweeping
-- 210 row
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.katalog_kode			= updReff.kode and
			upd.katalog_nama           is null;

-- query 5 barang yang tidak masuk
select * from tjurnal_sakti ts where katalog_nama is null and katalog_kode is not null;

-- row data yang masih belum ketemu mapping
-- 152 row
select * from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;
select sum(nilai_akhir) from tjurnal_sakti ts where katalog_kode is null and sts_mapping = 1;










---------------------------------------------------------------------------------------------------------------

-- daftar barang yang double
-- double secara keseluruhan
-- double untuk nama yang berelasi
select 		nama_barang, count(1) as qtyDouble
	from 	rsfMaster.mkatalog_farmasi
	group   by nama_barang
	having  count(1) > 1

select		katf.id_teamterima,
			katf.id_inventory,
			katf.kode,
			katf.nama_barang,
			katf.kemasan
	from	rsfMaster.mkatalog_farmasi katf,
			(
				select		*
					from 	(
								select		nama_barang, count(1) as qtyDouble
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang in (
												select 		tjs.sakti_nama
													from 	rsfPelaporan.tjurnal_sakti tjs,
															rsfMaster.mkatalog_farmasi mf
													where	tjs.sakti_nama = mf.nama_barang
													group   by tjs.sakti_nama
													having  count(1) > 1
											)
									group   by nama_barang
							) mKatalog left outer join
							(
								select 		tjs.sakti_nama, count(1) as sakti_qtyDouble
									from 	rsfPelaporan.tjurnal_sakti tjs
									group   by tjs.sakti_nama
							) tSakti
							on  mKatalog.nama_barang = tSakti.sakti_nama
					having  mKatalog.qtyDouble > 1 and
							mKatalog.qtyDouble <> coalesce(tSakti.sakti_qtyDouble,0)
			) tDouble
	where	katf.nama_barang = tDouble.nama_barang


-- daftar barang yang double di SAKTI
select 		tjs.sakti_nama, count(1) as qtyDouble
	from 	rsfPelaporan.tjurnal_sakti tjs
	group   by tjs.sakti_nama
	having  count(1) > 1

select		sakti_nama_klp, sakti_kode, sakti_nama,
			qty_awal, qty_masuk, qty_keluar, qty_akhir
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama in (
				select 		tjs.sakti_nama
					from 	rsfPelaporan.tjurnal_sakti tjs
					group   by tjs.sakti_nama
					having  count(1) > 1
			)
	order	by sakti_nama;


--- update semua kode
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
					from 	(
								select		nama_barang, kode
									from	rsfMaster.mkatalog_farmasi
									where	nama_barang not in (
												select 		nama_barang
													from 	rsfMaster.mkatalog_farmasi
													group   by nama_barang
													having  count(1) > 1
											)
							) mKatalog
			) as updReff
	SET		upd.katalog_kode			= updReff.kode,
			upd.katalog_nama			= updReff.nama_barang
	WHERE	upd.sakti_nama				= updReff.nama_barang;

-- yang masih null
-- 645
select		count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null;

select		substring(upd.sakti_nama,1,35), count(1)
	from	rsfPelaporan.tjurnal_sakti upd
	where	upd.katalog_kode is null
	group   by substring(upd.sakti_nama,1,35)
	having  count(1) > 1;

-- update pakai substring 50 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,50) = substring(mkatalogs.nama_barang,1,50)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,50)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,50) 	= substring(updReff.nama_barang,1,50) and
			upd.katalog_kode 				is null;

-- update pakai substring 40 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,40) = substring(mkatalogs.nama_barang,1,40)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,40)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,40) 	= substring(updReff.nama_barang,1,40) and
			upd.katalog_kode 				is null;

-- update pakai substring 35 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,35) = substring(mkatalogs.nama_barang,1,35)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,35)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,35) 	= substring(updReff.nama_barang,1,35) and
			upd.katalog_kode 				is null;


-- update pakai substring 30 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,30) = substring(mkatalogs.nama_barang,1,30)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,30)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,30) 	= substring(updReff.nama_barang,1,30) and
			upd.katalog_kode 				is null;

-- update pakai substring 25 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,25) = substring(mkatalogs.nama_barang,1,25)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,25)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,25) 	= substring(updReff.nama_barang,1,25) and
			upd.katalog_kode 				is null;

-- update pakai substring 20 karakter
UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		max(sakti.sakti_nama) as sakti_nama, 
							max(mkatalogs.nama_barang) as nama_barang,
							max(mkatalogs.kode) as kode
					from	rsfPelaporan.tjurnal_sakti sakti
							join
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog
							) mkatalogs
							on substring(sakti.sakti_nama,1,20) = substring(mkatalogs.nama_barang,1,20)
					where	sakti.katalog_kode is null
					group   by substring(sakti.sakti_nama,1,20)
					having  count(1) = 1
			) as updReff
	SET		upd.katalog_kode				= updReff.kode,
			upd.katalog_nama				= updReff.nama_barang
	WHERE	substring(upd.sakti_nama,1,20) 	= substring(updReff.nama_barang,1,20) and
			upd.katalog_kode 				is null;

select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	sakti_nama <> katalog_nama;
	
select		sakti_nama, katalog_nama
	from	rsfPelaporan.tjurnal_sakti
	where	katalog_kode is null and 
			( qty_awal > 0 or qty_akhir > 0);


UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		* 
					from
							(
								select		mKatalog.nama_barang as nama_barang, mKatalog.kode as kode
									from 	(
												select		nama_barang, kode
													from	rsfMaster.mkatalog_farmasi
													where	nama_barang not in (
																select 		nama_barang
																	from 	rsfMaster.mkatalog_farmasi
																	group   by nama_barang
																	having  count(1) > 1
															)
											) mKatalog,
											(
												select		sakti_nama_klp, sakti_kode, sakti_nama,
															qty_awal, qty_masuk, qty_keluar, qty_akhir
													from	rsfPelaporan.tjurnal_sakti
													where	sakti_nama in (
																select 		tjs.sakti_nama
																	from 	rsfPelaporan.tjurnal_sakti tjs
																	group   by tjs.sakti_nama
																	having  count(1) = 1
															)
											) tSakti
									where	mKatalog.nama_barang = tSakti.sakti_nama
							) test
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang;




UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select		nama_barang, kode
					from	rsfMaster.mkatalog_farmasi
					where	nama_barang not in (
								select 		nama_barang
									from 	rsfMaster.mkatalog_farmasi
									group   by nama_barang
									having  count(1) > 1
							)
			) as updReff
	SET		upd.katalog_kode			= updReff.kode
	WHERE	upd.sakti_nama				= updReff.nama_barang and
			upd.sakti_nama in (
									select 		tjs.sakti_nama
										from 	rsfPelaporan.tjurnal_sakti tjs
										group   by tjs.sakti_nama
										having  count(1) = 1
								)

