DROP PROCEDURE IF EXISTS rsfPelaporan.proc_rsff_masterupdate;
DELIMITER //
CREATE PROCEDURE rsfPelaporan.proc_rsff_masterupdate(
	aTableName VARCHAR(32),
	aJsonData TEXT
)
BEGIN
	DECLARE vJsonLength BIGINT;
	DECLARE vJsonKey TEXT;
	DECLARE vJsonKeyLength BIGINT;
	DECLARE vCounter BIGINT;
	DECLARE vCounterData BIGINT;
	DECLARE vQueryKey VARCHAR(1024);
	DECLARE vQUERY VARCHAR(1024);

	START TRANSACTION;
		SET vJsonLength 		= JSON_LENGTH(aJsonData);
		IF (vJsonLength > 0) THEN
			SET vJsonKey    	= JSON_KEYS(JSON_EXTRACT(aJsonData,'$[0]'));
			SET vJsonKeyLength	= JSON_LENGTH(JSON_KEYS(JSON_EXTRACT(aJsonData,'$[0]')));
			
			-- loop key
			SET vCounter = 0;
			SET vQueryKey			= CONCAT('insert into ', aTableName, ' (');
			WHILE vCounter < vJsonKeyLength DO
				IF (vCounter > 0) THEN
					SET vQueryKey	= CONCAT(vQueryKey, ', ');
				END IF;
				SET vQueryKey		= REPLACE(CONCAT(vQueryKey, JSON_EXTRACT(vJsonKey, CONCAT('$[',vCounter,']'))),'"','');
				SET vCounter		= vCounter + 1;
			END WHILE;
			SET vQueryKey			= CONCAT(vQueryKey, ') values (');

			SET vCounterData = 0;
			WHILE vCounterData < vJsonLength DO
				-- loop value
				SET @vQuery = vQueryKey;
				SET vCounter = 0;
				WHILE vCounter < vJsonKeyLength DO
					IF (vCounter > 0) THEN
						SET @vQuery	= CONCAT(@vQuery, ', ');
					END IF;
					SET @vQuery		= CONCAT(@vQuery, JSON_EXTRACT(JSON_EXTRACT(aJsonData, CONCAT('$[',vCounterData,']') ), CONCAT('$.',JSON_EXTRACT(vJsonKey, CONCAT('$[',vCounter,']')))));
					SET vCounter	= vCounter + 1;
				END WHILE;
				SET @vQuery			= CONCAT(@vQuery, ')');
				
				PREPARE stmt1 FROM @vQuery;
				EXECUTE stmt1;
				-- SELECT @vQuery;
				SET vCounterData	= vCounterData + 1;
			END WHILE;
		END IF;
		select vJsonLength as rowinserted;
	COMMIT;
END //
DELIMITER ;
