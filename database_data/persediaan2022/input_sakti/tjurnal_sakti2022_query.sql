-- verifikasi total yang masuk ke database
select 		count(1) as jml_baris,
            sum(qty_awal) as awal_qty, 
			sum(nilai_awal) as awal_nilai,
			sum(qty_akhir) as akhir_qty, 
			sum(nilai_akhir) as akhir_nilai
	from 	tjurnal_sakti2022;

					 5.071
				 7.084.287
			44.563.627.004
				 3.468.786
			30.695.364.946
			
					  5086
				   7084287
			   44563627004
			       3378826
			   30018367783

-- MASTERING grp_sakti
insert into tjurnal_sakti_kelompok ( sakti_kode_klp, sakti_nama_klp )
select sakti_kode_klp, sakti_nama_klp from tjurnal_sakti_klp;

select 		distinct ts.sakti_nama_klp as sakti, '' as klp, '' as kode
	from 	tjurnal_sakti2022 ts left outer join
			tjurnal_sakti_kelompok tsk
			on ts.sakti_nama_klp = tsk.sakti_nama_klp
	where	tsk.sakti_kode_klp  is null
union all
select '' as sakti, sakti_nama_klp as klp, sakti_kode_klp as kode  from tjurnal_sakti_kelompok 

insert into tjurnal_sakti_kelompok ( sakti_kode_klp, sakti_nama_klp )
values ('1010401006','ALAT/ OBAT KONTRASEPSI KELUARGA BERENCANA (PERSEDIAAN  LAINNYA)'),
       ('XXXXXXXX01','NON ALAT/OBAT KONTRASEPSI KELUARGA BERENCANA (PERSEDIAAN  LAINNYA)'),
       ('XXXXXXXX02','BARANG PERSEDIAAN');
insert into tjurnal_sakti_kelompok ( sakti_kode_klp, sakti_nama_klp )
values ('XXXXXXXX01','NON ALAT/OBAT KONTRASEPSI KELUARGABERENCANA (PERSEDIAAN  LAINNYA)');

update tjurnal_sakti_kelompok set sakti_kode_klp = '1010401007' where sakti_kode_klp = 'XXXXXXXX01';
SELECT * FROM tjurnal_sakti2022 WHERE sakti_kode_klp = 'XXXXXXXX02';
delete from tjurnal_sakti2022 WHERE sakti_kode_klp = 'XXXXXXXX02';

select 		distinct ts.sakti_nama_klp as sakti, '' as klp, '' as kode
	from 	tjurnal_sakti ts left outer join
			tjurnal_sakti_kelompok tsk
			on ts.sakti_nama_klp = tsk.sakti_nama_klp
	where	tsk.sakti_kode_klp  is null

-- update grp_sakti
UPDATE		rsfPelaporan.tjurnal_sakti2022 as upd,
			(
				select 		ts.sakti_kode,
							ts.sakti_nama_klp,
							tsk.sakti_kode_klp
					from 	tjurnal_sakti2022 ts,
							tjurnal_sakti_kelompok tsk
					where	ts.sakti_nama_klp = tsk.sakti_nama_klp
			) updReff
	SET		upd.sakti_kode_klp		= updReff.sakti_kode_klp
	WHERE	upd.sakti_kode			= updReff.sakti_kode and
			upd.sakti_nama_klp		= updReff.sakti_nama_klp;
select * from tjurnal_sakti2022 where sakti_kode_klp is null;

UPDATE		rsfPelaporan.tjurnal_sakti as upd,
			(
				select 		ts.sakti_kode,
							ts.sakti_nama_klp,
							tsk.sakti_kode_klp
					from 	tjurnal_sakti ts,
							tjurnal_sakti_kelompok tsk
					where	ts.sakti_nama_klp = tsk.sakti_nama_klp
			) updReff
	SET		upd.sakti_kode_klp		= updReff.sakti_kode_klp
	WHERE	upd.sakti_kode			= updReff.sakti_kode and
			upd.sakti_nama_klp		= updReff.sakti_nama_klp;
select * from tjurnal_sakti where sakti_kode_klp is null;

-- update tjurnal_sakti2022
UPDATE		rsfPelaporan.tjurnal_sakti2022 as upd,
			(
				select 		ts.sakti_kode_klp,
							ts.sakti_kode,
							ts.katalog_kode,
							ts.sts_mapping,
							ts.stat_mapsaldoawal
					from 	tjurnal_sakti ts
			) updReff
	SET		upd.katalog_kode		= updReff.katalog_kode,
			upd.sts_mapping			= updReff.sts_mapping,
			upd.stat_mapsaldoawal	= updReff.stat_mapsaldoawal
	WHERE	upd.sakti_kode_klp		= updReff.sakti_kode_klp and
			upd.sakti_kode			= updReff.sakti_kode;

-- verifikasi total yang masuk ke database dengan status
select 		count(1) as jml_baris,
            sum(qty_awal) as awal_qty, 
			sum(nilai_awal) as awal_nilai,
			sum(qty_akhir) as akhir_qty, 
			sum(nilai_akhir) as akhir_nilai
	from 	tjurnal_sakti2022
	where	katalog_kode is not null and
			(sts_mapping = 1 or sts_mapping = 2)

					 5.071					
				 7.084.287
			44.563.627.004
				 3.468.786
			30.695.364.946

			4674	7.084.287	44.563.627.004	
			        3.467.958	30.644.933.254
					
			4674	7.084.287	44.563.627.004
					3.357.877	29.967.915.970

-- yang harus di nol-kan
SELECT 		sakti_kode_klp,
			sakti_kode,
			1 as katalog_grp,
			1 as sakti_grp,
			qty_awal,
			qty_masuk,
			0 as sakti_awal_add,
			qty_akhir as sakti_akhir,
			null as simrs_akhir,
			null as pembulatan,
			null as simrs_trx,
			null as selisih_abs,
			null as selisih,
			katalog_kode as katalog_kode,
			'' as katalog_nama,
			sakti_nama as sakti_nama,
			sakti_nama_klp as sakti_nama_klp
	from 	tjurnal_sakti2022
	where	( katalog_kode is null or
			  (sts_mapping <> 1 and sts_mapping <> 2)) and
			nilai_akhir <> 0;
	
--- SAKTI DUPLIKASI
SELECT 		grp.katalog_kode_grp,
			sakti.katalog_kode,
			sakti.qty_akhir,
			sakti.qty_awal,
			sakti.qty_masuk,
			sakti.sakti_kode_klp,
			sakti.sakti_kode,
			sakti.sakti_nama,
			sakti.sakti_nama_klp
	FROM 	tjurnal_sakti2022 sakti,
			rsfPelaporan.laporan_so_grp grp
	where 	sakti.katalog_kode = grp.katalog_kode and
			grp.katalog_kode_grp in ('40R066','10P227','14F017'
				,'40C018','10E039','40S102','80C001.19','PFH046'
				,'10A285','10F043','80M247.1','90P097','80F123.1'
				,'80M246.1','80F118','42N114','10B142','15I022'
				,'40P012.16','50G019','40N005','40O044','PF037')
	order   by grp.katalog_kode_grp, case when sakti.katalog_kode = grp.katalog_kode_grp then 0 else 1 end;

update tjurnal_sakti2022 
set katalog_kode = '14P014', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '001017';
update tjurnal_sakti2022 
set katalog_kode = '82M003', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '001967';
update tjurnal_sakti2022 
set katalog_kode = '14L012', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '003389';
update tjurnal_sakti2022 
set katalog_kode = '14S006', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '003364';
update tjurnal_sakti2022 
set katalog_kode = '80K102', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '000372';
update tjurnal_sakti2022 
set katalog_kode = '14N004', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '003381';

update tjurnal_sakti2022 
set katalog_kode = '42N077', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '000027';
update tjurnal_sakti2022 
set katalog_kode = '42K062', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '001110';
update tjurnal_sakti2022 
set katalog_kode = '80I099', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '002006';
update tjurnal_sakti2022 
set katalog_kode = '50V008', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '002030';
update tjurnal_sakti2022 
set katalog_kode = '004149', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004317';
update tjurnal_sakti2022 
set katalog_kode = '42E037', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004318';
update tjurnal_sakti2022 
set katalog_kode = '42S199', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004319';

update tjurnal_sakti2022 
set katalog_kode = '80E033.2', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '000195';

update tjurnal_sakti2022 
set katalog_kode = '40S100', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000666';
update tjurnal_sakti2022 
set katalog_kode = '40S098', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000599';


update tjurnal_sakti2022 
set katalog_kode = '42C012', sts_mapping = 1 
where sakti_kode_klp = '1010401999' and sakti_kode = '004317';

update tjurnal_sakti2022 
set sts_mapping = 9
where sakti_kode_klp = '1010401999' and sakti_kode = '004149';

update tjurnal_sakti2022final
set katalog_kode = '40S100', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000666';
update tjurnal_sakti2022final
set katalog_kode = '40S098', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000599';
update tjurnal_sakti2022final
set katalog_kode = '42C012', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004317';

-- salah group dari 80M246.1
update laporan_so_grp set katalog_kode_grp = '80S344' where katalog_kode = '80S344'


/*

80M246.1

update tjurnal_sakti2022 
set katalog_kode = '14P014', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '001017';
update tjurnal_sakti2022 
set katalog_kode = '82M003', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '001967';
update tjurnal_sakti2022 
set katalog_kode = '14L012', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '003389';
update tjurnal_sakti2022 
set katalog_kode = '14S006', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '003364';
update tjurnal_sakti2022 
set katalog_kode = '80K102', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '000372';
update tjurnal_sakti2022 
set katalog_kode = '14N004', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '003381';

update tjurnal_sakti2022 
set katalog_kode = '42N077', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '000027';
update tjurnal_sakti2022 
set katalog_kode = '42K062', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '001110';
update tjurnal_sakti2022 
set katalog_kode = '80I099', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '002006';
update tjurnal_sakti2022 
set katalog_kode = '50V008', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '002030';
update tjurnal_sakti2022 
set katalog_kode = '42C012', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004317';
update tjurnal_sakti2022 
set katalog_kode = '42E037', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004318';
update tjurnal_sakti2022 
set katalog_kode = '42S199', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004319';
update tjurnal_sakti2022
set katalog_kode = '40S100', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000666';
update tjurnal_sakti2022
set katalog_kode = '40S098', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000599';
update tjurnal_sakti2022 
set katalog_kode = '80E033.2', sts_mapping = 1 where sakti_kode_klp = '1010401006' and sakti_kode = '000195';

update tjurnal_sakti2022final
set katalog_kode = '40S100', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000666';
update tjurnal_sakti2022final
set katalog_kode = '40S098', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '000599';
update tjurnal_sakti2022final
set katalog_kode = '42C012', sts_mapping = 1 where sakti_kode_klp = '1010401999' and sakti_kode = '004317';

-- salah group dari 80M246.1
update laporan_so_grp set katalog_kode_grp = '80S344' where katalog_kode = '80S344'
*/

PFH046	H2O2  3%  50 ml
PF037	H2O2 3%  100 ml

80M246.1	MASK OXIGEN NON REBREATHING ADULT	
            SUCTION CATHETER FINGER CH 10

update laporan_so_grp set katalog_kode_grp = '80S344' where katalog_kode = '80S344'

