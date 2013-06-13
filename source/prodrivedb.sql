-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 12, 2013 at 09:16 AM
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
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1; /* raised an exception */
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2; /* encountered a warning */

  /* sets the default value */
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



    /* inserts new recond into joborder table*/

    INSERT INTO joborder (jo_number, v_id, customer, plate, tax, discount, trnxdate)

      VALUE(p_jo_number, p_v_id, p_customer, p_plate, p_tax, p_discount, p_trnxdate);



      /* retrieves the last inserted id */

      SET p_last_id =  LAST_INSERT_ID();



      /* master details */

      BEGIN

        DECLARE EOF INT DEFAULT 0;

        DECLARE l_labor INT DEFAULT 0;

        DECLARE l_partmaterial VARCHAR(255) DEFAULT '';

        DECLARE l_details VARCHAR(255) DEFAULT '';

        DECLARE l_amnt DECIMAL(8,2);

        DECLARE curjocache CURSOR FOR SELECT labor, partmaterial, details, amnt FROM tmp_jo_details_cache;



        DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = 1;



        /* opens cursor */

        OPEN curjocache;



        main_loop:LOOP

          /* fetches each row */

          FETCH curjocache INTO l_labor, l_partmaterial, l_details, l_amnt;



          /* checks EOF */

          IF EOF = 1 THEN

            LEAVE main_loop;

          END IF;



          /* inserts into job order details table */

          INSERT INTO jodetails SET jo_id = p_last_id, labor = l_labor, partmaterial = l_partmaterial, details = l_details, amnt = l_amnt, `status` = '1';



        END LOOP main_loop;



        #/* closes cursor */

        CLOSE curjocache;



      END;





      /* clears tmp_jo_details_cache temporary table */

      DELETE FROM tmp_jo_details_cache;

  COMMIT;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_jo_cache`()
BEGIN

  DROP /*TEMPORARY*/ TABLE IF EXISTS `tmp_jo_details_cache`;

  CREATE /* TEMPORARY */ TABLE `tmp_jo_details_cache`(

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


  /* opens cursor */
  OPEN curDCR;

  main_loop:LOOP
    /* fetches each row */
    FETCH curDCR INTO l_trnxdate, l_cashier, l_status, l_particulars, l_refno, l_amnt, l_tender;

    /* is end of record */
    IF l_EOF = 1 THEN
      LEAVE main_loop;
    END IF;

    /* inserts each record into temporary table */
    IF fnc_isJoFullyPaid(l_refno) = 1 THEN
        INSERT INTO `tmp_daily_collection` (trnxdate,cashier,`status`, refno, amnt, tender, particulars, paid)
          VALUES(l_trnxdate,l_cashier,l_status,l_refno,l_amnt,l_tender, l_particulars, 1);
    ELSE
        INSERT INTO `tmp_daily_collection` (trnxdate,cashier,`status`, refno, amnt, tender, particulars, paid)
          VALUES(l_trnxdate,l_cashier,l_status,l_refno,l_amnt,l_tender, l_particulars, 0);
    END IF;

  END LOOP main_loop;

  /* closes cursor */
  CLOSE curDCR;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteDcrDetail`(IN p_dcrdtl_id INT, OUT p_status TINYINT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION SET p_status = -1;
  DECLARE EXIT HANDLER FOR SQLWARNING SET p_status = -2;

  /* sets default value for the p_status */
  SET p_status = 0;

  DELETE FROM dcrdetails WHERE dcrdtl_id = p_dcrdtl_id;

  SET p_status = 1;

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

  /* sets default status code for the p_status*/
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
/*
 * Updates master-detail table
 * @author    Mugs and Coffee
 * @coder    Kenneth "digiArtist_ph" Vallejos
 * @since    Thursday, June 6, 2013
 * @version  1.0
 *
*/

  DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
  DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

  START TRANSACTION;

    -- set default value for p_status
    SET  p_status = 0;

    -- updates the master table
    UPDATE joborder SET jo_number = p_jo_number,
                        v_id = p_v_id,
                        customer = p_customer,
                        plate = p_plate,
                        trnxdate = p_trnxdate,
                        tax = p_tax,
                        discount = p_discount
                    WHERE jo_id = p_jo_id;

    -- calls*/ /*!50003 function that processes the master-detail table
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

  /* sets default status */
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
/*
 * Processes the dependent table in a master-detail scenario
 * @author    Mugs and Coffee
 * @coder    Kenneth "digiArtist_ph" Vallejos
 * @since    Thursday, June 6, 2013
 * @version  1.0
 *
*/
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

  -- deletes the current jo order details
  DELETE FROM jodetails WHERE jo_id = p_jo_id;

  -- opens the cursor
  OPEN cur_tmpjotbldtls;

  main_loop:LOOP

    -- fetches each record from the cursor
    FETCH cur_tmpjotbldtls INTO l_labor, l_partmaterial, l_details, l_amnt;

    IF l_EOF = 1 THEN
      LEAVE main_loop;
    END IF;

    -- inserts into jodetails
    INSERT INTO jodetails SET jo_id = p_jo_id,
                              labor = l_labor,
                              partmaterial = l_partmaterial,
                              details = l_details,
                              amnt = l_amnt,
                              `status` = '1';

  END LOOP main_loop;

  -- closes the cursor
  CLOSE cur_tmpjotbldtls;

  -- deletes the tmp_jo_details_cache temporary table
  DELETE FROM tmp_jo_details_cache;

  -- sets the staturs error to (0), indicating no error occured
  SET l_status_ERROR = 0;

  RETURN l_status_ERROR;

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=40 ;

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
(39, 'BEIGE');

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

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
  PRIMARY KEY (`custid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=93 ;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`custid`, `fname`, `mname`, `lname`, `addr`, `phone`, `status`, `company`) VALUES
(28, 'LEONARDO', '', 'KHU', '', '09177170759', '1', 0),
(27, 'MARK', '', 'ILOGON', '', '09177170759', '1', 0),
(26, 'ARNEL', '', 'SANCHEZ', 'CAGAYAN', '+63', '1', 0),
(25, 'Mike', 'M', 'Padero', 'Cag. de Oro', '09177170108', '1', 0),
(29, 'GERRY', '', 'GALVEZ', '', '09177170759', '1', 0),
(30, 'ROMY', '', 'JUMALON', '', '09177170759', '1', 0),
(31, 'PEGGY ANN', '', 'SEBASTIAN', '', '09177170759', '1', 0),
(32, 'PATRICK', '', 'ABSIN', '', '09', '1', 0),
(33, ' ABSIN ', '  ', 'PATRICK ', 'CAGAYAN', '088 ', '1', 0),
(36, 'BERDIDA', 'B.', 'ARVY', '', '088', '1', 0),
(37, 'ODYSSEY DRIVING SCHOOL', 'L', 'L', '', '088', '1', 0),
(38, 'PHIL. ARMY', 'A', 'A', 'A', '088', '1', 0),
(40, 'BENG', '', 'PELAEZ', 'CAGAYAN', '09178636969', '1', 0),
(41, 'SAPIO', '', 'NECO', '', '09174111022', '1', 0),
(42, 'MIKHAEL/LRI THERAPHARMA', 'L.', 'BAUTISTA', 'METRO MANILA', '088', '1', 0),
(43, 'RIZAL', 'M', 'M', '', '088', '1', 0),
(44, 'PATRICK BRYAN', 'E.', 'ABSIN', 'CAGAYAN', '088', '1', 0),
(45, 'MIKE', 'B', 'IGNACIO', '', '088', '1', 0),
(46, 'FR.JULIUS', '', 'CLAVERO', '', '088', '1', 0),
(47, 'SGT. BANSE', '', 'M', '', '088', '1', 0),
(48, 'PROEL', '', 'MOFAN', '', '088', '1', 0),
(49, 'JOHN RAY', '', 'BADAJOS', '', '088', '1', 0),
(50, 'DARWIN', '', 'ANDRES', '', '09298714483', '1', 0),
(51, 'MIKE', '', 'CARONAN', '', '088', '1', 0),
(52, 'AP-CARGO', 'N', 'LOGISTIC NETWORK', '', '088', '1', 0),
(53, 'AP-CARGO', '', 'LOGISTIC NETWORK', '', '088', '1', 0),
(54, 'JINKY', '', 'BAYLON', '', '088', '1', 0),
(55, 'LOLOY', '', 'PABILONA', '', '09223046777', '1', 0),
(56, 'FR. JOBEL', '', 'K', '', '088', '1', 0),
(57, 'RICCA MARIE', 'CATHY', 'LUGOD', '', '088', '1', 0),
(58, 'MARK', '', 'ABDULLAH', '', '088', '1', 0),
(59, 'GERRY', '', 'GALVEZ', '', '088', '1', 0),
(60, 'MIKHAEL/LRI THERAPHARMA', '', 'BAUTISTA', '', '088', '1', 0),
(61, 'GEORGE', 'ROCKIKI', 'CLAUDIOS', '', '09228705408', '1', 0),
(62, 'ROGER', '', 'ALBACETE', '', '088', '1', 0),
(63, 'PAULO', '', 'SIAC', '', '09177063972', '1', 0),
(64, 'ELLEN', '', 'ROA', '', '088', '1', 0),
(65, 'LABUNTONG', '', 'AL', '', '088', '1', 0),
(68, 'BOJIE', '', 'NO ', '', '088', '1', 0),
(69, 'MAAM JING', '', 'JING', '', '088', '1', 0),
(70, 'PATRICK', '', 'TSENG', '', '088', '1', 0),
(71, 'ERVIN JOHN', 'WESTMONT PHARMA.', 'DANDOY', '', '088', '1', 0),
(72, 'GERRY', '', 'GALVEZ', '', '088', '1', 0),
(73, 'PHIL. ARMY', '', 'A', '', '088', '1', 0),
(74, 'AL GAUVIN', 'ILOGON/FLEET DEPARTMENT', 'LABUNTONG', '', '088', '1', 0),
(75, 'MICHAEL', '', 'VALENZUELA', '', '09178752232', '1', 0),
(76, 'MCDI', '', 'MCDI', '', '088', '1', 0),
(77, 'POEL ', 'CASIMIRO', 'MOFAR/ZUELLIG PHARMA', '', '088', '1', 0),
(78, 'PROEL', '', 'MOFAR', '', '088', '1', 0),
(79, 'TITUS', '', 'VELEZ', '', '09275998185', '1', 0),
(80, 'JOESONS', '', 'JOE', '', '088', '1', 0),
(81, 'ROGER', '', 'ALBACETE', '', '088', '1', 0),
(82, 'BENJAMIN', '', 'DELOS SANTOS', '', '088', '1', 0),
(83, 'AP-CARGO', '', 'AP', '', '088', '1', 0),
(84, 'AP-CARGO', '', 'AP', '', '088', '1', 0),
(85, 'ILOGON', '', 'MARK', '', '088', '1', 0),
(86, 'RALPH', '', 'QUIJANO', '', '088', '1', 0),
(87, 'BADAJOS', '', 'BADS', '', '088', '1', 0),
(88, 'JOSHUA', '', 'HOLCIM', '', '088', '1', 0),
(89, 'JR', '', 'NERI', '', '088', '1', 0),
(90, 'BENJAMIN', 'FEDERAL PHOENIX ASSURANCE', 'DELOS SANTOS', '', '088', '1', 0),
(91, 'SIMOUN AMEL', '', 'BAUTISTA', '', '088', '1', 0),
(92, 'GABRIEL', '', 'UMEREZ', '', '088', '1', 0);

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `dcr`
--

INSERT INTO `dcr` (`dcr_id`, `trnxdate`, `begbal`, `cashier`, `status`) VALUES
(1, '2013-06-09', '0.00', 12, '1');

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
  PRIMARY KEY (`jo_id`),
  UNIQUE KEY `indxJO` (`jo_number`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity' AUTO_INCREMENT=71 ;

--
-- Dumping data for table `joborder`
--

INSERT INTO `joborder` (`jo_id`, `jo_number`, `v_id`, `customer`, `plate`, `color`, `contactnumber`, `address`, `trnxdate`, `tax`, `discount`, `status`) VALUES
(6, '000006', 7, 27, ' MFN 122 -- MULTICAB', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(7, '000007', 8, 28, ' KHU-111 -- HONDA CR-V', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(8, '000008', 9, 29, ' MFB-115 -- CHEVROLET SPARK', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(9, '000009', 10, 26, ' UAR-731 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(10, '000010', 11, 30, ' 0000 -- NO MAKE', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1'),
(11, '000011', 12, 31, ' KCT-107 -- TOYOTA REVO', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1'),
(12, '000012', 12, 31, ' KCT-107 -- TOYOTA REVO', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1'),
(13, '000013', 13, 32, ' KCK-965 -- TOYOTA REVO -2001', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(14, '000014', 13, 32, ' KCK-965 -- TOYOTA REVO -2001', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(15, '000015', 14, 36, ' PQM-689 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-01-04', '0.00', '0.00', '1'),
(16, '000016', 15, 37, ' KDE-550 -- HONDA CITY', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1'),
(17, '000017', 16, 38, ' KCU-764 -- TOYOTA HI-ACE GRANDIA', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1'),
(18, '000018', 16, 38, ' KCU-764 -- TOYOTA HI-ACE GRANDIA', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1'),
(19, '000019', 17, 40, ' KEL-935 -- HONDA CIVIC FD-10', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1'),
(20, '000020', 18, 41, ' KEJ-416 -- HONDA CIVIC ''96', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1'),
(21, '000021', 19, 42, ' ZLJ-948 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-01-05', '0.00', '0.00', '1'),
(22, '000022', 20, 43, ' KCZ656 -- TOYOTA REVO', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1'),
(23, '000023', 21, 44, ' KCK-965 -- TOYOTA REVO -2001', 0, NULL, NULL, '2013-01-03', '0.00', '0.00', '1'),
(24, '000024', 22, 45, ' KBP-657 -- CHARADE', 0, NULL, NULL, '2013-01-07', '0.00', '0.00', '1'),
(25, '000025', 23, 46, ' GEN-732 -- ISUZU', 0, NULL, NULL, '2013-01-10', '0.00', '0.00', '1'),
(26, '000026', 24, 47, ' KFU-553 -- MITSUBISHI ECLAPSE', 0, NULL, NULL, '2013-01-11', '0.00', '0.00', '1'),
(27, '000027', 25, 48, ' ZKP-920 -- HONDA CITY VTEC', 0, NULL, NULL, '2013-01-11', '0.00', '0.00', '1'),
(28, '000028', 26, 49, ' KDM-249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-12', '0.00', '0.00', '1'),
(29, '000029', 27, 50, ' UKA-563 -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-01-12', '0.00', '0.00', '1'),
(30, '000030', 28, 51, ' NOL-541 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-12', '0.00', '0.00', '1'),
(31, '000031', 29, 52, ' NQV-326 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-09', '0.00', '0.00', '1'),
(32, '000032', 30, 52, ' KVU-924 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-09', '0.00', '0.00', '1'),
(33, '000033', 31, 54, ' NOA-844 -- NISSAN URBAN ''09', 0, NULL, NULL, '2013-01-14', '0.00', '0.00', '1'),
(34, '000034', 31, 54, ' NOA-844 -- NISSAN URBAN ''09', 0, NULL, NULL, '2013-01-14', '0.00', '0.00', '1'),
(35, '000035', 32, 55, ' KCM-313 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-01-14', '0.00', '0.00', '1'),
(36, '000036', 33, 56, ' KCC-437 -- ISUZU HI-LANDER', 0, NULL, NULL, '2013-01-14', '0.00', '0.00', '1'),
(37, '000037', 34, 57, ' KGF-430 -- MATIZ', 0, NULL, NULL, '2013-01-15', '0.00', '0.00', '1'),
(38, '000038', 35, 58, ' NQL-699 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-01-15', '0.00', '0.00', '1'),
(39, '000039', 9, 29, ' MFB-115 -- CHEVROLET SPARK', 0, NULL, NULL, '2013-01-16', '0.00', '0.00', '1'),
(40, '000040', 19, 42, ' ZLJ-948 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-01-16', '0.00', '0.00', '1'),
(41, '000041', 38, 61, ' KCZ-580 -- HONDA CITY', 0, NULL, NULL, '2013-01-17', '0.00', '0.00', '1'),
(42, '000042', 39, 62, ' TJD-176 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-18', '0.00', '0.00', '1'),
(43, '000043', 40, 63, ' KDE-510 -- KIA PICANTO', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1'),
(44, '000044', 41, 64, ' UAH-908 -- TAMARAW FX', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1'),
(45, '000045', 42, 65, ' POK-765 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1'),
(46, '000046', 43, 68, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1'),
(47, '000047', 44, 69, ' XHV-831 -- HONDA CR-V', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1'),
(48, '000048', 45, 70, ' GPX-640 -- ISUZU ELF', 0, NULL, NULL, '2013-01-19', '0.00', '0.00', '1'),
(49, '000049', 46, 71, ' ZTR-517 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-01-16', '0.00', '0.00', '1'),
(50, '000050', 9, 29, ' MFB-115 -- CHEVROLET SPARK', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1'),
(51, '000051', 48, 73, ' KCS-463 -- ISUZU FUEGO', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1'),
(52, '000052', 42, 65, ' POK-765 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-01-21', '0.00', '0.00', '1'),
(53, '000053', 50, 75, ' JBS-789 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-01-22', '0.00', '0.00', '1'),
(54, '000054', 51, 76, ' OEV-356 -- TOYOTA HI-LUX ''95', 0, NULL, NULL, '2013-01-22', '0.00', '0.00', '1'),
(55, '000055', 52, 77, ' ZKP -- HONDA CITY 2006', 0, NULL, NULL, '2013-01-23', '0.00', '0.00', '1'),
(56, '000056', 25, 48, ' ZKP-920 -- HONDA CITY VTEC', 0, NULL, NULL, '2013-01-15', '0.00', '0.00', '1'),
(57, '000057', 54, 79, ' KER 975 -- HONDA CITY', 0, NULL, NULL, '2013-01-24', '0.00', '0.00', '1'),
(58, '000058', 55, 80, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-01-24', '0.00', '0.00', '1'),
(59, '000059', 39, 62, ' TJD-176 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1'),
(60, '000060', 57, 82, ' KDA-668 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1'),
(61, '000061', 58, 83, ' NQV-326 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1'),
(62, '000062', 59, 83, ' NOK-251 -- MITSUBISHI L300', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1'),
(63, '000063', 7, 27, ' MFN 122 -- MULTICAB', 0, NULL, NULL, '2013-01-28', '0.00', '0.00', '1'),
(64, '000064', 61, 86, ' NO PLATE -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-26', '0.00', '0.00', '1'),
(65, '000065', 62, 87, ' KDM-249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-26', '0.00', '0.00', '1'),
(66, '000066', 63, 88, ' XGJ-146 -- TOYOTA REVO', 0, NULL, NULL, '2013-01-26', '0.00', '0.00', '1'),
(67, '000067', 64, 89, ' UKD-396 -- HONDA ACCORD', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1'),
(68, '000068', 65, 82, ' KDA-668 -- MITSUBISHI STRADA 2004', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1'),
(69, '000069', 66, 91, ' NKO-676 -- FORD RANGER PICK-UP', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1'),
(70, '000070', 67, 92, ' KEL-935 -- ISUZU DMAX 2010', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1');

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
(6, 0, '1 SET BRAKE MASTER KIT', '', '325.00', '1'),
(6, 0, 'BRAKE FLUID', '', '100.00', '1'),
(6, 0, 'BRAKE FLUID', '', '100.00', '1'),
(6, 33, '', '', '450.00', '1'),
(7, 0, '1 PC. OIL FILTER', '', '290.00', '1'),
(7, 0, '4 L SYNTHETIC', '', '3200.00', '1'),
(7, 0, '1 PC. HOOD CABLE', '', '980.00', '1'),
(7, 7, '', '', '150.00', '1'),
(7, 30, '', '', '350.00', '1'),
(8, 31, '', '', '450.00', '1'),
(8, 0, '4 PCS. SCREW', '', '10.00', '1'),
(9, 24, '', '', '550.00', '1'),
(10, 34, '', '', '200.00', '1'),
(11, 35, '', '', '550.00', '1'),
(12, 35, '', '', '550.00', '1'),
(12, 36, '', '', '100.00', '1'),
(12, 7, '', '', '150.00', '1'),
(12, 0, '1 PC. OIL FILTER', '', '300.00', '1'),
(12, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(13, 37, '', '', '9268.40', '1'),
(14, 38, '', '', '450.00', '1'),
(14, 39, '', '', '50.00', '1'),
(14, 0, 'VOLTAGE REG.NEW ERA', '', '755.00', '1'),
(15, 40, '', '', '1800.00', '1'),
(16, 41, '', '', '250.00', '1'),
(16, 0, '1 PC. HORN', '', '500.00', '1'),
(17, 43, '', '', '350.00', '1'),
(17, 44, '', '', '250.00', '1'),
(17, 45, '', '', '150.00', '1'),
(17, 0, '2 PCS. STABILIZER LINK', '', '1700.00', '1'),
(18, 43, '', '', '350.00', '1'),
(18, 44, '', '', '250.00', '1'),
(18, 45, '', '', '150.00', '1'),
(18, 0, '2PCS. STABILIZER LINK', '', '1700.00', '1'),
(19, 47, '', '', '22000.00', '1'),
(19, 48, '', '', '550.00', '1'),
(19, 0, '1 SET FOG LAMP', '', '4200.00', '1'),
(20, 7, '', '', '150.00', '1'),
(20, 49, '', '', '250.00', '1'),
(20, 0, '1GAL. ENGINE OIL/MATCH 5', '', '950.00', '1'),
(20, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(20, 0, '1PC. AIR FILTER', '', '325.00', '1'),
(20, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(21, 55, '', '', '2200.00', '1'),
(21, 56, '', '', '3400.00', '1'),
(21, 57, '', '', '2300.00', '1'),
(21, 58, '', '', '1200.00', '1'),
(21, 59, '', '', '2500.00', '1'),
(21, 53, '', '', '5470.00', '1'),
(21, 54, '', '', '2000.00', '1'),
(21, 52, '', '', '3640.00', '1'),
(22, 60, '', '', '450.00', '1'),
(22, 61, '', '', '250.00', '1'),
(22, 0, '1PC. RUBBER HANGER', '', '120.00', '1'),
(23, 62, '', '', '20000.00', '1'),
(24, 63, '', '', '150.00', '1'),
(24, 64, '', '', '150.00', '1'),
(24, 65, '', '', '150.00', '1'),
(24, 0, '1 PC. DOOR HANDLE LH', '', '650.00', '1'),
(24, 0, '16 FT. DOUBLE ADHESIVE', '', '480.00', '1'),
(25, 66, '', '', '350.00', '1'),
(25, 0, '1PC. BOLT 14X25X20', '', '30.00', '1'),
(25, 0, '1PC. MIGHTY BOND', '', '130.00', '1'),
(26, 68, '', '', '1500.00', '1'),
(26, 69, '', '', '800.00', '1'),
(26, 70, '', '', '50.00', '1'),
(26, 71, '', '', '150.00', '1'),
(26, 72, '', '', '100.00', '1'),
(26, 73, '', '', '800.00', '1'),
(26, 0, '5HRS. ATP', '', '1300.00', '1'),
(26, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(26, 0, '1PC. OIL FILTER-TRANSMISSION', '', '290.00', '1'),
(26, 0, '1PC OIL FILTER-ENGINE', '', '260.00', '1'),
(26, 0, '1PC. BRAKE LIGHT SWITCH', '', '160.00', '1'),
(26, 0, '1SET POWER LOCK ALARM', '', '1500.00', '1'),
(26, 0, '1 PC. THIRD BRAKE LIGHT BULB', '', '30.00', '1'),
(27, 74, '', '', '300.00', '1'),
(27, 75, '', '', '300.00', '1'),
(28, 77, '', '', '350.00', '1'),
(28, 78, '', '', '450.00', '1'),
(28, 79, '', '', '400.00', '1'),
(28, 0, '1PC. LOWER ARM BUSHING(SMALL)', '', '200.00', '1'),
(28, 0, '1PC. LOWER ARM BUSHING (BIG)', '', '325.00', '1'),
(29, 80, '', '', '2000.00', '1'),
(29, 81, '', '', '2500.00', '1'),
(29, 82, '', '', '500.00', '1'),
(29, 0, '1PC. 200 ACTUATOR', '', '200.00', '1'),
(29, 0, '3PCS. BUMPER LOCKS @65', '', '195.00', '1'),
(30, 83, '', '', '500.00', '1'),
(30, 84, '', '', '500.00', '1'),
(30, 0, '1PC. FUEL PUMP', '', '3600.00', '1'),
(30, 0, '1PC. FUEL FILTER', '', '1000.00', '1'),
(31, 49, '', '', '250.00', '1'),
(32, 85, '', '', '350.00', '1'),
(32, 86, '', '', '550.00', '1'),
(32, 0, '1PC. BRAKE MASTER ASSY', '', '3000.00', '1'),
(32, 0, 'BRAKE FLUID', '', '160.00', '1'),
(33, 88, NULL, '', '7700.00', '1'),
(33, 72, '', '', '150.00', '1'),
(33, 0, '1PC. BACK GLASS', '', '6800.00', '1'),
(33, 0, '2LTRS. GEAR OIL', '', '460.00', '1'),
(34, 89, '', '', '500.00', '1'),
(34, 88, '', '', '7700.00', '1'),
(34, 72, '', '', '150.00', '1'),
(34, 0, '1PC. BACK GLASS', '', '6800.00', '1'),
(34, 0, '2LTRS. GEAR OIL', '', '460.00', '1'),
(35, 90, '', '', '9500.00', '1'),
(36, 91, '', '', '350.00', '1'),
(36, 0, '1PC. POWER STEERING HOSE', '', '1000.00', '1'),
(36, 0, 'ATP', '', '250.00', '1'),
(37, 92, '', '', '150.00', '1'),
(37, 93, '', '', '50.00', '1'),
(37, 94, '', '', '850.00', '1'),
(38, 95, '', '', '800.00', '1'),
(39, 96, '', '', '200.00', '1'),
(39, 97, '', '', '300.00', '1'),
(39, 98, '', '', '300.00', '1'),
(39, 99, '', '', '300.00', '1'),
(39, 100, '', '', '350.00', '1'),
(39, 0, '1PC. BRONZE FITTING(OIL)', '', '80.00', '1'),
(39, 0, '1PC. FITTING BRONZE (WATER)', '', '150.00', '1'),
(40, 62, '', '', '1810.00', '1'),
(41, 72, '', '', '150.00', '1'),
(41, 101, '', '', '350.00', '1'),
(41, 71, '', '', '150.00', '1'),
(41, 0, '1P OIL FILTER', '', '235.00', '1'),
(41, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(41, 0, '1GAL. CVT FLUID', '', '2450.00', '1'),
(41, 0, '1PC. TRANSMISSION SUPPORT', '', '2500.00', '1'),
(42, 102, '', '', '1800.00', '1'),
(42, 0, '1SET CORNER LAMP RH/LH', '', '1200.00', '1'),
(43, 7, '', '', '150.00', '1'),
(43, 103, '', '', '550.00', '1'),
(43, 77, '', '', '450.00', '1'),
(43, 43, '', '', '150.00', '1'),
(43, 105, '', '', '200.00', '1'),
(43, 106, '', '', '150.00', '1'),
(43, 107, '', '', '1800.00', '1'),
(43, 0, 'CLEANING SOLVENT', '', '100.00', '1'),
(43, 0, '4LTRS. ENGINE OIL', '', '950.00', '1'),
(43, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(43, 0, '1PC. MIGHTY GASKET', '', '130.00', '1'),
(43, 0, '1PC. LOWER ARM BUSHING', '', '450.00', '1'),
(43, 0, '1PC. STABILIZER LINK FOR RH', '', '680.00', '1'),
(43, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(43, 0, '1PC. OIL SEAL', '', '550.00', '1'),
(43, 0, 'BRAKE FLUID', '', '100.00', '1'),
(44, 108, '', '', '350.00', '1'),
(45, 109, '', '', '100.00', '1'),
(45, 0, '1PC RELAY', '', '140.00', '1'),
(46, 0, '1PC. VALVE SPRING', '', '250.00', '1'),
(47, 110, '', '', '1500.00', '1'),
(47, 111, '', '', '300.00', '1'),
(47, 0, '1PCS. SHOCK ABSORBER', '', '1200.00', '1'),
(48, 112, '', '', '200.00', '1'),
(48, 113, '', '', '2000.00', '1'),
(48, 114, '', '', '150.00', '1'),
(48, 0, '1PC. VOLTAGE REGULATOR', '', '800.00', '1'),
(49, 7, '', '', '150.00', '1'),
(49, 49, '', '', '250.00', '1'),
(49, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(49, 0, '4PCS. SPARK PLUG', '', '640.00', '1'),
(49, 0, '1GAL. ENGINE OIL', '', '890.00', '1'),
(49, 0, '1PC. AIR FILTER', '', '595.00', '1'),
(49, 0, '1QRT. COOLANT', '', '215.00', '1'),
(50, 115, '', '', '1300.00', '1'),
(51, 59, '', '', '9500.00', '1'),
(51, 0, '1SET C ON ROD BEARING', '', '1500.00', '1'),
(51, 0, '1PC. CRANKSHAFT ASSY', '', '12000.00', '1'),
(51, 0, '1PC. CONNECTING ROD ASSY', '', '6500.00', '1'),
(51, 0, '1SET OVERHAULING GASKET', '', '1900.00', '1'),
(51, 0, 'ENGINE OIL', '', '1380.00', '1'),
(51, 0, 'OIL FILTER', '', '420.00', '1'),
(51, 0, 'CLEANING SOLVENT', '', '200.00', '1'),
(51, 0, '1PC CONIA (CRUCK KEY)', '', '90.00', '1'),
(51, 0, 'PISTON SET', '', '5500.00', '1'),
(51, 0, 'LINER SET', '', '5500.00', '1'),
(51, 0, 'PISTON RING SET', '', '1800.00', '1'),
(51, 0, 'ENGINE VALVE SET', '', '1950.00', '1'),
(51, 0, '1PC PLASTIC GAUGE', '', '100.00', '1'),
(51, 0, '1PC. GASKET MAKER', '', '130.00', '1'),
(51, 0, '1PC. CLUTCH PRESSURE PLATE', '', '5720.00', '1'),
(51, 0, '1PC. CLUTCH DISC', '', '2730.00', '1'),
(51, 0, '1PC. RELEASE BEARING', '', '910.00', '1'),
(51, 0, '1PC. UPPER HOSE', '', '455.00', '1'),
(51, 0, '1PC. OIL SENDER', '', '130.00', '1'),
(51, 0, '1PC.THREEBOND GASKET', '', '130.00', '1'),
(51, 0, '1PC. RADIATOR ASSY', '', '7500.00', '1'),
(51, 87, '', '', '300.00', '1'),
(52, 59, '', '', '4345.00', '1'),
(53, 120, '', '', '450.00', '1'),
(53, 121, '', '', '450.00', '1'),
(53, 0, '1PC. TPS SENSOR', '', '1500.00', '1'),
(53, 0, 'ATF', '', '260.00', '1'),
(54, 122, '', '', '450.00', '1'),
(54, 123, '', '', '150.00', '1'),
(54, 124, '', '', '150.00', '1'),
(54, 125, '', '', '350.00', '1'),
(54, 126, '', '', '100.00', '1'),
(54, 0, '1LTR. DIESEL OIL', '', '230.00', '1'),
(54, 0, '1SET HANDBRAKE CABLE', '', '1800.00', '1'),
(55, 127, '', '', '1800.00', '1'),
(55, 128, '', '', '700.00', '1'),
(55, 129, '', '', '600.00', '1'),
(55, 130, '', '', '600.00', '1'),
(55, 0, '1PC. CLUTCH COVER', '', '3500.00', '1'),
(55, 0, '1PC. CLUTCH DISC', '', '3200.00', '1'),
(55, 0, '1PC. RELEASE BEARING', '', '950.00', '1'),
(55, 0, '2PCS. RACK END LH/RH', '', '3730.00', '1'),
(55, 0, '2PCS. TIE ROD END LH/RH', '', '2750.00', '1'),
(55, 0, '2PCS. SHOCK ABSORBER FRONT LH/RH', '', '17170.00', '1'),
(56, 131, '', '', '1800.00', '1'),
(56, 0, '1PC CLUTCH COVER', '', '3500.00', '1'),
(56, 0, '1PC. CLUTCH DISC', '', '3200.00', '1'),
(56, 0, '1PC. RELEASE BEARING', '', '950.00', '1'),
(57, 131, '', '', '1800.00', '1'),
(57, 53, '', '', '2500.00', '1'),
(57, 133, '', '', '1200.00', '1'),
(57, 134, '', '', '500.00', '1'),
(57, 135, '', '', '300.00', '1'),
(57, 136, '', '', '800.00', '1'),
(57, 136, '', '', '800.00', '1'),
(57, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(57, 0, '1PC. OIL FILTER', '', '300.00', '1'),
(57, 0, '4PCS. SPARK PLUG', '', '630.00', '1'),
(57, 0, '1PC. AIR FILTER', '', '460.00', '1'),
(57, 0, '1PC. RELEASE BEARING', '', '1300.00', '1'),
(57, 0, '1PC. PLYWHEEL BEARING', '', '200.00', '1'),
(57, 0, '2LTRS. TRANS OIL', '', '460.00', '1'),
(57, 0, '141B FUSHING FLUID', '', '730.00', '1'),
(57, 0, '1PC. EXPANSION VALVE', '', '1500.00', '1'),
(57, 49, '', '', '250.00', '1'),
(58, 0, '1PC PLYWHEEL', '', '4500.00', '1'),
(59, 137, '', '', '450.00', '1'),
(60, 7, '', '', '150.00', '1'),
(60, 138, '', '', '2250.00', '1'),
(60, 0, '1PC OIL FILTER', '', '689.00', '1'),
(60, 0, '5LTRS. FULLY SYNTHETIC OIL', '', '4000.00', '1'),
(60, 0, '4PCS. GRILL CLIP', '', '160.00', '1'),
(61, 139, '', '', '550.00', '1'),
(61, 140, '', '', '250.00', '1'),
(61, 142, '', '', '150.00', '1'),
(61, 141, '', '', '150.00', '1'),
(61, 143, '', '', '100.00', '1'),
(61, 147, '', '', '450.00', '1'),
(61, 0, '1SET TIMING BELT', '', '2210.00', '1'),
(61, 0, '1PC. CRANK SHAFT PULLEY', '', '3640.00', '1'),
(61, 0, '1PC. TENSIONER BEARING (BIG)', '', '845.00', '1'),
(61, 0, '1PC. TENSIONER BEARING (SMALL)', '', '754.00', '1'),
(61, 0, '1PC. OIL SEAL', '', '364.00', '1'),
(61, 0, '1PC. STEERING BELT', '', '208.00', '1'),
(61, 0, '1PC. DRIVE BELT', '', '364.00', '1'),
(61, 0, '1PC. ALTERNATOR BELT', '', '364.00', '1'),
(62, 149, '', '', '2650.00', '1'),
(62, 0, '1PC. RELEASE BEARING', '', '1200.00', '1'),
(63, 85, '', '', '350.00', '1'),
(63, 0, '1PC. BRAKE MASTER ASSY.', '', '1560.00', '1'),
(63, 0, 'BRAKE FLUID', '', '100.00', '1'),
(64, 145, '', '', '250.00', '1'),
(64, 0, '1PC. DRIVE BELT', '', '960.00', '1'),
(65, 151, '', '', '100.00', '1'),
(66, 152, '', '', '1500.00', '1'),
(66, 153, '', '', '4500.00', '1'),
(66, 115, '', '', '1800.00', '1'),
(66, 53, '', '', '2500.00', '1'),
(66, 124, '', '', '250.00', '1'),
(66, 155, '', '', '580.00', '1'),
(66, 156, '', '', '550.00', '1'),
(66, 157, '', '', '1000.00', '1'),
(66, 0, '1PC. POWER LOCK', '', '350.00', '1'),
(66, 0, '1PC. STEREO POWER', '', '4200.00', '1'),
(66, 0, 'TINT', '', '1800.00', '1'),
(66, 0, '2PCS. SEATBELTS', '', '4500.00', '1'),
(67, 146, '', '', '150.00', '1'),
(67, 116, '', '', '150.00', '1'),
(67, 49, '', '', '250.00', '1'),
(67, 25, '', '', '250.00', '1'),
(67, 158, '', '', '100.00', '1'),
(67, 159, '', '', '100.00', '1'),
(67, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(67, 0, '1PC. AIR FILTER', '', '455.00', '1'),
(67, 0, '4PCS. SPARK PLUG', '', '500.00', '1'),
(67, 0, '1PC. ALTERNATOR BELT', '', '715.00', '1'),
(67, 0, '1PC. FUEL FILTER', '', '325.00', '1'),
(67, 0, '1PC. VALVE COVER GASKET', '', '286.00', '1'),
(67, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(68, 62, '', '', '15825.00', '1'),
(69, 62, '', '', '2700.00', '1'),
(70, 160, '', '', '50000.00', '1');

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=161 ;

--
-- Dumping data for table `labortype`
--

INSERT INTO `labortype` (`laborid`, `name`, `category`, `status`) VALUES
(1, 'Car Wash', 1, '1'),
(2, 'Painting', 1, '1'),
(4, 'Braking', 5, '1'),
(22, 'Change Mirror', 1, '1'),
(7, 'Change Oil', 1, '1'),
(10, 'Change Tire', 1, '1'),
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
(41, 'REPLACE HORN', 1, '1'),
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
(160, 'REPAIR 1 UNIT ISUZU DMAX2010', 1, '1');

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=74 ;

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
(73, 'admin', '1', '2013-06-11 21:12:09');

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
-- Table structure for table `tmp_jo_details_cache`
--

CREATE TABLE IF NOT EXISTS `tmp_jo_details_cache` (
  `trace_id` int(11) NOT NULL AUTO_INCREMENT,
  `labor` int(11) NOT NULL DEFAULT '0',
  `partmaterial` varchar(255) DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT NULL,
  UNIQUE KEY `trace_id` (`trace_id`)
) ENGINE=MEMORY  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `tmp_jo_details_cache`
--

INSERT INTO `tmp_jo_details_cache` (`trace_id`, `labor`, `partmaterial`, `details`, `amnt`) VALUES
(1, 160, '', '', '50000.00');

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=77 ;

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
(76, 'HONDA CITY 2006', '1');

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
  PRIMARY KEY (`vo_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=68 ;

--
-- Dumping data for table `vehicle_owner`
--

INSERT INTO `vehicle_owner` (`vo_id`, `plateno`, `color`, `make`, `description`, `owner`, `status`) VALUES
(7, 'MFN 122', 23, 36, '', 27, '1'),
(8, 'KHU-111', 23, 37, '', 28, '1'),
(9, 'MFB-115', 23, 38, '', 29, '1'),
(10, 'UAR-731', 22, 39, '', 26, '1'),
(11, '0000', 23, 73, '', 30, '1'),
(12, 'KCT-107', 10, 40, '', 31, '1'),
(13, 'KCK-965', 22, 41, '', 32, '1'),
(14, 'PQM-689', 1, 42, '', 36, '1'),
(15, 'KDE-550', 22, 43, '', 37, '1'),
(16, 'KCU-764', 10, 44, '', 38, '1'),
(17, 'KEL-935', 31, 45, '', 40, '1'),
(18, 'KEJ-416', 10, 46, '', 41, '1'),
(19, 'ZLJ-948', 32, 74, '', 42, '1'),
(20, 'KCZ656', 33, 40, '', 43, '1'),
(21, 'KCK-965', 22, 41, '', 44, '1'),
(22, 'KBP-657', 1, 48, '', 45, '1'),
(23, 'GEN-732', 22, 49, '', 46, '1'),
(24, 'KFU-553', 25, 50, '', 47, '1'),
(25, 'ZKP-920', 2, 51, '', 48, '1'),
(26, 'KDM-249', 34, 52, '', 49, '1'),
(27, 'UKA-563', 22, 53, '', 50, '1'),
(28, 'NOL-541', 10, 52, '', 51, '1'),
(29, 'NQV-326', 22, 54, '', 52, '1'),
(30, 'KVU-924', 35, 54, '', 52, '1'),
(31, 'NOA-844', 36, 55, '', 54, '1'),
(32, 'KCM-313', 10, 56, '', 55, '1'),
(33, 'KCC-437', 22, 57, '', 56, '1'),
(34, 'KGF-430', 25, 58, '', 57, '1'),
(35, 'NQL-699', 24, 59, '', 58, '1'),
(36, 'MFB-115', 31, 38, '', 29, '1'),
(37, 'ZLJ-948', 32, 74, '', 42, '1'),
(38, 'KCZ-580', 3, 43, '', 61, '1'),
(39, 'TJD-176', 2, 39, '', 62, '1'),
(40, 'KDE-510', 22, 61, '', 63, '1'),
(41, 'UAH-908', 37, 62, '', 64, '1'),
(42, 'POK-765', 1, 63, '', 65, '1'),
(43, 'NO PLATE', 32, 73, '', 68, '1'),
(44, 'XHV-831', 10, 37, '', 69, '1'),
(45, 'GPX-640', 2, 64, '', 70, '1'),
(46, 'ZTR-517', 10, 65, '', 71, '1'),
(47, 'MFB-115', 31, 38, '', 72, '1'),
(48, 'KCS-463', 3, 66, '', 73, '1'),
(49, 'POK-165', 32, 63, '', 65, '1'),
(50, 'JBS-789', 2, 67, '', 75, '1'),
(51, 'OEV-356', 22, 68, '', 76, '1'),
(52, 'ZKP-920', 10, 76, '', 77, '1'),
(53, 'ZKP-920', 37, 43, '', 78, '1'),
(54, 'KER 975', 10, 43, '', 79, '1'),
(55, 'NO PLATE', 32, 73, '', 80, '1'),
(56, 'TJD-176', 2, 39, '', 62, '1'),
(57, 'KDA-668', 38, 56, '', 82, '1'),
(58, 'NQV-326', 22, 54, '', 83, '1'),
(59, 'NOK-251', 22, 54, '', 83, '1'),
(60, 'MFN-122', 31, 36, '', 27, '1'),
(61, 'NO PLATE', 10, 52, '', 86, '1'),
(62, 'KDM-249', 1, 52, '', 87, '1'),
(63, 'XGJ-146', 22, 40, '', 88, '1'),
(64, 'UKD-396', 39, 69, '', 89, '1'),
(65, 'KDA-668', 36, 70, '', 82, '1'),
(66, 'NKO-676', 22, 71, '', 91, '1'),
(67, 'KEL-935', 31, 72, '', 92, '1');

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
  PRIMARY KEY (`vr_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=69 ;

--
-- Dumping data for table `vehicle_receive`
--

INSERT INTO `vehicle_receive` (`vr_id`, `customer`, `vehicle`, `recdate`, `status`, `recby`) VALUES
(7, 27, 7, '2013-01-04', '1', 12),
(8, 28, 8, '2013-01-04', '1', 12),
(9, 29, 9, '2013-01-04', '1', 12),
(10, 26, 10, '2013-01-04', '1', 12),
(11, 30, 11, '2013-01-03', '1', 12),
(12, 31, 12, '2013-01-03', '1', 12),
(13, 32, 13, '2013-01-04', '1', 12),
(14, 32, 13, '2013-01-04', '1', 12),
(15, 36, 14, '2013-01-04', '1', 12),
(16, 37, 15, '2013-01-05', '1', 12),
(17, 38, 16, '2013-01-05', '1', 12),
(18, 40, 17, '2013-01-05', '1', 12),
(19, 41, 18, '2013-01-05', '1', 12),
(20, 42, 19, '2013-01-05', '1', 12),
(21, 43, 20, '2013-01-07', '1', 12),
(22, 44, 21, '2013-01-03', '1', 12),
(23, 45, 22, '2013-01-07', '1', 12),
(24, 46, 23, '2013-01-10', '1', 12),
(25, 47, 24, '2013-01-11', '1', 12),
(26, 48, 25, '2013-01-11', '1', 12),
(27, 49, 26, '2013-01-12', '1', 12),
(28, 50, 27, '2013-01-12', '1', 12),
(29, 51, 28, '2013-01-12', '1', 12),
(30, 52, 29, '2013-01-09', '1', 12),
(31, 52, 30, '2013-01-09', '1', 12),
(32, 54, 31, '2013-01-14', '1', 12),
(33, 55, 32, '2013-01-14', '1', 12),
(34, 56, 33, '2013-01-14', '1', 12),
(35, 57, 34, '2013-01-15', '1', 12),
(36, 58, 35, '2013-01-15', '1', 12),
(37, 29, 9, '2013-01-16', '1', 12),
(38, 42, 19, '2013-01-16', '1', 12),
(39, 61, 38, '2013-01-17', '1', 12),
(40, 62, 39, '2013-01-18', '1', 12),
(41, 63, 40, '2013-01-19', '1', 12),
(42, 64, 41, '2013-01-19', '1', 12),
(43, 65, 42, '2013-01-19', '1', 12),
(44, 68, 43, '2013-01-19', '1', 12),
(45, 69, 44, '2013-01-19', '1', 12),
(46, 70, 45, '2013-01-19', '1', 12),
(47, 71, 46, '2013-01-19', '1', 12),
(48, 29, 9, '2013-01-21', '1', 12),
(49, 73, 48, '2013-01-21', '1', 12),
(50, 65, 42, '2013-01-21', '1', 12),
(51, 75, 50, '2013-01-22', '1', 12),
(52, 76, 51, '2013-01-22', '1', 12),
(53, 77, 52, '2013-01-23', '1', 12),
(54, 48, 25, '2013-01-15', '1', 12),
(55, 79, 54, '2013-01-24', '1', 12),
(56, 80, 55, '2013-01-24', '1', 12),
(57, 62, 39, '2013-01-28', '1', 12),
(58, 82, 57, '2013-01-28', '1', 12),
(59, 83, 58, '2013-01-28', '1', 12),
(60, 83, 59, '2013-01-28', '1', 12),
(61, 27, 7, '2013-01-28', '1', 12),
(62, 86, 61, '2013-01-26', '1', 12),
(63, 87, 62, '2013-01-26', '1', 12),
(64, 88, 63, '2013-01-26', '1', 12),
(65, 89, 64, '2013-01-29', '1', 12),
(66, 82, 65, '2013-01-29', '1', 12),
(67, 91, 66, '2013-01-29', '1', 12),
(68, 92, 67, '2013-01-29', '1', 12);

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

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
