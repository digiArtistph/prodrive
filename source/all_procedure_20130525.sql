-- MySQL dump 10.13  Distrib 5.5.24, for Win32 (x86)
--
-- Host: localhost    Database: prodrivedb
-- ------------------------------------------------------
-- Server version	5.5.24-log
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'prodrivedb'
--
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_addDCRDetails`(IN pParticular VARCHAR(255), IN pTender INT, IN pRefno VARCHAR(75), IN pAmnt DECIMAL(8,2), IN pID INT, IN pStatus INT)
BEGIN

  IF pStatus = 1 THEN
    INSERT INTO tmptblDCRDetails
      SET particular = pParticular,
          tender = pTender,
          refno = pRefno,
          amnt = pAmnt,
          id = pID;
  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_dropTmpTblDCRDetails`(OUT pSuccess INT)
BEGIN
  /* drops the tmptblDCRDetails temporary table */
  DROP TEMPORARY TABLE tmptblDCRDetails;
  SET pSuccess = 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editjoborder`(
IN 	m_v_id   		INT,
IN 	m_v_name 		VARCHAR(12),
IN	m_clr_id		INT,
IN	m_clr_name		VARCHAR(12),
IN 	m_customer 	INT,
IN	m_plate		VARCHAR(50),
IN	m_contactnum	VARCHAR(75),
IN	m_address		TEXT,
IN	m_trnxdate	DATE,
IN 	o_jo_id		INT,
INOUT	flag		INT
)
BEGIN

DECLARE status INT DEFAULT 0;
DECLARE v_last_id INT DEFAULT 0;
DECLARE c_last_id INT DEFAULT 0;
DECLARE EXIT handler for sqlexception set flag = 1;

IF NOT EXISTS(SELECT `v_id` FROM `vehicle` WHERE `v_id` = `m_v_id`) 
    THEN
	INSERT INTO `vehicle` set `make`=m_v_name, `status`=1;
	SET v_last_id = LAST_INSERT_ID();
	
	IF NOT EXISTS(SELECT `clr_id` FROM `color` WHERE `clr_id` = `m_clr_id`) 
    		THEN
			INSERT INTO `color` set `name`=m_clr_name;
			SET c_last_id = LAST_INSERT_ID();
			UPDATE `joborder` set `v_id`=v_last_id, `customer`=m_customer, `plate`=m_plate, `color`=c_last_id, `contactnumber`=m_contactnum, `address`=m_address, `trnxdate`=m_trnxdate WHERE `jo_id`=o_jo_id;

	ELSE
		UPDATE `joborder` set `v_id`=v_last_id, `customer`=m_customer, `plate`=m_plate, `color`=m_clr_id, `contactnumber`=m_contactnum, `address`=m_address, `trnxdate`=m_trnxdate WHERE `jo_id`=o_jo_id;
	END IF;

ELSE
	IF EXISTS(SELECT `clr_id` FROM `color` WHERE `clr_id` = `m_clr_id`) 
    		THEN
			UPDATE `joborder` set `v_id`=m_v_id, `customer`=m_customer, `plate`=m_plate, `color`=m_clr_id, `contactnumber`=m_contactnum, `address`=m_address, `trnxdate`=m_trnxdate WHERE `jo_id`=o_jo_id;
	ELSE
		INSERT INTO `color` set `name`=m_clr_name;
		SET c_last_id = LAST_INSERT_ID();
		UPDATE `joborder` set `v_id`=m_v_id, `customer`=m_customer, `plate`=m_plate, `color`=c_last_id, `contactnumber`=m_contactnum, `address`=m_address, `trnxdate`=m_trnxdate WHERE `jo_id`=o_jo_id;
	END IF;

    
END IF;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editjoborderdet`(
IN 	m_jo_id			INT,
IN 	m_labor 		TEXT,
IN	m_partmaterial		VARCHAR(50),
IN 	m_details 		TEXT,
IN	m_laboramnt 		DECIMAL(8,2),
IN	m_partmaterialamnt 	DECIMAL(8,2),
IN	m_status 		INT,
INOUT 	flag	INT
)
BEGIN

DECLARE stat INT;
DECLARE lt_last_id INT DEFAULT 0;
DECLARE EXIT handler for SQLEXCEPTION set flag = 1;

	SET stat = m_status + 1; 
	
	
	IF NOT EXISTS(SELECT * FROM `labortype` WHERE `name`=m_labor) 
		THEN
			IF (m_labor REGEXP '[0]'= 1)
				THEN
					INSERT INTO `jodetails` SET `jo_id`=m_jo_id, `labor`=m_labor, `partmaterial`=m_partmaterial, `details`=m_details, `laboramnt`=m_laboramnt, `partmaterialamnt`=m_partmaterialamnt, `status`=stat;
			ELSE
				INSERT INTO `labortype` SET `name`=m_labor, `category`="0", `status`="1";
 				SET lt_last_id = LAST_INSERT_ID();

				INSERT INTO `jodetails` SET `jo_id`=m_jo_id, `labor`=lt_last_id, `partmaterial`=m_partmaterial, `details`=m_details, `laboramnt`=m_laboramnt, `partmaterialamnt`=m_partmaterialamnt, `status`=stat;
			END IF;
			
	ELSE
		SET lt_last_id = (SELECT `laborid` FROM `labortype` WHERE `name`=m_labor);
		INSERT INTO `jodetails` SET `jo_id`=m_jo_id, `labor`=lt_last_id, `partmaterial`=m_partmaterial, `details`=m_details, `laboramnt`=m_laboramnt, `partmaterialamnt`=m_partmaterialamnt, `status`=stat;
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_end_editjoborder`(
INOUT	flag	INT
)
BEGIN
	IF flag = 0
		THEN

			COMMIT;
	ELSE
		ROLLBACK;
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_end_joborder`(
INOUT	o_jo_id	INT,
INOUT	flag	INT
)
BEGIN
	IF flag = 0
		THEN

			COMMIT;
	ELSE
		ROLLBACK;
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_joborderdet`(
INOUT 	m_jo_id			INT,
IN 	m_labor 		TEXT,
IN	m_partmaterial		VARCHAR(50),
IN 	m_details 		TEXT,
IN	m_laboramnt 		DECIMAL(8,2),
IN	m_partmaterialamnt 	DECIMAL(8,2),
IN	m_status 		INT,
INOUT 	flag	INT
)
BEGIN

DECLARE stat INT;
DECLARE lt_last_id INT DEFAULT 0;
DECLARE EXIT handler for SQLEXCEPTION set flag = 1;

	SET stat = m_status + 1; 
	
	
	IF NOT EXISTS(SELECT * FROM `labortype` WHERE `name`=m_labor) 
		THEN
			IF (m_labor REGEXP '[0]'= 1)
				THEN
					INSERT INTO `jodetails` SET `jo_id`=m_jo_id, `labor`=m_labor, `partmaterial`=m_partmaterial, `details`=m_details, `laboramnt`=m_laboramnt, `partmaterialamnt`=m_partmaterialamnt, `status`=stat;
			ELSE
				INSERT INTO `labortype` SET `name`=m_labor, `category`="0", `status`="1";
 				SET lt_last_id = LAST_INSERT_ID();

				INSERT INTO `jodetails` SET `jo_id`=m_jo_id, `labor`=lt_last_id, `partmaterial`=m_partmaterial, `details`=m_details, `laboramnt`=m_laboramnt, `partmaterialamnt`=m_partmaterialamnt, `status`=stat;
			END IF;
			
	ELSE
		SET lt_last_id = (SELECT `laborid` FROM `labortype` WHERE `name`=m_labor);
		INSERT INTO `jodetails` SET `jo_id`=m_jo_id, `labor`=lt_last_id, `partmaterial`=m_partmaterial, `details`=m_details, `laboramnt`=m_laboramnt, `partmaterialamnt`=m_partmaterialamnt, `status`=stat;
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_newdcr`(IN m_trnx_date DATE, IN m_beg_bal DECIMAL(8,2), IN m_cashier INT, IN m_status CHAR(1), OUT m_dcr_id BIGINT)
BEGIN
INSERT INTO dcr SET trnxdate = m_trnx_date, begbal = m_beg_bal, cashier = m_cashier, `status` = m_status;
  SET m_dcr_id = LAST_INSERT_ID();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_start_editjoborder`(
IN	m_joid		INT,
IN 	cust_id		INT,
IN	cust_fname	varchar(50),
IN	cust_mname	varchar(50),
IN	cust_lname	varchar(50),
OUT	ret_id		INT,
OUT	flag		INT
)
BEGIN

DECLARE EXIT handler for sqlexception set flag = 1;

START TRANSACTION;

	IF(cust_id=0)
		THEN
			DELETE FROM `jodetails` WHERE `jo_id`=m_joid;
			INSERT INTO `customer` SET `fname`=cust_fname, `mname`=cust_mname, `lname`=cust_lname;
			SET ret_id=LAST_INSERT_ID();

		SET flag=0;
 	ELSE
		DELETE FROM `jodetails` WHERE `jo_id`=m_joid;
		SET ret_id=cust_id;
		SET flag=0;

	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_start_joborder`(
OUT 	flag	INT
)
BEGIN

START TRANSACTION;
set flag=0;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tmptblDCRDetails`(OUT pSuccess INT)
BEGIN
    DECLARE cant_create_table INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR 1005 /* can't create table */ SET cant_create_table = 1;

    DROP TEMPORARY TABLE IF EXISTS `tmptblDCRDetails`;
    CREATE TEMPORARY TABLE `tmptblDCRDetails`(
      particular VARCHAR(255) NULL,
      tender TINYINT,
      refno VARCHAR(75) NULL,
      amnt DECIMAL(8,2),
      id INT NOT NULL DEFAULT 0) ENGINE = MEMORY;

      IF cant_create_table = 1 THEN
        SET pSuccess = 0; -- failed
      ELSE
        SET pSuccess = 1; -- success
      END IF;

  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_updateDCRDetails`(IN pExistTmpTable INT, IN pID INT)
    MODIFIES SQL DATA
BEGIN
    DECLARE no_record_found INT DEFAULT 0;
    DECLARE l_particular VARCHAR(255);
    DECLARE l_tender INT DEFAULT 0;
    DECLARE l_refno VARCHAR(75) DEFAULT '';
    DECLARE l_amnt DECIMAL(8,2) DEFAULT 0.00;
    DECLARE curTmpTable CURSOR FOR SELECT particular, tender, refno, amnt FROM tmptblDCRDetails WHERE id=pID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_record_found = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
    DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

    START TRANSACTION;

      IF pExistTmpTable = 0 THEN

        # deletes all dcr master details for a particular dcr
        DELETE FROM dcrdetails WHERE dcr_id = pID;

        /* opens the cursur */
        OPEN curTmpTable;
        main_loop:LOOP

          /* checks if not EOF */
          IF no_record_found = 1 THEN
            LEAVE main_loop;
          END IF;
          /* fetches every single row */
          FETCH curTmpTable INTO l_particular, l_tender, l_refno, l_amnt;

          -- inserts into dcr details table
          INSERT INTO dcrdetails
                      SET particulars = l_particular,
                          refno = l_refno,
                          tender = l_tender,
                          amnt = l_amnt,
                          dcr_id = pID;

        END LOOP main_loop;
        CLOSE curTmpTable;

      END IF;

    COMMIT;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-05-25 13:18:29
