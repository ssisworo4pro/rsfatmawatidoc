-- proses tanggal 2 Agustus 2023 13:30
select * from tremun_data;

truncate table rsfPelaporan.rincian_tagihanx;
insert into rsfPelaporan.rincian_tagihanx ( TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS )
	select TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS
	from pembayaran.rincian_tagihan
	where JENIS = 3;
delete from rsfPelaporan.rincian_tagihanx where ID in
	( 	select ID from
		( 
			select min(ID) as ID from rsfPelaporan.rincian_tagihanx
			group by TAGIHAN, REF_ID, JENIS, TARIF_ID
			having count(1) > 1
		) x
	);

CALL rsfPelaporan.remun_pembentukandata(0, "202307","2023-07-01","2023-07-31");
select * from tremun_data;
update tremun_data set uraian = 'Juli 2023' where id = 12;
select * from tremun_data;

select 		id_remunproses, count(1), sum(kegiatan_tarif) 
	from 	tremun_datarinci 
	group   by id_remunproses;

select 		id_remunproses, count(1), sum(kegiatan_tarif) 
	from 	tremun_datarinci 
	group   by id_remunproses;

-- proses tanggal 5 Juli 2023 06:40
select * from tremun_data;

truncate table rsfPelaporan.rincian_tagihanx;
insert into rsfPelaporan.rincian_tagihanx ( TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS )
	select TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS
	from pembayaran.rincian_tagihan
	where JENIS = 3;
delete from rsfPelaporan.rincian_tagihanx where ID in
	( 	select ID from
		( 
			select min(ID) as ID from rsfPelaporan.rincian_tagihanx
			group by TAGIHAN, REF_ID, JENIS, TARIF_ID
			having count(1) > 1
		) x
	);

CALL rsfPelaporan.remun_pembentukandata(0, "202306","2023-06-01","2023-06-30");
select * from tremun_data;
update tremun_data set uraian = 'Juni 2023' where id = 11;
select * from tremun_data;

select 		id_remunproses, count(1), sum(kegiatan_tarif) 
	from 	tremun_datarinci 
	group   by id_remunproses;

----------------------------------------------------------------------
-- proses tanggal 10 Juni 2023 06:40
select * from tremun_data;
update tremun_data set tahunbulan = '000305', proses_sts = 2 where id = 7;

truncate table rsfPelaporan.rincian_tagihanx;
insert into rsfPelaporan.rincian_tagihanx ( TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS )
	select TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS
	from pembayaran.rincian_tagihan
	where JENIS = 3;
delete from rsfPelaporan.rincian_tagihanx where ID in
	( 	select ID from
		( 
			select min(ID) as ID from rsfPelaporan.rincian_tagihanx
			group by TAGIHAN, REF_ID, JENIS, TARIF_ID
			having count(1) > 1
		) x
	);

CALL rsfPelaporan.remun_pembentukandata(0, "202305","2023-05-01","2023-05-31");
select * from tremun_data;
update tremun_data set uraian = 'Mei 2023' where id = 8;
select * from tremun_data;

select 		id_remunproses, count(1), sum(kegiatan_tarif) 
	from 	tremun_datarinci 
	group   by id_remunproses;

----------------------------------------------------------------------
-- proses tanggal 2 Juni 2023
select * from tremun_data;
update tremun_data set tahunbulan = '000205' where id = 6;
update tremun_data set proses_sts = 2 where id = 5 or id = 6;
update tremun_data set uraian = 'Januari 2023' where id = 1;
update tremun_data set uraian = 'Febuari 2023' where id = 2;
update tremun_data set uraian = 'Maret 2023' where id = 3;
update tremun_data set uraian = 'April 2023' where id = 4;
update tremun_data set uraian = 'Mei 2023' where id = 7;

truncate table rsfPelaporan.rincian_tagihanx;
insert into rsfPelaporan.rincian_tagihanx ( TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS )
	select TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS
	from pembayaran.rincian_tagihan
	where JENIS = 3;
delete from rsfPelaporan.rincian_tagihanx where ID in
	( 	select ID from
		( 
			select min(ID) as ID from rsfPelaporan.rincian_tagihanx
			group by TAGIHAN, REF_ID, JENIS, TARIF_ID
			having count(1) > 1
		) x
	);

CALL rsfPelaporan.remun_pembentukandata(0, "202305","2023-05-01","2023-05-31");

select 		id_remunproses, count(1), sum(kegiatan_tarif) 
	from 	tremun_datarinci 
	group   by id_remunproses;

----------------------------------------------------------------------


truncate table rsfPelaporan.rincian_tagihanx;
insert into rsfPelaporan.rincian_tagihanx ( TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS )
	select TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS
	from pembayaran.rincian_tagihan
	where JENIS = 3;
delete from rsfPelaporan.rincian_tagihanx where ID in
	( 	select ID from
		( 
			select min(ID) as ID from rsfPelaporan.rincian_tagihanx
			group by TAGIHAN, REF_ID, JENIS, TARIF_ID
			having count(1) > 1
		) x
	);

CALL rsfPelaporan.remun_pembentukandata(0, "202301","2022-12-26","2023-01-25");
CALL rsfPelaporan.remun_pembentukandata(0, "202302","2023-01-26","2023-02-25");
CALL rsfPelaporan.remun_pembentukandata(0, "202303","2023-02-26","2023-03-25");
CALL rsfPelaporan.remun_pembentukandata(0, "202304","2023-03-26","2023-04-30");
CALL rsfPelaporan.remun_pembentukandata(0, "202305","2023-05-01","2023-05-12");
CALL rsfPelaporan.remun_pembentukandata(0, "202305","2023-05-01","2023-05-23");

select 		id_remunproses, count(1), sum(kegiatan_tarif) 
	from 	tremun_datarinci 
	group   by id_remunproses;

	insert into tremun_datarinci_kunj ( id_remunproses, dokter_nip, dto_kegiatan_klp, kunj_bpjs, kunj_nbpjs, kunj_nbpjse, nilai_bjpjs, nilai_nbpjs, nilai_nbpjse)
	select		id_remunproses, dokter_nip, dto_kegiatan_klp,
				sum(dto_bpjs_qty) as kunj_bpjs, 
				sum(dto_nbpjs_qty) as kunj_nbpjs, 
				sum(dto_nbpjse_qty) as kunj_nbpjse,
				0 as nilai_bjpjs, 
				0 as nilai_nbpjs, 
				0 as nilai_nbpjse
		from	(
					select 		id_remunproses, dokter_nip, dto_kegiatan_klp, daftar_nomor,
								max(dto_bpjs_qty) as dto_bpjs_qty, 
								max(dto_nbpjs_qty) as dto_nbpjs_qty, 
								max(dto_nbpjse_qty) as dto_nbpjse_qty
						from	tremun_datarinci
						group   by id_remunproses, dokter_nip, dto_kegiatan_klp, kunj_nomor
				) tremun_datarinci_grouping
		group   by id_remunproses, dokter_nip, dto_kegiatan_klp;

delete 	from rsfPelaporan.tremun_pgwfatmawati where id in 
	(	select id from 
		(
			select max(id) as id from tremun_pgwfatmawati
			group by nip
			having count(1) > 1
		) x
	);	

update		tremun_persentase
	set 	nm_jenis_tind = "visite"
	where 	nm_jenis_tind = "visitase";

--- RUMUS
insert into tremun_rumus_tarif
	( 	dto_tunaibedahprima, dto_kegiatan_klp, kegiatan_instalasi_grouping, rumus_pengali_tarif_baru,
   		sysdate_in, sysdate_last )
select		trx.dto_tunaibedahprima,
			trx.dto_kegiatan_klp,
			-- trx.kegiatan_instalasi_grouping,
			ifnull((miKunjungan.remun_grouping),'') as kegiatan_instalasi_grouping,
			max(
			case trx.dto_tunaibedahprima
				when 1 then 115
				else
					case (trx.dto_kegiatan_klp)
						when 'penunjang' then 100
					when 'rawatjalan' then
						case ifnull((miKunjungan.remun_grouping),'')
							when 'executive' then 115
							else 110
						end
					when 'tindakan' then
						case ifnull((miKunjungan.remun_grouping),'')
							when 'executive' then 115
							when 'operasi' then 125
							when 'rawatinap' then 115
							when 'intensif' then 115
							when 'rawatjalan' then 110
							else 110
						end
					else 115
				end
			end)  as rumus_pengali_tarif_baru,
			CURRENT_TIMESTAMP(), 
			CURRENT_TIMESTAMP()
	from	rsfPelaporan.tremun_datarinci trx
			left outer join rsfMaster.mlokasi_ruangan miKunjungan
				on 	miKunjungan.id = trx.kunj_ruangan
	group   by 	trx.dto_tunaibedahprima,
				trx.dto_kegiatan_klp,
				ifnull((miKunjungan.remun_grouping),'')
	order   by 	trx.dto_tunaibedahprima,
				trx.dto_kegiatan_klp,
				ifnull((miKunjungan.remun_grouping),'');	

-- UPDATE ID RUMUS
update 		rsfPelaporan.tremun_datarinci upd,
			rsfPelaporan.tremun_rumus_tarif	updReff
	set		upd.rumus_pengali_tarif_baru_id = updReff.id_rumus,
			upd.rumus_pengali_tarif_baru    = updReff.rumus_pengali_tarif_baru
	where	upd.id_remunproses 				= 7 and
			upd.dto_tunaibedahprima			= updReff.dto_tunaibedahprima and
			upd.dto_kegiatan_klp			= updReff.dto_kegiatan_klp and
			upd.kegiatan_instalasi_grouping = updReff.kegiatan_instalasi_grouping;

--Analisa Tarif Griya Husada
select 		td.kegiatan_id, td.kegiatan_nama,  
			td.dto_kegiatan_klp,
			td.dto_kelompok_kegiatan,
			max(
				case kegiatan_instalasi_kelompok
					when 'executive' then 'griya'
					else if(dto_tunaibedahprima = '1','bedahPrima','')
				end
			) as griya,
			min(td.kegiatan_tarif) as tarif_min,
			max(td.kegiatan_tarif) as tarif_max,
			max(td.kegiatan_tarif * td.rumus_pengali_tarif_baru / 100) as tarif_kenaikan,
			if( max(rumus_porsi_dokter_dari_tarif) = min(rumus_porsi_dokter_dari_tarif), max(rumus_porsi_dokter_dari_tarif), 0) as porsi_dokter_persen,
			max(td.kegiatan_tarif * td.rumus_pengali_tarif_baru / 100 * rumus_porsi_dokter_dari_tarif / 100) as porsi_dokter_nilai,
			count(1) as qty_kegiatan
	from 	rsfPelaporan.tremun_datarinci td 
	where 	td.id_remunproses = 6 and 
			( 	kegiatan_instalasi_kelompok = 'executive' or
				dto_tunaibedahprima = '9' )
	group   by td.kegiatan_id, td.kegiatan_nama, td.dto_kegiatan_klp, td.dto_kelompok_kegiatan
	order   by td.kegiatan_id, td.kegiatan_nama, td.dto_kegiatan_klp, td.dto_kelompok_kegiatan;
