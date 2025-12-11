Kasus2
-------------------------------
StokOpName 
 1. Transaksi StokOpName dengan stok_opname_detil.MANUAL = null
    select * from dlap_persediaan_sodtl where jml_katalog = 99999;
	apakah dianggap jadi nol ?
 2. Transaksi StokOpName tidak sama dengan transaksi_stok_ruangan
    select * from dlap_persediaan_sodtl where id_transaksi is null;
    select * from dlap_persediaan_sodtl where jml_katalog <> jml_trx;
 3. Transaksi StokOpName vs transaksi_stok_ruangan Ambigue
	select '11', tsr.* from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 11 and tsr.BARANG_RUANGAN = 18686
	UNION ALL
	select '15', tsr.* from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 15 and tsr.BARANG_RUANGAN = 18686;
	-- vs --
	select tsr.*, tsr.JUMLAH, tsr.ID, tsr.BARANG_RUANGAN, br.BARANG 
	from inventory.transaksi_stok_ruangan tsr, inventory.barang_ruangan br 
	where REF = 3 and tsr.BARANG_RUANGAN = br.id and br.BARANG = 27;

	-- Akhir2 menggunakan jumlah, padahal di awal menggunakan flag
	select * 
	from (
		select '11', tsr.* from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 11 -- and tsr.BARANG_RUANGAN = 18686
		UNION ALL
		select '15', tsr.* from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 15 -- and tsr.BARANG_RUANGAN = 18686;
	) sq
	order by sq.BARANG_RUANGAN, JENIS

KoreksiStok
 1. Data koreksi terduplikasi
		select 	tsr.*
		from 	inventory.transaksi_stok_ruangan tsr,
				inventory.barang_ruangan br
		where 	tsr.REF = 3810 and (tsr.JENIS = 53 or tsr.JENIS = 54) and
				tsr.BARANG_RUANGAN = br.ID 
		-- vs --
		select	*
		from	inventory.transaksi_koreksi_detil
		where	id = 3810;





11	Stok Opname Balance
15	Batal Final Stok Opname

20	Penerimaan Barang dari Ruangan
21	Penerimaan Barang dari Rekanan
23	Pengiriman Barang ke Ruangan
24	Pembatalan Final Penerimaan Barang dari Rekanan
30	Penjualan
33	Pelayanan
34	Retur Pelayanan
35	Pembatalan Pelayanan
54	Transaksi Keluar

11	Stok Opname Balance
15	Batal Final Stok Opname
20	Penerimaan Barang dari Ruangan
21	Penerimaan Barang dari Rekanan
23	Pengiriman Barang ke Ruangan
24	Pembatalan Final Penerimaan Barang dari Rekanan
30	Penjualan
33	Pelayanan
34	Retur Pelayanan
35	Pembatalan Pelayanan
54	Transaksi Keluar

11	Stok Opname Balance
15	Batal Final Stok Opname
20	Penerimaan Barang dari Ruangan
23	Pengiriman Barang ke Ruangan
21	Penerimaan Barang dari Rekanan
24	Pembatalan Final Penerimaan Barang dari Rekanan
-------------------------------------------------------------
30	Penjualan
31	Retur Penjualan
33	Pelayanan
34	Retur Pelayanan
35	Pembatalan Pelayanan
-------------------------------------------------------------
51	Barang Produksi
52	Pemakaian Barang Produksi
53	Transaksi Masuk
54	Transaksi Keluar



kasus stok luar biasa :
-------------------------------------------------------
20220624165438.00
202206	101030109	11	90L022	Depo Teratai	Stok Opname Balance		10202	Pembalut	LEUKOMED IV 6X8 CM  (72389-00)	2	20220624165438.00
select * from inventory.transaksi_stok_ruangan tsr, inventory.barang_ruangan br, inventory.barang b 
where tsr.BARANG_RUANGAN = br.ID and br.BARANG = b.ID and b.KODE_BARANG = '90L022' and tsr.JENIS = 11;
select * from inventory.transaksi_stok_ruangan tsr where STOK = 20220624165438.00;
update inventory.transaksi_stok_ruangan set JUMLAH = 20 WHERE JUMLAH = 20220624165438.00;

202206	101030109	54	90L022	Depo Teratai	Transaksi Keluar	-	10202	Pembalut	LEUKOMED IV 6X8 CM  (72389-00)	1	20220624165429.00
select * from inventory.transaksi_stok_ruangan tsr where JUMLAH = 20220624165429.00;  -- ID : 00011015220625105300001
update inventory.transaksi_stok_ruangan set JUMLAH = 20 WHERE JUMLAH = 20220624165438.00;


-- transaksi stop opname.... header
select 		so.id as id_opname,
			so.tanggal_dibuat as tanggal,
			r.ID as depo_kode,
			r.DESKRIPSI as depo_nama,
			so.kategori as kategori,
			so.status as status,
			11 as trx_jenis,
			'Stok Opname Balance' as trx_nama,
			'0' as trx_tambahkurang
	from	master.ruangan r
			left outer join master.ruangan_farmasi rf
			on r.ID = rf.FARMASI,
			inventory.stok_opname so
	where	so.RUANGAN = r.ID and
			so.id = 1;
			
-- stok opname rinci
select		sod.id as id_opname_dtl,
			so.ID as id_opname,
			tsr.ID as id_transaksi,
			br.BARANG as katalog_id,
			b.kode_barang as katalog_kode,
			b.nama as katalog_nama,
			k.id as kateg_kode,
			k.nama as kateg_nama,
			sod.MANUAL as jml_katalog,
			tsr.jumlah as jml_trx
	from	inventory.stok_opname_detil sod,
			inventory.stok_opname so,
			inventory.barang_ruangan br 
			left outer join
            	( select * from inventory.transaksi_stok_ruangan where REF = 1 and JENIS = 15) tsr
            	on br.id = tsr.BARANG_RUANGAN,
            inventory.barang b,
            inventory.kategori k,
            master.ruangan r
      where	so.id = sod.STOK_OPNAME and
			sod.BARANG_RUANGAN = br.ID and
			br.BARANG =  b.id and
			b.KATEGORI = k.id and
			so.id = 1 and
			so.RUANGAN = r.id
	order   by tsr.ID




proses stok opname
-----------------------------------------
11	Stok Opname Balance
15	Batal Final Stok Opname

proses jenis
-------------------------------------------------------
21	Penerimaan Barang dari Rekanan
24	Pembatalan Final Penerimaan Barang dari Rekanan
30	Penjualan
33	Pelayanan
34	Retur Pelayanan
35	Pembatalan Pelayanan
42	Penerimaan Barang Residu
51	Barang Produksi
52	Pemakaian Barang Produksi
59	Distribusi Barang

proses jenis sub alasan
-------------------------------------------------------
53	Transaksi Masuk
54	Transaksi Keluar

proses jenis sub ruang farmasi / non farmasi
-------------------------------------------------------
20	Penerimaan Barang dari Ruangan
23	Pengiriman Barang ke Ruangan

CALL rsfPelaporan.proc_lap_persediaan("202206");

	select count(1) from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60;
-- 10313
	select count(1) from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 11;
	select count(1) from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 15;
	select distinct tsr.JENIS from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60;
-- 6872
-- 3436
11
15
20
52
23
51
53

-- deteksi barang yang dikoreksi
select 		tsr.BARANG_RUANGAN
	from 	inventory.transaksi_stok_ruangan tsr,
			(
				select 		tsrB.BARANG_RUANGAN, tsrB.JUMLAH
					from 	inventory.transaksi_stok_ruangan tsrB
					where 	tsrB.REF = 60 and 
							tsrB.JENIS = 15
			) tsr2
	where 	tsr.REF = 60 and 
			tsr.JENIS = 11 and
			tsr2.BARANG_RUANGAN = tsr.BARANG_RUANGAN and
			tsr2.JUMLAH != tsr.JUMLAH ;

select '11', tsr.* from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 11 and tsr.BARANG_RUANGAN = 18686
UNION ALL
select '15', tsr.* from inventory.transaksi_stok_ruangan tsr where tsr.REF = 60 and tsr.JENIS = 15 and tsr.BARANG_RUANGAN = 18686;

--- barang keluar masuk
	INSERT INTO rsfPelaporan.dlap_persediaan ( bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses,
				depo_nama, trx_nama, trx_tambahkurang, trxsub_nama,
				kateg_kode, kateg_nama, katalog_kode, katalog_nama, jml_transaksi, jml_katalog )
	SELECT 		DATE_FORMAT(max(transaksi_stok_ruangan.TANGGAL),'%Y%m') as bulan,
				max(inventory.barang_ruangan.ruangan) as depo_kode,
				max(transaksi_stok_ruangan.jenis) as trx_jenis,
				max(case when rf2.FARMASI is null then 2
					else 1
				end) as trx_jenis_sub,
				max(inventory.barang_ruangan.BARANG) as katalog_id,
				vIDProses,
				max(master.ruangan.deskripsi) as depo_nama,
				max(jenis_transaksi_stok.deskripsi) as trx_nama,
				max(jenis_transaksi_stok.tambah_atau_kurang) as trx_tambahkurang,
				max(case when rf2.FARMASI is null then 'ruang non farmasi'
					else 'ruang farmasi'
				end) as trxsub_nama,
				max(mbarang.KATEGORI) as kateg_kode,
				max(mkategori.NAMA) as kateg_nama,
				max(COALESCE(mbarang.kode_barang,'-')) as katalog_kode,
				max(mbarang.NAMA) as katalog_nama,
				count(1) as jml_transaksi,
				sum(transaksi_stok_ruangan.jumlah) as jml_katalog

select 		tk.TANGGAL,
			tkd.JUMLAH,
			COALESCE(tkd.JUMLAH, 0) as jml_katalog,
			COALESCE(
				( select 	(tsr.jumlah * (CASE WHEN tsr.JENIS = 53 THEN 1 ELSE -1 END)) as jumlah
					from 	inventory.transaksi_stok_ruangan tsr,
							inventory.barang_ruangan br
					where 	tsr.REF = tkd.ID and (tsr.JENIS = 53 or tsr.JENIS = 54) and
							tsr.BARANG_RUANGAN = br.ID and
							tkd.BARANG = tsr.BARANG
				), 0) as jml_trx,
			on tkd.BARANG = tsrx.BARANG,
			tk.*,
			tkd.*,
			case when tk.JENIS = 2 then 'Barang Keluar'
			else 'Barang Masuk' end as trx_nama,
			b.NAMA,
			b.KODE_BARANG,
			k.ID,
			k.NAMA,
			k.JENIS 
	from 	inventory.transaksi_koreksi tk, 
			inventory.transaksi_koreksi_detil tkd,
			inventory.barang b,
			inventory.kategori k
	where	tk.id 		= tkd.KOREKSI and
			tkd.BARANG 	= b.ID and
			b.KATEGORI 	= k.ID and
			tk.id 		= 575;


sapto sisworo is inviting you to a scheduled Zoom meeting.

Topic: sapto sisworo's Personal Meeting Room

Join Zoom Meeting
https://us05web.zoom.us/j/2011997862?pwd=U2R5Wlc0RTI1UjFRcVpsWlRaYVRBZz09

Meeting ID: 201 199 7862
Passcode: eHM3Y0


