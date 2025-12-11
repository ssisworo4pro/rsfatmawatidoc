DROP TRIGGER layanan.trg_layanan_order_lab; 
DELIMITER $$
CREATE TRIGGER layanan.trg_layanan_order_lab
    AFTER UPDATE
    ON layanan.order_lab FOR EACH ROW
BEGIN
    -- statements
	IF ((NEW.STATUS = 2) and (OLD.TUJUAN = '101130101')) THEN
		call rsfPelaporan.orderlabTerimaUTD('obj',OLD.NOMOR);
	END IF;
END$$    

DELIMITER ;
