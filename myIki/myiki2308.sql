7 Agustus 2023
- Update triger/function UTD registration
  * dalam rangka pembentukan data registration, ordered_item, demographics di UTD_BRIDGING
- revisi query pendapatan & ekstrak data (revisi ke-3)
  * karena kasus pasien nopend 2301110477, norm 1863441, cath lab dari rawat inap tapi nyasar ke kunjungan poli jantung
    masih harus ada analisa lanjutan untuk melihat kemungkinan adanya bug aplikasi
  * kasus konsul di konsulkan lagi, kemudian di periksa penunjang di tempat yang di konsulkan lagi
- data permintaan spi (revisi ke-1)
  * dalam rangka melihat penggunaan implan oleh dokter-dokter orthopedi
  * mengikuti revisi dari query pendapatan
- Berkoordinasi dengan team Wynacom untuk progres integrasi aplikasi SIMRS-UTD
  * sudah otomatis saat terima order UTD langsung update data order ke UTD_BRIDGING
  * menunggu feedback dari APLIKASI_UTD yang dikembangkan oleh Wynacom untuk insert data order_result sebagai repon dari terima order
- Update trigger pendaftaran.tujuan_pasien
  * terkait dengan kasus pendaftaran di poliklinik dibatalkan, kemudian didaftarkan lagi di hari yang sama

- master inputan mst_kuota_dokter
- Test triger UTD input respon request UTD
- Test triger UTD input reaksi transfusi UTD
- Update JKN vs REG vs EXE remun
- Kasus2 IRJ
- SATU SEHAT
- Master Katalog
- Antrian Online

Farmasi
------------------
Katalog
Brand
Kelompok
Generik
Kemasan
Pabrik
Pbf
Buffer Gudang
Jenis Anggaran
Sub Jenis Anggaran
Sakti
Sakti Hdr
* Dosis

11 Agustus 2023
-------------------------------------------------------
- Pendapatan Rawat Jalan Revisi 1
  * invetigasi kasus2
  * perbaikan query pendaftaran.pendaftaran.status != 0
- 