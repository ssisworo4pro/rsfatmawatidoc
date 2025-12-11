-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.28 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for bios
CREATE DATABASE IF NOT EXISTS `bios` /*!40100 DEFAULT CHARACTER SET latin1 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `bios`;

-- Dumping structure for procedure bios.SpSdm
DELIMITER //
CREATE PROCEDURE `SpSdm`()
BEGIN
	DECLARE VPNS INT;
	DECLARE VPPPK INT;
	DECLARE VNONPNSTETAP INT;
	DECLARE VKONTRAK INT;
	DECLARE VJENIS INT;
	
	DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
	DECLARE DATA_SDM CURSOR FOR
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '1' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '2'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '2' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '1'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '3' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '3'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '4' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '13'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '5' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '10'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '6' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '7'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '7' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '8'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '8' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '5'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '9' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '4'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '10' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '6'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '11' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '14'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '12' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '11'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '13' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '12'
		 AND mr.JENIS ='88'
		 UNION 
		SELECT DISTINCT sum(if(sp.STATUS_PEGAWAI in('1','2'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('13'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('4'),'1','0'))
		, sum(if(sp.STATUS_PEGAWAI in('7','8','9','10','11','14'),'1','0'))
		, '14' jenis
		 FROM `master`.pegawai mp
		 LEFT JOIN `pegawai`.status_pegawai  sp on mp.NIP = sp.NIP
		 LEFT JOIN `master`.referensi mr on sp.STATUS_PEGAWAI = mr.ID
		 WHERE mp.STATUS = '1'
		 AND mp.FLAGBIOS = '9'
		 AND mr.JENIS ='88';
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
	OPEN DATA_SDM;
	EOF: LOOP
		FETCH DATA_SDM INTO VPNS, VPPPK, VNONPNSTETAP, VKONTRAK, VJENIS;
		
		IF DATA_NOT_FOUND THEN
			LEAVE EOF;
		END IF;
		
		INSERT INTO `bios`.sdm(pns, pppk, non_pns_tetap, kontrak, jenis, send)
			VALUES (VPNS, VPPPK, VNONPNSTETAP, VKONTRAK, VJENIS, 1);

	END LOOP;
	CLOSE DATA_SDM;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
