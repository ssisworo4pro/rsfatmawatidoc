-- CREATE DEFINER=`rsflaporan`@`%` PROCEDURE `rsfBridging`.`orderlabTerimaUTD`(
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfBridging`.`orderlabTerimaUTD`(
-- CREATE PROCEDURE rsfBridging.orderlabTerimaUTD(
DROP PROCEDURE IF EXISTS rsfBridging.orderlabTerimaUTD;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `rsfBridging`.`orderlabTerimaUTD`(
	aOBJ VARCHAR(32) CHARSET utf8mb4,
	aKODE VARCHAR(35) CHARSET utf8mb4
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- rsfBridging.orderlabTerima 																				-- */
	/* -- description   : insert rsfMaster.tkatalog_ ....															-- */
	/* -- spesification : 																							-- */
	/* -- sysdateLast 	: 2023-08-07 08:30 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : Tambah Heeader								 											-- */
	/* -- trigger       : - OrderLabOnAfterUpdate								 								    -- */
	/* --------------------------------------------------------------------------------------------------------------- */
	/*
		select * from utd_bridging.registration r order by order_datetime desc;
		select * from utd_bridging.demographics d;
		select * from utd_bridging.ordered_item oi order by order_item_datetime desc;
		select STATUS, ol.* from layanan.order_lab ol where TUJUAN = '101130101' and TANGGAL > CURRENT_DATE()
		order by STATUS;
		insert into utd_bridging.master_jenisreaksi (
			id_reksi, nama_reaksi, gejala, tanda, sysdate_in, sysdate_last )
		values
			(0, 'Belum Input', '', '', current_timestamp, current_timestamp),
			(1, 'Tidak Ada Reaksi', '', '', current_timestamp, current_timestamp),
			(2, 'Kategori I', 'Gatal', 'Reaksi pada kulit yang terlokalisasi : Urtikaria (Bercak Merah / Rush)', 
				current_timestamp, current_timestamp),
			(3, 'Kategori II', '- Cemas \n- Gatal \n- Palpitasi \n- Sesak napas ringan \n- Sakit Kepala', 
				'- Flushing (kulit menjadi merah) \n- Urtikaria \n- kaku/Rigor \n- Demam \n- Gelisah \n- Takikardi',
				current_timestamp, current_timestamp),
			(4, 'Kategori III', '- Gatal \n- Nyeri data \n- Nyeri di daerah pemasangan jarum transfusi \n- Gangguan pernapasan \n- Nyeri punggung atau nyeri daerah pangkal paha \n- Sakit kepala \n- Sesak', 
				'- Kaku/Rigor \n- Gelisah \n- Hipertensi (tekanan darah sistolik turun > 20%) \n- Takikardi (Frekuensi denyut jantung meningkat > 20%) \n- Hemoglobinuri (air seni berwarna merah) \n- Pendarahan yang tidak diketahui alasannya (DIC)',
				current_timestamp, current_timestamp),
			(9, 'Tidak digunakan', '', '', current_timestamp, current_timestamp);
	
		select * from utd_bridging.master_jenisreaksi;
		truncate table utd_bridging.master_jenisreaksi;
		
		cek data
			SELECT 		pasien_asal.NORM as PATIENT_ID, 
						pasien_asal.NAMA as PATIENT_NAME, 
						ol.TANGGAL as ORDER_DATE, 
						ol.NOMOR as ORDER_NOMOR, 
						ol.KUNJUNGAN as KUNJUNGAN_NOMOR, 
						kunj_tujuan.NOMOR as KUNJUNGAN_NOMOR_TJN,
						kunj_tujuan.STATUS as KUNJUNGAN_STATUS,
						ol.KUNJUNGAN UPDATEKU
				FROM 	layanan.order_lab ol 
						LEFT JOIN pendaftaran.kunjungan kunj_tujuan ON ol.NOMOR = kunj_tujuan.REF
						LEFT JOIN pendaftaran.kunjungan kunj_asal ON kunj_asal.NOMOR = ol.KUNJUNGAN 
						LEFT JOIN pendaftaran.pendaftaran pend_asal ON pend_asal.NOMOR = kunj_asal.NOPEN 
						LEFT JOIN `master`.pasien pasien_asal ON pasien_asal.NORM = pend_asal.NORM
						LEFT JOIN layanan.tindakan_medis tm ON tm.KUNJUNGAN = kunj_tujuan.NOMOR
				WHERE 	ol.TUJUAN = '101130101'
						AND ol.TANGGAL >= curdate() - 3
						AND ol.STATUS != 2;
	----------------------------------------------------------------------------------------------------------------- */
	DECLARE vIDInsert BIGINT;
	DECLARE vMessage VARCHAR(255);
	DECLARE vErrorCode INTEGER;
	DECLARE vErrorCodeLast INTEGER;
	DECLARE vCounted INTEGER;
	DECLARE vPatienID VARCHAR(50);
	-- START TRANSACTION;
		INSERT INTO utd_bridging.registration
					(	
						patient_id, visit_number, order_number, order_datetime, diagnose_id, 
						diagnose_name, cito, service_unit_id, service_unit_name, guarantor_id, guarantor_name, agreement_id, agreement_name, 
						doctor_id, doctor_name, class_id, class_name, ward_id, ward_name, room_id, room_name, bed_id, bed_name, reg_user_id, reg_user_name, 
						lis_reg_no, retrieved_dt, retrieved_flag
					)
		SELECT 		pasien_asal.NORM as Patient_ID
					,pend_asal.NOMOR as Visit_Number
					,ol.nomor as Order_Number
					,date(ol.TANGGAL) as Order_DateTime
					,1 as Diagnose_ID
					,ifnull(ol.alasan,'') as Diagnose_Name
					,ol.CITO as cito
					,ruang_tujuan.ID as Service_Unit_ID
					,ruang_tujuan.DESKRIPSI as Service_Unit_Name
					,mr2.ID as Guarantor_ID
					,mr2.DESKRIPSI as Guarantor_Name
					,mr3.ID as Agreement_ID
					,mr3.DESKRIPSI as Agreement_Name
					,mstrd.ID as Doctor_ID
					,mstrpgw.NAMA as Doctor_Name
					,mr3.ID as Class_ID
					,mr3.DESKRIPSI as Class_Name
					,ruang_asal.ID as Ward_ID
					,ruang_asal.DESKRIPSI as Ward_Name
					,ifnull(mstrkmr.ID, 0) as Room_ID
					,ifnull(mstrkmr.KAMAR,'-') as Room_Name
					,ifnull(mstrkmrtdr.ID, 0) as Bed_ID
					,ifnull(mstrkmrtdr.TEMPAT_TIDUR, '-') as Bed_Name
					,kunj_tujuan.DITERIMA_OLEH as Reg_User_ID
					,app.NAMA as Reg_User_Name 
					,'' as lis_reg_no, null as retrieved_dt, '' as retrieved_flag
			FROM 	layanan.order_lab ol 
					LEFT JOIN pendaftaran.kunjungan kunj_tujuan ON ol.NOMOR = kunj_tujuan.REF
					LEFT JOIN pendaftaran.kunjungan kunj_asal ON kunj_asal.NOMOR = ol.KUNJUNGAN 
					LEFT JOIN pendaftaran.pendaftaran pend_asal ON pend_asal.NOMOR = kunj_asal.NOPEN 
					LEFT JOIN `master`.pasien pasien_asal ON pasien_asal.NORM = pend_asal.NORM
					LEFT JOIN `master`.ruangan ruang_asal ON ruang_asal.ID = kunj_asal.RUANGAN 
					LEFT JOIN `master`.ruangan ruang_tujuan ON ruang_tujuan.ID = ol.TUJUAN 
					LEFT JOIN pendaftaran.penjamin ppnjmn ON ppnjmn.NOPEN = pend_asal.NOMOR 
					LEFT JOIN `master`.referensi mr2 ON ppnjmn.JENIS = mr2.ID AND mr2.JENIS = 10 
					LEFT JOIN `master`.referensi mr3 ON ppnjmn.JENIS = mr3.ID AND mr3.JENIS = 19 
					LEFT JOIN `master`.dokter mstrd ON mstrd.ID = ol.DOKTER_ASAL
					LEFT JOIN `master`.pegawai mstrpgw ON mstrpgw.NIP = mstrd.NIP 
					LEFT JOIN `master`.ruang_kamar_tidur mstrkmrtdr ON mstrkmrtdr.ID = kunj_asal.RUANG_KAMAR_TIDUR 
					LEFT JOIN `master`.ruang_kamar mstrkmr ON mstrkmr.ID = mstrkmrtdr.RUANG_KAMAR 
					LEFT JOIN aplikasi.pengguna app ON app.ID = kunj_tujuan.DITERIMA_OLEH 
			WHERE 	ol.NOMOR = aKODE;
			
		INSERT INTO utd_bridging.ordered_item (order_number, order_item_id, order_item_name, qty, order_item_datetime)
		SELECT 		max(ol.nomor) as order_number
					,max(odl.TINDAKAN) as order_item_id
					,max(t.NAMA) as order_item_name
					,sum(1) as qty
					,max(date(ol.TANGGAL)) as order_item_datetime
			FROM 	layanan.order_lab ol
					LEFT JOIN layanan.order_detil_lab odl on odl.ORDER_ID = ol.NOMOR
					LEFT JOIN `master`.tindakan t ON t.ID = odl.TINDAKAN 
			WHERE 	ol.NOMOR = aKODE
			GROUP   BY ol.NOMOR, odl.TINDAKAN;
			
		/*
		SELECT 		max(ol.nomor) as order_number
					,max(ltm.TINDAKAN) as order_item_id
					,max(t.NAMA) as order_item_name
					,sum(1) as qty
					,max(date(ol.TANGGAL)) as order_item_datetime
			FROM 	layanan.order_lab ol 
					LEFT JOIN pendaftaran.kunjungan kunj_tujuan ON ol.NOMOR = kunj_tujuan.REF
					LEFT JOIN pendaftaran.kunjungan kunj_asal ON kunj_asal.NOMOR = ol.KUNJUNGAN 
					LEFT JOIN pendaftaran.pendaftaran pend_asal ON pend_asal.NOMOR = kunj_asal.NOPEN 
					LEFT JOIN `master`.pasien pasien_asal ON pasien_asal.NORM = pend_asal.NORM
					LEFT JOIN layanan.tindakan_medis ltm ON ltm.KUNJUNGAN = kunj_tujuan.NOMOR
					LEFT JOIN `master`.tindakan t ON t.ID = ltm.TINDAKAN
					LEFT JOIN `master`.ruangan ruang_asal ON ruang_asal.ID = kunj_asal.RUANGAN 
					LEFT JOIN `master`.ruangan ruang_tujuan ON ruang_tujuan.ID = ol.TUJUAN 
					LEFT JOIN pendaftaran.penjamin ppnjmn ON ppnjmn.NOPEN = pend_asal.NOMOR 
					LEFT JOIN `master`.referensi mr2 ON ppnjmn.JENIS = mr2.ID AND mr2.JENIS = 10 
					LEFT JOIN `master`.referensi mr3 ON ppnjmn.JENIS = mr3.ID AND mr3.JENIS = 19 
					LEFT JOIN `master`.dokter mstrd ON mstrd.ID = ol.DOKTER_ASAL
					LEFT JOIN `master`.pegawai mstrpgw ON mstrpgw.NIP = mstrd.NIP 
					LEFT JOIN `master`.ruang_kamar_tidur mstrkmrtdr ON mstrkmrtdr.ID = kunj_asal.RUANG_KAMAR_TIDUR 
					LEFT JOIN `master`.ruang_kamar mstrkmr ON mstrkmr.ID = mstrkmrtdr.RUANG_KAMAR 
					LEFT JOIN aplikasi.pengguna app ON app.ID = kunj_tujuan.DITERIMA_OLEH 
			WHERE 	ol.NOMOR = aKODE
			GROUP   BY ol.NOMOR, ltm.TINDAKAN;
		*/
		
		SELECT		pasien_asal.NORM into vPatienID
			FROM 	layanan.order_lab ol 
					LEFT JOIN pendaftaran.kunjungan kunj_tujuan ON ol.NOMOR = kunj_tujuan.REF
					LEFT JOIN pendaftaran.kunjungan kunj_asal ON kunj_asal.NOMOR = ol.KUNJUNGAN 
					LEFT JOIN pendaftaran.pendaftaran pend_asal ON pend_asal.NOMOR = kunj_asal.NOPEN 
					LEFT JOIN `master`.pasien pasien_asal ON pasien_asal.NORM = pend_asal.NORM
					LEFT JOIN `master`.ruangan ruang_asal ON ruang_asal.ID = kunj_asal.RUANGAN 
					LEFT JOIN `master`.ruangan ruang_tujuan ON ruang_tujuan.ID = ol.TUJUAN 
					LEFT JOIN pendaftaran.penjamin ppnjmn ON ppnjmn.NOPEN = pend_asal.NOMOR 
					LEFT JOIN `master`.referensi mr2 ON ppnjmn.JENIS = mr2.ID AND mr2.JENIS = 10 
					LEFT JOIN `master`.referensi mr3 ON ppnjmn.JENIS = mr3.ID AND mr3.JENIS = 19 
					LEFT JOIN `master`.dokter mstrd ON mstrd.ID = ol.DOKTER_ASAL
					LEFT JOIN `master`.pegawai mstrpgw ON mstrpgw.NIP = mstrd.NIP 
					LEFT JOIN `master`.ruang_kamar_tidur mstrkmrtdr ON mstrkmrtdr.ID = kunj_asal.RUANG_KAMAR_TIDUR 
					LEFT JOIN `master`.ruang_kamar mstrkmr ON mstrkmr.ID = mstrkmrtdr.RUANG_KAMAR 
					LEFT JOIN aplikasi.pengguna app ON app.ID = kunj_tujuan.DITERIMA_OLEH 
					left join master.wilayah wil on left(pasien_asal.WILAYAH,2) = wil.ID
					left join master.kontak_pasien kthp on pasien_asal.NORM = kthp.NORM and kthp.JENIS = '3'
					left join master.kontak_pasien kttp on pasien_asal.NORM = kttp.NORM and kttp .JENIS = '1'
			WHERE 	ol.NOMOR = aKODE;
		
		SELECT		count(1)
			INTO	vCounted
			FROM	utd_bridging.demographics
			WHERE	patient_id = vPatienID;
			
		IF (vCounted = 0) THEN
			INSERT INTO utd_bridging.demographics (patient_id, gender_id, gender_name, date_of_birth, patient_name, patient_address, city_id, 
						city_name, phone_number, fax_number, mobile_number, email)
			SELECT		pasien_asal.NORM as patient_id,
						if(pasien_asal.JENIS_KELAMIN = '1', 'L','P') as gender_id,
						if(pasien_asal.JENIS_KELAMIN = '1', 'Laki-laki','Perempuan') as gender_name,
						DATE_FORMAT(pasien_asal.TANGGAL_LAHIR,'%Y-%m-%d') as date_of_birth,
						pasien_asal.NAMA as patient_name,
						ifnull(pasien_asal.ALAMAT,'') as patient_address,
						wil.ID as city_id,
						wil.DESKRIPSI as city_name,
						kthp.NOMOR as phone_number,
						'' as fax_number,
						kttp.NOMOR as mobile_number,
						'' as email
				FROM 	layanan.order_lab ol 
						LEFT JOIN pendaftaran.kunjungan kunj_tujuan ON ol.NOMOR = kunj_tujuan.REF
						LEFT JOIN pendaftaran.kunjungan kunj_asal ON kunj_asal.NOMOR = ol.KUNJUNGAN 
						LEFT JOIN pendaftaran.pendaftaran pend_asal ON pend_asal.NOMOR = kunj_asal.NOPEN 
						LEFT JOIN `master`.pasien pasien_asal ON pasien_asal.NORM = pend_asal.NORM
						LEFT JOIN `master`.ruangan ruang_asal ON ruang_asal.ID = kunj_asal.RUANGAN 
						LEFT JOIN `master`.ruangan ruang_tujuan ON ruang_tujuan.ID = ol.TUJUAN 
						LEFT JOIN pendaftaran.penjamin ppnjmn ON ppnjmn.NOPEN = pend_asal.NOMOR 
						LEFT JOIN `master`.referensi mr2 ON ppnjmn.JENIS = mr2.ID AND mr2.JENIS = 10 
						LEFT JOIN `master`.referensi mr3 ON ppnjmn.JENIS = mr3.ID AND mr3.JENIS = 19 
						LEFT JOIN `master`.dokter mstrd ON mstrd.ID = ol.DOKTER_ASAL
						LEFT JOIN `master`.pegawai mstrpgw ON mstrpgw.NIP = mstrd.NIP 
						LEFT JOIN `master`.ruang_kamar_tidur mstrkmrtdr ON mstrkmrtdr.ID = kunj_asal.RUANG_KAMAR_TIDUR 
						LEFT JOIN `master`.ruang_kamar mstrkmr ON mstrkmr.ID = mstrkmrtdr.RUANG_KAMAR 
						LEFT JOIN aplikasi.pengguna app ON app.ID = kunj_tujuan.DITERIMA_OLEH 
						left join master.wilayah wil on left(pasien_asal.WILAYAH,2) = wil.ID
						left join master.kontak_pasien kthp on pasien_asal.NORM = kthp.NORM and kthp.JENIS = '3'
						left join master.kontak_pasien kttp on pasien_asal.NORM = kttp.NORM and kttp .JENIS = '1'
				WHERE 	ol.NOMOR = aKODE;
		END IF;
	-- COMMIT;
END //
DELIMITER ;
