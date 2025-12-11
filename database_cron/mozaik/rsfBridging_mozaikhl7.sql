DROP PROCEDURE IF EXISTS rsfBridging.mozaikhl7;
DELIMITER //
CREATE PROCEDURE rsfBridging.mozaikhl7()
BEGIN
	SELECT 		-- if(dataMozaik.data is null, 20001, 1) as xstatcode,
				1 as statcode,
				if(dataMozaik.data is null, 0, 1) as rowcount,
				if(dataMozaik.data is null, 'data kosong', 'data siap kirim') as message,
				ifnull(dataMozaik.data,'{"row":0}') as data
		FROM 	(select 1 as id) satusatu
				left join
				(
					select 		1 as id,
								CONCAT('{',
								CONCAT('"row"  : ', count(1), ','),
								CONCAT('"msh"  : "SIMRSGOS2|RSFATMAWATI|MOZAIK|RSFATMAWATI|', DATE_FORMAT(CURRENT_TIMESTAMP(),'%Y%m%d%H%i') ,'|-|ADT^A04|1|1|2.5|2.0|', tMozaik.norm, '|", '),
								CONCAT('"data" : ["PID||', 
										tMozaik.norm, '|||', 
										tMozaik.nama, '||',
										concat(YEAR(tMozaik.tgl_lahir), RIGHT(CONCAT('00',MONTH(tMozaik.tgl_lahir)),2), RIGHT(CONCAT('00',DAY(tMozaik.tgl_lahir)),2)), '|',
										if ( tMozaik.jns_kelamin = 1, 'M', 'F'), '|||',
										tMozaik.alamat, '|"]' 
								)
								,'}') as data
						from 	rsfBridging.tmozaik_pasien tMozaik
						where	tMozaik.send_sts = 0
						limit 1
				) dataMozaik
				on satusatu.id = dataMozaik.id;
END //
DELIMITER ;
