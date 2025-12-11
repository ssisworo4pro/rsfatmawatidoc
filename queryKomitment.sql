-- link voucer ke teamTerima, tidak dapat digunakan karena selalu null no_ba_terima
select * from keu_trx_voucher.no_ba_terima
select * from transaksif_penerimaan.no_doc

-- medapatkan voucher yang sudah dibayar
select 		vouTrx.no_ba_terima,
			vouTrx.no_spmk,
			vouTrx.uraian
	from 	rsfVoucher.keu_trx_voucher vouTrx
	where	vouTrx.id_mst_mt_anggaran =
			( select 	id_mst_mt_anggaran 
				from 	rsfVoucher.keu_mst_mt_anggaran
				where 	kd_th_anggaran = '20222022' and 
						nm_mt_anggaran = '- Barang Farmasi' ) and
			vouTrx.tgl_bku > '2022-01-01' and
			vouTrx.tgl_bku < '2022-02-01'
			limit 10;

-- kasus 1 : query dibawah ini ada kasus sts_kontrak_spk_spmk / no_spmk null,
--           tetapi no_ba_penerimaan terisi
select 		vouBerkas.id_trx_berkas_tagihan,
			vouBerkas.no_tracking_tagihan,
			vouBerkas.no_perencanaan,
			vouBerkas.sts_kontrak_spk_spmk,
			vouBerkasBa.no_ba_penerimaan,
			vouTrx.no_spmk, 
			vouTrx.uraian
	from 	rsfVoucher.keu_trx_voucher vouTrx
			left outer join rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa
			on vouTrx.id_trx_voucher  = vouBerkasBa.id_trx_voucher,
	        rsfVoucher.keu_trx_berkas_tagihan vouBerkas
	where	vouTrx.id_trx_voucher     = vouBerkas.id_trx_voucher and
			vouTrx.id_mst_mt_anggaran =
			( select 	id_mst_mt_anggaran 
				from 	rsfVoucher.keu_mst_mt_anggaran
				where 	kd_th_anggaran = '20222022' and 
						nm_mt_anggaran = '- Barang Farmasi' ) and
			vouTrx.tgl_bku > '2022-03-01' and 
			vouTrx.tgl_bku < '2022-04-01' and
			limit 310;
			
-- cek penerimaan lebih dari 1 untuk 1 voucher 
-- (ternyata bukan banyak terima, tapi banyak faktur, terima tetap 1)
-- kasus 2 : id_trx_berkas_tagihan 202203000171, banyak nomor faktur
select 		max(vouTrx.id_trx_voucher),
			max(vouBerkas.id_trx_berkas_tagihan),
			max(vouBerkasBa.no_ba_penerimaan),
			count(1),
			max(vouTrx.no_spmk), 
			max(vouTrx.uraian)
	from 	rsfVoucher.keu_trx_voucher vouTrx,
			rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
	        rsfVoucher.keu_trx_berkas_tagihan vouBerkas
	where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
			vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
			vouTrx.id_mst_mt_anggaran 	=
			( select 	id_mst_mt_anggaran 
				from 	rsfVoucher.keu_mst_mt_anggaran
				where 	kd_th_anggaran = '20222022' and 
						nm_mt_anggaran = '- Barang Farmasi' ) and
			vouTrx.tgl_bku > '2022-03-01' and 
			vouTrx.tgl_bku < '2022-04-01'
	group   by 	vouTrx.id_trx_voucher,
				vouBerkasBa.no_ba_penerimaan
	having  count(1) > 1;
	
select		* from keu_trx_berkas_tagihan_ba_penerimaan where id_trx_voucher = '202203000289';
select		* from keu_trx_berkas_tagihan_ba_penerimaan where id_trx_voucher = '202201000141';
select		* from keu_trx_berkas_tagihan_ba_penerimaan where id_trx_voucher = '202210000179';

-- CEK 1 voucer banyak penerimaan
select		id_trx_voucher, count(1)
	from	(
				select 		vouTrx.id_trx_voucher, 
							vouBerkasBa.no_ba_penerimaan
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	=
							( select 	id_mst_mt_anggaran 
								from 	rsfVoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran = '20222022' and 
										nm_mt_anggaran = '- Barang Farmasi' ) and
							vouTrx.tgl_bku > '2022-01-01' and 
							vouTrx.tgl_bku < '2022-02-01'
					group   by 	vouTrx.id_trx_voucher,
								vouBerkasBa.no_ba_penerimaan
			) qVouTeamterima
	group	by id_trx_voucher
	having  count(1) > 1

-- cek 1 voucher, banyak faktur & banyak terima
-- ada juga kasus banyak faktur tapi 1 terima
-- kasus 3 : kok nomor faktur di terima sama nomor faktur di terima berkas beda yach
select		teamTrm.tgl_doc   			as terima_tanggal,
			teamTrm.no_doc    			as terima_nomor,
			teamTrm.kode      			as terima_kode,
			teamTrm.revisike  			as terima_revke,
			teamTrm.no_faktur 			as faktur_nomor,
			teamTrm.tgl_faktur          as faktur_tanggal,
			teamTrm.tgl_tukar_faktur	as faktur_tanggal_tukar
	from	rsfTeamterima.transaksif_penerimaan teamTrm
	where	no_doc in (
			select 		vouBerkasBa.no_ba_penerimaan
				from 	rsfVoucher.keu_trx_voucher vouTrx,
						rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
						rsfVoucher.keu_trx_berkas_tagihan vouBerkas
				where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
						vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
						vouTrx.id_trx_voucher 		= '202112000862'
			)
UNION ALL
select 		null    						as terima_tanggal,
			vouBerkasBa.no_ba_penerimaan	as terima_nomor,
			null                            as terima_kode,
			0				  				as terima_revke,
			vouBerkasBa.no_faktur			as faktur_nomor,
			null							as faktur_tanggal,
			null							as faktur_tanggal_tukar
	from 	rsfVoucher.keu_trx_voucher vouTrx,
			rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
			rsfVoucher.keu_trx_berkas_tagihan vouBerkas
	where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
			vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
			vouTrx.id_trx_voucher 		= '202112000862'


-- Tracking dari voucer ke terima melalui no_penerimaan atau no_ba_penerimaan di track berkas
select		teamTrm.no_doc    			as terima_nomor,
			teamTrm.tgl_doc   			as terima_tanggal,
			teamTrm.kode      			as terima_kode,
			teamTrm.revisike  			as terima_revke,
			teamTrm.no_faktur 			as faktur_nomor,
			teamTrm.tgl_faktur          as faktur_tanggal,
			teamTrm.tgl_tukar_faktur	as faktur_tanggal_tukar,
			teamTrm.nilai_akhir         as terima_nilai_akhir
	from	rsfTeamterima.transaksif_penerimaan teamTrm
	where	no_doc in (
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	=
							( select 	id_mst_mt_anggaran 
								from 	rsfVoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran = '20222022' and 
										nm_mt_anggaran = '- Barang Farmasi' ) and
							vouTrx.tgl_bku > '2022-01-01' and 
							vouTrx.tgl_bku < '2022-12-01'
					group   by 	vouBerkasBa.no_ba_penerimaan
			)

select * from rsfTeamterima.tdetailf_penerimaan where kode_reff = 'T00202104000493';
select * from rsfTeamterima.tdetailf_penerimaanrinc where kode_reff = 'T00202104000493';



select		teamTrm.no_doc    			as terima_nomor,
			teamTrm.tgl_doc   			as terima_tanggal,
			teamTrm.kode      			as terima_kode,
			teamTrm.revisike  			as terima_revke,
			teamTrm.no_faktur 			as faktur_nomor,
			teamTrm.tgl_faktur          as faktur_tanggal,
			teamTrm.tgl_tukar_faktur	as faktur_tanggal_tukar,
			teamTrm.nilai_akhir         as terima_nilai_akhir
	from	rsfTeamterima.transaksif_penerimaan teamTrm
	where	no_doc in (
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	=
							( select 	id_mst_mt_anggaran 
								from 	rsfVoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran = '20222022' and 
										nm_mt_anggaran = '- Barang Farmasi' ) and
							vouTrx.no_bku > '006778' 
					group   by 	vouBerkasBa.no_ba_penerimaan
			)

select * from rsfTeamterima.transaksif_penerimaan where no_doc IN
(
select		teamTrm.no_doc    			as terima_nomor
	from	rsfTeamterima.transaksif_penerimaan teamTrm
	where	no_doc in (
				select 		max(vouBerkasBa.no_ba_penerimaan) as no_ba_penerimaan
					from 	rsfVoucher.keu_trx_voucher vouTrx,
							rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan vouBerkasBa,
							rsfVoucher.keu_trx_berkas_tagihan vouBerkas
					where	vouTrx.id_trx_voucher     	= vouBerkas.id_trx_voucher and
							vouTrx.id_trx_voucher  		= vouBerkasBa.id_trx_voucher and
							vouTrx.id_mst_mt_anggaran 	=
							( select 	id_mst_mt_anggaran 
								from 	rsfVoucher.keu_mst_mt_anggaran
								where 	kd_th_anggaran = '20222022' and 
										nm_mt_anggaran = '- Barang Farmasi' ) and
							vouTrx.no_bku > '006778' 
					group   by 	vouBerkasBa.no_ba_penerimaan
			)
)