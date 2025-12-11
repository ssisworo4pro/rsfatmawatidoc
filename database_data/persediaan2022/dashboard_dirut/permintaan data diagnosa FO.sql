select  TOP 10 * from TDFT_PASIEN_RM
select  TOP 10 * from dbo.TRM_DIAGNOSA_PSN WHERE KD_ICD IN ('O47.0','O47.1')
select  TOP 10 * from TBIL_PENDAFTARAN
select  * from MDFT_INSTALASI WHERE KD_KLP = '02'


select   COUNT(DISTINCT(B.NO_PENDAFTARAN) )
from 
TRM_DIAGNOSA_PSN A,
TBIL_PENDAFTARAN B
WHERE 
A.NO_PENDAFTARAN=B.NO_PENDAFTARAN AND
B.KD_INST IN ('01','03','13','14','39','40','46') AND
B.STS_PASIEN != '9' AND
B.TGL_DAFTAR >= '2022/01/01' AND
B.TGL_DAFTAR < '2022/04/01' AND
A.KD_ICD like 'E10%' or 
A.KD_ICD like 'E11%' or
A.KD_ICD like 'E12%' or
A.KD_ICD like 'E13%' or
A.KD_ICD like 'E14%' or
A.KD_ICD like 'E15%' 


select   COUNT(DISTINCT(B.NO_PENDAFTARAN) )
from 
TRM_DIAGNOSA_PSN A,
TBIL_PENDAFTARAN B
WHERE 
A.NO_PENDAFTARAN=B.NO_PENDAFTARAN AND
B.KD_INST IN ('02','04','05','06','07','19','43','22') AND
B.STS_PASIEN != '9' AND
B.TGL_DAFTAR >= '2022/01/01' AND
B.TGL_DAFTAR < '2022/04/01' AND
A.KD_ICD like 'E10%' or 
A.KD_ICD like 'E11%' or
A.KD_ICD like 'E12%' or
A.KD_ICD like 'E13%' or
A.KD_ICD like 'E14%' or
A.KD_ICD like 'E15%' 




select   B.NO_PENDAFTARAN, B.TGL_DAFTAR,C.TGL_LAHIR, DATEDIFF(DAY,C.TGL_LAHIR,B.TGL_DAFTAR) UMUR
from 
TBIL_PENDAFTARAN B,
TDFT_PASIEN_RM C
WHERE 
B.NORM=C.NORM AND
B.KD_INST IN ('01','03','13','14','39','40','46') AND
B.STS_PASIEN != '9' AND
B.TGL_DAFTAR >= '2022/01/01' AND
B.TGL_DAFTAR < '2022/04/01' 


-----------------------

select count(distinct(md.NOPEN)) 
from 
medicalrecord.diagnosa md 
left join pendaftaran.pendaftaran pp on pp.NOMOR=md.NOPEN
left join pendaftaran.tujuan_pasien tp on tp.NOPEN=pp.NOMOR
where 
tp.RUANGAN not like '10102%' and
pp.TANGGAL >= '2022-04-01' and
pp.TANGGAL < '2023-01-01' and
pp.STATUS != '0' and
md.KODE in ('U07.1', 'U07.2','A30.9','A36.8','A36.9') or
md.KODE like 'B20%' or
md.KODE like 'A90%' or
md.KODE like 'A91%' and
md.STATUS!='0';
