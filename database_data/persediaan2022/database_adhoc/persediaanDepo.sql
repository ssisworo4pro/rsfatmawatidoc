'101030103', -- Depo Griya Husada
'101030104', -- Depo IGD   
'101030106', -- Depo Anggrek
'101030107', -- Depo Bougenville
'101030108', -- Depo IBS
'101030105', -- Depo OK CITO
'101030110', -- Depo Produksi
'101030111', -- Gudang Farmasi
'101030109', -- Depo Teratai
'101030101', -- Depo IRJ LT 1
'101030112', -- Depo IRJ LT 3
'101030115', -- Gudang Gas Medis
	
'101030102', -- Depo IRJ LT 2
'101030113', -- Depo UKVI
'101030114', -- Gudang Expired
'101030116', -- Gudang Konsinyasi
'101030117', -- Gudang Rusak
'101030118', -- Depo Metadon
'101030119', -- Gudang Reused 

=IF(gudang!B2="";"";CONCATENATE("insert into laporan_so_depo( depo_nama, katalog_id, katalog_kode, katalog_nama, katalog_satuan, katalog_merk, opname, beli, mmasuk, mkeluar, prod, resep, resep_retur, jual, jual_retur, akhir, koreksi_check, koreksi_kode, koreksi_keterangan ) values ('";"gudang',";gudang!B2;",'";gudang!C2;"','";gudang!D2;"','";gudang!E2;"','";gudang!F2;"',";gudang!G2;",";gudang!H2;",";gudang!I2;",";gudang!J2;",";gudang!K2;",";gudang!L2;",";gudang!M2;",";gudang!N2;",";gudang!O2;",";gudang!P2;",'";"";"','";gudang!R2;"','";gudang!S2;"');"))
=IF(B2="";"";CONCATENATE("insert into laporan_so_depo( depo_nama, katalog_id, katalog_kode, katalog_nama, katalog_satuan, katalog_merk, opname, beli, mmasuk, mkeluar, prod, resep, resep_retur, jual, jual_retur, akhir, koreksi_check, koreksi_kode, koreksi_keterangan ) values ('";"gudang',";B2;",'";C2;"','";D2;"','";E2;"','";F2;"',";G2;",";H2;",";I2;",";J2;",";K2;",";L2;",";M2;",";N2;",";O2;",";P2;",'";"";"','";R2;"','";S2;"');"))
select depo_nama, count(1) from laporan_so_depo group by depo_nama;

SELECT * FROM master.ruangan where substr(id,1,6) = '101030';

-- stop opname
select		b.KODE_BARANG 		as katalog_kode,
			b.ID 				as katalog_id, 
			b.NAMA 				as katalog_nama, 
			sod.MANUAL 			as qty_opname, 
			so.RUANGAN,
			r.DESKRIPSI 
	from	master.ruangan r,
			inventory.stok_opname so,
			inventory.stok_opname_detil sod 
			left outer join inventory.barang_ruangan br 
			on	sod.BARANG_RUANGAN = br.id
			left outer join inventory.barang b 
			on br.BARANG = b.ID 
	where	so.id						= sod.STOK_OPNAME and
			r.ID 						= so.RUANGAN and
			so.TANGGAL 					> '2022-12-16' and
			sod.MANUAL  				< 0 and
			SUBSTR( so.RUANGAN,1, 6) 	= '101030';

-- id barang dengan kode masih kosong
select 		a.koreksi_kode,  a.* from laporan_so_depo a 
	where 	katalog_id in (
				select		katalog_id
					from	(
								select 		katalog_id, 
											max(katalog_nama) as katalog_nama, 
											max(katalog_kode) as katalog_kode, 
											min(koreksi_kode) as koreksi_kode_min, 
											max(koreksi_kode) as koreksi_kode_max 
									from 	laporan_so_depo 
									where 	laporan_so_depo.katalog_kode is null
									group 	by laporan_so_depo.katalog_id, laporan_so_depo.katalog_kode
							) lapNull
					where	lapNull.koreksi_kode_max is null
			);

update 		laporan_so_depo 
	set 	koreksi_kode = '42T360.01', 
			koreksi_keterangan = 'update kode katalog' 
	where 	katalog_id = 13707;

select 		katalog_id, 
			max(katalog_nama) as katalog_nama, 
			max(katalog_kode) as katalog_kode, 
			min(koreksi_kode) as koreksi_kode_min, 
			max(koreksi_kode) as koreksi_kode_max 
	from 	laporan_so_depo 
	where 	laporan_so_depo.katalog_kode is null
	group 	by laporan_so_depo.katalog_id, laporan_so_depo.katalog_kode

--- update 	
UPDATE		rsfPelaporan.laporan_so_depo as upd,
			(
				select		*
					from	(
								select 		katalog_id, 
											max(katalog_kode) as katalog_kode, 
											max(koreksi_kode) as koreksi_kode_max 
									from 	laporan_so_depo 
									where 	laporan_so_depo.katalog_kode is null
									group 	by laporan_so_depo.katalog_id, laporan_so_depo.katalog_kode
							) tableReff
					where	tableReff.koreksi_kode_max is not NULL and
							tableReff.katalog_kode is null
			) updReff
	SET		upd.katalog_kode	= updReff.koreksi_kode_max
	WHERE	upd.katalog_id		= updReff.katalog_id;
	
-- data yang masih kosong
select 		a.koreksi_kode,  a.* from laporan_so_depo a 
	where 	katalog_id in (
				select 		katalog_id
					from 	laporan_so_depo 
					where 	laporan_so_depo.katalog_kode is null
					group 	by laporan_so_depo.katalog_id, laporan_so_depo.katalog_kode
			);

-- kelompok kode
select		tableGrup.katalog_kode, 
			tableGrup.katalog_kode_koreksi as katalog_kode_grp
	from	(
				select 		a.katalog_kode as katalog_kode,
							COALESCE(a.koreksi_kode,a.katalog_kode) as katalog_kode_koreksi
					from 	rsfPelaporan.laporan_so_depo a 
					where 	katalog_id in (
								select 		katalog_id
									from 	rsfPelaporan.laporan_so_depo 
									where 	katalog_kode is not null
									group 	by katalog_id
							)
			) tableGrup,
			laporan_so_depo
	where	tableGrup.katalog_kode = laporan_so_depo.katalog_kode
	group	by  katalog_kode, katalog_kode_koreksi;

select		laporan_so_depo.*
	from	laporan_so_depo
	where	tableGrup.katalog_kode = laporan_so_depo.katalog_kode
	group	by  katalog_kode, katalog_kode_koreksi;

