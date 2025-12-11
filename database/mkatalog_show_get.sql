DROP PROCEDURE IF EXISTS rsfKatalog.mkatalog_show_get;
DELIMITER //
CREATE PROCEDURE rsfKatalog.mkatalog_show_get(
	aJson TEXT
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- mkatalog_show_get 		 			 																	-- */
	/* -- description   : mencari data master katalog berdasarkan object dan ID										-- */
	/* -- spesification : 						 		 															-- */
	/* -- sysdateLast 	: 2023-04-13 12:00 																			-- */
	/* -- useridLast  	: can 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vOBJ 	VARCHAR(35);
	DECLARE vID 	INTEGER(11);
	DECLARE aID 	INTEGER(11);

	SET vOBJ 		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.object'));
	SET vID 		= JSON_UNQUOTE(JSON_EXTRACT(aJson, '$.value'));

	IF (vOBJ = "pabrik") THEN
		SELECT mp.id INTO aID FROM rsfKatalog.mkatalog_pabrik mp WHERE mp.sts_aktif = 1 AND mp.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
						1 AS rowcount,
						concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
						mp.id ,mp.id_teamterima ,mp.id_inventory ,mp.kode ,mp.nama_pabrik ,mp.npwp ,mp.alamat ,
						mp.kota ,mp.kodepos ,mp.telp ,mp.fax ,mp.email ,mp.cp_name ,mp.cp_telp ,mp.userid_updt ,up.name ,DATE_FORMAT(mp.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt 
			FROM 		rsfKatalog.mkatalog_pabrik mp 
				LEFT JOIN rsfAuth.users_practitioner up ON mp.userid_updt = up.id 
			WHERE		mp.sts_aktif = 1
				AND		mp.id = vID;
		END IF;

	ELSEIF (vOBJ = "kemasan") THEN
		SELECT mk.id INTO aID FROM rsfKatalog.mkatalog_kemasan mk WHERE mk.sts_aktif = 1 AND mk.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,
	                    1 AS rowcount,
	                    concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
	                    mk.id ,mk.id_teamterima ,mk.id_inventory ,mk.kode ,mk.kode_med ,mk.nama_kemasan ,mk.userid_updt ,up.name ,DATE_FORMAT(mk.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt
			FROM 		rsfKatalog.mkatalog_kemasan mk
				LEFT JOIN rsfAuth.users_practitioner up ON mk.userid_updt = up.id
	        WHERE		mk.sts_aktif = 1
	        	AND		mk.id = vID;
    	END IF;

	ELSEIF (vOBJ = "pbf") THEN
		SELECT mp.id INTO aID FROM rsfKatalog.mkatalog_pbf mp WHERE mp.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
	                    1 AS rowcount,
	                    concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
	                    mp.id ,mp.id_teamterima ,mp.id_inventory ,mp.kode ,mp.nama_pbf ,mp.npwp ,mp.alamat ,mp.kota ,mp.kodepos ,
	                    mp.telp ,mp.fax ,mp.email ,mp.kepala_cabang ,mp.cp_name ,mp.cp_telp ,mp.userid_updt ,up.name ,DATE_FORMAT(mp.sysdate_updt , "%Y-%m-%d %H:%i:%s") sysdate_updt
	        FROM 	    rsfKatalog.mkatalog_pbf mp 
	            LEFT JOIN	rsfAuth.users_practitioner up ON mp.userid_updt  = up.id
			WHERE		mp.id = vID;
		END IF;

	ELSEIF (vOBJ = "generik") THEN
		SELECT mg.id INTO aID FROM rsfKatalog.mkatalog_generik mg WHERE mg.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
	                    1 AS rowcount,
	                    concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
	                    mg.id, mg.id_teamterima, mg.id_inventory, mg.kode, mg.nama_generik, mg.restriksi, mg.userid_updt ,up.name ,DATE_FORMAT(mg.sysdate_updt , "%Y-%m-%d %H:%i:%s") sysdate_updt
	        FROM 		rsfKatalog.mkatalog_generik mg 
	            LEFT JOIN	rsfAuth.users_practitioner up ON mg.userid_updt = up.id
	        WHERE		mg.id = vID;
		END IF;

	ELSEIF (vOBJ = "kelompok") THEN
		SELECT mk.id INTO aID FROM rsfKatalog.mkatalog_kelompok mk WHERE mk.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
	                    1 AS rowcount,
	                    concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
	                    mk.id, mk.id_teamterima, mk.id_inventory, mk.id_hardcode, mh.jenis_hardcode, mh.keterangan, mk.kode, mk.kelompok_barang, mk.kode_temp, mk.no_urut, 
	                    mk.gol, mk.bid, mk.kel, mk.subkel, mk.subsubkel, mk.userid_updt ,up.name ,DATE_FORMAT( mk.sysdate_updt , "%Y-%m-%d %H:%i:%s") sysdate_updt
	        FROM 		rsfKatalog.mkatalog_kelompok mk
	        	LEFT JOIN	rsfKatalog.mkatalog_hardcode mh ON mk.id_hardcode = mh.id_hardcode
	            LEFT JOIN	rsfAuth.users_practitioner up ON mk.userid_updt = up.id 
	        WHERE		mk.id = vID;
		END IF;

	ELSEIF (vOBJ = "brand") THEN
		SELECT mb.id INTO aID FROM rsfKatalog.mkatalog_brand mb WHERE mb.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
						1 AS rowcount,
						concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
						mb.id, mb.id_teamterima, mb.id_inventory, mb.kode, mb.id_generik, mb.nama_dagang, mb.userid_updt, up.name, DATE_FORMAT( mb.sysdate_updt , "%Y-%m-%d %H:%i:%s") sysdate_updt 
			FROM 		rsfKatalog.mkatalog_brand mb 
				LEFT JOIN	rsfAuth.users_practitioner up ON mb.userid_updt = up.id
			WHERE		mb.id = vID;
		END IF;

	ELSEIF (vOBJ = "buffer-gudang") THEN
		SELECT mbg.id INTO aID FROM rsfKatalog.mkatalog_buffer_gudang mbg WHERE mbg.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
						1 AS rowcount,
						concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
						mbg.id, mbg.id_katalog, mbg.katalog_kode, mbg.id_generik, mbg.jenis_moving, mbg.lead_time, mbg.persen_buffer, mbg.persen_leadtime, mbg.jumlah_avg, 
						mbg.jumlah_buffer, mbg.jumlah_leadtime, mbg.jumlah_rop, DATE_FORMAT(mbg.sysdate_updt , "%Y-%m-%d %H:%i:%s") sysdate_updt, mbg.userid_updt, up.name, mbg.status 
			FROM 		rsfKatalog.mkatalog_buffer_gudang mbg
				LEFT JOIN	rsfAuth.users_practitioner up ON mbg.userid_updt = up.id
			WHERE		mbg.status = 1
				AND 	mbg.id = vID;
		END IF;

	ELSEIF (vOBJ = "jenis-anggaran") THEN
		SELECT aj.id INTO aID FROM rsfKatalog.mkatalog_anggaranjns aj WHERE aj.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
						1 AS rowcount,
						concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
						aj.id, aj.kode, aj.jenis_anggaran, aj.sts_aktif, aj.userid_in, up.name name_in, 
						DATE_FORMAT(aj.sysdate_in, "%Y-%m-%d %H:%i:%s") sysdate_in, aj.userid_updt, up1.name name_updt, 
						DATE_FORMAT(aj.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt 
			FROM 		rsfKatalog.mkatalog_anggaranjns aj
				LEFT JOIN	rsfAuth.users_practitioner up ON aj.userid_in = up.id
				LEFT JOIN	rsfAuth.users_practitioner up1 ON aj.userid_updt = up1.id
			WHERE		aj.sts_aktif = 1
				AND 	aj.id = vID;
		END IF;

	ELSEIF (vOBJ = "sub-jenis-anggaran") THEN
		SELECT ajs.id INTO aID FROM rsfKatalog.mkatalog_anggaranjnssub ajs WHERE ajs.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 		0 AS statcode,	
						1 AS rowcount,
						concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
						ajs.id, ajs.id_jenis, aj.kode, aj.jenis_anggaran, ajs.thn_aktif, ajs.kode, ajs.subjenis_anggaran, ajs.keterangan, ajs.sts_aktif, 
						ajs.userid_in, up.name name_in, DATE_FORMAT(ajs.sysdate_in, "%Y-%m-%d %H:%i:%s") sysdate_in, ajs.userid_updt, up1.name name_updt, DATE_FORMAT(ajs.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt  
			FROM 		rsfKatalog.mkatalog_anggaranjnssub ajs
				LEFT JOIN 	rsfKatalog.mkatalog_anggaranjns aj ON ajs.id_jenis = aj.id
				LEFT JOIN	rsfAuth.users_practitioner up ON ajs.userid_in = up.id
				LEFT JOIN	rsfAuth.users_practitioner up1 ON ajs.userid_updt = up1.id
			WHERE		ajs.sts_aktif = 1
				AND 	ajs.id = vID;
		END IF;

	ELSEIF (vOBJ = "farmasi") THEN
		SELECT ajs.id INTO aID FROM rsfKatalog.mkatalog_farmasi ajs WHERE ajs.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 	0 AS statcode,	
					1 AS rowcount,
					concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
					(select CONCAT('[',GROUP_CONCAT(CONCAT('{','"id"',':',mfb.id,',','"id_pabrik"',':',mfb.id_pabrik,',','"nm_pabrik"',':"',mb.nama_pabrik ,'",','"no_urut"',':',mfb.no_urut,',','"sts_aktif"',':',mfb.sts_aktif,'}')),']') from rsfKatalog.mkatalog_farmasi_pabrik mfb LEFT JOIN rsfKatalog.mkatalog_pabrik mb ON mfb.id_pabrik = mb.id WHERE mfb.id=vID) as pabrik,
					f.id, f.id_teamterima, f.id_inventory, f.kode, f.nama_sediaan, f.nama_barang, f.id_brand, mb.nama_dagang nama_brand,  mk.id_hardcode,
					f.id_jenisbarang, ma.subjenis_anggaran nm_subjenis_anggaran, f.id_kelompokbarang, mk.kelompok_barang, f.id_kemasanbesar, mk2.nama_kemasan kemasan_besar, mk2.kode kode_kemasan_besar, 
					f.id_kemasankecil, mk3.nama_kemasan kemasan_kecil, mk3.kode kode_kemasan_kecil, f.id_sediaan, f.isi_kemasan, f.isi_sediaan, f.jumlah_itembeli, f.jumlah_itembonus, f.tgl_berlaku_bonus, 
					f.tgl_berlaku_bonus_akhir, f.kemasan, f.jenis_barang, f.id_pbf, mp.nama_pbf, f.id_pabrik, mp2.nama_pabrik, f.harga_beli, f.harga_kemasanbeli, f.diskon_beli, f.harga_jual, 
					f.diskon_jual, f.stok_adm, f.stok_fisik, f.stok_min, f.stok_opt, f.formularium_rs, f.formularium_nas, f.generik, f.live_saving, f.kode_barang_nasional, f.sts_frs, f.sts_fornas, f.sts_generik, f.sts_kronis, 
					f.sts_livesaving, f.sts_produksi, f.sts_konsinyasi, f.sts_ekatalog, f.sts_sumbangan, f.sts_narkotika, f.sts_psikotropika, f.sts_prekursor, f.sts_keras, f.sts_bebas, f.sts_bebasterbatas, f.sts_part, f.sts_alat, 
					f.sts_asset, f.sts_aktif, f.sts_hapus, f.moving, f.leadtime, f.optimum, f.buffer, f.zat_aktif, f.retriksi, f.keterangan, f.aktifasi, f.userid_in, up.name name_in, DATE_FORMAT(f.sysdate_in, "%Y-%m-%d %H:%i:%s") sysdate_in, 
					f.userid_updt, up1.name name_updt, DATE_FORMAT(f.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt, f.jml_max, 
					f.id_kfa91, kfa91.uraian uraian_kfa91, kfa91.satuan satuan_kfa91, f.id_kfa92, kfa92.uraian uraian_kfa92, kfa92.satuan satuan_kfa92, f.id_kfa93, kfa93.uraian uraian_kfa93, kfa93.satuan_kecil,
					f.id_barang_sakti, ms.uraian, f.id_dosis, md.nama nama_dosis, md.kode kode_dosis, f.isi_dosis
			FROM 	rsfKatalog.mkatalog_farmasi f
				LEFT JOIN	rsfKatalog.mkatalog_brand mb ON f.id_brand = mb.id 
				LEFT JOIN	rsfKatalog.mkatalog_anggaranjnssub ma ON f.id_jenisbarang = ma.id 
				LEFT JOIN	rsfKatalog.mkatalog_kelompok mk ON f.id_kelompokbarang = mk.id 
				LEFT JOIN	rsfKatalog.mkatalog_kemasan mk2 ON f.id_kemasanbesar = mk2.id 
				LEFT JOIN	rsfKatalog.mkatalog_kemasan mk3 ON f.id_kemasankecil = mk3.id 
				LEFT JOIN 	rsfKatalog.mkatalog_pbf mp ON f.id_pbf = mp.id 
				LEFT JOIN 	rsfKatalog.mkatalog_pabrik mp2 ON f.id_pabrik = mp2.id 
				LEFT JOIN	rsfAuth.users_practitioner up ON f.userid_in = up.id
				LEFT JOIN	rsfAuth.users_practitioner up1 ON f.userid_updt = up1.id
				LEFT JOIN 	rsfKatalog.mkatalog_kfa91 kfa91 ON f.id_kfa91 = kfa91.id
				LEFT JOIN 	rsfKatalog.mkatalog_kfa92 kfa92 ON f.id_kfa92 = kfa92.id
				LEFT JOIN 	rsfKatalog.mkatalog_kfa93 kfa93 ON f.id_kfa93 = kfa93.id
				LEFT JOIN 	rsfKatalog.mkatalog_sakti ms ON f.id_barang_sakti = ms.id
				LEFT JOIN 	rsfKatalog.mkatalog_dosis md ON f.id_dosis = md.id
			WHERE	f.id = vID;
		END IF;

	ELSEIF (vOBJ = "sakti") THEN
		SELECT ms.id INTO aID FROM rsfKatalog.mkatalog_sakti ms WHERE ms.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 	0 AS statcode,	
					1 AS rowcount,
					concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
					ms.id, ms.id_hdr, msh.uraian uraian_sakti, ms.kode, ms.uraian, ms.sts_aktif,
					ms.userid_in, up1.name name_in, DATE_FORMAT(ms.sysdate_in, "%Y-%m-%d %H:%i:%s") sysdate_in,
					ms.userid_updt, up.name, DATE_FORMAT(ms.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt 
			FROM 	rsfKatalog.mkatalog_sakti ms
				LEFT JOIN	rsfKatalog.mkatalog_sakti_hdr msh ON msh.id = ms.id_hdr
				LEFT JOIN  	rsfAuth.users_practitioner up ON up.id = ms.userid_updt
				LEFT JOIN  	rsfAuth.users_practitioner up1 ON up1.id = ms.userid_in
			WHERE	ms.id = vID;
		END IF;

	ELSEIF (vOBJ = "sakti-hdr") THEN
		SELECT msh.id INTO aID FROM rsfKatalog.mkatalog_sakti_hdr msh WHERE msh.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 	0 AS statcode,	
					1 AS rowcount,
					concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
					msh.id, msh.kode, msh.uraian, msh.userid_updt, up.name name_updt, 
					DATE_FORMAT(msh.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt, 
					DATE_FORMAT(msh.sysdate_in, "%Y-%m-%d %H:%i:%s") sysdate_in, msh.userid_in, up1.name name_in 
			FROM 	rsfKatalog.mkatalog_sakti_hdr msh
				LEFT JOIN  	rsfAuth.users_practitioner up ON up.id = msh.userid_updt
				LEFT JOIN  	rsfAuth.users_practitioner up1 ON up1.id = msh.userid_in
			WHERE	msh.id = vID;
		END IF;

	ELSEIF (vOBJ = "dosis") THEN
		SELECT md.id INTO aID FROM rsfKatalog.mkatalog_dosis md WHERE md.id = vID;

		IF (aID IS NULL) THEN
			SELECT 	20001 as statcode,
	                0 as rowcount,
	                concat('SHOW, dengan ID "', vID,'" tidak ditemukan atau sudah tidak aktif.') as statmessage,
	                '' as data;
		ELSE
			SELECT 	0 AS statcode,	
					1 AS rowcount, 
					concat('SHOW, dengan ID "', vID,'" berhasil') as statmessage,
					md.id, md.kode, md.nama, md.sts_aktif, 
					md.userid_in, up.name name_in, DATE_FORMAT(md.sysdate_in, "%Y-%m-%d %H:%i:%s") sysdate_in, 
					md.userid_updt, up1.name name_updt, DATE_FORMAT(md.sysdate_updt, "%Y-%m-%d %H:%i:%s") sysdate_updt 
			FROM 	rsfKatalog.mkatalog_dosis md
				LEFT JOIN  	rsfAuth.users_practitioner up ON up.id = md.userid_in
				LEFT JOIN  	rsfAuth.users_practitioner up1 ON up1.id = md.userid_updt
			WHERE	md.id = vID;
		END IF;

	END IF;
END //
DELIMITER ;
