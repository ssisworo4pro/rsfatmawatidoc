DROP PROCEDURE IF EXISTS rsfPelaporan.proc_lap_persediaan;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_lap_persediaan(
	aBulan CHAR(6)
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- proc_lap_persediaan																						-- */
	/* -- description   : merekap data transaksi farmasi															-- */
	/* -- spesification : rekap PENERIMAAN REKANAN RINCI															-- */
	/* -- 				  rekap 1. stok opname																		-- */
	/* -- 				  rekap 2. barang KOREKSI																	-- */
	/* -- 				  rekap 3. antar ruangan																	-- */
	/* -- 				  rekap 4. BARANG PRODUKSI																	-- */
	/* -- 				  rekap 5. PENERIMAAN BARANG REKANAN														-- */
	/* -- 				  rekap 6. PENJUALAN																		-- */
	/* -- 				  rekap 7. RETUR PENJUALAN																	-- */
	/* -- 				  rekap 8. PELAYANAN																		-- */
	/* -- sysdateLast 	: 2023-01-17 12:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 2 																						-- */
	/* -- revisionNote  : penerimaan rekanan dan stokopname di-skip													-- */
	/* -- revisionNote  : change farmasi criteria to SUBSTRING(pg.TUJUAN,1,5) = '10103'	and LENGTH(pg.TUJUAN) = 9	-- */
	/* --                 (case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) 				-- */
	/* --                       then 1 else 2 end)																	-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vTanggal CHAR(10);
	DECLARE vIDProses BIGINT;
	DECLARE vIDProsesTemp BIGINT;
	DECLARE vCounted BIGINT;
	DECLARE vIDOpname BIGINT;
	DECLARE vTransaksi_status BIGINT;
	DECLARE vTrxHeader_rowsumber BIGINT;
	DECLARE vTrxHeader_rowdata BIGINT;
	DECLARE vTrxDetail_rowsumber BIGINT;
	DECLARE vTrxDetail_rowdata BIGINT;
	DECLARE vTrxDetail_trxsumber decimal(20,4);
	DECLARE vTrxDetail_trxdata decimal(20,4);
	
	DECLARE vTrxDetail_rowsumber_temp BIGINT;
	DECLARE vTrxDetail_trxsumber_temp decimal(20,4);

	DECLARE vKasus1_rowsumber BIGINT;
	DECLARE vKasus1_trxsumber decimal(20,4);
	DECLARE vKasus2_rowsumber BIGINT;
	DECLARE vKasus2_trxsumber decimal(20,4);
	DECLARE vTransaksi_kasus1 BIGINT;
	DECLARE vDone int;
	
	/*
	Stok Opname di skip dulu di proses lain.
	Penerimaan barang di skip langsung ambil dari teamTerima
	
	DECLARE cursorStokOpname cursor for 
			select 		ID 
				from 	inventory.stok_opname
				where 	status 		 	 = 'Final' and
						TANGGAL 		>= vTanggal and 
						TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
	DECLARE cursorRekanan cursor for 
			select 		ID 
				from 	inventory.penerimaan_barang
				where 	status 		 	 = 2 and
						TANGGAL_DIBUAT 	>= vTanggal and 
						TANGGAL_DIBUAT 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vDone = 1;
	*/
	SET vTanggal = CONCAT(SUBSTRING(aBulan, 1, 4), '-', SUBSTRING(aBulan, 5, 2), '-01');
	START TRANSACTION;
		-- create header proses
		insert into rsfPelaporan.slap_persediaan ( tanggal_proses, bulan )
			values ( CURRENT_TIMESTAMP, aBulan );
		SELECT LAST_INSERT_ID() INTO vIDProses;

		-- proses 0 --
		-- proses insert data untuk :
		-- 0. PENERIMAAN REKANAN RINCI
		/*

		-- proses ulang PENERIMAAN REKANAN RINCI hanya jika statistiknya tidak sama
		-- baca statistik PENERIMAAN REKANAN RINCI
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan_trmrkn 
			where 	bulan 			 = aBulan;
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	inventory.penerimaan_barang
			where 	status 			 = 2 and
					TANGGAL_DIBUAT	>= vTanggal and 
					TANGGAL_DIBUAT	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(COALESCE(sod.JUMLAH, 0)), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from	inventory.penerimaan_barang so,
					inventory.penerimaan_barang_detil sod,
					inventory.barang b,
					inventory.kategori k,
					master.ruangan r
			  where	so.id 				 = sod.PENERIMAAN and
					sod.BARANG 			 = b.id and
					b.KATEGORI 			 = k.id and
					so.RUANGAN 			 = r.id and
					so.status 		 	 = 2 and
					so.TANGGAL_DIBUAT	>= vTanggal and 
					so.TANGGAL_DIBUAT 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);

		-- deteksi kasus #1 PENERIMAAN REKANAN RINCI vs barang_ruangan
		SET vKasus1_rowsumber = 0;
		SET vKasus1_trxsumber = 0;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 99;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				
				INSERT INTO rsfPelaporan.dlap_persediaan_trmrkndtl_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan_trmrkndtl
					WHERE 	bulan 		= aBulan;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan_trmrkndtl
					WHERE 	bulan 		= aBulan;

				INSERT INTO rsfPelaporan.dlap_persediaan_trmrkn_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan_trmrkn 
					WHERE 	bulan 		= aBulan;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan_trmrkn 
					WHERE 	bulan 		= aBulan;
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				99,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );

		-- eksekusi insert PENERIMAAN REKANAN RINCI
		IF (vTransaksi_status != 2) THEN
			SET vDone = 0;
			OPEN cursorRekanan;
			getRekanan: LOOP
				FETCH cursorRekanan INTO vIDOpname;
				IF vDone = 1 THEN 
					LEAVE getRekanan;
				ELSE
					-- transaksi PENERIMAAN REKANAN RINCI.... header
					insert into	rsfPelaporan.dlap_persediaan_trmrkn ( 
									id_penerimaan, id_proses, bulan, depo_kode,
									depo_nama, NO_SP, FAKTUR, TANGGAL, TANGGAL_PENERIMAAN, rekanan_id, rekanan_nama,
									KETERANGAN, PPN, SUMBER_DANA, MASA_BERLAKU, TANGGAL_DIBUAT, OLEH, STATUS, JENIS, REF_PO
								)
					select 		so.ID as id_penerimaan,
								vIDProses as id_proses,
								aBulan as bulan,
								so.RUANGAN as depo_kode,
								r.DESKRIPSI as depo_nama,
								so.NO_SP,
								so.FAKTUR,
								so.TANGGAL,
								so.TANGGAL_PENERIMAAN,
								so.REKANAN as rekanan_id,
								p.NAMA as rekanan_nama,
								so.KETERANGAN,
								so.PPN,
								so.SUMBER_DANA,
								so.MASA_BERLAKU,
								so.TANGGAL_DIBUAT,
								so.OLEH,
								so.STATUS,
								so.JENIS,
								so.REF_PO
						from	master.ruangan r,
								inventory.penyedia p,
								inventory.penerimaan_barang so
						where	so.RUANGAN 	= r.ID and
								so.REKANAN  = p.ID and
								so.id 		= vIDOpname;
								
					-- stok PENERIMAAN REKANAN RINCI rinci
					insert into rsfPelaporan.dlap_persediaan_trmrkndtl ( 
									id_penerimaan_dtl, id_proses, bulan, id_penerimaan, BARANG, NO_BATCH, JUMLAH,
									jml_trxruangan, JUMLAH_BESAR, JUMLAH_KECIL, BONUS, HARGA, HARGA_BESAR,
									DISKON, DISKON_P, ONGKIR, MASA_BERLAKU, STATUS, REF_PO_DETIL
								)
					select		sod.id as id_penerimaan_dtl,
								vIDProses as id_proses,
								aBulan as bulan,
								sod.PENERIMAAN as id_penerimaan,
								sod.BARANG,
								sod.NO_BATCH,
								sod.JUMLAH,
								(COALESCE(
									( 
										select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 21 THEN 1 ELSE -1 END)) as jumlah
										from 	inventory.transaksi_stok_ruangan tsr,
												inventory.barang_ruangan br2
										where 	tsr.REF 				= sod.ID and 
												( tsr.JENIS 			= 21 or
												  tsr.JENIS 			= 24 ) and
												tsr.BARANG_RUANGAN 		= br2.ID and
												br.ID                   = br2.ID
										group   by br2.BARANG
									), 0)) as jml_trxruangan,
								sod.JUMLAH_BESAR,
								sod.JUMLAH_KECIL,
								sod.BONUS,
								sod.HARGA,
								sod.HARGA_BESAR,
								sod.DISKON,
								sod.DISKON_P,
								sod.ONGKIR,
								sod.MASA_BERLAKU,
								sod.STATUS,
								sod.REF_PO_DETIL
						from	inventory.penerimaan_barang so,
								inventory.penerimaan_barang_detil sod,
								inventory.barang b,
								inventory.kategori k,
								inventory.barang_ruangan br,
								master.ruangan r
						  where	so.id 				= sod.PENERIMAAN and
								so.RUANGAN 			= br.RUANGAN and
								sod.BARANG 			= br.BARANG and
								br.BARANG 			= b.id and
								b.KATEGORI 			= k.id and
								so.id 				= vIDOpname and
								so.RUANGAN 			= r.id;
				END IF;
			END LOOP getRekanan;
			CLOSE cursorRekanan;
			
			-- baca statistik stok opname
			SELECT		count(1)
				into	vTrxHeader_rowdata
				from 	rsfPelaporan.dlap_persediaan_trmrkn
				where 	id_proses 			= vIDProses;

			SELECT		COALESCE(count(1),0),
						COALESCE(sum(JUMLAH),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from 	rsfPelaporan.dlap_persediaan_trmrkndtl
				WHERE 	id_proses 				= vIDProses;

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 99;
		END IF;
		*/


		-- proses 1 --
		-- proses insert data untuk :
		-- 1. stok opname
		/*

		-- proses ulang stokOpName hanya jika statistiknya tidak sama
		-- baca statistik stok opname
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan_so 
			where 	bulan 			 = aBulan;
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	inventory.stok_opname
			where 	status 			 = 'Final' and
					TANGGAL 		>= vTanggal and 
					TANGGAL 		 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(COALESCE(sod.MANUAL, 0)), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from	inventory.stok_opname so,
					inventory.stok_opname_detil sod,
					inventory.barang b,
					inventory.kategori k,
					inventory.barang_ruangan br,
					master.ruangan r
			  where	so.id 				 = sod.STOK_OPNAME and
					sod.BARANG_RUANGAN 	 = br.ID and
					br.BARANG 			 = b.id and
					b.KATEGORI 			 = k.id and
					so.status 		 	 = 'Final' and
					so.TANGGAL 			>= vTanggal and 
					so.TANGGAL 		 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH) and
					so.RUANGAN 			 = r.id;

		-- deteksi kasus #1 stok_opname_detil vs barang_ruangan
		select 		count(1)
			into	vKasus1_rowsumber
			from	( select		br.ID
							from	inventory.stok_opname so,
									inventory.stok_opname_detil sod
									left outer join inventory.barang_ruangan br
									on sod.BARANG_RUANGAN 	= br.ID
							  where	so.id 				 = sod.STOK_OPNAME and
									so.status 		     = 'Final' and
									so.TANGGAL 			>= vTanggal and 
									so.TANGGAL 		 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH)
							having  br.ID 				is null
					) kasus;
		SET vKasus1_trxsumber = 0;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 11;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				
				INSERT INTO rsfPelaporan.dlap_persediaan_sodtl_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan_sodtl
					WHERE 	bulan 		= aBulan;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan_sodtl
					WHERE 	bulan 		= aBulan;

				INSERT INTO rsfPelaporan.dlap_persediaan_so_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan_so 
					WHERE 	bulan 		= aBulan;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan_so 
					WHERE 	bulan 		= aBulan;
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				11,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );

		-- eksekusi insert stokOpName
		IF (vTransaksi_status != 2) THEN
			SET vDone = 0;
			OPEN cursorStokOpname;
			getOpname: LOOP
				FETCH cursorStokOpname INTO vIDOpname;
				IF vDone = 1 THEN 
					LEAVE getOpname;
				ELSE
					-- transaksi stok opname.... header
					insert into	rsfPelaporan.dlap_persediaan_so ( id_opname, id_proses, bulan, tanggal, sysdate_in, depo_kode, depo_nama,
								kategori, status, trx_jenis, trx_nama, trx_tambahkurang )
					select 		so.id as id_opname,
								vIDProses as id_proses,
								aBulan as bulan,
								if ( so.tanggal is null, cast('2022-01-01 00:00' as datetime), cast(concat(so.tanggal, ' ', so.time) as datetime)) as tanggal,
								so.tanggal_dibuat as sysdate_in,
								r.ID as depo_kode,
								r.DESKRIPSI as depo_nama,
								so.kategori as kategori,
								so.status as status,
								11 as trx_jenis,
								'Stok Opname Balance' as trx_nama,
								'0' as trx_tambahkurang
						from	master.ruangan r
								left outer join master.ruangan_farmasi rf
								on r.ID 	= rf.FARMASI,
								inventory.stok_opname so
						where	so.RUANGAN 	= r.ID and
								so.id 		= vIDOpname;
								
					-- stok opname rinci
					insert into rsfPelaporan.dlap_persediaan_sodtl ( id_opname_dtl, id_proses, bulan, id_opname, id_transaksi,
								tanggal, expired, katalog_id, katalog_kode, katalog_nama, kateg_kode, kateg_nama, jml_opname, jml_trxruangan )
					select		sod.id as id_opname_dtl,
								vIDProses as id_proses,
								aBulan as bulan,
								so.ID as id_opname,
								tsr.ID as id_transaksi,
								-- sod.tanggal as tanggal,
								if ( MONTH(sod.tanggal) = 0, cast('2022-01-01 00:00' as datetime), sod.tanggal) as tanggal,
								if ( MONTH(sod.EXD) = 0, null, sod.EXD ) as expired,
								-- if( cast(sod.EXD as char) = '0000-00-00', null, date(cast(sod.EXD as char))) as expired,
								br.BARANG as katalog_id,
								COALESCE(b.kode_barang,'-') as katalog_kode,
								b.nama as katalog_nama,
								k.id as kateg_kode,
								k.nama as kateg_nama,
								COALESCE(sod.MANUAL, 0) as jml_opname,
								COALESCE(tsr.jumlah, 0) as jml_trxruangan
						from	inventory.stok_opname so,
								inventory.stok_opname_detil sod
								left outer join
									( 
										select 	tsr.ID, tsr.BARANG_RUANGAN, tsr.JUMLAH as JUMLAH
										from 	inventory.transaksi_stok_ruangan tsr,
												( 
													select 	max(ID) as ID, MAX(BARANG_RUANGAN) AS BARANG_RUANGAN 
													from 	inventory.transaksi_stok_ruangan tsrx 
													where 	REF = vIDOpname and (JENIS = 15 or JENIS = 11) group by BARANG_RUANGAN 
												) tsrxx
										where 	tsr.REF = vIDOpname and (tsr.JENIS = 15 or tsr.JENIS = 11) and
												tsr.BARANG_RUANGAN = tsrxx.BARANG_RUANGAN and
												tsr.ID = tsrxx.ID
										order   by tsr.BARANG_RUANGAN 
									) tsr
									on sod.BARANG_RUANGAN = tsr.BARANG_RUANGAN,
								inventory.barang b,
								inventory.kategori k,
								inventory.barang_ruangan br,
								master.ruangan r
						  where	so.id 				= sod.STOK_OPNAME and
								sod.BARANG_RUANGAN 	= br.ID and
								br.BARANG 			= b.id and
								b.KATEGORI 			= k.id and
								so.id 				= vIDOpname and
								so.RUANGAN 			= r.id;
				END IF;
			END LOOP getOpname;
			CLOSE cursorStokOpname;
			
			-- baca statistik stok opname
			SELECT		count(1)
				into	vTrxHeader_rowdata
				from 	rsfPelaporan.dlap_persediaan_so
				where 	id_proses 			= vIDProses;

			SELECT		COALESCE(count(1),0),
						COALESCE(sum(jml_opname),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from 	rsfPelaporan.dlap_persediaan_sodtl
				WHERE 	id_proses 				= vIDProses;

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 11;
		END IF;
		*/


		-- proses 2 --
		-- proses insert data untuk :
		-- 2. barang KOREKSI

		-- proses ulang KOREKSI hanya jika statistiknya tidak sama
		-- baca statistik KOREKSI
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 = aBulan and
					( trx_jenis 	 = 53 or 
					  trx_jenis 	 = 54 );
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	inventory.transaksi_koreksi
			where 	status 		 	 = 2 and
					TANGGAL 		>= vTanggal and 
					TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(tkd.JUMLAH), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from	inventory.transaksi_koreksi tk,
					inventory.transaksi_koreksi_detil tkd
			where 	tk.status 		 = 2 and
					tk.TANGGAL 		>= vTanggal and 
					tk.TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH) and
					tk.id 			 = tkd.KOREKSI;
		
		SET vKasus1_rowsumber = 0;
		SET vKasus1_trxsumber = 0;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 53;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							( trx_jenis = 53 or 
							  trx_jenis = 54 );
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							( trx_jenis = 53 or 
							  trx_jenis = 54 );
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;

		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				53,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );

		-- eksekusi insert KOREKSI
		IF (vTransaksi_status != 2) THEN
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(tk.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						MAX(masref.ID) as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						MAX(masref.DESKRIPSI) as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(tkd.JUMLAH), 0) as jml_trxpersediaan,
						sum(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br
								where 	tsr.REF 			= tkd.ID and 
										tsr.JENIS 			= 53 and
										tsr.BARANG_RUANGAN 	= br.ID and
										tkd.BARANG 			= br.BARANG
								group   by br.BARANG
							), 0)) as jml_rowtrxruangan,
						sum(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 53 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br
								where 	tsr.REF 			= tkd.ID and 
										tsr.JENIS 			= 53 and
										tsr.BARANG_RUANGAN 	= br.ID and
										tkd.BARANG 			= br.BARANG
								group   by br.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.transaksi_koreksi tk
						left outer join
						(	select		ID, DESKRIPSI
								from	master.referensi
								where 	JENIS = 900601 ) masref
						on masref.ID = tk.ALASAN,
						inventory.transaksi_koreksi_detil tkd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	tk.id 				 = tkd.KOREKSI and
						tkd.BARANG 			 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = tk.RUANGAN and
						br.BARANG   		 = tkd.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 53 AND
						tk.JENIS 			 = 1 AND
						tk.STATUS   		 = 2 and 
						tk.TANGGAL 			>= vTanggal and 
						tk.TANGGAL  		 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							tk.JENIS,
							tk.ALASAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							tk.JENIS,
							tk.ALASAN,
							br.BARANG;

			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(tk.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						MAX(masref.ID) as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						MAX(masref.DESKRIPSI) as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(tkd.JUMLAH), 0) as jml_trxpersediaan,
						sum(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br
								where 	tsr.REF 			= tkd.ID and 
										tsr.JENIS 			= 54 and
										tsr.BARANG_RUANGAN 	= br.ID and
										tkd.BARANG 			= br.BARANG
								group   by br.BARANG
							), 0)) as jml_rowtrxruangan,
						sum(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 54 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br
								where 	tsr.REF 			= tkd.ID and 
										tsr.JENIS 			= 54 and
										tsr.BARANG_RUANGAN 	= br.ID and
										tkd.BARANG 			= br.BARANG
								group   by br.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.transaksi_koreksi tk
						left outer join
						(	select		ID, DESKRIPSI
								from	master.referensi
								where 	JENIS = 900602 ) masref
						on masref.ID = tk.ALASAN,
						inventory.transaksi_koreksi_detil tkd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	tk.id 				 = tkd.KOREKSI and
						tkd.BARANG 			 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = tk.RUANGAN and
						br.BARANG   		 = tkd.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 54 AND
						tk.JENIS 			 = 2 AND
						tk.STATUS   		 = 2 and 
						tk.TANGGAL 			>= vTanggal and 
						tk.TANGGAL  		 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							tk.JENIS,
							tk.ALASAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							tk.JENIS,
							tk.ALASAN,
							br.BARANG;

			-- baca statistik KOREKSI
			SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
				
			SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
						COALESCE(sum(jml_trxpersediaan),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from	rsfPelaporan.dlap_persediaan
				WHERE 	id_proses 				= vIDProses and
						( trx_jenis 			= 53 or 
						  trx_jenis 			= 54 );

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 53;
		END IF;
		
		-- proses 3 --
		-- proses insert data untuk :
		-- 3. antar ruangan

		-- proses ulang PENERIMAAN hanya jika statistiknya tidak sama
		-- baca statistik PENERIMAAN
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 = aBulan and
					( trx_jenis 	 = 20 or 
					  trx_jenis 	 = 23 );
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	inventory.penerimaan
			where 	JENIS 		 	 = 2 and
					TANGGAL 		>= vTanggal and 
					TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1) * 2, COALESCE(sum(pd.JUMLAH), 0) * 2
			into	vKasus1_rowsumber, vKasus1_trxsumber
			from	inventory.penerimaan p,
					inventory.pengiriman_detil pd
			where 	p.JENIS 		 = 2 and
					p.TANGGAL 		>= vTanggal and 
					p.TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH) and
					p.REF 			 = pd.PENGIRIMAN;
		SELECT		count(1),
					COALESCE(sum(pd.JUMLAH), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from 	inventory.penerimaan p, 
					inventory.pengiriman pg,
					inventory.pengiriman_detil pd,
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	p.REF 				 = pd.PENGIRIMAN and
					pg.NOMOR			 = pd.PENGIRIMAN and
					br.BARANG 	 		 = b.ID and
					b.KATEGORI 			 = k.ID and
					br.RUANGAN  		 = pg.TUJUAN and
					br.BARANG   		 = pd.BARANG and
					r.id 				 = br.ruangan AND
					jts.ID				 = 20 AND
					p.JENIS     	 	 = 2 and 
					p.TANGGAL 			>= vTanggal and 
					p.TANGGAL  			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(pd.JUMLAH), 0)
			into	vTrxDetail_rowsumber_temp,
					vTrxDetail_trxsumber_temp
			from 	inventory.penerimaan p, 
					inventory.pengiriman pg,
					inventory.pengiriman_detil pd,
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	p.REF 				 = pd.PENGIRIMAN and
					pg.NOMOR			 = pd.PENGIRIMAN and
					br.BARANG 	 		 = b.ID and
					b.KATEGORI 			 = k.ID and
					br.RUANGAN  		 = pg.ASAL and
					br.BARANG   		 = pd.BARANG and
					r.id 				 = br.ruangan AND
					jts.ID				 = 23 AND
					p.JENIS     	 	 = 2 and 
					p.TANGGAL 			>= vTanggal and 
					p.TANGGAL  			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		
		SET vTrxDetail_rowsumber = vTrxDetail_rowsumber + vTrxDetail_rowsumber_temp;
		SET vTrxDetail_trxsumber = vTrxDetail_trxsumber + vTrxDetail_trxsumber_temp;
		SET vKasus1_rowsumber = vKasus1_rowsumber - vTrxDetail_rowsumber;
		SET vKasus1_trxsumber = vKasus1_trxsumber - vTrxDetail_trxsumber;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 20;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							( trx_jenis = 20 or 
							  trx_jenis = 23 );
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							( trx_jenis = 20 or 
							  trx_jenis = 23 );
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				20,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );

		-- eksekusi insert DISTRIBUSI
		IF (vTransaksi_status != 2) THEN
			-- DISTRIBUSI PENERIMAAN BARANG
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(p.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						max(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 1 else 2 end)  as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						max(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 'ruang farmasi' else 'ruang non farmasi' end)  as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(pd.JUMLAH), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pd.ID and 
										tsr.JENIS 				= 20 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 20 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pd.ID and 
										tsr.JENIS 				= 20 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.penerimaan p, 
						inventory.pengiriman pg,
						inventory.pengiriman_detil pd,
						-- inventory.permintaan_detil pmd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	p.REF 				 = pd.PENGIRIMAN and
						-- pmd.ID			 	 = pd.PERMINTAAN_BARANG_DETIL and
						pg.NOMOR			 = pd.PENGIRIMAN and
						br.BARANG 	 		 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = pg.TUJUAN and
						-- br.BARANG   		 = pmd.BARANG and
						br.BARANG   		 = pd.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 20 AND
						p.JENIS     	 	 = 2 and 
						p.TANGGAL 			>= vTanggal and 
						p.TANGGAL  			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 1 else 2 end),
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							(case when (SUBSTRING(pg.ASAL,1,5) = '10103' and LENGTH(pg.ASAL) = 9) then 1 else 2 end),
							br.BARANG;

			-- DISTRIBUSI PENGIRIMAN BARANG
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(p.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						max(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 1 else 2 end)  as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						max(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 'ruang farmasi' else 'ruang non farmasi' end)  as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(pd.JUMLAH), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pd.ID and 
										tsr.JENIS 				= 23 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 23 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pd.ID and 
										tsr.JENIS 				= 23 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.penerimaan p, 
						inventory.pengiriman pg,
						inventory.pengiriman_detil pd,
						-- inventory.permintaan_detil pmd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	p.REF 				 = pd.PENGIRIMAN and
						-- pmd.ID			 	 = pd.PERMINTAAN_BARANG_DETIL and
						pg.NOMOR			 = pd.PENGIRIMAN and
						br.BARANG 	 		 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = pg.ASAL and
						-- br.BARANG   		 = pmd.BARANG and
						br.BARANG   		 = pd.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 23 AND
						p.JENIS     	 	 = 2 and 
						p.TANGGAL 			>= vTanggal and 
						p.TANGGAL  			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 1 else 2 end),
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							(case when (SUBSTRING(pg.TUJUAN,1,5) = '10103' and LENGTH(pg.TUJUAN) = 9) then 1 else 2 end),
							br.BARANG;
							
			-- baca statistik DISTRIBUSI
			SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
				
			SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
						COALESCE(sum(jml_trxpersediaan),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from	rsfPelaporan.dlap_persediaan
				WHERE 	id_proses 				= vIDProses and
						( trx_jenis 			= 20 or 
						  trx_jenis 			= 23 );

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 20;
		END IF;		

		-- proses 4 --
		-- proses insert data untuk :
		-- 4. BARANG PRODUKSI

		-- proses ulang BARANG PRODUKSI hanya jika statistiknya tidak sama
		-- baca statistik BARANG PRODUKSI
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 = aBulan and
					( trx_jenis 	 = 51 or 
					  trx_jenis 	 = 52 );
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	inventory.barang_produksi
			where 	STATUS 		 	 = 2 and
					TANGGAL 		>= vTanggal and 
					TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(bpd.QTY), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from 	inventory.barang_produksi bp, 
					inventory.barang_produksi_detil bpd,
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	bp.ID 				 = bpd.PRODUKSI and
					br.BARANG 	 		 = b.ID and
					b.KATEGORI 			 = k.ID and
					br.RUANGAN  		 = bp.RUANGAN and
					br.BARANG   		 = bpd.BAHAN and
					r.id 				 = br.ruangan AND
					jts.ID				 = 52 AND
					bp.STATUS     	 	 = 2 and 
					bp.TANGGAL 			>= vTanggal and 
					bp.TANGGAL  		 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(bp.QTY), 0)
			into	vKasus1_rowsumber,
					vKasus1_trxsumber
			from 	inventory.barang_produksi bp, 
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	br.BARANG 	 		 = b.ID and
					b.KATEGORI 			 = k.ID and
					br.RUANGAN  		 = bp.RUANGAN and
					br.BARANG   		 = bp.BARANG and
					r.id 				 = br.ruangan AND
					jts.ID				 = 51 AND
					bp.STATUS     	 	 = 2 and 
					bp.TANGGAL 			>= vTanggal and 
					bp.TANGGAL  		 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);

		SET vTrxDetail_rowsumber = vTrxDetail_rowsumber + vKasus1_rowsumber;
		SET vTrxDetail_trxsumber = vTrxDetail_trxsumber + vKasus1_trxsumber;
		
		SET vKasus1_rowsumber = 0;
		SET vKasus1_trxsumber = 0;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 51;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							( trx_jenis = 51 or 
							  trx_jenis = 52 );
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							( trx_jenis = 51 or 
							  trx_jenis = 52 );
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				51,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );

		-- eksekusi insert PRODUKSI
		IF (vTransaksi_status != 2) THEN
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(bp.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						0 as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						'-- non sub --' as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(bpd.QTY), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= bpd.ID and 
										tsr.JENIS 				= 52 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 52 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= bpd.ID and 
										tsr.JENIS 				= 52 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.barang_produksi bp, 
						inventory.barang_produksi_detil bpd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	bp.ID                = bpd.PRODUKSI and
						br.BARANG 	 		 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = bp.RUANGAN and
						br.BARANG   		 = bpd.BAHAN and
						r.id 				 = br.ruangan AND
						jts.ID				 = 52 AND
						bp.STATUS     	 	 = 2 and 
						bp.TANGGAL 			>= vTanggal and 
						bp.TANGGAL  		 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							br.BARANG;

			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(bp.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						0 as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						'-- non sub --' as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(bp.QTY), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= bp.ID and 
										tsr.JENIS 				= 51 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 51 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= bp.ID and 
										tsr.JENIS 				= 51 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.barang_produksi bp, 
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	br.BARANG 	 		 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = bp.RUANGAN and
						br.BARANG   		 = bp.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 51 AND
						bp.STATUS     	 	 = 2 and 
						bp.TANGGAL 			>= vTanggal and 
						bp.TANGGAL  		 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							br.BARANG;
							
			-- baca statistik PRODUKSI
			SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
				
			SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
						COALESCE(sum(jml_trxpersediaan),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from	rsfPelaporan.dlap_persediaan
				WHERE 	id_proses 				= vIDProses and
						( trx_jenis 			= 51 or 
						  trx_jenis 			= 52 );

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 51;

		END IF;		

		-- proses 5 --
		-- proses insert data untuk :
		-- 5. PENERIMAAN BARANG REKANAN
		/*

		-- proses ulang PENERIMAAN BARANG REKANAN hanya jika statistiknya tidak sama
		-- baca statistik PENERIMAAN BARANG REKANAN
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 = aBulan and
					trx_jenis 	 	 = 21;
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	inventory.penerimaan_barang
			where 	STATUS 		 	 = 2 and
					TANGGAL_DIBUAT	>= vTanggal and 
					TANGGAL_DIBUAT 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(pbd.JUMLAH), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from 	inventory.penerimaan_barang pb, 
					inventory.penerimaan_barang_detil pbd,
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	pb.ID 				 = pbd.PENERIMAAN and
					br.BARANG 	 		 = b.ID and
					b.KATEGORI 			 = k.ID and
					br.RUANGAN  		 = pb.RUANGAN and
					br.BARANG   		 = pbd.BARANG and
					r.id 				 = br.ruangan AND
					jts.ID				 = 21 AND
					pb.STATUS     	 	 = 2 and 
					pb.TANGGAL_DIBUAT	>= vTanggal and 
					pb.TANGGAL_DIBUAT	 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);

		SELECT		count(1),
					COALESCE(sum(pbd.JUMLAH), 0)
			into	vKasus1_rowsumber,
					vKasus1_trxsumber
			from 	inventory.penerimaan_barang pb, 
					inventory.penerimaan_barang_detil pbd,
					inventory.jenis_transaksi_stok jts
			where	pb.ID 				 = pbd.PENERIMAAN and
					jts.ID				 = 21 AND
					pb.STATUS     	 	 = 2 and 
					pb.TANGGAL_DIBUAT	>= vTanggal and 
					pb.TANGGAL_DIBUAT	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		
		SET vKasus1_rowsumber = vKasus1_rowsumber - vTrxDetail_rowsumber;
		SET vKasus1_trxsumber = vKasus1_trxsumber - vTrxDetail_trxsumber;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 21;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							trx_jenis 	= 21;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							trx_jenis 	= 21;
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				21,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );
		
		-- eksekusi insert PENERIMAAN BARANG REKANAN
		IF (vTransaksi_status != 2) THEN
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )

			select 		DATE_FORMAT(MAX(pb.TANGGAL_DIBUAT),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						0 as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						'-- non sub --' as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(pbd.JUMLAH), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pbd.ID and 
										( tsr.JENIS 			= 21 or
										  tsr.JENIS 			= 24 ) and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 21 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pbd.ID and 
										( tsr.JENIS 			= 21 or
										  tsr.JENIS 			= 24 ) and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	inventory.penerimaan_barang pb, 
						inventory.penerimaan_barang_detil pbd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	pb.ID                = pbd.PENERIMAAN and
						br.BARANG 	 		 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = pb.RUANGAN and
						br.BARANG   		 = pbd.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 21 AND
						pb.STATUS     	 	 = 2 and 
						pb.TANGGAL_DIBUAT	>= vTanggal and 
						pb.TANGGAL_DIBUAT	 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							br.BARANG;

			-- baca statistik PENERIMAAN BARANG REKANAN
			SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
				
			SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
						COALESCE(sum(jml_trxpersediaan),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from	rsfPelaporan.dlap_persediaan
				WHERE 	id_proses 				= vIDProses and
						trx_jenis 				= 21;

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 21;
		END IF;		
		*/

		-- proses 6 --
		-- proses insert data untuk :
		-- 6. PENJUALAN

		-- proses ulang PENJUALAN hanya jika statistiknya tidak sama
		-- baca statistik PENJUALAN
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 = aBulan and
					trx_jenis 	 	 = 30;
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	penjualan.penjualan
			where 	STATUS     		 = 2 and
					TANGGAL			>= vTanggal and 
					TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(pd.JUMLAH), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from 	penjualan.penjualan p, 
					penjualan.penjualan_detil pd,
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	p.NOMOR              = pd.PENJUALAN_ID and
					br.BARANG 	 		 = b.ID and
					b.KATEGORI 			 = k.ID and
					br.RUANGAN  		 = p.RUANGAN and
					br.BARANG   		 = pd.BARANG and
					r.id 				 = br.ruangan AND
					jts.ID				 = 30 AND
					p.STATUS     		 = 2 and
					p.TANGGAL			>= vTanggal and 
					p.TANGGAL			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(pd.JUMLAH), 0)
			into	vKasus1_rowsumber,
					vKasus1_trxsumber
			from 	penjualan.penjualan p, 
					penjualan.penjualan_detil pd,
					inventory.jenis_transaksi_stok jts
			where	p.NOMOR              = pd.PENJUALAN_ID and
					jts.ID				 = 30 AND
					p.STATUS     		 = 2 and
					p.TANGGAL			>= vTanggal and 
					p.TANGGAL			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		
		SET vKasus1_rowsumber = vKasus1_rowsumber - vTrxDetail_rowsumber;
		SET vKasus1_trxsumber = vKasus1_trxsumber - vTrxDetail_trxsumber;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 30;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							trx_jenis 	= 30;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							trx_jenis 	= 30;
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				30,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );
		
		-- eksekusi insert PENJUALAN
		IF (vTransaksi_status != 2) THEN
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(p.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						0 as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						'-- non sub --' as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(pd.JUMLAH), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pd.ID and 
										tsr.JENIS 				= 30 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 30 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= pd.ID and 
										tsr.JENIS 				= 30 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	penjualan.penjualan p, 
						penjualan.penjualan_detil pd,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	p.NOMOR              = pd.PENJUALAN_ID and
						br.BARANG 	 		 = b.ID and
						b.KATEGORI 			 = k.ID and
						br.RUANGAN  		 = p.RUANGAN and
						br.BARANG   		 = pd.BARANG and
						r.id 				 = br.ruangan AND
						jts.ID				 = 30 AND
						p.STATUS     		 = 2 and
						p.TANGGAL			>= vTanggal and 
						p.TANGGAL			 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							br.BARANG;

			-- baca statistik PENJUALAN
			SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
				
			SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
						COALESCE(sum(jml_trxpersediaan),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from	rsfPelaporan.dlap_persediaan
				WHERE 	id_proses 				= vIDProses and
						trx_jenis 				= 30;

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 30;
		END IF;		

		-- proses 7 --
		-- proses insert data untuk :
		-- 7. RETUR PENJUALAN

		-- proses ulang RETUR PENJUALAN hanya jika statistiknya tidak sama
		-- baca statistik RETUR PENJUALAN
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 = aBulan and
					trx_jenis 	 	 = 31;
		SELECT		count(1)
			into	vTrxHeader_rowsumber
			from 	penjualan.retur_penjualan
			where 	TANGGAL			>= vTanggal and 
					TANGGAL 	 	 < DATE_ADD(vTanggal, INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(rp.JUMLAH), 0)
			into	vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			from 	penjualan.penjualan p, 
					penjualan.penjualan_detil pd,
					penjualan.retur_penjualan rp,
					inventory.kategori k,
					inventory.barang b,
					inventory.barang_ruangan br,
					master.ruangan r,
					inventory.jenis_transaksi_stok jts
			where	p.NOMOR              	 = pd.PENJUALAN_ID and
					rp.PENJUALAN_ID      	 = p.NOMOR and
					rp.PENJUALAN_DETIL_ID 	 = pd.ID and
					br.BARANG 	 		 	 = b.ID and
					b.KATEGORI 			 	 = k.ID and
					br.RUANGAN  		 	 = p.RUANGAN and
					br.BARANG   		 	 = rp.BARANG and
					r.id 				 	 = br.ruangan AND
					jts.ID				 	 = 31 AND
					rp.TANGGAL				>= vTanggal and 
					rp.TANGGAL			 	 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		SELECT		count(1),
					COALESCE(sum(rp.JUMLAH), 0)
			into	vKasus1_rowsumber,
					vKasus1_trxsumber
			from 	penjualan.penjualan p, 
					penjualan.penjualan_detil pd,
					penjualan.retur_penjualan rp,
					inventory.jenis_transaksi_stok jts
			where	p.NOMOR              	 = pd.PENJUALAN_ID and
					rp.PENJUALAN_ID      	 = p.NOMOR and
					rp.PENJUALAN_DETIL_ID 	 = pd.ID and
					jts.ID				 	 = 31 AND
					rp.TANGGAL				>= vTanggal and 
					rp.TANGGAL			 	 < DATE_ADD(vTanggal , INTERVAL 1 MONTH);
		
		SET vKasus1_rowsumber = vKasus1_rowsumber - vTrxDetail_rowsumber;
		SET vKasus1_trxsumber = vKasus1_trxsumber - vTrxDetail_trxsumber;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 31;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							trx_jenis 	= 31;
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 		= aBulan and
							trx_jenis 	= 31;
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				31,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );
		
		-- eksekusi insert PENJUALAN
		IF (vTransaksi_status != 2) THEN
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			select 		DATE_FORMAT(MAX(rp.TANGGAL),'%Y%m') as bulan,
						MAX(br.RUANGAN) as depo_kode,
						MAX(jts.ID) as trx_jenis,
						0 as trx_jenis_sub,
						max(br.BARANG) as katalog_id,
						vIDProses as id_proses,
						max(r.deskripsi) as depo_nama,
						MAX(jts.DESKRIPSI) as trx_nama,
						MAX(jts.TAMBAH_ATAU_KURANG) as trx_tambahkurang,
						'-- non sub --' as trxsub_nama,
						max(b.KATEGORI) as kateg_kode,
						max(k.NAMA) as kateg_nama,
						COALESCE(max(b.kode_barang),'-') as katalog_kode,
						max(b.NAMA) as katalog_nama,				
						count(1) as jml_rowtrxpersediaan,
						COALESCE(sum(rp.JUMLAH), 0) as jml_trxpersediaan,
						SUM(COALESCE(
							( 
								select 	SUM(1) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= rp.ID and 
										tsr.JENIS 				= 31 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_rowtrxruangan,
						SUM(COALESCE(
							( 
								select 	SUM(tsr.jumlah * (CASE WHEN tsr.JENIS = 31 THEN 1 ELSE -1 END)) as jumlah
								from 	inventory.transaksi_stok_ruangan tsr,
										inventory.barang_ruangan br2
								where 	tsr.REF 				= rp.ID and 
										tsr.JENIS 				= 31 and
										tsr.BARANG_RUANGAN 		= br2.ID and
										br.ID                   = br2.ID
								group   by br2.BARANG
							), 0)) as jml_trxruangan
				from 	penjualan.penjualan p, 
						penjualan.penjualan_detil pd,
						penjualan.retur_penjualan rp,
						inventory.kategori k,
						inventory.barang b,
						inventory.barang_ruangan br,
						master.ruangan r,
						inventory.jenis_transaksi_stok jts
				where	p.NOMOR              	 = pd.PENJUALAN_ID and
						rp.PENJUALAN_ID      	 = p.NOMOR and
						rp.PENJUALAN_DETIL_ID 	 = pd.ID and
						br.BARANG 	 		 	 = b.ID and
						b.KATEGORI 			 	 = k.ID and
						br.RUANGAN  		 	 = p.RUANGAN and
						br.BARANG   		 	 = rp.BARANG and
						r.id 				 	 = br.ruangan AND
						jts.ID				 	 = 31 AND
						rp.TANGGAL				>= vTanggal and 
						rp.TANGGAL			 	 < DATE_ADD(vTanggal , INTERVAL 1 MONTH)
				GROUP	BY 	br.RUANGAN,
							br.BARANG
				ORDER 	BY 	br.RUANGAN,
							br.BARANG;

			-- baca statistik RETUR PENJUALAN
			SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
				
			SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
						COALESCE(sum(jml_trxpersediaan),0)
				into	vTrxDetail_rowdata,
						vTrxDetail_trxdata
				from	rsfPelaporan.dlap_persediaan
				WHERE 	id_proses 				= vIDProses and
						trx_jenis 				= 31;

			update 		rsfPelaporan.slap_persediaan_proses 
				set		prosesh_rowdata    		= vTrxHeader_rowdata,
						prosesd_rowdata    		= vTrxDetail_rowdata,
						prosesd_trxdata  		= vTrxDetail_trxdata
				where	id_proses 				= vIDProses and
						id_jenis				= 31;
		END IF;		

		-- proses 8 --
		-- proses insert data untuk :
		-- 8. PELAYANAN

		-- proses ulang PELAYANAN hanya jika statistiknya tidak sama
		-- baca statistik PELAYANAN
		SELECT 		count(1), max(id_proses) 
			into 	vTransaksi_status, vIDProsesTemp 
			from 	rsfPelaporan.dlap_persediaan 
			where 	bulan 			 		= aBulan and
					(	trx_jenis 			= 33 OR
						trx_jenis 			= 34 OR
						trx_jenis 			= 35 );
					
		SELECT		count(1),
					count(1),
					sum(transaksi_stok_ruangan.jumlah)
			into	vTrxHeader_rowsumber,
			        vTrxDetail_rowsumber,
					vTrxDetail_trxsumber
			FROM	inventory.transaksi_stok_ruangan,
					inventory.barang_ruangan,
					inventory.jenis_transaksi_stok,
					inventory.barang mbarang,
					inventory.kategori mkategori,
					master.ruangan
			WHERE	transaksi_stok_ruangan.barang_ruangan 	= barang_ruangan.id AND
					transaksi_stok_ruangan.jenis 			= jenis_transaksi_stok.id AND
					(	transaksi_stok_ruangan.jenis 		= 33 OR
						transaksi_stok_ruangan.jenis 		= 34 OR
						transaksi_stok_ruangan.jenis 		= 35 ) AND
					master.ruangan.id 						= inventory.barang_ruangan.ruangan AND
					mbarang.id 								= inventory.barang_ruangan.BARANG AND
					mkategori.ID 							= mbarang.KATEGORI AND
					transaksi_stok_ruangan.TANGGAL 		   >= vTanggal and 
					transaksi_stok_ruangan.TANGGAL 			< DATE_ADD(vTanggal, INTERVAL 1 MONTH);

		SET vKasus1_rowsumber = 0;
		SET vKasus1_trxsumber = 0;
		SET vKasus2_rowsumber = 0;
		SET vKasus2_trxsumber = 0;

		IF (vTransaksi_status > 0) THEN
			SET vTransaksi_status = 2;
						
			select 		COALESCE(max(prosesh_rowdata),0), 
						COALESCE(max(prosesd_rowdata),0), 
						COALESCE(max(prosesd_trxdata),0)
				into	vTrxHeader_rowdata, vTrxDetail_rowdata, vTrxDetail_trxdata
				from	slap_persediaan_proses
				where	id_proses 	= vIDProsesTemp and
						id_jenis	= 33;
			
			IF ((vTrxHeader_rowdata != vTrxHeader_rowsumber) or
				(vTrxDetail_rowdata != vTrxDetail_rowsumber) or
				(vTrxDetail_trxdata != vTrxDetail_trxsumber)) THEN
				SET vTransaksi_status = 3;
				INSERT INTO rsfPelaporan.dlap_persediaan_hist
				SELECT 		* 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 					= aBulan and
							(	trx_jenis 			= 33 OR
								trx_jenis 			= 34 OR
								trx_jenis 			= 35 );
				DELETE 
					FROM 	rsfPelaporan.dlap_persediaan 
					WHERE 	bulan 					= aBulan and
							(	trx_jenis 			= 33 OR
								trx_jenis 			= 34 OR
								trx_jenis 			= 35 );
			END IF;
		ELSE
			SET vTransaksi_status 	= 1;
			SET vTrxHeader_rowdata 	= 0;
			SET vTrxDetail_rowdata 	= 0;
			SET vTrxDetail_trxdata 	= 0;
		END IF;
		
		insert into rsfPelaporan.slap_persediaan_proses
				(	id_proses,				id_jenis,
					proses_status,			prosesh_rowsumber,		prosesh_rowdata,
					prosesd_rowsumber,		prosesd_rowdata,		prosesd_trxsumber,		prosesd_trxdata,	
					prosesd_kasus1row,		prosesd_kasus1trx,		prosesd_kasus2row,		prosesd_kasus2trx )
			values	
				(	vIDProses,				33,
					vTransaksi_status,		vTrxHeader_rowsumber,	vTrxHeader_rowdata,		
					vTrxDetail_rowsumber,	vTrxDetail_rowdata,		vTrxDetail_trxsumber,	vTrxDetail_trxdata,
					vKasus1_rowsumber,		vKasus1_trxsumber,		vKasus2_rowsumber,		vKasus2_trxsumber );
		
		-- eksekusi insert PELAYANAN
		IF (vTransaksi_status != 2) THEN
			INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
						depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
						kateg_kode, kateg_nama, katalog_kode, katalog_nama, 
						jml_rowtrxpersediaan, jml_trxpersediaan, jml_rowtrxruangan, jml_trxruangan )
			SELECT 		DATE_FORMAT(max(transaksi_stok_ruangan.TANGGAL),'%Y%m') as bulan,
						max(inventory.barang_ruangan.ruangan) as depo_kode,
						max(transaksi_stok_ruangan.jenis) as trx_jenis,
						0 as trx_jenis_sub,
						max(inventory.barang_ruangan.BARANG) as katalog_id,
						vIDProses,
						max(master.ruangan.deskripsi) as depo_nama,
						max(jenis_transaksi_stok.deskripsi) as trx_nama,
						max(jenis_transaksi_stok.tambah_atau_kurang) as trx_tambahkurang,
						'-- non sub --' as trxsub_nama,
						max(mbarang.KATEGORI) as kateg_kode,
						max(mkategori.NAMA) as kateg_nama,
						max(COALESCE(mbarang.kode_barang,'-')) as katalog_kode,
						max(mbarang.NAMA) as katalog_nama,
						count(1) as jml_rowtrxpersediaan,
						sum(transaksi_stok_ruangan.jumlah) as jml_trxpersediaan,
						count(1) as jml_rowtrxruangan,
						sum(transaksi_stok_ruangan.jumlah) as jml_trxruangan
				FROM	inventory.transaksi_stok_ruangan,
						inventory.barang_ruangan,
						inventory.jenis_transaksi_stok,
						inventory.barang mbarang,
						inventory.kategori mkategori,
						master.ruangan
				WHERE	transaksi_stok_ruangan.barang_ruangan 	= barang_ruangan.id AND
						transaksi_stok_ruangan.jenis 			= jenis_transaksi_stok.id AND
						(	transaksi_stok_ruangan.jenis 		= 33 OR
							transaksi_stok_ruangan.jenis 		= 34 OR
							transaksi_stok_ruangan.jenis 		= 35 ) AND
						master.ruangan.id 						= inventory.barang_ruangan.ruangan AND
						mbarang.id 								= inventory.barang_ruangan.BARANG AND
						mkategori.ID 							= mbarang.KATEGORI AND
						transaksi_stok_ruangan.TANGGAL 		   >= vTanggal and 
						transaksi_stok_ruangan.TANGGAL 			< DATE_ADD(vTanggal, INTERVAL 1 MONTH)
				GROUP	BY 	inventory.barang_ruangan.ruangan,
							transaksi_stok_ruangan.jenis,
							inventory.barang_ruangan.BARANG
				ORDER 	BY 	inventory.barang_ruangan.ruangan,
							transaksi_stok_ruangan.jenis,
							inventory.barang_ruangan.BARANG;

				-- baca statistik PELAYANAN
				SET vTrxHeader_rowdata = vTrxHeader_rowsumber;
					
				SELECT		COALESCE(sum(jml_rowtrxpersediaan),0),
							COALESCE(sum(jml_trxpersediaan),0)
					into	vTrxDetail_rowdata,
							vTrxDetail_trxdata
					from	rsfPelaporan.dlap_persediaan
					WHERE 	id_proses 				= vIDProses and
							(	trx_jenis 			= 33 OR
								trx_jenis 			= 34 OR
								trx_jenis 			= 35 );

				update 		rsfPelaporan.slap_persediaan_proses 
					set		prosesh_rowdata    		= vTrxHeader_rowdata,
							prosesd_rowdata    		= vTrxDetail_rowdata,
							prosesd_trxdata  		= vTrxDetail_trxdata
					where	id_proses 				= vIDProses and
							id_jenis				= 33;
		END IF;		
	COMMIT;
END //
DELIMITER ;
