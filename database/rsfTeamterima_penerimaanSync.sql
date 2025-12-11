DROP PROCEDURE IF EXISTS rsfTeamterima.penerimaanSync;
DELIMITER //
CREATE DEFINER=`admin`@`%` PROCEDURE `rsfTeamterima`.`penerimaanSync`(
	aOBJ VARCHAR(32) CHARSET utf8mb4,
	aKODE VARCHAR(35) CHARSET utf8mb4
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- rsfTeamterima.penerimaanSync 																				-- */
	/* -- description   : insert rsfKatalog.tkatalog_ ....															-- */
	/* -- spesification : 																							-- */
	/* -- sysdateLast 	: 2023-07-11 15:34 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 4 																						-- */
	/* -- revisionNote  : Tambah Heeader								 											-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vIDInsert BIGINT;
	DECLARE vMessage VARCHAR(255);
	DECLARE vErrorCode INTEGER;
	DECLARE vErrorCodeLast INTEGER;
	DECLARE vCounted INTEGER;
	DECLARE exit handler for SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
		insert into rsfLog.tlog_backend ( id_jenis, keyid, deskripsi, deskripsi2, sts_error, created_at )
		values ( 1, aKODE, 'SYSTEM-ERROR', @full_error, 1001, CURRENT_TIMESTAMP() );
		SELECT max(id) FROM rsfLog.tlog_backend INTO vIDInsert;
		set vCounted = 0;
		select		count(1), max(sts_error)
			into	vCounted, vErrorCodeLast
			from	rsfLog.tlog_backend_hdr
			where	id_jenis    = 1 and
					keyid		= aKODE;
		if (vCounted > 0) then
			if (vErrorCodeLast != 0) then
				update 		rsfLog.tlog_backend_hdr
					set		deskripsi	= 'SYSTEM-ERROR',
							deskripsi2	= @full_error,
							sts_error	= 1001,
							updated_at  = CURRENT_TIMESTAMP(),
							id_detil    = vIDInsert
					where	id_jenis    = 1 and
							keyid		= aKODE;
			end if;
		else
			insert into rsfLog.tlog_backend_hdr ( id_jenis, keyid, deskripsi, deskripsi2, sts_error, created_at, updated_at, id_detil)
			values ( 1, aKODE, 'SYSTEM-ERROR', @full_error, 1001, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), vIDInsert);
		end if;
	END;
	IF (aOBJ = "penerimaan") THEN
		set vErrorCode = 0;

		-- validasi id_inventory
		if (vErrorCode = 0) then
			set vCounted = 0;
			select		count(1), GROUP_CONCAT(sqKatalogUnSync.kd_katalog)
				into	vCounted, vMessage
				from	(
							/*select 		max(terimad.id_katalog) as kd_katalog
								from 	rsfTeamterima.tdetailf_penerimaan terimad
										left outer join rsfTeamterima.tdetailf_penerimaanrinc terimadr
										on 	terimad.kode_reff  	= terimadr.kode_reff and
											terimad.id_katalog 	= terimadr.id_katalog
										left outer join rsfKatalog.mkatalog_farmasi mf
										on  terimad.id_katalog  = mf.kode 
								where 	terimad.kode_reff 		= aKODE and
										mf.id_inventory			is null
								group   by  terimad.kode_reff,
											terimad.id_katalog
							select 		teamKat.id, simrsKat.id_inventory, 
										terimad.id_katalog as teamTerima,
										simrsgos.KODE_BARANG as simrsgos, 
										simrsKatalog.kode as simrs,
										simrsKatalog.sts_pabrik as sts_pabrik */
							select		max(terimad.id_katalog) as kd_katalog
								from 	rsfTeamterima.tdetailf_penerimaan terimad
										left outer join rsfTeamterima.tdetailf_penerimaanrinc terimadr
										on 	terimad.kode_reff  	= terimadr.kode_reff and
											terimad.id_katalog 	= terimadr.id_katalog
										left outer join rsfTeamterima.masterf_katalog teamKat
										on	teamKat.kode = terimad.id_katalog
										left outer join rsfKatalog.mkatalog_farmasi_pabrik simrsKat
										on  simrsKat.id_teamterima = teamKat.id
										left outer join rsfKatalog.mkatalog_farmasi simrsKatalog
										on  simrsKatalog.id = simrsKat.id
										left outer join inventory.barang simrsgos
										on simrsgos.ID = simrsKat.id_inventory
								where 	terimad.kode_reff 		= aKODE and
										simrsKat.id_inventory	is null
								group   by  terimad.kode_reff,
											terimad.id_katalog
						) sqKatalogUnSync;
			if (vCounted > 0) then
				set vErrorCode = 20002;
				set vMessage   = concat('kode katalog ', vMessage,' belum ada di SIMRSGOS. Mohon ditambahkan, kemudian proses ulang.');
			end if;
		end if;
		
		-- validasi proses berulang
		if (vErrorCode = 0) then
			set vCounted = 0;
			select		count(1) 
				into	vCounted
				from	inventory.penerimaan_barang
				where   REF_PO = aKODE;
			if (vCounted > 0) then
				set vErrorCode = 20003;
				set vMessage   = concat('penerimaan barang nomor : ', aKODE,' sudah pernah diproses. mohon untuk di cek ulang. apakah terjadi verifikasi berulang untuk nomor penerimaan ini.');
			end if;
		end if;

		-- insert into inventory.penerimaan_barang (
		if (vErrorCode = 0) then
			insert into inventory.penerimaan_barang (
						RUANGAN, NO_SP, FAKTUR, TANGGAL, TANGGAL_PENERIMAAN, REKANAN,
						KETERANGAN, PPN, SUMBER_DANA, MASA_BERLAKU, TANGGAL_DIBUAT,
						OLEH, STATUS, JENIS, -- 1 = penerimaan eksternal, 2 = penerimaan PO
						REF_PO )
			select		'101030111' as ruangan, COALESCE(max(pembelian.no_doc),'-'), 
						ifnull(if(trim(max(terima.no_faktur)) = '',null,max(terima.no_faktur)),max(no_suratjalan)), 
						max(terima.sysdate_in),
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
						COALESCE(min(terimadr.tgl_expired),'0000-00-00') as masa_berlaku, max(ver_tglgudang), 0, 1, 1, aKODE
				from	rsfTeamterima.tdetailf_penerimaan terimad
						left outer join rsfTeamterima.tdetailf_penerimaanrinc terimadr
						on 	terimad.kode_reff  	= terimadr.kode_reff and
							terimad.id_katalog 	= terimadr.id_katalog,
						rsfTeamterima.transaksif_penerimaan terima
						left outer join rsfTeamterima.transaksif_pembelian pembelian
						on terima.kode_reffpl 	= pembelian.kode
						left outer join rsfKatalog.mkatalog_pbf pbf
						on terima.id_pbf 		= pbf.id_teamterima
				where	terimad.kode_reff 		= terima.kode and
						terima.kode 			= aKODE;
						
			-- SELECT max(id) FROM inventory.penerimaan_barang INTO vIDInsert;
			SELECT max(id) FROM inventory.penerimaan_barang INTO vIDInsert;

			-- insert into inventory.penerimaan_barang_detil ( 
			insert into inventory.penerimaan_barang_detil ( 
						PENERIMAAN, BARANG, NO_BATCH,
						JUMLAH, JUMLAH_BESAR, JUMLAH_KECIL, BONUS,
						HARGA, HARGA_BESAR, DISKON, DISKON_P,
						ONGKIR, MASA_BERLAKU, STATUS, REF_PO_DETIL )
			select 		vIDInsert,
						max(simrsKatPab.id_inventory) as barang, min(terimadr.no_batch) as no_batch, 
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
				from 	rsfTeamterima.tdetailf_penerimaan terimad
						left outer join rsfTeamterima.tdetailf_penerimaanrinc terimadr
						on 	terimad.kode_reff  	= terimadr.kode_reff and
							terimad.id_katalog 	= terimadr.id_katalog
						left outer join rsfTeamterima.masterf_katalog teamKat
						on	teamKat.kode = terimad.id_katalog
						left outer join rsfKatalog.mkatalog_farmasi_pabrik simrsKatPab
						on  simrsKatPab.id_teamterima = teamKat.id
				where 	terimad.kode_reff 		= aKODE
				group   by  terimad.kode_reff,
							terimad.id_katalog;

			-- update 		inventory.penerimaan_barang
			update 		inventory.penerimaan_barang
				set		STATUS 	= 2
				 where	id 		= vIDInsert;

			-- result
			SELECT 		concat('rsfMaster tkatalog penerimaan, insert complete. ', count(1) ,' row inserted. ') 
				INTO    vMessage
				FROM	inventory.penerimaan_barang_detil
				WHERE	PENERIMAAN = vIDInsert;
				-- FROM    inventory.penerimaan_barang_detil

		end if;

		insert into rsfLog.tlog_backend ( id_jenis, keyid, deskripsi, deskripsi2, sts_error, created_at )
		values ( 1, aKODE, vMessage, null, vErrorCode, CURRENT_TIMESTAMP() );
		SELECT max(id) FROM rsfLog.tlog_backend INTO vIDInsert;
		set vCounted = 0;
		select		count(1), max(sts_error)
			into	vCounted, vErrorCodeLast
			from	rsfLog.tlog_backend_hdr
			where	id_jenis    = 1 and
					keyid		= aKODE;
		if (vCounted > 0) then
			if (vErrorCodeLast != 0) then
				update 		rsfLog.tlog_backend_hdr
					set		deskripsi	= vMessage,
							deskripsi2	= null,
							sts_error	= vErrorCode,
							updated_at  = CURRENT_TIMESTAMP(),
							id_detil    = vIDInsert
					where	id_jenis    = 1 and
							keyid		= aKODE;
			end if;
		else
			insert into rsfLog.tlog_backend_hdr ( id_jenis, keyid, deskripsi, deskripsi2, sts_error, created_at, updated_at, id_detil)
			values ( 1, aKODE, vMessage, null, vErrorCode, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), vIDInsert);
		end if;
	ELSE
		-- result
		set vMessage = concat('rsfMaster, tkatalog object ''', aOBJ,''' tidak ditemukan.');
		insert into rsfLog.tlog_backend ( id_jenis, keyid, deskripsi, deskripsi2, sts_error, created_at )
		values ( 1, aKODE, 'SYSTEM-ERROR', vMessage, 1002, CURRENT_TIMESTAMP() );
		SELECT max(id) FROM rsfLog.tlog_backend INTO vIDInsert;
		set vCounted = 0;
		select		count(1), max(sts_error)
			into	vCounted, vErrorCodeLast
			from	rsfLog.tlog_backend_hdr
			where	id_jenis    = 1 and
					keyid		= aKODE;
		if (vCounted > 0) then
			if (vErrorCodeLast != 0) then
				update 		rsfLog.tlog_backend_hdr
					set		deskripsi	= 'SYSTEM-ERROR',
							deskripsi2	= vMessage,
							sts_error	= 1002,
							updated_at  = CURRENT_TIMESTAMP(),
							id_detil    = vIDInsert
					where	id_jenis    = 1 and
							keyid		= aKODE;
			end if;
		else
			insert into rsfLog.tlog_backend_hdr ( id_jenis, keyid, deskripsi, deskripsi2, sts_error, created_at, updated_at, id_detil)
			values ( 1, aKODE, 'SYSTEM-ERROR', vMessage, 1002, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), vIDInsert);
		end if;
	END IF;
	-- COMMIT;
END //
DELIMITER ;
