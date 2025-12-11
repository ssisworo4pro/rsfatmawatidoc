insert into rsfMaster.msetting_hcode ( id_hcode, nama_hcode, object_id, function_id, sysdate_in )
values ( 1, 'LOG-BACKEND-PROSES','rsfLog.tlog_backend', null, CURRENT_TIMESTAMP() )

insert into rsfMaster.msetting_hcode_jenis ( id_hcode, id_jenis, keterangan, object_id, sysdate_in )
values ( 1, 1, 'error log untuk proses Sinkronisasi Data Teamterima dan Gudang','SYN-TTERIMA', CURRENT_TIMESTAMP() ),
       ( 1, 2, 'error log untuk proses Export Data SAKTI','EXP-SAKTI', CURRENT_TIMESTAMP() );

insert into rsfMaster.msetting_hcode ( id_hcode, nama_hcode, object_id, function_id, sysdate_in )
values ( 3, 'remun - kelompok bayar', 'rsfPegawai.mremun_persentase', 'kd_klp_byr', current_timestamp() ),
       ( 4, 'remun - jenis petugas', 'rsfPegawai.mremun_persentase', 'kd_petugas_jenis', current_timestamp() );

insert into rsfMaster.msetting_hcode_jenis ( id_hcode, id_jenis, keterangan, object_id, sysdate_in )
values ( 3, 1, 'JKN', 'remun.JKN', current_timestamp() ),
       ( 3, 2, 'NON JKN', 'remun.NON JKN', current_timestamp() ),
       ( 4, 1, 'operator', 'remun.Pelaksan', current_timestamp() ),
       ( 4, 2, 'co-operator', 'remun.Pendamping', current_timestamp() ),
       ( 4, 3, 'anestesi', 'remun.Anestesi', current_timestamp() );
