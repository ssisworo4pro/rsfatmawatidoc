select 		vouTrxs.no_bku 					as no_bku,
		    vouTrxs.tgl_bku 				as tgl_bku,
			teamTrmx.no_doc 				as no_terima,
			teamTrmx.kode 					as no_btb,
		    teamMasterK.kode,
		    masterBarang.KODE_PERSEDIAAN	as sub_kelompok,
			teamMasterK.nama_barang,
			teamTrmxDtl.jumlah_item,
			teamTrmxDtl.hp_item,
			teamTrmxDtl.jumlah_item * teamTrmxDtl.hp_item as total_item,
			teamTrmx.nilai_pembulatan as totaltrm_nilai_pembulatan,
			teamTrmx.nilai_akhir as totaltrm_nilai_akhir
			/*teamTrmxDtl.harga_item,
			teamTrmxDtl.diskon_item,
			teamTrmxDtl.diskon_harga,
			teamTrmxDtl.hna_item,
			teamTrmxDtl.hppb_item,
			teamTrmxDtl.phja_item,
			teamTrmxDtl.phjapb_item,
			teamTrmxDtl.hja_item,
			teamTrmxDtl.hppb_item,
			teamTrmx.ppn as totaltrm_ppn,
			teamTrmx.nilai_total as totaltrm_nilai_total,
			teamTrmx.nilai_diskon as totaltrm_nilai_diskon,
			teamTrmx.nilai_ppn as totaltrm_nilai_ppn,
			teamTrmx.nilai_pembulatan as totaltrm_nilai_pembulatan,
			teamTrmx.nilai_akhir as totaltrm_nilai_akhir*/
	from 	rsfTeamterima.transaksif_penerimaan teamTrmx,
			rsfTeamterima.tdetailf_penerimaan teamTrmxDtl,
			(
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan,
							max(vouTrx.no_bku) as no_bku,
							max(vouTrx.tgl_bku) as tgl_bku
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	=
							( select 	id_mst_mt_anggaran 
								from 	rsfVoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran 	= '20222022' and 
										nm_mt_anggaran 	= '- Barang Farmasi' ) and
							vouTrx.tgl_bku 				> '2022-01-01' and 
							vouTrx.tgl_bku 				< '2022-12-01'
					group   by 	vouBerkasBa.no_ba_penerimaan
			) vouTrxs,
			rsfTeamterima.masterf_katalog teamMasterK
			left outer join 
			(
				select 		kode as KODE_BARANG, kode_sakti as KODE_PERSEDIAAN
					from	rsfTeamterima.masterf_katalog_sakti
			) masterBarang
			on 
			teamMasterK.kode			= masterBarang.KODE_BARANG
			/*left outer join 
			(
				select 		KODE_BARANG, max(KODE_PERSEDIAAN) as KODE_PERSEDIAAN
					from	inventory.barang
					where   KODE_BARANG is not null
					group   by KODE_BARANG
			) masterBarang
			on 
			teamMasterK.kode			= masterBarang.KODE_BARANG*/
	where	teamTrmx.kode 				= teamTrmxDtl.kode_reff and
			teamMasterK.kode 			= teamTrmxDtl.id_reffkatalog and
			teamTrmx.no_doc 			= vouTrxs.no_ba_penerimaan
	order	by vouTrxs.no_bku



------------------------------


select 		vouTrxs.no_bku 					as no_bku,
		    vouTrxs.tgl_bku 				as tgl_bku,
			teamTrmx.no_doc 				as no_terima,
			teamTrmx.kode 					as no_btb,
		    teamMasterK.kode,
		    masterBarang.KODE_PERSEDIAAN	as sub_kelompok,
			teamMasterK.nama_barang,
			teamTrmxDtl.jumlah_item,
			teamTrmxDtl.hp_item,
			teamTrmxDtl.jumlah_item * teamTrmxDtl.hp_item as total_item,
			teamTrmx.nilai_pembulatan as totaltrm_nilai_pembulatan,
			teamTrmx.nilai_akhir as totaltrm_nilai_akhir
			/*teamTrmxDtl.harga_item,
			teamTrmxDtl.diskon_item,
			teamTrmxDtl.diskon_harga,
			teamTrmxDtl.hna_item,
			teamTrmxDtl.hppb_item,
			teamTrmxDtl.phja_item,
			teamTrmxDtl.phjapb_item,
			teamTrmxDtl.hja_item,
			teamTrmxDtl.hppb_item,
			teamTrmx.ppn as totaltrm_ppn,
			teamTrmx.nilai_total as totaltrm_nilai_total,
			teamTrmx.nilai_diskon as totaltrm_nilai_diskon,
			teamTrmx.nilai_ppn as totaltrm_nilai_ppn,
			teamTrmx.nilai_pembulatan as totaltrm_nilai_pembulatan,
			teamTrmx.nilai_akhir as totaltrm_nilai_akhir*/
	from 	rsfLiveteamterima.transaksif_penerimaan teamTrmx,
			rsfLiveteamterima.tdetailf_penerimaan teamTrmxDtl,
			(
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan,
							max(vouTrx.no_bku) as no_bku,
							max(vouTrx.tgl_bku) as tgl_bku
					from 	rsfLivevoucher.keu_trx_voucher vouTrx,
							rsfLivevoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfLivevoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	=
							( select 	id_mst_mt_anggaran 
								from 	rsfLivevoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran 	= '20222022' and 
										nm_mt_anggaran 	= '- Barang Farmasi' ) and
							vouTrx.tgl_bku 				> '2022-01-01' and 
							vouTrx.tgl_bku 				< '2022-12-01'
					group   by 	vouBerkasBa.no_ba_penerimaan
			) vouTrxs,
			rsfLiveteamterima.masterf_katalog teamMasterK
			left outer join 
			(
				select 		kode as KODE_BARANG, kode_sakti as KODE_PERSEDIAAN
					from	rsfTeamterima.masterf_katalog_sakti
			) masterBarang
			on 
			teamMasterK.kode			= masterBarang.KODE_BARANG
			/*left outer join 
			(
				select 		KODE_BARANG, max(KODE_PERSEDIAAN) as KODE_PERSEDIAAN
					from	inventory.barang
					where   KODE_BARANG is not null
					group   by KODE_BARANG
			) masterBarang
			on 
			teamMasterK.kode			= masterBarang.KODE_BARANG*/
	where	teamTrmx.kode 				= teamTrmxDtl.kode_reff and
			teamMasterK.kode 			= teamTrmxDtl.id_reffkatalog and
			teamTrmx.no_doc 			= vouTrxs.no_ba_penerimaan
	order	by vouTrxs.no_bku
