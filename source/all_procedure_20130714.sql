-- MySQL dump 10.13  Distrib 5.5.24, for Win64 (x86)
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_dcrPayments`(p_jo_id INT) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_dcr_payments DECIMAL(8,2) DEFAULT 0.00;

  SELECT SUM(d.amnt) AS `total` INTO l_dcr_payments FROM dcrdetails d WHERE refno=p_jo_id;

  RETURN  l_dcr_payments;
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_getBegBal`(p_cashier TINYINT, p_curdate DATE, p_status CHAR(1)) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_begbal DECIMAL(8,2) DEFAULT 0.00;

  SELECT begbal INTO l_begbal FROM dcr WHERE cashier=p_cashier AND trnxdate=p_curdate AND `status`=p_status;

  RETURN l_begbal;
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_getCashFloat`(p_cashier TINYINT, p_curdate DATE, p_status CHAR(1)) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_cash_float DECIMAL(8,2) DEFAULT 0.00;


  SELECT SUM(amnt) INTO l_cash_float FROM cashfloat c WHERE cashier=p_cashier AND trnxdate=p_curdate AND `status`=p_status;

  RETURN l_cash_float;

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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_getCashLift`(p_cashier TINYINT, p_curdate DATE, p_status CHAR(1)) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_cash_lift DECIMAL(8,2) DEFAULT 0.00;

  SELECT SUM(amnt) INTO l_cash_lift FROM cashlift c WHERE cashier=p_cashier AND trnxdate=p_curdate AND `status`=p_status;

  RETURN l_cash_lift;

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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_isJoFullyPaid`(p_jo_id INT) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN

  DECLARE l_paid INT DEFAULT 0;

  SELECT COUNT(j.customer) AS paid INTO l_paid FROM joborder j WHERE j.jo_id=p_jo_id AND j.`status`='0';

  RETURN l_paid;
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_joPayment`(p_jo_id INT) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_jo_payables DECIMAL(8,2) DEFAULT 0.00;
  DECLARE l_dcr_payments DECIMAL(8,2) DEFAULT 0.00;

  SELECT SUM(jd.amnt) AS `total` INTO l_jo_payables FROM joborder j LEFT JOIN jodetails jd ON j.jo_id=jd.jo_id WHERE j.`status`='1' AND j.jo_id=p_jo_id GROUP BY j.jo_id;
  SELECT SUM(d.amnt) AS `total` INTO l_dcr_payments FROM dcrdetails d WHERE refno=p_jo_id;

  RETURN l_jo_payables - l_dcr_payments;
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnc_updateDetailJO`(p_jo_id INT) RETURNS int(11)
    DETERMINISTIC
BEGIN

  DECLARE l_status_ERROR INT DEFAULT 0;
  DECLARE l_labor INT DEFAULT 1;
  DECLARE l_partmaterial VARCHAR(255);
  DECLARE l_details VARCHAR(255) DEFAULT NULL;
  DECLARE l_amnt DECIMAL(8,2) DEFAULT 0.00;
  DECLARE l_EOF INT DEFAULT 0;

  DECLARE cur_tmpjotbldtls CURSOR FOR SELECT labor, partmaterial, details, amnt FROM tmp_jo_details_cache;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_EOF = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET l_status_ERROR = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET l_status_ERROR = -2;

  
  DELETE FROM jodetails WHERE jo_id = p_jo_id;

  
  OPEN cur_tmpjotbldtls;

  main_loop:LOOP

    
    FETCH cur_tmpjotbldtls INTO l_labor, l_partmaterial, l_details, l_amnt;

    IF l_EOF = 1 THEN
      LEAVE main_loop;
    END IF;

    
    INSERT INTO jodetails SET jo_id = p_jo_id,
                              labor = l_labor,
                              partmaterial = l_partmaterial,
                              details = l_details,
                              amnt = l_amnt,
                              `status` = '1';

  END LOOP main_loop;

  
  CLOSE cur_tmpjotbldtls;

  
  DELETE FROM tmp_jo_details_cache;

  
  SET l_status_ERROR = 0;

  RETURN l_status_ERROR;

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
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `func_deactivate_vo`(p_plateno VARCHAR(50)) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN

  DECLARE m_EOF INT DEFAULT 0;
  DECLARE m_vo_id INT DEFAULT 0;
  DECLARE curVO CURSOR FOR SELECT vo_id FROM vehicle_owner WHERE (plateno LIKE '%p_plateno%' AND vo_id > (SELECT MIN(vo_id) FROM vehicle_owner WHERE plateno LIKE '%p_plateno%'));
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET m_EOF = 1;

  DROP TEMPORARY TABLE IF EXISTS `tmp_vo`;
  CREATE TEMPORARY TABLE `tmp_vo`(
    vo_id INT DEFAULT 0
  ) ENGINE = MEMORY;

  

  OPEN curVO;

  main_loop:LOOP
    FETCH curVO INTO m_vo_id;

    IF m_EOF THEN
      LEAVE main_loop;
    END IF;

    INSERT INTO tmp_vo SET vo_id = m_vo_id;

  END LOOP main_loop;

  CLOSE curVO;

  UPDATE vehicle_owner SET `status`='0' WHERE vo_id IN (SELECT vo_id FROM tmp_vo);

RETURN 0;
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_addDcrDetails`(IN p_dcr_id INT, IN p_particulars MEDIUMTEXT, IN p_refno VARCHAR(15), IN p_amnt DECIMAL(8,2), IN p_tender TINYINT, OUT p_status INT, OUT p_last_id INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1; 
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2; 

  
  SET p_last_id = 0;

  INSERT INTO dcrdetails SET dcr_id = p_dcr_id,
                              particulars = p_particulars,
                              refno = p_refno,
                              amnt = p_amnt,
                              tender = p_tender;
  SET p_status = 1;
  SET p_last_id = LAST_INSERT_ID();

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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_addJO`(IN p_jo_number VARCHAR(10), IN p_v_id INT, IN p_customer INT, IN p_plate VARCHAR(75), IN p_trnxdate VARCHAR(32), IN p_tax DECIMAL(8,2), IN p_discount DECIMAL(8,2), OUT p_last_id INT)
BEGIN



  DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

  DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;



  START TRANSACTION;



    

    INSERT INTO joborder (jo_number, v_id, customer, plate, tax, discount, trnxdate)

      VALUE(p_jo_number, p_v_id, p_customer, p_plate, p_tax, p_discount, p_trnxdate);



      

      SET p_last_id =  LAST_INSERT_ID();



      

      BEGIN

        DECLARE EOF INT DEFAULT 0;

        DECLARE l_labor INT DEFAULT 0;

        DECLARE l_partmaterial VARCHAR(255) DEFAULT '';

        DECLARE l_details VARCHAR(255) DEFAULT '';

        DECLARE l_amnt DECIMAL(8,2);

        DECLARE curjocache CURSOR FOR SELECT labor, partmaterial, details, amnt FROM tmp_jo_details_cache;



        DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = 1;



        

        OPEN curjocache;



        main_loop:LOOP

          

          FETCH curjocache INTO l_labor, l_partmaterial, l_details, l_amnt;



          

          IF EOF = 1 THEN

            LEAVE main_loop;

          END IF;



          

          INSERT INTO jodetails SET jo_id = p_last_id, labor = l_labor, partmaterial = l_partmaterial, details = l_details, amnt = l_amnt, `status` = '1';



        END LOOP main_loop;



        

        CLOSE curjocache;



      END;





      

      DELETE FROM tmp_jo_details_cache;

  COMMIT;



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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_create_jo_cache`()
BEGIN

  DROP  TABLE IF EXISTS `tmp_jo_details_cache`;

  CREATE  TABLE `tmp_jo_details_cache`(

    trace_id INT NOT NULL AUTO_INCREMENT,

    labor INT NOT NULL DEFAULT 0,

    partmaterial VARCHAR(255) DEFAULT NULL,

    details VARCHAR(255) DEFAULT NULL,

    amnt DECIMAL(8,2),

    UNIQUE KEY (trace_id)) ENGINE = MEMORY;

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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_DailyCollection`(IN p_cashier TINYINT, IN p_curdate DATE, IN p_status CHAR(1))
BEGIN

  DECLARE l_EOF INT DEFAULT 0;
  DECLARE l_trnxdate DATE DEFAULT '0000-00-00';
  DECLARE l_cashier TINYINT DEFAULT 0;
  DECLARE l_status CHAR(1) DEFAULT '1';
  DECLARE l_particulars VARCHAR(255) DEFAULT NULL;
  DECLARE l_refno INT DEFAULT 0;
  DECLARE l_amnt DECIMAL(8,2) DEFAULT 0.00;
  DECLARE l_tender TINYINT DEFAULT 0;

  DECLARE curDCR CURSOR FOR SELECT d.trnxdate, d.cashier, d.`status`, dd.particulars, dd.refno, dd.amnt, dd.tender FROM dcr d LEFT JOIN dcrdetails dd ON d.dcr_id=dd.dcr_id WHERE (d.trnxdate=p_curdate AND d.cashier=p_cashier AND d.`status`=p_status);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_EOF = 1;

  DROP TEMPORARY TABLE IF EXISTS `tmp_daily_collection`;
  CREATE TEMPORARY TABLE `tmp_daily_collection` (
    trnxdate DATE DEFAULT '0000-00-00',
    cashier TINYINT DEFAULT 0,
    `status` ENUM('0', '1') DEFAULT '1',
    refno INT NOT NULL DEFAULT 0,
    amnt DECIMAL(8,2) DEFAULT 0.00,
    tender TINYINT DEFAULT 0,
    particulars VARCHAR(255) DEFAULT NULL,
    paid TINYINT DEFAULT 0) ENGINE=INNODB;


  
  OPEN curDCR;

  main_loop:LOOP
    
    FETCH curDCR INTO l_trnxdate, l_cashier, l_status, l_particulars, l_refno, l_amnt, l_tender;

    
    IF l_EOF = 1 THEN
      LEAVE main_loop;
    END IF;

    
    IF fnc_isJoFullyPaid(l_refno) = 1 THEN
        INSERT INTO `tmp_daily_collection` (trnxdate,cashier,`status`, refno, amnt, tender, particulars, paid)
          VALUES(l_trnxdate,l_cashier,l_status,l_refno,l_amnt,l_tender, l_particulars, 1);
    ELSE
        INSERT INTO `tmp_daily_collection` (trnxdate,cashier,`status`, refno, amnt, tender, particulars, paid)
          VALUES(l_trnxdate,l_cashier,l_status,l_refno,l_amnt,l_tender, l_particulars, 0);
    END IF;

  END LOOP main_loop;

  
  CLOSE curDCR;



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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_deleteDcrDetail`(IN p_dcrdtl_id INT, OUT p_status TINYINT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2;

  
  SET p_status = 0;

  DELETE FROM dcrdetails WHERE dcrdtl_id = p_dcrdtl_id;

  SET p_status = 1;

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
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_vehicle_owner_duplicate`()
BEGIN

DECLARE m_EOF INT DEFAULT 0;
DECLARE m_vo_id INT DEFAULT 0;
DECLARE m_color INT DEFAULT 0;
DECLARE m_plateno VARCHAR(50) DEFAULT '';
DECLARE m_description VARCHAR(255) DEFAULT '';
DECLARE m_owner INT DEFAULT 0;
DECLARE m_make INT DEFAULT 0;
DECLARE m_status CHAR DEFAULT '';

DECLARE curVehicle_owner CURSOR FOR SELECT v.vo_id, v.make, v.owner, CONCAT(RTRIM(LTRIM(c.lname)), ', ', RTRIM(LTRIM(c.fname))) AS `customer`, c.custid, v.plateno AS plateno, COUNT(plateno) AS `count` FROM vehicle_owner v LEFT JOIN customer c ON v.owner=c.custid  GROUP BY plateno, `customer`, v.plateno  HAVING `count`>1  ORDER BY v.owner;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET m_EOF = 1;

  OPEN curVehicle_owner;

  main_loop:LOOP
    FETCH curVehicle_owner INTO m_vo_id, m_plateno, m_color, m_make, m_description, m_owner, m_status;

    IF m_EOF = 1 THEN
      LEAVE main_loop;
    END IF;


    SELECT func_deactivate_vo(m_plateno);
  END LOOP main_loop;

  CLOSE curVehicle_owner;

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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_dmax`(OUT p_counter VARCHAR(10))
BEGIN
    DECLARE l_max INT DEFAULT 0;

    SELECT MAX(jo_id) INTO l_max FROM joborder;

    IF(l_max IS NULL) THEN
      SET l_max = 1;
    ELSE
      SET l_max = l_max + 1;
    END IF;

    SET p_counter = LPAD(l_max, 6, '0');

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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editDcrDetail`(IN p_particulars MEDIUMTEXT, IN p_refno VARCHAR(15), IN p_amnt DECIMAL(8,2), IN p_tender TINYINT, IN p_dcrdtl_id INT, OUT p_status TINYINT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2;

  
  SET p_status = 0;

  UPDATE dcrdetails SET particulars = p_particulars,
                        refno = p_refno,
                        amnt = p_amnt,
                        tender = p_tender
                      WHERE dcrdtl_id = p_dcrdtl_id;

  SET p_status = 1;
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editJO`(IN p_jo_id INT, IN p_jo_number VARCHAR(10), IN p_v_id INT, IN p_customer INT, IN p_plate VARCHAR(75), IN p_trnxdate VARCHAR(32), IN p_tax DECIMAL(8,2), IN p_discount DECIMAL(8,2), OUT p_status INT)
BEGIN


  DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
  DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

  START TRANSACTION;

    
    SET  p_status = 0;

    
    UPDATE joborder SET jo_number = p_jo_number,
                        v_id = p_v_id,
                        customer = p_customer,
                        plate = p_plate,
                        trnxdate = p_trnxdate,
                        tax = p_tax,
                        discount = p_discount
                    WHERE jo_id = p_jo_id;

    
    IF fnc_updateDetailJO(p_jo_id) < 0 THEN
      SET  p_status = -1;
      ROLLBACK;
    END IF;

  COMMIT;


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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_jo_cache`(IN p_labor INT, IN p_partmaterial VARCHAR(255), IN p_details MEDIUMTEXT, IN p_amnt DECIMAL(8,2), OUT p_last_id INT, OUT p_status INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2;

  
  SET p_status = 0;

  INSERT INTO `tmp_jo_details_cache` SET labor = p_labor, partmaterial = p_partmaterial, details = p_details, amnt = p_amnt;
  SET p_last_id = LAST_INSERT_ID();
  SET p_status = 1;

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-07-14 17:54:52
