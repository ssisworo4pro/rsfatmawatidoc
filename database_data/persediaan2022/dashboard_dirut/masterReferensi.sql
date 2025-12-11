insert into rsfMaster.mlokasi_instalasi
			(id, jenis, jenis_kunjungan, ref_id, deskripsi, status, dashboard_klp, dashboard_hitung)
select 		id, jenis, jenis_kunjungan, ref_id, deskripsi, status, 'Rawat Jalan' as dashboard_klp, 1 as dashboard_hitung
	from	master.ruangan r 
	where 	JENIS = 3;

update rsfMaster.mlokasi_instalasi set dashboard_klp = 'Rawat Inap' where id = '10102';
update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where jenis_kunjungan = 0;
update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where jenis_kunjungan > 5;
update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where id = '10113';
update rsfMaster.mlokasi_instalasi set dashboard_hitung = 0 where id = '10119';

select * from rsfMaster.mlokasi_instalasi order by dashboard_hitung desc, dashboard_klp;

