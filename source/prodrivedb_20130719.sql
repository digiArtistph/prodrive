-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 18, 2013 at 08:48 AM
-- Server version: 5.5.24-log
-- PHP Version: 5.3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `prodrivedb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addDcrDetails`(IN p_dcr_id INT, IN p_particulars MEDIUMTEXT, IN p_refno VARCHAR(15), IN p_amnt DECIMAL(8,2), IN p_tender TINYINT, OUT p_status INT, OUT p_last_id INT)
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

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addJO`(IN p_jo_number VARCHAR(10), IN p_v_id INT, IN p_customer INT, IN p_plate VARCHAR(75), IN p_trnxdate VARCHAR(32), IN p_tax DECIMAL(8,2), IN p_discount DECIMAL(8,2), OUT p_last_id INT)
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



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_jo_cache`()
BEGIN

  DROP  TABLE IF EXISTS `tmp_jo_details_cache`;

  CREATE  TABLE `tmp_jo_details_cache`(

    trace_id INT NOT NULL AUTO_INCREMENT,

    labor INT NOT NULL DEFAULT 0,

    partmaterial VARCHAR(255) DEFAULT NULL,

    details VARCHAR(255) DEFAULT NULL,

    amnt DECIMAL(8,2),

    UNIQUE KEY (trace_id)) ENGINE = MEMORY;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DailyCollection`(IN p_cashier TINYINT, IN p_curdate DATE, IN p_status CHAR(1))
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



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteDcrDetail`(IN p_dcrdtl_id INT, OUT p_status TINYINT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2;

  
  SET p_status = 0;

  DELETE FROM dcrdetails WHERE dcrdtl_id = p_dcrdtl_id;

  SET p_status = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_vehicle_owner_duplicate`()
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

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_dmax`(OUT p_counter VARCHAR(10))
BEGIN
    DECLARE l_max INT DEFAULT 0;

    SELECT MAX(jo_id) INTO l_max FROM joborder;

    IF(l_max IS NULL) THEN
      SET l_max = 1;
    ELSE
      SET l_max = l_max + 1;
    END IF;

    SET p_counter = LPAD(l_max, 6, '0');

  END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editDcrDetail`(IN p_particulars MEDIUMTEXT, IN p_refno VARCHAR(15), IN p_amnt DECIMAL(8,2), IN p_tender TINYINT, IN p_dcrdtl_id INT, OUT p_status TINYINT)
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editJO`(IN p_jo_id INT, IN p_jo_number VARCHAR(10), IN p_v_id INT, IN p_customer INT, IN p_plate VARCHAR(75), IN p_trnxdate VARCHAR(32), IN p_tax DECIMAL(8,2), IN p_discount DECIMAL(8,2), OUT p_status INT)
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


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editjoborder`(
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



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editjoborderdet`(
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

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_end_editjoborder`(
INOUT	flag	INT
)
BEGIN
	IF flag = 0
		THEN

			COMMIT;
	ELSE
		ROLLBACK;
	END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_end_joborder`(
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

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_jo_cache`(IN p_labor INT, IN p_partmaterial VARCHAR(255), IN p_details MEDIUMTEXT, IN p_amnt DECIMAL(8,2), OUT p_last_id INT, OUT p_status INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2;

  
  SET p_status = 0;

  INSERT INTO `tmp_jo_details_cache` SET labor = p_labor, partmaterial = p_partmaterial, details = p_details, amnt = p_amnt;
  SET p_last_id = LAST_INSERT_ID();
  SET p_status = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_joborderdet`(
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

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_newdcr`(IN m_trnx_date DATE, IN m_beg_bal DECIMAL(8,2), IN m_cashier INT, IN m_status CHAR(1), OUT m_dcr_id BIGINT)
BEGIN
INSERT INTO dcr SET trnxdate = m_trnx_date, begbal = m_beg_bal, cashier = m_cashier, `status` = m_status;
  SET m_dcr_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_start_editjoborder`(
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_start_joborder`(
OUT 	flag	INT
)
BEGIN

START TRANSACTION;
set flag=0;

END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_dcrPayments`(p_jo_id INT) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_dcr_payments DECIMAL(8,2) DEFAULT 0.00;

  SELECT SUM(d.amnt) AS `total` INTO l_dcr_payments FROM dcrdetails d WHERE refno=p_jo_id;

  RETURN  l_dcr_payments;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_getBegBal`(p_cashier TINYINT, p_curdate DATE, p_status CHAR(1)) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_begbal DECIMAL(8,2) DEFAULT 0.00;

  SELECT begbal INTO l_begbal FROM dcr WHERE cashier=p_cashier AND trnxdate=p_curdate AND `status`=p_status;

  RETURN l_begbal;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_getCashFloat`(p_cashier TINYINT, p_curdate DATE, p_status CHAR(1)) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_cash_float DECIMAL(8,2) DEFAULT 0.00;


  SELECT SUM(amnt) INTO l_cash_float FROM cashfloat c WHERE cashier=p_cashier AND trnxdate=p_curdate AND `status`=p_status;

  RETURN l_cash_float;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_getCashLift`(p_cashier TINYINT, p_curdate DATE, p_status CHAR(1)) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_cash_lift DECIMAL(8,2) DEFAULT 0.00;

  SELECT SUM(amnt) INTO l_cash_lift FROM cashlift c WHERE cashier=p_cashier AND trnxdate=p_curdate AND `status`=p_status;

  RETURN l_cash_lift;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_isJoFullyPaid`(p_jo_id INT) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN

  DECLARE l_paid INT DEFAULT 0;

  SELECT COUNT(j.customer) AS paid INTO l_paid FROM joborder j WHERE j.jo_id=p_jo_id AND j.`status`='0';

  RETURN l_paid;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_joPayment`(p_jo_id INT) RETURNS decimal(8,2)
    DETERMINISTIC
BEGIN

  DECLARE l_jo_payables DECIMAL(8,2) DEFAULT 0.00;
  DECLARE l_dcr_payments DECIMAL(8,2) DEFAULT 0.00;

  SELECT SUM(jd.amnt) AS `total` INTO l_jo_payables FROM joborder j LEFT JOIN jodetails jd ON j.jo_id=jd.jo_id WHERE j.`status`='1' AND j.jo_id=p_jo_id GROUP BY j.jo_id;
  SELECT SUM(d.amnt) AS `total` INTO l_dcr_payments FROM dcrdetails d WHERE refno=p_jo_id;

  RETURN l_jo_payables - l_dcr_payments;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fnc_updateDetailJO`(p_jo_id INT) RETURNS int(11)
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

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `func_deactivate_vo`(p_plateno VARCHAR(50)) RETURNS tinyint(4)
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cashfloat`
--

CREATE TABLE IF NOT EXISTS `cashfloat` (
  `cf_id` int(11) NOT NULL AUTO_INCREMENT,
  `refno` varchar(150) DEFAULT NULL,
  `particulars` mediumtext,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `trnxdate` date DEFAULT NULL,
  `cashier` tinyint(4) DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`cf_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `cashlift`
--

CREATE TABLE IF NOT EXISTS `cashlift` (
  `cl_id` int(11) NOT NULL AUTO_INCREMENT,
  `refno` varchar(150) DEFAULT NULL,
  `particulars` mediumtext,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `trnxdate` date DEFAULT NULL,
  `cashier` tinyint(4) DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`cl_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
  `categ_id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(150) DEFAULT NULL,
  `parent` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`categ_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`categ_id`, `category`, `parent`) VALUES
(1, 'Preventive Maintenance Services', 6),
(3, 'Change Oil', 3),
(4, 'Exhaust System', 0),
(5, 'Braking', 3),
(6, 'Cool/Heat System', 0);

-- --------------------------------------------------------

--
-- Table structure for table `color`
--

CREATE TABLE IF NOT EXISTS `color` (
  `clr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`clr_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=53 ;

--
-- Dumping data for table `color`
--

INSERT INTO `color` (`clr_id`, `name`) VALUES
(1, 'Red'),
(2, 'Blue'),
(3, 'Green'),
(6, 'Sky Blue'),
(25, 'Yellow'),
(10, 'Silver'),
(24, 'Brown'),
(23, 'Black Forest'),
(13, 'Dark Red'),
(22, 'White'),
(26, 'Aqua Marine'),
(27, 'Fuschia'),
(31, 'BLACK'),
(32, 'NO COLOR'),
(33, 'GOLD'),
(34, 'RED ORANGE'),
(35, 'WHITE YELLOW'),
(36, 'MAROON'),
(37, 'GRAY'),
(38, 'FLAMINGGO RED'),
(39, 'BEIGE'),
(40, 'BLAZE'),
(41, 'THERMALITE'),
(42, 'PASSION ORANGE'),
(43, 'DARK BLUE'),
(44, 'NAVY BLUE'),
(45, 'MAJINTA RED'),
(46, 'MET.BLUE'),
(47, 'MIDNIGHT BLACK'),
(48, 'ORANGE'),
(49, 'MOCHA'),
(50, 'HANTER GREEN'),
(51, 'BLUE GREEN'),
(52, 'EMERALD GREEN');

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE IF NOT EXISTS `company` (
  `co_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `addr` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `fax` varchar(50) DEFAULT NULL,
  `email` mediumtext,
  `url` mediumtext,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`co_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=36 ;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`co_id`, `name`, `addr`, `phone`, `fax`, `email`, `url`, `status`) VALUES
(1, 'TOPWATCH SECURITY AGENCY', '', '088', '', '', '', '1'),
(2, 'ETE MACHINE SHOP', '', '088', '', '', '', '1'),
(3, 'PROSEL PHARMACEUTICALS', '', '088', '', '', '', '1'),
(4, 'ZUELLIG PHARMA CORPORATION', '', '088', '', '', '', '1'),
(5, 'PEDIATRIC, INC.', '', '088', '', '', '', '1'),
(6, 'WESTMONT PHARMACEUTICALS,INC.', '', '088', '', '', '', '1'),
(7, 'MEDICHEM PHARMACEUTICALS INC.', '', '088', '', '', '', '1'),
(8, 'LRI-THERAPHARMA', '', '088', '', '', '', '1'),
(9, 'UNITED LABORATORIES,INC.', '', '088', '', '', '', '1'),
(10, 'THE MERCANTILE INSURANCE,INC.', '', '088', '', '', '', '1'),
(11, 'RITEMED PHILS. INC.', '', '088', '', '', '', '1'),
(12, 'NORTH TREND MKTG. CORP', '', '088', '', '', '', '1'),
(13, 'FEDERAL PHOENIX ASSURANCE CO.INC', '', '088', '', '', '', '1'),
(14, 'NOVARTIS HEALTHCARE PHILS.,INC.', '', '088', '', '', '', '1'),
(15, 'JB PHARMA', '', '088', '', '', '', '1'),
(16, 'FLEET DEPARTMENT', '', '088', '', '', '', '1'),
(17, 'GRANITE INDUSTRIAL CORPORATION', '', '088', '', '', '', '1'),
(18, 'AP CARGO LOGISTIC NETWORK CORP.', '', '088', '', '', '', '1'),
(19, 'CAAN PHARMACEUTICALS CO.,INC', '', '088', '', '', '', '1'),
(20, 'EIE MACHINE SHOP', '', '088', '', '', '', '1'),
(21, 'SV MORE PHARMA', '', '088', '', '', '', '1'),
(22, 'MAA GENERAL ASSURANCE PHILS. INC.', '', '088', '', '', '', '1'),
(23, 'MINDANAO COMMUNITY DEVELOPMENT INNOVATIONS, INC.', '', '088', '', '', '', '1'),
(24, 'TRIPLE A', '', '088', '', '', '', '1'),
(25, 'HIMEX COOP', '', '088', '', '', '', '1'),
(26, 'BASIC PHARMA CORP.', '', '088', '', '', '', '1'),
(27, 'STARGET', '', '088', '', '', '', '1'),
(28, 'STRONGHOLD INSURANCE COMPANY', '', '088', '', '', '', '1'),
(29, 'PLANET SPEED', '', '088', '', '', '', '1'),
(30, 'MUNDIPHARMA DISTRIBUTION', '', '088', '', '', '', '1'),
(31, 'ORIENTAL & MOTOLITE MKTG. CORP', '', '088', '', '', '', '1'),
(32, 'AGRINANAS DEVELOPMENT COMPANY INC.', '', '088', '', '', '', '1'),
(33, 'MULTICARE PHARMACEUTICAL PHILS.', '', '088', '', '', '', '1'),
(34, 'ASIA BREWERY INCORPORATED', '', '088', '', '', '', '1'),
(35, 'ORIX RENTAL CORPORATION', '', '088', '', '', '', '1');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE IF NOT EXISTS `customer` (
  `custid` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(255) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `addr` mediumtext,
  `phone` varchar(255) DEFAULT NULL,
  `status` enum('0','1') DEFAULT '1',
  `company` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`custid`),
  UNIQUE KEY `unq_fullname` (`lname`,`fname`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=407 ;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`custid`, `fname`, `mname`, `lname`, `addr`, `phone`, `status`, `company`) VALUES
(3, 'LEONARDO', NULL, 'KHU', NULL, NULL, '1', 0),
(4, 'MARK', NULL, 'ILOGON', NULL, NULL, '1', 0),
(5, 'ARNEL', NULL, 'SANCHEZ', NULL, NULL, '1', 0),
(6, 'Mike', NULL, 'Padero', NULL, NULL, '1', 0),
(7, 'GERRY', NULL, 'GALVEZ', NULL, NULL, '1', 0),
(8, 'ROMY', NULL, 'JUMALON', NULL, NULL, '1', 0),
(9, 'PEGGY ANN', NULL, 'SEBASTIAN', NULL, NULL, '1', 0),
(10, 'PATRICK', NULL, 'ABSIN', NULL, NULL, '0', 0),
(11, 'ABSIN', NULL, 'PATRICK', NULL, NULL, '0', 0),
(12, 'BERDIDA', NULL, 'ARVY', NULL, NULL, '1', 0),
(13, 'ODYSSEY DRIVING SCHOOL', NULL, 'L', NULL, NULL, '1', 0),
(14, 'PHIL. ARMY', '', 'A', 'CDO', '+63', '1', 0),
(15, 'BENG', NULL, 'PELAEZ', NULL, NULL, '1', 0),
(16, 'SAPIO', NULL, 'NECO', NULL, NULL, '1', 0),
(17, 'MIKHAEL/LRI THERAPH', '', 'BAUTISTA', 'CDO', '+63', '0', 0),
(18, 'RIZAL', NULL, 'M', NULL, NULL, '0', 0),
(19, 'PATRICK BRYAN', NULL, 'ABSIN', NULL, NULL, '1', 0),
(20, 'MIKE', NULL, 'IGNACIO', NULL, NULL, '1', 0),
(21, 'FR.JULIUS', NULL, 'CLAVERO', NULL, NULL, '1', 0),
(22, 'SGT. BANSE', NULL, 'M', NULL, NULL, '0', 0),
(23, 'PROEL', NULL, 'MOFAN', NULL, NULL, '0', 0),
(24, 'JOHN RAY', NULL, 'BADAJOS', NULL, NULL, '1', 0),
(25, 'DARWIN', NULL, 'ANDRES', NULL, NULL, '1', 0),
(26, 'MIKE', NULL, 'CARONAN', NULL, NULL, '1', 0),
(27, 'AP-CARGO', NULL, 'LOGISTIC NETWORK', NULL, NULL, '0', 0),
(28, 'JINKY', NULL, 'BAYLON', NULL, NULL, '1', 0),
(29, 'LOLOY', NULL, 'PABILONA', NULL, NULL, '1', 0),
(30, 'FR. JOBEL', NULL, 'K', NULL, NULL, '0', 0),
(31, 'RICCA MARIE', NULL, 'LUGOD', NULL, NULL, '1', 0),
(32, 'MARK', NULL, 'ABDULLAH', NULL, NULL, '1', 0),
(33, 'GEORGE', NULL, 'CLAUDIOS', NULL, NULL, '1', 0),
(34, 'ROGER', NULL, 'ALBACETE', NULL, NULL, '1', 0),
(35, 'PAULO', NULL, 'SIAC', NULL, NULL, '1', 0),
(36, 'ELLEN', NULL, 'ROA', NULL, NULL, '1', 0),
(37, 'LABUNTONG', NULL, 'AL', NULL, NULL, '1', 0),
(38, 'BOJIE', NULL, 'NO', NULL, NULL, '1', 0),
(39, 'MAAM JING', NULL, 'JING', NULL, NULL, '1', 0),
(40, 'PATRICK', NULL, 'TSENG', NULL, NULL, '1', 0),
(41, 'ERVIN JOHN', NULL, 'DANDOY', NULL, NULL, '1', 0),
(42, 'AL GAUVIN', NULL, 'LABUNTONG', NULL, NULL, '1', 0),
(43, 'MICHAEL', NULL, 'VALENZUELA', NULL, NULL, '1', 0),
(44, 'MCDI', NULL, 'MCDI', NULL, NULL, '1', 0),
(45, 'POEL', NULL, 'MOFAR/ZUELLIG PHARMA', NULL, NULL, '0', 0),
(46, 'PROEL', NULL, 'MOFAR', NULL, NULL, '0', 0),
(47, 'TITUS', NULL, 'VELEZ', NULL, NULL, '1', 0),
(48, 'JOESONS', NULL, 'JOE', NULL, NULL, '1', 0),
(49, 'BENJAMIN', NULL, 'DELOS SANTOS', NULL, NULL, '1', 0),
(50, 'AP-CARGO', NULL, 'AP', NULL, NULL, '1', 0),
(51, 'ILOGON', NULL, 'MARK', NULL, NULL, '0', 0),
(52, 'RALPH', NULL, 'QUIJANO', NULL, NULL, '0', 0),
(53, 'BADAJOS', NULL, 'BADS', NULL, NULL, '0', 0),
(54, 'JOSHUA', NULL, 'HOLCIM', NULL, NULL, '1', 0),
(55, 'JR', NULL, 'NERI', NULL, NULL, '1', 0),
(56, 'SIMOUN AMEL', NULL, 'BAUTISTA', NULL, NULL, '1', 0),
(57, 'GABRIEL', NULL, 'UMEREZ', NULL, NULL, '0', 0),
(58, 'JOSEPH', NULL, 'ESTROBO', NULL, NULL, '1', 0),
(59, 'ROBERTO,JR.', NULL, 'MALFERRARI', NULL, NULL, '1', 0),
(60, 'HAZEL ELIZABETH', NULL, 'CHAARAONI', NULL, NULL, '1', 0),
(61, 'RIZAL', NULL, 'DALKILIC', NULL, NULL, '1', 0),
(62, 'DONALD', NULL, 'CORDERO', NULL, NULL, '1', 0),
(63, 'DAOMILAS', NULL, 'DAO', NULL, NULL, '1', 0),
(64, 'TOPWATCH AGENCY', NULL, 'AGENCY', NULL, NULL, '1', 0),
(65, 'ISRAEL', NULL, 'ADELANTE', NULL, NULL, '0', 0),
(66, 'KARL', NULL, 'QUINCO', NULL, NULL, '1', 0),
(67, 'ETE', NULL, 'MACHINE SHOP', NULL, NULL, '1', 0),
(68, 'RICHARD', NULL, 'ONG', NULL, NULL, '1', 0),
(69, 'REGIE MARIE', NULL, 'GUEVARRA', NULL, NULL, '1', 0),
(70, 'RICHIE', NULL, 'ARRIESGADO', NULL, NULL, '1', 0),
(71, 'KENNY MICK', NULL, 'SERQUIÑA', NULL, NULL, '1', 0),
(72, 'KENN', NULL, 'SERQ', NULL, NULL, '1', 0),
(73, 'JUN RAñERI', NULL, 'OLIVEROS', NULL, NULL, '1', 0),
(74, 'ABRAHIM', NULL, 'MASTAFA', NULL, NULL, '1', 0),
(75, 'JOSEPH', NULL, 'LEE', NULL, NULL, '1', 0),
(76, 'KAROL JO', NULL, 'ALVAREZ', NULL, NULL, '1', 0),
(77, 'GERARDO', NULL, 'CHAVEZ', NULL, NULL, '1', 0),
(78, 'AUDY', NULL, 'ONG', NULL, NULL, '1', 0),
(79, 'MIKE', NULL, 'CORONAN', NULL, NULL, '1', 0),
(80, 'FRANCIS', NULL, 'LANUSA', NULL, NULL, '1', 0),
(81, 'PRINSESA HIYAS', NULL, 'LABAY', NULL, NULL, '1', 0),
(82, 'RALPH MC LEON', NULL, 'QUIJANO', NULL, NULL, '1', 0),
(83, 'SUMALPONG', NULL, 'DELIZA', NULL, NULL, '0', 0),
(84, 'CHRISTIAN', NULL, 'DADULAS', NULL, NULL, '1', 0),
(85, 'CHING', NULL, 'CABASE', NULL, NULL, '1', 0),
(86, 'RIZALINO', NULL, 'BULAGULAN', NULL, NULL, '1', 0),
(87, 'JAIME', NULL, 'PUBLICO', NULL, NULL, '1', 0),
(88, 'TEODORO', NULL, 'GALES', NULL, NULL, '1', 0),
(89, 'JOHN', NULL, 'CUA', NULL, NULL, '1', 0),
(90, 'DENNIS', NULL, 'YAP', NULL, NULL, '1', 0),
(91, 'BOY', NULL, 'SALAZAR', NULL, NULL, '1', 0),
(92, 'JOLO', NULL, 'CABALANG', NULL, NULL, '1', 0),
(93, 'ELPEDIO,JR.', NULL, 'LABRADOR', NULL, NULL, '1', 0),
(94, 'JONATHAN', NULL, 'CENTENO', NULL, NULL, '1', 0),
(95, 'JUNE IVY', NULL, 'ANG', NULL, NULL, '1', 0),
(96, 'ADRIANO', NULL, 'MARGUAX', NULL, NULL, '1', 0),
(97, 'MARCELO', NULL, 'CANOY', NULL, NULL, '1', 0),
(98, 'ROMMEL', NULL, 'TIMOJERA', NULL, NULL, '1', 0),
(99, 'DR.BORONGANAN', NULL, 'DR.', NULL, NULL, '1', 0),
(100, 'JB PHARMA', NULL, 'JB', NULL, NULL, '1', 0),
(101, 'JELESIS', NULL, 'TEVES', NULL, NULL, '1', 0),
(102, 'JOE', NULL, 'BUERANO', NULL, NULL, '1', 0),
(103, 'MARK', NULL, 'ABD', NULL, NULL, '1', 0),
(104, 'PHIL. ARMY', NULL, 'PHIL ARMY', NULL, NULL, '0', 0),
(105, 'JOEMAR', NULL, 'PENANONANG', NULL, NULL, '1', 0),
(106, 'NEUTON', NULL, 'QUIBLAT', NULL, NULL, '1', 0),
(107, 'DINO', NULL, 'LABITAD', NULL, NULL, '1', 0),
(108, 'DAVE', NULL, 'ALEGRADO', NULL, NULL, '1', 0),
(109, 'CARLO', NULL, 'AVILA', NULL, NULL, '1', 0),
(110, 'RYAN', NULL, 'MELITANTE', NULL, NULL, '1', 0),
(111, 'TSENG', NULL, 'PATRICK', NULL, NULL, '0', 0),
(112, 'RAUL', NULL, 'CABALANG', NULL, NULL, '1', 0),
(113, 'CRISTINO', NULL, 'OYEN', NULL, NULL, '1', 0),
(114, 'CRISTINO', NULL, 'EDRALIN', NULL, NULL, '1', 0),
(115, 'JOSHUA', NULL, 'BETIA', NULL, NULL, '1', 0),
(116, 'BOBBY', NULL, 'MALFERRARI', NULL, NULL, '1', 0),
(117, 'HEMBRADOR', NULL, 'HEMBRADOR', NULL, NULL, '1', 0),
(118, 'ELPEDIO', NULL, 'LABRADOR', NULL, NULL, '0', 0),
(119, 'ATTY. ARTURO', NULL, 'LEGASPI', NULL, NULL, '1', 0),
(120, 'RAMGUAN', NULL, 'KO', NULL, NULL, '1', 0),
(121, 'GOGOY', NULL, 'NAGAL', NULL, NULL, '1', 0),
(122, 'LEMUEL', NULL, 'PARANTAR', NULL, NULL, '1', 0),
(123, 'KRISTOPHER', NULL, 'ABELLANOSA', NULL, NULL, '1', 0),
(124, 'JAN IRENE', NULL, 'SMITH', NULL, NULL, '1', 0),
(125, 'RAYMOND', NULL, 'ANG', NULL, NULL, '1', 0),
(126, 'ROMMEL', NULL, 'TIMONERA', NULL, NULL, '1', 0),
(127, 'MICHAEL', NULL, 'IGNACIO', NULL, NULL, '1', 0),
(128, 'ENRIQUE', NULL, 'MABOLTO', NULL, NULL, '1', 0),
(129, 'DR. LORD SANNY', '', 'SALVAÑA', 'CAGAYAN', '088', '1', 0),
(130, 'HERMOGENES', NULL, 'NICDAO', NULL, NULL, '1', 0),
(131, 'THOMAS', NULL, 'YLANA', NULL, NULL, '1', 0),
(132, 'EIE MACHINE SHOP', NULL, 'EIE', NULL, NULL, '1', 0),
(133, 'BODJIE', NULL, 'SIAO', NULL, NULL, '1', 0),
(134, 'EVELYN', NULL, 'RAMOS', NULL, NULL, '1', 0),
(135, 'PAUL', NULL, 'AJO', NULL, NULL, '1', 0),
(136, 'ROSELYN', NULL, 'SAN BUENAVENTURA', NULL, NULL, '1', 0),
(137, 'ATTY. LEGASPI', NULL, 'ATTY.', NULL, NULL, '0', 0),
(138, 'ARLENE GRACE', NULL, 'PUGALES', NULL, NULL, '1', 0),
(139, 'MARK ANGEL', NULL, 'TORAYNO', NULL, NULL, '1', 0),
(140, 'RODOLFO', NULL, 'CAHULOGAN', NULL, NULL, '1', 0),
(141, 'GERARD', NULL, 'CHAVES', NULL, NULL, '1', 0),
(142, 'JOCEL', NULL, 'WAKABAYASHI', NULL, NULL, '1', 0),
(143, 'CLAUDIOS', NULL, 'ROKICKI', NULL, NULL, '1', 0),
(144, 'JOJO', NULL, 'EMBRADOR', NULL, NULL, '1', 0),
(145, 'ALVIN', NULL, 'PARAS', NULL, NULL, '1', 0),
(146, 'FERNANDO', NULL, 'MAMURI DE JESUS', NULL, NULL, '1', 0),
(147, 'DARLENE MAY', NULL, 'LAPUZ', NULL, NULL, '1', 0),
(148, 'MARK LESTER', NULL, 'SANTOS', NULL, NULL, '1', 0),
(149, 'CLINT PAUL', NULL, 'PLANTAS', NULL, NULL, '1', 0),
(150, 'LUISA', NULL, 'NANALE', NULL, NULL, '1', 0),
(151, 'JENNIFER', NULL, 'MIOLE', NULL, NULL, '1', 0),
(152, 'JING', NULL, 'EPARWA', NULL, NULL, '1', 0),
(153, 'STEAG STATE POWER', NULL, 'STATE', NULL, NULL, '1', 0),
(154, 'MEDICHEM', NULL, 'MEDICHEM PHARMACEUTICALS', NULL, NULL, '1', 0),
(155, 'DELIZA', NULL, 'SUMALPONG', NULL, NULL, '1', 0),
(156, 'MYCO CARLO', NULL, 'PERNES', NULL, NULL, '1', 0),
(157, 'TEDDY', NULL, 'CABALTES', NULL, NULL, '1', 0),
(158, 'TOPHE', NULL, 'PEREZ', NULL, NULL, '1', 0),
(159, 'KEN', NULL, 'MAGNO', NULL, NULL, '1', 0),
(160, 'JIE', NULL, 'TAHA', NULL, NULL, '1', 0),
(161, 'DR. BEN', NULL, 'ALBANECE', NULL, NULL, '1', 0),
(162, 'RHAYA', NULL, 'FEBRERO', NULL, NULL, '1', 0),
(163, 'ATTY. PAREÑO', NULL, 'ATTY. PAREÑO', NULL, NULL, '1', 0),
(164, 'MICHAEL', NULL, 'CHAVES', NULL, NULL, '1', 0),
(165, 'MARK', NULL, 'DIZON', NULL, NULL, '1', 0),
(166, 'OLIVE', NULL, 'TUMULAK', NULL, NULL, '1', 0),
(167, 'TEDDY', NULL, 'CABELTES', NULL, NULL, '1', 0),
(168, 'JOSEPH', NULL, 'ACUZAR', NULL, NULL, '1', 0),
(169, 'ROLAND', NULL, 'OLLOVES', NULL, NULL, '1', 0),
(170, 'JAIREH', NULL, 'BRACAMONTE', NULL, NULL, '1', 0),
(171, 'FRANCIS', NULL, 'LIM', NULL, NULL, '1', 0),
(172, 'CUNARD', NULL, 'CAHARIAN', NULL, NULL, '1', 0),
(173, 'KARR', NULL, 'JACKSON', NULL, NULL, '1', 0),
(174, 'BOBBY', NULL, 'CANAPIA', NULL, NULL, '1', 0),
(175, 'FLORENCIO', NULL, 'LUMUSAD', NULL, NULL, '1', 0),
(176, 'ALEXIS', NULL, 'EMATA', NULL, NULL, '1', 0),
(177, 'OSIAS', NULL, 'CAROSA', NULL, NULL, '1', 0),
(178, 'MANTO', NULL, 'UY', NULL, NULL, '1', 0),
(179, 'MRS. GUEVARRA', NULL, 'GUEVARRA', NULL, NULL, '1', 0),
(180, 'ROBERT', NULL, 'CRUZ', NULL, NULL, '1', 0),
(181, 'ROSE', NULL, 'BUENAVENTURA', NULL, NULL, '1', 0),
(182, 'ATTY. LEGASPI', NULL, 'ATTY.LEGASPI', NULL, NULL, '0', 0),
(183, 'GEORGE', NULL, 'QUIMPO', NULL, NULL, '1', 0),
(184, 'ALDRIN', NULL, 'TY', NULL, NULL, '1', 0),
(185, 'METALITE', NULL, 'METALITE', NULL, NULL, '1', 0),
(186, 'FELOMINO', NULL, 'NOCIAN', NULL, NULL, '1', 0),
(187, 'ROEL', NULL, 'DE LEON', NULL, NULL, '1', 0),
(188, 'BOBI', NULL, 'DAGUS', NULL, NULL, '1', 0),
(189, 'DENNIS', NULL, 'ASIO', NULL, NULL, '1', 0),
(190, 'JOHN ROI', NULL, 'MANALASTAS', NULL, NULL, '1', 0),
(191, 'JB PHARMA', NULL, 'JB PHARMA', NULL, NULL, '0', 0),
(192, 'LORREY DIANNE', NULL, 'CHIONG', NULL, NULL, '1', 0),
(193, 'ROLANDO', NULL, 'BAUZON', NULL, NULL, '1', 0),
(194, 'LOUELA', NULL, 'MAÑA', NULL, NULL, '1', 0),
(195, 'MICHAEL', NULL, 'PALARCA', NULL, NULL, '1', 0),
(196, 'NELSON', NULL, 'FLORES', NULL, NULL, '1', 0),
(197, 'GEORGE', NULL, 'SERDEÑA', NULL, NULL, '1', 0),
(198, 'KOON', NULL, 'GO', NULL, NULL, '1', 0),
(199, 'REY', NULL, 'ROXAS', NULL, NULL, '1', 0),
(200, 'MAY RHEZA', NULL, 'BOQUIA', NULL, NULL, '1', 0),
(201, 'JOCELYN', NULL, 'HERNANDEZ', NULL, NULL, '1', 0),
(202, 'RICHARD', NULL, 'PINOTE', NULL, NULL, '1', 0),
(203, 'ARIEL', NULL, 'AMENE', NULL, NULL, '1', 0),
(204, 'PAOLO', NULL, 'JARAULA', NULL, NULL, '1', 0),
(205, 'JIGGER JOHN', NULL, 'GEVERO', NULL, NULL, '1', 0),
(206, 'ALEX', NULL, 'LAURON', NULL, NULL, '1', 0),
(207, 'GASPAR', NULL, 'HABUG', NULL, NULL, '1', 0),
(208, 'EDWIN', NULL, 'ELORDE', NULL, NULL, '1', 0),
(209, 'JOHN', NULL, 'MACHATE', NULL, NULL, '1', 0),
(210, 'BONG', NULL, 'ANECITO', NULL, NULL, '1', 0),
(211, 'JING', NULL, 'BRUNO', NULL, NULL, '1', 0),
(212, 'GRACE', NULL, 'ALCANTARA', NULL, NULL, '1', 0),
(213, 'AL MARTIN', NULL, 'PARANTAR', NULL, NULL, '1', 0),
(214, 'ROMAN', NULL, 'ALBASIN', NULL, NULL, '1', 0),
(215, 'DARLENE', NULL, 'LAPUZ', NULL, NULL, '1', 0),
(216, 'MA. CARMELITA', NULL, 'ALVAREZ', NULL, NULL, '1', 0),
(217, 'CHARMAE', NULL, 'JANAYON', NULL, NULL, '1', 0),
(218, 'AL GAUVIN', NULL, 'LABUNTOG', NULL, NULL, '1', 0),
(219, 'ASHBY MARIE', NULL, 'SALAZAR', NULL, NULL, '1', 0),
(220, 'JANICE', NULL, 'JANIOSA', NULL, NULL, '1', 0),
(221, 'MON', NULL, 'MEDINA', NULL, NULL, '1', 0),
(222, 'HON. ROELITO', NULL, 'GAWILAN', NULL, NULL, '1', 0),
(223, 'JAIREH MAY', NULL, 'BRACAMONTE', NULL, NULL, '1', 0),
(224, 'JANICE', NULL, 'JANIOSO', NULL, NULL, '1', 0),
(225, 'MANNY', NULL, 'DUWA', NULL, NULL, '1', 0),
(226, 'HIMEX', NULL, 'HIMEX COOP', NULL, NULL, '1', 0),
(227, 'AILEEN', NULL, 'PALAD', NULL, NULL, '1', 0),
(228, 'ROCHELLE', NULL, 'CANO', NULL, NULL, '1', 0),
(229, 'STARGATE', NULL, 'STARGET', NULL, NULL, '1', 0),
(230, 'BASIC PHARMA', NULL, 'BASIC', NULL, NULL, '1', 0),
(231, 'JERITZ', NULL, 'BALDADO', NULL, NULL, '1', 0),
(232, 'BOY', NULL, 'DOSDOS', NULL, NULL, '1', 0),
(233, 'JHOSTONI', NULL, 'GO', NULL, NULL, '1', 0),
(234, 'DENNIS', NULL, 'UY', NULL, NULL, '1', 0),
(235, 'PAUL', NULL, 'BACANDA', NULL, NULL, '1', 0),
(236, 'MIKE', NULL, 'CAPINPUYAN', NULL, NULL, '1', 0),
(237, 'EDSEL', NULL, 'BALINTAG', NULL, NULL, '1', 0),
(238, 'ROBINSON', NULL, 'TAN', NULL, NULL, '1', 0),
(239, 'JOHN PAUL', NULL, 'GO', NULL, NULL, '1', 0),
(240, 'KHARIS', NULL, 'JANNY', NULL, NULL, '1', 0),
(241, 'EDISON', NULL, 'GRAMATA', NULL, NULL, '1', 0),
(242, 'JESS', NULL, 'VERGARA', NULL, NULL, '1', 0),
(243, 'KARL', NULL, 'TALINGTING', NULL, NULL, '1', 0),
(244, 'EMMANUEL', NULL, 'PIMENTEL', NULL, NULL, '1', 0),
(245, 'FRANCISCO', NULL, 'BUCTUAN', NULL, NULL, '1', 0),
(246, 'GUSTAVO', NULL, 'ANSALDO', NULL, NULL, '1', 0),
(247, 'DAVID', NULL, 'JOHANSON', NULL, NULL, '1', 0),
(248, 'ROBERT', NULL, 'JIMENEZ', NULL, NULL, '1', 0),
(249, 'APOLLO', NULL, 'LEE', NULL, NULL, '1', 0),
(250, 'LOVELLA', NULL, 'MAÑA', NULL, NULL, '1', 0),
(251, 'ALESSANDRA', NULL, 'JAVIER', NULL, NULL, '1', 0),
(252, 'RUDY', NULL, 'GALCERAN', NULL, NULL, '1', 0),
(253, 'FIRMACION II', NULL, 'SERG', NULL, NULL, '1', 0),
(254, 'JUVY', NULL, 'PEETERS', NULL, NULL, '1', 0),
(255, 'REY', NULL, 'VILLAFRANCA', NULL, NULL, '1', 0),
(256, 'FELIMON', NULL, 'KHO', NULL, NULL, '1', 0),
(257, 'JAYSON', NULL, 'MARTINEZ', NULL, NULL, '1', 0),
(258, 'FR. CLAUDIOS', NULL, 'FR. CLAUDIOS', NULL, NULL, '1', 0),
(259, 'ANNABEL', NULL, 'KHO', NULL, NULL, '1', 0),
(260, 'DR. SARMIENTO NIÑO', NULL, 'DR. SARMIENTO', NULL, NULL, '1', 0),
(261, 'PAOLO', NULL, 'BAUTISTA', NULL, NULL, '1', 0),
(262, 'ACSARA', NULL, 'GUMAL', NULL, NULL, '1', 0),
(263, 'ASCARA', NULL, 'GUMAL', NULL, NULL, '1', 0),
(264, 'LOI', NULL, 'DABA', NULL, NULL, '1', 0),
(265, 'REY', NULL, 'MORTIZ', NULL, NULL, '1', 0),
(266, 'ISABEL', NULL, 'ADELANTE', NULL, NULL, '1', 0),
(267, 'JOVY', NULL, 'PEETERS', NULL, NULL, '1', 0),
(268, 'NASSHIP', NULL, 'HASSAN', NULL, NULL, '1', 0),
(269, 'IAN', NULL, 'CABANATAN', NULL, NULL, '1', 0),
(270, 'DR. CALINGASAN', NULL, 'DR. CALINGASAN', NULL, NULL, '1', 0),
(271, 'DR.SARMIENTO', NULL, 'DR. SARMIENTO', NULL, NULL, '1', 0),
(272, 'KIMSLE', NULL, 'NISPEROS', NULL, NULL, '1', 0),
(273, 'AMY', NULL, 'MALFERRARI', NULL, NULL, '1', 0),
(274, 'JONATHAN', NULL, 'ROSARIO', NULL, NULL, '1', 0),
(275, 'RYAN', NULL, 'MORTIZ', NULL, NULL, '1', 0),
(276, 'NICK', NULL, 'RAMOS', NULL, NULL, '1', 0),
(277, 'BEBOT', NULL, 'BEBOT', NULL, NULL, '1', 0),
(278, 'SONNY', NULL, 'MANUAL', NULL, NULL, '1', 0),
(279, 'DANTE', NULL, 'JAYSON', NULL, NULL, '1', 0),
(280, 'ARLENE', NULL, 'LABIAL', NULL, NULL, '1', 0),
(281, 'JOY', NULL, 'AVILA', NULL, NULL, '1', 0),
(282, 'WALK-IN', NULL, 'WALK-IN', NULL, NULL, '1', 0),
(283, 'DEL ROSARIO', NULL, 'DEL ROSARIO', NULL, NULL, '1', 0),
(284, 'ROBERT', NULL, 'BANSE', NULL, NULL, '1', 0),
(285, 'ARLENE JOY', NULL, 'LABIAL', NULL, NULL, '1', 0),
(286, 'ATTY. YOYOC', NULL, 'YAP', NULL, NULL, '1', 0),
(287, 'SERGIO', NULL, 'YAP', NULL, NULL, '1', 0),
(288, 'ROMMEL', NULL, 'KIAMCO', NULL, NULL, '1', 0),
(289, 'JACKY', NULL, 'JACKY', NULL, NULL, '1', 0),
(290, 'MARK GERARD', NULL, 'DIZON', NULL, NULL, '1', 0),
(291, 'JOSEPH', NULL, 'ESCOBAR', NULL, NULL, '1', 0),
(292, 'MA. TERESA', NULL, 'LOW', NULL, NULL, '1', 0),
(293, 'RAMON', NULL, 'MEDINA', NULL, NULL, '1', 0),
(294, 'PHILLIP BENJAMIN', NULL, 'CAJULAO', NULL, NULL, '1', 0),
(295, 'MIKHAEL', NULL, 'BAUTISTA', NULL, NULL, '1', 0),
(296, 'VINCE EDUARD', NULL, 'AGNES', NULL, NULL, '1', 0),
(297, 'RUEL, JR', NULL, 'SAA', NULL, NULL, '1', 0),
(298, 'FRANCIS', NULL, 'LANUZA', NULL, NULL, '1', 0),
(299, 'PLANET SPEED', NULL, 'PLANET SPEED', NULL, NULL, '1', 0),
(300, 'BENJO', NULL, 'SY', NULL, NULL, '1', 0),
(301, 'IAN', NULL, 'CABANTAN', NULL, NULL, '1', 0),
(302, 'EDUARDO', NULL, 'ALMIRANTE', NULL, NULL, '1', 0),
(303, 'CLAIRE', NULL, 'BELLO', NULL, NULL, '1', 0),
(304, 'JEFFREY', NULL, 'SY', NULL, NULL, '1', 0),
(305, 'SIMON', NULL, 'BAUTISTA', NULL, NULL, '1', 0),
(306, 'GERALD', NULL, 'SUMILE', NULL, NULL, '1', 0),
(307, 'JAE', NULL, 'SOLEVA', NULL, NULL, '1', 0),
(308, 'TONIO', NULL, 'CAAMIÑO', NULL, NULL, '1', 0),
(309, 'PETER', NULL, 'ROSARIO', NULL, NULL, '1', 0),
(310, 'ALMA', NULL, 'SALDUA', NULL, NULL, '1', 0),
(311, 'BOJIE', NULL, 'BOJIE', NULL, NULL, '1', 0),
(312, 'MR. SY', NULL, 'MR. SY', NULL, NULL, '1', 0),
(313, 'LOUELLA', NULL, 'MAÑA', NULL, NULL, '1', 0),
(314, 'PAGAYAMON', NULL, 'PAGAYAMON', NULL, NULL, '1', 0),
(315, 'ERWIN', NULL, 'SIGNO', NULL, NULL, '1', 0),
(316, 'DSEOGRACIA', NULL, 'BAUTISTA', NULL, NULL, '1', 0),
(317, 'ARVY', NULL, 'BERDIDA', NULL, NULL, '1', 0),
(318, 'ORIENTAL & MOTOLITE', NULL, 'MKTG. CORP', NULL, NULL, '1', 0),
(319, 'JOEMAR', NULL, 'ALOVA', NULL, NULL, '1', 0),
(320, 'LEONARD', NULL, 'FARIN', NULL, NULL, '1', 0),
(321, 'RICHELLE', NULL, 'AYCO', NULL, NULL, '1', 0),
(322, 'FREDO', NULL, 'MADRONA', NULL, NULL, '1', 0),
(323, 'MA. REYNA HOSPITAL', NULL, 'XAVIER UNIVERSITY HOSPITAL', NULL, NULL, '1', 0),
(324, 'GABRIEL', NULL, 'ARANJUEZ', NULL, NULL, '1', 0),
(325, 'ANDRELITO', NULL, 'GUZMAN', NULL, NULL, '1', 0),
(326, 'FR. JOBEL', NULL, 'FR. JOBEL', NULL, NULL, '1', 0),
(327, 'NARCISO', NULL, 'YBAÑEZ', NULL, NULL, '1', 0),
(328, 'MA. THERESA', NULL, 'GALLARDO', NULL, NULL, '1', 0),
(329, 'GESTER', NULL, 'YU', NULL, NULL, '1', 0),
(330, 'DIAMOND', NULL, 'LOGISTIC', NULL, NULL, '1', 0),
(331, 'CHRISTINE', NULL, 'BDO', NULL, NULL, '1', 0),
(332, 'JERRY', NULL, 'BOG-OS', NULL, NULL, '1', 0),
(333, 'KIMBLE', NULL, 'KIMBLE', NULL, NULL, '1', 0),
(334, 'JOEMAR', NULL, 'ALONA', NULL, NULL, '1', 0),
(335, 'DBP', NULL, 'DBP', NULL, NULL, '1', 0),
(336, 'CARLO', NULL, 'LIMJOCO', NULL, NULL, '1', 0),
(337, 'JING', NULL, 'EMPARWA', NULL, NULL, '0', 0),
(338, 'CEPALCO', NULL, 'CEPALCO', NULL, NULL, '1', 0),
(339, 'AGRINANAS', NULL, 'AGRINANAS', NULL, NULL, '1', 0),
(340, 'AIMEE', NULL, 'HONA', NULL, NULL, '1', 0),
(341, 'REY', NULL, 'MONDEGO', NULL, NULL, '1', 0),
(342, 'LUDY', NULL, 'CASIÑO', NULL, NULL, '1', 0),
(343, 'LEA', NULL, 'LARCO', NULL, NULL, '1', 0),
(344, 'MULTICARE', NULL, 'MULTICARE', NULL, NULL, '1', 0),
(345, 'KHARIS', NULL, 'JANAYON', NULL, NULL, '1', 0),
(346, 'DRA. FLORES', NULL, 'DRA. FLORES', NULL, NULL, '1', 0),
(347, 'RAY', NULL, 'MONDIGO', NULL, NULL, '1', 0),
(348, 'J', NULL, 'CARHUT', NULL, NULL, '1', 0),
(349, 'JACKY', NULL, 'SY', NULL, NULL, '1', 0),
(350, 'KIMBLE', NULL, 'NISPEROS', NULL, NULL, '1', 0),
(351, 'BRYAN', NULL, 'BRYAN', NULL, NULL, '1', 0),
(352, 'FERDINAND', NULL, 'PABILONA', NULL, NULL, '1', 0),
(353, 'JONG', NULL, 'SEVILLA', NULL, NULL, '1', 0),
(354, 'CHE2X', NULL, 'BDO', NULL, NULL, '1', 0),
(355, 'SABINO', NULL, 'MABOLO', NULL, NULL, '1', 0),
(356, 'PINKY', NULL, 'BARRIOS', NULL, NULL, '1', 0),
(357, 'JOY', NULL, 'JOY', NULL, NULL, '1', 0),
(358, 'RICHARD', NULL, 'TEE', NULL, NULL, '1', 0),
(359, 'ELENO', NULL, 'DOSDOS', NULL, NULL, '1', 0),
(360, 'CONGLASCO', NULL, 'CONGLASCO', NULL, NULL, '1', 0),
(361, 'ELI', NULL, 'LILLY', NULL, NULL, '1', 0),
(362, 'SYNTACTICS', NULL, 'SYNTACTICS', NULL, NULL, '1', 0),
(363, 'ROBIN', NULL, 'JICABAO', NULL, NULL, '1', 0),
(364, 'SACRED HEART OF JESUS', NULL, 'SACRED', NULL, NULL, '1', 0),
(365, 'IKE', NULL, 'EDUAVE', NULL, NULL, '1', 0),
(366, 'KRISTINE', NULL, 'BDO', NULL, NULL, '1', 0),
(367, 'KENNY', NULL, 'SERQUIÑA', NULL, NULL, '0', 0),
(368, 'GEMMA', NULL, 'BDO/ HINLO', NULL, NULL, '1', 0),
(369, 'MERLYN', NULL, 'TACANDONG', NULL, NULL, '1', 0),
(370, 'BONG', NULL, 'BONG', NULL, NULL, '1', 0),
(371, 'EDNA', NULL, 'BORJA', NULL, NULL, '1', 0),
(372, 'ELIZA', NULL, 'ELIZA', NULL, NULL, '1', 0),
(373, 'JELLY', NULL, 'GABUCAN', NULL, NULL, '1', 0),
(374, 'GARRY', NULL, 'CORTEZ', NULL, NULL, '1', 0),
(375, 'HEIDE', NULL, 'CAPAMPANGAN', NULL, NULL, '1', 0),
(376, 'ALFRED', NULL, 'SY', NULL, NULL, '1', 0),
(377, 'ARON', NULL, 'RAVANERA', NULL, NULL, '1', 0),
(378, 'JERRY', NULL, 'GALVEZ', NULL, NULL, '0', 0),
(379, 'MARIO', NULL, 'GUEVARRA', NULL, NULL, '1', 0),
(380, 'IBRAHIM', NULL, 'IBB', NULL, NULL, '1', 0),
(381, 'MARVIN', NULL, 'TORRES', NULL, NULL, '1', 0),
(382, 'PAOLO', NULL, 'ACENAS', NULL, NULL, '1', 0),
(383, 'FRANCIS JOSEPH', NULL, 'DECIERDO', NULL, NULL, '1', 0),
(384, 'PHILIP BENJAMIN', NULL, 'CAJULAO', NULL, NULL, '1', 0),
(385, 'JERIKO', NULL, 'ALMODOBAR', NULL, NULL, '1', 0),
(386, 'FRESH', NULL, 'FRUITS', NULL, NULL, '1', 0),
(387, 'FERNANDO', NULL, 'TIU', NULL, NULL, '1', 0),
(388, 'JONY', NULL, 'TONGCO', NULL, NULL, '1', 0),
(389, 'IRENE', NULL, 'CUTAR', NULL, NULL, '1', 0),
(390, 'PHILIP', NULL, 'QUIMPO', NULL, NULL, '1', 0),
(391, 'MAAM BING', NULL, 'MAAM BING', NULL, NULL, '0', 0),
(392, 'PHILIP', NULL, 'BUNAGAN', NULL, NULL, '1', 0),
(393, 'ERIC', NULL, 'GARCIA', NULL, NULL, '1', 0),
(394, 'DR. GEORGE', NULL, 'CARBAJAL', NULL, NULL, '1', 0),
(395, 'BESTBAKE', NULL, 'BESTBAKE', NULL, NULL, '1', 0),
(396, 'NUTRI-ASIA', NULL, 'INC.', NULL, NULL, '1', 0),
(397, 'TOMMY', NULL, 'TOMMY', NULL, NULL, '1', 0),
(398, 'BEBIE', NULL, 'TUMANG', NULL, NULL, '1', 0),
(399, 'ODYSSEY DRIVING SCHOOL', NULL, 'ODEYSSEY', NULL, NULL, '1', 0),
(400, 'VOLT WILMER', '  ', 'MENESES', '  CDO', '088 ', '1', 0),
(401, 'RIZAL', '  ', 'RIZAL', '  CDO', '088 ', '1', 0),
(402, 'SGT. BANSE', '  ', 'BANSE', '  CDO', '088', '1', 0),
(403, 'PROEL', '  ', 'MOFAR/ZUELLIG PHARMA', '  CDO', '088 ', '1', 4),
(404, 'MR. GABRIEL', 'V.', 'UMEREZ', 'CAGAYAN', '088', '1', 0),
(405, 'MR. PROEL', '  ', 'MOFAR', '  CAGAYAN', '088 ', '1', 0),
(406, 'PROSEL', '  ', 'PHARMA', '  CAGAYAN', '088 ', '1', 0);

-- --------------------------------------------------------

--
-- Table structure for table `dcr`
--

CREATE TABLE IF NOT EXISTS `dcr` (
  `dcr_id` int(11) NOT NULL AUTO_INCREMENT,
  `trnxdate` date DEFAULT NULL,
  `begbal` decimal(8,2) DEFAULT NULL,
  `cashier` tinyint(4) DEFAULT NULL,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`dcr_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `dcr`
--

INSERT INTO `dcr` (`dcr_id`, `trnxdate`, `begbal`, `cashier`, `status`) VALUES
(3, '2013-07-01', '1500.00', 11, '1');

-- --------------------------------------------------------

--
-- Table structure for table `dcrdetails`
--

CREATE TABLE IF NOT EXISTS `dcrdetails` (
  `dcr_id` int(11) NOT NULL DEFAULT '0',
  `dcrdtl_id` int(11) NOT NULL AUTO_INCREMENT,
  `particulars` mediumtext,
  `refno` varchar(15) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `tender` tinyint(4) DEFAULT '0',
  UNIQUE KEY `dcrdtl_id` (`dcrdtl_id`),
  KEY `FK_dcrdetails_1` (`dcr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `joborder`
--

CREATE TABLE IF NOT EXISTS `joborder` (
  `jo_id` int(11) NOT NULL AUTO_INCREMENT,
  `jo_number` varchar(75) DEFAULT NULL,
  `v_id` int(11) DEFAULT NULL,
  `customer` int(11) DEFAULT '0',
  `plate` varchar(50) DEFAULT NULL,
  `color` int(11) DEFAULT '0',
  `contactnumber` varchar(75) DEFAULT NULL,
  `address` mediumtext,
  `trnxdate` date DEFAULT NULL,
  `tax` decimal(8,2) DEFAULT '0.00',
  `discount` decimal(8,2) DEFAULT '0.00',
  `status` enum('0','1') DEFAULT '1',
  `billed` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`jo_id`),
  UNIQUE KEY `indxJO` (`jo_number`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity' AUTO_INCREMENT=181 ;

--
-- Dumping data for table `joborder`
--

INSERT INTO `joborder` (`jo_id`, `jo_number`, `v_id`, `customer`, `plate`, `color`, `contactnumber`, `address`, `trnxdate`, `tax`, `discount`, `status`, `billed`) VALUES
(1, '000001', 1, 4, ' MFN122 -- MULTICAB', 0, NULL, NULL, '2013-01-02', '0.00', '0.00', '1', '0'),
(2, '000002', 2, 3, ' KHU111 -- HONDA CR-V', 0, NULL, NULL, '2013-01-02', '0.00', '0.00', '1', '0'),
(3, '000003', 3, 7, ' MFB115 -- CHEVROLET SPARK', 0, NULL, NULL, '2013-01-04', '0.00', '10.00', '1', '0'),
(4, '000004', 4, 5, ' UAR731 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(5, '000005', 5, 8, ' NOPLATE -- NO MAKE', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(6, '000006', 6, 9, ' KCT107 -- TOYOTA REVO', 0, NULL, NULL, '2012-12-19', '0.00', '0.00', '1', '0'),
(7, '000007', 7, 19, ' KCK965 -- TOYOTA REVO -2001', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(8, '000008', 7, 19, ' KCK965 -- TOYOTA REVO -2001', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(9, '000009', 8, 317, ' PQM689 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(10, '000010', 9, 399, ' KDE550 -- HONDA CITY', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(11, '000011', 10, 104, ' KCU764 -- TOYOTA HI-ACE GRANDIA', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1', '0'),
(12, '000012', 11, 15, ' KEL935 -- HONDA CIVIC FD-10', 0, NULL, NULL, '2012-12-12', '0.00', '0.00', '1', '0'),
(13, '000013', 12, 16, ' KEJ416 -- HONDA CIVIC ''96', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(14, '000014', 13, 295, ' ZLJ949 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(15, '000015', 14, 400, ' WNA461 -- TOYOTA CAMRY 2000', 0, NULL, NULL, '2012-12-28', '0.00', '0.00', '1', '0'),
(16, '000016', 15, 401, ' KCZ656 -- TOYOTA REVO', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(17, '000017', 7, 19, ' KCK965 -- TOYOTA REVO -2001', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(18, '000018', 16, 20, ' KBP657 -- CHARADE', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(19, '000019', 17, 21, ' GEN732 -- ISUZU TFR', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(20, '000020', 18, 402, ' KFU553 -- MITSUBISHI ECLAPSE', 0, NULL, NULL, '2012-12-03', '0.00', '0.00', '1', '0'),
(21, '000021', 19, 23, ' ZKP920 -- HONDA CITY VTEC', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(22, '000022', 20, 24, ' KDM249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-12', '0.00', '0.00', '1', '0'),
(23, '000023', 21, 25, ' UKA563 -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(24, '000024', 22, 26, ' NOL541 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(25, '000025', 23, 50, ' NQV326 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-08', '0.00', '0.00', '1', '0'),
(26, '000026', 24, 50, ' KVU924 -- MITSUBISHI L300', 0, NULL, NULL, '2012-12-17', '0.00', '0.00', '1', '0'),
(27, '000027', 25, 28, ' NOA844 -- NISSAN URBAN ''09', 0, NULL, NULL, '2013-01-02', '0.00', '800.00', '1', '0'),
(28, '000028', 26, 29, ' KCM313 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-01-02', '0.00', '0.00', '1', '0'),
(29, '000029', 27, 326, ' KCC437 -- ISUZU HI-LANDER', 0, NULL, NULL, '2013-01-11', '0.00', '0.00', '1', '0'),
(30, '000030', 28, 31, ' KGF430 -- MATIZ', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(31, '000031', 29, 32, ' NQL699 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-01-15', '0.00', '0.00', '1', '0'),
(32, '000032', 3, 7, ' MFB115 -- CHEVROLET SPARK', 0, NULL, NULL, '2013-01-11', '0.00', '0.00', '1', '0'),
(33, '000033', 13, 295, ' ZLJ949 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-01-16', '0.00', '0.00', '1', '0'),
(34, '000034', 30, 143, ' KCZ588 -- HONDA CITY', 0, NULL, NULL, '2013-01-14', '0.00', '0.00', '1', '0'),
(35, '000035', 31, 34, ' TJD176 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-10', '0.00', '0.00', '1', '0'),
(36, '000036', 32, 133, ' KDE510 -- KIA PICANTO', 0, NULL, NULL, '2013-01-09', '0.00', '80.00', '1', '0'),
(37, '000037', 33, 36, ' UAH908 -- TAMARAW FX', 0, NULL, NULL, '2013-01-14', '0.00', '0.00', '1', '0'),
(38, '000038', 34, 218, ' POK765 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1', '0'),
(39, '000039', 36, 40, ' GPX640 -- ISUZU ELF', 0, NULL, NULL, '2013-01-16', '0.00', '0.00', '1', '0'),
(40, '000040', 37, 41, ' ZTR517 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2012-12-06', '0.00', '0.00', '1', '0'),
(41, '000041', 3, 7, ' MFB115 -- CHEVROLET SPARK', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1', '0'),
(42, '000042', 38, 104, ' KCS463 -- ISUZU FUEGO', 0, NULL, NULL, '2012-11-26', '0.00', '0.00', '1', '0'),
(43, '000043', 38, 104, ' KCS463 -- ISUZU FUEGO', 0, NULL, NULL, '2013-01-17', '0.00', '0.00', '1', '0'),
(44, '000044', 34, 218, ' POK765 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1', '0'),
(45, '000045', 39, 43, ' JBS789 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-01-17', '0.00', '0.00', '1', '0'),
(46, '000046', 40, 44, ' OEV356 -- TOYOTA HI-LUX ''95', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(47, '000047', 41, 47, ' KER975 -- HONDA CITY', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1', '0'),
(48, '000048', 31, 34, ' TJD176 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1', '0'),
(49, '000049', 42, 49, ' KDA668 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-01-28', '0.00', '9.00', '1', '0'),
(50, '000050', 31, 34, ' TJD176 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1', '0'),
(51, '000051', 23, 50, ' NQV326 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1', '0'),
(52, '000052', 23, 50, ' NQV326 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-22', '0.00', '0.00', '1', '0'),
(53, '000053', 1, 4, ' MFN122 -- MULTICAB', 0, NULL, NULL, '2013-01-25', '0.00', '10.00', '1', '0'),
(54, '000054', 43, 82, ' ZKP420 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-26', '0.00', '10.00', '1', '0'),
(55, '000055', 20, 24, ' KDM249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-26', '0.00', '0.00', '1', '0'),
(56, '000056', 44, 54, ' XGJ146 -- TOYOTA REVO', 0, NULL, NULL, '2012-11-28', '0.00', '30.00', '1', '0'),
(57, '000057', 45, 55, ' UKD396 -- HONDA ACCORD', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1', '0'),
(58, '000058', 42, 49, ' KDA668 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-01-11', '0.00', '0.00', '1', '0'),
(59, '000059', 46, 56, ' NKO676 -- FORD RANGER PICK-UP', 0, NULL, NULL, '2012-06-23', '0.00', '0.00', '1', '0'),
(60, '000060', 47, 58, ' ZLT784 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-30', '0.00', '0.00', '1', '0'),
(61, '000061', 32, 133, ' KDE510 -- KIA PICANTO', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1', '0'),
(62, '000062', 48, 404, ' KEL985 -- ISUZU DMAX 2010', 0, NULL, NULL, '2012-12-11', '0.00', '0.00', '1', '0'),
(63, '000063', 49, 48, ' AAA000 -- HONDA CIVIC', 0, NULL, NULL, '2013-01-24', '0.00', '0.00', '1', '0'),
(64, '000064', 50, 39, ' XHV832 -- HONDA CR-V', 0, NULL, NULL, '2013-01-02', '0.00', '0.00', '1', '0'),
(65, '000065', 51, 405, ' ZKP921 -- HONDA CITY 2006', 0, NULL, NULL, '2013-01-15', '0.00', '0.00', '1', '0'),
(66, '000066', 29, 32, ' NQL699 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-01-31', '0.00', '0.00', '1', '0'),
(67, '000067', 52, 59, ' XJC760 -- HONDA CR-V', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1', '0'),
(68, '000068', 54, 62, ' YEZ620 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1', '0'),
(69, '000069', 55, 63, ' AAB001 -- MITSUBISHI L200', 0, NULL, NULL, '2013-02-04', '0.00', '0.00', '1', '0'),
(70, '000070', 56, 64, ' ZJW965 -- NISSAN FRONTIER ''07', 0, NULL, NULL, '2013-02-04', '0.00', '6.25', '1', '0'),
(71, '000071', 56, 64, ' ZJW965 -- NISSAN FRONTIER ''07', 0, NULL, NULL, '2012-11-29', '0.00', '0.00', '1', '0'),
(72, '000072', 1, 4, ' MFN122 -- MULTICAB', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1', '0'),
(73, '000073', 58, 66, ' AAC002 --  Mitsubishi  ', 0, NULL, NULL, '2013-02-05', '0.00', '0.00', '1', '0'),
(74, '000074', 59, 132, ' KEG189 -- HONDA IMPORTER', 0, NULL, NULL, '2013-01-30', '0.00', '0.00', '1', '0'),
(75, '000075', 60, 68, ' GTB254 -- MITSUBISHI LANCER ''93-95', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1', '0'),
(76, '000076', 61, 204, ' KBU537 -- TOYOTA TAMARAW FX', 0, NULL, NULL, '2013-02-06', '0.00', '0.00', '1', '0'),
(77, '000077', 61, 204, ' KBU537 -- TOYOTA TAMARAW FX', 0, NULL, NULL, '2013-02-05', '0.00', '2.33', '1', '0'),
(78, '000078', 62, 406, ' TPS526 -- NISSAN SENTRA GA13', 0, NULL, NULL, '2013-01-09', '0.00', '0.00', '1', '0'),
(79, '000079', 63, 71, ' ZGP662 -- HYUNDAI GETZ1.1M/T', 0, NULL, NULL, '2013-01-26', '0.00', '0.00', '1', '0'),
(80, '000080', 63, 71, ' ZGP662 -- HYUNDAI GETZ1.1M/T', 0, NULL, NULL, '2013-01-26', '0.00', '0.00', '1', '0'),
(81, '000081', 20, 24, ' KDM249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1', '0'),
(82, '000082', 64, 73, ' PBO950 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-31', '0.00', '0.00', '1', '0'),
(83, '000083', 65, 74, ' KCH342 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1', '0'),
(84, '000084', 66, 75, ' ZTR740 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1', '0'),
(85, '000085', 67, 76, ' ZPE142 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(86, '000086', 67, 76, ' ZPE142 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1', '0'),
(87, '000087', 68, 141, ' KFY684 -- HONDA FIT', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1', '0'),
(88, '000088', 69, 78, ' KFN437 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1', '0'),
(89, '000089', 22, 26, ' NOL541 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-30', '0.00', '0.00', '1', '0'),
(90, '000090', 70, 80, ' ZTR990 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(91, '000091', 71, 81, ' ZKP410 -- TOYOTA VIOS 2007-2008', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1', '0'),
(92, '000092', 43, 82, ' ZKP420 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-23', '0.00', '0.00', '1', '0'),
(93, '000093', 72, 155, ' ZRW466 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-01-24', '0.00', '0.00', '1', '0'),
(94, '000094', 73, 84, ' PMB177 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-06', '0.00', '0.00', '1', '0'),
(95, '000095', 74, 85, ' KGJ185 -- HYUNDAI STAREX ''02', 0, NULL, NULL, '2013-02-09', '0.00', '0.00', '1', '0'),
(96, '000096', 75, 86, ' KDP703 -- MITSUBISHI STRADA 2004', 0, NULL, NULL, '2013-01-28', '0.00', '300.00', '1', '0'),
(97, '000097', 76, 87, ' AAC003 -- Honda', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1', '0'),
(98, '000098', 77, 19, ' KDU175 -- MITSUBISHI ADVENTURE 2008', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1', '0'),
(99, '000099', 78, 89, ' ZYX222 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-01-22', '0.00', '0.00', '1', '0'),
(100, '000100', 79, 89, ' GHR257 -- HONDA ACCORD', 0, NULL, NULL, '2013-01-16', '0.00', '0.00', '1', '0'),
(101, '000101', 80, 89, ' KCF884 -- HONDA CIVIC', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1', '0'),
(102, '000102', 81, 90, ' KCF648 -- ISUZU FUEGO', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1', '0'),
(103, '000103', 82, 91, ' GJR238 -- HONDA CITY', 0, NULL, NULL, '2013-01-25', '0.00', '0.00', '1', '0'),
(104, '000104', 83, 34, ' SHJ477 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-02-11', '0.00', '30.00', '1', '0'),
(105, '000105', 84, 92, ' XMR211 -- HONDA CIVIC ''2004', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1', '0'),
(106, '000106', 85, 93, ' THG207 -- TOYOTA CORONA', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1', '0'),
(107, '000107', 86, 94, ' ZMH389 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2012-12-12', '0.00', '0.00', '1', '0'),
(108, '000108', 87, 95, ' KFZ679 -- ISUZU DMAX 2011', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1', '0'),
(109, '000109', 82, 91, ' GJR238 -- HONDA CITY', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1', '0'),
(110, '000110', 73, 84, ' PMB177 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1', '0'),
(111, '000111', 16, 20, ' KBP657 -- CHARADE', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1', '0'),
(112, '000112', 44, 54, ' XGJ146 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1', '0'),
(113, '000113', 88, 97, ' KDE850 -- HONDA CITY', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1', '0'),
(114, '000114', 63, 71, ' ZGP662 -- HYUNDAI GETZ1.1M/T', 0, NULL, NULL, '2013-01-31', '0.00', '0.00', '1', '0'),
(115, '000115', 89, 98, ' ZRM710 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1', '0'),
(116, '000116', 89, 98, ' ZRM710 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2012-09-14', '0.00', '0.00', '1', '0'),
(117, '000117', 45, 55, ' UKD396 -- HONDA ACCORD', 0, NULL, NULL, '2013-02-12', '0.00', '170.00', '1', '0'),
(118, '000118', 53, 60, ' ZCG528 -- INNOVA 2006', 0, NULL, NULL, '2013-02-16', '0.00', '0.00', '1', '0'),
(119, '000119', 90, 99, ' TGD371 -- HONDA CIVIC ESI', 0, NULL, NULL, '2010-07-05', '0.00', '0.00', '1', '0'),
(120, '000120', 91, 100, ' NOE844 -- NISSAN URBAN ''09', 0, NULL, NULL, '2013-02-01', '0.00', '0.00', '1', '0'),
(121, '000121', 92, 101, ' URB361 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-14', '0.00', '1820.00', '1', '0'),
(122, '000122', 94, 32, ' WHV610 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-19', '0.00', '0.00', '1', '0'),
(123, '000123', 95, 14, ' UBS806 -- MITSUBISHI L200', 0, NULL, NULL, '2013-01-24', '0.00', '0.00', '1', '0'),
(124, '000124', 96, 105, ' ZPU213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1', '0'),
(125, '000125', 97, 106, ' PIX852 -- TOYOTA VIOS 2011', 0, NULL, NULL, '2013-02-16', '0.00', '0.00', '1', '0'),
(126, '000126', 98, 107, ' RCA655 -- STRADA', 0, NULL, NULL, '2012-12-14', '0.00', '0.00', '1', '0'),
(127, '000127', 99, 108, ' KEZ926 -- HONDA CIVIC EK4', 0, NULL, NULL, '2013-04-03', '0.00', '0.00', '1', '0'),
(128, '000128', 99, 108, ' KEZ926 -- HONDA CIVIC EK4', 0, NULL, NULL, '2012-11-28', '0.00', '0.00', '1', '0'),
(129, '000129', 100, 109, ' KBJ555 -- LANCER BOX TYPE ', 0, NULL, NULL, '2012-07-16', '0.00', '0.00', '1', '0'),
(130, '000130', 101, 110, ' XGS555 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1', '0'),
(131, '000131', 102, 40, ' GJY555 -- HONDA CR-V', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1', '0'),
(132, '000132', 103, 40, ' YDF296 -- ISUZU CROSSWIND', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1', '0'),
(133, '000133', 104, 112, ' AAD004 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1', '0'),
(134, '000134', 105, 113, ' WTG939 -- TOYOTA REVO', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1', '0'),
(135, '000135', 106, 114, ' AAE005 -- TOYOTA REVO -2001', 0, NULL, NULL, '2012-12-17', '0.00', '0.00', '1', '0'),
(136, '000136', 107, 115, ' KDP466 -- KIA SPORTAGE ''07', 0, NULL, NULL, '2013-01-30', '0.00', '0.00', '1', '0'),
(137, '000137', 52, 59, ' XJC760 -- HONDA CR-V', 0, NULL, NULL, '2013-02-15', '0.00', '10.00', '1', '0'),
(138, '000138', 108, 117, ' TDS280 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1', '0'),
(139, '000139', 85, 93, ' THG207 -- TOYOTA CORONA', 0, NULL, NULL, '2013-02-16', '0.00', '0.00', '1', '0'),
(140, '000140', 109, 119, ' GEV975 -- MITSUBISHI GALANT 95-95', 0, NULL, NULL, '2013-02-04', '0.00', '0.00', '1', '0'),
(141, '000141', 85, 93, ' THG207 -- TOYOTA CORONA', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1', '0'),
(142, '000142', 110, 120, ' GTJ483 -- ISUZU TROOPER', 0, NULL, NULL, '2013-02-23', '0.00', '50.00', '1', '0'),
(143, '000143', 111, 121, ' KDF860 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1', '0'),
(144, '000144', 112, 122, ' GGV946 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-23', '0.00', '10.00', '1', '0'),
(145, '000145', 113, 123, ' UTB141 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1', '0'),
(146, '000146', 114, 124, ' KDV819 -- TOYOTA HI-ACE', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1', '0'),
(147, '000147', 84, 92, ' XMR211 -- HONDA CIVIC ''2004', 0, NULL, NULL, '2013-02-25', '0.00', '0.00', '1', '0'),
(148, '000148', 115, 125, ' GHJ358 -- HONDA CIVIC VTEC', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(149, '000149', 86, 94, ' ZMH389 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1', '0'),
(150, '000150', 116, 50, ' PUD750 -- MITSUBISHI L300', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1', '0'),
(151, '000151', 24, 50, ' KVU924 -- MITSUBISHI L300', 0, NULL, NULL, '2013-02-22', '0.00', '0.00', '1', '0'),
(152, '000152', 89, 98, ' ZRM710 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1', '0'),
(153, '000153', 16, 20, ' KBP657 -- CHARADE', 0, NULL, NULL, '2013-02-22', '0.00', '0.00', '1', '0'),
(154, '000154', 117, 128, ' XHX944 -- HONDA CR-V', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1', '0'),
(155, '000155', 118, 129, ' GHH -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1', '0'),
(156, '000156', 119, 130, ' ZDK482 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2012-06-20', '0.00', '0.00', '1', '0'),
(157, '000157', 96, 105, ' ZPU213 -- HYUNDAI GETZ', 0, NULL, NULL, '2012-11-30', '0.00', '0.00', '1', '0'),
(158, '000158', 96, 105, ' ZPU213 -- HYUNDAI GETZ', 0, NULL, NULL, '2012-10-27', '0.00', '0.00', '1', '0'),
(159, '000159', 96, 105, ' ZPU213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1', '0'),
(160, '000160', 96, 105, ' ZPU213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1', '0'),
(161, '000161', 20, 24, ' KDM249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1', '0'),
(162, '000162', 120, 4, ' MEZ141 -- MULTICAB', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1', '0'),
(163, '000163', 1, 4, ' MFN122 -- MULTICAB', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1', '0'),
(164, '000164', 99, 108, ' KEZ926 -- HONDA CIVIC EK4', 0, NULL, NULL, '2013-02-22', '0.00', '0.00', '1', '0'),
(165, '000165', 121, 132, ' MBR615 -- KIA K2 400', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1', '0'),
(166, '000166', 57, 266, ' ZGN690 -- TOYOTA VIOS ''06', 0, NULL, NULL, '2013-01-15', '0.00', '0.00', '1', '0'),
(167, '000167', 122, 61, ' KCG656 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1', '0'),
(168, '000168', 53, 60, ' ZCG528 -- INNOVA 2006', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1', '0'),
(169, '000169', 32, 133, ' KDE510 -- KIA PICANTO', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1', '0'),
(170, '000170', 31, 34, ' TJD176 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-03-01', '0.00', '0.00', '1', '0'),
(171, '000171', 123, 134, ' GDL522 -- LANCER', 0, NULL, NULL, '2012-12-28', '0.00', '0.00', '1', '0'),
(172, '000172', 123, 134, ' GDL522 -- LANCER', 0, NULL, NULL, '2012-12-28', '0.00', '0.00', '1', '0'),
(173, '000173', 124, 135, ' KGB589 -- ISUZU DMAX', 0, NULL, NULL, '2013-03-01', '0.00', '0.00', '1', '0'),
(174, '000174', 125, 136, ' CSL577 -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-03-02', '0.00', '0.00', '1', '0'),
(175, '000175', 109, 119, ' GEV975 -- MITSUBISHI GALANT 95-95', 0, NULL, NULL, '2013-02-25', '0.00', '0.00', '1', '0'),
(176, '000176', 126, 138, ' KEF875 -- HONDA CITY', 0, NULL, NULL, '2013-03-04', '0.00', '100.00', '1', '0'),
(177, '000177', 86, 94, ' ZMH389 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-03-05', '0.00', '0.00', '1', '0'),
(178, '000178', 127, 139, ' ZNG361 -- HONDA CITY', 0, NULL, NULL, '2013-03-05', '0.00', '0.00', '1', '0'),
(179, '000179', 128, 140, ' XDX543 -- HYUNDAI GETZ ''07', 0, NULL, NULL, '2013-02-27', '0.00', '330.00', '1', '0'),
(180, '000180', 129, 141, ' KEY684 -- HONDA FIT', 0, NULL, NULL, '2013-03-06', '0.00', '0.00', '1', '0');

-- --------------------------------------------------------

--
-- Table structure for table `jodetails`
--

CREATE TABLE IF NOT EXISTS `jodetails` (
  `jo_id` int(11) NOT NULL DEFAULT '0',
  `labor` int(11) DEFAULT '0',
  `partmaterial` varchar(255) DEFAULT '0',
  `details` mediumtext,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `status` enum('0','1','2','3') DEFAULT '0' COMMENT '0:deactivated, 1:active, 2:reserved, 3:reserved',
  KEY `FK_jodetails_1` (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jodetails`
--

INSERT INTO `jodetails` (`jo_id`, `labor`, `partmaterial`, `details`, `amnt`, `status`) VALUES
(1, 573, '', '', '450.00', '1'),
(1, 0, '1 SET BRAKE MASTER KIT', '', '325.00', '1'),
(1, 0, 'BRAKE FLUID', '', '100.00', '1'),
(1, 0, 'BRAKE FLUID', '', '100.00', '1'),
(1, 0, 'BRAKE FLUID', '', '50.00', '1'),
(2, 116, '', '', '150.00', '1'),
(2, 30, '', '', '350.00', '1'),
(2, 0, 'SYNTHETIC 4 LTRS.', '', '3200.00', '1'),
(2, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(2, 0, '1PC. HOOD CABLE', '', '980.00', '1'),
(3, 31, '', '', '450.00', '1'),
(3, 0, '4PCS. SCREW', '', '10.00', '1'),
(4, 521, '', '', '550.00', '1'),
(5, 34, '', '', '200.00', '1'),
(6, 521, '', '', '550.00', '1'),
(6, 36, '', '', '100.00', '1'),
(6, 116, '', '', '150.00', '1'),
(6, 0, '1 PC. OIL FILTER', '', '300.00', '1'),
(6, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(7, 0, 'CHARGE INVOICE # 2433', '', '9268.40', '1'),
(8, 0, 'CHARGE INVOICE # 2435', '', '1255.00', '1'),
(9, 40, '', '', '1800.00', '1'),
(10, 250, '', '', '250.00', '1'),
(10, 0, '1PC. HORN', '', '500.00', '1'),
(11, 469, '', '', '350.00', '1'),
(11, 44, '', '', '250.00', '1'),
(11, 45, '', '', '150.00', '1'),
(11, 0, '2PCS. STABILIZER LINK', '', '1700.00', '1'),
(12, 47, '', '', '22000.00', '1'),
(12, 574, '', '', '550.00', '1'),
(12, 0, '1SET FOG LAMPS', '', '4200.00', '1'),
(13, 116, '', '', '150.00', '1'),
(13, 49, '', '', '250.00', '1'),
(13, 0, '1GAL. ENGINE OIL MACH 5', '', '950.00', '1'),
(13, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(13, 0, '1PC. AIR FILTER', '', '325.00', '1'),
(13, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(14, 0, 'CHARGE INVOICE # 2437', '', '22710.00', '1'),
(15, 575, '', '', '1500.00', '1'),
(16, 60, '', '', '450.00', '1'),
(16, 61, '', '', '250.00', '1'),
(16, 0, '1PC. RUBBER HANGER', '', '120.00', '1'),
(17, 0, 'CHARGE INVOICE # 2434', '', '20000.00', '1'),
(18, 63, '', '', '150.00', '1'),
(18, 64, '', '', '150.00', '1'),
(18, 65, '', '', '150.00', '1'),
(18, 0, '1PC. DOOR HANDLE LH', '', '650.00', '1'),
(18, 0, '16FT DOUBLE ADHESIVE', '', '480.00', '1'),
(19, 66, '', '', '350.00', '1'),
(19, 0, '1PC BOLT 14X25X20', '', '30.00', '1'),
(19, 0, '1PC. MIGHTY GASKET', '', '130.00', '1'),
(20, 62, '', '', '7890.00', '1'),
(21, 460, '', '', '300.00', '1'),
(21, 75, '', '', '300.00', '1'),
(22, 77, '', '', '350.00', '1'),
(22, 78, '', '', '450.00', '1'),
(22, 79, '', '', '400.00', '1'),
(22, 0, '1PC. LOWER AEM BUSHING( SMALL)', '', '200.00', '1'),
(22, 0, '1PC. LOWER ARM BUSHING ( BIG)', '', '325.00', '1'),
(23, 62, '', '', '5395.00', '1'),
(24, 83, '', '', '500.00', '1'),
(24, 84, '', '', '500.00', '1'),
(24, 0, '1PC. FUEL FILTER', '', '1000.00', '1'),
(24, 0, '1PC.FUEL PUMP', '', '3600.00', '1'),
(25, 49, '', '', '250.00', '1'),
(26, 0, 'CHARGE INVOICE # 2442', '', '4060.00', '1'),
(27, 87, '', '', '500.00', '1'),
(27, 576, '', '', '8500.00', '1'),
(27, 72, '', '', '150.00', '1'),
(27, 0, '1PC. BACK GLASS', '', '6800.00', '1'),
(27, 0, '2LTRS. GEAR OIL', '', '460.00', '1'),
(28, 62, '', '', '9500.00', '1'),
(29, 91, '', '', '350.00', '1'),
(29, 0, '1PC POWER STEERING HOSE', '', '1000.00', '1'),
(29, 0, 'ATF', '', '250.00', '1'),
(30, 92, '', '', '150.00', '1'),
(30, 93, '', '', '50.00', '1'),
(30, 94, '', '', '850.00', '1'),
(31, 95, '', '', '800.00', '1'),
(32, 96, '', '', '200.00', '1'),
(32, 97, '', '', '300.00', '1'),
(32, 98, '', '', '300.00', '1'),
(32, 99, '', '', '300.00', '1'),
(32, 100, '', '', '350.00', '1'),
(32, 0, '1PC. BRONZE FITTING ( OIL)', '', '80.00', '1'),
(32, 0, '1PC. FITTING BRONZE ( WATER)', '', '150.00', '1'),
(33, 0, 'CHARGE INVOICE # 2438', '', '1810.00', '1'),
(34, 72, '', '', '150.00', '1'),
(34, 101, '', '', '350.00', '1'),
(34, 71, '', '', '150.00', '1'),
(34, 0, '1PC. OIL FILTER', '', '235.00', '1'),
(34, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(34, 0, '1GAL. CVT FLUID', '', '2450.00', '1'),
(34, 0, '1PC. TRANSMISSION SUPPORT', '', '2500.00', '1'),
(35, 102, '', '', '1800.00', '1'),
(35, 0, '1SET CORNER LAMP RH/LH', '', '1200.00', '1'),
(36, 62, '', '', '7180.00', '1'),
(37, 108, '', '', '350.00', '1'),
(38, 109, '', '', '100.00', '1'),
(38, 0, '1PC. RELAY', '', '140.00', '1'),
(39, 112, '', '', '200.00', '1'),
(39, 113, '', '', '2000.00', '1'),
(39, 114, '', '', '150.00', '1'),
(39, 0, '1PC. VOLTAGE REGULATOR', '', '800.00', '1'),
(40, 116, '', '', '150.00', '1'),
(40, 49, '', '', '250.00', '1'),
(40, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(40, 0, '4PCS. SPARK PLUG', '', '640.00', '1'),
(40, 0, '1GAL. ENGINE OIL', '', '890.00', '1'),
(40, 0, '1PC. AIR FILTER', '', '595.00', '1'),
(40, 0, '1QRT. COOLANT', '', '215.00', '1'),
(41, 115, '', '', '1300.00', '1'),
(42, 62, '', '', '66345.00', '1'),
(43, 577, '', '', '300.00', '1'),
(43, 0, '1PC. RADIATOR ASSY', '', '7500.00', '1'),
(44, 0, 'CHARGE INVOICE# 2353', '', '4345.00', '1'),
(45, 120, '', '', '450.00', '1'),
(45, 121, '', '', '450.00', '1'),
(45, 0, '1PC. TPS SENSOR', '', '1500.00', '1'),
(45, 0, 'ATF', '', '260.00', '1'),
(46, 0, 'CHARGE INVOICE # 2351-2352', '', '3230.00', '1'),
(47, 62, '', '', '23880.00', '1'),
(48, 137, '', '', '450.00', '1'),
(49, 116, '', '', '150.00', '1'),
(49, 167, '', '', '2250.00', '1'),
(49, 0, '1PC. OIL FILTER', '', '689.00', '1'),
(49, 0, '5LTRS.FULLY SYNTHETIC OIL', '', '4000.00', '1'),
(49, 0, '4PCS. GRILL CLIP', '', '160.00', '1'),
(50, 137, '', '', '450.00', '1'),
(51, 139, '', '', '550.00', '1'),
(51, 140, '', '', '250.00', '1'),
(51, 141, '', '', '150.00', '1'),
(51, 142, '', '', '150.00', '1'),
(51, 143, '', '', '100.00', '1'),
(51, 147, '', '', '450.00', '1'),
(51, 0, '1SET TIMING BELT', '', '2210.00', '1'),
(51, 0, '1PC. CRANK SHAFT PULLEY', '', '3640.00', '1'),
(51, 0, '1PC. TENSIONER BERAING (BIG)', '', '845.00', '1'),
(51, 0, '1PC. TENSIONER BERAING (SMALL)', '', '754.00', '1'),
(51, 0, '1PC. OIL SEAL', '', '364.00', '1'),
(51, 0, '1PC. STEERING BELT', '', '208.00', '1'),
(51, 0, '1PC. DRIVE BELT', '', '364.00', '1'),
(51, 0, '1PC. ALTERNATOR BELT', '', '364.00', '1'),
(52, 149, '', '', '2650.00', '1'),
(52, 0, '1PC. RELEASE BEARING', '', '1200.00', '1'),
(53, 85, '', '', '350.00', '1'),
(53, 0, '1PC. BRAKE MASTER ASSY', '', '1560.00', '1'),
(53, 0, 'BRAKE FLUID', '', '100.00', '1'),
(54, 145, '', '', '250.00', '1'),
(54, 0, '1PC. DRIVE BELT', '', '960.00', '1'),
(55, 151, '', '', '100.00', '1'),
(56, 62, '', '', '23530.00', '1'),
(57, 146, '', '', '150.00', '1'),
(57, 116, '', '', '150.00', '1'),
(57, 49, '', '', '250.00', '1'),
(57, 25, '', '', '250.00', '1'),
(57, 158, '', '', '100.00', '1'),
(57, 578, '', '', '100.00', '1'),
(57, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(57, 0, '1PC. AIR FILTER', '', '455.00', '1'),
(57, 0, '4PCS. SPARK PLUG', '', '500.00', '1'),
(57, 0, '1PC. ALTERNATOR BELT', '', '715.00', '1'),
(57, 0, '1PC. FULE FILTER', '', '325.00', '1'),
(57, 0, '1PC. VALVE COVER GASKET', '', '286.00', '1'),
(57, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(58, 0, 'CHARGE INVOICE # 2363', '', '15825.00', '1'),
(59, 0, 'CHARGE INVOICE # 2364', '', '2700.00', '1'),
(60, 116, '', '', '150.00', '1'),
(60, 161, '', '', '1200.00', '1'),
(60, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(60, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(61, 0, '1PC. VALVE SPRING', '', '250.00', '1'),
(62, 0, 'CHARGE INVOICE # 2359', '', '50000.00', '1'),
(63, 0, '1PC. PLYWHEEL', '', '4500.00', '1'),
(64, 110, '', '', '1500.00', '1'),
(64, 111, '', '', '300.00', '1'),
(64, 0, '1PC. SHOCK ABSORBER MOUNTING', '', '1200.00', '1'),
(65, 0, 'CHARGE INVOICE # 2448-2449', '', '35000.00', '1'),
(66, 162, '', '', '950.00', '1'),
(67, 163, '', '', '450.00', '1'),
(67, 0, '1PC. ALTERNATOR ASSY', '', '9000.00', '1'),
(67, 0, 'ATF 2', '', '520.00', '1'),
(68, 116, '', '', '150.00', '1'),
(68, 49, '', '', '250.00', '1'),
(68, 72, '', '', '150.00', '1'),
(69, 170, '', '', '150.00', '1'),
(69, 0, '1PC. RADIATOR HOSE ', '', '350.00', '1'),
(69, 0, 'BRAKE FLUID', '', '100.00', '1'),
(70, 171, '', '', '300.00', '1'),
(70, 172, '', '', '2936.25', '1'),
(71, 0, 'CHARGE INVOICE # 2372', '', '42108.75', '1'),
(72, 176, '', '', '1200.00', '1'),
(72, 177, '', '', '300.00', '1'),
(73, 116, '', '', '150.00', '1'),
(73, 0, '5 LTRS. ENGINE OIL', '', '1575.00', '1'),
(73, 0, '1PC. OIL FILTER', '', '650.00', '1'),
(74, 179, '', '', '1300.00', '1'),
(74, 0, '1PC. CLUTCH COVER', '', '3250.00', '1'),
(74, 0, '1PC. RELEASE BEARING', '', '1105.00', '1'),
(74, 0, '1LTR. GEAR OIL', '', '230.00', '1'),
(75, 180, '', '', '650.00', '1'),
(75, 181, '', '', '50.00', '1'),
(75, 182, '', '', '1500.00', '1'),
(75, 183, '', '', '400.00', '1'),
(75, 0, '1PC. WEDGE BULB', '', '25.00', '1'),
(75, 0, '16 PCS. VALVE SEAL (NOK)', '', '640.00', '1'),
(75, 0, '1PC. STOP LIGHT SWITCH', '', '150.00', '1'),
(76, 185, '', '', '500.00', '1'),
(76, 186, '', '', '150.00', '1'),
(76, 187, '', '', '250.00', '1'),
(76, 0, 'CONTACT POINT', '', '230.00', '1'),
(77, 49, '', '', '250.00', '1'),
(77, 188, '', '', '250.00', '1'),
(77, 0, '1PC. WINDOW GLASS', '', '2800.00', '1'),
(77, 0, 'FREIGHT', '', '587.33', '1'),
(78, 62, '', '', '6150.00', '1'),
(79, 0, 'CHARGE INVOICE # 2367', '', '16950.00', '1'),
(80, 0, 'CHARGE INVOICE # 2368', '', '2666.00', '1'),
(81, 116, '', '', '150.00', '1'),
(81, 189, '', '', '800.00', '1'),
(81, 0, '4 LTRS. ENGINE OIL', '', '950.00', '1'),
(81, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(81, 0, '1LTR. COOLANT', '', '150.00', '1'),
(82, 190, '', '', '2100.00', '1'),
(82, 191, '', '', '100.00', '1'),
(83, 192, '', '', '150.00', '1'),
(83, 193, '', '', '100.00', '1'),
(83, 0, '1PC. SIDE MIRROR', '', '800.00', '1'),
(84, 0, 'CHARGE INVOICE # 2375', '', '15470.00', '1'),
(85, 0, 'CHARGE INVOICE # 2439', '', '3000.00', '1'),
(86, 0, 'CHARGE INVOICE # 2440', '', '5250.00', '1'),
(87, 71, '', '', '150.00', '1'),
(87, 196, '', '', '250.00', '1'),
(87, 72, '', '', '150.00', '1'),
(87, 0, '8PCS SPARK PLUG', '', '960.00', '1'),
(87, 0, '1PC.OIL FILTER', '', '300.00', '1'),
(87, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(87, 0, '1GAL. CVT FLUID', '', '2450.00', '1'),
(88, 197, '', '', '950.00', '1'),
(89, 198, '', '', '250.00', '1'),
(89, 116, '', '', '150.00', '1'),
(89, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(89, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(90, 0, 'CHARGE INVOICE # 2450', '', '6060.00', '1'),
(91, 0, 'CHARGE INVOICE # 2365', '', '19760.00', '1'),
(92, 0, 'CHARGE INVOICE # 2361', '', '3640.00', '1'),
(93, 0, 'CHARGE INVOICE # 2370-2371', '', '11291.00', '1'),
(94, 213, '', '', '450.00', '1'),
(94, 214, '', '', '650.00', '1'),
(94, 0, '1PC. RELAY W/ SOCKET', '', '160.00', '1'),
(94, 0, '2PCS. TIE WRAP', '', '20.00', '1'),
(95, 216, '', '', '1500.00', '1'),
(95, 218, '', '', '150.00', '1'),
(96, 62, '', '', '25472.00', '1'),
(97, 0, '1PC FUEL INJECTOR TYPE Z', '', '1400.00', '1'),
(98, 0, 'CHARGE INVOICE # 2374', '', '43000.00', '1'),
(99, 233, '', '', '6000.00', '1'),
(99, 0, '10 PCS. MUDGUARD CLIPS', '', '360.00', '1'),
(100, 234, '', '', '150.00', '1'),
(100, 235, '', '', '100.00', '1'),
(100, 236, '', '', '2000.00', '1'),
(100, 237, '', '', '2500.00', '1'),
(100, 115, '', '', '1000.00', '1'),
(100, 71, '', '', '150.00', '1'),
(100, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(100, 0, 'BRAKE FLUID', '', '200.00', '1'),
(100, 0, '1 QRT. ATF', '', '260.00', '1'),
(101, 238, '', '', '1500.00', '1'),
(101, 0, '1 UNIT TRANSMISSION', '', '35000.00', '1'),
(101, 0, 'FREIGHT', '', '2490.21', '1'),
(101, 0, '4 LTRS. ATF', '', '1040.00', '1'),
(101, 0, '5 LTRS. ATF', '', '1300.00', '1'),
(102, 239, '', '', '2600.00', '1'),
(103, 240, '', '', '3566.00', '1'),
(104, 241, '', '', '350.00', '1'),
(104, 242, '', '', '500.00', '1'),
(104, 0, '1PC. BALLJOINT RH', '', '980.00', '1'),
(104, 0, 'VOLT', '', '84.00', '1'),
(105, 579, '', '', '150.00', '1'),
(105, 0, '1PC. RUBBER VALVE', '', '30.00', '1'),
(106, 245, '', '', '250.00', '1'),
(107, 0, 'CHARGE INVOICE # 1671', '', '7700.00', '1'),
(108, 0, 'CHARGE INVOICE # 2379', '', '5004.00', '1'),
(109, 0, 'CHARGE INVOICE # 2373', '', '10664.00', '1'),
(110, 246, '', '', '250.00', '1'),
(110, 155, '', '', '650.00', '1'),
(111, 247, '', '', '350.00', '1'),
(111, 25, '', '', '100.00', '1'),
(111, 248, '', '', '450.00', '1'),
(111, 0, '1PC. FUEL FILTER', '', '70.00', '1'),
(111, 0, 'FUEL', '', '300.00', '1'),
(112, 249, '', '', '800.00', '1'),
(112, 0, '1SET ALARM', '', '1500.00', '1'),
(113, 250, '', '', '350.00', '1'),
(114, 0, 'CHARGE INVOICE # 2369', '', '15270.00', '1'),
(115, 0, 'CHARGE INVOICE # 2376', '', '4600.00', '1'),
(116, 0, 'CHARGE INVOICE # 2380', '', '1000.00', '1'),
(117, 251, '', '', '1500.00', '1'),
(117, 129, '', '', '250.00', '1'),
(117, 468, '', '', '300.00', '1'),
(117, 91, '', '', '300.00', '1'),
(117, 252, '', '', '300.00', '1'),
(117, 253, '', '', '100.00', '1'),
(117, 255, '', '', '100.00', '1'),
(117, 254, '', '', '350.00', '1'),
(117, 0, '1 SET TIE ROD END', '', '1600.00', '1'),
(117, 0, '1 SET RACK END ', '', '1500.00', '1'),
(117, 0, '1PC. POWER STEERING HOSE W/ CRIMP', '', '1800.00', '1'),
(117, 0, '2PCS. STEERING BOOTS ', '', '380.00', '1'),
(117, 0, '1 SET STEERING ROCK REPAIR KIT', '', '3800.00', '1'),
(117, 0, '1 SET BRAKE PADS', '', '1400.00', '1'),
(117, 0, '1 SET HEADLIGHT BULB', '', '180.00', '1'),
(117, 0, '1LTR. ATF', '', '260.00', '1'),
(117, 0, 'BRAKE FLUID', '', '50.00', '1'),
(118, 116, '', '', '150.00', '1'),
(118, 258, '', '', '50.00', '1'),
(118, 0, '1 PC. OIL FILTER', '', '290.00', '1'),
(118, 0, '1PC. AIR FILTER', '', '1400.00', '1'),
(118, 0, '5HRS. SEMI SYNTHETIC', '', '1575.00', '1'),
(119, 62, '', '', '118716.00', '1'),
(120, 116, '', '', '150.00', '1'),
(120, 0, '1 PC. OIL FILTER', '', '390.00', '1'),
(120, 0, '6 LTRS. ENGINE OIL', '', '1380.00', '1'),
(121, 119, '', '', '1100.00', '1'),
(121, 116, '', '', '150.00', '1'),
(121, 0, '1PC. HEAD GASKET ( ORIG )', '', '1280.00', '1'),
(121, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(121, 0, 'OIL FILTER', '', '290.00', '1'),
(121, 0, 'CLEANING SOLVENT', '', '50.00', '1'),
(122, 259, '', '', '1500.00', '1'),
(123, 62, '', '', '57954.00', '1'),
(124, 0, 'CHARGE INVOICE # 2386', '', '3335.00', '1'),
(125, 0, 'CHARGE INVOICE # 2385', '', '15570.00', '1'),
(126, 260, '', '', '350.00', '1'),
(126, 0, '1 LTR. ATF', '', '260.00', '1'),
(127, 261, '', '', '1500.00', '1'),
(127, 263, '', '', '800.00', '1'),
(127, 0, 'CROSSMEMBER', '', '12000.00', '1'),
(127, 0, 'RACK & PINION ASSY', '', '11000.00', '1'),
(127, 0, '2 PCS. WIPER LINKAGE ASSY W/ MOTOR', '', '7000.00', '1'),
(127, 0, 'ATF', '', '260.00', '1'),
(128, 264, '', '', '350.00', '1'),
(128, 265, '', '', '150.00', '1'),
(128, 266, '', '', '2800.00', '1'),
(128, 267, '', '', '1200.00', '1'),
(128, 268, '', '', '800.00', '1'),
(128, 0, '1PC. BRONZE ROD', '', '65.00', '1'),
(128, 0, '1 QRT. ATF', '', '260.00', '1'),
(128, 0, 'CLEANING SOLVENT', '', '50.00', '1'),
(129, 62, '', '', '56805.00', '1'),
(130, 269, '', '', '900.00', '1'),
(131, 71, '', '', '150.00', '1'),
(131, 49, '', '', '250.00', '1'),
(131, 72, '', '', '100.00', '1'),
(131, 581, '', '', '450.00', '1'),
(131, 582, '', '', '600.00', '1'),
(131, 583, '', '', '150.00', '1'),
(131, 584, '', '', '50.00', '1'),
(131, 0, '1 GAL ENGINE OIL', '', '950.00', '1'),
(131, 0, '4 LTRS. ATF TRANSMISSION', '', '1040.00', '1'),
(131, 0, 'COOLANT', '', '150.00', '1'),
(131, 0, '1 C 806 OIL FILTER', '', '260.00', '1'),
(131, 0, '4 PCS. SPARK PLUG', '', '940.00', '1'),
(131, 0, '1 PC. THERMO SWITCH', '', '1000.00', '1'),
(131, 0, '1 PC. OUTER DOOR HANDLE FRT RH', '', '850.00', '1'),
(131, 0, '1PC. ALTERNATOR 5 WIRES', '', '350.00', '1'),
(132, 116, '', '', '150.00', '1'),
(132, 49, '', '', '250.00', '1'),
(132, 85, '', '', '350.00', '1'),
(132, 585, '', '', '300.00', '1'),
(132, 75, '', '', '300.00', '1'),
(132, 586, '', '', '350.00', '1'),
(132, 0, '1PC. BRAKE MASTER ASSY', '', '2740.00', '1'),
(132, 0, '1PC. CLUTCH SLAVE ASSY', '', '590.00', '1'),
(132, 0, '1PC. OIL FILTER', '', '240.00', '1'),
(132, 0, '1 SET BRAKE PADS FRT', '', '1240.00', '1'),
(132, 0, '2 BRAKE FLUID', '', '200.00', '1'),
(132, 0, '1 GAL. URANIA', '', '1135.00', '1'),
(132, 0, '2 PCS. WHEEL CYLINDER ASSY', '', '1170.00', '1'),
(133, 270, '', '', '250.00', '1'),
(134, 116, '', '', '150.00', '1'),
(134, 271, '', '', '150.00', '1'),
(134, 0, '1 PC. OIL FILTER', '', '190.00', '1'),
(135, 158, '', '', '150.00', '1'),
(135, 49, '', '', '250.00', '1'),
(135, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(135, 0, '1PC. VALVE COVER GASKET', '', '1100.00', '1'),
(136, 272, '', '', '700.00', '1'),
(136, 274, '', '', '910.00', '1'),
(136, 273, '', '', '260.00', '1'),
(136, 0, '2 PCS. HUB BEARING ', '', '3600.00', '1'),
(136, 0, 'FREIGHT', '', '300.00', '1'),
(137, 131, '', '', '2000.00', '1'),
(137, 116, '', '', '150.00', '1'),
(137, 275, '', '', '300.00', '1'),
(137, 587, '', '', '100.00', '1'),
(137, 0, '1PC. CLUTCH COVER', '', '5500.00', '1'),
(137, 0, '1 PC. CLUTCH LINING', '', '4800.00', '1'),
(137, 0, '1PC. RELEASE BEARING', '', '850.00', '1'),
(137, 0, '1 PC. OIL FILTER', '', '290.00', '1'),
(137, 0, '4 LTRS. ENGINE OIL', '', '920.00', '1'),
(137, 0, '2 QRT. COOLANT', '', '300.00', '1'),
(137, 0, '2 PCS. BUMPER LOCKS', '', '150.00', '1'),
(137, 0, '1 PC. HORN SWITCH', '', '100.00', '1'),
(137, 0, '1 PC. OIL SEAL', '', '640.00', '1'),
(137, 0, '1PC. THREAD LOCKER', '', '210.00', '1'),
(138, 276, '', '', '250.00', '1'),
(138, 0, '1PC. CLUTCH SLAVE REPAIR KIT', '', '350.00', '1'),
(139, 25, '', '', '250.00', '1'),
(139, 277, '', '', '150.00', '1'),
(139, 278, '', '', '500.00', '1'),
(139, 0, '1PC. FUEL PUMP', '', '3500.00', '1'),
(140, 62, '', '', '25359.00', '1'),
(141, 279, '', '', '550.00', '1'),
(142, 280, '', '', '250.00', '1'),
(143, 281, '', '', '150.00', '1'),
(144, 282, '', '', '600.00', '1'),
(144, 25, '', '', '250.00', '1'),
(144, 283, '', '', '500.00', '1'),
(144, 0, '1PC. FUEL FILTER', '', '460.00', '1'),
(145, 0, '1PC. NOZZEL WIPER', '', '150.00', '1'),
(146, 285, '', '', '9000.00', '1'),
(147, 286, '', '', '150.00', '1'),
(148, 139, '', '', '600.00', '1'),
(148, 0, '1 PC. TIMING BELT', '', '1850.00', '1'),
(149, 287, '', '', '250.00', '1'),
(150, 588, '', '', '150.00', '1'),
(150, 589, '', '', '850.00', '1'),
(150, 0, '1 QRT. COOLANT', '', '300.00', '1'),
(151, 199, '', '', '300.00', '1'),
(151, 0, '1PC. FAN BELT', '', '180.00', '1'),
(151, 0, '1 PC. STEERING BELT', '', '200.00', '1'),
(152, 250, '', '', '2700.00', '1'),
(153, 174, '', '', '350.00', '1'),
(153, 590, '', '', '390.00', '1'),
(153, 289, '', '', '350.00', '1'),
(153, 294, '', '', '450.00', '1'),
(153, 291, '', '', '450.00', '1'),
(153, 292, '', '', '50.00', '1'),
(153, 293, '', '', '350.00', '1'),
(153, 294, '', '', '450.00', '1'),
(153, 0, 'BRAKE SHOE W/ LH-RH', '', '950.00', '1'),
(153, 0, 'FRT WHEEL BEARING LH', '', '1300.00', '1'),
(153, 0, 'BRAKE FLUID', '', '100.00', '1'),
(153, 0, '1PC. WHEEL BEARING RH', '', '1300.00', '1'),
(154, 295, '', '', '3800.00', '1'),
(155, 0, 'CV JOINT OUTER LH/RH', '', '3000.00', '1'),
(155, 0, 'FREIGHT', '', '400.00', '1'),
(156, 0, 'CHARGE INVOICE # 2395', '', '4400.00', '1'),
(157, 0, 'CHARGE INVOICE # 2396', '', '12500.00', '1'),
(158, 0, 'CHARGE INVOICE # 2398', '', '8130.00', '1'),
(159, 0, 'CHARGE INVOICE # 2397', '', '4300.00', '1'),
(160, 0, 'CHRAGE INVOICE # 2399', '', '1110.00', '1'),
(161, 0, 'CHARGE INVOICE # 2394', '', '3500.00', '1'),
(162, 297, '', '', '18900.00', '1'),
(162, 0, '2PCS. SIDE MIRROR LH/RH @ 800', '', '1600.00', '1'),
(163, 298, '', '', '450.00', '1'),
(163, 299, '', '', '50.00', '1'),
(163, 300, '', '', '300.00', '1'),
(163, 302, '', '', '150.00', '1'),
(163, 0, '1 PC. PEANUT BULB', '', '50.00', '1'),
(163, 0, '1PC. OIL SEAL 35X 5X8', '', '260.00', '1'),
(163, 0, '1 PC. ORING 213', '', '30.00', '1'),
(163, 0, '1PC. T FITTING', '', '50.00', '1'),
(163, 301, '', '', '150.00', '1'),
(164, 395, '', '', '200.00', '1'),
(164, 467, '', '', '150.00', '1'),
(164, 0, '1SET RACK END LR', '', '1900.00', '1'),
(164, 0, '1 SET TIE ROD LR', '', '1600.00', '1'),
(164, 0, '2PCS. TIE WRAP ( BIG)', '', '30.00', '1'),
(164, 0, '2PCS. TIE WRAP SMALL', '', '16.00', '1'),
(165, 116, '', '', '150.00', '1'),
(165, 303, '', '', '450.00', '1'),
(165, 304, '', '', '250.00', '1'),
(165, 305, '', '', '850.00', '1'),
(165, 306, '', '', '350.00', '1'),
(165, 307, '', '', '350.00', '1'),
(165, 308, '', '', '150.00', '1'),
(165, 309, '', '', '250.00', '1'),
(165, 412, '', '', '450.00', '1'),
(165, 0, 'BELANOID GASKET', '', '80.00', '1'),
(165, 0, 'CLEANING SOLVENT', '', '50.00', '1'),
(165, 0, '1PC. CRANK CASE GASKET', '', '550.00', '1'),
(166, 173, '', '', '1500.00', '1'),
(166, 174, '', '', '300.00', '1'),
(166, 175, '', '', '600.00', '1'),
(166, 0, '1PC. HUB BEARING FRT LH', '', '1800.00', '1'),
(167, 168, '', '', '150.00', '1'),
(168, 164, '', '', '8500.00', '1'),
(168, 167, '', '', '3000.00', '1'),
(169, 0, '1PC. TRACK BITE', '', '3000.00', '1'),
(170, 311, '', '', '450.00', '1'),
(170, 0, '1PC. O/R 2X6', '', '15.00', '1'),
(170, 0, '2PCS. O/R 2X10', '', '30.00', '1'),
(170, 0, '1PC. O/R 2X20', '', '15.00', '1'),
(170, 0, '1PC. O/R 2X65', '', '30.00', '1'),
(171, 312, '', '', '5800.00', '1'),
(171, 49, '', '', '250.00', '1'),
(171, 277, '', '', '150.00', '1'),
(171, 158, '', '', '100.00', '1'),
(171, 314, '', '', '250.00', '1'),
(171, 318, '', '', '450.00', '1'),
(171, 315, '', '', '480.00', '1'),
(171, 250, '', '', '150.00', '1'),
(171, 316, '', '', '450.00', '1'),
(171, 317, '', '', '350.00', '1'),
(171, 84, '', '', '300.00', '1'),
(171, 0, 'GASOLINE ', '', '250.00', '1'),
(171, 0, '1 SET HI- TENSION WIRE', '', '600.00', '1'),
(171, 0, '1 PC. AIR FILTER', '', '630.00', '1'),
(171, 0, '1PC. VALVE COVER GASKET', '', '200.00', '1'),
(171, 0, '1PC. FUEL INJECTOR', '', '1500.00', '1'),
(171, 0, '1PC. HORN', '', '650.00', '1'),
(171, 0, '1 SET BRAKE PISTON', '', '750.00', '1'),
(171, 0, '1 SET CALIPER KIT', '', '650.00', '1'),
(171, 0, 'BRAKE FLUID', '', '300.00', '1'),
(171, 0, '1SET BRAKE MASTER KIT', '', '715.00', '1'),
(172, 49, '', '', '250.00', '1'),
(172, 158, '', '', '100.00', '1'),
(172, 314, '', '', '250.00', '1'),
(172, 318, '', '', '450.00', '1'),
(172, 315, '', '', '480.00', '1'),
(172, 250, '', '', '150.00', '1'),
(172, 316, '', '', '450.00', '1'),
(172, 591, '', '', '350.00', '1'),
(172, 0, 'GASOLINE', '', '250.00', '1'),
(172, 0, '1 SET HI- TENSION WIRE', '', '600.00', '1'),
(172, 0, '1PC. AIR FILTER', '', '630.00', '1'),
(172, 0, '1PC. VALVE COVER GASKET', '', '200.00', '1'),
(172, 0, '1PC. FUEL INJECTOR', '', '1500.00', '1'),
(172, 0, 'TOWING', '', '300.00', '1'),
(172, 0, '1PC. HORN', '', '650.00', '1'),
(172, 0, '1SET BRAKE PISTON CALIPER', '', '750.00', '1'),
(172, 0, '1SET CALIPER KIT ', '', '650.00', '1'),
(172, 0, 'BRAKE FLUID', '', '300.00', '1'),
(172, 0, '1SET BRAKE MASTER REPAIR KIT', '', '715.00', '1'),
(173, 319, '', '', '1000.00', '1'),
(174, 320, '', '', '800.00', '1'),
(174, 321, '', '', '150.00', '1'),
(174, 322, '', '', '100.00', '1'),
(174, 0, 'CLEANING SOLVENT', '', '200.00', '1'),
(175, 323, '', '', '3500.00', '1'),
(175, 0, 'FREON', '', '500.00', '1'),
(176, 324, '', '', '1800.00', '1'),
(177, 325, '', '', '250.00', '1'),
(178, 0, 'CHARGE INVOICE # 2252', '', '3000.00', '1'),
(179, 397, '', '', '200.00', '1'),
(179, 469, '', '', '300.00', '1'),
(179, 396, '', '', '250.00', '1'),
(179, 468, '', '', '300.00', '1'),
(179, 77, '', '', '500.00', '1'),
(179, 241, '', '', '300.00', '1'),
(179, 202, '', '', '250.00', '1'),
(179, 556, '', '', '150.00', '1'),
(179, 594, '', '', '400.00', '1'),
(179, 254, '', '', '300.00', '1'),
(179, 397, '', '', '100.00', '1'),
(179, 0, '2 PCS. STABILIZER BAR BUSHING', '', '190.00', '1'),
(179, 0, '1SET STABILIZER LINK', '', '950.00', '1'),
(179, 0, '1 SET TIE ROD END L/R', '', '860.00', '1'),
(179, 0, '1 SET RACK END ', '', '1100.00', '1'),
(179, 0, '2PCS. LOWER ARM BUSHING BIG', '', '1000.00', '1'),
(179, 0, '2PCS. LOWER ARM BUSHING SMALL', '', '690.00', '1'),
(179, 0, '1 SET LOWER BALLJOINT', '', '1200.00', '1'),
(179, 0, 'CV JOINT OUTER', '', '1700.00', '1'),
(179, 0, 'AXLE BOOTS', '', '300.00', '1'),
(179, 0, '2PCS. TIE WRAP', '', '30.00', '1'),
(179, 0, '1 SET BRAKE PADS', '', '1110.00', '1'),
(179, 0, '1 SET STUB. BOLT W/ NUT', '', '150.00', '1'),
(180, 326, '', '', '1800.00', '1');

-- --------------------------------------------------------

--
-- Table structure for table `labortype`
--

CREATE TABLE IF NOT EXISTS `labortype` (
  `laborid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `category` int(11) DEFAULT '0',
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`laborid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=596 ;

--
-- Dumping data for table `labortype`
--

INSERT INTO `labortype` (`laborid`, `name`, `category`, `status`) VALUES
(1, 'Car Wash', 1, '1'),
(2, 'Painting', 1, '1'),
(4, 'Braking', 5, '1'),
(22, 'Change Mirror', 1, '1'),
(169, 'REPAIR RADIATOR HOSE', 1, '1'),
(192, 'REPLACE SIDE MIRROR', 1, '1'),
(23, 'Overhaul', 1, '1'),
(24, 'CHECK DISTRIBUTOR', 1, '1'),
(25, 'REPLACE FUEL FILTER', 1, '1'),
(26, 'REPLACE MAP SENSOR', 1, '1'),
(27, 'OVERHAUL DISTRIBUTOR', 1, '1'),
(28, 'BATTERY CHARGING', 1, '1'),
(29, 'REMOVAL & REINSTALL DISTRIBUTOR', 1, '1'),
(30, 'REPLACE HOOD CABLE', 1, '1'),
(31, 'INSTALL TACOMETER', 1, '1'),
(32, 'BRAKE MASTER KIT LEAKING', 1, '1'),
(33, 'REPLACE MASTER KIT LEAKING', 1, '1'),
(34, 'WELDING TANK', 1, '1'),
(35, 'REPAIR STARTER', 1, '1'),
(36, 'check V-belt loose tension/tighten', 1, '1'),
(37, 'PARTICIPATING OF POLICY', 1, '1'),
(38, 'REPLACE VOLTAGE REG. NEW ERO', 1, '1'),
(39, 'INSTALL SEATBELT', 1, '1'),
(40, 'TINT FRONT WINDSHIELD', 1, '1'),
(251, 'REPAIR STEERING LEAK', 1, '1'),
(42, 'CHECK POWER WINDOW', 1, '1'),
(43, 'REPLACE STABILIZER LINK L/R', 1, '1'),
(44, 'ADJUST ECCENTRIC BOLT/CAMBER ADJUSTMENT', 1, '1'),
(45, 'ROTATION TIRES', 1, '1'),
(47, 'REPAIR RUNNING BOARD/FRONT BUMPER/REPAINT WHOLE UN', 1, '1'),
(48, 'REPAIR FOG LAMP ASSY', 1, '1'),
(49, 'TUNE-UP', 1, '1'),
(50, 'AIRCON CLEANING/CHECK', 1, '1'),
(52, 'PMS TUNE UP105T', 1, '1'),
(53, 'AIRCON CLEANING', 1, '1'),
(54, 'EXPANSION VALVE', 1, '1'),
(55, 'RESISTOR BLOCK', 1, '1'),
(56, 'CLUTCH COVER', 1, '1'),
(57, 'CLUTCH DISC', 1, '1'),
(58, 'RELEASE BEARING', 1, '1'),
(59, 'LABOR', 1, '1'),
(60, 'CHECK STEREO SIDE MIRROR & CIGAR. WIRINGS', 1, '1'),
(61, 'REPLACE RUBBER HANGER', 1, '1'),
(62, 'REPAIR I UNIT ', 1, '1'),
(63, 'REPLACE DRIVER SIDE HANDLE LH', 1, '1'),
(64, 'SIDE FENDER LH/RH', 1, '1'),
(65, 'CHECK ENGINE TROUBLE', 1, '1'),
(66, 'LEAKING DRAIN PLUG', 1, '1'),
(67, 'RETOUCH RR BUMPER(SIDE PORTION)', 1, '1'),
(68, 'RETOUCH RR BUMPER SIDE PORTION/FIT BUMPER/LH FRT. ', 1, '1'),
(69, 'REPAIR & RETOUCH FRT. PORTION', 1, '1'),
(70, 'BRAKE LIGHT 3RD UPPER', 1, '1'),
(71, 'CHANGE OIL/ENGINE', 1, '1'),
(72, 'CHANGE OIL -TRANSMISSION', 1, '1'),
(73, 'RETOUCH FRT. BUMPER LH', 1, '1'),
(74, 'REPAIRE NOISE BRAKE CALLIPER FRT. RH-LH', 1, '1'),
(75, 'REPLACE BRAKE PADS RR LH/RH', 1, '1'),
(77, 'REPLACE LOWER ARM BUSHING BIG & SMALL LH', 1, '1'),
(78, 'REPAIR & ALIGN CROSSMEMBER LH', 1, '1'),
(79, 'LOWER ARM BUSHING PRESS & INSTALL/MACHINING', 1, '1'),
(80, 'INSTALL LCA LH/RH/SUBFRAME UPPER & LOWER/STEERING ', 1, '1'),
(81, 'REWORK FRT/REAR BUMPER MOLDING', 1, '1'),
(82, 'INSTALL ALARM', 1, '1'),
(83, 'REPLACE FUEL PUMP/FUEL FILTER', 1, '1'),
(84, 'TOWING/SERVICE CHARGE', 1, '1'),
(85, 'REPLACE BRAKE MASTER ASSY', 1, '1'),
(86, 'REPLACE HYDRAUVAC', 1, '1'),
(87, 'REPLACE & ALIGN BACK GLASS', 1, '1'),
(88, 'REPAIR ALIGN & REPAINT TRUNK ASSY/REAR BUMPER/QUAR', 1, '1'),
(89, 'REPAIR & ALIGN BACK GLASS', 1, '1'),
(90, 'REPLACE ALIGN&REPAINT FENDER RH/STEPBOARD/', 1, '1'),
(91, 'REPLACE POWER STEERING HOSE', 1, '1'),
(92, 'CHECK ALTERNATOR BELT/CHECK BATTERY', 1, '1'),
(93, 'VACUUM', 1, '1'),
(94, 'WELD GAS TANK COVER& REPAINT', 1, '1'),
(95, 'REPAINT CHIN', 1, '1'),
(96, 'RETHREADING', 1, '1'),
(97, 'INSTALL WATER TEMP. WIRING& SENSOR', 1, '1'),
(98, 'INSTALL VACUUM WIRING & SENSOR', 1, '1'),
(99, 'INSTALL OIL PRESSURE WIRING & SENSOR', 1, '1'),
(100, 'FABRICATE ADAPTOR WATER TEMP.', 1, '1'),
(101, 'REPLACE TRANSMISSION SUPPORT UPPER LH', 1, '1'),
(102, 'REPLACE CORNER LAMP LH/RH/REPAIR & REPAINT FENDER ', 1, '1'),
(103, 'REPLACE MIGHTY GASKET', 1, '1'),
(104, 'REPLACE ARM BUSHING FRT. RH', 1, '1'),
(105, 'MACHINING OF BUSHING', 1, '1'),
(106, 'TUNE UP-REPLACE SPARK PLUG/CLEAN AIR FILTER', 1, '1'),
(107, 'REPLACE OIL SEAL& DOWN TRANSMISSION', 1, '1'),
(108, 'CHECK HARD START/PALYADO', 1, '1'),
(109, 'REPLACE RELAY', 1, '1'),
(110, 'REPAIR, ALIGN& REPAINT FENDER FRT. LH', 1, '1'),
(111, 'REPLACE SHOCK ABSORBER MOUNTING LR', 1, '1'),
(112, 'CHECK ALTERNATOR', 1, '1'),
(113, 'REWIND ALTERNATOR', 1, '1'),
(114, 'REPLACE VOLTAGE REGULATOR', 1, '1'),
(115, 'BUFFING WHOLE UNIT', 1, '1'),
(116, 'CHANGE OIL', 1, '1'),
(117, 'CHANGE LINER/REBORING & HONING', 1, '1'),
(118, 'ENGINE VALVE RESEATING', 1, '1'),
(119, 'RESURFACE CYLINDER HEAD', 1, '1'),
(120, 'CHECK TPS SENSOR/DIAGNOSE', 1, '1'),
(121, 'REPAIR STEERING RACK BRACKET', 1, '1'),
(122, 'CHECK HANDBRAKE CABLE', 1, '1'),
(123, 'CHECK BRAKE LIGHTS/FAN BELT', 1, '1'),
(124, 'REPAIR POWER LOCK FRT LH/TIGHTEN BOLT', 1, '1'),
(125, 'WELDING TAILGETLR PAINT', 1, '1'),
(126, 'TIGHTEN CAMPER SHELL BOLTS', 1, '1'),
(127, 'REPLACE CLUTCH COVER,CLUTCH DISC & RELEASE BEARING', 1, '1'),
(128, 'REPLACE RACK END LH/RH', 1, '1'),
(129, 'REPLACE TIE ROD END', 1, '1'),
(130, 'REPLACE SHOCK ABSORBER LH/RH FRONT', 1, '1'),
(131, 'DOWN TRANSMISSION', 1, '1'),
(132, 'INTERIOR& EXTERIOR CLEANING REMOVE OF CAT SEATS MA', 1, '1'),
(133, 'TOWING', 1, '1'),
(134, 'REPAIR BLOWER SWITCH', 1, '1'),
(135, 'REPLACE EXPANSION VALVE', 1, '1'),
(136, 'ALIGN FENDER LH', 1, '1'),
(137, 'REPAIR WIPER', 1, '1'),
(138, 'PARTICIPATING OF CLAIM NO. MC-PC', 1, '1'),
(139, 'REPLACE TIMING BELT', 1, '1'),
(140, 'REPLACE CRANK SHAFT FULLY', 1, '1'),
(141, 'REPLACE TENSIONER BEARING(SMALL)', 1, '1'),
(142, 'REPLACE TENSIONER BEARING (BIG)', 1, '1'),
(143, 'REPLACE OIL SEAL', 1, '1'),
(144, 'REPLACE STEERING BELT', 1, '1'),
(145, 'REPLACE DRIVE BELT', 1, '1'),
(146, 'REPLACE ALTERNATOR BELT', 1, '1'),
(147, 'REPLACE STEERING BELT/DRIVE BELT/ALTERNATOR BELT', 1, '1'),
(148, 'CHECK CLUTCH FORK', 1, '1'),
(149, 'CHECK CLUTCH FORK/DOWN TRANSMISSION', 1, '1'),
(150, 'REPLACE MASTER ASSY.', 1, '1'),
(151, 'ADJUST MENOR', 1, '1'),
(152, 'REPAINT LH FRONT DOOR', 1, '1'),
(153, 'RETOUCH QUARTER PANEL LH/LOWER PORTION', 1, '1'),
(154, 'BUFFING WHOLE UNIT', 1, '1'),
(155, 'INSTALL STEREO', 1, '1'),
(156, 'WHEEL ALIGNMENT', 1, '1'),
(157, 'INSTALL SEATBELT REAR L/R', 1, '1'),
(158, 'REPLACE VALVE COVER GASKET', 1, '1'),
(159, 'TIGTEN POWER STEERING BELT', 1, '1'),
(160, 'REPAIR 1 UNIT ISUZU DMAX2010', 1, '1'),
(161, 'REPAIR & REPAINT RUNNING BOARD RH', 1, '1'),
(162, 'REPAINT MUFFLER TUBE', 1, '1'),
(163, 'REPLACE ALTERNATOR ASSY', 1, '1'),
(164, 'REPAIR & REPAINT LH FRT. DOOR', 1, '1'),
(165, 'REPAIR & REPAINT LH REAR DOOR', 1, '1'),
(166, 'STENCIL 2KD 9476239', 1, '1'),
(167, 'PARTICIPATION', 1, '1'),
(168, 'CHECK HEADLIGHT FUSE', 1, '1'),
(170, 'REPLACE RADIATOR HOSE', 1, '1'),
(171, 'IMPROVISE BRACKET( BATTERY)', 1, '1'),
(172, 'PARTICIPATION OF CLAIM# MC-CV-HA-11-421', 1, '1'),
(173, 'CAR MATTING CLEANING', 1, '1'),
(174, 'REPLACE HUB BEARING FRT LH', 1, '1'),
(175, 'MACHINING PRESS OUT & INSTALL HUB BEARING', 1, '1'),
(176, 'REPAIR & RETOUCH TRUNK', 1, '1'),
(177, 'ADJUST CLEARANCE', 1, '1'),
(178, 'REPAIR CLUTCH HARD', 1, '1'),
(179, 'REPLACE CLUTCH COVER/RELEASE BEARING', 1, '1'),
(180, 'CHECK WINDOW FRT LH', 1, '1'),
(181, 'REPLACE WEDGE BULB', 1, '1'),
(182, 'REPLACE VALVE SEAL', 1, '1'),
(183, 'REPLACE BRAKE LIGHT SWITCH', 1, '1'),
(184, 'REPLACE BRAKE LIGHT SWITCH/CHECK WIRING', 1, '1'),
(185, 'REPAIR MUFFLER', 1, '1'),
(186, 'CHECK LH REAR DOOR', 1, '1'),
(187, 'REPLACE CONTACT POINT/ADJUST IDLING', 1, '1'),
(188, 'REPLACE WINDOW GLASS FRT/RH', 1, '1'),
(189, 'CLEANING OF PLAINUM& THROTTLE SENSOR', 1, '1'),
(190, 'REPAIR RIM', 1, '1'),
(191, 'CHANGE TIRE', 1, '1'),
(193, 'CHECK HORN', 1, '1'),
(194, 'REPLACE TIRE 175/65/14', 1, '1'),
(195, 'WHEEL BALANCING INCLUDING WEIGHTS', 1, '1'),
(196, 'CHECK SPARK PLUG/REPLACE', 1, '1'),
(197, 'RETOUCH BUMPER LEFTSIDE', 1, '1'),
(198, 'REPLACE QUARTER GLASS', 1, '1'),
(199, 'REPLACE FAN BELT', 1, '1'),
(200, 'INSTALL FOG LAMPS', 1, '1'),
(201, 'REPLACE RADIATOR AUXILIARY FAN ASSEMBLY', 1, '1'),
(202, 'REPLACE OUTER CV JOINT FRONT LH/RH', 1, '1'),
(203, 'COMPLETE FUEL LINE INSP.FROM FUEL TANK,FUEL PUMP& ', 1, '1'),
(204, 'CHECK ELECTRONIC THROTTLE CONTROL SYSTEM', 1, '1'),
(205, 'REPLACE SUSPENSION ARM BUSHING', 1, '1'),
(206, 'MACHINE PRESS BUSHING', 1, '1'),
(207, 'REPLACE SUSPENSION ARM BUSHING 2 PCS. LH', 1, '1'),
(208, 'REPLACE SUSPENSION ARM BUSHING 2PCS. RH', 1, '1'),
(209, 'MACHINE PRESS BUSHING LH', 1, '1'),
(210, 'MACHINE PRESS BUSHING RH', 1, '1'),
(211, 'REPLACE STABILIZER BAR BUSHING RH/LH', 1, '1'),
(212, 'REPAIR POWER LOCK LH FRONT & REAR', 1, '1'),
(213, 'CHECK AUXILLIARY FAN', 1, '1'),
(214, 'OVERHAULING RADIATOR', 1, '1'),
(215, 'CHECK FUSE AUXILLIARY FAN', 1, '1'),
(216, 'REPAIR CHASSIS FRT RH/LH', 1, '1'),
(217, 'REPAIR CHASSIS FRT RH/LH&ADJUST TORSION BAR', 1, '1'),
(218, 'REPAIR LOCK', 1, '1'),
(219, 'INTERIOR DETAILING/VACUUM FLOORING/DETAIL CEILING', 1, '1'),
(220, 'REPLACE BRAKE CALIPER ASSY. FRT RH', 1, '1'),
(221, 'RETOUCH RH FENDER& H FRT REAR DOOR', 1, '1'),
(222, 'ENGINE DETAILING', 1, '1'),
(223, 'FLUSHING,REPLACE EXP. VALVE & DRIER', 1, '1'),
(224, 'REPLACE SOLENOID SWITCH', 0, '1'),
(225, 'AIRCON WIRING', 1, '1'),
(226, 'REPAIR,ALIGN& REPAINT BACKDOOR PANEL ASSY', 1, '1'),
(227, 'REPLACE &ALIGN CARRIER ASSY SPARE TIRE', 1, '1'),
(228, 'REPAIR& ALIGN SPARE TIRE MOUNTING MECHANISM LOCK', 1, '1'),
(229, 'REMOVAL OF PARTS(EMBLEM,WIPER ARM ASSY,WIPER MECHA', 1, '1'),
(230, 'REMOVAL&REINSTALLATION OF BACK GLASS', 1, '1'),
(231, 'REPAIR& ALIGN BACKDOOR HINGE,UPPER&LOWER', 1, '1'),
(232, 'REPAINTING SPARE TIRE COVER', 1, '1'),
(233, 'REPAINT UNDERCHASSIS', 1, '1'),
(234, 'REPAIR OIL LEAK/REPLACE GASKET', 1, '1'),
(235, 'REFILL BRAKE FLUID', 1, '1'),
(236, 'REPAINT FRT BUMPER,REAR BUMPER,', 1, '1'),
(237, 'REPAINT 4PCS.RISSUS', 1, '1'),
(238, 'REPLACE TRANSMISSION', 1, '1'),
(239, 'RETOUCH TRUNK PORTION/REPAINT HOOD', 1, '1'),
(240, 'PARTICIPATION AS POLICY #MC-PC-TC-12-0000611-01', 1, '1'),
(241, 'REPLACE BALLJOINT RH', 1, '1'),
(242, 'RESCUE CHARGE', 1, '1'),
(243, 'REPLACE & INSTALL OF TIRE', 1, '1'),
(244, 'REPLACE & INSTALL OF TIRE/REPLACE RUBBER VALVE', 1, '1'),
(245, 'CONNECT HI-TENSION WIRE', 1, '1'),
(246, 'CHECK ON & OFF ENGINE', 1, '1'),
(247, 'OVERHAUL CARBURETOR', 1, '1'),
(248, 'FABRICATE AIRCON ACTUATOR', 1, '1'),
(249, 'CHECK CENTRAL LOCK/REPAIR& INSTALL ALARM', 1, '1'),
(250, 'REPLACE HORN', 1, '1'),
(252, 'REPLACE STEERING BOOTS', 1, '1'),
(253, 'REPLACE HEADLIGHT BULB', 1, '1'),
(254, 'REPLACE BRAKE PADS', 1, '1'),
(255, 'CHECK BRAKE SWITCH/ADJUST', 1, '1'),
(256, 'REPLACE STEERING LEAK', 1, '1'),
(257, 'REPLACE OIL FILTER', 1, '1'),
(258, 'REPLACE AIR FILTER', 1, '1'),
(259, 'REPAINT FRONT CHIN', 1, '1'),
(260, 'REMOVAL & WELDING OF TUBE', 1, '1'),
(261, 'REPLACE CROSSMEMBER ASSY', 1, '1'),
(262, 'REPLACE RACK END & PENION ASSY', 1, '1'),
(263, 'REPLACE WIPER ARM ,WIPER LEAKAGE ASSY W/ MOTOR', 1, '1'),
(264, 'CHECK WIRING TAIL LIGHT ', 1, '1'),
(265, 'BOLT SIDE SKIRK RH REAR', 1, '1'),
(266, 'REPLACE WIPER COWL COVER', 1, '1'),
(267, 'RETOUCH RH REAR (DOOR-MID)rETOUCH LH FENDER', 1, '1'),
(268, 'REPLACE & REPAINT SIDE MIRROR LR(BODY COLOR)', 1, '1'),
(269, 'CHANGE DOOR BUSHING', 1, '1'),
(270, 'PATCHING', 1, '1'),
(271, 'BUFFING LH QUARTER PANNEL', 1, '1'),
(272, 'CHECK NOISE SHOCK RR/RH', 1, '1'),
(273, 'MACHINE PRESS VELOCITY PULL-OUT', 1, '1'),
(274, 'REPLACE HUB BEARING ( MACHINE PRESS)', 1, '1'),
(275, 'REPLACE CRANK SHAFT OIL SEAL REAR', 1, '1'),
(276, 'REPLACE CLUTCH SLAVE REPAIR KIT TIGHTENED HAND BRA', 1, '1'),
(277, 'REPLACE HI-TENSION WIRE', 1, '1'),
(278, 'REPLACE FUEL PUMP', 1, '1'),
(279, 'ADJUST IDLING', 1, '1'),
(280, 'ALIGN SIDE MIRROR', 1, '1'),
(281, 'TIGHTENED STEP BOARD (LEFTSIDE)', 1, '1'),
(282, 'CLEAN 4PCS. INJECTOR', 1, '1'),
(283, 'REINSTALL TIMING BELT', 1, '1'),
(284, 'REPLACE NOZZEL WIPER', 1, '1'),
(285, 'REPLACE WINDSHIELD ASSY', 1, '1'),
(286, 'REPAIR BRAKE LIGHT SWITCH', 1, '1'),
(287, 'ALIGN ENGINE UNDER COVER', 1, '1'),
(288, 'RESURFACE MOTOR DISK', 1, '1'),
(289, 'REPLACE BRAKE SHOE REAR', 1, '1'),
(290, 'MACHINING PRESS OUT & INSTALL HUB BEARING', 1, '1'),
(291, 'SPINDLE WELD ( MACHINING)', 1, '1'),
(292, 'BRAKE BLEEDING RH', 1, '1'),
(293, 'REPLACE HUB BEARING RH', 1, '1'),
(294, 'HUB BEARING PRESS OUT & INSTALL', 1, '1'),
(295, 'REPAIR & RETOUCH FRT BUMPER', 1, '1'),
(296, 'REPLACE SIDE MIRROR RH & REPAIR WIRINGS', 1, '1'),
(297, 'CHANGE COLOR', 1, '1'),
(298, 'CHECK LOSS POWER/TIMING BELT', 1, '1'),
(299, 'REPLACE PEANUT BULL/REPAIR WIRING', 1, '1'),
(300, 'REPLACE OIL SEAL /ORING', 1, '1'),
(301, 'ADJUST TIMING', 1, '1'),
(302, 'REPLACE T FITTING VACUUM', 1, '1'),
(303, 'CHECK TRANSMISSION &ADJUST, REVERSE GEAR', 1, '1'),
(304, 'OIL LEAKING REPAIR', 1, '1'),
(305, 'REPAIR RADIATOR LEAKING(TEMP. RISE)', 1, '1'),
(306, 'REPLACE GLOW PLUG', 1, '1'),
(307, 'REPLACE WATER PUMP ASSY', 1, '1'),
(308, 'REPLACE HEADLIGHT RH', 1, '1'),
(309, 'REPLACE SHIFTER LINKAGE', 1, '1'),
(310, 'REPLACE CRANKASE GASKET', 1, '1'),
(311, 'REPAIR LEAK STEERING/OVERHAUL POWER STEERING PUMP', 1, '1'),
(312, 'REPLACE FRT WINDSHIELD', 1, '1'),
(313, 'REPLACE VALVE COVER', 1, '1'),
(314, 'REPLACE FUEL INJECTOR', 1, '1'),
(315, 'REPAIR LH POWER WINDOW MECHANISM', 1, '1'),
(316, 'REPLACE BRAKE PISTON CALIPER,CALIPER SET', 1, '1'),
(317, 'REPLACE BRAKE MASTER REPAIR KIT', 1, '1'),
(318, 'REPAIR WINDOW SWITCH', 1, '1'),
(319, 'RETOUCH FRT BUMPER RH/RUBBING FENDER FLARE ', 1, '1'),
(320, 'OVERHAUL/CLEANING,INTAKE MANIFOLD,THROTTLE BODY SE', 1, '1'),
(321, 'CEMENT VALVE COVER GASKET', 1, '1'),
(322, 'CHECK NOISE BRAKE CALIPER RR/LH', 1, '1'),
(323, 'RE-CHRONING STEERING RACK', 1, '1'),
(324, 'RETOUCH RR RH DOOR', 1, '1'),
(325, 'WELDING MUFFLER', 1, '1'),
(326, 'REPAINT REAR SPOILER', 1, '1'),
(327, 'WELDING BRACKETS', 1, '1'),
(328, 'REPAIR STEERING LEAK & REPLACE OIL SEALS', 1, '1'),
(329, 'REPLACE POWER STEERING PUMP', 1, '1'),
(330, 'REPAIR FRT BUMPER', 1, '1'),
(331, 'CHECK BRAKE NOISE', 1, '1'),
(332, 'REPLACE FENDER LH FRT & CORNER LAMP', 1, '1'),
(333, 'RETOUCH QUARTER PANEL RH DOOR', 1, '1'),
(334, 'REPLACE ALIGN & REPAINT QUARTER PANEL ASSY LH', 1, '1'),
(335, 'REPLACE ALIGN TAIL LIGHT ASSY LH', 1, '1'),
(336, 'REPAIR & ALIGN REAR BUMPER ASSY', 1, '1'),
(337, 'REPLACE TIRE 235/75/R15', 1, '1'),
(338, 'REFORM RIMS', 1, '1'),
(339, 'MACHINE PRESS', 1, '1'),
(340, 'REPAIR CERVO/IDLING @ 1500 RPM', 1, '1'),
(341, 'POWER LOCK LH/RH DOOR /REPAIR', 1, '1'),
(342, 'RETOUCH BELT ,BUBBLES LH,DOOR FRT.,LH DENT QUARTER', 1, '1'),
(343, 'REPAIR CV JOINT OUTER', 1, '1'),
(344, 'REPAINT RIMS', 1, '1'),
(345, 'REPLACE AXLE BOOTS OUTER', 1, '1'),
(346, 'REPACK CV JOINT OUTER', 1, '1'),
(347, 'REPLACE SOCKET', 1, '1'),
(348, 'REPAIR VALVE COVER GASKET', 1, '1'),
(349, 'REPLACE VTEC SOLENOID GASKET', 1, '1'),
(350, 'SPINDLES HELS PULLOUT', 1, '1'),
(351, 'PULL OUT HUB BEARING', 1, '1'),
(352, 'REPLACE HOSE CLIPS STRG HOSE 2PCS.', 1, '1'),
(353, 'MACHINE PRESS SPINDLE HUB PULLOUT & INSTALL', 1, '1'),
(354, 'MACHINE PRESS HUB BEARING', 1, '1'),
(355, 'REPLACE WATER PUMP', 1, '1'),
(356, 'ADDITIONAL PAYMENT OF TIRE 185/80/R14', 1, '1'),
(357, 'RUB DOWN 2 SIDE MIRRORS REPAINT', 1, '1'),
(358, 'AIRCON CLEANING/REPAIR', 1, '1'),
(359, 'REPAIR,ALIGN,REPAINT LH REAR DOOR,ALIGN MOLDING LH', 1, '1'),
(360, 'REPLAC POWER STEERING BELT', 1, '1'),
(361, 'REPLACE RUBBER CAP', 1, '1'),
(362, 'CHECK STEERING LEAK', 1, '1'),
(363, 'REPLACE POWER STEERING BELT', 1, '1'),
(364, 'REPLACE SHOCK ABSORBER', 1, '1'),
(365, 'REPLACE SIDE MIRROR RH', 1, '1'),
(366, 'REPLACE TIE ROD END, RACK END, STEERING BOOTS', 1, '1'),
(367, 'TIGHTEN AIRCON BELT', 1, '1'),
(368, 'RETOUCH BRAKE CALIPER FRT LH/RH', 1, '1'),
(369, 'RUB DOWN WHOLE UNIT', 1, '1'),
(370, 'RETOUCH SPOILER', 1, '1'),
(371, 'TINT FRT WINDSHIELD & FRT LH/RH DOOR', 1, '1'),
(372, 'PAINT SIDE MIRROR LH/RH,DOOR HANDLE FRT RR RH/LH', 1, '1'),
(373, 'FOG LAMP COVER LH/RH', 1, '1'),
(374, 'REPAIR CHECK ENGINE', 1, '1'),
(375, 'BOLT TIGHTING & CHECK NOISE', 1, '1'),
(376, 'REPLACE GEAR BOX BOLT', 1, '1'),
(377, 'REPLACE TIE ROD END', 1, '1'),
(378, 'INNER OUTER LH/R OUT', 1, '1'),
(379, 'REPLACE CENTER BEARING', 1, '1'),
(380, 'REPLACE CLUTCH HOSE', 1, '1'),
(381, 'REPLACE UPPER HOSE', 1, '1'),
(382, 'REPLACE RADIATOR /CHECK', 1, '1'),
(383, 'REPAIR WATER LEAKS', 1, '1'),
(384, 'WELDING ALUMINUM WATER SPORT', 1, '1'),
(385, 'REPLACE SPARK PLUG', 1, '1'),
(386, 'REPAIR DOOR POWER MOTOR FRT. & REAR LH', 1, '1'),
(387, 'REPAIR SWITCH', 1, '1'),
(388, 'CHECK SHOCK ABSORBER', 1, '1'),
(389, 'REPAIR LH FRT DOOR POWER LOCK', 1, '1'),
(390, 'ADJUST THERMOSTAT', 1, '1'),
(391, 'LIFT UP 2 COIL SPRING', 1, '1'),
(392, 'ADJUST MENOR/CLEAN SPARK PLUG', 1, '1'),
(393, 'REPLACE 2 BELT', 1, '1'),
(394, 'REPLACE FUEL HOSE', 1, '1'),
(395, 'REPLACE RACK END L/R', 1, '1'),
(396, 'REPLACE TIE ROD END L/R', 1, '1'),
(397, 'REPLACE STABILIZER BAR BUSHING LR', 1, '1'),
(398, 'REPLACE BALLJOINT LR', 1, '1'),
(399, 'REPLACE ARM BUSHING FRONT LR', 1, '1'),
(400, 'REPLACE ARM BUSHING REAR LR', 1, '1'),
(401, 'MACHINING BALLJOINT PULL OUT & INSTALL', 1, '1'),
(402, 'REPLACE DOOR GLASS LH FRT', 1, '1'),
(403, 'REPALCE WINDOW RUBBER', 1, '1'),
(404, 'REPLACE WINDOW RUBBER', 1, '1'),
(405, 'RESURFACE RH MOTOR DISC', 1, '1'),
(406, 'REPLACE ACCELERATOR CABLE', 1, '1'),
(407, 'TIGHTEN DRAIN PLUG', 1, '1'),
(408, 'REPLACE LH RACK END', 1, '1'),
(409, 'REPLACE LH TIE ROD END', 1, '1'),
(410, 'REPLACE LH LOWER ARM BUSHING', 1, '1'),
(411, 'MACHINING BUSHING PRESS IN & INSTALL', 1, '1'),
(412, 'REPLACE CRANK CASE GASKET', 1, '1'),
(413, 'REFILL TRANSMISSION OIL/ ENGINE OIL', 1, '1'),
(414, 'REPACK BEARING FRT LR', 1, '1'),
(415, 'REPLACE BALLJOINT', 1, '1'),
(416, 'CHECK FUEL GAUGE', 1, '1'),
(417, 'CUT RACK END WELDING', 1, '1'),
(418, 'STEREO(PIONEER X2550BT)', 1, '1'),
(419, 'HID FOGLAMP', 1, '1'),
(420, 'WIRING KIT', 1, '1'),
(421, 'CHECK BRAKES/REPLACE BRAKE PADS', 1, '1'),
(422, 'WELDING MUFFLER SUPPORT', 1, '1'),
(423, 'REPLACE LEAF SPRING BUSHINGS', 1, '1'),
(424, 'REPLACE BY PASS HOSE CLAMP& ORING ( DRAIN PLUG)', 1, '1'),
(425, 'REPLACE BUMP STOP LR', 1, '1'),
(426, 'REPLACE CRANK SHAFT PULLEY', 1, '1'),
(427, 'REPLACE STEERING PINION BUSHING/GROMMET', 1, '1'),
(428, 'CARWASH', 1, '1'),
(429, 'TUNE-UP, CHECK ENGINE', 1, '1'),
(430, 'HESITANT DURING ACCEL/ABS,REPAIR BRAKE LIGHT', 1, '1'),
(431, 'REPLACE HUB BEARING REAR LH', 1, '1'),
(432, 'RECONNECT FOG LAMP', 1, '1'),
(433, 'REPLACE SHOCK ABSORBER FRONT LH/RH', 1, '1'),
(434, 'REPLACE RADIATOR HOSE UPPER & REFILL COOLANT', 1, '1'),
(435, 'REINSTALLER PISTON & BRAKE PADS FRT LH', 1, '1'),
(436, 'CHECK BRAKE/CLEANING 380/.SIDE LR FRONT', 1, '1'),
(437, 'REPLACE DISTRIBUTOR OIL SEAL /REPLACE BOST CROSSME', 1, '1'),
(438, 'REPLACE UPPER RADIATOR HOSE', 1, '1'),
(439, 'INSTALL H/B HEADLIGHT', 1, '1'),
(440, 'INSTALL H/B FOG LAMP', 1, '1'),
(441, 'CHECK ON 2 OFF , NO FORCE, REPLACE RELAY', 1, '1'),
(442, 'CLEAN FUEL TANK', 1, '1'),
(443, 'EXCESS FOR TIRE @ 520/ TIRE', 1, '1'),
(444, 'CHECK TRANSMISSION LEAK/REPAIR', 1, '1'),
(445, 'CHECK CLUTCH/REPLACE PRIMARY CLUTCH', 1, '1'),
(446, 'REPAIR HEADLIGHT', 1, '1'),
(447, 'ALIGN LH FRT & REAR DOOR', 1, '1'),
(448, 'CHANGE LH FRT. TIRE TO LH REAR ', 1, '1'),
(449, 'CLEAN CARBURATOR', 1, '1'),
(450, 'REPLACE STARTER ASSY', 0, '1'),
(451, 'REPLACE STARTER ASSY', 1, '1'),
(452, 'REPLACE, ALIGN & REPAINT REAR BUMPER ASSY', 1, '1'),
(453, 'REPLACE MUFFLER SUPPORT', 1, '1'),
(454, 'GRINDING PISTON PIN MACHINING', 1, '1'),
(455, 'CUTTING PISTON PIN', 1, '1'),
(456, 'REFACE CYLINDER HEAD', 1, '1'),
(457, 'LABOR', 1, '1'),
(458, 'PRESSING PISTON PIN', 1, '1'),
(459, 'INSTALL SIMOTA AIR INTAKE', 1, '1'),
(460, 'REPAIR BRAKE CALIPER LH/RH', 1, '1'),
(461, 'ROTOR HEAD RECONDITIONING', 1, '1'),
(462, 'LABOR PULL OUT & INSTALL', 1, '1'),
(463, 'CALIBRATE BALANCING', 1, '1'),
(464, 'ADJUST ALTERNATOR BELT', 1, '1'),
(465, 'ADJUST AIRCON BELT', 1, '1'),
(466, 'CHECK NO FORCE ( ON & OFF ) REPAIR', 1, '1'),
(467, 'REPLACE TIE ROD END LR', 1, '1'),
(468, 'REPLACE RACK END', 1, '1'),
(469, 'REPLACE STABILIZER LINK', 1, '1'),
(470, 'RESKIE BIG LOWER ARM BUSHING ', 1, '1'),
(471, 'REPLACE 2 PCS. STEERING RACK BOOTS', 1, '1'),
(472, 'REPLACE 2PCS. HUB BEARING RH/LH', 1, '1'),
(473, 'REPLACE 2 PCS. UPPER ARM ASSY', 1, '1'),
(474, 'PRESS IN/OUT SUSP. BUSHING', 1, '1'),
(475, 'PRESS OUT & INSTALL HUB BEARING', 1, '1'),
(476, 'GREASING OF LH BRAKE PADS', 1, '1'),
(477, 'INSTALL POWER LOCK & ALARM', 1, '1'),
(478, 'REPAIR & REPAINT TRUNK', 1, '1'),
(479, 'CHECK ALTERNATOR BEARING, REPLACE BEARING BIG& SMA', 1, '1'),
(480, 'REPLACE STUD BOLT', 1, '1'),
(481, 'REPAIR SLIDING DOOR RH', 1, '1'),
(482, 'CHECK HEADLIGHT', 1, '1'),
(483, 'REPAIR STEERING SOUND', 1, '1'),
(484, 'STORAGE FEE & MOLDING', 1, '1'),
(485, 'WELDING BOLT', 1, '1'),
(486, 'REPLACE SHOCK BUSHING', 1, '1'),
(487, 'REPAIR, ALIGN & REPAINT FRT RH DOOR , FENDER RH ( ', 1, '1'),
(488, 'REPLACE HEADLIGHT/ REPAIR & REPAINT FRT BUMPER RIG', 1, '1'),
(489, 'INSTALL REAR WING', 1, '1'),
(490, 'PULL OUT & INSTALL', 1, '1'),
(491, 'CLEANING & ASSEMBLE', 1, '1'),
(492, 'REPLACE HOSE', 1, '1'),
(493, 'BALANCING & CALIBRATE', 1, '1'),
(494, 'INTAKE & GRIND', 1, '1'),
(495, 'FULL TINTING AU WINDOWS', 1, '1'),
(496, 'REPLACE HEADLIGHT & CLEARANCE LAMP COMBINATION', 1, '1'),
(497, 'REPAIR DOOR MOLDING', 1, '1'),
(498, 'HEADLIGHT/HORN', 1, '1'),
(499, 'CHECK WATER LEAKING BYPASS', 1, '1'),
(500, 'STARTER ASSY', 1, '1'),
(501, 'HEADLIGHT GROUNDED', 1, '1'),
(502, 'CALIBRATION INJECTION PUMP / INJECTOR', 1, '1'),
(503, 'REPAIR SWITCH MAIN POWER WINDOW', 1, '1'),
(504, 'CHECK UP ENGINE LEAKING', 1, '1'),
(505, 'INSTALL REAR RH HUB BEARING', 1, '1'),
(506, 'ALIGN REAR BUMPER FRT & REAR RH MUDGUARDS', 1, '1'),
(507, 'REPLACE BYPASS HOSE', 1, '1'),
(508, 'WELDING & MACHINING OF ALUMINUM PARTS', 1, '1'),
(509, 'CHANGE SPARK PLUG', 1, '1'),
(510, 'CHANGE FUEL FILTER', 1, '1'),
(511, 'REPAIR BRAKE LIGHTS', 1, '1'),
(512, 'REPLACE ORING FOAM,FUEL PUMP ', 1, '1'),
(513, 'REPAIR, ALIGN & REPAINT FRONT BUMPER', 1, '1'),
(514, 'REPAIR POWER STEERING LEAK', 1, '1'),
(515, 'REPAIR REAR LEFT SIDE DOOR', 1, '1'),
(516, 'REPLACE FUEL FLOAT  GAUGE', 1, '1'),
(517, 'REPLACE REAR SHOCK', 1, '1'),
(518, 'ASSEMBLE ENGINE, OVERHAUL ENGINE', 1, '1'),
(519, 'REWIRE AUX FAN AIRCON ,REPLACE AUXFAN, INSTALL REL', 1, '1'),
(520, 'CHECK LOWER ARM BUSHING,ATTACHING SUSP., CHECK TIE', 1, '1'),
(521, 'CHECK AIRCON /CLEANING CONDENSER', 1, '1'),
(522, 'REPLACE CLUTCH COVER,CLUTCH DISC , & RELEASE BEARI', 1, '1'),
(523, 'IRATIC IDLING', 1, '1'),
(524, 'REPAIR AIRCON SYSTEM', 1, '1'),
(525, 'REPLACE ACTUATOR', 1, '1'),
(526, 'REPLACE HOSE CLAMP', 1, '1'),
(527, 'STENCIL', 1, '1'),
(528, 'REPAIR DOOR LH MECHANISM', 1, '1'),
(529, 'VULCATE TIRE', 1, '1'),
(530, 'INSTALL MUFFLER', 1, '1'),
(531, 'REWORK THERMOSTAT', 1, '1'),
(532, 'DOWN FUEL TANK', 1, '1'),
(533, 'REPLACE UPPER ARM ASSY L/R', 1, '1'),
(534, 'REPLACE IDLER ARM', 1, '1'),
(535, 'JUMPER BATTERY', 1, '1'),
(536, 'REPLACE WATER PLUG W/ PARTS', 1, '1'),
(537, 'REPLACE TRUNK CABLE', 1, '1'),
(538, 'REPAIR FUEL TANK COVER/TIGHTEN', 1, '1'),
(539, 'REPAIR NOISE REAR PORTION', 1, '1'),
(540, 'SEALED VALVE COVER', 1, '1'),
(541, 'LIFT-UP', 1, '1'),
(542, 'CHANGE ATF', 1, '1'),
(543, 'HOME SERVICE CHARGE', 1, '1'),
(544, 'REPLACE INJECTION PUMP', 1, '1'),
(545, 'CHANGE TERMINAL BATTERY', 1, '1'),
(546, 'CHECK HARD START/INSTALL PUSH BOTTON FOR HEATER', 1, '1'),
(547, 'REPLACE STEERING RACK BUSHING', 1, '1'),
(548, 'REPLACE CARBORATOR REPAIR KIT', 1, '1'),
(549, 'WELDING EMPALMING CHASSIS RH', 1, '1'),
(550, 'REPLACE AIRCON TENSIONER BEARING ', 1, '1'),
(551, 'REPLACE AIRCON BELT', 1, '1'),
(552, 'REPAIR TIRE', 1, '1'),
(553, 'INSTALL BRAKE AUXILLIARY', 1, '1'),
(554, 'REPLACE IGNITION SWITCH', 1, '1'),
(555, 'ALIGN SIDE PANEL FRT LH DOOR/TIGHTEN BOLTS', 1, '1'),
(556, 'REPLACE AXLE BOOTS', 1, '1'),
(557, 'REPLACE BRAKE MASTER', 1, '1'),
(558, 'CHECK NOISE/ ADJUST BOOTS/REPLACE ALTERNATOR BELT', 1, '1'),
(559, 'REMOVAL & INSTALLATION OF RADIATOR', 1, '1'),
(560, 'REPLACE TEMP. SENDER/REPLACE HOSE CLIP', 1, '1'),
(561, 'REPLACE BALL JOINT LH LOWER/REPLACE FRT BRAKE PADS', 1, '1'),
(562, 'REPLACE AUX FAN MOTOR', 1, '1'),
(563, 'POWER LOCK INSTALLATION', 1, '1'),
(564, 'CLEAN SPARK PLUG', 1, '1'),
(565, 'CHECK BRAKE REPAIR', 1, '1'),
(566, 'REPLACE OIL SENDER', 1, '1'),
(567, 'REPLACE BALL JOINT LH UPPER', 1, '1'),
(568, 'REPLACE CLUTCH SLAVE REPAIR KIT', 1, '1'),
(569, 'CHANGE OIL DIFFERENTIAL', 1, '1'),
(570, 'REPAIR POWER LOCK', 1, '1'),
(571, 'REPLACE LEAF SPRING L/R', 1, '1'),
(572, 'REPLACE FRONT BRAKE PADS', 1, '1'),
(573, 'REPLACE BRAKE MASTER KIT LEAKING', 1, '1'),
(574, 'REPLACE FOG LAMP ASSY', 1, '1'),
(575, 'INSTALL FUEL ENERGY SAVER/BRACKET WATER TEMP. GAUG', 1, '1'),
(576, 'REPAIR, ALIGN & REPAINT  TRUNK ASSY, REAR BUMPER, ', 1, '1'),
(577, 'REPLACE RADIATOR ASSY', 1, '1'),
(578, 'TIGHTEN POWER STEERING BELT', 1, '1'),
(579, 'REMOVAL & INSTALL OF TIRE & REPLACE RUBBER VALVE', 1, '1'),
(580, 'WHEEL BALANCING', 1, '1'),
(581, 'REPLACE DOOR HANDLE FRT RH', 1, '1'),
(582, 'REPAIR CENTRAL LOCK ( ALL SIDES )', 1, '1'),
(583, 'REPLACE THERMO SWITCH', 1, '1'),
(584, 'REPAIR AUXICILLIARY FAN', 1, '1'),
(585, 'REPLACE CLUTCH SLAVE ASSY', 1, '1'),
(586, 'REPLACE WHEEL CYLINDER ASSY', 1, '1'),
(587, 'REPLACE HORN SWITCH', 1, '1'),
(588, 'REPAIR RADIATOR', 1, '1'),
(589, 'OVERHAUL RADIATOR', 1, '1'),
(590, 'RESURFACE ROTOR DISC', 1, '1'),
(591, 'REPLACE REPAIR KIT/BRAKE MASTER', 1, '1'),
(592, 'REPLACE LOWER L/R', 1, '1'),
(593, 'REPAIR LOWER BALL JOINT L/R', 1, '1'),
(594, 'MACHINING LOWER ARM BUSHING PULL OUT & INSTALL', 1, '1'),
(595, 'REPAINT FRONT BUMPER', 1, '1');

-- --------------------------------------------------------

--
-- Table structure for table `logintrace`
--

CREATE TABLE IF NOT EXISTS `logintrace` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(35) DEFAULT NULL,
  `succeeded` enum('0','1') DEFAULT '0',
  `tracetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=122 ;

--
-- Dumping data for table `logintrace`
--

INSERT INTO `logintrace` (`id`, `username`, `succeeded`, `tracetime`) VALUES
(1, 'juntals', '1', '2013-05-28 16:44:07'),
(2, 'juntals', '1', '2013-05-28 16:55:26'),
(3, 'juntals01', '0', '2013-05-28 16:56:06'),
(4, 'juntals', '1', '2013-05-28 16:57:03'),
(5, 'juntals', '1', '2013-05-29 07:18:22'),
(6, 'juntals', '1', '2013-05-29 10:05:58'),
(7, 'juntals', '1', '2013-05-29 14:12:50'),
(8, 'juntals', '1', '2013-05-29 23:52:24'),
(9, 'juntals', '1', '2013-05-30 00:32:29'),
(10, 'kenn', '1', '2013-05-30 06:46:08'),
(11, 'kenn', '1', '2013-05-30 14:14:46'),
(12, 'kenn', '1', '2013-05-30 22:39:41'),
(13, 'kenn', '1', '2013-05-31 04:19:19'),
(14, 'kenn', '0', '2013-05-31 04:19:44'),
(15, 'kenn', '1', '2013-05-31 04:19:51'),
(16, 'kenn', '1', '2013-06-02 07:11:17'),
(17, 'kenn', '1', '2013-06-03 07:51:42'),
(18, 'kenn', '1', '2013-06-03 19:03:47'),
(19, 'kenn', '1', '2013-06-04 02:03:11'),
(20, 'kenn', '1', '2013-06-04 23:20:57'),
(21, 'kenn', '1', '2013-06-05 01:48:00'),
(22, 'kenn', '1', '2013-06-05 15:27:53'),
(23, 'kenn', '1', '2013-06-05 18:59:57'),
(24, 'digiartist', '0', '2013-06-05 22:54:00'),
(25, 'kenn', '0', '2013-06-05 22:54:06'),
(26, 'kenn', '0', '2013-06-05 22:54:17'),
(27, 'kenn', '1', '2013-06-05 22:54:30'),
(28, 'kenn', '1', '2013-06-06 06:29:59'),
(29, 'kenn', '1', '2013-06-06 15:11:03'),
(30, 'kenn', '0', '2013-06-06 18:07:33'),
(31, 'kenn', '1', '2013-06-06 18:07:39'),
(32, 'kenn', '1', '2013-06-07 18:09:18'),
(33, 'kenn', '1', '2013-06-07 06:36:08'),
(34, 'kenn', '1', '2013-06-08 06:45:25'),
(35, 'kenn', '1', '2013-06-09 06:45:58'),
(36, 'kenn', '1', '2013-06-07 06:50:12'),
(37, 'marc', '1', '2013-06-07 07:28:23'),
(38, 'kenn', '1', '2013-06-07 07:30:08'),
(39, 'kenn', '1', '2013-06-07 09:30:37'),
(40, 'kenn', '1', '2013-06-07 11:24:21'),
(41, 'kenn', '1', '2013-06-07 17:41:40'),
(42, 'kenn', '1', '2013-06-07 17:49:54'),
(43, 'emz', '0', '2013-06-07 17:55:25'),
(44, 'emz', '0', '2013-06-07 17:55:32'),
(45, 'emz', '0', '2013-06-07 17:56:02'),
(46, 'emz', '0', '2013-06-07 17:56:28'),
(47, 'kenn', '1', '2013-06-07 17:59:52'),
(48, 'emz', '1', '2013-06-07 18:00:59'),
(49, 'kenn', '1', '2013-06-07 18:10:15'),
(50, 'emz', '1', '2013-06-07 18:12:47'),
(51, 'kenn', '1', '2013-06-07 18:18:18'),
(52, 'kenn', '1', '2013-06-08 01:19:20'),
(53, 'ken', '0', '2013-05-29 10:31:36'),
(54, 'kenn', '1', '2013-05-29 10:31:40'),
(55, 'kenn', '1', '2013-06-08 10:32:13'),
(56, 'admin', '1', '2013-06-08 11:19:57'),
(57, 'admin', '1', '2013-06-08 11:20:46'),
(58, 'nanettee', '1', '2013-06-08 11:24:28'),
(59, 'NANETTEE', '1', '2013-06-08 11:58:08'),
(60, 'nanettee', '1', '2013-06-08 23:50:14'),
(61, 'NANETTEE', '1', '2013-06-09 04:18:03'),
(62, 'NANETTEE', '1', '2013-06-09 04:42:03'),
(63, 'NANETTEE', '1', '2013-06-09 05:25:31'),
(64, 'NANETTEE', '1', '2013-06-09 05:41:52'),
(65, 'NANETTEE', '1', '2013-06-09 05:43:21'),
(66, 'NANETTEE', '1', '2013-06-09 06:20:51'),
(67, 'nanettee', '1', '2013-06-09 08:23:09'),
(68, 'NANETTEE', '1', '2013-06-09 11:04:15'),
(69, 'NANETTEE', '1', '2013-06-09 11:22:44'),
(70, 'NANETTEE', '1', '2013-06-09 12:26:03'),
(71, 'NANETTEE', '1', '2013-06-09 12:27:17'),
(72, 'NANETTEE', '1', '2013-06-09 13:22:08'),
(73, 'admin', '1', '2013-06-11 21:12:09'),
(74, 'nanettee', '1', '2013-06-12 09:17:56'),
(75, 'nanettee', '1', '2013-06-13 01:11:05'),
(76, 'NANETTEE', '1', '2013-06-13 08:28:52'),
(77, 'nanettee', '1', '2013-06-13 11:38:41'),
(78, 'nanettee', '1', '2013-06-14 01:16:26'),
(79, 'NANETTEE', '1', '2013-06-14 08:02:43'),
(80, 'nanettee', '1', '2013-06-15 01:03:42'),
(81, 'nanettee', '1', '2013-06-17 05:48:49'),
(82, 'NANETTEE', '1', '2013-06-17 06:00:43'),
(83, 'NANETTEE', '1', '2013-06-17 08:15:47'),
(84, 'nanettee', '1', '2013-06-18 01:26:10'),
(85, 'NANETTEE', '1', '2013-06-18 08:22:28'),
(86, 'nanettee', '1', '2013-06-19 01:14:20'),
(87, 'nanettee', '1', '2013-06-19 05:52:30'),
(88, 'nanettee', '1', '2013-06-19 09:22:26'),
(89, 'nanettee', '0', '2013-06-20 01:17:03'),
(90, 'nanettee', '1', '2013-06-20 01:17:21'),
(91, 'nanettee', '1', '2013-06-21 01:06:08'),
(92, 'admin', '1', '2013-06-28 14:34:48'),
(93, 'admin', '1', '2013-06-28 22:10:57'),
(94, 'admin', '0', '2013-06-29 23:46:54'),
(95, 'admin', '1', '2013-06-29 23:47:05'),
(96, 'admin', '1', '2013-06-30 06:43:32'),
(97, 'admin', '1', '2013-06-30 10:58:40'),
(98, 'admin', '1', '2013-06-30 16:34:38'),
(99, 'admin', '1', '2013-06-30 23:45:26'),
(100, 'admin', '1', '2013-07-07 16:56:05'),
(101, 'admin', '1', '2013-07-07 23:16:38'),
(102, 'admin', '1', '2013-07-08 21:34:14'),
(103, 'admin', '1', '2013-07-09 08:32:29'),
(104, 'admin', '1', '2013-07-09 23:54:06'),
(105, 'admin', '1', '2013-07-10 08:39:41'),
(106, 'admin', '1', '2013-07-13 07:31:33'),
(107, 'admin', '1', '2013-07-13 13:15:09'),
(108, 'admin', '0', '2013-07-14 14:54:46'),
(109, 'admin', '1', '2013-07-14 14:54:50'),
(110, 'admin', '1', '2013-07-14 14:59:54'),
(111, 'admin', '1', '2013-07-14 15:05:20'),
(112, 'nanettee', '1', '2013-07-14 15:07:47'),
(113, 'NANETTEE', '1', '2013-07-14 20:11:46'),
(114, 'NANETTEE', '1', '2013-07-14 20:33:17'),
(115, 'nanettee', '1', '2013-07-14 20:35:46'),
(116, 'nanettee', '1', '2013-07-15 01:57:26'),
(117, 'NANETTEE', '1', '2013-07-16 07:46:46'),
(118, 'nanettee', '1', '2013-07-17 01:50:59'),
(119, 'NANETTEE', '1', '2013-07-17 07:29:28'),
(120, 'NANETTEE', '1', '2013-07-17 07:32:46'),
(121, 'NANETTEE', '1', '2013-07-18 03:00:54');

-- --------------------------------------------------------

--
-- Table structure for table `option`
--

CREATE TABLE IF NOT EXISTS `option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `option_name` mediumtext,
  `option_value` longtext,
  `autoload` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COMMENT='IMBA JUNTALS' AUTO_INCREMENT=27 ;

--
-- Dumping data for table `option`
--

INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES
(1, 'section_metahead', '{"0":"funcmeta"}', '1'),
(2, 'section_metastyle', '{"0":"funcmetastyle"}', '1'),
(3, 'section_metascript', '{"0":"funcmetasript"}', '1'),
(4, 'section_masthead', '{"0":"funcone"}', '1'),
(5, 'section_panels', '{"0":"dbconfig","1":"functpaste"}', '1'),
(6, 'section_pasteboard', '{"0":"funcpasteboard"}', '1'),
(7, 'section_toolbars', '{"0":"functoolbar"}', '1'),
(8, 'section_footer', '{"0":"footerfunc"}', '1'),
(9, 'section_metahead', '{"0":"funcmeta"}', '1'),
(10, 'section_metastyle', '{"0":"funcmetastyle"}', '1'),
(11, 'section_metascript', '{"0":"funcmetasript"}', '1'),
(12, 'section_masthead', '{"0":"funcone"}', '1'),
(13, 'section_panels', '{"0":"dbconfig","1":"functpaste"}', '1'),
(14, 'section_panels', '{"0":"dbconfig","1":"functpaste"}', '1'),
(15, 'section_pasteboard', '{"0":"funcpasteboard"}', '1'),
(16, 'section_toolbars', '{"0":"functoolbar"}', '1'),
(17, 'section_footer', '{"0":"footerfunc"}', '1'),
(18, 'section_metahead', '{"0":"funcmeta"}', '1'),
(19, 'section_metastyle', '{"0":"funcmetastyle"}', '1'),
(20, 'section_metascript', '{"0":"funcmetasript"}', '1'),
(21, 'section_masthead', '{"0":"funcone"}', '1'),
(22, 'section_panels', '{"0":"dbconfig","1":"functpaste"}', '1'),
(23, 'section_panels', '{"0":"dbconfig","1":"functpaste"}', '1'),
(24, 'section_pasteboard', '{"0":"funcpasteboard"}', '1'),
(25, 'section_toolbars', '{"0":"functoolbar"}', '1'),
(26, 'section_footer', '{"0":"footerfunc"}', '1');

-- --------------------------------------------------------

--
-- Table structure for table `tendertype`
--

CREATE TABLE IF NOT EXISTS `tendertype` (
  `tdr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`tdr_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `tendertype`
--

INSERT INTO `tendertype` (`tdr_id`, `name`) VALUES
(1, 'Cash'),
(2, 'Check');

-- --------------------------------------------------------

--
-- Table structure for table `tmp`
--

CREATE TABLE IF NOT EXISTS `tmp` (
  `count` varchar(15) DEFAULT NULL,
  `status` enum('0','1') DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tmp`
--

INSERT INTO `tmp` (`count`, `status`) VALUES
('MFN 122', '0'),
('KHU-111', '0'),
('MFB-115', '0'),
('UAR-731', '0'),
('0000', '0'),
('KCT-107', '0'),
('KCK-965', '0'),
('PQM-689', '0'),
('KDE-550', '0'),
('KCU-764', '0'),
('KEL-935', '0'),
('KEJ-416', '0'),
('ZLJ-948', '0'),
('KCZ656', '0'),
('KBP-657', '0'),
('GEN-732', '0'),
('KFU-553', '0'),
('ZKP-920', '0'),
('KDM-249', '0'),
('UKA-563', '0'),
('NOL-541', '0'),
('NQV-326', '0'),
('KVU-924', '0'),
('NOA-844', '0'),
('KCM-313', '0'),
('KCC-437', '0'),
('KGF-430', '0'),
('NQL-699', '0'),
('KCZ-580', '0'),
('TJD-176', '0'),
('KDE-510', '0'),
('UAH-908', '0'),
('POK-765', '0'),
('NO PLATE', '0'),
('XHV-831', '0'),
('GPX-640', '0'),
('ZTR-517', '0'),
('KCS-463', '0'),
('POK-165', '0'),
('JBS-789', '0'),
('OEV-356', '0'),
('KER 975', '0'),
('KDA-668', '0'),
('NOK-251', '0'),
('MFN-122', '0'),
('XGJ-146', '0'),
('UKD-396', '0'),
('NKO-676', '0'),
('zlt-784', '0'),
('XJC-760', '0'),
('ZCG-528', '0'),
('KCG-656', '0'),
('VEZ-620', '0'),
('ZJW-965', '0'),
('KEG-189', '0'),
('GTB-254', '0'),
('KBU-537', '0'),
('TPS 526', '0'),
('ZGP662', '0'),
('PBO-950', '0'),
('KCH-342', '0'),
('ZTR 740', '0'),
('ZPE-142', '0'),
('KFY-684', '0'),
('KFN-437', '0'),
('NDL-541', '0'),
('ZTR-990', '0'),
('ZKP-410', '0'),
('ZRW-466', '0'),
('PMB-177', '0'),
('KGJ-185', '0'),
('KDP-703', '0'),
('KDU-175', '0'),
('ZYX-222', '0'),
('GHR-257', '0'),
('KCF-884', '0'),
('KCF-648', '0'),
('GJR-238', '0'),
('SHJ-477', '0'),
('XMR-211', '0'),
('THG-207', '0'),
('ZMH 389', '0'),
('KFZ-679', '0'),
('KDE-850', '0'),
('ZGP-662', '0'),
('ZRM-270', '0'),
('UKD 396', '0'),
('TGD-371', '0'),
('NOE 844', '0'),
('URB-361', '0'),
('PKI-588', '0'),
('WHV-610', '0'),
('UBS-806', '0'),
('ZPU-213', '0'),
('PIX-852', '0'),
('RCA-655', '0'),
('KEZ-926', '0'),
('KBJ-555', '0'),
('XGS-555', '0'),
('GJY 555', '0'),
('YDF-296', '0'),
('WTG-939', '0'),
('KDP-466', '0'),
('TDS-280', '0'),
('AIG-207', '0'),
('GEV-975', '0'),
('THG-207`', '0'),
('STJ-483', '0'),
('KDF-860', '0'),
('GGV-946', '0'),
('UTV-141', '0'),
('KDV-819', '0'),
('GHJ-358', '0'),
('ZHM-389', '0'),
('PUD-750', '0'),
('ZRM-710', '0'),
('XHX-944', '0'),
('GHH-333', '0'),
('ZDK-482', '0'),
('MEZ-141', '0'),
('MBR-615', '0'),
('GDL-522', '0'),
('GDL-522`', '0'),
('KGB-589', '0'),
('CSL-577', '0'),
('KEF-875', '0'),
('ZMH-389', '0'),
('ZNG-361', '0'),
('ZDX-543', '0'),
('KEY-684', '0'),
('YCJ-718', '0'),
('KCZ-588', '0'),
('KCN-367', '0'),
('GJY-555', '0'),
('NIY 431', '0'),
('ZKP-420', '0'),
('ZTL-451', '0'),
('NKO-749', '0'),
('ZSS-343', '0'),
('PYI-919', '0'),
('KCG-196', '0'),
('WLP-276', '0'),
('UGN-620', '0'),
('TZL-389', '0'),
('KDL-558', '0'),
('PHO-378', '0'),
('GKZ-601', '0'),
('KBY- 402', '0'),
('XBN-266', '0'),
('GST-813', '0'),
('III-209', '0'),
('TRV-304', '0'),
('NKO-755', '0'),
('TLL-389', '0'),
('KFE-435', '0'),
('ZHL-789', '0'),
('ZHT-951', '0'),
('UQD-136', '0'),
('NDO-841', '0'),
('USR-727', '0'),
('ZRC-290', '0'),
('NOE-521', '0'),
('ZPA-807', '0'),
('UGI-829', '0'),
('KFD-269', '0'),
('GJT-362', '0'),
('ZRD-124', '0'),
('SEH-870', '0'),
('KCS-703', '0'),
('GEV-426', '0'),
('PVI-747', '0'),
('KDG-948', '0'),
('JDF-946', '0'),
('WDY-595', '0'),
('AJM-818', '0'),
('KGF-629', '0'),
('ZNT-582', '0'),
('KDS-796', '0'),
('MAE-280', '0'),
('GSI-813', '0'),
('ZTR-170', '0'),
('KDX-177', '0'),
('ZNY-414', '0'),
('LDD-210', '0'),
('KDF-839', '0'),
('YFB-755', '0'),
('PRI-747', '0'),
('XKU-437', '0'),
('LMS-880', '0'),
('XAB-537', '0'),
('KDN-427', '0'),
('ZMR-406', '0'),
('LNG-327', '0'),
('KCK-301', '0'),
('KEP-900', '0'),
('KDY-177', '0'),
('TJV-567', '0'),
('KFL-939', '0'),
('KEY-282', '0'),
('ZRN-459', '0'),
('ZTR-669', '0'),
('ZLN-861', '0'),
('TIP-991', '0'),
('KEL-874', '0'),
('PVI-539', '0'),
('KDC-286', '0'),
('KVU- 621', '0'),
('ZLJ--949', '0'),
('LCL-832', '0'),
('XLV-984', '0'),
('ZPU-212', '0'),
('XTF-691', '0'),
('NOQ-707', '0'),
('XTF-961', '0'),
('GDW-136', '0'),
('YJK-675', '0'),
('KCD-519', '0'),
('WBG-922', '0'),
('KDN-353', '0'),
('KGC-200', '0'),
('HID-175', '0'),
('WJU-947', '0'),
('WEM-368', '0'),
('KDZ-156', '0'),
('ZPC-471', '0'),
('KBY-537', '0'),
('KCG-917', '0'),
('KDD-971', '0'),
('KDR-243', '0'),
('UFT-620', '0'),
('RDM-798', '0'),
('WMD-562', '0'),
('KCG-608', '0'),
('ZNT-572', '0'),
('KDY-259', '0'),
('GHX-665', '0'),
('GGM-661', '0'),
('XBO-900', '0'),
('KCZ- 517', '0'),
('KCV-231', '0'),
('KDP-374', '0'),
('KCT-444', '0'),
('KCG-588', '0'),
('KCZ-172', '0'),
('KDM-194', '0'),
('TLQ-940', '0'),
('UKD-412', '0'),
('GHR-704', '0'),
('KDJ-539', '0'),
('TIJ-622', '0'),
('ZGN-690', '0'),
('WCG-849', '0'),
('YBV-419', '0'),
('GJG-536', '0'),
('KDY-864', '0'),
('KDJ-188', '0'),
('KOV-297', '0'),
('FRT-808', '0'),
('KCB-241', '0'),
('KTU-553', '0'),
('MFV-573', '0'),
('RDW-648', '0'),
('TIG-509', '0'),
('ZLN-871', '0'),
('NAO-606', '0'),
('JCT-394', '0'),
('KCD- 382', '0'),
('KCM-985', '0'),
('UIL-949', '0'),
('XRD-841', '0'),
('KVU-921', '0'),
('ZFU-359', '0'),
('WKO-676', '0'),
('UEC-129', '0'),
('GHZ-724', '0'),
('GMH-300', '0'),
('XMV-471', '0'),
('GNW-680', '0'),
('ZNK-416', '0'),
('YEP-253', '0'),
('ZNG-327', '0'),
('ZJK-716', '0'),
('TIR-586', '0'),
('TBQ-160', '0'),
('PKQ-767', '0'),
('ZEJ--821', '0'),
('XRU-889', '0'),
('ZNT-269', '0'),
('NVO-264', '0'),
('XMV-417', '0'),
('GTS-813', '0'),
('ZJP-470', '0'),
('GTS-798', '0'),
('KEC-213', '0'),
('JCL-656', '0'),
('GEV-976', '0'),
('YRM-889', '0'),
('SHJ-237', '0'),
('KDN-181', '0'),
('ZKP--920', '0'),
('YAA-663', '0'),
('KDE-266', '0'),
('EOV-356', '0'),
('PQO-122', '0'),
('TQG-966', '0'),
('UIJ-175', '0'),
('PDQ-660', '0'),
('KDJ-589', '0'),
('TJK-332', '0'),
('TJV-569', '0'),
('TFO-924', '0'),
('XFU-516', '0'),
('PRJ-223', '0'),
('NGO-544', '0'),
('ZMF-287', '0'),
('KBX-946', '0'),
('WTM-699', '0'),
('UGN-811', '0'),
('YHR- 804', '0'),
('UAW-453', '0'),
('KCZ-897', '0'),
('GGC-849', '0'),
('KCD-749', '0'),
('YEY-812', '0'),
('KDD-568', '0'),
('UME-778', '0'),
('NVO-797', '0'),
('NOI-292', '0'),
('ZNE-322', '0'),
('ZLJ-949', '0'),
('ZRW-459', '0'),
('KCL-456', '0'),
('KCP-212', '0'),
('KEN-524', '0'),
('WMD--562', '0'),
('KDV-590', '0'),
('TKO-820', '0');

-- --------------------------------------------------------

--
-- Table structure for table `tmp_jo_details_cache`
--

CREATE TABLE IF NOT EXISTS `tmp_jo_details_cache` (
  `trace_id` int(11) NOT NULL AUTO_INCREMENT,
  `labor` int(11) NOT NULL DEFAULT '0',
  `partmaterial` varchar(255) DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT NULL,
  UNIQUE KEY `trace_id` (`trace_id`)
) ENGINE=MEMORY  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `tmp_jo_details_cache`
--

INSERT INTO `tmp_jo_details_cache` (`trace_id`, `labor`, `partmaterial`, `details`, `amnt`) VALUES
(1, 327, '', '', '800.00'),
(2, 328, '', '', '1500.00'),
(3, 329, '', '', '250.00'),
(4, 595, '', '', '1500.00'),
(5, 0, '1 PC. OIL SEAL 20X30X5', '', '240.00'),
(6, 0, '1PC. OIL SEAL 25X35X6', '', '190.00');

-- --------------------------------------------------------

--
-- Table structure for table `username`
--

CREATE TABLE IF NOT EXISTS `username` (
  `laborid` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(50) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `addr` mediumtext,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`laborid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(50) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `username` varchar(35) DEFAULT NULL,
  `pword` varchar(32) DEFAULT NULL,
  `addr` mediumtext,
  `status` enum('0','1') DEFAULT '1',
  `ut_id` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`u_id`),
  KEY `users_ibfk_1` (`ut_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`u_id`, `fname`, `mname`, `lname`, `username`, `pword`, `addr`, `status`, `ut_id`) VALUES
(11, 'Administrator', 'Administrator', 'Administrator', 'admin', '21232f297a57a5a743894a0e4a801fc3', 'Cag. de Oro', '1', 1),
(12, 'Nanettee', 'B', 'Pabalolot', 'nanettee', '45614288deebcc7c6b1b3db530c48a3a', 'Cag. de Oro', '1', 2);

-- --------------------------------------------------------

--
-- Table structure for table `usertype`
--

CREATE TABLE IF NOT EXISTS `usertype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `access` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `usertype`
--

INSERT INTO `usertype` (`id`, `type`, `access`) VALUES
(1, 'admin', 5),
(2, 'cashier', 1),
(3, 'super cashier', 3);

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE IF NOT EXISTS `vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `make` varchar(150) DEFAULT NULL,
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`v_id`),
  KEY `Index_2` (`make`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=208 ;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`v_id`, `make`, `status`) VALUES
(3, 'Toyota', '1'),
(28, ' Mitsubishi  ', '1'),
(34, 'Ford', '1'),
(33, 'Honda', '1'),
(35, 'NISSAN SENTRA 97', '1'),
(36, 'MULTICAB', '1'),
(37, 'HONDA CR-V', '1'),
(38, 'CHEVROLET SPARK', '1'),
(39, 'HONDA CIVIC ESI', '1'),
(40, 'TOYOTA REVO', '1'),
(41, 'TOYOTA REVO -2001', '1'),
(42, 'TOYOTA VIOS -2010', '1'),
(43, 'HONDA CITY', '1'),
(44, 'TOYOTA HI-ACE GRANDIA', '1'),
(45, 'HONDA CIVIC FD-10', '1'),
(46, 'HONDA CIVIC ''96', '1'),
(47, 'TOYOTA CAMRY 2000', '1'),
(48, 'CHARADE', '1'),
(49, 'ISUZU', '1'),
(50, 'MITSUBISHI ECLAPSE', '1'),
(51, 'HONDA CITY VTEC', '1'),
(52, 'TOYOTA VIOS', '1'),
(53, 'HONDA CIVIC VTI', '1'),
(54, 'MITSUBISHI L300', '1'),
(55, 'NISSAN URBAN ''09', '1'),
(56, 'MITSUBISHI STRADA', '1'),
(57, 'ISUZU HI-LANDER', '1'),
(58, 'MATIZ', '1'),
(59, 'TOYOTA INNOVA', '1'),
(61, 'KIA PICANTO', '1'),
(62, 'TAMARAW FX', '1'),
(63, 'HYUNDAI GETZ', '1'),
(64, 'ISUZU ELF', '1'),
(65, 'TOYOTA VIOS 2009', '1'),
(66, 'ISUZU FUEGO', '1'),
(67, 'HONDA HATCHBACK', '1'),
(68, 'TOYOTA HI-LUX ''95', '1'),
(69, 'HONDA ACCORD', '1'),
(70, 'MITSUBISHI STRADA 2004', '1'),
(71, 'FORD RANGER PICK-UP', '1'),
(72, 'ISUZU DMAX 2010', '1'),
(73, 'NO MAKE', '1'),
(74, 'TOYOTA VIOS L3J M/T 2008', '1'),
(75, 'WHITE YELLOW', '1'),
(76, 'HONDA CITY 2006', '1'),
(77, 'INNOVA 2006', '1'),
(78, 'HONDA CIVIC', '1'),
(79, 'MITSUBISHI L200', '1'),
(80, 'NISSAN FRONTIER ''07', '1'),
(81, 'TOYOTA VIOS ''06', '1'),
(82, 'SUZUKI', '1'),
(83, 'HONDA IMPORTER', '1'),
(84, 'MITSUBISHI LANCER ''93-95', '1'),
(85, 'TOYOTA TAMARAW FX', '1'),
(86, 'NISSAN SENTRA GA13', '1'),
(87, 'HYUNDAI GETZ1.1M/T', '1'),
(88, 'TOYOTA VIOS 2008', '1'),
(89, 'TOYOTA VIOS 1.3 2008', '1'),
(90, 'HONDA FIT', '1'),
(91, 'TOYOTA FORTUNER', '1'),
(92, 'TOYOTA VIOS 2007-2008', '1'),
(93, 'TOYOTA VIOS 1.3 2007', '1'),
(94, 'TOYOTA COROLLA', '1'),
(95, 'HYUNDAI STAREX ''02', '1'),
(96, 'MITSUBISHI ADVENTURE 2008', '1'),
(97, 'MITSUBISHI ADVENTURE', '1'),
(98, 'HONDA CIVIC ''2004', '1'),
(99, 'ISUZU DMAX 2011', '1'),
(100, 'DAIHATSU CHARADE ''92', '1'),
(101, 'HYUNDAI GETZ 2005', '1'),
(102, 'CIVIC ESI', '1'),
(103, 'NISSAN ', '1'),
(104, 'STRADA', '1'),
(105, 'HONDA CIVIC EK4', '1'),
(106, 'LANCER BOX TYPE ', '1'),
(107, 'MITSUBISHI PAJERO', '1'),
(108, 'ISUZU CROSSWIND', '1'),
(109, 'REVO ''01', '1'),
(110, 'KIA SPORTAGE ''07', '1'),
(111, 'CHECK NOISE SHOCK RR/RH', '1'),
(112, 'REPLACE HUB BEARING (MACHINE PRESS)', '1'),
(113, 'MACHINE PRESS VELOCITY PULL-OUT', '1'),
(114, 'HONDA CR-V 2003', '1'),
(115, 'MITSUBISHI GALANT 95-95', '1'),
(116, 'TOYOTA CORONA', '1'),
(117, 'ISIZU TROOPER', '1'),
(118, 'ISUZU TROOPER', '1'),
(119, 'TOYOTA HI-ACE', '1'),
(120, 'DAIHATSU CHARADE ''92', '1'),
(121, 'DAIHATSU CHARADE', '1'),
(122, 'TOYOTA VIOS SEDAN 2006', '1'),
(123, 'MULTICAB SUZUKI', '1'),
(124, 'KIA K2 400', '1'),
(125, 'LANCER', '1'),
(126, 'ISUZU DMAX', '1'),
(127, 'MITSUBISHI LANCER', '1'),
(128, 'MITSUBISHI GALANT', '1'),
(129, 'HYUNDAI GETZ ''07', '1'),
(130, 'MAZDA MIYATA', '1'),
(131, 'UNITED LABORATORIES INC.', '1'),
(132, 'NISSAN CEFIRO VQ-276', '1'),
(133, 'MITSUBISHI OUTLANDER', '1'),
(134, 'TOYOTA HI-LUX', '1'),
(135, 'VOUGSUAGEN', '1'),
(136, 'HYUNDAI ELANTRA', '1'),
(137, 'FORD RANGER 2009', '1'),
(138, 'MITSUBISHI GALANT ''97', '1'),
(139, 'MAZDA 3', '1'),
(140, 'KIA PICANTO', '1'),
(141, 'KIA PICANTO ''08', '1'),
(142, 'HI-LUX', '1'),
(143, 'SUBARU ''02', '1'),
(144, 'TOYOTA VIOS 1.3 2010', '1'),
(145, 'NISSAN CEFIRO', '1'),
(146, 'CHEVROLET LSI.5 AVIO', '1'),
(147, 'FORD RANGER', '1'),
(148, 'VIOS 1.3', '1'),
(149, 'HONDA CIVIC HATCHBACK', '1'),
(150, 'HONDA JAZZ', '1'),
(151, 'HYUNDAI STAREX', '1'),
(152, 'NISSAN SENTRA GA13', '1'),
(153, 'NISSAN SENTRA', '1'),
(154, 'KIA SORENTO', '1'),
(155, 'TOYOTA VIOS 1.3 J M/T 2012', '1'),
(156, 'NISSAN NAVARRA', '1'),
(157, 'MITSUBISHI CANTER ''08 6 WHEELERS', '1'),
(158, 'CIVIC ''93', '1'),
(159, 'SUZUKI CELERIO', '1'),
(160, 'CHEVROLLET AVIO', '1'),
(161, 'SUZUKI SAMURAI', '1'),
(162, 'DAEWOO MATIZ', '1'),
(163, 'TOYOTA VIOS 2012', '1'),
(164, 'HONDA CITY 1999', '1'),
(165, 'NISSAN FRONTIER', '1'),
(166, 'HONDA CIVIC VTEC', '1'),
(167, 'ISUZU PICK-UP', '1'),
(168, 'SUBARU', '1'),
(169, 'KIA PRIDE FORD', '1'),
(170, 'BLUE GREEN', '1'),
(171, 'EMERALD GREEN', '1'),
(172, 'NISSAN 4WD', '1'),
(173, 'KIA AVILA', '1'),
(174, 'CHEVROLET AVEO', '1'),
(175, 'HONDA CITY TYPE Z', '1'),
(176, 'TOYOTA GRANDIA', '1'),
(177, 'HONDA CIVIC SiR ''99', '1'),
(178, 'CHEVROLET', '1'),
(179, 'MITSUBISHI MONTERO', '1'),
(180, 'PICK-UP', '1'),
(181, 'OFFROAD', '1'),
(182, 'MITSUBISHI ELF', '1'),
(183, 'MITSUBISHI PICK-UP', '1'),
(184, 'KIA PRIDE', '1'),
(185, 'MITSUBISHI MIRAGE', '1'),
(186, 'MITSUBISHI CANTER', '1'),
(187, 'BMW', '1'),
(188, 'TOYOTA ACCORD', '1'),
(189, 'KIA SEPHIA', '1'),
(190, 'TOYOTA VIOS 2011', '1'),
(191, 'ORIENTAL & MOTOLITE MKTG. CORP.', '1'),
(192, 'HONDA CITY 2008 1.5V M', '1'),
(193, 'MAZDA PICK-UP', '1'),
(194, 'TOYOTA VIOS 2011 1.3 J M/T', '1'),
(195, 'MULTICARE PHARMACEUTICAL PHILS. INC', '1'),
(196, 'FORD EVEREST', '1'),
(197, 'HYUNDAI ACCENT', '1'),
(198, 'SUZUKI SWIFT', '1'),
(199, 'FORWARDER', '1'),
(200, 'TOYOTA AVANZA', '1'),
(201, 'PRELOAD', '1'),
(202, 'SUZUKI SWIFT 1.5 HATCHBACK', '1'),
(203, 'HONDA FSI', '1'),
(204, 'KIA VAN', '1'),
(205, 'ATOZ', '1'),
(206, 'SPORTAGE', '1'),
(207, 'ISUZU TFR', '1');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_owner`
--

CREATE TABLE IF NOT EXISTS `vehicle_owner` (
  `vo_id` int(11) NOT NULL AUTO_INCREMENT,
  `plateno` varchar(15) DEFAULT NULL,
  `color` int(11) NOT NULL DEFAULT '0',
  `make` int(11) NOT NULL DEFAULT '0',
  `description` varchar(255) DEFAULT NULL,
  `owner` int(11) NOT NULL DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`vo_id`),
  UNIQUE KEY `unq_plate_owner` (`plateno`,`owner`),
  UNIQUE KEY `unq_plate_only` (`plateno`),
  KEY `fgn_owner` (`owner`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=131 ;

--
-- Dumping data for table `vehicle_owner`
--

INSERT INTO `vehicle_owner` (`vo_id`, `plateno`, `color`, `make`, `description`, `owner`, `status`) VALUES
(1, 'MFN122', 31, 36, '', 4, '1'),
(2, 'KHU111', 31, 37, '', 3, '1'),
(3, 'MFB115', 31, 38, '', 7, '1'),
(4, 'UAR731', 22, 39, '', 5, '1'),
(5, 'NOPLATE', 32, 73, '', 8, '1'),
(6, 'KCT107', 10, 40, '', 9, '1'),
(7, 'KCK965', 22, 41, '', 19, '1'),
(8, 'PQM689', 1, 42, '', 317, '1'),
(9, 'KDE550', 22, 43, '', 399, '1'),
(10, 'KCU764', 10, 44, '', 104, '1'),
(11, 'KEL935', 31, 45, '', 15, '1'),
(12, 'KEJ416', 10, 46, '', 16, '1'),
(13, 'ZLJ949', 32, 89, '', 295, '1'),
(14, 'WNA461', 33, 47, '', 400, '1'),
(15, 'KCZ656', 33, 40, '', 401, '1'),
(16, 'KBP657', 1, 48, '', 20, '1'),
(17, 'GEN732', 22, 207, '', 21, '1'),
(18, 'KFU553', 25, 50, '', 402, '1'),
(19, 'ZKP920', 2, 51, '', 23, '1'),
(20, 'KDM249', 34, 52, '', 24, '1'),
(21, 'UKA563', 22, 53, '', 25, '1'),
(22, 'NOL541', 10, 52, '', 26, '1'),
(23, 'NQV326', 22, 54, '', 50, '1'),
(24, 'KVU924', 35, 54, '', 50, '1'),
(25, 'NOA844', 36, 55, '', 28, '1'),
(26, 'KCM313', 10, 56, '', 29, '1'),
(27, 'KCC437', 22, 57, '', 326, '1'),
(28, 'KGF430', 25, 58, '', 31, '1'),
(29, 'NQL699', 24, 59, '', 32, '1'),
(30, 'KCZ588', 3, 43, '', 143, '1'),
(31, 'TJD176', 2, 39, '', 34, '1'),
(32, 'KDE510', 22, 61, '', 133, '1'),
(33, 'UAH908', 37, 62, '', 36, '1'),
(34, 'POK765', 1, 63, '', 218, '1'),
(35, 'XHV831', 10, 37, '', 391, '0'),
(36, 'GPX640', 2, 64, '', 40, '1'),
(37, 'ZTR517', 10, 65, '', 41, '1'),
(38, 'KCS463', 3, 66, '', 104, '1'),
(39, 'JBS789', 2, 67, '', 43, '1'),
(40, 'OEV356', 22, 68, '', 44, '1'),
(41, 'KER975', 10, 43, '', 47, '1'),
(42, 'KDA668', 38, 56, '', 49, '1'),
(43, 'ZKP420', 10, 52, '', 82, '1'),
(44, 'XGJ146', 22, 40, '', 54, '1'),
(45, 'UKD396', 39, 69, '', 55, '1'),
(46, 'NKO676', 22, 71, '', 56, '1'),
(47, 'ZLT784', 10, 52, '', 58, '1'),
(48, 'KEL985', 31, 72, '', 404, '1'),
(49, 'AAA000', 22, 78, '', 48, '1'),
(50, 'XHV832', 10, 37, '', 39, '1'),
(51, 'ZKP921', 10, 76, '', 405, '1'),
(52, 'XJC760', 37, 37, '', 59, '1'),
(53, 'ZCG528', 40, 77, '', 60, '1'),
(54, 'YEZ620', 31, 78, '', 62, '1'),
(55, 'AAB001', 10, 79, '', 63, '1'),
(56, 'ZJW965', 10, 80, '', 64, '1'),
(57, 'ZGN690', 1, 81, '', 266, '1'),
(58, 'AAC002', 1, 28, '', 66, '1'),
(59, 'KEG189', 2, 83, '', 132, '1'),
(60, 'GTB254', 33, 84, '', 68, '1'),
(61, 'KBU537', 1, 85, '', 204, '1'),
(62, 'TPS526', 1, 86, '', 406, '1'),
(63, 'ZGP662', 32, 87, '', 71, '1'),
(64, 'PBO950', 10, 52, '', 73, '1'),
(65, 'KCH342', 22, 40, '', 74, '1'),
(66, 'ZTR740', 1, 88, '', 75, '1'),
(67, 'ZPE142', 10, 89, '', 76, '1'),
(68, 'KFY684', 22, 90, '', 141, '1'),
(69, 'KFN437', 10, 91, '', 78, '1'),
(70, 'ZTR990', 10, 42, '', 80, '1'),
(71, 'ZKP410', 41, 92, '', 81, '1'),
(72, 'ZRW466', 2, 88, '', 155, '1'),
(73, 'PMB177', 10, 94, '', 84, '1'),
(74, 'KGJ185', 31, 95, '', 85, '1'),
(75, 'KDP703', 10, 70, '', 86, '1'),
(76, 'AAC003', 31, 33, '', 87, '1'),
(77, 'KDU175', 22, 96, '', 19, '1'),
(78, 'ZYX222', 22, 91, '', 89, '1'),
(79, 'GHR257', 1, 69, '', 89, '1'),
(80, 'KCF884', 1, 78, '', 89, '1'),
(81, 'KCF648', 22, 66, '', 90, '1'),
(82, 'GJR238', 2, 43, '', 91, '1'),
(83, 'SHJ477', 22, 97, '', 34, '1'),
(84, 'XMR211', 2, 98, '', 92, '1'),
(85, 'THG207', 10, 116, '', 93, '1'),
(86, 'ZMH389', 36, 88, '', 94, '1'),
(87, 'KFZ679', 22, 99, '', 95, '1'),
(88, 'KDE850', 10, 43, '', 97, '1'),
(89, 'ZRM710', 41, 74, '', 98, '1'),
(90, 'TGD371', 10, 39, '', 99, '1'),
(91, 'NOE844', 36, 55, '', 100, '1'),
(92, 'URB361', 22, 78, '', 101, '1'),
(93, 'PKI588', 10, 52, '', 102, '1'),
(94, 'WHV610', 42, 78, '', 32, '1'),
(95, 'UBS806', 37, 79, '', 14, '1'),
(96, 'ZPU213', 1, 63, '', 105, '1'),
(97, 'PIX852', 10, 190, '', 106, '1'),
(98, 'RCA655', 2, 104, '', 107, '1'),
(99, 'KEZ926', 43, 105, '', 108, '1'),
(100, 'KBJ555', 45, 106, '', 109, '1'),
(101, 'XGS555', 43, 107, '', 110, '1'),
(102, 'GJY555', 31, 37, '', 40, '1'),
(103, 'YDF296', 22, 108, '', 40, '1'),
(104, 'AAD004', 2, 78, '', 112, '1'),
(105, 'WTG939', 36, 40, '', 113, '1'),
(106, 'AAE005', 36, 41, '', 114, '1'),
(107, 'KDP466', 10, 110, '', 115, '1'),
(108, 'TDS280', 1, 94, '', 117, '1'),
(109, 'GEV975', 10, 115, '', 119, '1'),
(110, 'GTJ483', 44, 118, '', 120, '1'),
(111, 'KDF860', 10, 97, '', 121, '1'),
(112, 'GGV946', 39, 78, '', 122, '1'),
(113, 'UTB141', 1, 78, '', 123, '1'),
(114, 'KDV819', 10, 119, '', 124, '1'),
(115, 'GHJ358', 31, 166, '', 125, '1'),
(116, 'PUD750', 22, 54, '', 50, '1'),
(117, 'XHX944', 3, 37, '', 128, '1'),
(118, 'GHH', 31, 53, '', 129, '1'),
(119, 'ZDK482', 10, 93, '', 130, '1'),
(120, 'MEZ141', 22, 36, '', 4, '1'),
(121, 'MBR615', 2, 124, '', 132, '1'),
(122, 'KCG656', 33, 40, '', 61, '1'),
(123, 'GDL522', 2, 125, '', 134, '1'),
(124, 'KGB589', 10, 126, '', 135, '1'),
(125, 'CSL577', 31, 127, '', 136, '1'),
(126, 'KEF875', 31, 43, '', 138, '1'),
(127, 'ZNG361', 32, 43, '', 139, '1'),
(128, 'XDX543', 24, 129, '', 140, '1'),
(129, 'KEY684', 22, 90, '', 141, '1'),
(130, 'YCJ718', 37, 130, '', 142, '1');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_receive`
--

CREATE TABLE IF NOT EXISTS `vehicle_receive` (
  `vr_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer` int(11) NOT NULL DEFAULT '0',
  `vehicle` int(11) NOT NULL DEFAULT '0',
  `recdate` date DEFAULT '0000-00-00',
  `status` enum('0','1') DEFAULT '1',
  `recby` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vr_id`),
  KEY `fgn_customer` (`customer`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=182 ;

--
-- Dumping data for table `vehicle_receive`
--

INSERT INTO `vehicle_receive` (`vr_id`, `customer`, `vehicle`, `recdate`, `status`, `recby`) VALUES
(1, 4, 1, '2013-01-04', '1', 12),
(2, 3, 2, '2013-01-02', '1', 12),
(3, 7, 3, '2013-01-04', '1', 12),
(4, 5, 4, '2013-01-03', '1', 12),
(5, 8, 5, '2013-01-03', '1', 12),
(6, 9, 6, '2012-12-19', '1', 12),
(7, 19, 7, '2013-01-03', '1', 12),
(8, 19, 7, '2013-01-03', '1', 12),
(9, 317, 8, '2013-01-05', '1', 12),
(10, 399, 9, '2013-01-05', '1', 12),
(11, 104, 10, '2013-01-04', '1', 12),
(12, 15, 11, '2012-12-12', '1', 12),
(13, 16, 12, '2013-01-05', '1', 12),
(14, 295, 13, '2013-01-05', '1', 12),
(15, 400, 14, '2012-12-28', '1', 12),
(16, 401, 15, '2013-01-07', '1', 12),
(17, 19, 7, '2013-01-03', '1', 12),
(18, 20, 16, '2013-01-07', '1', 12),
(19, 21, 17, '2013-01-07', '1', 12),
(20, 402, 18, '2012-12-03', '1', 12),
(21, 23, 19, '2013-01-03', '1', 12),
(22, 24, 20, '2013-01-12', '1', 12),
(23, 25, 21, '2013-01-07', '1', 12),
(24, 26, 22, '2013-01-07', '1', 12),
(25, 50, 23, '2013-01-08', '1', 12),
(26, 50, 24, '2012-12-17', '1', 12),
(27, 28, 25, '2013-01-02', '1', 12),
(28, 29, 26, '2013-01-02', '1', 12),
(29, 326, 27, '2013-01-11', '1', 12),
(30, 31, 28, '2013-01-05', '1', 12),
(31, 32, 29, '2013-01-15', '1', 12),
(32, 7, 3, '2013-01-11', '1', 12),
(33, 295, 13, '2013-01-16', '1', 12),
(34, 143, 30, '2013-01-14', '1', 12),
(35, 34, 31, '2013-01-10', '1', 12),
(36, 133, 32, '2013-01-09', '1', 12),
(37, 36, 33, '2013-01-14', '1', 12),
(38, 218, 34, '2013-01-19', '1', 12),
(39, 40, 36, '2013-01-16', '1', 12),
(40, 41, 37, '2012-12-06', '1', 12),
(41, 7, 3, '2013-01-21', '1', 12),
(42, 104, 38, '2012-11-26', '1', 12),
(43, 104, 38, '2013-01-17', '1', 12),
(44, 218, 34, '2013-01-21', '1', 12),
(45, 43, 39, '2013-01-17', '1', 12),
(46, 44, 40, '2013-01-05', '1', 12),
(47, 47, 41, '2013-02-11', '1', 12),
(48, 34, 31, '2013-01-28', '1', 12),
(49, 49, 42, '2013-01-28', '1', 12),
(50, 34, 31, '2013-01-28', '1', 12),
(51, 50, 24, '2013-01-21', '1', 12),
(52, 50, 23, '2013-01-22', '1', 12),
(53, 4, 1, '2013-01-25', '1', 12),
(54, 82, 43, '2013-01-26', '1', 12),
(55, 24, 20, '2013-01-26', '1', 12),
(56, 54, 44, '2012-11-28', '1', 12),
(57, 55, 45, '2013-01-28', '1', 12),
(58, 49, 42, '2013-01-11', '1', 12),
(59, 56, 46, '2012-06-23', '1', 12),
(60, 58, 47, '2013-01-30', '1', 12),
(61, 133, 32, '2013-01-19', '1', 12),
(62, 404, 48, '2012-12-11', '1', 12),
(63, 48, 49, '2013-01-24', '1', 12),
(64, 39, 50, '2013-01-02', '1', 12),
(65, 405, 51, '2013-01-15', '1', 12),
(66, 32, 29, '2013-01-31', '1', 12),
(67, 59, 52, '2013-01-29', '1', 12),
(68, 60, 53, '2013-01-28', '1', 12),
(69, 62, 54, '2013-02-02', '1', 12),
(70, 63, 55, '2013-02-04', '1', 12),
(71, 64, 56, '2013-02-04', '1', 12),
(72, 64, 56, '2012-11-29', '1', 12),
(73, 4, 1, '2013-02-02', '1', 12),
(74, 66, 58, '2013-02-05', '1', 12),
(75, 132, 59, '2013-01-30', '1', 12),
(76, 68, 60, '2013-01-28', '1', 12),
(77, 204, 61, '2013-02-06', '1', 12),
(78, 204, 61, '2013-02-05', '1', 12),
(79, 406, 62, '2013-01-09', '1', 12),
(80, 71, 63, '2013-01-26', '1', 12),
(81, 71, 63, '2013-01-26', '1', 12),
(82, 24, 20, '2013-02-07', '1', 12),
(83, 73, 64, '2013-01-31', '1', 12),
(84, 74, 65, '2013-02-07', '1', 12),
(85, 75, 66, '2013-02-02', '1', 12),
(86, 76, 67, '2013-01-03', '1', 12),
(87, 76, 67, '2013-01-03', '1', 12),
(88, 141, 68, '2013-02-08', '1', 12),
(89, 78, 69, '2013-02-08', '1', 12),
(90, 26, 22, '2013-01-30', '1', 12),
(91, 80, 70, '2013-01-07', '1', 12),
(92, 81, 71, '2013-01-21', '1', 12),
(93, 82, 43, '2013-01-23', '1', 12),
(94, 155, 72, '2013-01-24', '1', 12),
(95, 84, 73, '2013-02-06', '1', 12),
(96, 85, 74, '2013-02-09', '1', 12),
(97, 86, 75, '2013-01-28', '1', 12),
(98, 87, 76, '2013-02-11', '1', 12),
(99, 19, 77, '2013-02-11', '1', 12),
(100, 89, 78, '2013-01-22', '1', 12),
(101, 89, 79, '2013-01-16', '1', 12),
(102, 89, 80, '2013-01-07', '1', 12),
(103, 90, 81, '2013-01-29', '1', 12),
(104, 91, 82, '2013-01-25', '1', 12),
(105, 34, 83, '2013-02-11', '1', 12),
(106, 92, 84, '2013-02-11', '1', 12),
(107, 93, 85, '2013-02-13', '1', 12),
(108, 94, 86, '2012-12-12', '1', 12),
(109, 95, 87, '2013-01-04', '1', 12),
(110, 91, 82, '2013-02-12', '1', 12),
(111, 84, 73, '2013-02-13', '1', 12),
(112, 20, 16, '2013-02-12', '1', 12),
(113, 54, 44, '2013-02-12', '1', 12),
(114, 97, 88, '2013-02-15', '1', 12),
(115, 71, 63, '2013-01-31', '1', 12),
(116, 98, 89, '2013-02-07', '1', 12),
(117, 55, 45, '2013-02-12', '1', 12),
(118, 60, 53, '2013-02-15', '1', 12),
(119, 99, 90, '2010-07-05', '1', 12),
(120, 100, 91, '2013-02-01', '1', 12),
(121, 101, 92, '2013-02-14', '1', 12),
(122, 102, 93, '2013-02-01', '1', 12),
(123, 32, 94, '2013-02-19', '1', 12),
(124, 14, 95, '2013-01-24', '1', 12),
(125, 105, 96, '2013-02-02', '1', 12),
(126, 106, 97, '2013-02-16', '1', 12),
(127, 107, 98, '2012-12-14', '1', 12),
(128, 108, 99, '2013-04-03', '1', 12),
(129, 108, 99, '2012-11-28', '1', 12),
(130, 109, 100, '2012-07-16', '1', 12),
(131, 110, 101, '2013-02-20', '1', 12),
(132, 40, 102, '2013-02-02', '1', 12),
(133, 40, 103, '2013-02-12', '1', 12),
(134, 112, 104, '2013-02-20', '1', 12),
(135, 113, 105, '2013-01-28', '1', 12),
(136, 114, 106, '2012-12-17', '1', 12),
(137, 115, 107, '2013-01-30', '1', 12),
(138, 59, 52, '2013-02-15', '1', 12),
(139, 117, 108, '2013-02-20', '1', 12),
(140, 93, 85, '2013-02-16', '1', 12),
(141, 119, 109, '2013-02-04', '1', 12),
(142, 93, 85, '2013-02-23', '1', 12),
(143, 120, 110, '2013-02-23', '1', 12),
(144, 121, 111, '2013-02-23', '1', 12),
(145, 122, 112, '2013-02-23', '1', 12),
(146, 123, 113, '2013-02-23', '1', 12),
(147, 124, 114, '2013-02-23', '1', 12),
(148, 92, 84, '2013-02-25', '1', 12),
(149, 125, 115, '2013-01-05', '1', 12),
(150, 125, 115, '2013-01-05', '1', 12),
(151, 94, 86, '2013-02-13', '1', 12),
(152, 50, 116, '2013-02-21', '1', 12),
(153, 50, 24, '2013-02-22', '1', 12),
(154, 98, 89, '2013-02-27', '1', 12),
(155, 20, 16, '2013-02-22', '1', 12),
(156, 128, 117, '2013-02-23', '1', 12),
(157, 129, 118, '2013-02-27', '1', 12),
(158, 130, 119, '2012-06-20', '1', 12),
(159, 105, 96, '2012-10-27', '1', 12),
(160, 105, 96, '2013-01-05', '1', 12),
(161, 105, 96, '2013-02-02', '1', 12),
(162, 24, 20, '2013-02-21', '1', 12),
(163, 4, 120, '2013-01-04', '1', 12),
(164, 4, 1, '2013-02-20', '1', 12),
(165, 108, 99, '2013-02-22', '1', 12),
(166, 132, 121, '2013-01-21', '1', 12),
(167, 266, 57, '2013-01-15', '1', 12),
(168, 61, 122, '2013-02-02', '1', 12),
(169, 133, 32, '2013-02-15', '1', 12),
(170, 34, 31, '2013-03-01', '1', 12),
(171, 134, 123, '2012-12-28', '1', 12),
(172, 134, 123, '2012-12-28', '1', 12),
(173, 135, 124, '2013-03-01', '1', 12),
(174, 136, 125, '2013-03-02', '1', 12),
(175, 119, 109, '2013-02-25', '1', 12),
(176, 138, 126, '2013-03-04', '1', 12),
(177, 94, 86, '2013-03-05', '1', 12),
(178, 139, 127, '2013-03-05', '1', 12),
(179, 140, 128, '2013-02-27', '1', 12),
(180, 141, 129, '2013-03-06', '1', 12),
(181, 142, 130, '2013-02-04', '1', 12);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `dcrdetails`
--
ALTER TABLE `dcrdetails`
  ADD CONSTRAINT `FK_dcrdetails_1` FOREIGN KEY (`dcr_id`) REFERENCES `dcr` (`dcr_id`);

--
-- Constraints for table `jodetails`
--
ALTER TABLE `jodetails`
  ADD CONSTRAINT `jodetails_ibfk_1` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`),
  ADD CONSTRAINT `jodetails_ibfk_2` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`ut_id`) REFERENCES `usertype` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `vehicle_owner`
--
ALTER TABLE `vehicle_owner`
  ADD CONSTRAINT `vehicle_owner_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `customer` (`custid`);

--
-- Constraints for table `vehicle_receive`
--
ALTER TABLE `vehicle_receive`
  ADD CONSTRAINT `vehicle_receive_ibfk_1` FOREIGN KEY (`customer`) REFERENCES `customer` (`custid`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
