drop table if exists rsfPelaporan.dlap_persediaan_trmrkndtl_hist;
drop table if exists rsfPelaporan.dlap_persediaan_trmrkn_hist;
drop table if exists rsfPelaporan.dlap_persediaan_trmrkndtl;
drop table if exists rsfPelaporan.dlap_persediaan_trmrkn;

drop table if exists rsfPelaporan.dlap_persediaan_hist;
drop table if exists rsfPelaporan.dlap_persediaan;

drop table if exists rsfPelaporan.dlap_persediaan_sodtl_hist;
drop table if exists rsfPelaporan.dlap_persediaan_so_hist;
drop table if exists rsfPelaporan.dlap_persediaan_sodtl;
drop table if exists rsfPelaporan.dlap_persediaan_so;

drop table if exists rsfPelaporan.mlap_persediaan;
drop table if exists rsfPelaporan.slap_persediaan_proses;
drop table if exists rsfPelaporan.slap_persediaan;

----------------------------------------------------------

create table rsfPelaporan.slap_persediaan
(
   id_proses            bigint not null auto_increment,
   tanggal_proses       datetime not null,
   bulan                char(6) not null,
   primary key (id_proses)
);

create table rsfPelaporan.slap_persediaan_proses
(
   id_proses            bigint not null,
   id_jenis             integer not null,
   proses_status        integer not null,
   prosesh_rowsumber    bigint not null,
   prosesh_rowdata      bigint not null,
   prosesd_rowsumber    bigint not null,
   prosesd_rowdata      bigint not null,
   prosesd_trxsumber    decimal(20,4) not null,
   prosesd_trxdata      decimal(20,4) not null,
   prosesd_kasus1row    bigint not null,
   prosesd_kasus1trx    decimal(20,4) not null,
   prosesd_kasus2row    bigint not null,
   prosesd_kasus2trx    decimal(20,4) not null,
   primary key (id_proses, id_jenis)
);

alter table rsfPelaporan.slap_persediaan_proses add constraint fk_slap_persediaan_proses_1 foreign key (id_proses)
      references rsfPelaporan.slap_persediaan (id_proses) on delete restrict on update restrict;
	  
create table rsfPelaporan.mlap_persediaan
(
   trx_jenis            integer not null,
   trx_jenis_sub        integer not null,
   trx_nama             varchar(50) not null,
   trxsub_nama          varchar(50) not null,
   trx_tambahkurang     char(1) not null,
   klp_pengali          integer not null,
   klp_kolomupd         varchar(32) not null,
   klp_kolomupd_depo    varchar(32) not null,
   primary key (trx_jenis, trx_jenis_sub)
);

--------------------------------------------------------- STOK OP NAME

create table rsfPelaporan.dlap_persediaan_so
(
   id_opname            bigint not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   tanggal              datetime not null,
   sysdate_in           datetime not null,
   depo_kode            char(10) not null,
   depo_nama            varchar(50) not null,
   kategori             varchar(10),
   status               varchar(15) not null,
   trx_jenis            integer not null,
   trx_nama             varchar(50) not null,
   trx_tambahkurang     char(1) not null,
   primary key (id_opname)
);
create index idx_dlap_persediaan_so_1 on rsfPelaporan.dlap_persediaan_so
(
   id_proses
);
create index idx_dlap_persediaan_so_2 on rsfPelaporan.dlap_persediaan_so
(
   bulan
);
alter table rsfPelaporan.dlap_persediaan_so add constraint fk_dlap_persediaan_so_1 foreign key (id_proses)
      references rsfPelaporan.slap_persediaan (id_proses) on delete restrict on update restrict;
	  
create table rsfPelaporan.dlap_persediaan_sodtl
(
   id_opname_dtl        bigint not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   id_opname            bigint not null,
   id_transaksi         varchar(23),
   tanggal              date,
   expired              date,
   katalog_id           bigint not null,
   katalog_kode         varchar(15) not null,
   katalog_nama         varchar(150) not null,
   kateg_kode           varchar(10) not null,
   kateg_nama           varchar(150) not null,
   jml_opname           decimal(20,4) not null,
   jml_trxruangan       decimal(20,4) not null,
   primary key (id_opname_dtl)
);
create index idx_dlap_persediaan_sodtl_1 on rsfPelaporan.dlap_persediaan_sodtl
(
   bulan
);

alter table rsfPelaporan.dlap_persediaan_sodtl add constraint fk_dlap_persediaan_sodtl_1 foreign key (id_opname)
      references rsfPelaporan.dlap_persediaan_so (id_opname) on delete restrict on update restrict;

create table rsfPelaporan.dlap_persediaan_so_hist
(
   id_opname            bigint not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   tanggal              datetime not null,
   sysdate_in           datetime not null,
   depo_kode            char(10) not null,
   depo_nama            varchar(50) not null,
   kategori             varchar(10),
   status               varchar(15) not null,
   trx_jenis            integer not null,
   trx_nama             varchar(50) not null,
   trx_tambahkurang     char(1) not null,
   primary key (id_opname, id_proses)
);

create table rsfPelaporan.dlap_persediaan_sodtl_hist
(
   id_opname_dtl        bigint not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   id_opname            bigint not null,
   id_transaksi         varchar(23),
   tanggal              date,
   expired              date,
   katalog_id           bigint not null,
   katalog_kode         varchar(15) not null,
   katalog_nama         varchar(150) not null,
   kateg_kode           varchar(10) not null,
   kateg_nama           varchar(150) not null,
   jml_opname           decimal(20,4) not null,
   jml_trxruangan       decimal(20,4) not null,
   primary key (id_opname_dtl, id_proses)
);

--------------------------------------------------------- PENERIMAAN REKANAN

create table rsfPelaporan.dlap_persediaan_trmrkn
(
   id_penerimaan        bigint unsigned not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   depo_kode            char(10) not null,
   depo_nama            varchar(50),
   NO_SP                char(30) not null,
   FAKTUR               varchar(50) not null,
   TANGGAL              datetime not null comment 'Tanggal Faktur',
   TANGGAL_PENERIMAAN   datetime comment 'Tanggal Penerimaan Barang',
   rekanan_id           bigint,
   rekanan_nama         varchar(250),
   KETERANGAN           varchar(250) not null,
   PPN                  enum('ya','tidak') not null,
   SUMBER_DANA          bigint not null,
   MASA_BERLAKU         date,
   TANGGAL_DIBUAT       datetime not null comment 'Tanggal di input',
   OLEH                 integer not null,
   STATUS               integer not null default 1,
   JENIS                integer not null default 1 comment '1 = penerimaan eksternal, 2 = penerimaan PO',
   REF_PO               char(15) not null,
   primary key (id_penerimaan)
);
create index idx_dlap_persediaan_trmrkn_1 on rsfPelaporan.dlap_persediaan_trmrkn
(
   id_proses
);
create index idx_dlap_persediaan_trmrkn_2 on rsfPelaporan.dlap_persediaan_trmrkn
(
   bulan
);
alter table rsfPelaporan.dlap_persediaan_trmrkn add constraint fk_dlap_persediaan_trmrkn_1 foreign key (id_proses)
      references rsfPelaporan.slap_persediaan (id_proses) on delete restrict on update restrict;


create table rsfPelaporan.dlap_persediaan_trmrkndtl
(
   id_penerimaan_dtl    bigint not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   id_penerimaan        bigint unsigned not null,
   BARANG               bigint not null,
   NO_BATCH             varchar(50) not null,
   JUMLAH               decimal(20,4) not null,
   jml_trxruangan       decimal(20,4) not null,
   JUMLAH_BESAR         decimal(20,4) not null,
   JUMLAH_KECIL         decimal(20,4) not null,
   BONUS                decimal(20,4) not null,
   HARGA                decimal(20,4) not null,
   HARGA_BESAR          decimal(20,4) not null,
   DISKON               decimal(20,4) not null,
   DISKON_P             decimal(20,4) not null,
   ONGKIR               decimal(20,4) not null,
   MASA_BERLAKU         date comment 'Tanggal Berakhir / Expire',
   STATUS               integer not null default 1,
   REF_PO_DETIL         bigint not null,
   primary key (id_penerimaan_dtl)
);
alter table rsfPelaporan.dlap_persediaan_trmrkndtl add constraint fk_dlap_persediaan_trmrkndtl_1 foreign key (id_penerimaan)
      references rsfPelaporan.dlap_persediaan_trmrkn (id_penerimaan) on delete restrict on update restrict;

create table rsfPelaporan.dlap_persediaan_trmrkn_hist
(
   id_penerimaan        bigint unsigned not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   depo_kode            char(10) not null,
   depo_nama            varchar(50),
   NO_SP                char(30) not null,
   FAKTUR               varchar(50) not null,
   TANGGAL              datetime not null comment 'Tanggal Faktur',
   TANGGAL_PENERIMAAN   datetime comment 'Tanggal Penerimaan Barang',
   rekanan_id           bigint,
   rekanan_nama         varchar(250),
   KETERANGAN           varchar(250) not null,
   PPN                  enum('ya','tidak') not null,
   SUMBER_DANA          bigint not null,
   MASA_BERLAKU         date,
   TANGGAL_DIBUAT       datetime not null comment 'Tanggal di input',
   OLEH                 integer not null,
   STATUS               integer not null default 1,
   JENIS                integer not null default 1 comment '1 = penerimaan eksternal, 2 = penerimaan PO',
   REF_PO               char(15) not null,
   primary key (id_penerimaan, id_proses)
);

create table rsfPelaporan.dlap_persediaan_trmrkndtl_hist
(
   id_penerimaan_dtl    bigint not null,
   id_proses            bigint not null,
   bulan                char(6) not null,
   id_penerimaan        bigint unsigned not null,
   BARANG               bigint not null,
   NO_BATCH             varchar(50) not null,
   JUMLAH               decimal(20,4) not null,
   jml_trxruangan       decimal(20,4) not null,
   JUMLAH_BESAR         decimal(20,4) not null,
   JUMLAH_KECIL         decimal(20,4) not null,
   BONUS                decimal(20,4) not null,
   HARGA                decimal(20,4) not null,
   HARGA_BESAR          decimal(20,4) not null,
   DISKON               decimal(20,4) not null,
   DISKON_P             decimal(20,4) not null,
   ONGKIR               decimal(20,4) not null,
   MASA_BERLAKU         date comment 'Tanggal Berakhir / Expire',
   STATUS               integer not null default 1,
   REF_PO_DETIL         bigint not null,
   primary key (id_penerimaan_dtl, id_proses, bulan)
);

--------------------------------------------------------- PERSEDIAAN

create table rsfPelaporan.dlap_persediaan
(
   bulan                char(6) not null,
   depo_kode            char(10) not null,
   trx_jenis            integer not null comment 'Jenis Transaksi Stok',
   trx_jenis_sub        integer not null,
   katalog_id           bigint not null,
   id_proses            bigint not null,
   depo_nama            varchar(50) not null,
   trx_nama             varchar(50) not null,
   trx_tambahkurang     char(1) not null,
   trxsub_nama          varchar(50),
   kateg_kode           char(10) not null,
   kateg_nama           varchar(150) not null,
   katalog_kode         varchar(15) not null,
   katalog_nama         varchar(150) not null,
   jml_rowtrxpersediaan bigint not null,
   jml_trxpersediaan    decimal(20,4) not null,
   jml_rowtrxruangan    bigint not null,
   jml_trxruangan       decimal(20,4) not null,
   primary key (bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id)
);
create index idx_dlap_persediaan_1 on rsfPelaporan.dlap_persediaan
(
   id_proses,
   trx_jenis
);
create index idx_dlap_persediaan_2 on rsfPelaporan.dlap_persediaan
(
   bulan,
   trx_jenis
);
alter table rsfPelaporan.dlap_persediaan add constraint fk_dlap_persediaan_1 foreign key (id_proses)
      references rsfPelaporan.slap_persediaan (id_proses) on delete restrict on update restrict;

create table rsfPelaporan.dlap_persediaan_hist
(
   bulan                char(6) not null,
   depo_kode            char(10) not null,
   trx_jenis            integer not null comment 'Jenis Transaksi Stok',
   trx_jenis_sub        integer not null,
   katalog_id           bigint not null,
   id_proses            bigint not null,
   depo_nama            varchar(50) not null,
   trx_nama             varchar(50) not null,
   trx_tambahkurang     char(1) not null,
   trxsub_nama          varchar(50) not null,
   kateg_kode           char(10) not null,
   kateg_nama           varchar(150) not null,
   katalog_kode         varchar(15) not null,
   katalog_nama         varchar(150) not null,
   jml_rowtrxpersediaan bigint not null,
   jml_trxpersediaan    decimal(20,4) not null,
   jml_rowtrxruangan    bigint not null,
   jml_trxruangan       decimal(20,4) not null,
   primary key (bulan, depo_kode, trx_jenis, trx_jenis_sub, katalog_id, id_proses)
);

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

drop table if exists rsfPelaporan.laporan_mutasi_bulan;
create table rsfPelaporan.laporan_mutasi_bulan
(
   bulan                int not null,
   tahun                int not null,
   id_katalog           varchar(15) not null,
   kode_barang          varchar(15),
   nama_barang          varchar(255) not null,
   id_jenisbarang       int not null,
   kode_jenis           varchar(15) not null,
   nama_jenis           varchar(255) not null,
   id_kelompokbarang    int not null,
   kode_kelompok        varchar(15) not null,
   nama_kelompok        varchar(255) not null,
   tgl_create_katalog   datetime,
   jumlah_awal          decimal(20,4) not null default 0.0000,
   harga_awal           decimal(20,4) not null default 0.0000,
   nilai_awal           decimal(20,4) not null default 0.0000,
   tgl_updt_awal        datetime,
   jumlah_pembelian     decimal(20,4) not null default 0.0000,
   nilai_pembelian      decimal(20,4) not null default 0.0000,
   tgl_updt_pembelian   datetime,
   jumlah_hasilproduksi decimal(20,4) not null default 0.0000,
   nilai_hasilproduksi  decimal(20,4) not null default 0.0000,
   tgl_updt_hasilproduksi varchar(45),
   jumlah_koreksi       decimal(20,4) not null default 0.0000,
   nilai_koreksi        decimal(20,4) not null default 0.0000,
   tgl_updt_koreksi     datetime,
   jumlah_penjualan     decimal(20,4) not null default 0.0000,
   nilai_penjualan      decimal(20,4) not null default 0.0000,
   tgl_updt_penjualan   datetime,
   jumlah_floorstok     decimal(20,4) not null default 0.0000,
   nilai_floorstok      decimal(20,4) not null default 0.0000,
   tgl_updt_floorstok   datetime,
   jumlah_bahanproduksi decimal(20,4) not null default 0.0000,
   nilai_bahanproduksi  decimal(20,4) not null default 0.0000,
   tgl_updt_bahanproduksi datetime,
   jumlah_rusak         decimal(20,4) not null default 0.0000,
   nilai_rusak          decimal(20,4) not null default 0.0000,
   tgl_updt_rusak       datetime,
   jumlah_expired       decimal(20,4) not null default 0.0000,
   nilai_expired        decimal(20,4) not null default 0.0000,
   tgl_updt_expired     datetime,
   jumlah_returpembelian decimal(20,4) not null default 0.0000,
   nilai_returpembelian decimal(20,4) not null default 0.0000,
   tgl_updt_returpembelian datetime,
   jumlah_koreksipenerimaan decimal(20,4) not null default 0.0000,
   nilai_koreksipenerimaan decimal(20,4) not null default 0.0000,
   tgl_updt_koreksipenerimaan datetime,
   jumlah_revisipenerimaan decimal(20,4) not null default 0.0000,
   nilai_revisipenerimaan decimal(20,4) not null default 0.0000,
   tgl_updt_revisipenerimaan datetime,
   jumlah_adjustment    decimal(20,4) not null default 0.0000,
   nilai_adjustment     decimal(20,4) not null default 0.0000,
   tgl_updt_adjusment   datetime,
   jumlah_tidakterlayani decimal(20,4) not null default 0.0000,
   tgl_updt_tidakterlayani datetime,
   jumlah_akhir         decimal(20,4) not null default 0.0000,
   harga_akhir          decimal(20,4) not null default 0.0000,
   nilai_akhir          decimal(20,4) not null default 0.0000,
   tgl_updt_akhir       datetime,
   jumlah_lainnya       decimal(20,4) not null,
   harga_lainnya        decimal(20,4) not null,
   nilai_lainnya        decimal(20,4) not null,
   tgl_updt_lainnya     datetime,
   jumlah_opname        decimal(20,4) not null,
   harga_opname         decimal(20,4) not null,
   nilai_opname         decimal(20,4) not null,
   tgl_updt_opname      datetime,
   userid_in            int default 1,
   sysdate_in           datetime,
   userid_updt          int default 1,
   sysdate_updt         timestamp default CURRENT_TIMESTAMP,
   primary key (bulan, tahun, id_katalog)
);

-- ===============================================================================
drop table if exists rsfPelaporan.mlap_katalog_harga;
drop table if exists rsfPelaporan.mlap_katalog;

create table rsfPelaporan.mlap_katalog
(
   katalog_id           bigint not null,
   katalog_kode         varchar(15),
   katalog_nama         varchar(150),
   kateg_kode           varchar(15),
   kateg_nama           varchar(150),
   harga_perolehan_akhir decimal(20,4),
   primary key (katalog_id)
);
create table rsfPelaporan.mlap_katalog_harga
(
   katalog_id           bigint not null,
   katalog_tanggal      date not null,
   penerimaan_dtl_id    bigint not null,
   katalog_qty          decimal(20,4) not null,
   katalog_harga        decimal(20,4) not null,
   katalog_discount     decimal(20,4) not null,
   katalog_hargadiscount decimal(20,4) not null,
   katalog_ppn          decimal(20,4) not null,
   katalog_hargaperolehan decimal(20,4) not null,
   primary key (katalog_id, katalog_tanggal, penerimaan_dtl_id)
);
alter table rsfPelaporan.mlap_katalog_harga add constraint fk_mlap_katalog_harga_1 foreign key (katalog_id)
      references rsfPelaporan.mlap_katalog (katalog_id) on delete restrict on update restrict;
