							 select 	mts.nm_sumber,
							 			mtss.nm_sumber_sub,
							 			mta.kd_th_anggaran, mta.nm_mt_anggaran, 
							 			mta.* 
								from 	rsfVoucher.keu_mst_mt_anggaran mta,
										rsfVoucher.keu_mst_sumberdana mts,
										rsfVoucher.keu_mst_sumberdana_sub mtss
								where 	mta.kd_th_anggaran 	 = '20232023'
										and mts.id_mst_sumberdana = mtss.id_mst_sumberdana 
										and mta.id_mst_sumberdana_sub = mtss.id_mst_sumberdana_sub -- and 
										-- nm_mt_anggaran 	 = 'Barang Farmasi' 
