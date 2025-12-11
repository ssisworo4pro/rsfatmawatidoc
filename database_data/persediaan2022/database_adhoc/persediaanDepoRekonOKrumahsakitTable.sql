-------------- non grup

insert into rsfPelaporan.laporan_so_trxrsn
	( 	katalog_kode, katalog_nama, katalog_satuan, katalog_merk,
		katalog_kode_asal, katalog_kode_koreksi, katalog_kode_grp, koreksi_tambahan, koreksi_keterangan,
		opname, beli, mmasuk, mkeluar, prod, resep, resep_retur,
		jual, jual_retur, tambil, akhir )
	SELECT		max(laporanSOdepoREKON.katalog_kode) as katalog_kode,
				max(barang.NAMA) as katalog_nama,
				max(msatuan.NAMA) as katalog_satuan,
				max(mreff.DESKRIPSI) as katalog_merk,
				max(laporanSOdepoREKON.katalog_kode_asal) as katalog_kode_asal,
				max(laporanSOdepoREKON.katalog_kode_koreksi) as katalog_kode_koreksi,
				max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp,
				max(laporanSOdepoREKON.koreksi_tambahan) as koreksi_tambahan,
				max(laporanSOdepoREKON.koreksi_keterangan) as koreksi_keterangan,
				sum(tableTransaksi.opname) as opname,
				sum(tableTransaksi.beli) as beli,
				sum(tableTransaksi.mmasuk) as mmasuk,
				sum(tableTransaksi.mkeluar) as mkeluar,
				sum(tableTransaksi.prod) as prod,
				sum(tableTransaksi.resep) as resep,
				sum(tableTransaksi.resep_retur) as resep_retur,
				sum(tableTransaksi.jual) as jual,
				sum(tableTransaksi.jual_retur) as jual_retur,
				sum(tableTransaksi.tambil) as tambil,
				sum(tableTransaksi.akhir) as akhir
		FROM	rsfPelaporan.laporan_so_trx tableTransaksi,
				(
					select		case depo_nama 	when 'anggrek' then '101030106'
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
								else '00000000' end as ruangan_kode,
								depo_nama,
								katalog_id,
								katalog_kode as katalog_kode_asal,
								koreksi_kode as katalog_kode_koreksi,
								case COALESCE(koreksi_kode, '')
									when '' then katalog_kode
									else koreksi_kode end as katalog_kode,
								katalog_nama as katalog_nama_asal,
								koreksi_kode2 as koreksi_tambahan,
								koreksi_keterangan
						from	laporan_so_depo
						-- where   koreksi_kode <> '.GHE' and koreksi_kode <> '.PINJAM' and koreksi_kode <> '0000000'
						--		and koreksi_kode <> '.BILLING' and koreksi_kode <> '.TAMBIL' and
						--		koreksi_kode2 <> '.GHE' and koreksi_kode2 <> '.PINJAM' and koreksi_kode2 <> '0000000'
						--		and koreksi_kode2 <> '.BILLING' and koreksi_kode2 <> '.TAMBIL'
						order   by case COALESCE(koreksi_kode, '')
									when '' then katalog_kode
									else koreksi_kode end
				) laporanSOdepoREKON
				left outer join (
					select 		*
						from 	rsfPelaporan.laporan_so_grp
				) laporanKatalogGrp
				on  laporanKatalogGrp.katalog_kode = laporanSOdepoREKON.katalog_kode
				left outer join (
					select * from inventory.barang where id in 
					(select min(id) from inventory.barang where KODE_BARANG is not null group by KODE_BARANG)
				) barang
					on barang.KODE_BARANG = laporanSOdepoREKON.katalog_kode
				left outer join inventory.satuan msatuan ON msatuan.ID = barang.SATUAN
				left outer join (select * from master.referensi where JENIS = 39) mreff on barang.MERK = mreff.ID
		WHERE	laporanSOdepoREKON.ruangan_kode = tableTransaksi.depo_kode and
				laporanSOdepoREKON.katalog_id = tableTransaksi.katalog_id
		GROUP   BY  laporanSOdepoREKON.katalog_kode

---------------------------- grup

insert into rsfPelaporan.laporan_so_trxrs
	( 	katalog_kode, katalog_nama, katalog_satuan, katalog_merk,
		katalog_kode_asal, katalog_kode_koreksi, katalog_kode_grp, koreksi_tambahan, koreksi_keterangan,
		opname, beli, mmasuk, mkeluar, prod, resep, resep_retur,
		jual, jual_retur, tambil, akhir )
	SELECT		max(laporanSOdepoREKON.katalog_kode) as katalog_kode,
				max(barang.NAMA) as katalog_nama,
				max(msatuan.NAMA) as katalog_satuan,
				max(mreff.DESKRIPSI) as katalog_merk,
				max(laporanSOdepoREKON.katalog_kode_asal) as katalog_kode_asal,
				max(laporanSOdepoREKON.katalog_kode_koreksi) as katalog_kode_koreksi,
				max(laporanKatalogGrp.katalog_kode_grp) as katalog_kode_grp,
				max(laporanSOdepoREKON.koreksi_tambahan) as koreksi_tambahan,
				max(laporanSOdepoREKON.koreksi_keterangan) as koreksi_keterangan,
				sum(tableTransaksi.opname) as opname,
				sum(tableTransaksi.beli) as beli,
				sum(tableTransaksi.mmasuk) as mmasuk,
				sum(tableTransaksi.mkeluar) as mkeluar,
				sum(tableTransaksi.prod) as prod,
				sum(tableTransaksi.resep) as resep,
				sum(tableTransaksi.resep_retur) as resep_retur,
				sum(tableTransaksi.jual) as jual,
				sum(tableTransaksi.jual_retur) as jual_retur,
				sum(tableTransaksi.tambil) as tambil,
				sum(tableTransaksi.akhir) as akhir
		FROM	rsfPelaporan.laporan_so_trx tableTransaksi,
				(
					select		case depo_nama 	when 'anggrek' then '101030106'
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
								else '00000000' end as ruangan_kode,
								depo_nama,
								katalog_id,
								katalog_kode as katalog_kode_asal,
								koreksi_kode as katalog_kode_koreksi,
								case COALESCE(koreksi_kode, '')
									when '' then katalog_kode
									else koreksi_kode end as katalog_kode,
								katalog_nama as katalog_nama_asal,
								koreksi_kode2 as koreksi_tambahan,
								koreksi_keterangan
						from	laporan_so_depo
						-- where   koreksi_kode <> '.GHE' and koreksi_kode <> '.PINJAM' and koreksi_kode <> '0000000'
						--		and koreksi_kode <> '.BILLING' and koreksi_kode <> '.TAMBIL' and
						--		koreksi_kode2 <> '.GHE' and koreksi_kode2 <> '.PINJAM' and koreksi_kode2 <> '0000000'
						--		and koreksi_kode2 <> '.BILLING' and koreksi_kode2 <> '.TAMBIL'
						order   by case COALESCE(koreksi_kode, '')
									when '' then katalog_kode
									else koreksi_kode end
				) laporanSOdepoREKON
				left outer join (
					select 		*
						from 	rsfPelaporan.laporan_so_grp
				) laporanKatalogGrp
				on  laporanKatalogGrp.katalog_kode = laporanSOdepoREKON.katalog_kode
				left outer join (
					select * from inventory.barang where id in 
					(select min(id) from inventory.barang where KODE_BARANG is not null group by KODE_BARANG)
				) barang
					on barang.KODE_BARANG = laporanKatalogGrp.katalog_kode_grp
				left outer join inventory.satuan msatuan ON msatuan.ID = barang.SATUAN
				left outer join (select * from master.referensi where JENIS = 39) mreff on barang.MERK = mreff.ID
		WHERE	laporanSOdepoREKON.ruangan_kode = tableTransaksi.depo_kode and
				laporanSOdepoREKON.katalog_id = tableTransaksi.katalog_id
		GROUP   BY  laporanKatalogGrp.katalog_kode_grp
