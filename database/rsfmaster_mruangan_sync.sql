DROP PROCEDURE IF EXISTS rsfMaster.mruangan_sync;
DELIMITER //
CREATE PROCEDURE rsfMaster.mruangan_sync(
	aOBJ VARCHAR(32),
	aINVinsert integer
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- mruangan_sync 																							-- */
	/* -- description   : insert rsfMaster.mruangan_ ....															-- */
	/* -- spesification : 																							-- */
	/* -- sysdateLast 	: 2022-12-28 19:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	START TRANSACTION;
		IF (aOBJ = "farmasi") THEN
			-- insert to rsfMaster
			insert		into rsfMaster.mruangan_farmasi
						(	kd_inventory, id_teamterima, nm_ruangan )
			select 		r.ID, NULL, r.DESKRIPSI
				from 	master.ruangan r
						left outer join
						(	select		kd_inventory
								from	rsfMaster.mruangan_farmasi ) subquery
						on r.ID = subquery.kd_inventory
				where 	substr(r.id,1,6) 		= '101030' and
						r.JENIS 				= 5 and
						subquery.kd_inventory 	is null;

			-- update id from inventory
			-- 23	DEPO001	Apotik Askes(irj lt1)			101030101
			-- 25	DEPO002	Depo Griya Husada				101030103
			-- 26	DEPO003	Depo IBS						101030108
			-- 27	DEPO004	Depo IGD						101030104
			-- 28	DEPO005	Depo Produksi					101030110
			-- 30	DEPO007	Depo Teratai					101030109
			-- 59	eqys8120	Gudang Induk Farmasi		101030111
			-- 60	GDG018	Gudang Gas Medis				101030115
			-- 61	DEPO009	Depo Rawat Jalan Lt. 3			101030112
			-- 64	DEPO014	Depo Rawat Jalan Lt. 2			101030102
			-- 65	Depo015	Depo OK Cito					101030105
			-- 129	DEPO019	Depo Bougenvil					101030107
			-- 329	DEPO020	Depo Anggrek					101030106
			update rsfMaster.mruangan_farmasi set id_teamterima =  23 where kd_inventory = '101030101' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  25 where kd_inventory = '101030103' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  26 where kd_inventory = '101030108' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  27 where kd_inventory = '101030104' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  28 where kd_inventory = '101030110' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  30 where kd_inventory = '101030109' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  59 where kd_inventory = '101030111' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  60 where kd_inventory = '101030115' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  61 where kd_inventory = '101030112' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  64 where kd_inventory = '101030102' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima =  65 where kd_inventory = '101030105' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima = 129 where kd_inventory = '101030107' and id_teamterima is null;
			update rsfMaster.mruangan_farmasi set id_teamterima = 329 where kd_inventory = '101030106' and id_teamterima is null;
				
			-- insert to inventory & update id lagi
			/*
			IF (aINVinsert = 1) THEN
				insert into inventory.satuan ( NAMA, DESKRIPSI, TANGGAL, OLEH, STATUS )
				select 		kemasan.kode, kemasan.nama_kemasan, current_timestamp, 0, 1
					from 	rsfMaster.mruangan_kemasan kemasan
					where	kemasan.id_inventory is null;
				UPDATE 		rsfMaster.mruangan_kemasan kemasan, inventory.satuan satuan
					SET		kemasan.id_inventory = satuan.id
					WHERE   kemasan.kode = satuan.nama and
							kemasan.id_inventory is null;
			END IF;
			*/

			-- result
			SELECT 		0 as statcode,
						count(1) as rowcount,
						concat('rsfMaster ruangan farmasi, insert complete. now ', count(1) ,' row counted. ') as statmessage,
						'success' as data
				FROM	rsfMaster.mruangan_farmasi;
		-- ELSEIF (aOBJ = "pbf") THEN
		ELSE
			SELECT 		20001 as statcode,
						0 as rowcount,
						concat('rsfMaster ruangan, object ''', aOBJ,''' tidak ditemukan.') as statmessage,
						'' as data;
		END IF;
	COMMIT;
END //
DELIMITER ;
