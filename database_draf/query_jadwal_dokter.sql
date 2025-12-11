select * from hims.mreservasi_kuota mk;
select * from hims.mreservasi_liburdokter ml;
alter table hims.mreservasi_liburdokter add ruangan char(10) null;
select * from rsfPegawai.tpegawai t where t.id_ksm != 0;
select * from rsfPegawai.mpegawai_ksm mk 
select * from rsfPegawai.mpegawai_ksmgrp mk2 
select * from rsfMaster.msetting_ruangan mr 
alter table rsfMaster.msetting_ruangan add setting_ksm bigint null;
select * from rsfMaster.msetting_ruangan where deskripsi like '%mata%';
update rsfMaster.msetting_ruangan set setting_ksm = 3 where id = '101010101';
update rsfMaster.msetting_ruangan set setting_ksm = 3 where id = '101270102';
update rsfMaster.msetting_ruangan set setting_ksm = 19 where id = '101270112';
update rsfMaster.msetting_ruangan set setting_ksm = 19 where id = '101010158';

select 		max(tPegawai.nama) as dokter,
			max(mRuang.deskripsi) as ruang,
			max(case mKuota.hari when 2 then mKuota.start else '' end) as senin_start,
			max(case mKuota.hari when 2 then mKuota.end else '' end)  as senin_end,
			max(case mKuota.hari when 3 then mKuota.start else '' end) as selasa_start,
			max(case mKuota.hari when 3 then mKuota.end else '' end)  as selasa_end,
			max(case mKuota.hari when 4 then mKuota.start else '' end) as rabu_start,
			max(case mKuota.hari when 4 then mKuota.end else '' end)  as rabu_end,
			max(case mKuota.hari when 5 then mKuota.start else '' end) as kamis_start,
			max(case mKuota.hari when 5 then mKuota.end else '' end)  as kamis_end,
			max(case mKuota.hari when 6 then mKuota.start else '' end) as jumat_start,
			max(case mKuota.hari when 6 then mKuota.end else '' end)  as jumat_end,
			max(case mKuota.hari when 7 then mKuota.start else '' end) as sabtu_start,
			max(case mKuota.hari when 7 then mKuota.end else '' end)  as sabtu_end,
			max(case mKuota.hari when 1 then mKuota.start else '' end) as minggu_start,
			max(case mKuota.hari when 1 then mKuota.end else '' end)  as minggu_end
	from 	hims.mreservasi_kuota mKuota
			join rsfPegawai.tpegawai tPegawai
			on tPegawai.id = mKuota.dokter
			join rsfMaster.msetting_ruangan mRuang
			on mKuota.ruangan = mRuang.id COLLATE utf8_unicode_ci
	group   by mKuota.dokter;

ALTER TABLE rsfMaster.msetting_ruangan CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE rsfMaster.msetting_ruangan CHARACTER SET utf8 COLLATE utf8_general_ci;
select 		r.id, r.deskripsi, t.* 
	from 	rsfPegawai.tpegawai t 
			join rsfMaster.msetting_ruangan r
			on t.id_ksm = r.setting_ksm
	-- where 	t.nip = 197407152014121002
	order   by t.nama;



---- JADWAL
-- list poli
select 		max(mRuang.deskripsi) as ruang,
			max(mRuang.id) as ruangID
	from 	hims.mreservasi_kuota mKuota
			join rsfPegawai.tpegawai tPegawai
			on tPegawai.id = mKuota.dokter
			join rsfMaster.msetting_ruangan mRuang
			on mKuota.ruangan = mRuang.id COLLATE utf8_unicode_ci
	group   by mRuang.id;

-- list dokter
select 		max(tPegawai.nama) as dokter,
			max(tPegawai.id) as dokterID
	from 	hims.mreservasi_kuota mKuota
			join rsfPegawai.tpegawai tPegawai
			on tPegawai.id = mKuota.dokter
			join rsfMaster.msetting_ruangan mRuang
			on mKuota.ruangan = mRuang.id COLLATE utf8_unicode_ci
	where	mRuang.id = '101270102';

-- list kuota / Jadwal
select		sqQuotaKlaim.tanggal,
			sqJadwalDokter.dokterID,
			sqJadwalDokter.ruangID,
			sqJadwalDokter.hari,
			sqJadwalDokter.hari_jam_mulai,
			sqJadwalDokter.hari_jam_selesai,
			sqJadwalDokter.hari_quota,
			sqJadwalDokter.hariDesc,
			ifnull(sqJadwalBooking.quota_booking,0) as quota_booking,
			sqHariLiburNasional.keterangan as hari_libur_ket,
			if(sqHariLiburNasional.tanggal is null, 0, 1) as hari_libur_nasional,
			sqHariLiburDokter.keterangan as hari_libur_dokter,
			if(sqHariLiburDokter.tanggal is null, 0, 1) as hari_libur_dokter
	from	(
				SELECT		DATE_ADD(CURRENT_DATE(), interval SEQ.SeqValue day) as tanggal,
							DAYOFWEEK(DATE_ADD(CURRENT_DATE(), interval SEQ.SeqValue day)) as tanggal_hari 
					FROM	(
								SELECT		(HUNDREDS.SeqValue + TENS.SeqValue + ONES.SeqValue) SeqValue
									FROM	(	SELECT 0 SeqValue UNION ALL SELECT 1 SeqValue UNION ALL SELECT 2 SeqValue UNION ALL SELECT 3 SeqValue
				    							UNION ALL SELECT 4 SeqValue UNION ALL SELECT 5 SeqValue UNION ALL SELECT 6 SeqValue
				    							UNION ALL SELECT 7 SeqValue UNION ALL SELECT 8 SeqValue UNION ALL SELECT 9 SeqValue
				    						) ONES CROSS JOIN
											(	SELECT 0 SeqValue UNION ALL SELECT 10 SeqValue UNION ALL SELECT 20 SeqValue UNION ALL
												SELECT 30 SeqValue UNION ALL SELECT 40 SeqValue UNION ALL SELECT 50 SeqValue UNION ALL
												SELECT 60 SeqValue UNION ALL SELECT 70 SeqValue UNION ALL SELECT 80 SeqValue UNION ALL SELECT 90 SeqValue
											) TENS CROSS JOIN
											(	SELECT 0 SeqValue UNION ALL SELECT 100 SeqValue UNION ALL SELECT 200 SeqValue UNION ALL
												SELECT 300 SeqValue UNION ALL SELECT 400 SeqValue UNION ALL SELECT 500 SeqValue UNION ALL SELECT 600 SeqValue
												UNION ALL SELECT 700 SeqValue UNION ALL SELECT 800 SeqValue UNION ALL SELECT 900 SeqValue
				    						) HUNDREDS
				    		) SEQ
				    WHERE   SEQ.SeqValue > 0 and SEQ.SeqValue < 31
    		) sqQuotaKlaim
    		left outer join
			(
				select 		tPegawai.id as dokterID,
							tPegawai.nama as dokter,
							mRuang.deskripsi as ruang,
							mRuang.id as ruangID,
							mKuota.hari as hari,
							mKuota.start as hari_jam_mulai,
							mKuota.end as hari_jam_selesai,
							mKuota.quota_online as hari_quota,
							CONCAT(	case mKuota.hari 
											when 1 then 'minggu'
											when 2 then 'senin'
											when 3 then 'selasa'
											when 4 then 'rabu'
											when 5 then 'kamis'
											when 6 then 'jumat'
											when 7 then 'sabtu'
											else '---'
									end, ', ', start, '-', end ) 
							as hariDesc
					from 	hims.mreservasi_kuota mKuota
							join rsfPegawai.tpegawai tPegawai
							on tPegawai.id = mKuota.dokter
							join rsfMaster.msetting_ruangan mRuang
							on mKuota.ruangan = mRuang.id COLLATE utf8_unicode_ci
					where	mRuang.id = '101270102'
			) sqJadwalDokter on sqQuotaKlaim.tanggal_hari = sqJadwalDokter.hari
			left outer join
			(
				select 		tReservasi.tanggal_reservasi as tanggal,
							max(tReservasi.id_dokter) as id_dokter,
							count(1) as quota_booking
					from	hims.dft_trx_reservasi tReservasi
					where	tReservasi.status = 1 and
							tReservasi.id_dokter = 80
					group	by tReservasi.tanggal_reservasi
			) sqJadwalBooking on 	sqJadwalBooking.tanggal 	= sqQuotaKlaim.tanggal and
									sqJadwalBooking.id_dokter	= sqJadwalDokter.dokterID
			left outer join
			(
				select 		mLibur.tanggal_libur as tanggal,
							mLibur.keterangan as keterangan
					from 	hims.mreservasi_harilibur mLibur
					where	tanggal_libur > CURRENT_DATE()
			) sqHariLiburNasional on sqHariLiburNasional.tanggal = sqQuotaKlaim.tanggal	
			left outer join
			(
				select 		mLiburDokter.dokter as dokterID,
							mLiburDokter.ruangan as ruangID,
							mLiburDokter.tanggal_libur as tanggal,
							mLiburDokter.keterangan as keterangan 
					from 	hims.mreservasi_liburdokter mLiburDokter
					where	tanggal_libur > CURRENT_DATE()
			) sqHariLiburDokter on 	sqHariLiburDokter.tanggal 	= sqQuotaKlaim.tanggal and
									sqHariLiburDokter.dokterID 	= sqJadwalDokter.dokterID and 
									sqHariLiburDokter.ruangID	= sqJadwalDokter.ruangID
	where	sqJadwalDokter.hari_quota is not null
	order	by sqQuotaKlaim.tanggal;
