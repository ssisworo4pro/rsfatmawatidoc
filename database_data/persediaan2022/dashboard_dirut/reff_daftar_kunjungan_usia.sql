-- kasus pendaftaran vs kunjungan DAN usia_waktu_daftar vs usia_waktu_kunjungan
select 		daftar.NOMOR as no_pendaftaran,
			daftar.TANGGAL AS tgl_daftar,
			daftar.NORM as nomor_rm,
			pasien.TANGGAL_LAHIR as tgl_lahir,
			DATEDIFF(daftar.TANGGAL,pasien.TANGGAL_LAHIR) as usia_hari_daftar,
			DATEDIFF(kunj.MASUK,pasien.TANGGAL_LAHIR) as usia_hari_kunj,
			r.DESKRIPSI as tujuan,
			kunj.MASUK as kunj_terima,
			kunj.KELUAR as kunj_selesai
	from 	pendaftaran.pendaftaran daftar,
			master.pasien pasien,
			pendaftaran.kunjungan kunj,
			master.ruangan r
	where 	daftar.NORM 	 = pasien.NORM and
			daftar.NOMOR     = kunj.NOPEN and
			r.ID 			 = kunj.RUANGAN and
			daftar.NORM      = 1824278 and
			-- SUBSTR(kunj.RUANGAN,1,5) = '10101' and
			daftar.tanggal < DATE_ADD(pasien.TANGGAL_LAHIR, INTERVAL 28 DAY) AND
			daftar.tanggal 	>= '2022-01-01' and 
			daftar.tanggal 	 < '2023-01-01'
	order   by kunj.MASUK;

-- kunjungan rawat jalan DAN usia_waktu_kunjungan sampai 28 hari
select 		daftar.NOMOR as no_pendaftaran,
			kunj.NOMOR as no_kunjungan,
			kunj.MASUK as tgl_kunjungan,
			daftar.NORM as nomor_rm,
			pasien.TANGGAL_LAHIR as tgl_lahir,
			DATEDIFF(kunj.MASUK,pasien.TANGGAL_LAHIR) as usia_hari_kunj,
			r.DESKRIPSI as tujuan,
			kunj.MASUK as kunj_terima,
			kunj.KELUAR as kunj_selesai
	from 	pendaftaran.pendaftaran daftar,
			master.pasien pasien,
			pendaftaran.kunjungan kunj,
			master.ruangan r
	where 	daftar.NORM 	 = pasien.NORM and
			daftar.NOMOR     = kunj.NOPEN and
			r.ID 			 = kunj.RUANGAN and
			SUBSTR(kunj.RUANGAN,1,5) = '10101' and
			kunj.MASUK       < DATE_ADD(pasien.TANGGAL_LAHIR, INTERVAL 29 DAY) AND
			kunj.MASUK      >= '2022-01-01' and 
			kunj.MASUK       < '2023-01-01'
	order   by kunj.MASUK;

-- jumlah pasien dan jumlah kunjungan per instalasi per cara bayar dengan usia pasien <= 28 hari
select		max(subquery.instalasi) as instalasi,
			max(subquery.carabayar_nm) as carabayar_nm,
			count(1) as jumlah_pasien,
			sum(subquery.jumlah_kunjungan) as jumlah_kunjungan
	from	(
				select 		max(daftar.NORM) as nomor_rm,
							count(1) as jumlah_kunjungan,
							max(r.DESKRIPSI) as instalasi,
							max(mcarabayar.deskripsi) as carabayar_nm
					from 	master.pasien pasien,
							pendaftaran.kunjungan kunj,
							master.ruangan r,
							pendaftaran.pendaftaran daftar
							left outer join
							(
								select 		pp.NOPEN, 
											MAX(pp.JENIS) as carabayar_id,
											COUNT(1) as carabayar_qty
									from	pendaftaran.penjamin pp,
											master.referensi mr
									where	pp.JENIS = mr.ID and
											mr.JENIS = 10
									group   by pp.NOPEN
							) pjamin
							on pjamin.NOPEN = daftar.NOMOR
							left outer join
							(
								select		*
									from 	master.referensi mr
									where   JENIS = 10 
							) mcarabayar
							on mcarabayar.id = pjamin.carabayar_id
							-- master.referensi refr
					where 	daftar.NORM 	 = pasien.NORM and
							daftar.NOMOR     = kunj.NOPEN and
							-- refr.JENIS       = 10 and
							SUBSTR(kunj.RUANGAN,1,5) = r.id and
							kunj.MASUK       < DATE_ADD(pasien.TANGGAL_LAHIR, INTERVAL 29 DAY) AND
							kunj.MASUK      >= '2022-01-01' and 
							kunj.MASUK       < '2023-01-01'
					group   by daftar.NORM, SUBSTR(kunj.RUANGAN,1,5), pjamin.carabayar_id
		) subquery
group   by subquery.instalasi, subquery.carabayar_nm
order   by subquery.instalasi, subquery.carabayar_nm;
