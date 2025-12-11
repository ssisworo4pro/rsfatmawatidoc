DROP TRIGGER layanan.onAfterUpdateTindakanMedisToLis; 
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER layanan.onAfterUpdateTindakanMedisToLis
    AFTER UPDATE
    ON layanan.tindakan_medis FOR EACH ROW
BEGIN
    -- statements
	IF LEFT(NEW.KUNJUNGAN,7) = '1010701' THEN
		IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN			
			UPDATE lis_bridging.ordered_item B
			SET B.sts_delete = '1'
			WHERE NEW.KUNJUNGAN=B.order_number
			AND NEW.TINDAKAN=B.order_item_id;
			insert into lis_bridging.ordered_item_batal 
						( 	order_number, order_item_id, order_item_name, 
							order_item_datetime, sts_post, sts_delete, sysdatetime	)
			select		NEW.KUNJUNGAN as order_number,
						NEW.TINDAKAN as order_item_id,
						substring(mTind.NAMA,1,50) as order_item_name,
						NEW.TANGGAL as order_item_datetime,
						0 as sts_post,
						1 as sts_delete,
						current_timestamp() as sysdatetime
				from	master.tindakan mTind 
						join lis_bridging.ordered_item tOrder
						on 	tOrder.order_number 		= NEW.KUNJUNGAN and
							tOrder.order_item_id 		= NEW.TINDAKAN and
							tOrder.order_item_datetime	= NEW.TANGGAL
				where 	mTind.ID  = NEW.TINDAKAN;
		END IF;
	END IF;
END$$    
DELIMITER ;
