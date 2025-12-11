select		so.RUANGAN as ruangan_kode,
			daftarDepo.depo_nama as ruangan_nama,
			b.KODE_BARANG as katalog_kode,
			b.ID as katalog_id, 
			b.NAMA as katalog_nama, 
			(msatuan.NAMA) as katalog_satuan,
			sod.MANUAL as qty_opname
	from	inventory.stok_opname so,
			inventory.stok_opname_detil sod 
			left outer join inventory.barang_ruangan br 
			on	sod.BARANG_RUANGAN = br.id
			left outer join inventory.barang b 
			on br.BARANG = b.ID 
			LEFT JOIN inventory.satuan msatuan ON msatuan.ID = b.SATUAN,
			(
				select		convert(
							case depo_nama 	when 'anggrek' then '101030106'
											when 'bougenvile' then '101030107'
											when 'gasmedis' then '101030115'
											when 'griya' then '101030103'
											when 'gudang' then '101030111'
											when 'ibs' then '101030108'
											when 'igd' then '101030104'
											when 'irj1' then '101030101'
											when 'irj3' then '101030112'
											when 'okcito' then '101030105'
											when 'produksi' then '101030110'
											when 'teratai' then '101030109'
							else '000000000000000' end, char(15)) as ruangan_kode,
							depo_nama
					from	rsfPelaporan.laporan_so_depo
					group   by depo_nama
			) daftarDepo
	where	so.id		= sod.STOK_OPNAME and
			so.TANGGAL 	> '2022-12-16' and
			so.RUANGAN  = daftarDepo.ruangan_kode and
			so.STATUS 	= 3 and
			sod.MANUAL  != 0 
			and so.TANGGAL < '2023-01-01'
