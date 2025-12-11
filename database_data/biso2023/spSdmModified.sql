select * from master.pegawai p

select * from master.referensi r where r.JENIS = 88;

select 	p.FLAGBIOS, 
		sum(1) as total,
		sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0')) as pns,
		sum(if(sp.STATUS_PEGAWAI in('13'),'1','0')) as pppk,
		sum(if(sp.STATUS_PEGAWAI in('4'),'1','0')) as non_pns_tetap,
		sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0')) as kontrak
		from master.pegawai p,
		pegawai.status_pegawai sp
	where p.NIP = sp.NIP
group by p.FLAGBIOS ;

select 	p.* 
		from master.pegawai p,
		pegawai.status_pegawai sp
	where p.NIP = sp.NIP and
		sp.STATUS_PEGAWAI = 9;

select FLAGBIOS, sum(1) from master.pegawai p group by p.FLAGBIOS;
