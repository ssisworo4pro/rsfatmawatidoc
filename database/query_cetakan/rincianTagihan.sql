select * from pembayaran.rincian_tagihan order by TAGIHAN desc;
select 		tMedisKunj.NOMOR as noKUNJ,
			rTagihan.JENIS,
			tMedisKunj.NOPEN 
	from 	pembayaran.tagihan_pendaftaran tDaftar 
			left join pembayaran.rincian_tagihan rTagihan
			on rTagihan.TAGIHAN = tDaftar.TAGIHAN
			left join layanan.tindakan_medis tMedis
			on tMedis.ID = rTagihan.REF_ID
			left join pendaftaran.kunjungan tMedisKunj
			on tMedisKunj.NOMOR = tMedis.KUNJUNGAN
	where 	tDaftar.PENDAFTARAN = '2310240001';

select * from pendaftaran.kunjungan k where k.NOPEN = '2310240001';
insert into pembayaran.tagihan_kunjungan ( KUNJUNGAN, TAGIHAN_ID, STS_BAYAR, STATUS )
values 	( '1010101402310240001', 1, 0, 1 ),
		( '1010101852310240001', 1, 0, 1 ),
		( '1010701012310240001', 1, 0, 1 );
insert into pembayaran.tagihan_kunjungan ( KUNJUNGAN, TAGIHAN_ID, STS_BAYAR, STATUS )
values 	( '1010301012310240001', 1, 0, 1 );

call pembayaran.CetakRincianPasienPerDokterKunjungan('1010101402310240001','1');
call pembayaran.CetakRincianPasienPerDokterKunjungan('1010101852310240001','1');
call pembayaran.CetakRincianPasienPerDokterKunjungan('1010701012310240001','1');
call pembayaran.CetakRincianPasienPerDokterKunjungan('1010301012310240001','1');
