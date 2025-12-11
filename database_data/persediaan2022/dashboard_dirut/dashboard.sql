select		deskripsi as uraian,
			count(1)  as jml_pendaftaran
	from	(
				SELECT		pasien.NORM as pasien_norm, 
							pasien.NAMA as pasien_nama,
							DATE_FORMAT(pasien.TANGGAL_LAHIR,'%d-%m-%Y') as pasien_tgl_lahir,
							IF(pasien.JENIS_KELAMIN=1,'L','P') as pasien_jeniskelamin,
							IF(DATE_FORMAT(pasien.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y'),'Baru','Lama') as daftar_pengunjung, 
							bpjs.nmJenisPeserta as bpjs_jenis_peserta, 
							bpjs.kdKelas as bpjs_kelas,
							daftar.NOMOR as daftar_nomor,
							DATE_FORMAT(daftar.TANGGAL,'%d-%m-%Y %H:%i:%s') daftar_tanggal, 
							DATE_FORMAT((SELECT tk.MASUK
											FROM	pendaftaran.kunjungan tk
											WHERE 	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),'%d-%m-%Y %H:%i:%s') daftar_tglterima, 
							DATE_FORMAT(TIMEDIFF((SELECT 	tk.MASUK
													FROM 	pendaftaran.kunjungan tk
													WHERE	tk.NOPEN=daftar.NOMOR AND tk.REF IS NULL LIMIT 1),daftar.TANGGAL),'%H:%i:%s') kunjungan_selisih,
							ref.DESKRIPSI as daftar_carabayar, 
							stt.DESKRIPSI as daftar_keterangan,
							IF(pjamin.JENIS=0,'Semua',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=pjamin.JENIS AND ref.JENIS=10)) as daftar_carabayar_hdr,
							pjamin.NOMOR as NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, i.DESKRIPSI INSTALASI, 
							r.DESKRIPSI UNITPELAYANAN, 
							instalasi.deskripsi,
							srp.DOKTER,
							INST.NAMAINST, INST.ALAMATINST 
					FROM	master.pasien pasien
							LEFT JOIN master.referensi rjk ON pasien.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2, 
							pendaftaran.pendaftaran daftar
							LEFT JOIN pendaftaran.penjamin pjamin ON daftar.NOMOR=pjamin.NOPEN
							LEFT JOIN master.referensi ref ON pjamin.JENIS=ref.ID AND ref.JENIS=10
							LEFT JOIN master.kartu_asuransi_pasien kap ON daftar.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
							LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON daftar.RUJUKAN=srp.ID AND srp.STATUS!=0
							LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
							LEFT JOIN aplikasi.pengguna us ON daftar.OLEH=us.ID AND us.STATUS!=0
							LEFT JOIN master.pegawai pegawai ON us.NIP=pegawai.NIP AND pegawai.STATUS!=0
							LEFT JOIN bpjs.peserta bpjs on bpjs.NORM=daftar.NORM, 
							pendaftaran.tujuan_pasien tujuandft
							LEFT JOIN master.ruangan r ON tujuandft.RUANGAN=r.ID AND r.JENIS=5
							LEFT JOIN master.ruangan i ON left(tujuandft.RUANGAN,5)=left(i.ID,5) AND r.JENIS=3
							LEFT JOIN rsfMaster.mlokasi_instalasi instalasi on instalasi.id = substr(tujuandft.RUANGAN,1,5)
							LEFT JOIN master.dokter dok ON tujuandft.DOKTER=dok.ID
							LEFT JOIN master.referensi stt ON tujuandft.STATUS=stt.ID AND stt.JENIS=24 AND stt.ID=2, master.ruangan jkr  
							LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5,
							(	SELECT 		p.NAMA NAMAINST, p.ALAMAT ALAMATINST
									FROM 	aplikasi.instansi ai, master.ppk p
									WHERE 	ai.PPK=p.ID ) INST
					WHERE 	pasien.NORM 			 	 = daftar.NORM AND 
							daftar.NOMOR			 	 = tujuandft.NOPEN AND 
							daftar.STATUS 				IN (1,2) AND 
							tujuandft.RUANGAN		 	 = jkr.ID AND 
							jkr.JENIS				 	 = 5 AND 
							daftar.TANGGAL				>= DATE_ADD(CURRENT_DATE(), INTERVAL 0 DAY) AND
							daftar.TANGGAL				 < DATE_ADD(CURRENT_DATE(), INTERVAL 1 DAY) AND
							daftar.STATUS 				IN (1,2) AND
							left(tujuandft.RUANGAN,5)  	in ('10119','10112','10101','10106','10110','10127','10114','10115','10117','10118','10125')
					ORDER 	BY daftar.NOMOR, tujuandft.RUANGAN
			) dashboardrj
	GROUP	by deskripsi
	