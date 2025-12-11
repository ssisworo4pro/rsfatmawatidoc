-- persiapan master data
call rsfMaster.masterreferensi_sync('lokasi.instalasi');
select * from rsfMaster.mlokasi_instalasi order by dashboard_hitung desc, dashboard_klp;

call rsfMaster.masterreferensi_sync('lokasi.nicupicu');
select * from rsfMaster.mlokasi_nicupicu;

call rsfMaster.masterreferensi_sync('icd10.penyakit');
select * from rsfMaster.mdiagnosa_penyakit;

-- pembentukan datadasar untuk query dashboard
call rsfPelaporan.dashboard_dirut_data('pasien28hari');
select count(1) from rsfPelaporan.dashboardes_pasien28hari;

call rsfPelaporan.dashboard_dirut_data('pasienNicuPicu');
select count(1) from rsfPelaporan.dashboardes_pasiennicupicu;

call rsfPelaporan.dashboard_dirut_data('pasienDiagnosa');
select count(1) from rsfPelaporan.dashboardes_pasiendiagnosa;


TAHAPAN PROSES :
1. isi table master di rsfMaster
   - mlokasi_instalasi
   - mlokasi_nicupicu
   - mdiagnosa_penyakit
   cara ngisinya dengan menjalankan
   fungsi : call rsfMaster.masterreferensi_sync('....');
2. bentuk datadasar executive summary
   - dashboardes_pasien28hari
   - dashboardes_pasiennicupicu
   - dashboardes_pasiendiagnosa
   cara ngisinya dengan menjalankan
   fungsi : call  rsfPelaporan.dashboard_dirut_data('...');
3. dashboard http://192.168.5.52:88/ 
   akan manggil fungsi : rsfPelaporan.dashboard_dirut()
   untuk menampilkan data

catatan :
 - kalo ada penyesuian atau penambahakn
   adanya di master (nomor 1)
     misal : nambahin diagnosa yang mau di review
   atau di datadasrnya (nomor 2(
     misal : nambahin data bulan jan s.d maret dari medisys
 - ada yang belum 1 lagi
   pembentukan data berdasarkan dpjp
 - pengembangannya, baru bikin rekapan per jenis layanan
 
 
	 
   
   