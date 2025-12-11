============================================= refresh table target

drop table if exists rsfVoucher.keu_trx_voucher_status;
drop table if exists rsfVoucher.keu_trx_voucher;
drop table if exists rsfVoucher.keu_trx_kegiatan;
drop table if exists rsfVoucher.keu_trx_berkas_tagihan_faktur;
drop table if exists rsfVoucher.keu_trx_berkas_tagihan_ba_penerimaan;
drop table if exists rsfVoucher.keu_trx_berkas_tagihan;

drop table if exists rsfVoucher.keu_mst_mt_anggaran;
drop table if exists rsfVoucher.keu_mst_sumberdana_sub;
drop table if exists rsfVoucher.keu_mst_sumberdana;
drop table if exists rsfVoucher.keu_mst_th_anggaran;

============================================= data master

select count(1) keu_mst_th_anggaran;
select count(1) keu_mst_sumberdana;
select count(1) keu_mst_sumberdana_sub;
select count(1) keu_mst_mt_anggaran;

keu_mst_th_anggaran	    		 5 -     5
keu_mst_sumberdana	   			24 -    24
keu_mst_sumberdana_sub		   103 -   103
keu_mst_mt_anggaran			  1039 -  1039

select * from keu_mst_th_anggaran;
select * from keu_mst_sumberdana;
select * from keu_mst_sumberdana_sub;
select * from keu_mst_mt_anggaran;

