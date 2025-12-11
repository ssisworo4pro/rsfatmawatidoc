select 		vouTrxs.no_bku 					as no_bku,
		    vouTrxs.tgl_bku 				as tgl_bku,
			IF( teamTrmx.tgl_doc < '2023-01-01', 'hutang', '') as sts_hutang,
			LEFT(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),INSTR(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),"/")-1) as KLP_NOMOR,
			teamTrmx.tgl_doc				as tgl_terima,
			teamTrmx.no_doc 				as no_terima,
			teamTrmx.kode 					as no_btb,
			teamTrmx.ver_tglgudang			as tgl_verifikasi_gudang,
			teamTrmx.id_pbf					as id_pbf,
			teamTrmxPbf.kode				as kode_pbf,
			teamTrmxPbf.nama_pbf			as nama_pbf,
		    teamMasterK.kode				as kode,
			teamMasterK.nama_barang			as nama_barang,
			teamTrmxDtl.jumlah_item							as qty_terima,
			returrekanan.jumlah_item 						as qty_retur,
			teamTrmxDtl.jumlah_item - 
			COALESCE(returrekanan.jumlah_item,0)			as qty_terima_bersih,
			teamTrmxDtl.hp_item								as nilai_hp,
			teamTrmxDtl.hppb_item							as nilai_hppb,
			( teamTrmxDtl.jumlah_item - 
			  COALESCE(returrekanan.jumlah_item,0) )
			* teamTrmxDtl.hppb_item							as nilai_total,
			teamTrmx.nilai_akhir 							as nilai_akhir,
			vouTrxs.id_mst_mt_anggaran as id_mt_anggaran,
			vouTrxs.nm_mt_anggaran as nm_mt_anggaran
	from 	(
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan,
							max(vouTrx.no_bku) as no_bku,
							max(vouTrx.tgl_bku) as tgl_bku,
							max(vouTrx.id_mst_mt_anggaran) as id_mst_mt_anggaran,
							max(vouMst.nm_mt_anggaran) as nm_mt_anggaran
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas,
							rsfVoucher.keu_mst_mt_anggaran vouMst
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	= vouMst.id_mst_mt_anggaran and
							vouTrx.tgl_bku 				>= '2023-01-01' and 
							vouTrx.tgl_bku 				 < '2023-05-01'
					group   by 	vouBerkasBa.no_ba_penerimaan
			) vouTrxs
			left outer join
			rsfTeamterima.transaksif_penerimaan teamTrmx
			on
			teamTrmx.no_doc 			= vouTrxs.no_ba_penerimaan and
			teamTrmx.ver_gudang 		 = 1
			left outer join
			rsfTeamterima.tdetailf_penerimaan teamTrmxDtl
			on 
			teamTrmx.kode 				 = teamTrmxDtl.kode_reff
			left outer join
			(
				select 		max(rcn.kode_refftrm) as kode_refftrm, max(rcndtl.id_katalog) as id_katalog,
							sum(rcndtl.jumlah_item) as jumlah_item, sum(rcndtl.jumlah_kemasan) as jumlah_kemasan
					from 	rsfTeamterima.tdetailf_return rcndtl, rsfTeamterima.transaksif_return rcn
					where 	rcn.kode 			= rcndtl.kode_reff AND
							rcn.ver_gudang      = 1 and
							rcn.sts_deleted		= 0
					group   by rcn.kode_refftrm, rcndtl.id_katalog
			) returrekanan
			on
			teamTrmx.kode 				= returrekanan.kode_refftrm AND
			teamTrmxDtl.id_reffkatalog  = returrekanan.id_katalog
			left outer join rsfTeamterima.masterf_katalog teamMasterK
			on
			teamMasterK.kode 			 = teamTrmxDtl.id_reffkatalog
			left outer join rsfTeamterima.masterf_pbf teamTrmxPbf
			on teamTrmx.id_pbf 			 = teamTrmxPbf.id
	order	by 	vouTrxs.no_bku,
				vouTrxs.tgl_bku,
				LEFT(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),INSTR(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),"/")-1)
