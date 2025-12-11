select 		LEFT(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),INSTR(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),"/")-1) as KLP_NOMOR,
			teamTrmx.tgl_doc				as tgl_terima,
			teamTrmx.no_doc 				as no_terima,
			teamTrmx.kode 					as no_btb,
			teamTrmx.ver_tglgudang			as tgl_verifikasi_gudang,
			-- teamTrmx.ver_gudang 			as sts_verifikasi_gudang,
			teamTrmx.id_pbf					as id_pbf,
			teamTrmxPbf.kode				as kode_pbf,
			teamTrmxPbf.nama_pbf			as nama_pbf,
		    vouTrxs.no_bku 					as no_bku,
		    vouTrxs.tgl_bku 				as tgl_bku,
			teamMasterK.kode				as kode,
		    masterBarang.KODE_PERSEDIAAN	as sub_kelompok,
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
			teamTrmx.nilai_akhir 							as nilai_akhir
	from 	rsfTeamterima.transaksif_penerimaan teamTrmx
			left outer join
			(
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan,
							max(vouTrx.no_bku) as no_bku,
							max(vouTrx.tgl_bku) as tgl_bku
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	in
							( select 	id_mst_mt_anggaran 
								from 	rsfVoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran 	 = '20202020' and 
										nm_mt_anggaran 	 = '- Belanja Barang Farmasi' ) and
							vouTrx.tgl_bku 				>= '2020-01-01' and 
							vouTrx.tgl_bku 				 < '2023-01-01'
					group   by 	vouBerkasBa.no_ba_penerimaan
			) vouTrxs
			on
			teamTrmx.no_doc 			= vouTrxs.no_ba_penerimaan
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
							rcn.ver_gudang      = 1
					group   by rcn.kode_refftrm, rcndtl.id_katalog
			) returrekanan
			on
			teamTrmx.kode 				= returrekanan.kode_refftrm AND
			teamTrmxDtl.id_reffkatalog  = returrekanan.id_katalog,
			rsfTeamterima.masterf_katalog teamMasterK
			left outer join 
			(
				select 		kode as KODE_BARANG, kode_sakti as KODE_PERSEDIAAN
					from	rsfTeamterima.masterf_katalog_sakti
			) masterBarang
			on 
			teamMasterK.kode			 = masterBarang.KODE_BARANG,
			rsfTeamterima.masterf_pbf teamTrmxPbf
	where	teamTrmx.id_pbf 			 = teamTrmxPbf.id and
			teamMasterK.kode 			 = teamTrmxDtl.id_reffkatalog and
			teamTrmx.tgl_doc 			>= '2020-01-01' and 
			teamTrmx.tgl_doc 			 < '2021-01-01' and 
			-- vouTrxs.tgl_bku				is null and
			teamTrmx.ver_gudang 		 = 1
	order	by 	LEFT(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),INSTR(SUBSTRING(teamTrmx.no_doc,INSTR(teamTrmx.no_doc,"/")+1),"/")-1),
				teamTrmx.tgl_doc, 
				teamTrmx.no_doc
