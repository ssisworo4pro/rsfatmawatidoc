-- untuk mendaptkan data yang akan dikirim
call rsfInterconn.satusehat_datakirim();

-- untuk memanggil organization dan query lihat, reset hasil respon
call rsfInterconn.satusehat_json_get('organization','1');
call rsfInterconn.satusehat_json_set('organization','1','{"id":"3308ed0c-2a71-4b2a-952f-d75dc6d20064","test":true}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_morganization where id = 1;
update rsfInterconn.satusehat_morganization set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

-- untuk memanggil location dan query lihat, reset hasil respon
call rsfInterconn.satusehat_json_get('location','1');
call rsfInterconn.satusehat_json_set('location','1','{"id":"3308ed0c-2a71-4b2a-952f-d75dc6d20064","test":true}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mlocation where id = 1;
update rsfInterconn.satusehat_mlocation set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

-- untuk memanggil practitioner dan query lihat, reset hasil respon
call rsfInterconn.satusehat_json_get('practitioner','1');
call rsfInterconn.satusehat_json_set('practitioner','1','{"resourceType": "Bundle","total": 0,"type": "searchset"}');
call rsfInterconn.satusehat_json_set('practitioner','1','{"entry": [{"resource": {"birthDate": "1990-07-21","id": "10000329187"}}],"total": 1,"type": "searchset"}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mpractitioner where id = 1;
update rsfInterconn.satusehat_mpractitioner set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

-- untuk memanggil Patient dan query lihat, reset hasil respon
call rsfInterconn.satusehat_json_get('Patient','1');
call rsfInterconn.satusehat_json_set('Patient','1','{"resourceType": "Bundle","total": 0,"type": "searchset"}');
call rsfInterconn.satusehat_json_set('Patient','1','{"entry": [{"resource": {"birthDate": "1990-07-21","id": "10000329187"}}],"total": 1,"type": "searchset"}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mpatient where id = 1;
update rsfInterconn.satusehat_mpatient set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

-- untuk memanggil Patient dan query lihat, reset hasil respon
call rsfInterconn.satusehat_json_get('Encounter','1');
call rsfInterconn.satusehat_json_set('Encounter','1','{"resourceType": "Bundle","total": 0,"type": "searchset"}');
call rsfInterconn.satusehat_json_set('Encounter','1','{"entry": [{"resource": {"birthDate": "1990-07-21","id": "10000329187"}}],"total": 1,"type": "searchset"}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_tencounter where id = 1;
update rsfInterconn.satusehat_tencounter set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

-- untuk memanggil Patient dan query lihat, reset hasil respon
call rsfInterconn.satusehat_json_get('Condition','1');
call rsfInterconn.satusehat_json_set('Condition','1','{"resourceType": "Bundle","total": 0,"type": "searchset"}');
call rsfInterconn.satusehat_json_set('Condition','1','{"resource": {"birthDate": "1990-07-21","id": "10000329187"},"total": 1,"type": "searchset"}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_condition where id = 1;
update rsfInterconn.satusehat_condition set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

============================================================== Condition ==============================================================

insert		into satusehat_condition (id_encounter, icd10_kode, icd10_keterangan, icd10_utama, icd10_tanggal,
			sysdate_in, sysdate_last, response_stat )
select 		ssencounter.id, diag.KODE, micd.STR, diag.UTAMA, diag.TANGGAL,
			CURRENT_TIMESTAMP() as sysdate_in,
			CURRENT_TIMESTAMP() as sysdate_last,
			0 as response_stat
	from 	medicalrecord.diagnosa diag,
			pendaftaran.kunjungan kunj,
			master.mrconso micd,
			rsfInterconn.satusehat_tencounter ssencounter
	where 	diag.NOPEN = kunj.NOPEN and
			micd.CODE = diag.KODE and
			ssencounter.kunjungan_nomor = kunj.nomor and
			kunj.nomor = '1010101242212050001' and
			diag.INA_GROUPER = 0;

{"resourceType": "Condition",
   "clinicalStatus": {"coding": [{"system": "http://terminology.hl7.org/CodeSystem/condition-clinical","code": "active","display": "Active"}]},
   "category": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/condition-category","code": "encounter-diagnosis","display": "Encounter Diagnosis"}]}],
   "code": {"coding": [{"system": "http://hl7.org/fhir/sid/icd-10","code": "K35.8","display": "Acute appendicitis, other and unspecified"}]},
   "subject": {"reference": "Patient/100000030009","display": "Budi Santoso"},
   "encounter": {"reference": "Encounter/1a0951f7-c99e-4b54-9207-29709483895d","display": "Kunjungan Budi Santoso di hari Selasa, 14 Juni 2022"}}

============================================================== Encounter ==============================================================

-- select * from pendaftaran.kunjungan order by masuk desc limit 10;
-- select * from pendaftaran.pendaftaran order by nomor desc limit 10;

select * from satusehat_tencounter;

insert into satusehat_tencounter
( id_patient, id_location, id_practitioner, kunjungan_nomor, kunjungan_tanggal,
   sysdate_in, sysdate_last, response_stat )
select 		sspatient.id as id_patient, 
			ssloc.id as id_location,
			sspract.id as id_practitioner,
			kunj.nomor as kunjungan_nomor,
			kunj.masuk as kunjungan_tanggal,
			CURRENT_TIMESTAMP() as sysdate_in,
			CURRENT_TIMESTAMP() as sysdate_last,
			0 as response_stat
	from 	master.pasien p,
			rsfInterconn.satusehat_mpatient sspatient,
			master.ruangan r,
			rsfInterconn.satusehat_mlocation ssloc,
			master.dokter d,
			satusehat_mpractitioner sspract,
			pendaftaran.kunjungan kunj,
			pendaftaran.pendaftaran pend
	where	sspatient.patient_norm 	= p.NORM and
			ssloc.ruangan_id 		= r.id and
			sspract.practitioner_id = d.id and
			kunj.NOPEN = pend.NOMOR and
			pend.NORM = p.NORM and
			kunj.DPJP = d.ID and
			kunj.RUANGAN = r.ID and
			kunj.nomor = '1010101242212050001';
			

{"resourceType": "Encounter","status": "arrived",
 "class": {"system": "http://terminology.hl7.org/CodeSystem/v3-ActCode","code": "AMB","display": "ambulatory"},
 "subject": {"reference": "Patient/100000030009","display": "Budi Santoso"},
 "participant": [{"type": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/v3-ParticipationType","code": "ATND","display": "attender"}]}],
 "individual": {"reference": "Practitioner/N10000001","display": "Dokter Bronsig"}}],
 "period": {"start": "2022-06-14T07:00:00+07:00"},
 "location": [{"location": {"reference": "Location/b017aa54-f1df-4ec2-9d84-8823815d7228","display": "Ruang 1A, Poliklinik Bedah Rawat Jalan Terpadu, Lantai 2, Gedung G"}}],
 "statusHistory": [{"status": "arrived","period": {"start": "2022-06-14T07:00:00+07:00"}}],
 "serviceProvider": {"reference": "Organization/10000004"},
 "identifier": [{"system": "http://sys-ids.kemkes.go.id/encounter/10000004","value": "P20240001"}]}

============================================================== Patient ==============================================================

select	id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mpatient where id = 1;
call rsfInterconn.satusehat_json_get('Patient','1');
call rsfInterconn.satusehat_json_set('Patient','1','{"resourceType": "Bundle","total": 0,"type": "searchset"}');
call rsfInterconn.satusehat_json_set('Patient','1','{"entry": [{"resource": {"birthDate": "1990-07-21","id": "10000329187"}}],"total": 1,"type": "searchset"}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mpatient where id = 1;
update rsfInterconn.satusehat_mpatient set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

insert into satusehat_mpatient (patient_norm, patient_nik, patient_nama, sysdate_in, sysdate_last, response_stat)
select 		p.NORM as patient_norm, kip.NOMOR as patient_nik, p.NAMA as patient_nama, 
			current_timestamp as sysdate_in,
			current_timestamp as sysdate_last,
			0 as response_stat
	from 	master.pasien p,
			master.kartu_identitas_pasien kip left outer join 
			(	
				select		patient_nik
					from 	rsfInterconn.satusehat_mpatient
			) subquery
			on kip.NOMOR = subquery.patient_nik
	where	subquery.patient_nik is null and
			p.NORM = kip.NORM and
			kip.JENIS = 1 and
			kip.NOMOR != '0'
	order 	by p.norm desc limit 15;

============================================================== practitioner ==============================================================

select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mpractitioner where id = 1;
call rsfInterconn.satusehat_json_get('practitioner','1');
call rsfInterconn.satusehat_json_set('practitioner','1','{"resourceType": "Bundle","total": 0,"type": "searchset"}');
call rsfInterconn.satusehat_json_set('practitioner','1','{"entry": [{"resource": {"birthDate": "1990-07-21","id": "10000329187"}}],"total": 1,"type": "searchset"}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mpractitioner where id = 1;
update rsfInterconn.satusehat_mpractitioner set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

insert into satusehat_mpractitioner (
			practitioner_id, practitioner_nip, practitioner_nik, practitioner_nama,
			sysdate_in, sysdate_last, response_stat )
select 		d.ID as practitioner_id, d.NIP as practitioner_nip, ki.NOMOR as practitioner_nik, p.NAMA as practitioner_nama,
			current_timestamp as sysdate_in,
			current_timestamp as sysdate_last,
			0 as response_stat
	from	master.dokter d,
			master.pegawai p,
			pegawai.kartu_identitas ki left outer join 
			(	
				select		practitioner_nik
					from 	rsfInterconn.satusehat_mpractitioner
			) subquery
			on ki.NOMOR = subquery.practitioner_nik
	where	subquery.practitioner_nik is null and
			d.NIP = ki.NIP and
			d.NIP = p.NIP 

============================================================== location ==============================================================

select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mlocation where id = 1;
call rsfInterconn.satusehat_json_get('location','1');
call rsfInterconn.satusehat_json_set('location','1','{"id":"3308ed0c-2a71-4b2a-952f-d75dc6d20064","test":true}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_mlocation where id = 1;
update rsfInterconn.satusehat_mlocation set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

insert into	satusehat_mlocation ( id_organization, ruangan_id, ruangan_jenis, ruangan_kunjungan, ruangan_deskripsi,
			loc_nama, loc_deskripsi, loc_alamat, loc_telp, loc_fax, loc_email, loc_url,
			loc_longitude, loc_latitude, loc_altitude, sysdate_in, sysdate_last, response_stat )
select		1 as id_organization,		
			id as ruangan_id,
			jenis as ruangan_jenis,
			jenis_kunjungan as ruangan_kunjungan,
			deskripsi as ruangan_deskripsi,
			concat('Poliklinik ', deskripsi) as loc_nama,
			concat('Poliklinik ', deskripsi, ' Rawat Jalan') as loc_deskripsi,
			concat('Gedung Rawat Jalan RSUP Fatmawati') as loc_alamat,
			'0000' as loc_telp,
			'0000' as loc_fax,
			'0000' as loc_email,
			'0000' as loc_url,
			'-6.23115426275766' as loc_longitude,
			'106.83239885393944' as loc_latitude,
			'0' as loc_altitude,
			current_timestamp as sysdate_in,
			current_timestamp as sysdate_last,
			0 as response_stat
	from 	master.ruangan 
	where 	SUBSTR(id,1,7) = '1010101' and JENIS_KUNJUNGAN = 1 AND JENIS = 5; 

{"resourceType": "Location",
    "identifier": [{"system": "http://sys-ids.kemkes.go.id/location/1000001","value": "G-2-R-1A"}],
    "status": "active",
    "name": "Ruang 1A IRJT",
    "description": "Ruang 1A, Poliklinik Bedah Rawat Jalan Terpadu, Lantai 2, Gedung G",
    "mode": "instance",
    "telecom": [
        {"system": "phone","value": "2328","use": "work"},
        {"system": "fax","value": "2329","use": "work"},
        {"system": "email","value": "second wing admissions"},
        {"system": "url","value": "http://sampleorg.com/southwing","use": "work"}
    ],
    "address": {
        "use": "work",
        "line": ["Gd. Prof. Dr. Sujudi Lt.5, Jl. H.R. Rasuna Said Blok X5 Kav. 4-9 Kuningan"],
        "city": "Jakarta","postalCode": "12950","country": "ID",
        "extension": [{
                "url": "https://fhir.kemkes.go.id/r4/StructureDefinition/administrativeCode",
                "extension": [{"url": "province","valueCode": "10"},
                    {"url": "city","valueCode": "1010"},
                    {"url": "district","valueCode": "1010101"},
                    {"url": "village","valueCode": "1010101101"},
                    {"url": "rt","valueCode": "1"},
                    {"url": "rw","valueCode": "2"}]}]},
    "physicalType": {"coding": [{"system": "http://terminology.hl7.org/CodeSystem/location-physical-type","code": "ro","display": "Room"}]},
    "position": {"longitude": -6.23115426275766,"latitude": 106.83239885393944,"altitude": 0},
    "managingOrganization": {"reference": "Organization/10000004"}}

============================================================== organization ==============================================================

select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_morganization where id = 1;
call rsfInterconn.satusehat_json_get('organization','1');
call rsfInterconn.satusehat_json_set('organization','1','{"id":"3308ed0c-2a71-4b2a-952f-d75dc6d20064","test":true}');
select id, response_stat, response_json, response_sysdate, response_id from rsfInterconn.satusehat_morganization where id = 1;
update rsfInterconn.satusehat_morganization set response_stat = 0, response_json = null, response_sysdate = null, response_id = null where id = 1;

insert into rsfInterconn.satusehat_morganization
	( 	id,		kode,	nama,	telpon,		email,		url,	
		alamat_jalan,	alamat_kota,		alamat_kodepos,
		alamat_kd_negara,	alamat_kd_kelurahan, alamat_rt, alamat_rw, response_stat )
	values 
	(	1, '10080037', 'RSUP Fatmawati', '+6221-7501524', 'humas@fatmawatihospital.com',
		'https:\/\/rsupfatmawati.id', 'Jalan Fatmawati Cilandak', 'Jakarta', '12430', 'ID',
		'31710101', '000', '000', 0);

{"resourceType": "Organization","active": true,
 "identifier": [{"use": "official","system": "http://sys-ids.kemkes.go.id/organization/10000004","value": "R220001"}],
 "type": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/organization-type","code": "dept","display": "Hospital Department"}]}],
 "name": "Rawat Jalan Terpadu",
 "telecom": [{"system": "phone","value": "+6221-783042654","use": "work"},
        {"system": "email","value": "rs-satusehat@gmail.com","use": "work"},
        {"system": "url","value": "www.rs-satusehat@gmail.com","use": "work"}],
 "address": [{"use": "work","type": "both","line": ["Jalan Jati Asih"],
	"city": "Jakarta","postalCode": "55292","country": "ID",
	"extension": [{"url": "https://fhir.kemkes.go.id/r4/StructureDefinition/administrativeCode",
		"extension": [{"url": "province","valueCode": "31"},
			{"url": "city","valueCode": "3171"},
			{"url": "district","valueCode": "317101"},
			{"url": "village","valueCode": "31710101"}]
			}]}],
 "partOf": {"reference": "Organization/10000004"}}


=== PERSIAPAN pasien dan dokter END =====================================================================================================================================

select * from pendaftaran.kunjungan order by nomor desc limit 10;

call rsfInterconn.satusehat_datakirim();

select * from satusehat_mpractitioner WHERE id >= 23;
select practitioner_nip as NIP, practitioner_nama as  nama_dokter from satusehat_mpractitioner WHERE id >= 23;

select * from satusehat_mpatient;
delete from satusehat_mpatient WHERE id >= 1;
select patient_norm as nomor_rm, patient_nama as  nama_pasien from satusehat_mpatient WHERE id >= 2;

select * from satusehat_mpractitioner WHERE id >= 23;
select * from satusehat_mpatient WHERE id >= 2;

select 		p.NORM as patient_norm, 
			kip.NOMOR as patient_nik, 
			p.NAMA as patient_nama,
			current_timestamp as sysdate_in,
			current_timestamp as sysdate_last,
			0 as response_stat
	from 	master.pasien p,
			master.kartu_identitas_pasien kip left outer join 
			(	
				select		patient_nik
					from 	rsfInterconn.satusehat_mpatient
			) subquery
			on kip.NOMOR = subquery.patient_nik
	where	p.NORM = kip.NORM and
			kip.JENIS = 1 and
			kip.NOMOR != '0'
	order 	by p.norm desc limit 15;
	
update 	master.pasien set NAMA = 'Pasien 1' where NAMA = 'Practitioner 1';
update 	satusehat_mpatient set patient_nama = 'Pasien 1' where patient_nama = 'Practitioner 1';
update  master.kartu_identitas_pasien
   set  NOMOR = '9271060312000001'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 1');

update 	master.pasien set NAMA = 'Pasien 2' where NAMA = 'Practitioner 2';
update 	satusehat_mpatient set patient_nama = 'Pasien 2' where patient_nama = 'Practitioner 2';
update  master.kartu_identitas_pasien
   set  NOMOR = '9204014804000002'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 2');

update 	master.pasien set NAMA = 'Pasien 3' where NAMA = 'Practitioner 3';
update 	satusehat_mpatient set patient_nama = 'Pasien 3' where patient_nama = 'Practitioner 3';
update  master.kartu_identitas_pasien
   set  NOMOR = '9104224509000003'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 3');

update 	master.pasien set NAMA = 'Pasien 4' where NAMA = 'Practitioner 4';
update 	satusehat_mpatient set patient_nama = 'Pasien 4' where patient_nama = 'Practitioner 4';
update  master.kartu_identitas_pasien
   set  NOMOR = '9104223107000004'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 4');

update 	master.pasien set NAMA = 'Pasien 5' where NAMA = 'Practitioner 5';
update 	satusehat_mpatient set patient_nama = 'Pasien 5' where patient_nama = 'Practitioner 5';
update  master.kartu_identitas_pasien
   set  NOMOR = '9104224606000005'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 5');

update 	master.pasien set NAMA = 'Pasien 6' where NAMA = 'Practitioner 6';
update 	satusehat_mpatient set patient_nama = 'Pasien 6' where patient_nama = 'Practitioner 6';
update  master.kartu_identitas_pasien
   set  NOMOR = '9104025209000006'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 6');

update 	master.pasien set NAMA = 'Pasien 7' where NAMA = 'Practitioner 7';
update 	satusehat_mpatient set patient_nama = 'Pasien 7' where patient_nama = 'Practitioner 7';
update  master.kartu_identitas_pasien
   set  NOMOR = '9201076001000007'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 7');

update 	master.pasien set NAMA = 'Pasien 8' where NAMA = 'Practitioner 8';
update 	satusehat_mpatient set patient_nama = 'Pasien 8' where patient_nama = 'Practitioner 8';
update  master.kartu_identitas_pasien
   set  NOMOR = '9201394901000008'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 8');

update 	master.pasien set NAMA = 'Pasien 9' where NAMA = 'Practitioner 9';
update 	satusehat_mpatient set patient_nama = 'Pasien 9' where patient_nama = 'Practitioner 9';
update  master.kartu_identitas_pasien
   set  NOMOR = '9201076407000009'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 9');

update 	master.pasien set NAMA = 'Pasien 10' where NAMA = 'Practitioner 10';
update 	satusehat_mpatient set patient_nama = 'Pasien 10' where patient_nama = 'Practitioner 10';
update  master.kartu_identitas_pasien
   set  NOMOR = '9210060207000010'
 where  NORM = (select NORM from master.pasien where NAMA = 'Pasien 10');

update  master.kartu_identitas_pasien
   set  NOMOR = '9210060207000011'
 where  NORM = (select NORM from master.pasien where NAMA = 'PSNDEMO1851233');

insert into satusehat_mpatient (patient_norm, patient_nik, patient_nama, sysdate_in, sysdate_last, response_stat)
select 		p.NORM as patient_norm, kip.NOMOR as patient_nik, p.NAMA as patient_nama, 
			current_timestamp as sysdate_in,
			current_timestamp as sysdate_last,
			0 as response_stat
	from 	master.pasien p,
			master.kartu_identitas_pasien kip left outer join 
			(	
				select		patient_nik
					from 	rsfInterconn.satusehat_mpatient
			) subquery
			on kip.NOMOR = subquery.patient_nik
	where	subquery.patient_nik is null and
			p.NORM = kip.NORM and
			kip.JENIS = 1 and
			kip.NOMOR != '0'
	order 	by p.norm desc limit 15;
	
=== PERSIAPAN pasien dan dokter END =====================================================================================================================================
