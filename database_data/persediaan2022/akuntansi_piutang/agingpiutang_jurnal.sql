-- select * from TGLD_JURNAL_DETAIL where NO_DOKUMEN = '003/CL/02/20';
-- select * from dbo.MGLD_COA where NO_COA = '115602              ';
-- select * from dbo.MGLD_BBESAR where NO_COA = '115602              ';

select      MAX(TGLD_JURNAL_DETAIL.NO_DOKUMEN) as NO_DOKUMEN,
                    MAX(TGLD_JURNAL.TGL_JURNAL) as TGL_JURNAL,
                    MAX(TGLD_JURNAL_DETAIL.KETERANGAN) as KETERANGAN,
                    MAX(MGLD_BBESAR.DESKRIPSI) as COA_DESKRIPSI,
                    MAX(TGLD_JURNAL_DETAIL.NO_COA) as NO_COA,
                    MAX(MGLD_BTAMBAHAN_DETAIL.KD_BTAMBAHAN) as KD_BTAMBAHAN,
                    MAX(MGLD_BTAMBAHAN_DETAIL.NO_COABT) as NO_COABT,
                    MAX(MGLD_BTAMBAHAN_DETAIL.DESKRIPSI) as PERUSAHAAN,
                    SUM(TGLD_JURNAL_DETAIL.NILAI * CHARINDEX(TGLD_JURNAL_DETAIL.DEBET_KREDIT, MGLD_BBESAR.DEBET_KREDIT)) as PIUTANG,
                    SUM(TGLD_JURNAL_DETAIL.NILAI * (CHARINDEX(TGLD_JURNAL_DETAIL.DEBET_KREDIT, MGLD_BBESAR.DEBET_KREDIT) - 1 ) * -1 ) as BAYAR,
                    SUM(TGLD_JURNAL_DETAIL.NILAI * (CHARINDEX(TGLD_JURNAL_DETAIL.DEBET_KREDIT,'9' + MGLD_BBESAR.DEBET_KREDIT) - 1 )) as SISA_PIUTANG,
                    sum(1) as QTY_TRX
            from    TGLD_JURNAL_DETAIL,
                    TGLD_JURNAL,
                    MGLD_BBESAR,
                    MGLD_BTAMBAHAN_DETAIL
            where   TGLD_JURNAL_DETAIL.NO_JURNAL    = TGLD_JURNAL.NO_JURNAL AND
                    MGLD_BBESAR.NO_COA              = TGLD_JURNAL_DETAIL.NO_COA AND
                    TGLD_JURNAL_DETAIL.KD_BTAMBAHAN = MGLD_BTAMBAHAN_DETAIL.KD_BTAMBAHAN AND
                    TGLD_JURNAL_DETAIL.NO_COABT     = MGLD_BTAMBAHAN_DETAIL.NO_COABT AND
                    ( 
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2131' OR
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2132' OR
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2133' OR
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2134' OR
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2135' OR
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2136' OR
                    	TGLD_JURNAL_DETAIL.NO_COA       = '2137' ) AND
                    TGLD_JURNAL_DETAIL.KD_BTAMBAHAN     = 'V' AND
                    -- TGLD_JURNAL_DETAIL.NO_COABT     = 'A055' AND
                    TGLD_JURNAL.TGL_JURNAL          < dateadd(day,1,'2022-12-31') AND
                    TGLD_JURNAL.TGL_JURNAL         >= dateadd(year,-7,dateadd(day,1,'2022-12-31'))
        GROUP BY    TGLD_JURNAL_DETAIL.NO_DOKUMEN,
                    TGLD_JURNAL_DETAIL.NO_COA,
                    TGLD_JURNAL_DETAIL.KD_BTAMBAHAN,
                    TGLD_JURNAL_DETAIL.NO_COABT
        HAVING      SUM(TGLD_JURNAL_DETAIL.NILAI * (CHARINDEX(TGLD_JURNAL_DETAIL.DEBET_KREDIT,'9' + MGLD_BBESAR.DEBET_KREDIT) - 1 )) > 0 
