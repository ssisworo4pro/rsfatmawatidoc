SELECT 
nik = ISNULL(M.NOKTP,'0000000000000000'),
nama_pasien = A.NAMA,  
id_jenis_kelamin  = CASE WHEN A.KELAMIN = '1' THEN '1' WHEN A.KELAMIN = '0' THEN '2' END,
tanggal_lahir = A.TGL_LAHIR,
alamat = M.ALAMAT,
id_kelurahan = N.WIL_NEW,
alamat_tinggal = M.ALAMAT,
id_kelurahan_tinggal = N.WIL_NEW,
kontak_pasien = CASE WHEN M.NO_HP = '0' THEN M.NO_TELPON
                WHEN M.NO_HP IS NULL THEN  M.NO_TELPON ELSE '021' END, 
tanggal_masuk = A.TGL_DAFTAR,
id_cara_masuk_pasien = CASE WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0101','1301','1501') THEN '0'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0202','0203','0301','0302','0401','0402','0501','0502','0601','0602','0701','0801','0802','0901','0902','1001','1002','1101','1108','1109','1110','1201','1202') THEN '2'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0102','0103','0104','0105','0106','0107','0201','1102','1103','1104','1105','1106','1107','1401','1402','1403','1404','1405','1406','1407','1408','1409','1502','1503','1504') THEN '1' ELSE '0' END,
id_asal_rujukan_pasien = CASE WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0102','1102','1401','1402','1502') THEN '1'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0103','1103','1403','1404','1407','1503') THEN '2'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK = '1405' THEN '4'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0104','1104','1406','1504') THEN '5'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK = '1408' THEN '7'
                        WHEN C.KD_ASAL_RJK+C.KD_CARAMASUK IN ('0106','1106','1409') THEN '8' ELSE '2' END,
asal_rjk_psn_fasyankes_lain = '',
id_diagnosa_masuk = E.KD_ICD, 
id_instalasi_unit = CASE WHEN G.KD_KLP = '01' THEN '3' 
                    WHEN G.KD_KLP = '02' THEN '2' 
                    WHEN G.KD_KLP = '03' THEN '1' END , 
id_sub_instalasi_unit = CASE WHEN O.KD_KELAS IN ('65','12','13','34','39','36','01','64','83','70','69','74','71','72','73','50','61','56','57','49','21','23','22','32','33','31','84','11','81','82','91','92','97','93','90','95','85','60','63','00','87','80','19','20','98','45','88','14','43','44','15','17','18','68','66','53','54','55','02','38','37','51','67','52','58','75','35') THEN '2.1' 
                            WHEN O.KD_KELAS IN ('62','47','46','79','86','77','76','42','41','40','48','89','78','99') THEN '2.2'
                            WHEN O.KD_KELAS IN ('16','96') THEN '2.3' ELSE '2.1' END,
id_diagnosa_utama = E.KD_ICD,
id_diagnosa_sekunder1 = '',
id_diagnosa_sekunder2 = '',
id_diagnosa_sekunder3 = '',
tanggal_diagnosa  = D.TGL_DIAGNOSA,
tanggal_keluar = J.TGL_KELUAR, 

id_cara_keluar = CASE WHEN K.KD_CARAKELUAR IN ('00','01') THEN '1'
                    WHEN K.KD_CARAKELUAR = '02' THEN '3' 
                    WHEN K.KD_CARAKELUAR = '03' THEN '2'
                    WHEN K.KD_CARAKELUAR = '04' THEN '6'
                    WHEN K.KD_CARAKELUAR = '05' THEN '7' ELSE '1' END,
id_keadaan_keluar = CASE WHEN J.KD_KEADAAN_KLR IN ('0','1') THEN '3'
                        WHEN J.KD_KEADAAN_KLR = '2' THEN '4'
                        WHEN J.KD_KEADAAN_KLR = '3' THEN '5'
                        WHEN J.KD_KEADAAN_KLR = '4' THEN '6' ELSE '3' END,
id_sebab_kematian_langsung_1a = '',
id_sebab_kematian_antara_1b = '',
id_sebab_kematian_antara_1c = '',
id_sebab_kematian_dasar_1d = '',
id_kondisi_kontribusi_kematian = '',
sebab_dasar_kematian = '',
id_cara_bayar = CASE WHEN B.KD_BAYAR = '001' THEN '1'
                WHEN B.KD_BAYAR IN ('006','012') THEN '6'
                WHEN B.KD_BAYAR IN ('008','010','011','004','003','007') THEN '7'
                WHEN B.KD_BAYAR+B.KD_JNS_CARABAYAR  = '00522' THEN '4'
                WHEN B.KD_BAYAR = '005' AND B.KD_JNS_CARABAYAR != '22' THEN '6'
                WHEN B.KD_BAYAR+B.KD_JNS_CARABAYAR IN ('01303','01304','01306','01307') THEN '2'
                WHEN B.KD_BAYAR+B.KD_JNS_CARABAYAR IN ('01305','01301','01301') THEN '3' ELSE '5' END,
nomor_bpjs = C.SESSION_ID_LAKA_POLDA,

A.NO_PENDAFTARAN, 
A.NORM, 
B.JNS_CARABAYAR, 
E.NM_ICD, 
H.KD_JNS_DIAGNOSA, 
H.NM_JNS_DIAGNOSA, 
F.NM_PENERIMA, 
G.NM_INST, 
H.NM_JNS_DIAGNOSA
FROM 
TBIL_PENDAFTARAN A,
MMAS_JNS_CRBYR B,
TDFT_PENDAFTARAN C,
TRM_DIAGNOSA_PSN D,
MMAS_RM_ICD E,
MMAS_PENERIMA F,
MDFT_INSTALASI G,
MMAS_JNS_DIAGNOSA H,
TDFT_KELUAR J,
MDFT_CARAKELUAR K,
TDFT_PASIEN_RM L,
TDFT_PASIEN_DEWASA M,
MAPING_WILAYAH N,
TDFT_RRAWAT_PASIEN O
WHERE   
A.KD_BAYAR = B.KD_BAYAR
AND A.KD_JNS_CARABAYAR = B.KD_JNS_CARABAYAR
AND A.NO_PENDAFTARAN = C.NO_PENDAFTARAN
AND C.NO_PENDAFTARAN = D.NO_PENDAFTARAN
AND D.KD_ICD = E.KD_ICD
AND D.KD_PELAKSANA = F.KD_PENERIMA
AND A.KD_INST = G.KD_INST
AND D.KD_JNS_DIAGNOSA = H.KD_JNS_DIAGNOSA
AND A.NO_PENDAFTARAN = J.NO_PENDAFTARAN
AND J.KD_CARAKELUAR = K.KD_CARAKELUAR
AND C.NORM = L.NORM
AND C.NORM = M.NORM
AND (M.KD_PROPINSI+M.KD_KODYA+M.KD_KECAMATAN+M.KD_KELURAHAN = N.WIL_OLD) 
AND J.NO_PENDAFTARAN = O.NO_PENDAFTARAN
AND (O.STS_AKHIR = '1' OR O.STS_AKHIR = '2')
--AND K.KD_CARAKELUAR = '05'
-- AND (J.TGL_KELUAR >= '2022/01/01' AND J.TGL_KELUAR < '2022/01/01')  
-- AND D.TGL_CATAT  >= '2022/01/01' AND D.TGL_CATAT < '2022/04/01'
AND A.TGL_DAFTAR >= '2022/01/01' AND A.TGL_DAFTAR < '2022/04/01'
AND A.STS_PASIEN <> '9'
AND (C.STS_BATAL IS NULL OR C.STS_BATAL = '0')
AND H.KD_JNS_DIAGNOSA = '00'
AND G.KD_INST in ('02','04','05','06','07','19','43','22') 
AND D.KD_ICD IN ('U07.1','U07.2','A30.9','A36.8','A36.9','B20','B20.0','B20.1','B20.2','B20.3','B20.4','B20.5','B20.6','B20.7','B20.8','B20.9','A90','A91','A91.0','A91.1','A91.9 ')


