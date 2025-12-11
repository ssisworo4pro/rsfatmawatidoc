alter table laporan_opname add jumlah_fisik_hitung decimal(20,4) null;
update laporan_opname set jumlah_fisik_hitung = 0;
ALTER TABLE laporan_opname modify jumlah_fisik_hitung decimal(20,4) null;

UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '10P227' WHERE katalog_kode = '10P115';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '10V136' WHERE katalog_kode = '10V132';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '14F016' WHERE katalog_kode = '14A026';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '22C010' WHERE katalog_kode = '22C017';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '40D091' WHERE katalog_kode = '40E023';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80B112' WHERE katalog_kode = '80B120';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80B112' WHERE katalog_kode = '80I108';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80D172' WHERE katalog_kode = '80D010.01';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80L058' WHERE katalog_kode = '10918';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80M233' WHERE katalog_kode = '22M074';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80M247.1' WHERE katalog_kode = '80N010';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80N156' WHERE katalog_kode = '80N108';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80M246.1' WHERE katalog_kode = '80O016.13';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80F123.1' WHERE katalog_kode = '80P129';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80M246.1' WHERE katalog_kode = '80S344';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '90L018' WHERE katalog_kode = '90L022';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '90P095' WHERE katalog_kode = '90S005';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '90P097' WHERE katalog_kode = '90S007';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '10A285' WHERE katalog_kode = '10K021';

UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80E162' WHERE katalog_kode = '80E142';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80E163' WHERE katalog_kode = '80E143';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80E161' WHERE katalog_kode = '80E144';
UPDATE rsfPelaporan.laporan_mutasi_saldo_simgos SET katalog_kode_grp = '80E013.1' WHERE katalog_kode = '80E156';
