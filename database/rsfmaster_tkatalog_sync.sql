DROP PROCEDURE IF EXISTS rsfMaster.tkatalog_sync;
DELIMITER //
CREATE PROCEDURE rsfMaster.tkatalog_sync(
	aOBJ VARCHAR(32),
	aKODE VARCHAR(15)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- tkatalog_sync 																				-- */
	/* -- description   : insert rsfMaster.tkatalog_ ....															-- */
	/* -- spesification : 																							-- */
	/* -- sysdateLast 	: 2022-12-28 19:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vIDInsert BIGINT;
	START TRANSACTION;
		IF (aOBJ = "penerimaan") THEN
			insert into inventory.penerimaan_barang (
						RUANGAN, NO_SP, FAKTUR, TANGGAL, TANGGAL_PENERIMAAN, REKANAN,
						KETERANGAN, PPN, SUMBER_DANA, MASA_BERLAKU, TANGGAL_DIBUAT,
						OLEH, STATUS, JENIS, -- 1 = penerimaan eksternal, 2 = penerimaan PO
						REF_PO )
			select		'101030111' as ruangan, COALESCE(max(pembelian.no_doc),'-'), 
						max(terima.no_doc), max(terima.sysdate_in),
						max(ver_tglgudang), max(pbf.id_inventory), max(terima.no_doc), 
						-- case when max(terima.ppn) = 0 then 'Ya' else 'Tidak' end as ppn,
						'Ya' as ppn,
						case max(terima.id_sumberdana)
							when 0 then 0 
							when 1 then 3
							when 2 then 3
							when 3 then 3
							when 4 then 3
							when 5 then 1
							when 6 then 2
						else 0 end as sumberdana,
						COALESCE(min(terimadr.tgl_expired),'0000-00-00') as masa_berlaku, max(ver_tglgudang), 0, 1, 1, ''
				from	rsfLiveteamterima.tdetailf_penerimaan terimad
						left outer join rsfLiveteamterima.tdetailf_penerimaanrinc terimadr
						on 	terimad.kode_reff  	= terimadr.kode_reff and
							terimad.id_katalog 	= terimadr.id_katalog,
						rsfLiveteamterima.transaksif_penerimaan terima
						left outer join rsfLiveteamterima.transaksif_pembelian pembelian
						on terima.kode_reffpl 	= pembelian.kode
						left outer join rsfMaster.mkatalog_pbf pbf
						on terima.id_pbf 		= pbf.id
				where	terimad.kode_reff 		= terima.kode and
						terima.kode 			= aKODE;

			SELECT max(id) FROM inventory.penerimaan_barang INTO vIDInsert;

			insert into inventory.penerimaan_barang_detil ( 
						PENERIMAAN, BARANG, NO_BATCH,
						JUMLAH, JUMLAH_BESAR, JUMLAH_KECIL, BONUS,
						HARGA, HARGA_BESAR, DISKON, DISKON_P,
						ONGKIR, MASA_BERLAKU, STATUS, REF_PO_DETIL )
			select 		vIDInsert,
						max(mf.id_inventory) as barang, min(terimadr.no_batch) as no_batch, 
						max(terimad.jumlah_item) as jumlah, max(terimad.jumlah_kemasan) as jumlah_besar, 
						max(terimad.isi_kemasan) as jumlah_kecil, 0 as bonus,
						max(terimad.hp_item) as harga, 
						max(terimad.isi_kemasan * terimad.hp_item) as harga_besar, 
						-- max(terimad.hp_item + terimad.diskon_harga) as harga, 
						-- max(terimad.isi_kemasan * (terimad.hp_item + terimad.diskon_harga)) as harga_besar, 
						0 as diskon, 
						0 as diskon_p, 
						-- max(terimad.diskon_harga * terimad.isi_kemasan * terimad.jumlah_kemasan) as diskon, 
						-- max(terimad.diskon_item) as diskon_p, 
						0 as ongkir, COALESCE(min(terimadr.tgl_expired),'0000-00-00') as masa_berlaku,
						1, 0
				from 	rsfLiveteamterima.tdetailf_penerimaan terimad
						left outer join rsfLiveteamterima.tdetailf_penerimaanrinc terimadr
						on 	terimad.kode_reff  	= terimadr.kode_reff and
							terimad.id_katalog 	= terimadr.id_katalog,
						rsfMaster.mkatalog_farmasi mf
				where 	terimad.id_katalog		= mf.kode and
						terimad.kode_reff 		= aKODE
				group   by  terimad.kode_reff,
							terimad.id_katalog;

			update 		inventory.penerimaan_barang
				set		STATUS 	= 2
				where	id 		= vIDInsert;

			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster tkatalog penerimaan, insert complete. ', count(1) ,' row inserted. ') as statmessage,
						'success' as data
				FROM	inventory.penerimaan_barang_detil
				WHERE	PENERIMAAN = vIDInsert;
		ELSE
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('rsfMaster, tkatalog object ''', aOBJ,''' tidak ditemukan.') as statmessage,
						'' as data;
		END IF;
	COMMIT;
END //
DELIMITER ;
