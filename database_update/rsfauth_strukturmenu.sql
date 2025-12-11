select * from logs.pengguna_akses_log pal where pal.OBJEK = 18020; 
select * from layanan.tindakan_medis;

select 		* 
	from 	aplikasi.objek o 
	where   TABEL = 'layanan.tindakan_medis';
	
	
	select * from rsfAuth.modules m;

insert into rsfAuth.modules_smenu 
	( smenuname, created_at, created_by, updated_at, updated_by )
values ('struktur menu standar', current_timestamp, 0, current_timestamp, 0);

select * from rsfAuth.modules_smenu;

insert into modules_smenu_dtl (id_smenu, kode_smenu, smenu_name, is_heading,
	level, id_modules, created_at, created_by, updated_at, updated_by )
values 	(1,'0100000000', 'Dashboard', 0, 1, 1, current_timestamp, 0, current_timestamp, 0),
		(1,'0200000000', 'Master', 1, 1, null, current_timestamp, 0, current_timestamp, 0),
		(1,'0201000000', 'Pegawai', 0, 2, 5, current_timestamp, 0, current_timestamp, 0),
		(1,'0202000000', 'Pengguna', 0, 2, 6, current_timestamp, 0, current_timestamp, 0),
		(1,'0203000000', 'Pasien', 0, 2, 14, current_timestamp, 0, current_timestamp, 0),
		(1,'0204000000', 'Kuota', 0, 2, 16, current_timestamp, 0, current_timestamp, 0),
		(1,'0205000000', 'Kuota Dokter', 0, 2, 21, current_timestamp, 0, current_timestamp, 0),
		(1,'0206000000', 'Katalog', 0, 2, 37, current_timestamp, 0, current_timestamp, 0),
		(1,'0300000000', 'Keuangan', 1, 1, null, current_timestamp, 0, current_timestamp, 0),
		(1,'0301000000', 'Klaim', 0, 2, 8, current_timestamp, 0, current_timestamp, 0),
		(1,'0302000000', 'Klaim Data', 0, 2, 20, current_timestamp, 0, current_timestamp, 0),
		(1,'0303000000', 'Import Data', 0, 2, 22, current_timestamp, 0, current_timestamp, 0),
		(1,'0304000000', 'Bios', 0, 2, 40, current_timestamp, 0, current_timestamp, 0),
		(1,'0400000000', 'Reservasi', 1, 1, null, current_timestamp, 0, current_timestamp, 0),
		(1,'0401000000', 'UTD', 0, 2, 13, current_timestamp, 0, current_timestamp, 0),
		(1,'0402000000', 'MCU', 0, 2, 18, current_timestamp, 0, current_timestamp, 0),
		(1,'0403000000', 'Meningitis', 0, 2, 19, current_timestamp, 0, current_timestamp, 0),
		(1,'0404000000', 'Rawat Jalam', 0, 2, 28, current_timestamp, 0, current_timestamp, 0),
		(1,'0405000000', 'Griya Husada', 0, 2, 29, current_timestamp, 0, current_timestamp, 0),
		(1,'0500000000', 'Laboratorium', 1, 1, null, current_timestamp, 0, current_timestamp, 0),
		(1,'0501000000', 'Jadwal Lab', 0, 2, 24, current_timestamp, 0, current_timestamp, 0),
		(1,'0600000000', 'Public', 1, 1, null, current_timestamp, 0, current_timestamp, 0),
		(1,'0601000000', 'BPJS Kepesertaan', 0, 2, 31, current_timestamp, 0, current_timestamp, 0),
		(1,'0602000000', 'Offline', 0, 2, 32, current_timestamp, 0, current_timestamp, 0),
		(1,'0603000000', 'Offline Vaksin', 0, 2, 33, current_timestamp, 0, current_timestamp, 0),
		(1,'0700000000', 'Monitoring', 1, 1, null, current_timestamp, 0, current_timestamp, 0),
		(1,'0701000000', 'Dashboard Direktur', 0, 2, 35, current_timestamp, 0, current_timestamp, 0),
		(1,'0702000000', 'Farmasi', 0, 2, 15, current_timestamp, 0, current_timestamp, 0);


insert into rsfAuth.modules_smenu 
	( smenuname, created_at, created_by, updated_at, updated_by )
values ('struktur linier', current_timestamp, 0, current_timestamp, 0);

select * from rsfAuth.modules_smenu;

insert into modules_smenu_dtl (id_smenu, kode_smenu, smenu_name, is_heading,
	level, id_modules, created_at, created_by, updated_at, updated_by )
values 	(2,'0100000000', 'Master Katalog', 0, 2, 37, current_timestamp, 0, current_timestamp, 0),
		(2,'0200000000', 'Master Pegawai', 0, 2, 5, current_timestamp, 0, current_timestamp, 0),
		(2,'0300000000', 'Master Pengguna', 0, 2, 6, current_timestamp, 0, current_timestamp, 0);

-----------

insert into rsfAuth.users_grp (grpname, created_at, created_by, updated_at, updated_by, id_smenu)
values ('Katalog', current_timestamp, 0, current_timestamp, 0, 2);
select * from rsfAuth.users_grp;

select * from rsfAuth.modules_grp mg ;
insert into rsfAuth.modules_grp 
	(	id_grp, id_modules, active_stat, bitcontrol1, bitcontrol2, 
		created_at, created_by, updated_at, updated_by )
	select 		3 as id_grp, grp.id_modules, grp.active_stat, grp.bitcontrol1, grp.bitcontrol2, 
				grp.created_at, grp.created_by, grp.updated_at, grp.updated_by 
		from 	rsfAuth.modules_grp grp
		where 	grp.id_grp = 1;

update rsfAuth.users_practitioner set id_grp = 3 where id = 4;

select * from rsfAuth.modules_smenu_dtl;

select * from rsfAuth.users_practitioner up;
update rsfAuth.users_practitioner set id_grp = 3 where id = 4;

call rsfAuth.rsfauth_menu(4);
call rsfAuth.rsfauth_menu(1);

select * from modules_smenu_dtl where id_smenu = 2;
update modules_smenu_dtl set level = 1 where id_smenu = 2;