DROP PROCEDURE IF EXISTS rsfMaster.mkatalog_sync;
DELIMITER //
CREATE PROCEDURE rsfMaster.mkatalog_sync(
	aOBJ VARCHAR(32),
	aINVinsert integer
)
BEGIN
	/* ---------------------------------------------------------------------------------------------------------------- */
	/* -- mkatalog_sync 																							 -- */
	/* -- description   : insert rsfMaster.mkatalog_ ....															 -- */
	/* -- spesification : 																							 -- */
	/* -- sysdateLast 	: 2023-05-16 16:00 																			 -- */
	/* -- useridLast  	: ss 																						 -- */
	/* -- revisionCount : 1 																				 		 -- */
	/* -- revisionNote  : 								 														 	 -- */
	/* ---------------------------------------------------------------------------------------------------------------- */
	/*	mkatalog_anggaranjnssub				mkatalog_farmasi.id_jenisbarang												*/
	/*		mkatalog_anggaranjns			mkatalog_anggaranjnssub.id_jenis											*/
	/*	mkatalog_kelompok					mkatalog_farmasi.id_kelompokbarang											*/
	/*	mkatalog_kemasan 					mkatalog_farmasi.id_kemasankecil, 											*/
	/*										mkatalog_farmasi.id_kemasanbesar											*/
	/*	mkatalog_pbf						mkatalog_farmasi.id_pbf														*/
	/*	mkatalog_pabrik						mkatalog_farmasi.id_pabrik													*/
	/*	mkatalog_brand						mkatalog_farmasi.id_brand													*/
	/*		mkatalog_generik				mkatalog_brand.id_generik													*/
	/*	mkatalog_kfa91   					mkatalog_farmasi.id_kfa91													*/
	/*	mkatalog_kfa92						mkatalog_farmasi.id_kfa92													*/
	/*	mkatalog_kfa93						mkatalog_farmasi.id_kfa93													*/
	/*	mkatalog_sakti						mkatalog_farmasi.id_barang_sakti											*/
	/*		mkatalog_sakti_hdr				mkatalog_sakti.id_hdr														*/
	/*	mkatalog_dosis						mkatalog_farmasi.id_dosis													*/
	/*	_mkatalog_buffer_gudang																							*/
	/* ---------------------------------------------------------------------------------------------------------------- */
	START TRANSACTION;
		IF (aOBJ = "persiapan") THEN
			delete from rsfMaster.mkatalog_farmasi;
			delete from rsfMaster.mkatalog_anggaranjnssub;
			delete from rsfMaster.mkatalog_anggaranjns;
			delete from rsfMaster.mkatalog_kelompok;
			delete from rsfMaster.mkatalog_kemasan;
			delete from rsfMaster.mkatalog_pbf;
			delete from rsfMaster.mkatalog_pabrik;
			delete from rsfMaster.mkatalog_brand;
			delete from rsfMaster.mkatalog_generik;
			SELECT 		0 as statcode,
						1 as rowcount,
						concat('rsfMaster mkatalog ... persiapan completed. ') as statmessage,
						'success' as data;
		ELSEIF (aOBJ = "selesai") THEN
			SELECT 		0 as statcode,
						1 as rowcount,
						concat('rsfMaster mkatalog ... persiapan completed. ') as statmessage,
						'success' as data;
		ELSEIF (aOBJ = "anggaranjns") THEN
			-- tidak ada kesetaraan anggaranjns di inventory
			insert into rsfMaster.mkatalog_anggaranjns
						( id, kode, jenis_anggaran, sts_aktif, userid_in, sysdate_in, userid_updt,
						sysdate_updt )
			select 		id, kode, subjenis_anggaran, sts_aktif, userid_in, sysdate_in, userid_updt,
						sysdate_updt
				from	rsfTeamterima.masterf_subjenisanggaran;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster mkatalog_anggaranjns, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_anggaranjns;
		ELSEIF (aOBJ = "anggaranjnssub") THEN
			-- tidak ada kesetaraan anggaranjnssub di inventory
			insert into rsfMaster.mkatalog_anggaranjnssub
						( 	id, id_jenis, thn_aktif, kode,
							subjenis_anggaran, keterangan, sts_aktif,
							userid_in, sysdate_in, userid_updt, sysdate_updt )
				select		id, id_jenis, thn_aktif, kode,
							subjenis_anggaran, keterangan, sts_aktif,
							userid_in, sysdate_in, userid_updt, sysdate_updt 
					from	(
								select		CONCAT(RIGHT(CONCAT('00000',ms.id),5),
											RIGHT(CONCAT('00000',ra.id_subjenis),5),
											ra.thn_aktif) as akey, 
											ms.id as id, ra.id_subjenis as id_jenis,
											ra.thn_aktif as thn_aktif,
											ms.kode as kode,
											ms.subjenis_anggaran as subjenis_anggaran,
											ra.keterangan as keterangan,
											ms.sts_aktif as sts_aktif,
											ms.userid_in as userid_in,
											ms.sysdate_in as sysdate_in,
											ms.userid_updt as userid_updt,
											ms.sysdate_updt as sysdate_updt 
									from	rsfTeamterima.masterf_subjenisanggaran ms,
											rsfTeamterima.relasif_anggaran ra 
									where	ra.id_subjenis = ms.id
									order	by ms.id
							) anggaran,
							(
								select		min(CONCAT(RIGHT(CONCAT('00000',ms.id),5),
											RIGHT(CONCAT('00000',ra.id_subjenis),5),
											ra.thn_aktif)) as akey
									from	rsfTeamterima.masterf_subjenisanggaran ms,
											rsfTeamterima.relasif_anggaran ra 
									where	ra.id_subjenis = ms.id
									group   by ms.id, ra.id_subjenis
							) anggfilter
					where	anggaran.akey = anggfilter.akey
					order	by anggaran.akey;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster mkatalog_anggaranjnssub, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_anggaranjnssub;
		ELSEIF (aOBJ = "kelompok") THEN
			-- tidak ada kesetaraan kelompok di inventory
			insert		into rsfMaster.mkatalog_kelompok
						(	id,	id_teamterima, id_inventory,
							kode, kelompok_barang, kode_temp, no_urut, gol,
							bid, kel, subkel, subsubkel, userid_updt, sysdate_updt
						)
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.kelompok_barang, mk.kode_temp, mk.no_urut, mk.gol,
						mk.bid, mk.kel, mk.subkel, mk.subsubkel, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_kelompokbarang mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_kelompok ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog kelompok, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_kelompok;
		ELSEIF (aOBJ = "kemasan") THEN
			-- insert to rsfMaster
			insert		into rsfMaster.mkatalog_kemasan
						(	id, id_teamterima, id_inventory, kode, kode_med,
							nama_kemasan, sts_aktif, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, mk.kode, mk.kode_med,
						mk.nama_kemasan, mk.sts_aktif, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_kemasan mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_kemasan ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfMaster.mkatalog_kemasan kemasan, inventory.satuan satuan
				SET		kemasan.id_inventory = satuan.id
				WHERE   kemasan.kode = satuan.nama and
						kemasan.id_inventory is null;
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into inventory.satuan ( NAMA, DESKRIPSI, TANGGAL, OLEH, STATUS )
				select 		kemasan.kode, kemasan.nama_kemasan, current_timestamp, 0, 1
					from 	rsfMaster.mkatalog_kemasan kemasan
					where	kemasan.id_inventory is null;
				UPDATE 		rsfMaster.mkatalog_kemasan kemasan, inventory.satuan satuan
					SET		kemasan.id_inventory = satuan.id
					WHERE   kemasan.kode = satuan.nama and
							kemasan.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster mkatalog_kemasan, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_kemasan;
		ELSEIF (aOBJ = "pbf") THEN
			-- insert to rsfMaster
			insert		into rsfMaster.mkatalog_pbf
						(	id, id_teamterima, id_inventory, 
							kode, nama_pbf, npwp, alamat, kota,
							kodepos, telp, fax, email, kepala_cabang,
							cp_name, cp_telp, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_pbf, mk.npwp, mk.alamat, mk.kota,
						mk.kodepos, mk.telp, mk.fax, mk.email, mk.kepala_cabang,
						mk.cp_name, mk.cp_telp, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_pbf mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_pbf ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfMaster.mkatalog_pbf pbf, inventory.penyedia penyedia
				SET		pbf.id_inventory = penyedia.id
				WHERE   SUBSTR(pbf.nama_pbf,1,50) = penyedia.nama and
						pbf.id_inventory is null;
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into inventory.penyedia ( NAMA, ALAMAT, TELEPON, FAX, TANGGAL, STATUS )
				select 		SUBSTR(pbf.nama_pbf,1,50), pbf.alamat, pbf.telp, pbf.fax, current_timestamp, 1
					from 	rsfMaster.mkatalog_pbf pbf
					where	pbf.id_inventory is null;

				UPDATE 		rsfMaster.mkatalog_pbf pbf, inventory.penyedia penyedia
					SET		pbf.id_inventory = penyedia.id
					WHERE   SUBSTR(pbf.nama_pbf,1,50) = penyedia.nama and
							pbf.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog pbf, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_pbf;
		ELSEIF (aOBJ = "pabrik") THEN
			-- insert to rsfMaster
			insert		into rsfMaster.mkatalog_pabrik
						(	id, id_teamterima, id_inventory, 
							kode, nama_pabrik, npwp, alamat, kota,
							kodepos, telp, fax, email, 
							cp_name, cp_telp, sts_aktif, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_pabrik, mk.npwp, mk.alamat, mk.kota,
						mk.kodepos, mk.telp, mk.fax, mk.email, 
						mk.cp_name, mk.cp_telp, mk.sts_aktif, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_pabrik mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_pabrik ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfMaster.mkatalog_pabrik pabrik, 
						( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
				SET		pabrik.id_inventory = ref39pabrik.id
				WHERE   pabrik.nama_pabrik 	= ref39pabrik.deskripsi and
						pabrik.id_inventory is null;
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into master.referensi ( JENIS, DESKRIPSI, REF_ID, STATUS )
				select 		39, pabrik.nama_pabrik, '', 1
					from 	rsfMaster.mkatalog_pabrik pabrik
					where	pabrik.id_inventory is null;
				UPDATE 		rsfMaster.mkatalog_pabrik pabrik, 
							( select id, deskripsi from master.referensi where JENIS = 39) ref39pabrik
					SET		pabrik.id_inventory = ref39pabrik.id
					WHERE   pabrik.nama_pabrik 	= ref39pabrik.deskripsi and
							pabrik.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog pabrik, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_pabrik;
		ELSEIF (aOBJ = "generik") THEN
			-- tidak ada padanan generik id inventory
			insert		into rsfMaster.mkatalog_generik
						(	id,	id_teamterima, id_inventory,
							kode, nama_generik, restriksi, userid_updt, sysdate_updt
						)
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_generik, mk.restriksi, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_generik mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_generik ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog generik, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_generik;
		ELSEIF (aOBJ = "brand") THEN
			-- tidak ada kesetaraan brand di inventory
			insert		into rsfMaster.mkatalog_brand
						(	id,	id_teamterima, id_inventory, kode,
							id_generik, nama_dagang, userid_updt, sysdate_updt )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.id_generik, mk.nama_dagang, mk.userid_updt, mk.sysdate_updt
				from 	rsfTeamterima.masterf_brand mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_brand ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog brand, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_brand;
		ELSEIF (aOBJ = "buffergudang") THEN
			-- insert to rsfMaster
			-- select 		count(1) 
			-- 	from 	rsfTeamterima.laporan_buffer_gudang lbg,
			--			rsfTeamterima.masterf_generik mg 
			--	where 	mg.id = lbg.id_generik;
			insert		into rsfMaster.mkatalog_buffer_gudang
						(	id_katalog, katalog_kode, id_generik, jenis_moving, lead_time, 
							persen_buffer, persen_leadtime,
							jumlah_avg, jumlah_buffer, jumlah_leadtime, jumlah_rop,
							sysdate_updt, userid_updt, status )
			select 		mf.id as id_katalog, mk.id_katalog, mg.id as id_generik,
						mk.jenis_moving, mk.lead_time, mk.persen_buffer, mk.persen_leadtime, 
						mk.jumlah_avg, mk.jumlah_buffer, mk.jumlah_leadtime, mk.jumlah_rop, 
						mk.sysdate_updt, mk.userid_updt, mk.status
				from 	rsfMaster.mkatalog_farmasi mf,
						rsfMaster.mkatalog_generik mg,
						rsfTeamterima.laporan_buffer_gudang mk
						left outer join
						(	select		id_katalog
								from	rsfMaster.mkatalog_buffer_gudang ) subquery
						on 	mk.id_katalog 		= subquery.id_katalog
				where	mf.kode					= mk.id_katalog and
						mg.id_teamterima		= mk.id_generik and
						subquery.id_katalog is null;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog buffer gudang, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_buffer_gudang;
		ELSEIF (aOBJ = "farmasi") THEN
			-- insert to rsfMaster
			insert		into rsfMaster.mkatalog_farmasi
						(	id, id_teamterima, id_inventory, 
							kode, nama_sediaan, nama_barang,
							id_brand, id_jenisbarang, id_kelompokbarang, id_kemasanbesar, id_kemasankecil, 
							id_sediaan, isi_kemasan, isi_sediaan, jumlah_itembeli, jumlah_itembonus,
							tgl_berlaku_bonus, tgl_berlaku_bonus_akhir, kemasan, jenis_barang, 
							id_pbf, id_pabrik,
							harga_beli, harga_kemasanbeli, diskon_beli, harga_jual, diskon_jual,
							stok_adm, stok_fisik, stok_min, stok_opt,
							formularium_rs, formularium_nas, generik, live_saving, kode_barang_nasional,
							sts_frs, sts_fornas, sts_generik, sts_kronis, sts_livesaving,
							sts_produksi, sts_konsinyasi, sts_ekatalog, sts_sumbangan, sts_narkotika,
							sts_psikotropika, sts_prekursor, sts_keras, sts_bebas, sts_bebasterbatas,
							sts_part, sts_alat, sts_asset, sts_aktif, sts_hapus,
							moving, leadtime, optimum, buffer, zat_aktif, retriksi, keterangan, aktifasi,
							userid_in, sysdate_in, userid_updt, sysdate_updt, jml_max )
			select 		mk.id as id, mk.id as id_teamterima, null as id_inventory, 
						mk.kode, mk.nama_sediaan, mk.nama_barang,
						mk.id_brand, mk.id_jenisbarang, mk.id_kelompokbarang, mk.id_kemasanbesar, mk.id_kemasankecil, 
						mk.id_sediaan, mk.isi_kemasan, mk.isi_sediaan, mk.jumlah_itembeli, mk.jumlah_itembonus,
						mk.tgl_berlaku_bonus, mk.tgl_berlaku_bonus_akhir, mk.kemasan, mk.jenis_barang, 
						mk.id_pbf, mk.id_pabrik,
						mk.harga_beli, mk.harga_kemasanbeli, mk.diskon_beli, mk.harga_jual, mk.diskon_jual,
						mk.stok_adm, mk.stok_fisik, mk.stok_min, mk.stok_opt,
						mk.formularium_rs, mk.formularium_nas, mk.generik, mk.live_saving, mk.kode_barang_nasional,
						mk.sts_frs, mk.sts_fornas, mk.sts_generik, mk.sts_kronis, mk.sts_livesaving,
						mk.sts_produksi, mk.sts_konsinyasi, mk.sts_ekatalog, mk.sts_sumbangan, mk.sts_narkotika,
						mk.sts_psikotropika, mk.sts_prekursor, mk.sts_keras, mk.sts_bebas, mk.sts_bebasterbatas,
						mk.sts_part, mk.sts_alat, mk.sts_asset, mk.sts_aktif, mk.sts_hapus,
						mk.moving, mk.leadtime, mk.optimum, mk.buffer, mk.zat_aktif, mk.retriksi, mk.keterangan, mk.aktifasi,
						mk.userid_in, mk.sysdate_in, mk.userid_updt, mk.sysdate_updt, mk.jml_max
				from 	rsfTeamterima.masterf_katalog mk
						left outer join
						(	select		id_teamterima
								from	rsfMaster.mkatalog_farmasi ) subquery
						on mk.id = subquery.id_teamterima
				where	mk.id > 0 and
						subquery.id_teamterima is null;
			-- update id from inventory
			UPDATE 		rsfMaster.mkatalog_farmasi farmasi, inventory.barang barang
				SET		farmasi.id_inventory = barang.id
				WHERE   farmasi.kode = barang.KODE_BARANG and
						farmasi.id_inventory is null;
			-- insert to inventory & update id lagi
			IF (aINVinsert = 1) THEN
				insert into inventory.barang ( 
							   NAMA, KATEGORI, SATUAN, MERK, PENYEDIA, GENERIK, JENIS_GENERIK,
							   FORMULARIUM, STOK, HARGA_BELI, PPN, HARGA_JUAL,
							   MASA_BERLAKU, JENIS_PENGGUNAAN_OBAT, KLAIM_TERPISAH,
							   TANGGAL, OLEH, STATUS,
							   KODE_PSEDIA, KODE_BARANG, KODE_PERSEDIAAN, MOVING )
				select 		SUBSTR(farmasi.nama_barang,1,150), '1', kemasan.id_inventory, 
							pabrik.id_inventory, pbf.id_inventory, 
							0 as GENERIK, 
							2 as JENIS_GENERIK,   -- '1 : GENERIK, 2 : NON GENERIK',
							2 as FORMULARIUM,     -- '1 : FORMULARIUM 2: NON FORMULARIUM',
							0, 0, 0, 0, null, 0, 0,
							current_timestamp, 0, 1, '0', farmasi.kode, '', null
					from 	rsfMaster.mkatalog_farmasi farmasi,
							rsfMaster.mkatalog_kemasan kemasan,
							rsfMaster.mkatalog_pbf pbf,
							rsfMaster.mkatalog_pabrik pabrik
					where	farmasi.id_pabrik 			=  pabrik.id and
					        farmasi.id_pbf    			=  pbf.id and
							farmasi.id_kemasankecil 	=  kemasan.id and
							farmasi.id_inventory 		is null;

				UPDATE 		rsfMaster.mkatalog_farmasi farmasi, inventory.barang barang
					SET		farmasi.id_inventory = barang.id
					WHERE   farmasi.kode = barang.KODE_BARANG and
							farmasi.id_inventory is null;
			END IF;
			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster katalog farmasi, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mkatalog_farmasi;
		ELSE
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('rsfMaster, object ''', aOBJ,''' tidak ditemukan.') as statmessage,
						'' as data;
		END IF;
	COMMIT;
END //
DELIMITER ;
