------ harga perolehan terakhir -------

42C020	PCS     CANCELLOUS SCREW 216.95	      343.524,53
42C029	PCS     CANCELLOUS SCREW 217.85	      343.524,53
42C164	BUAH    CORTEX SCREW 4.5 MM 214.048   335.880,00

PFA048	BOTOL   ALKOHOL 95% 100ML	            2.047,63
PFD001	BKS     DEXTROSE MONOHYDRATE 1 KG      32.000,00

14H013	TAB     HYDROCLOROQUIN 200MG TAB (COVID-19)
14L012	TAB     LIANHUA QINGWEN CAPSULES @12 TABLET	
14N004	TAB     NORMUDAL 2MG TABLET BNPB	
14P014	PAKET   PAKET DLBS (P)

---------------------------------------------------------------------------------------

truncate table rsfPelaporan.laporan_hpt;

insert into rsfPelaporan.laporan_hpt (
   katalog_kode, id, tgl_vergudang,
   nilai_hppb, sts_prod )
values ( '42C020', 0, '2022-12-31', 343524.53, '2');

insert into rsfPelaporan.laporan_hpt (
   katalog_kode, id, tgl_vergudang,
   nilai_hppb, sts_prod )
values ( '42C029', 0, '2022-12-31', 343524.53, '2');

insert into rsfPelaporan.laporan_hpt (
   katalog_kode, id, tgl_vergudang,
   nilai_hppb, sts_prod )
values ( '42C164', 0, '2022-12-31', 335880, '2');

insert into rsfPelaporan.laporan_hpt (
   katalog_kode, id, tgl_vergudang,
   nilai_hppb, sts_prod )
values ( 'PFA048', 0, '2022-12-31', 2047.63, '2');

insert into rsfPelaporan.laporan_hpt (
   katalog_kode, id, tgl_vergudang,
   nilai_hppb, sts_prod )
values ( 'PFD001', 0, '2022-12-31', 32000, '2');

42C029	PCS     CANCELLOUS SCREW 217.85	      343.524,53
42C164	BUAH    CORTEX SCREW 4.5 MM 214.048   335.880,00
PFA048	BOTOL   ALKOHOL 95% 100ML	            2047.63
PFD001	BKS     DEXTROSE MONOHYDRATE 1 KG      32000

insert into rsfPelaporan.laporan_hpt (
   katalog_kode, id, tgl_vergudang,
   no_btb, no_dokumen, nilai_hppb, sts_prod )
select		beli.katalog_kode,
			beli.id,
			beli.tgl_vergudang,
			beli.no_btb,
			beli.no_dokumen,
			beli.nilai_hppb,
			'0'
	from 	tjurnal_penerimaanall beli,
			(
				select      katalog_kode, 
							max(concat(tgl_terima, right(concat('0000',id),4))) as tgl
					from 	tjurnal_penerimaanall
					where	sts_proses = 1 and
							nilai_hppb > 0 and
							qty_terima > 0
					group   by katalog_kode
			) beliMax
	where	beli.katalog_kode = beliMax.katalog_kode and
            concat(beli.tgl_terima, right(concat('0000',beli.id),4)) = beliMax.tgl;

alter table rsfPelaporan.laporan_hpt add katalog_kode_grp varchar(15) null;
alter table rsfPelaporan.laporan_hpt add nilai_hppb_max decimal(20,4) null;
alter table rsfPelaporan.laporan_hpt add nilai_hppb_min decimal(20,4) null;

insert into rsfPelaporan.laporan_hpt ( 
	katalog_kode, id, tgl_vergudang, nilai_hppb, sts_prod )
select 		hptinput.katalog_kode, 0, '2022-12-31', hptinput.nilai_hppb, '1' 
	from 	rsfPelaporan.laporan_hptinput hptinput
			left outer join rsfPelaporan.laporan_hpt hpt
			on hptinput.katalog_kode = hpt.katalog_kode
	where	hpt.katalog_kode is null;

UPDATE		rsfPelaporan.laporan_hpt as upd,
			(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) updReff
	SET		upd.katalog_kode_grp		= updReff.katalog_kode_grp
	WHERE	upd.katalog_kode			= updReff.katalog_kode;

select * from rsfPelaporan.laporan_hpt where katalog_kode_grp is null;
update  rsfPelaporan.laporan_hpt
	set katalog_kode_grp = katalog_kode
  where katalog_kode_grp is null;

UPDATE		rsfPelaporan.laporan_hpt as upd,
			(
				select 		max(hpt.katalog_kode_grp) as katalog_kode_grp,
							min(hpt.nilai_hppb) as nilai_hppb_min,
							max(hpt.nilai_hppb) as nilai_hppb_max
					from 	rsfPelaporan.laporan_hpt hpt
					group   by hpt.katalog_kode_grp
			) updReff
	SET		upd.nilai_hppb_min			= updReff.nilai_hppb_min,
			upd.nilai_hppb_max			= updReff.nilai_hppb_max
	WHERE	upd.katalog_kode_grp		= updReff.katalog_kode_grp;

--- update katalog_kode_grp_rekon1 untuk kasus
--- sudah lapor bpk tapi ada group yang berubah
alter table laporan_hpt add katalog_kode_grp_rekon1 varchar(15) null;
update laporan_hpt set katalog_kode_grp_rekon1 = katalog_kode_grp;
UPDATE		rsfPelaporan.laporan_hpt as upd,
			(
				select 		grp.*
					from 	rsfPelaporan.laporan_so_grp grp
			) updReff
	SET		upd.katalog_kode_grp		= updReff.katalog_kode_grp
	WHERE	upd.katalog_kode			= updReff.katalog_kode;
UPDATE		rsfPelaporan.laporan_hpt as upd,
			(
				select 		max(hpt.katalog_kode_grp) as katalog_kode_grp,
							min(hpt.nilai_hppb) as nilai_hppb_min,
							max(hpt.nilai_hppb) as nilai_hppb_max
					from 	rsfPelaporan.laporan_hpt hpt
					group   by hpt.katalog_kode_grp
			) updReff
	SET		upd.nilai_hppb_min			= updReff.nilai_hppb_min,
			upd.nilai_hppb_max			= updReff.nilai_hppb_max
	WHERE	upd.katalog_kode_grp		= updReff.katalog_kode_grp;
