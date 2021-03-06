-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 21, 2013 at 06:29 AM
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
  PRIMARY KEY (`custid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=669 ;

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
(92, 'GABRIEL', '', 'UMEREZ', '', '088', '1', 0),
(93, 'JOSEPH ', '  ', 'ESTROBO ', '  ', '088 ', '1', 0),
(94, ' MARK', ' ', 'ABDULLAH', ' ', '088', '1', 0),
(95, ' ROBERTO,JR.', 'V. ', 'MALFERRARI', ' ', ' 088', '1', 0),
(96, ' HAZEL ELIZABETH', ' P.', 'CHAARAONI', ' ', '088', '1', 0),
(97, ' RIZAL', 'MEHMET', 'DALKILIC', ' ', '088', '1', 0),
(98, 'DONALD ', ' ', 'CORDERO', ' ', '088', '1', 0),
(99, ' DAOMILAS', ' ', 'DAO', ' ', '088', '1', 0),
(101, ' TOPWATCH AGENCY', 'SECURITY ', 'AGENCY', ' ', '088', '1', 1),
(102, 'ISRAEL ', ' ', 'ADELANTE', ' ', '088', '1', 0),
(103, 'TOPWATCH AGENCY', 'SECURITY', 'AGENCY', ' ', '088', '1', 1),
(104, ' MARK', ' ', 'ILOGON', ' ', '088', '1', 0),
(105, ' KARL', ' ', 'QUINCO', ' ', '088', '1', 0),
(106, ' ETE', ' ', 'MACHINE SHOP', ' ', ' 088', '1', 2),
(107, 'RICHARD ', ' ', 'ONG', ' ', '088', '1', 0),
(108, ' REGIE MARIE', ' ', 'GUEVARRA', ' ', '088', '1', 0),
(109, 'REGIE MARIE', ' ', 'GUEVARRA', ' ', '088', '1', 0),
(110, 'RICHIE ', ' ', 'ARRIESGADO', ' NONE', '088', '1', 0),
(111, ' KENNY MICK', ' ', 'SERQUIÑA', ' ', '088', '1', 4),
(112, ' KENN', ' ', 'SERQ', ' ', '088', '1', 4),
(113, 'JOHN RAY', ' ', 'BADAJOS', ' ', ' 088', '1', 0),
(114, ' JUN RAñERI', ' R.', 'OLIVEROS', ' ', ' 088', '1', 0),
(115, ' ABRAHIM', 'TURHISH', 'MASTAFA', ' ', '088', '1', 0),
(116, 'JOSEPH', 'P.', 'LEE', ' ', '088', '1', 5),
(117, ' KAROL JO', 'E.', 'ALVAREZ', ' ', '088', '1', 6),
(118, 'KAROL JO', 'E.', 'ALVAREZ', ' ', '088', '1', 6),
(119, ' GERARDO', ' ', 'CHAVEZ', ' ', '088', '1', 0),
(120, ' AUDY', 'REYES', 'ONG', ' ', '088', '1', 0),
(121, 'MIKE ', ' ', 'CORONAN', ' ', '088', '1', 0),
(122, ' FRANCIS', ' ', 'LANUSA', ' ', '088', '1', 7),
(123, 'PRINSESA HIYAS ', 'T.', 'LABAY', ' ', '088', '1', 8),
(124, 'RALPH MC LEON ', ' ', 'QUIJANO', ' ', '088', '1', 8),
(125, ' SUMALPONG', ' ', 'DELIZA', ' ', '088', '1', 9),
(126, ' CHRISTIAN', ' ', 'DADULAS', ' ', '088', '1', 0),
(127, ' CHING', ' ', 'CABASE', ' ', '09478083827', '1', 0),
(128, ' RIZALINO', ' ', 'BULAGULAN', ' ', '088', '1', 0),
(129, ' JAIME', ' ', 'PUBLICO', ' ', '088', '1', 0),
(130, ' PATRICK BRYAN', ' E. ', 'ABSIN', ' ', '088', '1', 10),
(131, ' TEODORO', 'A.', 'GALES', ' ', ' 088', '1', 0),
(132, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(133, 'JOHN ', ' ', 'CUA', ' ', '088', '1', 0),
(134, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(135, ' DENNIS', ' ', 'YAP', ' ', '088', '1', 0),
(136, ' BOY', ' ', 'SALAZAR', ' ', '088', '1', 0),
(137, ' ROGER', ' ', 'ALBACETE', ' ', '088', '1', 0),
(138, ' JOLO', ' ', 'CABALANG', ' ', '088', '1', 0),
(139, ' ELPEDIO,JR.', ' ', 'LABRADOR', ' ', '088', '1', 0),
(141, ' JONATHAN', 'R', 'CENTENO', ' ', ' 088', '1', 6),
(142, ' JUNE IVY', ' ', 'ANG', ' ', '088', '1', 12),
(143, ' ADRIANO', 'R. ', 'MARGUAX', ' ', '088', '1', 13),
(144, 'CHRISTIAN', ' ', 'DADULAS', ' ', '088', '1', 0),
(145, ' MIKE', ' ', 'IGNACIO', ' ', '088', '1', 0),
(146, ' JOSHUA', ' ', 'HOLCIM', ' ', '088', '1', 0),
(147, ' MARCELO', 'V. ', 'CANOY', ' ', '088', '1', 0),
(148, 'KENNY MICK', ' M.', 'SERQUIÑA', ' ', '088', '1', 0),
(149, 'ROMMEL', ' ', 'TIMOJERA', ' ', '088', '1', 0),
(150, 'ROMMEL', ' ', 'TIMOJERA', ' ', ' 088', '1', 0),
(151, ' JR', ' ', 'NERI', ' ', '088', '1', 0),
(152, 'HAZEL ELIZABETH', ' P.', 'CHAARAONI', ' ', ' 088', '1', 0),
(153, ' DR.BORONGANAN', 'DR.', 'DR.', ' ', ' 09226022351', '1', 0),
(157, ' JB PHARMA', '', 'JB', ' ', '088', '1', 15),
(158, ' JELESIS', ' ', 'TEVES', ' ', '088', '1', 0),
(159, ' JOE', ' ', 'BUERANO', ' ', '088', '1', 0),
(160, ' MARK', ' ', 'ABD', ' ', '088', '1', 0),
(161, 'PHIL. ARMY', ' A', 'PHIL ARMY', ' ', ' 088', '1', 0),
(162, ' JOEMAR', 'P.', 'PENANONANG', ' ', '088', '1', 16),
(163, ' NEUTON ', '  ', 'QUIBLAT ', '  ', '088', '1', 0),
(164, ' DINO', ' ', 'LABITAD', ' ', '088', '1', 0),
(165, ' DAVE', ' ', 'ALEGRADO', ' ', '088', '1', 0),
(166, ' DAVE', ' ', 'ALEGRADO', ' ', '088', '1', 0),
(167, ' CARLO', ' ', 'AVILA', ' ', '088/', '1', 0),
(168, ' RYAN', ' ', 'MELITANTE', ' ', '088', '1', 0),
(169, 'PATRICK', ' ', 'TSENG', ' ', '088', '1', 17),
(170, ' TSENG', ' ', 'PATRICK', ' ', '088', '1', 17),
(171, ' RAUL', ' ', 'CABALANG', ' ', '088', '1', 0),
(172, ' CRISTINO', ' ', 'OYEN', ' ', '088', '1', 0),
(173, 'CRISTINO ', ' ', 'EDRALIN', ' ', ' 088', '1', 0),
(174, ' JOSHUA', ' ', 'BETIA', ' ', '088', '1', 0),
(175, ' BOBBY', ' ', 'MALFERRARI', ' ', '088', '1', 0),
(176, ' HEMBRADOR', ' ', 'HEMBRADOR', ' ', '088', '1', 0),
(177, ' ELPEDIO', ' ', 'LABRADOR', ' ', '088', '1', 0),
(178, ' ATTY. ARTURO', ' ', 'LEGASPI', ' ', '088', '1', 0),
(179, 'ELPEDIO', ' ', 'LABRADOR', ' ', '088', '1', 0),
(180, ' RAMGUAN', ' ', 'KO', ' ', '088', '1', 0),
(181, ' GOGOY', ' ', 'NAGAL', ' ', '088', '1', 0),
(182, ' LEMUEL', ' ', 'PARANTAR', ' ', '088', '1', 0),
(183, ' KRISTOPHER', ' ', 'ABELLANOSA', ' ', '088', '1', 0),
(184, ' JAN IRENE', ' ', 'SMITH', ' ', '088', '1', 0),
(185, ' RAUL', ' ', 'CABALANG', ' ', '088', '1', 0),
(186, ' RAYMOND', ' ', 'ANG', ' ', '088', '1', 0),
(187, ' JONATHAN', ' ', 'CENTENO', ' ', '088', '1', 0),
(188, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 0),
(189, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 18),
(190, ' ROMMEL', ' ', 'TIMONERA', ' ', '088', '1', 0),
(191, ' MICHAEL', ' ', 'IGNACIO', ' ', '088', '1', 0),
(192, ' ENRIQUE', ' ', 'MABOLTO', ' ', '088', '1', 0),
(193, ' DR. LORD SANNY', 'N.', 'SALUAN', ' ', '088', '1', 0),
(194, 'HERMOGENES ', ' ', 'NICDAO', ' ', '088', '1', 7),
(195, 'JOEMAR', ' ', 'PENANONANG', ' ', '088', '1', 16),
(196, 'JOEMAR', ' ', 'PENANONANG', ' ', ' 088', '1', 16),
(197, 'JOEMAR', ' ', 'PENANONANG', ' ', '088', '1', 16),
(198, 'JOEMAR ', '  ', 'PENANONANG ', '  ', '088', '1', 16),
(199, ' THOMAS', 'Q.', 'YLANA', ' ', '088', '1', 19),
(200, ' THOMAS', 'Q.', 'YLANA', ' ', '088', '1', 19),
(201, ' JOHN RAY', ' ', 'BADAJOS', ' ', ' 088', '1', 19),
(202, ' MARK', ' ', 'ILOGON', ' ', '088', '1', 0),
(203, ' MARK', ' ', 'ILOGON', ' ', ' 088', '1', 0),
(204, ' DAVE', ' ', 'ALEGRADO', ' ', '088', '1', 0),
(205, ' EIE MACHINE SHOP', ' ', 'EIE', ' ', '088', '1', 20),
(206, ' BODJIE', ' ', 'SIAO', ' ', '088', '1', 0),
(207, 'ROGER', ' ', 'ALBACETE', ' ', '088', '1', 0),
(208, 'EVELYN ', ' ', 'RAMOS', ' ', '088', '1', 0),
(209, 'EVELYN', ' ', 'RAMOS', ' ', '088', '1', 0),
(210, ' PAUL', ' ', 'AJO', ' ', '088', '1', 0),
(211, 'ROSELYN ', ' ', 'SAN BUENAVENTURA', ' ', '088', '1', 0),
(212, ' ATTY. LEGASPI', ' ', 'ATTY.', ' ', ' 088', '1', 0),
(213, ' ARLENE GRACE', 'P', 'PUGALES', ' ', '088', '1', 21),
(214, ' JONATHAN', ' ', 'CENTENO', ' ', '088', '1', 0),
(215, ' MARK ANGEL', ' ', 'TORAYNO', ' ', ' 088', '1', 4),
(216, ' RODOLFO', 'G', 'CAHULOGAN', ' ', '088', '1', 0),
(217, ' GERARD', ' ', 'CHAVES', ' ', '088', '1', 0),
(218, ' JOCEL', ' ', 'WAKABAYASHI', ' ', '088', '1', 0),
(219, ' CLAUDIOS', ' ', 'ROKICKI', ' ', '088', '1', 0),
(220, 'JOJO', ' ', 'EMBRADOR', ' ', '088', '1', 0),
(221, 'PATRICK', ' ', 'TSENG', ' ', '088', '1', 17),
(222, ' ERVIN JOHN', ' ', 'DANDOY', ' ', '088', '1', 6),
(223, ' ALVIN', ' ', 'PARAS', ' ', '088', '1', 6),
(224, ' RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 8),
(225, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 18),
(226, ' FERNANDO', ' ', 'MAMURI DE JESUS', ' ', '088', '1', 5),
(227, ' DARLENE MAY', ' ', 'LAPUZ', ' ', '088', '1', 9),
(228, ' MARK LESTER', ' ', 'SANTOS', ' ', '088', '1', 5),
(229, ' CLINT PAUL', ' ', 'PLANTAS', ' ', '088', '1', 8),
(230, ' LUISA', ' ', 'NANALE', ' ', '088', '1', 0),
(231, ' JENNIFER', ' ', 'MIOLE', ' ', '088', '1', 0),
(232, ' JING', ' ', 'EPARWA', ' ', '088', '1', 0),
(233, ' MARK', ' ', 'ABDULLAH', ' ', ' 088', '1', 0),
(234, ' STEAG STATE POWER', ' ', 'STATE', ' ', '088', '1', 13),
(235, ' MEDICHEM', ' ', 'MEDICHEM PHARMACEUTICALS', ' ', '088', '1', 13),
(236, ' DELIZA', ' ', 'SUMALPONG', ' ', '088', '1', 0),
(237, ' MYCO CARLO', ' ', 'PERNES', ' ', '088', '1', 14),
(238, 'MYCO CARLO', ' ', 'PERNES', ' ', '088', '1', 14),
(239, 'MARK ANGEL ', ' ', 'TORAYNO', ' ', '088', '1', 4),
(240, ' TEDDY', ' ', 'CABALTES', ' ', '088', '1', 0),
(241, ' TOPHE', ' ', 'PEREZ', ' ', '09062430406', '1', 0),
(242, 'MARK', ' ', 'ILOGON', ' ', '088', '1', 0),
(243, ' KEN', ' ', 'MAGNO', ' ', '088', '1', 0),
(244, ' ROGER', ' ', 'ALBACETE', ' ', '088', '1', 0),
(245, ' MCDI', ' ', 'MCDI', ' ', '088', '1', 23),
(246, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(247, ' JIE', ' ', 'TAHA', ' ', '088', '1', 0),
(248, ' DR. BEN', ' ', 'ALBANECE', ' ', '088', '1', 0),
(249, 'RHAYA ', ' ', 'FEBRERO', ' ', '088', '1', 0),
(250, 'MARK', ' ', 'ABDULLAH', ' ', '088', '1', 0),
(251, ' JENNIFER', ' ', 'MIOLE', ' ', '088', '1', 0),
(252, 'ATTY. PAREÑO ', ' ', 'ATTY. PAREÑO', ' ', '088', '1', 0),
(253, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(254, ' MICHAEL', ' ', 'CHAVES', ' ', ' 088', '1', 0),
(255, ' MARK', ' ', 'DIZON', ' ', '088', '1', 0),
(256, ' ROGER', ' ', 'ALBACETE', ' ', '088', '1', 0),
(257, ' OLIVE', ' ', 'TUMULAK', ' ', '088', '1', 0),
(258, ' TEDDY', ' ', 'CABELTES', ' ', '088', '1', 0),
(259, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(260, ' OLIVE ', ' ', 'TUMULAK', ' ', '088', '1', 0),
(261, ' ROGER', ' ', 'ALBACETE ', ' ', '088 ', '1', 0),
(262, 'DELIZA', ' ', 'SUMALPONG', ' ', '088', '1', 0),
(263, ' JOSEPH', ' ', 'ACUZAR', ' ', '088', '1', 0),
(264, ' ROLAND', ' ', 'OLLOVES', ' ', '088', '1', 0),
(265, 'JONATHAN', ' ', 'CENTENO', ' ', ' 088', '1', 0),
(266, ' PEGGY ANN', ' ', 'SEBASTIAN', ' ', '088', '1', 0),
(267, 'JAIREH ', ' ', 'BRACAMONTE', ' ', '088', '1', 0),
(269, ' FRANCIS', 'CLARETE', 'LIM ', ' ', ' 088', '1', 0),
(270, ' CUNARD', ' ', 'CAHARIAN', ' ', '088', '1', 0),
(271, ' MICHAEL', ' ', 'CHAVES', ' ', '088', '1', 0),
(272, 'KARR ', ' ', 'JACKSON', ' ', '088', '1', 0),
(273, ' ROSELYN', ' ', 'SAN BUENAVENTURA', ' ', '088', '1', 0),
(274, 'BOBBY ', ' ', 'CANAPIA', ' ', '088', '1', 0),
(275, 'FLORENCIO ', ' ', 'LUMUSAD', ' ', '088', '1', 0),
(276, ' ALEXIS', ' ', 'EMATA', ' ', '088', '1', 0),
(277, 'ALEXIS', ' ', 'EMATA', ' ', '088', '1', 0),
(278, ' OSIAS', ' ', 'CAROSA', ' ', '088', '1', 0),
(279, ' MANTO', ' ', 'UY', ' ', '088', '1', 0),
(280, ' MRS. GUEVARRA', ' ', 'GUEVARRA', ' ', '088', '1', 0),
(281, ' ROBERT', ' ', 'CRUZ', ' ', '088', '1', 0),
(282, ' ROSE', ' ', 'BUENAVENTURA', ' ', '088', '1', 0),
(283, ' ATTY. LEGASPI', ' ', 'ATTY.LEGASPI', ' ', '088', '1', 0),
(284, ' GEORGE', ' ', 'QUIMPO', ' ', '088', '1', 0),
(285, 'ALDRIN ', ' ', 'TY', ' ', '088', '1', 0),
(286, 'ALDRIN', ' ', 'TY', ' ', '088', '1', 0),
(287, 'METALITE ', ' ', 'METALITE', ' ', '088', '1', 0),
(288, 'JONATHAN', ' ', 'CENTENO', ' ', '088', '1', 0),
(289, ' FELOMINO', ' ', 'NOCIAN', ' ', '088', '1', 0),
(290, ' ROEL', ' ', 'DE LEON', ' ', '088', '1', 0),
(291, ' BOBI', ' ', 'DAGUS', ' ', '088', '1', 0),
(292, ' DENNIS ', ' ', 'ASIO', ' ', '09196031237', '1', 0),
(293, ' JOHN ROI', ' ', 'MANALASTAS', ' ', '088', '1', 0),
(294, 'JB PHARMA', ' ', 'JB PHARMA', ' ', '088', '1', 0),
(295, ' LORREY DIANNE', ' ', 'CHIONG', ' ', '088', '1', 0),
(296, ' KEN', ' ', 'MAGNO', ' ', '088', '1', 0),
(297, 'ROLANDO', ' ', 'BAUZON', ' ', '088/', '1', 0),
(298, ' LOUELA', 'L', 'MAÑA', ' ', '088', '1', 0),
(299, ' RICHARD', ' ', 'ONG', ' ', '088', '1', 0),
(300, ' MICHAEL', ' ', 'PALARCA', ' ', '088', '1', 0),
(301, ' NELSON', ' ', 'FLORES', ' ', '088', '1', 0),
(302, ' GEORGE', ' ', 'SERDEÑA', ' ', '088', '1', 0),
(303, ' KOON', ' ', 'GO', ' ', '088', '1', 0),
(304, ' REY ', ' ', ' ROXAS', ' ', '088', '1', 0),
(305, ' ALDRIN', ' ', 'TY', ' ', '088', '1', 0),
(306, ' MAY RHEZA', ' ', 'BOQUIA', ' ', '088', '1', 0),
(307, ' JOCELYN', ' ', 'HERNANDEZ', ' ', '088', '1', 0),
(308, ' RICHARD', ' ', ' PINOTE', ' ', '088', '1', 0),
(309, ' ROEL', ' ', 'DE LEON', ' ', '088', '1', 0),
(310, ' ARIEL', ' ', 'AMENE', ' ', '088', '1', 0),
(311, 'PAOLO ', ' ', 'JARAULA', ' ', '088', '1', 0),
(312, ' JIGGER JOHN', ' ', 'GEVERO', ' ', '088', '1', 0),
(313, ' ALEX', ' ', 'LAURON', ' ', '088', '1', 0),
(314, 'RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 0),
(315, 'RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 0),
(316, ' ROBERT', ' ', 'CRUZ', ' ', '088', '1', 0),
(317, ' GASPAR', ' ', 'HABUG', ' ', '088', '1', 0),
(318, ' EDWIN', ' ', 'ELORDE', ' ', '088', '1', 0),
(319, ' MICHAEL', ' ', 'PALARCA', ' ', '088', '1', 0),
(320, ' JOHN', ' ', 'MACHATE', ' ', '088', '1', 0),
(321, ' BONG', ' ', 'ANECITO', ' ', '088', '1', 0),
(322, ' ROLANDO', ' ', 'BAUZON', ' ', '088', '1', 0),
(323, ' JING', ' ', 'BRUNO', ' ', '088', '1', 0),
(324, 'GRACE ', ' ', 'ALCANTARA', ' ', '088', '1', 0),
(325, 'AL MARTIN ', ' ', 'PARANTAR', ' ', '088', '1', 0),
(326, ' JOHN ROI', ' ', 'MANALASTAS', ' ', '088', '1', 0),
(327, ' DELIZA', ' ', 'SUMALPONG', ' ', '088', '1', 0),
(328, ' RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 0),
(329, ' ROMAN', ' ', 'ALBASIN', ' ', '088', '1', 0),
(330, ' DARLENE', ' ', 'LAPUZ', ' ', '088', '1', 0),
(331, ' DARLENE', ' ', 'LAPUZ', ' ', '088', '1', 0),
(332, ' MA. CARMELITA', ' ', 'ALVAREZ', ' ', '088', '1', 0),
(333, 'MA. CARMELITA', ' ', 'ALVAREZ', '', ' 088', '1', 9),
(334, ' CHARMAE', 'LACONDE', 'JANAYON', ' ', '088', '1', 8),
(335, 'CHARMAE', ' ', 'JANAYON', ' ', ' 088', '1', 8),
(336, ' JOHN ROI', ' ', 'MANALASTAS', ' ', ' 088', '1', 8),
(337, 'JOHN ROI', ' ', ' MANALASTAS', ' ', '088', '1', 8),
(338, ' AL GAUVIN', ' ', 'LABUNTOG', ' ', '088', '1', 16),
(339, ' ASHBY MARIE', ' ', 'SALAZAR', ' ', '088', '1', 5),
(340, 'AP-CARGO', ' ', 'AP', ' ', ' 088', '1', 18),
(341, ' JANICE', ' ', 'JANIOSA', ' ', ' 088', '1', 0),
(342, ' MON', ' ', 'MEDINA', ' ', '088', '1', 0),
(343, ' MICHAEL', ' ', 'PALARCA', ' ', '088', '1', 0),
(344, ' HON. ROELITO', ' ', 'GAWILAN', ' ', '088', '1', 0),
(345, 'ALDRIN', ' ', 'TY', ' ', '088', '1', 0),
(346, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 18),
(347, 'MIKHAEL/LRI THERAPHARMA', ' ', 'BAUTISTA', ' ', '088', '1', 8),
(348, 'MYCO CARLO', ' ', 'PERNES', ' ', '088', '1', 14),
(349, ' JAIREH MAY', ' ', 'BRACAMONTE', ' ', '088', '1', 5),
(350, ' JANICE', ' ', 'JANIOSO', ' ', '088', '1', 0),
(351, ' MANNY', ' ', 'DUWA', ' ', '088', '1', 0),
(352, ' HIMEX', ' ', 'HIMEX COOP', ' ', '088', '1', 25),
(353, ' ROEL', ' ', 'DE LEON', ' ', '088', '1', 0),
(354, ' MIKE', ' ', 'IGNACIO', ' ', '088', '1', 0),
(355, ' AILEEN', ' ', 'PALAD', ' ', '088', '1', 0),
(356, ' ROCHELLE', ' ', 'CANO', ' ', '088', '1', 26),
(357, ' MCDI', ' ', 'MCDI', ' ', '088', '1', 23),
(358, ' ALEX', ' ', 'LAURON', ' ', '088', '1', 0),
(359, ' STARGATE', ' ', 'STARGET', ' ', '088', '1', 0),
(360, ' BASIC PHARMA', ' ', 'BASIC', ' ', '088', '1', 26),
(361, ' JERITZ', ' ', 'BALDADO', ' ', '088', '1', 0),
(362, 'BOY ', ' ', 'DOSDOS', ' ', '088', '1', 0),
(363, ' BOY', ' ', 'DOSDOS', ' ', '088', '1', 0),
(364, ' JHOSTONI', ' ', 'GO', ' ', '088', '1', 0),
(365, ' MANNY', ' ', 'DUWA', ' ', '088', '1', 0),
(366, ' MIKE', ' ', 'IGNACIO', ' ', '088', '1', 0),
(367, ' REY', ' ', 'ROXAS', ' ', '088', '1', 0),
(368, 'CHARMAE ', ' ', 'JANAYON', ' ', '088', '1', 0),
(369, 'CHARMAE', ' ', 'JANAYON', ' ', ' 088', '1', 8),
(370, 'CHARMAE', ' ', 'JANAYON', ' ', '088', '1', 8),
(371, 'DENNIS', ' ', 'UY', ' ', ' 088', '1', 0),
(372, ' PAUL', ' ', 'BACANDA', ' ', '088', '1', 0),
(373, 'MIKE ', ' ', 'CAPINPUYAN', ' ', '088', '1', 0),
(374, ' EDSEL', ' ', 'BALINTAG', ' ', '088', '1', 0),
(375, ' ROBINSON', ' ', 'TAN', ' ', '088', '1', 0),
(376, ' JOHN PAUL', ' ', 'GO', ' ', '088', '1', 0),
(377, ' KHARIS', ' ', 'JANNY', ' ', '088', '1', 0),
(378, ' ALEX', ' ', 'LAURON', ' ', '088', '1', 0),
(379, ' EDISON', ' ', 'GRAMATA', ' ', '088', '1', 0),
(380, 'EDISON', ' ', 'GRAMATA', ' ', '088', '1', 0),
(381, ' JESS', ' ', 'VERGARA', ' ', '088', '1', 0),
(382, ' KARL', ' ', 'TALINGTING', ' ', '088', '1', 0),
(383, ' KARL', ' ', 'TALINGTING', ' ', '088', '1', 0),
(384, ' MCDI', ' ', 'MCDI', ' ', '088', '1', 0),
(385, ' PAOLO', ' ', 'JARAULA', ' ', '088', '1', 0),
(386, 'EMMANUEL ', ' ', 'PIMENTEL', ' ', '088', '1', 0),
(387, 'FRANCIS', ' ', 'LIM', ' ', '088', '1', 0),
(388, 'PATRICK', ' ', 'ABSIN', ' ', ' 088', '1', 23),
(389, ' FRANCISCO', ' ', 'BUCTUAN', ' ', '088', '1', 0),
(390, ' MARK', ' ', 'ILOGON', ' ', '088', '1', 0),
(391, 'GUSTAVO ', ' ', 'ANSALDO', ' ', '088', '1', 0),
(392, ' DAVID', ' ', 'JOHANSON', ' ', '088', '1', 0),
(393, ' ROBERT', ' ', 'JIMENEZ', ' ', '088', '1', 0),
(394, ' APOLLO', ' ', 'LEE', ' ', '088', '1', 0),
(395, ' LOVELLA', ' ', 'MAÑA', ' ', '088', '1', 0),
(396, 'DARLENE ', ' ', 'LAPUZ', ' ', '088', '1', 0),
(397, ' ALESSANDRA', ' ', 'JAVIER', ' ', '088', '1', 0),
(398, 'ALESSANDRA', ' ', 'JAVIER', ' ', '088', '1', 0),
(399, 'RUDY ', ' ', 'GALCERAN', ' ', '088', '1', 0),
(400, ' FIRMACION II', ' ', 'SERG', ' ', '088', '1', 0),
(401, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(402, ' JUVY', ' ', 'PEETERS', ' ', '088', '1', 0),
(403, 'PHIL. ARMY', ' ', 'PHIL ARMY', ' ', ' 088', '1', 0),
(404, ' REY', ' ', 'VILLAFRANCA', ' ', '088', '1', 0),
(405, ' FELIMON', ' ', 'KHO', ' ', '088', '1', 0),
(406, ' KEN', ' ', 'MAGNO', ' ', '088', '1', 0),
(407, ' JAYSON', ' ', 'MARTINEZ', ' ', '088', '1', 0),
(408, ' ROBERT', ' ', 'CRUZ', ' ', '088', '1', 0),
(409, ' AILEEN', ' ', 'PALAD', ' ', '088', '1', 0),
(410, ' FR. CLAUDIOS', ' ', 'FR. CLAUDIOS', ' ', '088', '1', 0),
(411, 'FR. CLAUDIOS', '', 'FR. CLAUDIOS', ' ', '088', '1', 0),
(412, ' ANNABEL', 'CARPIO', 'KHO', ' ', '088', '1', 0),
(413, ' RAUL', ' ', 'CABALANG', ' ', '088', '1', 0),
(414, 'PHIL. ARMY', ' ', 'PHIL ARMY', ' ', ' 088', '1', 0),
(415, ' DR. SARMIENTO NIÑO', ' ', 'DR. SARMIENTO', ' ', '088', '1', 0),
(416, 'PAOLO ', '  ', 'BAUTISTA ', '  ', '  088', '1', 0),
(417, ' ACSARA', ' ', 'GUMAL', ' ', '088', '1', 0),
(418, 'ASCARA ', ' ', 'GUMAL', ' ', '088', '1', 0),
(419, ' LOI', ' ', 'DABA', ' ', '088', '1', 0),
(420, 'PHIL. ARMY', ' ', 'PHIL ARMY', ' ', '088', '1', 0),
(421, 'PHIL. ARMY', ' ', 'PHIL ARMY', ' ', '088', '1', 0),
(422, ' REY', ' ', 'MORTIZ', ' ', '088', '1', 0),
(423, 'ISABEL ', ' ', 'ADELANTE', ' ', '088', '1', 0),
(424, 'ISRAEL ', ' ', 'ADELANTE', ' ', '088', '1', 0),
(425, ' JOHN RAY', ' ', 'BADAJOS', ' ', '088', '1', 0),
(426, ' ROBINSON', ' ', ' TAN', ' ', '088', '1', 0),
(427, 'JOVY ', ' ', 'PEETERS', ' ', '088', '1', 0),
(428, ' NASSHIP', ' ', 'HASSAN', ' ', '088', '1', 0),
(429, ' IAN', ' ', 'CABANATAN', ' ', '088', '1', 0),
(430, ' DR. CALINGASAN', ' ', 'DR. CALINGASAN', ' ', '088', '1', 0),
(431, 'DR.SARMIENTO ', ' ', 'DR. SARMIENTO', ' ', '088', '1', 0),
(432, 'DR. CALINGASAN', ' ', 'DR. CALINGASAN', ' ', ' 088', '1', 0),
(433, ' KIMSLE', ' ', 'NISPEROS', ' ', '088', '1', 0),
(434, ' BOY', ' ', 'DOSDOS', ' ', '088', '1', 0),
(435, ' MANNY', ' ', 'DUWA', ' ', '088', '1', 0),
(436, 'JHOSTONI', ' ', 'GO', ' ', '088', '1', 0),
(437, ' AMY', ' ', 'MALFERRARI', ' ', '088', '1', 0),
(438, ' JONATHAN', ' ', 'ROSARIO', ' ', '088', '1', 0),
(439, ' RYAN', ' ', 'MORTIZ', ' ', '088', '1', 0),
(440, ' NICK', ' ', 'RAMOS', ' ', '088', '1', 0),
(441, ' BEBOT', ' ', 'BEBOT', ' ', '088', '1', 0),
(443, ' SONNY', ' ', 'MANUAL', ' ', '088', '1', 0),
(444, ' DANTE', ' ', 'JAYSON', ' ', '088', '1', 0),
(445, ' ARLENE ', ' ', ' LABIAL', ' ', '088', '1', 0),
(446, ' ROBERT', ' ', 'CRUZ', ' ', '088', '1', 0),
(447, ' JOY', ' ', 'AVILA', ' ', '088', '1', 0),
(448, 'WALK-IN ', ' ', 'WALK-IN', ' ', '088', '1', 0),
(449, ' DEL ROSARIO', ' ', 'DEL ROSARIO', ' ', '088', '1', 0),
(450, ' ROBERT', ' ', 'BANSE', ' ', '088', '1', 0),
(451, ' JOHN', ' ', 'CUA', ' ', '088', '1', 0),
(452, ' EDISON', ' ', 'GRAMATA', ' ', '088', '1', 0),
(453, ' KARL', ' ', 'TALINGTING', ' ', '088', '1', 0),
(454, ' ARLENE JOY', ' ', 'LABIAL', ' ', '088', '1', 0),
(455, 'ARLENE JOY', ' ', 'LABIAL', ' ', '088', '1', 0),
(456, ' MCDI', ' ', 'MCDI', ' ', '088', '1', 0),
(457, ' ATTY. YOYOC', ' ', 'YAP', ' ', '088', '1', 0),
(458, ' SERGIO', ' ', 'YAP', ' ', '088', '1', 0),
(459, ' REY', ' ', 'ROXAS', ' ', '088', '1', 0),
(460, ' ROMMEL', ' ', 'KIAMCO', ' ', '088', '1', 0),
(461, ' JACKY', ' ', 'JACKY', ' ', '088', '1', 0),
(462, ' MARK GERARD', ' ', 'DIZON', ' ', '088', '1', 0),
(463, ' JOSEPH', ' ', 'ESCOBAR', ' ', '088', '1', 8),
(464, 'RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 0),
(465, ' MA. TERESA', ' ', 'LOW', ' ', '088', '1', 0),
(466, ' RAMON', ' ', 'MEDINA', ' ', '088', '1', 0),
(467, ' RAMON', ' ', 'MEDINA', ' ', '088', '1', 0),
(468, ' RAMON', ' ', 'MEDINA', ' ', '088', '1', 0),
(469, ' DELIZA', ' ', 'SUMALPONG', ' ', '088', '1', 0),
(470, ' PHILLIP BENJAMIN', ' ', 'CAJULAO', ' ', '088', '1', 0),
(471, 'MIKHAEL', ' ', 'BAUTISTA', ' ', '088', '1', 8),
(472, ' RHAYA', ' ', 'FEBRERO', ' ', '088', '1', 9),
(473, ' VINCE EDUARD', ' ', 'AGNES', ' ', '088', '1', 0),
(474, ' RUEL, JR', ' ', 'SAA', ' ', ' 088', '1', 0),
(475, 'FRANCIS', ' ', 'LANUZA', ' ', '088', '1', 0),
(476, 'JAIREH MAY', ' ', 'BRACAMONTE', ' ', ' 088', '1', 0),
(477, ' PLANET SPEED', ' ', 'PLANET SPEED', ' ', '088', '1', 0),
(478, ' JOY', ' ', 'AVILA', ' ', '088', '1', 0),
(479, ' BENJO', ' ', 'SY', ' ', '088', '1', 0),
(480, 'EIE MACHINE SHOP', ' ', 'EIE', ' ', '088', '1', 0),
(481, ' IAN', ' ', 'CABANTAN', ' ', '088', '1', 0),
(482, 'RHAYA', ' ', 'FEBRERO', ' ', '088', '1', 0),
(483, ' EDUARDO', ' ', 'ALMIRANTE', ' ', '088', '1', 0),
(484, ' JOSEPH', ' ', 'ESCOBAR', ' ', '088', '1', 8),
(485, ' MIKE', ' ', 'CARONAN', ' ', '088', '1', 11),
(486, ' CLAIRE', ' ', 'BELLO', ' ', '088', '1', 0),
(487, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 18),
(488, 'ARLENE ', ' ', 'LABIAL', ' ', '088', '1', 0),
(489, ' JEFFREY', ' ', 'SY', ' ', '088', '1', 0),
(490, 'MIKHAEL', ' ', 'BAUTISTA', ' ', '088', '1', 8),
(491, ' SIMON', ' ', 'BAUTISTA', ' ', '088', '1', 0),
(492, 'SIMON', ' ', 'BAUTISTA', ' ', '088', '1', 0),
(493, ' GERALD', ' ', 'SUMILE', ' ', '088', '1', 0),
(494, ' GERALD', ' ', 'SUMILE', ' ', '088', '1', 0),
(495, ' RHAYA', ' ', 'FEBRERO', ' ', '088', '1', 9),
(496, ' JAE', ' ', 'SOLEVA', ' ', '088', '1', 0),
(497, 'FR. CLAUDIOS', ' ', 'FR. CLAUDIOS', ' ', ' 088', '1', 0),
(498, ' TONIO', ' ', 'CAAMIÑO', ' ', '088', '1', 29),
(499, 'PAOLO ', ' ', 'JARAULA', ' ', '088', '1', 0),
(500, 'RICHARD ', ' ', 'ONG', ' ', '088', '1', 0),
(501, 'CHRISTIAN', ' ', 'DADULAS', ' ', '088 ', '1', 0),
(502, ' PETER', ' ', 'ROSARIO', ' ', '088', '1', 0),
(503, ' ALMA', ' ', 'SALDUA', ' ', '088', '1', 0),
(504, 'BOJIE', ' ', 'BOJIE', ' ', '088', '1', 0),
(505, ' MR. SY', ' ', 'MR. SY', ' ', '088', '1', 0),
(506, ' JOY', ' ', 'AVILA', ' ', '088', '1', 0),
(507, 'GERALD', ' ', 'SUMILE', ' ', ' 088', '1', 0),
(508, 'LOUELLA ', ' ', 'MAÑA', ' ', '088', '1', 30),
(509, ' PAGAYAMON', ' ', 'PAGAYAMON', ' ', '088', '1', 0),
(510, 'ALEX', ' ', 'LAURON', ' ', '088', '1', 0),
(511, ' JOEMAR ', ' ', 'PENANONANG', ' ', ' 088', '1', 0),
(512, ' ERWIN', ' ', 'SIGNO', ' ', '088', '1', 0),
(513, ' DSEOGRACIA', ' ', 'BAUTISTA', ' ', '088', '1', 0),
(514, ' REY', ' ', 'ROXAS', ' ', '088', '1', 0),
(515, ' ARVY', ' ', 'BERDIDA', ' ', '088', '1', 0),
(516, ' ORIENTAL & MOTOLITE', ' ', 'MKTG. CORP', ' ', '088', '1', 31),
(517, ' JOEMAR', ' ', 'ALOVA', ' ', '088', '1', 0),
(518, ' ROLANDO', ' ', 'BAUZON', ' ', '088', '1', 5),
(519, ' LEONARD', ' ', 'FARIN', ' ', '088', '1', 6),
(520, 'RICHELLE', ' ', 'AYCO', ' ', '088', '1', 8),
(521, 'RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 8),
(522, ' FREDO', ' ', 'MADRONA', ' ', '088', '1', 0),
(523, ' MA. REYNA HOSPITAL', ' ', 'XAVIER UNIVERSITY HOSPITAL', ' ', '088', '1', 0),
(524, ' GABRIEL', ' ', 'ARANJUEZ', ' ', '088', '1', 9),
(525, ' ANDRELITO', ' ', 'GUZMAN', ' ', ' 088', '1', 5),
(526, ' FR. JOBEL', ' ', 'FR. JOBEL', ' ', '088', '1', 0),
(527, ' ALMA', ' ', 'SALDUA', ' ', '088', '1', 0),
(528, ' NARCISO', ' ', 'YBAÑEZ', ' ', '088', '1', 0),
(529, ' AL MARTIN', ' ', 'PARANTAR', ' ', '088', '1', 0),
(530, ' mike ', ' ', 'IGNACIO', ' ', '088', '1', 0),
(531, ' MA. THERESA', ' ', 'GALLARDO', ' ', '088', '1', 0),
(532, ' KEN', ' ', 'MAGNO', ' ', '088', '1', 0),
(533, ' GESTER', ' ', 'YU', ' ', '088', '1', 0),
(534, ' RAYMOND', ' ', 'ANG', ' ', '088', '1', 0),
(535, ' DIAMOND', ' ', 'LOGISTIC', ' ', '088', '1', 0),
(536, ' CHRISTINE ', ' ', 'BDO', ' ', '088', '1', 0),
(537, ' JERRY', ' ', 'BOG-OS', ' ', '088', '1', 0),
(538, 'ATTY. LEGASPI', ' ', 'ATTY.LEGASPI', ' ', '088', '1', 0),
(539, 'MA. REYNA HOSPITAL', ' ', 'XAVIER UNIVERSITY HOSPITAL', ' ', ' 088', '1', 0),
(540, 'RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 8),
(541, 'RALPH MC LEON', ' ', 'QUIJANO', ' ', '088', '1', 0),
(542, 'PROEL', 'CASIMIRO', 'MOFAR', ' ', ' 088', '1', 0),
(543, 'DEL ROSARIO', ' ', 'DEL ROSARIO', ' ', ' 088', '1', 0),
(544, 'KIMBLE ', ' ', 'KIMBLE', ' ', '088', '1', 0),
(545, ' JOEMAR', ' ', 'ALONA', ' ', '088', '1', 0),
(546, 'ARLENE', ' ', 'LABIAL', ' ', '088', '1', 0),
(547, ' DBP', ' ', 'DBP', ' ', '088', '1', 0),
(548, ' CARLO', ' ', 'LIMJOCO', ' ', '088', '1', 0),
(549, ' JING', ' ', 'EMPARWA', ' ', '088', '1', 0),
(550, 'PROEL ', ' ', 'MOFAR', ' ', '088', '1', 0),
(551, 'CEPALCO ', ' ', 'CEPALCO', ' ', ' 088', '1', 0),
(552, 'ALESSANDRA', ' ', 'JAVIER', ' ', '088', '1', 0),
(553, ' AGRINANAS', ' ', 'AGRINANAS', ' ', '088', '1', 32),
(554, 'AGRINANAS', ' ', 'AGRINANAS', ' ', '088', '1', 32),
(555, ' MCDI', ' ', 'MCDI', ' ', '088', '1', 0),
(556, ' AIMEE', ' ', 'HONA', ' ', '088', '1', 14),
(557, ' DARLENE', ' ', 'LAPUZ', ' ', '088', '1', 9),
(558, ' REY', ' ', 'MONDEGO', ' ', '088', '1', 0),
(559, ' LUDY', ' ', 'CASIÑO', ' ', '088', '1', 0),
(560, ' TONIO', ' ', 'CAAMIÑO', ' ', '088', '1', 0),
(561, ' LEA', ' ', 'LARCO', ' ', '088', '1', 0),
(562, ' MULTICARE', ' ', 'MULTICARE', ' ', '088', '1', 0),
(563, ' KHARIS', ' ', 'JANAYON', ' ', '088', '1', 0),
(564, ' DRA. FLORES', ' ', 'DRA. FLORES', ' ', '088', '1', 0),
(565, ' RAY', ' ', 'MONDIGO', ' ', '088', '1', 0),
(566, 'AL MARTIN', ' ', 'PARANTAR', ' ', '088', '1', 0),
(567, ' J', ' ', 'CARHUT', ' ', '088', '1', 0),
(568, 'MULTICARE', ' ', 'MULTICARE', ' ', '088', '1', 33),
(569, ' ALESSANDRA', ' ', 'JAVIER', ' ', '088', '1', 0),
(570, ' JACKY', ' ', 'SY', ' ', '088', '1', 0),
(571, 'JEFFREY', ' ', 'SY', ' ', '088', '1', 0),
(572, ' ALMA', ' ', 'SALDUA', ' ', '088', '1', 0),
(573, ' RICHARD', ' ', 'ONG', ' ', '088', '1', 0),
(574, ' KIMBLE', ' ', 'NISPEROS', ' ', '088', '1', 0),
(575, 'PATRICK', ' ', 'ABSIN', ' ', '088', '1', 0),
(576, ' BRYAN', ' ', 'BRYAN', ' ', '088', '1', 0),
(577, ' FERDINAND', ' ', 'PABILONA', ' ', '088', '1', 0),
(578, ' JONG', ' ', 'SEVILLA', ' ', '088', '1', 0),
(579, 'ROEL ', ' ', 'DE LEON', ' ', '088', '1', 0),
(580, ' JHOSTONI', ' ', 'GO', ' ', '088', '1', 0),
(581, ' CHE2X', ' ', 'BDO', ' ', '088', '1', 0),
(582, 'SABINO ', ' ', 'MABOLO', ' ', '088', '1', 0),
(583, 'RALPH ', ' ', 'QUIJANO', ' ', '088', '1', 0),
(584, ' JOHN', ' ', 'MACHATE', ' ', '088', '1', 0),
(585, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 18),
(586, ' NEUTON', ' ', 'QUIBLAT ', ' ', '088', '1', 0),
(587, 'ORIENTAL & MOTOLITE', ' ', 'MKTG. CORP', ' ', '088', '1', 31),
(588, ' PINKY ', 'ROA', 'BARRIOS', ' ', '088', '1', 0),
(589, ' JOY', ' ', 'JOY', ' ', '088', '1', 0),
(590, ' DEL ROSARIO', ' ', 'DEL ROSARIO', ' ', '.088', '1', 0),
(591, ' RICHARD ', ' ', 'TEE', ' ', '088', '1', 0),
(592, 'MA. REYNA HOSPITAL', ' ', 'XAVIER UNIVERSITY HOSPITAL', ' ', ' 088', '1', 0),
(593, ' ELENO', ' ', 'DOSDOS', ' ', '088', '1', 0),
(594, ' CONGLASCO', ' ', 'CONGLASCO', ' ', '088', '1', 0),
(595, 'MA. THERESA', ' ', 'GALLARDO', ' ', '088', '1', 0),
(596, 'NARCISO ', ' ', 'YBAÑEZ', ' ', '088', '1', 0),
(597, ' ALEX', ' ', 'LAURON', ' ', '088', '1', 0),
(598, 'JELESIS', ' ', 'TEVES', ' ', '088', '1', 0),
(599, ' TONIO', ' ', 'CAAMIÑO', ' ', '088', '1', 0),
(600, 'JHOSTONI', ' ', 'GO', ' ', ' 088', '1', 0),
(601, 'CEPALCO', ' ', 'CEPALCO', ' ', ' 088', '1', 0),
(602, 'ELI ', ' ', 'LILLY', ' ', '088', '1', 0),
(603, ' ELI', ' ', 'LILLY', ' ', '088', '1', 0),
(604, ' SYNTACTICS', ' ', 'SYNTACTICS', ' ', '088', '1', 0),
(605, ' ROBIN', ' ', 'JICABAO', ' ', '09209207738', '1', 0),
(606, 'CHRISTIAN', ' ', 'DADULAS', ' ', '088', '1', 0),
(607, ' SACRED HEART OF JESUS', ' ', 'SACRED', ' ', '088', '1', 0),
(608, ' IKE', ' ', 'EDUAVE', ' ', '088', '1', 0),
(609, ' KRISTINE', ' ', 'BDO', ' ', '088', '1', 0),
(610, ' KENNY', ' ', 'SERQUIÑA', ' ', '088', '1', 0),
(611, ' MIKE', ' ', 'CARONAN', ' ', '088', '1', 0),
(612, ' GEMMA', ' ', 'BDO/ HINLO', ' ', '088', '1', 0),
(613, ' MERLYN', ' ', 'TACANDONG', ' ', '088', '1', 0),
(614, ' BONG', ' ', 'BONG', ' ', '088', '1', 0),
(615, 'PATRICK', ' ', 'TSENG', ' ', '088', '1', 17),
(616, 'EDNA ', ' ', 'BORJA', ' ', '088', '1', 0),
(617, 'PATRICK', ' ', 'TSENG', ' ', '088', '1', 0),
(618, 'ALESSANDRA', ' ', 'JAVIER', ' ', '088', '1', 0),
(619, ' ELIZA', ' ', 'ELIZA', ' ', '088', '1', 0),
(620, ' WALK-IN', ' ', 'WALK-IN', ' ', '088', '1', 0),
(621, 'FERDINAND', ' ', 'PABILONA', ' ', '088', '1', 0),
(622, ' JELLY', ' ', 'GABUCAN', ' ', '088', '1', 0),
(623, ' GARRY', 'F. ', 'CORTEZ', ' ', '09177006873', '1', 0),
(624, 'HEIDE ', ' ', 'CAPAMPANGAN', ' ', '09179698454', '1', 0),
(625, ' ALFRED', ' ', 'SY', ' ', '088', '1', 0),
(626, ' ARON', ' ', 'RAVANERA', ' ', '088', '1', 0),
(627, ' JUVY', ' ', 'PEETERS', ' ', '088', '1', 0),
(628, ' JERRY', ' ', 'GALVEZ', ' ', '088', '1', 0),
(629, ' MARIO', ' ', 'GUEVARRA', ' ', '088', '1', 0),
(630, ' IBRAHIM', ' ', 'IBB', ' ', '088', '1', 0),
(631, ' MARVIN', ' ', 'TORRES', ' ', '088', '1', 0),
(632, 'AP-CARGO', ' ', 'AP', ' ', '088', '1', 0),
(633, ' PAOLO', ' ', 'ACENAS', ' ', '088', '1', 0),
(634, ' FRANCIS JOSEPH', ' ', 'DECIERDO', ' ', '088', '1', 0),
(635, ' GABRIEL', ' ', 'ARANJUEZ', ' ', '088', '1', 0),
(636, ' PHILIP BENJAMIN', ' ', 'CAJULAO', ' ', '088', '1', 0),
(637, ' JERIKO', ' ', 'ALMODOBAR', ' ', '088', '1', 0),
(638, ' MIKHAEL', ' ', 'BAUTISTA', ' ', '088', '1', 0),
(639, ' ALDRIN', ' ', 'TY', ' ', '088', '1', 0),
(640, ' ROLANDO', ' ', 'BAUZON', ' ', '088', '1', 0),
(641, ' FERDINAND', ' ', 'PABILONA', ' ', '088', '1', 0),
(642, 'FRESH ', ' ', 'FRUITS', ' ', '088', '1', 0),
(643, 'KIMBLE', ' ', 'NISPEROS', ' ', '088', '1', 0),
(644, ' ROMAN', ' ', 'ALBASIN', ' ', '088', '1', 0),
(645, 'MCDI', ' ', 'MCDI', ' ', '088', '1', 0),
(646, ' MERLYN', ' ', 'TACANDONG', ' ', '088', '1', 0),
(647, ' FERNANDO', ' ', 'TIU', ' ', '088', '1', 0),
(648, ' JONY', ' ', 'TONGCO', ' ', '088', '1', 0),
(649, ' BONG', ' ', 'ANECITO', ' ', '088', '1', 0),
(650, ' IRENE', ' ', 'CUTAR', ' ', '088', '1', 0),
(651, 'NEUTON ', ' ', 'QUIBLAT', ' ', '088', '1', 14),
(652, ' MARCELO', ' ', 'CANOY', ' ', '088', '1', 0),
(653, ' PHILIP', ' ', 'QUIMPO', ' ', '088', '1', 0),
(654, 'WALK-IN', ' ', 'WALK-IN', ' ', '088', '1', 0),
(655, ' SYNTACTICS', ' ', 'SYNTACTICS', ' ', '088', '1', 0),
(656, ' MAAM BING', ' ', 'MAAM BING', ' ', '088', '1', 0),
(657, 'PHILIP', ' ', 'BUNAGAN', ' ', '088', '1', 0),
(658, ' JUVY', ' ', 'PEETERS', ' ', '088', '1', 0),
(659, ' ERIC', ' ', 'GARCIA', ' ', '088', '1', 0),
(660, ' DR. GEORGE', ' ', 'CARBAJAL', ' ', '088', '1', 0),
(661, 'SABINO', ' ', 'MABOLO', ' ', '088', '1', 0),
(662, ' BESTBAKE', ' ', 'BESTBAKE', ' ', '088', '1', 0),
(663, ' NUTRI-ASIA ', ' ', 'INC.', ' ', '088', '1', 35),
(664, 'BODJIE', ' ', 'SIAO', ' ', '088', '1', 0),
(665, ' TOMMY', ' ', 'TOMMY', ' ', '088', '1', 0),
(666, ' BEBIE', ' ', 'TUMANG', ' ', '088', '1', 0),
(667, 'ODYSSEY DRIVING SCHOOL', ' ', 'ODEYSSEY ', ' ', '088', '1', 0),
(668, 'ODYSSEY DRIVING SCHOOL', ' ', 'ODEYSSEY', ' ', '088', '1', 0);

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity' AUTO_INCREMENT=637 ;

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
(70, '000070', 67, 92, ' KEL-935 -- ISUZU DMAX 2010', 0, NULL, NULL, '2013-01-29', '0.00', '0.00', '1'),
(71, '000071', 68, 93, ' zlt-784 -- TOYOTA VIOS', 0, NULL, NULL, '2013-01-31', '0.00', '0.00', '1'),
(72, '000072', 35, 58, ' NQL-699 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1'),
(73, '000073', 70, 95, ' XJC-760 -- HONDA CR-V', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1'),
(74, '000074', 71, 96, ' ZCG-528 -- INNOVA 2006', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1'),
(75, '000075', 72, 97, ' KCG-656 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1'),
(76, '000076', 73, 98, ' VEZ-620 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-02', '0.00', '0.00', '1'),
(77, '000077', 74, 99, ' NO PLATE -- MITSUBISHI L200', 0, NULL, NULL, '2013-02-04', '0.00', '0.00', '1'),
(78, '000078', 75, 101, ' ZJW-965 -- NISSAN FRONTIER ''07', 0, NULL, NULL, '2013-02-04', '0.00', '0.00', '1'),
(79, '000079', 76, 102, ' NO PLATE -- TOYOTA VIOS ''06', 0, NULL, NULL, '2013-02-04', '0.00', '0.00', '1'),
(80, '000080', 75, 101, ' ZJW-965 -- NISSAN FRONTIER ''07', 0, NULL, NULL, '2013-02-04', '0.00', '0.00', '1'),
(81, '000081', 78, 27, ' MFN 122 -- SUZUKI', 0, NULL, NULL, '2013-02-05', '0.00', '0.00', '1'),
(82, '000082', 79, 105, ' NO PLATE --  Mitsubishi  ', 0, NULL, NULL, '2013-02-05', '0.00', '0.00', '1'),
(83, '000083', 80, 106, ' KEG-189 -- HONDA IMPORTER', 0, NULL, NULL, '2013-02-05', '0.00', '0.00', '1'),
(84, '000084', 81, 107, ' GTB-254 -- MITSUBISHI LANCER ''93-95', 0, NULL, NULL, '2013-02-05', '0.00', '0.00', '1'),
(85, '000085', 82, 108, ' KBU-537 -- TOYOTA TAMARAW FX', 0, NULL, NULL, '2013-02-06', '0.00', '0.00', '1'),
(86, '000086', 82, 108, ' KBU-537 -- TOYOTA TAMARAW FX', 0, NULL, NULL, '2013-02-05', '0.00', '0.00', '1'),
(87, '000087', 84, 110, ' TPS 526 -- NISSAN SENTRA GA13', 0, NULL, NULL, '2013-02-06', '0.00', '0.00', '1'),
(88, '000088', 85, 111, ' ZGP662 -- HYUNDAI GETZ1.1M/T', 0, NULL, NULL, '2013-02-06', '0.00', '0.00', '1'),
(89, '000089', 85, 111, ' ZGP662 -- HYUNDAI GETZ1.1M/T', 0, NULL, NULL, '2013-02-06', '0.00', '0.00', '1'),
(90, '000090', 26, 49, ' KDM-249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1'),
(91, '000091', 88, 114, ' PBO-950 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1'),
(92, '000092', 89, 115, ' KCH-342 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1'),
(93, '000093', 90, 116, ' ZTR 740 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1'),
(94, '000094', 91, 117, ' ZPE-142 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1'),
(95, '000095', 91, 117, ' ZPE-142 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-02-07', '0.00', '0.00', '1'),
(96, '000096', 93, 119, ' KFY-684 -- HONDA FIT', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(97, '000097', 94, 120, ' KFN-437 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(98, '000098', 95, 121, ' NDL-541 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(99, '000099', 96, 122, ' ZTR-990 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(100, '000100', 97, 123, ' ZKP-410 -- TOYOTA VIOS 2007-2008', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(101, '000101', 98, 124, ' ZKP-410 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(102, '000102', 99, 125, ' ZRW-466 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-02-08', '0.00', '0.00', '1'),
(103, '000103', 100, 126, ' PMB-177 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-09', '0.00', '0.00', '1'),
(104, '000104', 101, 127, ' KGJ-185 -- HYUNDAI STAREX ''02', 0, NULL, NULL, '2013-02-09', '0.00', '0.00', '1'),
(105, '000105', 102, 128, ' KDP-703 -- MITSUBISHI STRADA 2004', 0, NULL, NULL, '2013-02-09', '0.00', '0.00', '1'),
(106, '000106', 103, 129, ' NO PLATE -- Honda', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1'),
(107, '000107', 104, 44, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1'),
(108, '000108', 105, 131, ' KDU-175 -- MITSUBISHI ADVENTURE 2008', 0, NULL, NULL, '2013-02-11', '0.00', '0.00', '1'),
(109, '000109', 106, 132, ' ZYX-222 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1'),
(110, '000110', 107, 132, ' GHR-257 -- HONDA ACCORD', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1'),
(111, '000111', 108, 132, ' KCF-884 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1'),
(112, '000112', 109, 135, ' KCF-648 -- ISUZU FUEGO', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1'),
(113, '000113', 110, 136, ' GJR-238 -- HONDA CITY', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1'),
(114, '000114', 111, 137, ' SHJ-477 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-02-12', '0.00', '0.00', '1'),
(115, '000115', 112, 138, ' XMR-211 -- HONDA CIVIC ''2004', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1'),
(116, '000116', 113, 139, ' THG-207 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1'),
(117, '000117', 114, 141, ' ZMH 389 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1'),
(118, '000118', 115, 142, ' KFZ-679 -- ISUZU DMAX 2011', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1'),
(119, '000119', 116, 143, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-02-13', '0.00', '0.00', '1'),
(120, '000120', 117, 126, ' NO PLATE -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-14', '0.00', '0.00', '1'),
(121, '000121', 118, 45, ' KBP-657 -- DAIHATSU CHARADE ''92', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1'),
(122, '000122', 63, 88, ' XGJ-146 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1'),
(123, '000123', 120, 147, ' KDE-850 -- HONDA CITY', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1'),
(124, '000124', 121, 148, ' ZGP-662 -- HYUNDAI GETZ 2005', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1'),
(125, '000125', 122, 149, ' NO PLATE -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1'),
(126, '000126', 123, 149, ' ZRM-270 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-15', '0.00', '0.00', '1'),
(127, '000127', 64, 89, ' UKD-396 -- HONDA ACCORD', 0, NULL, NULL, '2013-02-16', '0.00', '0.00', '1'),
(128, '000128', 125, 96, ' ZCG-528 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-02-16', '0.00', '0.00', '1'),
(129, '000129', 126, 153, ' TGD-371 -- CIVIC ESI', 0, NULL, NULL, '2013-02-16', '0.00', '0.00', '1'),
(130, '000130', 127, 157, ' NOE 844 -- NISSAN ', 0, NULL, NULL, '2013-02-18', '0.00', '0.00', '1'),
(131, '000131', 128, 158, ' URB-361 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-18', '0.00', '0.00', '1'),
(132, '000132', 129, 159, ' PKI-588 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-19', '0.00', '0.00', '1'),
(133, '000133', 130, 58, ' WHV-610 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-19', '0.00', '0.00', '1'),
(134, '000134', 131, 161, ' UBS-806 -- MITSUBISHI L200', 0, NULL, NULL, '2013-02-19', '0.00', '0.00', '1'),
(135, '000135', 132, 162, ' ZPU-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-19', '0.00', '0.00', '1'),
(136, '000136', 133, 163, ' PIX-852 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-19', '0.00', '0.00', '1'),
(137, '000137', 134, 164, ' RCA-655 -- STRADA', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(138, '000138', 135, 165, ' KEZ-926 -- HONDA CIVIC EK4', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(139, '000139', 135, 165, ' KEZ-926 -- HONDA CIVIC EK4', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(140, '000140', 137, 167, ' KBJ-555 -- LANCER BOX TYPE ', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(141, '000141', 138, 168, ' XGS-555 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(142, '000142', 139, 70, ' GJY 555 -- HONDA CR-V', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(143, '000143', 140, 70, ' YDF-296 -- ISUZU CROSSWIND', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(144, '000144', 141, 171, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(145, '000145', 142, 172, ' WTG-939 -- TOYOTA REVO', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1'),
(146, '000146', 143, 173, ' NO PLATE -- REVO ''01', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1'),
(147, '000147', 144, 174, ' KDP-466 -- KIA SPORTAGE ''07', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1'),
(148, '000148', 145, 175, ' XJC-760 -- HONDA CR-V 2003', 0, NULL, NULL, '2013-02-21', '0.00', '0.00', '1'),
(149, '000149', 146, 176, ' TDS-280 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-02-20', '0.00', '0.00', '1'),
(150, '000150', 147, 177, ' AIG-207 -- TOYOTA CAMRY 2000', 0, NULL, NULL, '2013-02-22', '0.00', '0.00', '1'),
(151, '000151', 148, 178, ' GEV-975 -- MITSUBISHI GALANT 95-95', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1'),
(152, '000152', 149, 177, ' THG-207` -- TOYOTA CORONA', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1'),
(153, '000153', 150, 180, ' STJ-483 -- ISUZU TROOPER', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1'),
(154, '000154', 151, 181, ' KDF-860 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1'),
(155, '000155', 152, 182, ' GGV-946 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1'),
(156, '000156', 153, 183, ' UTV-141 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-02-23', '0.00', '0.00', '1'),
(157, '000157', 154, 184, ' KDV-819 -- TOYOTA HI-ACE GRANDIA', 0, NULL, NULL, '2013-02-25', '0.00', '0.00', '1'),
(158, '000158', 155, 171, ' XMR-211 -- Honda', 0, NULL, NULL, '2013-02-25', '0.00', '0.00', '1'),
(159, '000159', 156, 186, ' GHJ-358 -- HONDA CIVIC', 0, NULL, NULL, '2013-02-26', '0.00', '0.00', '1'),
(160, '000160', 114, 141, ' ZMH 389 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-02-26', '0.00', '0.00', '1'),
(161, '000161', 158, 83, ' PUD-750 -- MITSUBISHI L300', 0, NULL, NULL, '2013-02-26', '0.00', '0.00', '1'),
(162, '000162', 159, 83, ' KVU-924 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-26', '0.00', '0.00', '1'),
(163, '000163', 160, 190, ' ZRM-710 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(164, '000164', 161, 191, ' KBP-657 -- DAIHATSU CHARADE', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(165, '000165', 162, 192, ' XHX-944 -- HONDA CR-V', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(166, '000166', 163, 193, ' GHH-333 -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(167, '000167', 164, 194, ' ZDK-482 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(168, '000168', 132, 162, ' ZPU-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(169, '000169', 132, 162, ' ZPU-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(170, '000170', 132, 162, ' ZPU-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(171, '000171', 132, 162, ' ZPU-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(172, '000172', 169, 199, ' KDM-249 -- TOYOTA VIOS SEDAN 2006', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(173, '000173', 26, 49, ' KDM-249 -- TOYOTA VIOS', 0, NULL, NULL, '2013-02-27', '0.00', '0.00', '1'),
(174, '000174', 171, 27, ' MEZ-141 -- MULTICAB', 0, NULL, NULL, '2013-02-28', '0.00', '0.00', '1'),
(175, '000175', 172, 27, ' MFN 122 -- MULTICAB SUZUKI', 0, NULL, NULL, '2013-02-28', '0.00', '0.00', '1'),
(176, '000176', 135, 165, ' KEZ-926 -- HONDA CIVIC EK4', 0, NULL, NULL, '2013-02-28', '0.00', '0.00', '1'),
(177, '000177', 174, 205, ' MBR-615 -- KIA K2 400', 0, NULL, NULL, '2013-02-28', '0.00', '0.00', '1'),
(178, '000178', 175, 206, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-03-01', '0.00', '0.00', '1'),
(179, '000179', 176, 62, ' TJD-176 -- HONDA CITY VTEC', 0, NULL, NULL, '2013-03-01', '0.00', '0.00', '1'),
(180, '000180', 177, 208, ' GDL-522 -- LANCER', 0, NULL, NULL, '2013-03-01', '0.00', '0.00', '1'),
(181, '000181', 177, 208, ' GDL-522 -- LANCER', 0, NULL, NULL, '2013-03-01', '0.00', '0.00', '1'),
(182, '000182', 179, 210, ' KGB-589 -- ISUZU DMAX', 0, NULL, NULL, '2013-03-02', '0.00', '0.00', '1'),
(183, '000183', 180, 211, ' CSL-577 -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-03-02', '0.00', '0.00', '1'),
(184, '000184', 181, 212, ' GEV-975 -- MITSUBISHI GALANT', 0, NULL, NULL, '2013-03-02', '0.00', '0.00', '1'),
(185, '000185', 182, 213, ' KEF-875 -- HONDA CITY', 0, NULL, NULL, '2013-03-04', '0.00', '0.00', '1'),
(186, '000186', 183, 141, ' ZMH-389 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-05', '0.00', '0.00', '1'),
(187, '000187', 184, 215, ' ZNG-361 -- HONDA CITY', 0, NULL, NULL, '2013-03-05', '0.00', '0.00', '1'),
(188, '000188', 185, 216, ' ZDX-543 -- HYUNDAI GETZ ''07', 0, NULL, NULL, '2013-03-05', '0.00', '0.00', '1'),
(189, '000189', 186, 217, ' KEY-684 -- HONDA FIT', 0, NULL, NULL, '2013-03-09', '0.00', '0.00', '1'),
(190, '000190', 187, 218, ' YCJ-718 -- MAZDA MIYATA', 0, NULL, NULL, '2013-03-09', '0.00', '0.00', '1'),
(191, '000191', 188, 219, ' KCZ-588 -- HONDA CITY 2006', 0, NULL, NULL, '2013-03-22', '0.00', '0.00', '1'),
(192, '000192', 189, 220, ' KCN-367 -- TOYOTA REVO', 0, NULL, NULL, '2013-03-13', '0.00', '0.00', '1'),
(193, '000193', 190, 70, ' GJY-555 -- HONDA CR-V', 0, NULL, NULL, '2013-03-13', '0.00', '0.00', '1'),
(194, '000194', 46, 71, ' ZTR-517 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(195, '000195', 192, 223, ' NIY 431 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(196, '000196', 193, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(197, '000197', 194, 83, ' KVU-924 -- MITSUBISHI L300', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(198, '000198', 195, 226, ' ZTL-451 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(199, '000199', 196, 227, ' NKO-749 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(200, '000200', 197, 228, ' ZSS-343 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(201, '000201', 198, 229, ' PYI-919 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(202, '000202', 199, 230, ' KCG-196 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(203, '000203', 200, 231, ' WLP-276 -- NISSAN CEFIRO VQ-276', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(204, '000204', 201, 232, ' UGN-620 -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(205, '000205', 202, 58, ' TZL-389 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(206, '000206', 203, 234, ' KDL-558 -- MITSUBISHI OUTLANDER', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(207, '000207', 204, 235, ' ZRW-466 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(208, '000208', 205, 236, ' ZRW-466 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(209, '000209', 206, 237, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(210, '000210', 207, 237, ' PHO-378 -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(211, '000211', 208, 215, ' ZNG-361 -- HONDA CITY 2006', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(212, '000212', 209, 240, ' GKZ-601 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(213, '000213', 210, 241, ' KBY- 402 -- VOUGSUAGEN', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(214, '000214', 211, 27, ' XBN-266 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(215, '000215', 212, 243, ' GST-813 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(216, '000216', 213, 62, ' TJD-176 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(217, '000217', 214, 76, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(218, '000218', 107, 132, ' GHR-257 -- HONDA ACCORD', 0, NULL, NULL, '2013-03-18', '0.00', '0.00', '1'),
(219, '000219', 216, 247, ' III-209 -- HYUNDAI ELANTRA', 0, NULL, NULL, '2013-03-18', '0.00', '0.00', '1'),
(220, '000220', 217, 248, ' TRV-304 -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(221, '000221', 218, 249, ' NKO-755 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(222, '000222', 219, 58, ' TLL-389 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(223, '000223', 200, 231, ' WLP-276 -- NISSAN CEFIRO VQ-276', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(224, '000224', 221, 252, ' KFE-435 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(225, '000225', 222, 132, ' KCF-884 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(226, '000226', 223, 254, ' ZHL-789 -- TOYOTA VIOS ''06', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(227, '000227', 224, 255, ' ZHT-951 -- TOYOTA VIOS ''06', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(228, '000228', 225, 62, ' SHJ-477 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(229, '000229', 226, 257, ' UQD-136 -- KIA PICANTO', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(230, '000230', 227, 258, ' GKZ-601 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(231, '000231', 106, 132, ' ZYX-222 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(232, '000232', 226, 257, ' UQD-136 -- KIA PICANTO', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(233, '000233', 230, 62, ' TJD-176 -- HONDA CIVIC', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(234, '000234', 205, 236, ' ZRW-466 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-03-22', '0.00', '0.00', '1'),
(235, '000235', 232, 263, ' NDO-841 -- FORD RANGER 2009', 0, NULL, NULL, '2013-03-22', '0.00', '0.00', '1'),
(236, '000236', 233, 264, ' USR-727 -- MITSUBISHI GALANT ''97', 0, NULL, NULL, '2013-03-25', '0.00', '0.00', '1'),
(237, '000237', 183, 141, ' ZMH-389 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(238, '000238', 12, 31, ' KCT-107 -- TOYOTA REVO', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(239, '000239', 236, 267, ' ZRC-290 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(240, '000240', 237, 269, ' NOE-521 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(241, '000241', 238, 270, ' ZPA-807 -- HONDA CITY', 0, NULL, NULL, '2013-03-27', '0.00', '0.00', '1'),
(242, '000242', 239, 254, ' UGI-829 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-30', '0.00', '0.00', '1'),
(243, '000243', 240, 272, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-03-09', '0.00', '0.00', '1'),
(244, '000244', 241, 211, ' CSL-577 --  Mitsubishi  ', 0, NULL, NULL, '2013-03-08', '0.00', '0.00', '1'),
(245, '000245', 242, 274, ' KFD-269 -- MAZDA 3', 0, NULL, NULL, '2013-03-09', '0.00', '0.00', '1'),
(246, '000246', 243, 275, ' GJT-362 -- ISUZU FUEGO', 0, NULL, NULL, '2013-03-09', '0.00', '0.00', '1'),
(247, '000247', 244, 276, ' ZRD-124 -- KIA PICANTO', 0, NULL, NULL, '2013-03-11', '0.00', '0.00', '1'),
(248, '000248', 245, 276, ' ZRD-124 -- KIA PICANTO ''08', 0, NULL, NULL, '2013-03-11', '0.00', '0.00', '1'),
(249, '000249', 246, 278, ' SEH-870 -- HI-LUX', 0, NULL, NULL, '2013-03-11', '0.00', '0.00', '1'),
(250, '000250', 247, 279, ' KCS-703 -- HONDA CR-V', 0, NULL, NULL, '2013-03-11', '0.00', '0.00', '1'),
(251, '000251', 248, 280, ' NO PLATE -- TAMARAW FX', 0, NULL, NULL, '2013-03-15', '0.00', '0.00', '1'),
(252, '000252', 249, 281, ' NO PLATE -- HONDA CR-V', 0, NULL, NULL, '2013-03-12', '0.00', '0.00', '1'),
(253, '000253', 250, 282, ' NO PLATE -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-03-12', '0.00', '0.00', '1'),
(254, '000254', 251, 212, ' GEV-426 -- MITSUBISHI GALANT', 0, NULL, NULL, '2013-03-13', '0.00', '0.00', '1'),
(255, '000255', 252, 284, ' NO PLATE -- SUBARU ''02', 0, NULL, NULL, '2013-03-14', '0.00', '0.00', '1'),
(256, '000256', 253, 285, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(257, '000257', 254, 286, ' PVI-747 -- TOYOTA VIOS 1.3 2010', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(258, '000258', 255, 287, ' KDG-948 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(259, '000259', 256, 141, ' ZMH-389 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-16', '0.00', '0.00', '1'),
(260, '000260', 257, 289, ' JDF-946 -- SUZUKI', 0, NULL, NULL, '2013-03-18', '0.00', '0.00', '1'),
(261, '000261', 258, 290, ' WDY-595 -- NISSAN CEFIRO', 0, NULL, NULL, '2013-03-18', '0.00', '0.00', '1'),
(262, '000262', 259, 291, ' AJM-818 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-03-18', '0.00', '0.00', '1'),
(263, '000263', 260, 292, ' KGF-629 -- MATIZ', 0, NULL, NULL, '2013-03-18', '0.00', '0.00', '1'),
(264, '000264', 261, 293, ' ZNT-582 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(265, '000265', 262, 157, ' KDS-796 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-03-19', '0.00', '0.00', '1'),
(266, '000266', 263, 295, ' MAE-280 -- VOUGSUAGEN', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(267, '000267', 264, 243, ' GSI-813 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(268, '000268', 265, 297, ' ZTR-170 -- TOYOTA VIOS 1.3 2010', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(269, '000269', 266, 298, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-03-20', '0.00', '0.00', '1'),
(270, '000270', 267, 299, ' GTB-254 -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(271, '000271', 268, 300, ' KDX-177 -- HYUNDAI STAREX ''02', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(272, '000272', 269, 301, ' ZNY-414 -- NISSAN URBAN ''09', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(273, '000273', 270, 302, ' LDD-210 -- NISSAN SENTRA 97', 0, NULL, NULL, '2013-03-21', '0.00', '0.00', '1'),
(274, '000274', 271, 303, ' KDF-839 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-03-22', '0.00', '0.00', '1'),
(275, '000275', 272, 304, ' YFB-755 -- CHEVROLET LSI.5 AVIO', 0, NULL, NULL, '2013-03-22', '0.00', '0.00', '1'),
(276, '000276', 273, 285, ' PRI-747 -- TOYOTA VIOS', 0, NULL, NULL, '2013-03-22', '0.00', '0.00', '1'),
(277, '000277', 274, 306, ' XKU-437 -- HONDA CITY', 0, NULL, NULL, '2013-03-23', '0.00', '0.00', '1'),
(278, '000278', 275, 307, ' LMS-880 -- HYUNDAI STAREX ''02', 0, NULL, NULL, '2013-03-23', '0.00', '0.00', '1'),
(279, '000279', 276, 308, ' XAB-537 -- ISUZU CROSSWIND', 0, NULL, NULL, '2013-03-25', '0.00', '0.00', '1'),
(280, '000280', 258, 290, ' WDY-595 -- NISSAN CEFIRO', 0, NULL, NULL, '2013-03-25', '0.00', '0.00', '1'),
(281, '000281', 278, 310, ' KDN-427 -- FORD RANGER', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(282, '000282', 279, 311, ' NO PLATE -- TAMARAW FX', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(283, '000283', 280, 312, ' ZMR-406 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-03-26', '0.00', '0.00', '1'),
(284, '000284', 281, 313, ' LNG-327 -- HONDA CIVIC HATCHBACK', 0, NULL, NULL, '2013-03-30', '0.00', '0.00', '1'),
(285, '000285', 193, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-01', '0.00', '0.00', '1'),
(286, '000286', 193, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-01', '0.00', '0.00', '1'),
(287, '000287', 249, 281, ' NO PLATE -- HONDA CR-V', 0, NULL, NULL, '2013-04-01', '0.00', '0.00', '1'),
(288, '000288', 285, 317, ' KCK-301 -- TOYOTA HI-ACE', 0, NULL, NULL, '2013-04-02', '0.00', '0.00', '1'),
(289, '000289', 286, 318, ' KEP-900 -- HONDA JAZZ', 0, NULL, NULL, '2013-04-02', '0.00', '0.00', '1'),
(290, '000290', 287, 300, ' KDY-177 -- HYUNDAI STAREX', 0, NULL, NULL, '2013-04-02', '0.00', '0.00', '1'),
(291, '000291', 288, 320, ' TJV-567 -- NISSAN SENTRA', 0, NULL, NULL, '2013-04-03', '0.00', '0.00', '1'),
(292, '000292', 289, 321, ' KFL-939 -- KIA SORENTO', 0, NULL, NULL, '2013-04-05', '0.00', '0.00', '1'),
(293, '000293', 290, 297, ' ZTR-170 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-05', '0.00', '0.00', '1'),
(294, '000294', 291, 323, ' XHV-831 -- HONDA CR-V', 0, NULL, NULL, '2013-04-06', '0.00', '0.00', '1'),
(295, '000295', 292, 324, ' KEY-282 -- HYUNDAI STAREX', 0, NULL, NULL, '2013-04-08', '0.00', '0.00', '1'),
(296, '000296', 293, 325, ' GGV-946 -- HONDA CIVIC', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(297, '000297', 261, 293, ' ZNT-582 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(298, '000298', 205, 236, ' ZRW-466 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(299, '000299', 193, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(300, '000300', 297, 329, ' ZRN-459 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(301, '000301', 298, 330, ' NKO-749 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(302, '000302', 298, 330, ' NKO-749 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(303, '000303', 300, 332, ' ZTR-669 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(304, '000304', 301, 333, ' ZTR-669 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(305, '000305', 302, 334, ' ZLN-861 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(306, '000306', 302, 334, ' ZLN-861 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(307, '000307', 304, 293, ' ZNT-582 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(308, '000308', 305, 337, ' ZNT-582 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(309, '000309', 306, 338, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-10', '0.00', '0.00', '1'),
(310, '000310', 307, 339, ' TIP-991 -- TOYOTA VIOS 1.3 J M/T 2012', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(311, '000311', 308, 83, ' NOK-251 -- MITSUBISHI L200', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(312, '000312', 309, 341, ' KEL-874 -- NISSAN NAVARRA', 0, NULL, NULL, '2013-04-10', '0.00', '0.00', '1'),
(313, '000313', 310, 342, ' PVI-539 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-04-11', '0.00', '0.00', '1'),
(314, '000314', 287, 300, ' KDY-177 -- HYUNDAI STAREX', 0, NULL, NULL, '2013-04-11', '0.00', '0.00', '1'),
(315, '000315', 312, 344, ' KDC-286 -- FORD RANGER', 0, NULL, NULL, '2013-04-11', '0.00', '0.00', '1'),
(316, '000316', 273, 285, ' PRI-747 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-12', '0.00', '0.00', '1'),
(317, '000317', 314, 83, ' KVU- 621 -- MITSUBISHI CANTER ''08 6 WHEELERS', 0, NULL, NULL, '2013-04-12', '0.00', '0.00', '1'),
(318, '000318', 19, 42, ' ZLJ-948 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(319, '000319', 207, 237, ' PHO-378 -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-04-13', '0.00', '0.00', '1'),
(320, '000320', 317, 349, ' ZRC-290 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-04-13', '0.00', '0.00', '1'),
(321, '000321', 309, 341, ' KEL-874 -- NISSAN NAVARRA', 0, NULL, NULL, '2013-04-13', '0.00', '0.00', '1'),
(322, '000322', 319, 351, ' LCL-832 -- ISUZU FUEGO', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(323, '000323', 320, 352, ' XLV-984 -- MITSUBISHI ADVENTURE', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(324, '000324', 258, 290, ' WDY-595 -- NISSAN CEFIRO', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(325, '000325', 322, 45, ' KBP-657 -- DAIHATSU CHARADE', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(326, '000326', 323, 355, ' ZPU-212 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(327, '000327', 324, 356, ' XTF-691 -- NO MAKE', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(328, '000328', 214, 76, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-16', '0.00', '0.00', '1'),
(329, '000329', 326, 313, ' LNG-327 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(330, '000330', 327, 359, ' NOQ-707 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-04-16', '0.00', '0.00', '1'),
(331, '000331', 328, 360, ' XTF-691 -- NO MAKE', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(332, '000332', 329, 361, ' XTF-961 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-04-17', '0.00', '0.00', '1'),
(333, '000333', 330, 362, ' GDW-136 -- CIVIC ''93', 0, NULL, NULL, '2013-04-17', '0.00', '0.00', '1'),
(334, '000334', 331, 364, ' YJK-675 -- SUZUKI CELERIO', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(335, '000335', 319, 351, ' LCL-832 -- ISUZU FUEGO', 0, NULL, NULL, '2013-04-17', '0.00', '0.00', '1'),
(336, '000336', 322, 45, ' KBP-657 -- DAIHATSU CHARADE', 0, NULL, NULL, '2013-04-19', '0.00', '0.00', '1'),
(337, '000337', 334, 304, ' YFB-755 -- CHEVROLLET AVIO', 0, NULL, NULL, '2013-04-20', '0.00', '0.00', '1'),
(338, '000338', 302, 334, ' ZLN-861 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-20', '0.00', '0.00', '1'),
(339, '000339', 302, 334, ' ZLN-861 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-20', '0.00', '0.00', '1'),
(340, '000340', 302, 334, ' ZLN-861 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-04-20', '0.00', '0.00', '1'),
(341, '000341', 338, 371, ' KCD-519 -- ISUZU HI-LANDER', 0, NULL, NULL, '2013-04-22', '0.00', '0.00', '1'),
(342, '000342', 339, 372, ' GKZ-601 -- HONDA CIVIC', 0, NULL, NULL, '2013-04-22', '0.00', '0.00', '1'),
(343, '000343', 340, 373, ' WBG-922 -- SUZUKI SAMURAI', 0, NULL, NULL, '2013-04-23', '0.00', '0.00', '1'),
(344, '000344', 341, 374, ' KDN-353 -- HONDA CR-V', 0, NULL, NULL, '2013-04-24', '0.00', '0.00', '1'),
(345, '000345', 342, 375, ' NO PLATE -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-04-24', '0.00', '0.00', '1'),
(346, '000346', 343, 376, ' KGC-200 -- DAEWOO MATIZ', 0, NULL, NULL, '2013-04-25', '0.00', '0.00', '1'),
(347, '000347', 344, 377, ' HID-175 -- TOYOTA VIOS 2012', 0, NULL, NULL, '2013-04-25', '0.00', '0.00', '1'),
(348, '000348', 345, 313, ' NO PLATE -- HONDA HATCHBACK', 0, NULL, NULL, '2013-04-26', '0.00', '0.00', '1'),
(349, '000349', 346, 379, ' WJU-947 -- HONDA CITY 1999', 0, NULL, NULL, '2013-04-27', '0.00', '0.00', '1'),
(350, '000350', 347, 381, ' WEM-368 -- ISUZU HI-LANDER', 0, NULL, NULL, '2013-04-27', '0.00', '0.00', '1'),
(351, '000351', 348, 382, ' KDZ-156 -- HYUNDAI STAREX', 0, NULL, NULL, '2013-04-29', '0.00', '0.00', '1'),
(352, '000352', 349, 382, ' ZPC-471 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-29', '0.00', '0.00', '1'),
(353, '000353', 51, 76, ' OEV-356 -- TOYOTA HI-LUX ''95', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(354, '000354', 351, 311, ' KBY-537 -- TAMARAW FX', 0, NULL, NULL, '2013-04-30', '0.00', '0.00', '1'),
(355, '000355', 352, 386, ' KCG-917 -- NISSAN FRONTIER', 0, NULL, NULL, '2013-04-30', '0.00', '0.00', '1'),
(356, '000356', 353, 269, ' NOE-521 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-04-02', '0.00', '0.00', '1'),
(357, '000357', 354, 32, ' KDD-971 -- ISUZU DMAX', 0, NULL, NULL, '2013-04-02', '0.00', '0.00', '1'),
(358, '000358', 355, 389, ' KDR-243 -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-04-03', '0.00', '0.00', '1'),
(359, '000359', 356, 27, ' XBN-266 -- HONDA CIVIC VTEC', 0, NULL, NULL, '2013-04-04', '0.00', '0.00', '1'),
(360, '000360', 357, 391, ' UFT-620 -- ISUZU PICK-UP', 0, NULL, NULL, '2013-04-05', '0.00', '0.00', '1'),
(361, '000361', 358, 392, ' RDM-798 -- SUBARU', 0, NULL, NULL, '2013-04-05', '0.00', '0.00', '1'),
(362, '000362', 359, 393, ' WMD-562 -- NISSAN CEFIRO', 0, NULL, NULL, '2013-04-05', '0.00', '0.00', '1'),
(363, '000363', 360, 394, ' KCG-608 -- KIA PRIDE FORD', 0, NULL, NULL, '2013-04-06', '0.00', '0.00', '1'),
(364, '000364', 266, 298, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-06', '0.00', '0.00', '1'),
(365, '000365', 362, 330, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-06', '0.00', '0.00', '1'),
(366, '000366', 363, 397, ' ZNT-572 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(367, '000367', 363, 397, ' ZNT-572 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-04-10', '0.00', '0.00', '1'),
(368, '000368', 365, 399, ' KDY-259 -- NISSAN NAVARRA', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(369, '000369', 366, 400, ' GHX-665 -- HONDA CIVIC', 0, NULL, NULL, '2013-04-09', '0.00', '0.00', '1'),
(370, '000370', 367, 132, ' GGM-661 -- HONDA CIVIC HATCHBACK', 0, NULL, NULL, '2013-04-10', '0.00', '0.00', '1'),
(371, '000371', 368, 402, ' WMD-562 -- NISSAN CEFIRO', 0, NULL, NULL, '2013-04-10', '0.00', '0.00', '1'),
(372, '000372', 369, 161, ' KCS-463 -- ISUZU FUEGO', 0, NULL, NULL, '2013-04-11', '0.00', '0.00', '1'),
(373, '000373', 370, 404, ' XBO-900 -- HONDA CITY', 0, NULL, NULL, '2013-04-11', '0.00', '0.00', '1'),
(374, '000374', 371, 405, ' KCZ- 517 -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(375, '000375', 372, 243, ' KCV-231 -- NISSAN 4WD', 0, NULL, NULL, '2013-04-12', '0.00', '0.00', '1'),
(376, '000376', 373, 407, ' KDP-374 -- KIA AVILA', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(377, '000377', 375, 355, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-13', '0.00', '0.00', '1'),
(378, '000378', 376, 410, ' KCG-588 -- HONDA CITY 2006', 0, NULL, NULL, '2013-04-11', '0.00', '0.00', '1'),
(379, '000379', 377, 410, ' KCG-588 -- HONDA CITY', 0, NULL, NULL, '2013-04-24', '0.00', '0.00', '1'),
(380, '000380', 378, 412, ' KCZ-172 -- HONDA CITY', 0, NULL, NULL, '2013-04-15', '0.00', '0.00', '1'),
(381, '000381', 155, 171, ' XMR-211 -- Honda', 0, NULL, NULL, '2013-04-17', '0.00', '0.00', '1'),
(382, '000382', 369, 161, ' KCS-463 -- ISUZU FUEGO', 0, NULL, NULL, '2013-04-16', '0.00', '0.00', '1'),
(383, '000383', 381, 415, ' KDM-194 -- CHEVROLET AVEO', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(384, '000384', 382, 416, ' TLQ-940 -- TOYOTA VIOS', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(385, '000385', 383, 417, ' UKD-412 -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(386, '000386', 383, 417, ' UKD-412 -- HONDA CIVIC VTI', 0, NULL, NULL, '2013-04-18', '0.00', '0.00', '1'),
(387, '000387', 385, 419, ' GHR-704 -- HONDA CITY TYPE Z', 0, NULL, NULL, '2013-04-19', '0.00', '0.00', '1'),
(388, '000388', 386, 161, ' KCU-764 -- TOYOTA GRANDIA', 0, NULL, NULL, '2013-04-19', '0.00', '0.00', '1'),
(389, '000389', 388, 422, ' KDJ-539 -- HONDA CIVIC', 0, NULL, NULL, '2013-04-30', '0.00', '0.00', '1'),
(390, '000390', 389, 102, ' TIJ-622 -- TOYOTA VIOS 1.3 J M/T 2012', 0, NULL, NULL, '2013-04-22', '0.00', '0.00', '1'),
(391, '000391', 389, 102, ' TIJ-622 -- TOYOTA VIOS 1.3 J M/T 2012', 0, NULL, NULL, '2013-04-22', '0.00', '0.00', '1'),
(392, '000392', 391, 49, ' KDM-249 -- TOYOTA VIOS ''06', 0, NULL, NULL, '2013-04-23', '0.00', '0.00', '1'),
(393, '000393', 392, 426, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-24', '0.00', '0.00', '1'),
(394, '000394', 393, 402, ' WMD-562 -- NISSAN ', 0, NULL, NULL, '2013-04-25', '0.00', '0.00', '1'),
(395, '000395', 394, 428, ' WCG-849 -- HONDA CIVIC SiR ''99', 0, NULL, NULL, '2013-04-27', '0.00', '0.00', '1'),
(396, '000396', 395, 429, ' AJM-818 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-04-29', '0.00', '0.00', '1'),
(397, '000397', 396, 430, ' YBV-419 -- MAZDA MIYATA', 0, NULL, NULL, '2013-04-30', '0.00', '0.00', '1'),
(398, '000398', 397, 431, ' KDM-194 -- CHEVROLET', 0, NULL, NULL, '2013-04-30', '0.00', '0.00', '1'),
(399, '000399', 397, 431, ' KDM-194 -- CHEVROLET', 0, NULL, NULL, '2013-04-30', '0.00', '0.00', '1'),
(400, '000400', 398, 430, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-01', '0.00', '0.00', '1'),
(401, '000401', 399, 433, ' NO PLATE -- HONDA CIVIC HATCHBACK', 0, NULL, NULL, '2013-05-01', '0.00', '0.00', '1'),
(402, '000402', 400, 362, ' GDW-136 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-05-01', '0.00', '0.00', '1'),
(403, '000403', 319, 351, ' LCL-832 -- ISUZU FUEGO', 0, NULL, NULL, '2013-05-02', '0.00', '0.00', '1'),
(404, '000404', 402, 436, ' YJK-675 -- SUZUKI CELERIO', 0, NULL, NULL, '2013-05-02', '0.00', '0.00', '1'),
(405, '000405', 403, 437, ' GJG-536 -- HONDA CIVIC', 0, NULL, NULL, '2013-05-02', '0.00', '0.00', '1'),
(406, '000406', 404, 438, ' NO PLATE -- KIA SORENTO', 0, NULL, NULL, '2013-05-02', '0.00', '0.00', '1'),
(407, '000407', 405, 439, ' KDY-864 -- MITSUBISHI MONTERO', 0, NULL, NULL, '2013-05-02', '0.00', '0.00', '1'),
(408, '000408', 406, 440, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-05-03', '0.00', '0.00', '1'),
(409, '000409', 407, 441, ' NO PLATE -- NISSAN SENTRA', 0, NULL, NULL, '2013-05-03', '0.00', '0.00', '1'),
(410, '000410', 408, 443, ' KDJ-188 -- HONDA CITY', 0, NULL, NULL, '2013-05-03', '0.00', '0.00', '1'),
(411, '000411', 409, 444, ' KOV-297 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(412, '000412', 410, 445, ' FRT-808 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(413, '000413', 249, 281, ' NO PLATE -- HONDA CR-V', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(414, '000414', 412, 447, ' KCB-241 -- NISSAN FRONTIER', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(415, '000415', 413, 448, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(416, '000416', 414, 449, ' NO PLATE -- PICK-UP', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(417, '000417', 415, 450, ' KTU-553 --  Mitsubishi  ', 0, NULL, NULL, '2013-05-06', '0.00', '0.00', '1'),
(418, '000418', 416, 132, ' KCF-884 -- Honda', 0, NULL, NULL, '2013-05-06', '0.00', '0.00', '1'),
(419, '000419', 346, 379, ' WJU-947 -- HONDA CITY 1999', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(420, '000420', 349, 382, ' ZPC-471 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(421, '000421', 419, 454, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(422, '000422', 419, 454, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-04', '0.00', '0.00', '1'),
(423, '000423', 421, 76, ' OEV-356 -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(424, '000424', 422, 457, ' NO PLATE -- OFFROAD', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(425, '000425', 423, 458, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(426, '000426', 334, 304, ' YFB-755 -- CHEVROLLET AVIO', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(427, '000427', 425, 460, ' MFV-573 -- HONDA FIT', 0, NULL, NULL, '2013-05-07', '0.00', '0.00', '1'),
(428, '000428', 426, 461, ' RDW-648 -- TOYOTA HI-ACE', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(429, '000429', 427, 462, ' ZHT-951 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(430, '000430', 428, 463, ' TIG-509 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(431, '000431', 193, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(432, '000432', 430, 465, ' ZLN-871 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(433, '000433', 431, 466, ' PVI-539 -- TOYOTA VIOS 1.3 2010', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(434, '000434', 431, 466, ' PVI-539 -- TOYOTA VIOS 1.3 2010', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(435, '000435', 431, 466, ' PVI-539 -- TOYOTA VIOS 1.3 2010', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(436, '000436', 205, 236, ' ZRW-466 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(437, '000437', 435, 470, ' NAO-606 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(438, '000438', 436, 471, ' ZLJ--949 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(439, '000439', 437, 249, ' NKO-755 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(440, '000440', 438, 473, ' JCT-394 -- MITSUBISHI ELF', 0, NULL, NULL, '2013-05-08', '0.00', '0.00', '1'),
(441, '000441', 439, 474, ' KCM-313 -- MITSUBISHI PICK-UP', 0, NULL, NULL, '2013-05-09', '0.00', '0.00', '1'),
(442, '000442', 440, 122, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-09', '0.00', '0.00', '1'),
(443, '000443', 317, 349, ' ZRC-290 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-05-09', '0.00', '0.00', '1'),
(444, '000444', 442, 477, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-09', '0.00', '0.00', '1'),
(445, '000445', 412, 447, ' KCB-241 -- NISSAN FRONTIER', 0, NULL, NULL, '2013-05-10', '0.00', '0.00', '1'),
(446, '000446', 444, 479, ' KCD- 382 -- TOYOTA CORONA', 0, NULL, NULL, '2013-05-10', '0.00', '0.00', '1'),
(447, '000447', 445, 205, ' KCM-985 -- KIA PRIDE', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(448, '000448', 446, 429, ' AJM-818 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(449, '000449', 447, 249, ' NKO-755 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(450, '000450', 448, 483, ' NO PLATE -- MITSUBISHI MIRAGE', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(451, '000451', 428, 463, ' TIG-509 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(452, '000452', 450, 51, ' UIL-949 -- TOYOTA VIOS 2012', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(453, '000453', 451, 486, ' XRD-841 -- NISSAN SENTRA', 0, NULL, NULL, '2013-05-11', '0.00', '0.00', '1'),
(454, '000454', 452, 83, ' KVU-921 -- MITSUBISHI CANTER', 0, NULL, NULL, '2013-05-14', '0.00', '0.00', '1'),
(455, '000455', 453, 445, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-14', '0.00', '0.00', '1'),
(456, '000456', 454, 489, ' ZFU-359 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(457, '000457', 436, 471, ' ZLJ--949 -- TOYOTA VIOS L3J M/T 2008', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(458, '000458', 456, 471, ' WKO-676 -- FORD RANGER PICK-UP', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(459, '000459', 457, 491, ' NKO-676 -- FORD RANGER PICK-UP', 0, NULL, NULL, '2013-05-16', '0.00', '0.00', '1'),
(460, '000460', 458, 493, ' UEC-129 -- BMW', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(461, '000461', 459, 249, ' NKO-755 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(462, '000462', 460, 496, ' GHZ-724 -- TAMARAW FX', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(463, '000463', 376, 410, ' KCG-588 -- HONDA CITY 2006', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(464, '000464', 462, 498, ' NO PLATE -- TOYOTA COROLLA', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(465, '000465', 279, 311, ' NO PLATE -- TAMARAW FX', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(466, '000466', 464, 107, ' GTB-254 -- LANCER', 0, NULL, NULL, '2013-05-15', '0.00', '0.00', '1'),
(467, '000467', 465, 126, ' PMB-177 -- Toyota', 0, NULL, NULL, '2013-05-16', '0.00', '0.00', '1'),
(468, '000468', 466, 502, ' GMH-300 -- HONDA CIVIC', 0, NULL, NULL, '2013-05-16', '0.00', '0.00', '1'),
(469, '000469', 467, 503, ' XMV-471 -- HONDA CITY', 0, NULL, NULL, '2013-05-17', '0.00', '0.00', '1'),
(470, '000470', 467, 503, ' XMV-471 -- HONDA CITY', 0, NULL, NULL, '2013-05-17', '0.00', '0.00', '1'),
(471, '000471', 468, 504, ' GNW-680 -- HONDA CITY', 0, NULL, NULL, '2013-05-17', '0.00', '0.00', '1'),
(472, '000472', 469, 505, ' KCD- 382 -- TOYOTA ACCORD', 0, NULL, NULL, '2013-05-17', '0.00', '0.00', '1'),
(473, '000473', 412, 447, ' KCB-241 -- NISSAN FRONTIER', 0, NULL, NULL, '2013-05-17', '0.00', '0.00', '1'),
(474, '000474', 471, 493, ' NO PLATE -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-05-18', '0.00', '0.00', '1'),
(475, '000475', 472, 298, ' ZNK-416 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-05-18', '0.00', '0.00', '1'),
(476, '000476', 473, 509, ' YEP-253 -- KIA SEPHIA', 0, NULL, NULL, '2013-05-18', '0.00', '0.00', '1'),
(477, '000477', 474, 313, ' ZNG-327 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-05-18', '0.00', '0.00', '1'),
(478, '000478', 132, 162, ' ZPU-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(479, '000479', 476, 512, ' ZJK-716 -- HYUNDAI GETZ ''07', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(480, '000480', 477, 513, ' TIR-586 -- TOYOTA VIOS 2011', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(481, '000481', 478, 304, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(482, '000482', 479, 515, ' PQM-689 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(483, '000483', 480, 516, ' NO PLATE -- MITSUBISHI CANTER', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1');
INSERT INTO `joborder` (`jo_id`, `jo_number`, `v_id`, `customer`, `plate`, `color`, `contactnumber`, `address`, `trnxdate`, `tax`, `discount`, `status`) VALUES
(484, '000484', 482, 517, ' NO PLATE -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(485, '000485', 483, 297, ' ZTR-170 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(486, '000486', 484, 519, ' TBQ-160 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(487, '000487', 485, 520, ' PKQ-767 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(488, '000488', 193, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(489, '000489', 487, 522, ' ZEJ--821 -- HONDA CIVIC', 0, NULL, NULL, '2013-05-24', '0.00', '0.00', '1'),
(490, '000490', 488, 523, ' XRU-889 -- ISUZU FUEGO', 0, NULL, NULL, '2013-05-24', '0.00', '0.00', '1'),
(491, '000491', 489, 524, ' ZNT-269 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(492, '000492', 490, 525, ' NVO-264 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(493, '000493', 491, 526, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(494, '000494', 492, 503, ' XMV-417 -- HONDA CITY', 0, NULL, NULL, '2013-05-20', '0.00', '0.00', '1'),
(495, '000495', 493, 528, ' NO PLATE -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-21', '0.00', '0.00', '1'),
(496, '000496', 494, 325, ' GGV-946 -- HONDA CIVIC', 0, NULL, NULL, '2013-05-21', '0.00', '0.00', '1'),
(497, '000497', 495, 45, ' KBP-657 -- DAIHATSU CHARADE', 0, NULL, NULL, '2013-05-21', '0.00', '0.00', '1'),
(498, '000498', 496, 531, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-21', '0.00', '0.00', '1'),
(499, '000499', 497, 243, ' GTS-813 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-05-21', '0.00', '0.00', '1'),
(500, '000500', 498, 533, ' ZJP-470 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-05-22', '0.00', '0.00', '1'),
(501, '000501', 499, 534, ' GTS-798 -- MULTICAB', 0, NULL, NULL, '2013-05-22', '0.00', '0.00', '1'),
(502, '000502', 500, 535, ' KEC-213 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-05-23', '0.00', '0.00', '1'),
(503, '000503', 501, 536, ' NO PLATE -- KIA PRIDE', 0, NULL, NULL, '2013-05-24', '0.00', '0.00', '1'),
(504, '000504', 502, 537, ' JCL-656 -- HYUNDAI STAREX', 0, NULL, NULL, '2013-05-24', '0.00', '0.00', '1'),
(505, '000505', 503, 212, ' GEV-976 -- MITSUBISHI GALANT', 0, NULL, NULL, '2013-05-24', '0.00', '0.00', '1'),
(506, '000506', 504, 523, ' YRM-889 -- ISUZU FUEGO', 0, NULL, NULL, '2013-05-24', '0.00', '0.00', '1'),
(507, '000507', 505, 124, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(508, '000508', 506, 540, ' ZKP-420 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(509, '000509', 507, 78, ' ZKP-920 -- HONDA CITY 2008 1.5V M', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(510, '000510', 508, 449, ' NO PLATE -- MAZDA PICK-UP', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(511, '000511', 509, 544, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(512, '000512', 510, 545, ' NO PLATE -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(513, '000513', 511, 445, ' FRT-808 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(514, '000514', 512, 547, ' SHJ-237 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-05-27', '0.00', '0.00', '1'),
(515, '000515', 513, 548, ' KDN-181 -- TOYOTA FORTUNER', 0, NULL, NULL, '2013-05-27', '0.00', '0.00', '1'),
(516, '000516', 514, 549, ' UGN-620 -- HONDA CIVIC', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(517, '000517', 25, 48, ' ZKP-920 -- HONDA CITY VTEC', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(518, '000518', 516, 551, ' YAA-663 -- FORD RANGER', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(519, '000519', 517, 397, ' KDE-266 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(520, '000520', 518, 553, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-25', '0.00', '0.00', '1'),
(521, '000521', 519, 553, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(522, '000522', 520, 76, ' EOV-356 -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(523, '000523', 521, 556, ' PQO-122 -- TOYOTA VIOS 2011 1.3 J M/T', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(524, '000524', 522, 330, ' NKO-749 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-05-28', '0.00', '0.00', '1'),
(525, '000525', 523, 558, ' TQG-966 -- TOYOTA VIOS 2012', 0, NULL, NULL, '2013-05-29', '0.00', '0.00', '1'),
(526, '000526', 524, 559, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-05-29', '0.00', '0.00', '1'),
(527, '000527', 525, 498, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-29', '0.00', '0.00', '1'),
(528, '000528', 526, 561, ' NO PLATE -- HYUNDAI STAREX', 0, NULL, NULL, '2013-05-29', '0.00', '0.00', '1'),
(529, '000529', 527, 562, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(530, '000530', 528, 563, ' UIJ-175 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-27', '0.00', '0.00', '1'),
(531, '000531', 529, 564, ' KDE-266 -- TOYOTA INNOVA', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(532, '000532', 523, 558, ' TQG-966 -- TOYOTA VIOS 2012', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(533, '000533', 532, 325, ' GGV-946 -- HONDA CIVIC', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(534, '000534', 533, 567, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(535, '000535', 534, 562, ' PDQ-660 -- TOYOTA VIOS 2011', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(536, '000536', 535, 397, ' ZNT-572 -- TOYOTA VIOS', 0, NULL, NULL, '2013-05-30', '0.00', '0.00', '1'),
(537, '000537', 536, 570, ' NO PLATE -- TOYOTA HI-ACE', 0, NULL, NULL, '2013-05-31', '0.00', '0.00', '1'),
(538, '000538', 537, 489, ' ZFU-359 -- HYUNDAI GETZ', 0, NULL, NULL, '2013-05-31', '0.00', '0.00', '1'),
(539, '000539', 538, 503, ' NO PLATE -- HONDA CITY', 0, NULL, NULL, '2013-05-31', '0.00', '0.00', '1'),
(540, '000540', 539, 107, ' GTB-254 -- MITSUBISHI LANCER', 0, NULL, NULL, '2013-05-31', '0.00', '0.00', '1'),
(541, '000541', 541, 32, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-04-02', '0.00', '0.00', '1'),
(542, '000542', 542, 576, ' NO PLATE -- TOYOTA VIOS', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(543, '000543', 543, 577, ' NO PLATE -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(544, '000544', 544, 578, ' KDJ-589 -- FORD EVEREST', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(545, '000545', 545, 290, ' NO PLATE -- NISSAN CEFIRO', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(546, '000546', 546, 580, ' NO PLATE -- SUZUKI CELERIO', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(547, '000547', 547, 581, ' NO PLATE -- HONDA CITY', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(548, '000548', 548, 582, ' TJK-332 -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(549, '000549', 549, 86, ' NO PLATE -- TOYOTA VIOS', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(550, '000550', 549, 86, ' NO PLATE -- TOYOTA VIOS', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(551, '000551', 550, 320, ' TJV-569 -- NISSAN SENTRA', 0, NULL, NULL, '2013-06-03', '0.00', '0.00', '1'),
(552, '000552', 551, 83, ' TFO-924 -- MITSUBISHI L300', 0, NULL, NULL, '2013-06-03', '0.00', '0.00', '1'),
(553, '000553', 552, 163, ' PIX-852 -- TOYOTA VIOS 2011 1.3 J M/T', 0, NULL, NULL, '2013-06-03', '0.00', '0.00', '1'),
(554, '000554', 553, 516, ' NO PLATE -- MITSUBISHI CANTER', 0, NULL, NULL, '2013-06-03', '0.00', '0.00', '1'),
(555, '000555', 554, 588, ' NO PLATE -- HYUNDAI ACCENT', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(556, '000556', 555, 589, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-05', '0.00', '0.00', '1'),
(557, '000557', 556, 449, ' NO PLATE -- MAZDA PICK-UP', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(558, '000558', 557, 591, ' XFU-516 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(559, '000559', 558, 523, ' PRJ-223 -- TOYOTA COROLLA', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(560, '000560', 559, 593, ' NO PLATE -- HONDA CIVIC ESI', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(561, '000561', 560, 594, ' NGO-544 -- ISUZU ELF', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(562, '000562', 561, 531, ' ZMF-287 -- HONDA CIVIC', 0, NULL, NULL, '2013-06-04', '0.00', '0.00', '1'),
(563, '000563', 562, 528, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-05', '0.00', '0.00', '1'),
(564, '000564', 563, 313, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-06-05', '0.00', '0.00', '1'),
(565, '000565', 564, 158, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-06-05', '0.00', '0.00', '1'),
(566, '000566', 565, 498, ' NO PLATE -- TOYOTA COROLLA', 0, NULL, NULL, '2013-06-05', '0.00', '0.00', '1'),
(567, '000567', 566, 600, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(568, '000568', 567, 551, ' KBX-946 -- TOYOTA HI-ACE', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(569, '000569', 568, 602, ' TQG-966 -- TOYOTA VIOS 2012', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(570, '000570', 569, 602, ' TQG-966 -- TOYOTA VIOS 2012', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(571, '000571', 570, 604, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(572, '000572', 571, 605, ' WTM-699 -- Honda', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(573, '000573', 572, 126, ' NO PLATE -- TOYOTA COROLLA', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(574, '000574', 573, 607, ' NO PLATE -- HYUNDAI STAREX', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(575, '000575', 574, 608, ' UGN-811 -- HONDA ACCORD', 0, NULL, NULL, '2013-06-06', '0.00', '0.00', '1'),
(576, '000576', 575, 609, ' NO PLATE -- KIA PRIDE', 0, NULL, NULL, '2013-06-01', '0.00', '0.00', '1'),
(577, '000577', 576, 610, ' NO PLATE -- HYUNDAI GETZ', 0, NULL, NULL, '2013-06-07', '0.00', '0.00', '1'),
(578, '000578', 577, 51, ' NOL-541 -- TOYOTA VIOS', 0, NULL, NULL, '2013-06-07', '0.00', '0.00', '1'),
(579, '000579', 578, 612, ' NO PLATE -- HONDA CITY', 0, NULL, NULL, '2013-06-07', '0.00', '0.00', '1'),
(580, '000580', 579, 613, ' YHR- 804 -- SUZUKI SWIFT', 0, NULL, NULL, '2013-06-07', '0.00', '0.00', '1'),
(581, '000581', 580, 614, ' UAW-453 -- HONDA CIVIC HATCHBACK', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(582, '000582', 581, 70, ' YDF-296 -- ISUZU CROSSWIND', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(583, '000583', 582, 616, ' KCZ-897 -- TOYOTA VIOS', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(584, '000584', 583, 70, ' GGC-849 -- FORWARDER', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(585, '000585', 584, 397, ' NO PLATE -- TOYOTA AVANZA', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(586, '000586', 585, 619, ' KCD-749 -- ISUZU HI-LANDER', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(587, '000587', 586, 448, ' NO PLATE -- MULTICAB', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(588, '000588', 587, 577, ' KCM-313 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-06-08', '0.00', '0.00', '1'),
(589, '000589', 588, 622, ' YEY-812 -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-06-10', '0.00', '0.00', '1'),
(590, '000590', 589, 623, ' JBS-789 -- HONDA HATCHBACK', 0, NULL, NULL, '2013-06-10', '0.00', '0.00', '1'),
(591, '000591', 590, 624, ' KDD-568 -- HONDA CITY', 0, NULL, NULL, '2013-06-10', '0.00', '0.00', '1'),
(593, '000592', 591, 625, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-06-11', '0.00', '0.00', '1'),
(594, '000594', 592, 626, ' UME-778 -- HONDA CIVIC', 0, NULL, NULL, '2013-06-11', '0.00', '0.00', '1'),
(595, '000595', 593, 402, ' NO PLATE -- NISSAN CEFIRO', 0, NULL, NULL, '2013-06-11', '0.00', '0.00', '1'),
(596, '000596', 595, 628, ' MFB-115 -- CHEVROLET', 0, NULL, NULL, '2013-06-11', '0.00', '0.00', '1'),
(597, '000597', 596, 629, ' NO PLATE -- HONDA HATCHBACK', 0, NULL, NULL, '2013-06-12', '0.00', '0.00', '1'),
(598, '000598', 597, 630, ' NO PLATE -- Honda', 0, NULL, NULL, '2013-06-12', '0.00', '0.00', '1'),
(599, '000599', 598, 631, ' NO PLATE -- PRELOAD', 0, NULL, NULL, '2013-06-13', '0.00', '0.00', '1'),
(600, '000600', 599, 83, ' NQV-326 -- MITSUBISHI L300', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(601, '000601', 600, 633, ' NVO-797 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(602, '000602', 601, 634, ' NOI-292 -- TOYOTA VIOS 1.3 2007', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(603, '000603', 602, 524, ' ZNT-269 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(604, '000604', 603, 470, ' NAO-606 -- TOYOTA VIOS 2009', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(605, '000605', 604, 637, ' ZNE-322 -- TOYOTA VIOS', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(606, '000606', 605, 42, ' ZLJ-949 -- TOYOTA VIOS 1.3 2008', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(607, '000607', 606, 345, ' PVI-747 -- TOYOTA VIOS -2010', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(608, '000608', 607, 297, ' ZTR-170 -- TOYOTA VIOS 1.3 2010', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(609, '000609', 608, 577, ' KCM-313 -- MITSUBISHI STRADA', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(610, '000610', 609, 642, ' NO PLATE -- MITSUBISHI PAJERO', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(611, '000611', 610, 574, ' NO PLATE -- HONDA HATCHBACK', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(612, '000612', 611, 329, ' ZRW-459 -- TOYOTA VIOS 2008', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(613, '000613', 520, 76, ' EOV-356 -- TOYOTA HI-LUX', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(614, '000614', 613, 613, ' YHR- 804 -- SUZUKI SWIFT 1.5 HATCHBACK', 0, NULL, NULL, '2013-06-14', '0.00', '0.00', '1'),
(615, '000615', 614, 647, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-15', '0.00', '0.00', '1'),
(616, '000616', 615, 648, ' KCL-456 -- HONDA CIVIC', 0, NULL, NULL, '2013-06-15', '0.00', '0.00', '1'),
(617, '000617', 616, 321, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-15', '0.00', '0.00', '1'),
(618, '000618', 617, 650, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-06-17', '0.00', '0.00', '1'),
(619, '000619', 618, 163, ' PIX-852 -- TOYOTA VIOS 2011', 0, NULL, NULL, '2013-06-17', '0.00', '0.00', '1'),
(620, '000620', 619, 147, ' NO PLATE -- HONDA CITY', 0, NULL, NULL, '2013-06-17', '0.00', '0.00', '1'),
(621, '000621', 620, 653, ' KCP-212 -- SUBARU', 0, NULL, NULL, '2013-06-17', '0.00', '0.00', '1'),
(622, '000622', 621, 448, ' KEN-524 -- MULTICAB', 0, NULL, NULL, '2013-06-18', '0.00', '0.00', '1'),
(623, '000623', 622, 604, ' NO PLATE -- HONDA CIVIC', 0, NULL, NULL, '2013-06-18', '0.00', '0.00', '1'),
(624, '000624', 623, 656, ' NO PLATE -- TOYOTA COROLLA', 0, NULL, NULL, '2013-06-18', '0.00', '0.00', '1'),
(625, '000625', 624, 657, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-18', '0.00', '0.00', '1'),
(626, '000626', 625, 402, ' WMD--562 -- NISSAN CEFIRO', 0, NULL, NULL, '2013-06-19', '0.00', '0.00', '1'),
(627, '000627', 626, 659, ' NO PLATE -- HONDA ACCORD', 0, NULL, NULL, '2013-06-19', '0.00', '0.00', '1'),
(628, '000628', 627, 660, ' NO PLATE -- NO MAKE', 0, NULL, NULL, '2013-06-19', '0.00', '0.00', '1'),
(629, '000629', 628, 582, ' NO PLATE -- HONDA FSI', 0, NULL, NULL, '2013-06-19', '0.00', '0.00', '1'),
(630, '000630', 629, 662, ' KDV-590 -- KIA VAN', 0, NULL, NULL, '2013-06-19', '0.00', '0.00', '1'),
(631, '000631', 630, 663, ' TKO-820 -- TOYOTA VIOS 1.3 J M/T 2012', 0, NULL, NULL, '2013-06-20', '0.00', '0.00', '1'),
(632, '000632', 631, 206, ' NO PLATE -- ATOZ', 0, NULL, NULL, '2013-06-20', '0.00', '0.00', '1'),
(633, '000633', 632, 665, ' NO PLATE -- SPORTAGE', 0, NULL, NULL, '2013-06-20', '0.00', '0.00', '1'),
(634, '000634', 633, 666, ' NO PLATE -- ISUZU FUEGO', 0, NULL, NULL, '2013-06-20', '0.00', '0.00', '1'),
(635, '000635', 634, 667, ' NO PLATE -- HONDA CITY', 0, NULL, NULL, '2013-06-20', '0.00', '0.00', '1'),
(636, '000636', 634, 667, ' NO PLATE -- HONDA CITY', 0, NULL, NULL, '2013-06-20', '0.00', '0.00', '1');

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
(70, 160, '', '', '50000.00', '1'),
(71, 116, '', '', '150.00', '1'),
(71, 161, '', '', '1200.00', '1'),
(71, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(71, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(40, 62, '', '', '1810.00', '1'),
(72, 162, '', '', '950.00', '1'),
(73, 163, '', '', '450.00', '1'),
(73, 0, '1PC. ALTERNATOR ASSY', '', '9000.00', '1'),
(73, 0, 'ATF 2', '', '520.00', '1'),
(74, 164, NULL, '', '7650.00', '1'),
(74, 167, '', '', '3000.00', '1'),
(75, 168, '', '', '150.00', '1'),
(76, 116, '', '', '150.00', '1'),
(76, 49, '', '', '250.00', '1'),
(76, 72, '', '', '150.00', '1'),
(77, 170, '', '', '150.00', '1'),
(77, 0, '1PC. RADIATOR HOSE', '', '350.00', '1'),
(77, 0, 'BRAKE FLUID', '', '100.00', '1'),
(78, 171, '', '', '300.00', '1'),
(78, 172, '', '', '2936.25', '1'),
(79, 173, '', '', '1500.00', '1'),
(79, 174, '', '', '300.00', '1'),
(79, 175, '', '', '600.00', '1'),
(79, 0, '1PC. HUB BEARING FRT LH', '', '1800.00', '1'),
(80, 62, '', '', '42108.75', '1'),
(81, 176, '', '', '1200.00', '1'),
(81, 177, '', '', '300.00', '1'),
(82, 116, '', '', '150.00', '1'),
(82, 0, '5LTRS. ENGINE OIL', '', '1575.00', '1'),
(82, 0, '1PC. OIL FILTER', '', '650.00', '1'),
(83, 127, '', '', '1300.00', '1'),
(83, 0, '1PC. CLUTCH COVER', '', '3250.00', '1'),
(83, 0, '1PC. RELEASE BEARING', '', '1105.00', '1'),
(83, 0, '1LTR. GEAR OIL', '', '230.00', '1'),
(84, 180, '', '', '650.00', '1'),
(84, 181, '', '', '50.00', '1'),
(84, 182, '', '', '1500.00', '1'),
(84, 184, '', '', '400.00', '1'),
(84, 0, '1PC. WEDGE BULB', '', '25.00', '1'),
(84, 0, '16PCS. VALVE SEAL(NOK)', '', '640.00', '1'),
(84, 0, '1PC. STOPLIGHT SWITCH', '', '150.00', '1'),
(85, 185, '', '', '500.00', '1'),
(85, 186, '', '', '150.00', '1'),
(85, 187, '', '', '250.00', '1'),
(85, 0, 'CONTACT POINT ', '', '230.00', '1'),
(86, 49, '', '', '250.00', '1'),
(86, 188, '', '', '250.00', '1'),
(86, 0, '1PC WINDOW GLASS', '', '2800.00', '1'),
(86, 0, 'FREIGHT', '', '587.33', '1'),
(87, 62, '', '', '6150.00', '1'),
(88, 0, 'CHARGE INVOICE', '', '16950.00', '1'),
(89, 0, 'CHARGE INVOICE#2368', '', '2666.00', '1'),
(90, 116, '', '', '150.00', '1'),
(90, 189, '', '', '800.00', '1'),
(90, 0, '4LTRS. ENGINE OIL', '', '950.00', '1'),
(90, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(90, 0, '1LTR. COOLANT', '', '150.00', '1'),
(91, 190, '', '', '2100.00', '1'),
(91, 191, '', '', '100.00', '1'),
(92, 192, '', '', '150.00', '1'),
(92, 193, '', '', '100.00', '1'),
(92, 0, '1PC. SIDE MIRROR', '', '800.00', '1'),
(93, 194, '', '', '400.00', '1'),
(93, 195, '', '', '350.00', '1'),
(93, 0, '1PC. TIRE 175/65/R14 FRT.LH', '', '3680.00', '1'),
(93, 0, '1PC. TIRE 175/65/R14 FRT RH', '', '3680.00', '1'),
(93, 0, '1PC. TIRE 175/65/R14 REAR RH', '', '3680.00', '1'),
(93, 0, '1PC. TIRE 175/65/R14 REAR LH', '', '3680.00', '1'),
(94, 116, '', '', '150.00', '1'),
(94, 106, '', '', '250.00', '1'),
(94, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(94, 0, '4PCS. SPARK PLUG', '', '640.00', '1'),
(94, 0, '1 GAL. ENGINE OIL', '', '890.00', '1'),
(94, 0, '1PC. AIR FILTER', '', '595.00', '1'),
(94, 0, '1QRT. COOLANT', '', '215.00', '1'),
(95, 130, '', '', '350.00', '1'),
(95, 0, '1SET SHROUD MOTOR ASSEMBLY WITH BLADE', '', '4900.00', '1'),
(96, 71, '', '', '150.00', '1'),
(96, 196, '', '', '250.00', '1'),
(96, 72, '', '', '150.00', '1'),
(96, 0, '8PCS. SPARK PLUG', '', '960.00', '1'),
(96, 0, '1PC. OIL FILTER', '', '300.00', '1'),
(96, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(96, 0, '1 GA. CVT FLUID', '', '2450.00', '1'),
(97, 197, '', '', '950.00', '1'),
(98, 198, '', '', '250.00', '1'),
(98, 116, '', '', '150.00', '1'),
(98, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(98, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(99, 199, '', '', '250.00', '1'),
(99, 200, '', '', '350.00', '1'),
(99, 0, '1PC. FAN BELT', '', '960.00', '1'),
(99, 0, '1SET FOG LAMP', '', '4500.00', '1'),
(100, 145, '', '', '250.00', '1'),
(100, 201, '', '', '350.00', '1'),
(100, 202, '', '', '900.00', '1'),
(100, 203, '', '', '1000.00', '1'),
(100, 204, '', '', '600.00', '1'),
(100, 0, '1PC. DRIVE BELT', '', '960.00', '1'),
(100, 0, '2PCS. OUTER CV JOINT LH/RH', '', '7600.00', '1'),
(100, 0, '1PC. FRONT BUMPER RETAINER', '', '3200.00', '1'),
(100, 0, '1PC. AUXILLIARY FAN ASSEMBLY', '', '4900.00', '1'),
(101, 116, '', '', '150.00', '1'),
(101, 49, '', '', '250.00', '1'),
(101, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(101, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(101, 0, '1PC. AIR FILTER', '', '714.00', '1'),
(101, 0, '4PCS. SPARK PLUG', '', '936.00', '1'),
(101, 0, '1QRT.COOLANT', '', '350.00', '1'),
(102, 116, '', '', '150.00', '1'),
(102, 49, '', '', '250.00', '1'),
(102, 199, '', '', '250.00', '1'),
(102, 75, '', '', '350.00', '1'),
(102, 207, '', '', '350.00', '1'),
(102, 209, '', '', '400.00', '1'),
(102, 208, '', '', '350.00', '1'),
(102, 210, '', '', '400.00', '1'),
(102, 211, '', '', '350.00', '1'),
(102, 212, '', '', '1000.00', '1'),
(102, 0, '1GAL ENGINE OIL', '', '950.00', '1'),
(102, 0, '1PC. OIL FILTER', '', '230.00', '1'),
(102, 0, '1PC. AIR FILTER', '', '695.00', '1'),
(102, 0, '4PCS. SPARK PLUG', '', '936.00', '1'),
(102, 0, '1QRT. COOLANT', '', '350.00', '1'),
(102, 0, '1PC. FAN BELT', '', '960.00', '1'),
(102, 0, '2PCS. LOWER ARM BUSHING FRONT(BIG)', '', '880.00', '1'),
(102, 0, '2PCS. LOWER ARM BUSHING RH/LH', '', '700.00', '1'),
(102, 0, '2PCS. STABILIZER BAR BUSHING RH/LH', '', '360.00', '1'),
(102, 0, '1SET BRAKE PADS', '', '1380.00', '1'),
(103, 213, '', '', '450.00', '1'),
(103, 214, '', '', '650.00', '1'),
(103, 0, '1PC. RELAY W/ SOCKET', '', '160.00', '1'),
(103, 0, '2PCS. TIE WRAP', '', '20.00', '1'),
(104, 217, '', '', '1500.00', '1'),
(104, 218, '', '', '150.00', '1'),
(105, 219, '', '', '1500.00', '1'),
(105, 115, '', '', '1800.00', '1'),
(105, 220, '', '', '300.00', '1'),
(105, 221, '', '', '3000.00', '1'),
(105, 222, '', '', '350.00', '1'),
(105, 53, '', '', '2500.00', '1'),
(105, 223, '', '', '800.00', '1'),
(105, 224, '', '', '950.00', '1'),
(105, 225, '', '', '500.00', '1'),
(105, 0, '5KLS. FUSHING FLUID', '', '1400.00', '1'),
(105, 0, '1PC. EXPANSION VALVE', '', '950.00', '1'),
(105, 0, '1PC. DRIER', '', '1200.00', '1'),
(105, 0, '1PC.BRAKE CALIPER ASSY', '', '8000.00', '1'),
(105, 0, 'BRAKE FLUID', '', '100.00', '1'),
(105, 0, '2PCS. FUSE', '', '22.00', '1'),
(105, 0, 'CLEANING SOLVENT', '', '100.00', '1'),
(105, 0, '1PC. SOLENOID SWITCH', '', '1500.00', '1'),
(106, 0, 'FUEL INJECTOR TYPE ', '', '1400.00', '1'),
(107, 0, 'CHARGE INVOICE#2374', '', '43000.00', '1'),
(108, 226, '', '', '12800.00', '1'),
(108, 227, '', '', '1500.00', '1'),
(108, 228, '', '', '890.00', '1'),
(108, 229, '', '', '1500.00', '1'),
(108, 230, '', '', '1500.00', '1'),
(108, 231, '', '', '1200.00', '1'),
(108, 232, '', '', '1200.00', '1'),
(108, 0, '1PC. CARRIER ASSY SPARETIRE', '', '32900.17', '1'),
(108, 0, '2PCS. WINDSHIELD SEALANT URETHANE 3M', '', '1800.00', '1'),
(109, 233, '', '', '6000.00', '1'),
(109, 0, '10PCS. MUD GUARD CLIPS', '', '360.00', '1'),
(110, 234, '', '', '150.00', '1'),
(110, 235, '', '', '100.00', '1'),
(110, 236, '', '', '2000.00', '1'),
(110, 237, '', '', '2500.00', '1'),
(110, 115, '', '', '1000.00', '1'),
(110, 71, '', '', '150.00', '1'),
(110, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(110, 0, 'BRAKE FLUID', '', '200.00', '1'),
(110, 0, '1QRT ATF', '', '260.00', '1'),
(111, 238, '', '', '1500.00', '1'),
(111, 0, '1 UNIT TRANSMISSION', '', '35000.00', '1'),
(111, 0, 'FREIGHT', '', '2490.21', '1'),
(111, 0, '4HR.ATF', '', '1040.00', '1'),
(111, 0, '5HR. AFT', '', '1300.00', '1'),
(112, 239, '', '', '2600.00', '1'),
(113, 240, '', '', '3566.00', '1'),
(114, 241, '', '', '350.00', '1'),
(114, 242, '', '', '500.00', '1'),
(114, 0, '1PC. BALLJOINT RH', '', '980.00', '1'),
(114, 0, 'VOLT', '', '84.00', '1'),
(115, 244, '', '', '150.00', '1'),
(115, 0, '1PC. RUBBER VALVE', '', '30.00', '1'),
(116, 245, '', '', '250.00', '1'),
(117, 0, 'CHARGE INVOICE #1671', '', '7700.00', '1'),
(118, 0, 'CHARGE INVOICE#2379', '', '5004.00', '1'),
(119, 0, 'CHARGE INVOICE # 2373', '', '10664.00', '1'),
(120, 246, '', '', '250.00', '1'),
(120, 155, '', '', '650.00', '1'),
(121, 247, '', '', '350.00', '1'),
(121, 25, '', '', '100.00', '1'),
(121, 248, '', '', '450.00', '1'),
(121, 0, '1PC. FUEL FILTER', '', '70.00', '1'),
(121, 0, 'FUEL', '', '300.00', '1'),
(122, 249, '', '', '800.00', '1'),
(122, 0, '1 SET ALARM', '', '1500.00', '1'),
(123, 41, '', '', '350.00', '1'),
(124, 194, '', '', '200.00', '1'),
(124, 195, '', '', '350.00', '1'),
(124, 0, '4PCS. TIRE 175/65/14', '', '14720.00', '1'),
(125, 0, 'CHARGE INVOICE #2376', '', '4600.00', '1'),
(126, 0, 'CHARGE INVOICE#2380', '', '1000.00', '1'),
(127, 251, '', '', '1500.00', '1'),
(127, 129, '', '', '250.00', '1'),
(127, 128, '', '', '300.00', '1'),
(127, 91, '', '', '300.00', '1'),
(127, 252, '', '', '300.00', '1'),
(127, 253, '', '', '100.00', '1'),
(127, 255, '', '', '100.00', '1'),
(127, 254, '', '', '350.00', '1'),
(127, 0, '1SET TIEROD END', '', '1600.00', '1'),
(127, 0, '1SET RACK END', '', '1500.00', '1'),
(127, 0, '1PC POWER STEERING BOOTS', '', '380.00', '1'),
(127, 0, '1SET STEERING RACK REPAIR', '', '3800.00', '1'),
(127, 0, '1SET BRAKE PADS', '', '1400.00', '1'),
(127, 0, '1PC. HEADLIGHT BULB', '', '180.00', '1'),
(127, 0, '1LTR. ATF', '', '260.00', '1'),
(127, 0, 'BRAKE FLUID', '', '50.00', '1'),
(127, 0, '1PC POWER STEERING HOSE', '', '1800.00', '1'),
(128, 116, '', '', '150.00', '1'),
(128, 258, '', '', '50.00', '1'),
(128, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(128, 0, '1PC. AIR FILTER', '', '1400.00', '1'),
(128, 0, '5HRS. SEMISYNTHETIC', '', '1575.00', '1'),
(129, 62, '', '', '118716.00', '1'),
(130, 116, '', '', '150.00', '1'),
(130, 0, '1PC. OIL FILTER', '', '390.00', '1'),
(130, 0, '6HRS. ENGINE OIL', '', '1380.00', '1'),
(131, 119, '', '', '1100.00', '1'),
(131, 116, '', '', '150.00', '1'),
(131, 0, '1PC HEAD GASKET(ORING)', '', '1280.00', '1'),
(131, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(131, 0, 'OIL FILTER', '', '290.00', '1'),
(131, 0, 'CLEANING SOLVENT', '', '50.00', '1'),
(132, 195, '', '', '350.00', '1'),
(132, 0, '4PCS. TIRES 205/45/17 @ 4200', '', '16400.00', '1'),
(133, 259, '', '', '1500.00', '1'),
(134, 62, '', '', '51954.00', '1'),
(135, 116, '', '', '150.00', '1'),
(135, 49, '', '', '250.00', '1'),
(135, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(135, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(135, 0, '1PC. AIR FILTER', '', '695.00', '1'),
(135, 0, '4PCS. SPARK PLUG', '', '680.00', '1'),
(135, 0, '1QRT. COOLANT', '', '350.00', '1'),
(136, 194, '', '', '400.00', '1'),
(136, 195, '', '', '450.00', '1'),
(136, 0, '4PCS. TIRE 175/65/R14', '', '14720.00', '1'),
(137, 260, '', '', '350.00', '1'),
(137, 0, '1 LTR. ATF', '', '260.00', '1'),
(138, 261, '', '', '1500.00', '1'),
(138, 263, '', '', '800.00', '1'),
(138, 0, 'CROSSMEMBER', '', '12000.00', '1'),
(138, 0, 'RACK & PINION ASSY', '', '11000.00', '1'),
(138, 0, '2PCS. WIPER LINKAGE ASSY W/ MOTOR', '', '7000.00', '1'),
(138, 0, 'ATF', '', '260.00', '1'),
(139, 264, '', '', '350.00', '1'),
(139, 265, '', '', '150.00', '1'),
(139, 266, '', '', '2800.00', '1'),
(139, 267, '', '', '1200.00', '1'),
(139, 268, '', '', '800.00', '1'),
(139, 0, '1PC. BRONZE ROD', '', '65.00', '1'),
(139, 0, '1QRT ATF', '', '260.00', '1'),
(139, 0, 'CLEANING SOLVENT', '', '50.00', '1'),
(140, 62, '', '', '56805.00', '1'),
(141, 269, '', '', '900.00', '1'),
(142, 0, 'CHARGE INVOICE #2381-2382', '', '7290.00', '1'),
(143, 0, 'CHARGE INVOICE#2383-2384', '', '9105.00', '1'),
(144, 270, '', '', '250.00', '1'),
(145, 116, '', '', '150.00', '1'),
(145, 271, '', '', '150.00', '1'),
(145, 0, '1PC. OIL FILTER', '', '190.00', '1'),
(146, 158, '', '', '150.00', '1'),
(146, 49, '', '', '250.00', '1'),
(146, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(146, 0, '1PC. VALVE COVER GASKET', '', '1100.00', '1'),
(147, 272, '', '', '700.00', '1'),
(147, 274, '', '', '910.00', '1'),
(147, 273, '', '', '260.00', '1'),
(147, 0, '2PCS. HUB BEARING@1800', '', '3600.00', '1'),
(147, 0, 'FREIGHT (BEARING)', '', '300.00', '1'),
(148, 131, '', '', '2000.00', '1'),
(148, 116, '', '', '150.00', '1'),
(148, 275, '', '', '300.00', '1'),
(148, 250, '', '', '100.00', '1'),
(148, 0, '1PC. CLUTCH COVER', '', '5500.00', '1'),
(148, 0, '1PC. CLUTCH LINING', '', '4800.00', '1'),
(148, 0, '1PC. RELEASE BEARING', '', '850.00', '1'),
(148, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(148, 0, '4HRS. ENGINE OIL', '', '920.00', '1'),
(148, 0, '2QRT. COOLANT', '', '300.00', '1'),
(148, 0, '2PCS. BUMPER LOCKS', '', '150.00', '1'),
(148, 0, '1PC. HORN SWITCH', '', '100.00', '1'),
(148, 0, '1PC. OIL SEAL', '', '640.00', '1'),
(148, 0, '1PC. THREAD LOCKER', '', '210.00', '1'),
(149, 276, '', '', '250.00', '1'),
(149, 0, '1PC. CLUTCH SLAVE REPAIR KIT', '', '350.00', '1'),
(150, 25, '', '', '250.00', '1'),
(150, 277, '', '', '150.00', '1'),
(150, 278, '', '', '500.00', '1'),
(150, 0, '1PC. FUEL PUMP', '', '3500.00', '1'),
(151, 62, '', '', '25359.00', '1'),
(152, 279, '', '', '550.00', '1'),
(153, 280, '', '', '250.00', '1'),
(154, 281, '', '', '150.00', '1'),
(155, 282, '', '', '600.00', '1'),
(155, 25, '', '', '250.00', '1'),
(155, 283, '', '', '500.00', '1'),
(155, 0, '1PC. FUEL FILTER', '', '460.00', '1'),
(156, 0, '1PC.  NOZZEL WIPER', '', '150.00', '1'),
(157, 285, '', '', '9000.00', '1'),
(158, 286, '', '', '150.00', '1'),
(159, 139, '', '', '600.00', '1'),
(159, 0, '1PC. TIMING BELT', '', '1850.00', '1'),
(160, 287, '', '', '250.00', '1'),
(161, 0, 'CHARGE INVOICE#2360', '', '1300.00', '1'),
(162, 0, 'CHARGE INVOICE#2387', '', '680.00', '1'),
(163, 250, '', '', '1700.00', '1'),
(164, 174, '', '', '350.00', '1'),
(164, 288, '', '', '390.00', '1'),
(164, 289, '', '', '350.00', '1'),
(164, 294, '', '', '450.00', '1'),
(164, 291, '', '', '450.00', '1'),
(164, 292, '', '', '50.00', '1'),
(164, 293, '', '', '350.00', '1'),
(164, 294, '', '', '450.00', '1'),
(164, 0, 'BRAKE SHOE LH/RH', '', '950.00', '1'),
(164, 0, 'FRONT WHEEL BEARING LH', '', '1300.00', '1'),
(164, 0, 'BRAKE FLUID ', '', '100.00', '1'),
(164, 0, '1PC WHEEL BEARING RH', '', '1300.00', '1'),
(165, 295, '', '', '3800.00', '1'),
(166, 0, 'CV JOINT OUTER LH/RH', '', '3000.00', '1'),
(166, 0, 'FREIGHT', '', '400.00', '1'),
(167, 0, 'CHARGE INVOICE # 2395', '', '4400.00', '1'),
(168, 0, 'CHARGE INVOICE #2396', '', '12500.00', '1'),
(169, 0, 'CHARGE INVOICE # 2398', '', '8130.00', '1'),
(170, 0, 'CHARGE INVOICE#2397', '', '4300.00', '1'),
(171, 0, 'CHARGE INVOICE # 2399', '', '1110.00', '1'),
(172, 0, 'CHARGE INVOICE #2394', '', '3500.00', '1'),
(173, 296, '', '', '800.00', '1'),
(173, 0, '1PC. SIDE MIRROR ASSEMBLY RH', '', '3000.00', '1'),
(174, 297, '', '', '18900.00', '1'),
(174, 0, '2PCS. SIDE MIRROR LH-RH @ 800', '', '1600.00', '1'),
(175, 298, '', '', '450.00', '1'),
(175, 299, '', '', '50.00', '1'),
(175, 300, '', '', '300.00', '1'),
(175, 301, '', '', '150.00', '1'),
(175, 302, '', '', '150.00', '1'),
(175, 0, '1PC. PEANUT BULB', '', '50.00', '1'),
(175, 0, '1PC. OIL SEAL 35X5X8', '', '260.00', '1'),
(175, 0, '1PC ORING 213', '', '30.00', '1'),
(175, 0, '1PC. T FITTING', '', '50.00', '1'),
(176, 128, '', '', '200.00', '1'),
(176, 129, '', '', '150.00', '1'),
(176, 0, '1SET RACK END LR', '', '1900.00', '1'),
(176, 0, '1SET TIE ROD END LR', '', '1600.00', '1'),
(176, 0, '2PCS. TIE WRAP (BIG)', '', '30.00', '1'),
(176, 0, '2PCS. TIE WRAP (SMALL)', '', '16.00', '1'),
(177, 116, '', '', '150.00', '1'),
(177, 303, '', '', '450.00', '1'),
(177, 304, '', '', '250.00', '1'),
(177, 305, '', '', '850.00', '1'),
(177, 306, '', '', '350.00', '1'),
(177, 307, '', '', '350.00', '1'),
(177, 308, '', '', '150.00', '1'),
(177, 309, '', '', '250.00', '1'),
(177, 310, '', '', '450.00', '1'),
(177, 0, 'BELANOID GASKET', '', '80.00', '1'),
(177, 0, 'CLEANING SOLVENT', '', '50.00', '1'),
(177, 0, '1PC. CRANKCASE GASKET', '', '550.00', '1'),
(178, 0, '1PC. TRACK BITE', '', '3000.00', '1'),
(179, 311, '', '', '450.00', '1'),
(179, 0, '1PC. O/R 2X6', '', '15.00', '1'),
(179, 0, '2PCS. O/R 2X10', '', '30.00', '1'),
(179, 0, '1PC. O/R 2X20', '', '15.00', '1'),
(179, 0, '1PC. O/R 2X65', '', '30.00', '1'),
(180, 312, '', '', '5800.00', '1'),
(180, 49, '', '', '250.00', '1'),
(180, 277, '', '', '150.00', '1'),
(180, 158, '', '', '100.00', '1'),
(180, 314, '', '', '250.00', '1'),
(180, 318, '', '', '450.00', '1'),
(180, 315, '', '', '480.00', '1'),
(180, 250, '', '', '150.00', '1'),
(180, 316, '', '', '450.00', '1'),
(180, 317, '', '', '350.00', '1'),
(180, 84, '', '', '300.00', '1'),
(180, 0, 'GASOLINE', '', '250.00', '1'),
(180, 0, '1SET HI-TENSION WIRE', '', '600.00', '1'),
(180, 0, '1PC. AIR FILTER', '', '630.00', '1'),
(180, 0, '1PC. VALVE COVER GASKET', '', '200.00', '1'),
(180, 0, '1PC FUEL INJECTOR', '', '1500.00', '1'),
(180, 0, '1PC. HORN', '', '650.00', '1'),
(180, 0, '1SET BRAKE PISTON', '', '750.00', '1'),
(180, 0, '1SET CALIPER KIT', '', '650.00', '1'),
(180, 0, 'BRAKE FLUID', '', '300.00', '1'),
(180, 0, '1SET BRAKE MASTER KIT', '', '715.00', '1'),
(181, 62, '', '', '10510.00', '1'),
(182, 319, '', '', '1000.00', '1'),
(183, 320, '', '', '800.00', '1'),
(183, 321, '', '', '150.00', '1'),
(183, 322, '', '', '100.00', '1'),
(183, 0, 'CLEANING SOLVENT VALVE COVER GASKET', '', '200.00', '1'),
(184, 323, '', '', '3500.00', '1'),
(184, 0, 'FREON', '', '500.00', '1'),
(185, 324, '', '', '1800.00', '1'),
(186, 325, '', '', '250.00', '1'),
(187, 0, 'CHARGE INVOICE# 2252', '', '3000.00', '1'),
(188, 62, '', '', '12000.00', '1'),
(189, 326, '', '', '1800.00', '1'),
(190, 327, '', '', '800.00', '1'),
(190, 328, '', '', '1500.00', '1'),
(190, 329, '', '', '250.00', '1'),
(190, 236, '', '', '1500.00', '1'),
(190, 0, '1PC. OIL SEAL 20X30X5', '', '240.00', '1'),
(190, 0, '1PC. OIL SEAL 25X35X6', '', '190.00', '1'),
(190, 0, '2PCS. OIL SEAL 23X41X8', '', '750.00', '1'),
(190, 0, '2HRS. ATF', '', '520.00', '1'),
(190, 0, '1PC. POWER STEERING PUMP', '', '4800.00', '1'),
(190, 0, '1HR. ATF', '', '260.00', '1'),
(190, 0, '1HR. ATF', '', '260.00', '1'),
(190, 0, '2PCS. OIL SEAL', '', '1170.00', '1'),
(191, 331, '', '', '150.00', '1'),
(191, 85, '', '', '450.00', '1'),
(191, 0, '1SET BRAKE MASTER ASSY', '', '3800.00', '1'),
(191, 0, '1QRT. BRAKE FLUID', '', '160.00', '1'),
(192, 62, '', '', '31634.00', '1'),
(193, 0, 'CHARGE INVOICE # 2255-2256', '', '6940.00', '1'),
(194, 0, 'CHARGE INVOICE # 2389', '', '3000.00', '1'),
(195, 0, 'CHARGE INVOICE # 2390-2391', '', '7475.00', '1'),
(196, 0, 'CHARGE INVOICE # 2393', '', '3900.00', '1'),
(197, 0, 'CHARGE INVOICE #2257', '', '950.00', '1'),
(198, 0, 'CHARGE INVOICE # 2378', '', '10915.00', '1'),
(199, 0, 'CHARGE INVOICE#2400', '', '5250.00', '1'),
(200, 0, 'CHARGE INVOICE # 2377', '', '17250.00', '1'),
(201, 0, 'CHARGE INVOICE # 1164', '', '3900.00', '1'),
(202, 332, '', '', '6800.00', '1'),
(203, 62, '', '', '32600.00', '1'),
(204, 116, '', '', '150.00', '1'),
(204, 322, '', '', '150.00', '1'),
(204, 0, '1GAL ENGINE OIL', '', '950.00', '1'),
(204, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(205, 333, '', '', '2500.00', '1'),
(206, 0, 'CHARGE INVOICE # 2203', '', '4000.00', '1'),
(207, 0, 'CHARGE INVOICE # 2418', '', '32296.38', '1'),
(208, 334, '', '', '15500.00', '1'),
(208, 335, '', '', '300.00', '1'),
(208, 336, '', '', '1800.00', '1'),
(208, 0, '1PC. QUARTER PANEL ASSY LH', '', '17350.69', '1'),
(208, 0, '1PC TAIL LIGHT ASSEMBLY LH', '', '6311.96', '1'),
(209, 0, 'CHARGE INVOICE # 2254', '', '6400.00', '1'),
(210, 337, '', '', '150.00', '1'),
(210, 195, '', '', '450.00', '1'),
(210, 338, '', '', '3500.00', '1'),
(210, 0, '1PC. TIRE 235/75/R15', '', '7800.00', '1'),
(211, 0, 'CHARGE INVOICE # 2251', '', '21100.00', '1'),
(212, 77, '', '', '300.00', '1'),
(212, 339, '', '', '380.00', '1'),
(212, 0, '1PC LOWER ARM BUSHING FRT RH', '', '350.00', '1'),
(213, 340, '', '', '1200.00', '1'),
(214, 341, '', '', '150.00', '1'),
(214, 342, '', '', '2800.00', '1'),
(215, 346, '', '', '700.00', '1'),
(215, 344, '', '', '2800.00', '1'),
(215, 345, '', '', '600.00', '1'),
(215, 0, '1CAN GREASE', '', '450.00', '1'),
(215, 0, 'CLEANING SOLVENT', '', '100.00', '1'),
(215, 0, '2PCS. AXLE BOOTS OUTER', '', '312.00', '1'),
(216, 347, '', '', '150.00', '1'),
(216, 0, '2PCS. HEADLIGHT SOCKET', '', '200.00', '1'),
(217, 0, 'CHARGE INVOICE # 2170', '', '2435.00', '1'),
(218, 274, '', '', '600.00', '1'),
(218, 354, '', '', '850.00', '1'),
(218, 348, '', '', '100.00', '1'),
(218, 349, '', '', '150.00', '1'),
(218, 350, '', '', '260.00', '1'),
(218, 351, '', '', '910.00', '1'),
(218, 352, '', '', '150.00', '1'),
(218, 353, '', '', '350.00', '1'),
(218, 0, '2PCS. FRT HUB BEARING', '', '3800.00', '1'),
(218, 0, '1PC. VTEC SOLENOID GASKET', '', '650.00', '1'),
(218, 0, '1PC. FUEL HOSE', '', '60.00', '1'),
(218, 0, '4PCS. HOSE CLIPS', '', '130.00', '1'),
(219, 62, '', '', '13000.00', '1'),
(220, 355, '', '', '500.00', '1'),
(220, 0, '4G 13A WATER PUMP', '', '1500.00', '1'),
(221, 356, '', '', '1500.00', '1'),
(222, 357, '', '', '1800.00', '1'),
(223, 358, '', '', '1700.00', '1'),
(224, 359, '', '', '5500.00', '1'),
(225, 362, '', '', '350.00', '1'),
(225, 363, '', '', '50.00', '1'),
(225, 361, '', '', '250.00', '1'),
(225, 0, '1PC. POWER STEERING HOSE W/ CRIM', '', '1800.00', '1'),
(225, 0, '1PC. POWER STEERING BELT', '', '500.00', '1'),
(225, 0, '2PCS. RUBBER CAP', '', '100.00', '1'),
(225, 0, '1QRT ATF', '', '260.00', '1'),
(225, 0, '1 BRAKE FLUID', '', '150.00', '1'),
(226, 0, '2PCS. SHOCK ABSORBER', '', '3600.00', '1'),
(227, 0, '1PC. SIDE MIRROR', '', '800.00', '1'),
(228, 366, '', '', '350.00', '1'),
(228, 0, '1SET TIE ROD END @780', '', '1560.00', '1'),
(228, 0, '1SET RACK END @980', '', '1960.00', '1'),
(228, 0, '2PCS. STEERING BOOTS @ 160', '', '320.00', '1'),
(229, 0, 'CHARGE INVOICE # 2262', '', '1775.00', '1'),
(230, 367, '', '', '100.00', '1'),
(231, 368, '', '', '150.00', '1'),
(231, 116, '', '', '150.00', '1'),
(231, 369, '', '', '1800.00', '1'),
(231, 370, '', '', '800.00', '1'),
(231, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(231, 0, '2 GALS. ENGINE OIL', '', '7000.00', '1'),
(232, 0, 'PARTICIPATION OF CLAIM# 200041251', '', '2725.00', '1'),
(233, 143, '', '', '300.00', '1'),
(233, 0, '1PC. OIL SEAL', '', '200.00', '1'),
(234, 0, 'CHARGE INVOICE # 2204', '', '7910.00', '1'),
(235, 0, 'CHARGE INVOICE #2259-2260', '', '12737.00', '1'),
(236, 193, '', '', '250.00', '1'),
(237, 371, '', '', '2000.00', '1'),
(238, 0, 'CHARGE INVOICE #2266', '', '2780.00', '1'),
(239, 0, 'CHARGE INVOICE # 2253', '', '11420.00', '1'),
(240, 0, 'CHARGE INVOICE #2265', '', '8100.00', '1'),
(241, 325, '', '', '450.00', '1'),
(242, 372, '', '', '1800.00', '1'),
(242, 373, '', '', '200.00', '1'),
(243, 0, 'PAYMENTS', '', '5500.00', '1'),
(244, 25, '', '', '150.00', '1'),
(244, 374, '', '', '500.00', '1'),
(244, 0, '1PC. FUEL FILTER', '', '500.00', '1'),
(245, 375, '', '', '150.00', '1'),
(246, 376, '', '', '100.00', '1'),
(246, 129, '', '', '250.00', '1'),
(246, 378, '', '', '350.00', '1'),
(246, 379, '', '', '350.00', '1'),
(246, 116, '', '', '150.00', '1'),
(246, 0, '1PC. OIL FILTER', '', '320.00', '1'),
(246, 0, '4pcs. tie rod end', '', '3800.00', '1'),
(246, 0, '1PC. CENTER BEARING', '', '1050.00', '1'),
(246, 0, '6HRS. ENGINE OIL', '', '1380.00', '1'),
(246, 0, '1PC. BOLT ', '', '35.00', '1'),
(247, 0, 'CHARGE INVOICE # 2201', '', '2090.00', '1'),
(248, 0, '1LTR. ENGINE OIL', '', '230.00', '1'),
(249, 380, '', '', '250.00', '1'),
(249, 0, 'BRAKE FLUID', '', '100.00', '1'),
(250, 381, '', '', '350.00', '1'),
(251, 382, '', '', '300.00', '1'),
(251, 0, '1PC. RADIATOR', '', '6500.00', '1'),
(251, 0, '1HR. COOLANT', '', '300.00', '1'),
(252, 383, '', '', '550.00', '1'),
(252, 384, '', '', '1200.00', '1'),
(252, 158, '', '', '150.00', '1'),
(252, 0, '1PC. RADIATOR HOSE CLAMP', '', '50.00', '1'),
(252, 0, '1PC. ORING', '', '40.00', '1'),
(252, 0, 'DEVCON', '', '100.00', '1'),
(252, 0, '1PC. VALVE COVER GASKET', '', '1200.00', '1'),
(253, 385, '', '', '150.00', '1'),
(253, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(254, 386, '', '', '1500.00', '1'),
(254, 0, 'ATF BONTING', '', '260.00', '1'),
(255, 388, '', '', '600.00', '1'),
(255, 389, '', '', '850.00', '1'),
(255, 0, '2PCS. SHOCK ABSORBER', '', '14000.00', '1'),
(255, 0, 'FREIGHT', '', '520.00', '1'),
(256, 0, 'CHARGE INVOICE # 2202', '', '15470.00', '1'),
(257, 0, 'CHARGE INVOICE # 2205', '', '4850.00', '1'),
(258, 390, '', '', '350.00', '1'),
(258, 0, 'COOLANT', '', '300.00', '1'),
(259, 391, '', '', '600.00', '1'),
(260, 392, '', '', '150.00', '1'),
(261, 393, '', '', '150.00', '1'),
(261, 394, '', '', '50.00', '1'),
(261, 395, '', '', '300.00', '1'),
(261, 396, '', '', '250.00', '1'),
(261, 397, '', '', '150.00', '1'),
(261, 398, '', '', '350.00', '1'),
(261, 399, '', '', '400.00', '1'),
(261, 400, '', '', '400.00', '1'),
(261, 43, '', '', '300.00', '1'),
(261, 252, '', '', '200.00', '1'),
(261, 105, '', '', '400.00', '1'),
(261, 401, '', '', '400.00', '1'),
(261, 0, '1pc. FAN BELT(ALTERNATOR)', '', '690.00', '1'),
(261, 0, '1PC. TAN BELT ( STEERING)', '', '320.00', '1'),
(261, 0, '1PC. FUEL HOSE', '', '170.00', '1'),
(261, 0, '2PCS. RACK END LR', '', '2200.00', '1'),
(261, 0, '2PCS. TIE ROD END LR', '', '1500.00', '1'),
(261, 0, '2PCS. STABILIZER BAR BUSHING LR', '', '250.00', '1'),
(261, 0, '2PCS. BALLJOINT LR', '', '1800.00', '1'),
(261, 0, '2PCS. ARM BUSHING FRT LR', '', '700.00', '1'),
(261, 0, '2PCS. ARM BUSHING REAR', '', '1700.00', '1'),
(261, 0, '2PCS. STABILIZER LINK LR', '', '1500.00', '1'),
(261, 0, '2PCS. STEERING BOOTS', '', '430.00', '1'),
(262, 402, '', '', '200.00', '1'),
(262, 404, '', '', '150.00', '1'),
(262, 0, '1PC DOOR GLASS', '', '3800.00', '1'),
(262, 0, '1PC. WINDOW RUBBER', '', '1500.00', '1'),
(263, 62, '', '', '1500.00', '1'),
(264, 405, '', '', '500.00', '1'),
(265, 116, '', '', '150.00', '1'),
(265, 0, '1 PC OIL FILTER', '', '290.00', '1'),
(265, 0, '7LTRS. ENGINE OIL', '', '1610.00', '1'),
(266, 406, '', '', '450.00', '1'),
(267, 407, '', '', '50.00', '1'),
(268, 0, 'CHARGE INVOICE # 2208', '', '4850.00', '1'),
(269, 0, 'CHARGE INVOICE # 2209-2210', '', '26930.00', '1'),
(270, 408, '', '', '180.00', '1'),
(270, 409, '', '', '150.00', '1'),
(270, 410, '', '', '300.00', '1'),
(270, 411, '', '', '120.00', '1'),
(270, 278, '', '', '800.00', '1'),
(270, 170, '', '', '150.00', '1'),
(270, 0, '1PC. RACK END', '', '650.00', '1'),
(270, 0, '1PC. TIE ROD END', '', '800.00', '1'),
(270, 0, '1PC. LOWER ARM BUSHING', '', '260.00', '1'),
(270, 0, '1PC. FUEL PUMP', '', '3500.00', '1'),
(270, 0, '1PC. RADIATOR HOSE', '', '260.00', '1'),
(271, 412, '', '', '800.00', '1'),
(271, 413, '', '', '100.00', '1'),
(271, 0, '3LTRS. ENGINE OIL', '', '690.00', '1'),
(272, 414, '', '', '600.00', '1'),
(272, 0, 'GREASE', '', '450.00', '1'),
(273, 415, '', '', '350.00', '1'),
(274, 416, '', '', '150.00', '1'),
(275, 417, '', '', '550.00', '1'),
(275, 156, '', '', '100.00', '1'),
(276, 418, '', '', '16200.00', '1'),
(276, 419, '', '', '2500.00', '1'),
(276, 420, '', '', '950.00', '1'),
(276, 0, 'INSTALL HID FOG LAMP', '', '500.00', '1'),
(276, 0, 'INSTALL WIRING KIT', '', '350.00', '1'),
(276, 0, 'FREIGHT', '', '300.00', '1'),
(277, 421, '', '', '300.00', '1'),
(277, 82, '', '', '1500.00', '1'),
(277, 0, '1SET BRAKE PADS', '', '1200.00', '1'),
(277, 0, '1PC. ACTUSTOR', '', '350.00', '1'),
(278, 116, '', '', '150.00', '1'),
(278, 0, '1PC. OIL FILTER', '', '650.00', '1'),
(278, 0, '6HRS. ENGINE OIL', '', '1380.00', '1'),
(278, 0, '1HR. ATF', '', '260.00', '1'),
(279, 422, '', '', '150.00', '1'),
(279, 423, '', '', '900.00', '1'),
(279, 424, '', '', '250.00', '1'),
(279, 425, '', '', '300.00', '1'),
(279, 0, '4PCS. LEAF SPRING BUSHING @65', '', '260.00', '1'),
(280, 426, '', '', '550.00', '1'),
(280, 427, '', '', '450.00', '1'),
(280, 0, '1PC. CRANK SHAFT PULLEY', '', '2900.00', '1'),
(280, 0, '2PCS. STEERING BUSHING @ 350', '', '700.00', '1'),
(281, 297, '', '', '150.00', '1'),
(282, 428, '', '', '120.00', '1'),
(283, 429, '', '', '250.00', '1'),
(283, 430, '', '', '450.00', '1'),
(283, 431, '', '', '300.00', '1'),
(283, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(283, 0, '1PC. HUB BEARING REAR LH', '', '3500.00', '1'),
(283, 0, '1PC. AIR FILTER', '', '690.00', '1'),
(284, 199, '', '', '100.00', '1'),
(284, 432, '', '', '300.00', '1'),
(284, 0, '1PC. FAN BELT', '', '500.00', '1'),
(285, 0, 'CHARGE INVOICE # 2215', '', '14236.00', '1'),
(286, 433, '', '', '600.00', '1'),
(286, 145, '', '', '250.00', '1'),
(286, 0, '2PCS. SHOCK ABSORBER FRONT LH/RH', '', '10050.00', '1'),
(286, 0, '1PC. DRIVE BELT', '', '960.00', '1'),
(287, 275, '', '', '500.00', '1'),
(287, 434, '', '', '250.00', '1'),
(287, 0, '1PC. CRANKSHAFT OIL SEAL', '', '580.00', '1'),
(287, 0, '1LTR. ENGINE OIL', '', '230.00', '1'),
(287, 0, '1PC. UPPER RADIATOR HOSE', '', '500.00', '1'),
(287, 0, 'COOLANT', '', '150.00', '1'),
(288, 435, '', '', '380.00', '1'),
(289, 116, '', '', '150.00', '1'),
(289, 212, '', '', '650.00', '1'),
(289, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(289, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(289, 0, '1PC. BUMPER LACK', '', '75.00', '1'),
(290, 436, '', '', '760.00', '1'),
(291, 437, '', '', '550.00', '1'),
(291, 0, '1PC. OIL SEAL', '', '100.00', '1'),
(291, 0, '1PC. ORING', '', '35.00', '1'),
(292, 438, '', '', '250.00', '1'),
(293, 439, '', '', '500.00', '1'),
(293, 440, '', '', '500.00', '1'),
(293, 0, '1SET HEADLIGHT H/B', '', '2800.00', '1'),
(293, 0, '1SET FOG LAMP H/B', '', '2500.00', '1'),
(294, 116, '', '', '150.00', '1'),
(294, 0, '1GAL. ENGINE OIL', '', '1250.00', '1'),
(294, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(295, 441, '', '', '250.00', '1'),
(296, 25, '', '', '250.00', '1'),
(296, 442, '', '', '850.00', '1'),
(296, 0, 'DETERGENT POWDER', '', '100.00', '1'),
(297, 0, 'CHARGE INVOICE # 2213', '', '3611.00', '1'),
(298, 0, 'CHARGE INVOICE # 2211', '', '10200.00', '1'),
(299, 0, 'CHARGE INVOICE #2216', '', '9800.00', '1'),
(300, 0, 'CHARGE INVOICE # 2222', '', '12833.00', '1'),
(301, 0, 'CHARGE INVOICE # 2272', '', '3370.00', '1'),
(302, 0, 'CHARGE INVOICE # 2271', '', '3811.00', '1'),
(303, 0, 'CHARGE INVOICE # 2275', '', '7770.00', '1'),
(304, 0, 'CHARGE INVOICE # 2274', '', '3561.00', '1'),
(305, 0, 'CHARGE INVOICE # 2226', '', '4760.00', '1'),
(306, 0, 'CHARGE INVOICE #2225', '', '19220.00', '1'),
(307, 0, 'CHARGE INVOICE # 2261', '', '5250.00', '1'),
(308, 0, 'CHARGE INVOICE # 2214', '', '10660.00', '1'),
(309, 0, 'CHARGE INVOICE # 2227', '', '12410.00', '1'),
(310, 0, 'CHARGE INVOICE #2206-2207', '', '10310.00', '1'),
(311, 0, 'CHARGE INVOICE # 2267', '', '350.00', '1'),
(312, 116, '', '', '150.00', '1'),
(312, 0, '7 HRS. ENGINE OIL', '', '1610.00', '1'),
(312, 0, '1PC. OIL FILTER', '', '500.00', '1'),
(312, 0, '1PC. AIR FILTER', '', '750.00', '1'),
(313, 443, '', '', '2080.00', '1'),
(314, 444, '', '', '250.00', '1'),
(314, 0, '4HRS. GEAR OIL', '', '920.00', '1'),
(315, 445, '', '', '350.00', '1'),
(316, 446, '', '', '150.00', '1'),
(317, 0, 'CHARGE INVOICE # 2230-2231', '', '25900.00', '1'),
(318, 0, 'CHARGE INVOICE # 2233', '', '6440.00', '1'),
(319, 0, 'CHARGE INVOICE # 2276', '', '2000.00', '1'),
(320, 0, 'CHARGE INVOICE # 2223', '', '4850.00', '1'),
(321, 364, '', '', '700.00', '1'),
(321, 0, '2 pcs. shock absorber frt LR', '', '9000.00', '1'),
(322, 447, '', '', '800.00', '1'),
(323, 116, '', '', '150.00', '1'),
(324, 0, 'STORAGE FEE @ 30/ DAY', '', '330.00', '1'),
(325, 448, '', '', '100.00', '1'),
(325, 449, '', '', '450.00', '1'),
(325, 163, '', '', '350.00', '1'),
(325, 450, '', '', '350.00', '1'),
(325, 0, '1 PC. ALTERNATOR ASSY', '', '4500.00', '1'),
(325, 0, '1PC. STARTER ASSY', '', '3500.00', '1'),
(326, 0, 'CHARGE INVOICE # 2277', '', '9900.00', '1'),
(327, 0, 'CHARGE INVOICE # 2234', '', '4475.00', '1'),
(328, 0, 'CHARGE INVOICE # 2220', '', '14500.00', '1'),
(329, 199, '', '', '100.00', '1'),
(330, 116, '', '', '150.00', '1'),
(330, 0, '1 PC. OIL FILTER', '', '290.00', '1'),
(330, 0, '6 LTRS. ENGINE OIL', '', '2820.00', '1'),
(331, 0, 'CHARGE INVOICE # 2278', '', '2525.00', '1'),
(332, 452, '', '', '2500.00', '1'),
(332, 0, '1PC. REAR BUMPER ASSEMBLY', '', '5500.00', '1'),
(333, 453, '', '', '100.00', '1'),
(333, 458, '', '', '300.00', '1'),
(333, 454, '', '', '210.00', '1'),
(333, 455, '', '', '550.00', '1'),
(333, 456, '', '', '1100.00', '1'),
(333, 59, '', '', '6000.00', '1'),
(333, 0, '1PC. MUFFLER SUPPORT', '', '150.00', '1'),
(333, 0, '1PC. BOLT ', '', '5.00', '1'),
(333, 0, '1 UNIT BLADE', '', '25000.00', '1'),
(333, 0, '1PC. HEAD GASKET ( ORIG)', '', '1500.00', '1'),
(333, 0, '2PCS. PISTON PIN', '', '1040.00', '1'),
(333, 0, '2PCS. V GASKET', '', '100.00', '1'),
(333, 0, '1 PC. TIMING BELT', '', '2100.00', '1'),
(333, 0, '1PC. OIL FILTER', '', '260.00', '1'),
(333, 0, '1 GAL ENGINE OIL', '', '950.00', '1'),
(333, 0, '1 LTRS. ATF', '', '260.00', '1'),
(333, 0, '1 PC. STEERING BELT', '', '360.00', '1'),
(334, 459, '', '', '350.00', '1'),
(334, 460, '', '', '1600.00', '1'),
(335, 25, '', '', '150.00', '1'),
(335, 461, '', '', '900.00', '1'),
(335, 462, '', '', '800.00', '1'),
(335, 463, '', '', '900.00', '1'),
(335, 133, '', '', '450.00', '1'),
(335, 0, '1PC. FUEL FILTER', '', '300.00', '1'),
(335, 0, '1SET INJECTION PUMP REPAIR KIT', '', '1600.00', '1'),
(335, 0, '2 PCS. CAMSHAFT BUSHING', '', '1200.00', '1'),
(335, 0, '1PC CAMSHAFT OIL SEAL', '', '580.00', '1'),
(335, 0, '1SET TRANSFER PUMP', '', '1350.00', '1'),
(335, 0, '1PC. PUMP LINER', '', '1400.00', '1'),
(335, 0, '1PC. OVER FLOW VALVE', '', '900.00', '1'),
(336, 49, '', '', '250.00', '1'),
(336, 0, '3 PCS. SPARK PLUG', '', '360.00', '1'),
(336, 0, '1 PC. CONTACT PAINT', '', '240.00', '1'),
(336, 0, '1PC. CONDENSER', '', '130.00', '1'),
(337, 116, '', '', '150.00', '1'),
(338, 0, 'CHARGE INVOICE # 2242', '', '10010.00', '1'),
(339, 0, 'CHARGE INVOICE # 2241', '', '7820.00', '1'),
(340, 0, 'CHARGE INVOICE # 2240', '', '5300.00', '1'),
(341, 464, '', '', '150.00', '1'),
(342, 465, '', '', '100.00', '1'),
(343, 466, '', '', '650.00', '1'),
(344, 116, '', '', '150.00', '1'),
(344, 254, '', '', '350.00', '1'),
(344, 0, '1PC. OIL FILTER', '', '350.00', '1'),
(344, 0, '1 GAL ENGINE OIL', '', '950.00', '1'),
(344, 0, '1SET BRAKE PADS FRT', '', '1400.00', '1'),
(345, 129, '', '', '250.00', '1'),
(345, 468, '', '', '350.00', '1'),
(345, 469, '', '', '200.00', '1'),
(345, 397, '', '', '150.00', '1'),
(345, 470, '', '', '700.00', '1'),
(345, 471, '', '', '150.00', '1'),
(345, 472, '', '', '500.00', '1'),
(345, 473, '', '', '400.00', '1'),
(345, 158, '', '', '150.00', '1'),
(345, 474, '', '', '800.00', '1'),
(345, 475, '', '', '850.00', '1'),
(346, 31, '', '', '350.00', '1'),
(347, 476, '', '', '150.00', '1'),
(348, 477, '', '', '2850.00', '1'),
(348, 478, '', '', '2200.00', '1'),
(348, 479, '', '', '450.00', '1'),
(348, 0, '1PC BEARING BIG', '', '390.00', '1'),
(348, 0, '1PC. BEARING  SMALL', '', '325.00', '1'),
(349, 0, 'PARTICIPATION OF CLAIM # MC-PC-HW 13-137', '', '2000.00', '1'),
(350, 480, '', '', '350.00', '1'),
(350, 0, '4PCS. HUGBOLT W/ NUT', '', '550.00', '1'),
(351, 481, '', '', '150.00', '1'),
(351, 482, '', '', '150.00', '1'),
(351, 483, '', '', '250.00', '1'),
(351, 0, '2PCS. BULB', '', '365.00', '1'),
(352, 116, '', '', '150.00', '1'),
(352, 49, '', '', '250.00', '1'),
(352, 484, '', '', '60.00', '1'),
(352, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(352, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(352, 0, '4PCS. SPARK PLUG', '', '480.00', '1'),
(352, 0, '1PC. AIR FILTER', '', '695.00', '1'),
(352, 0, '2PCS. PLASTIC LOCK W/ WASHER', '', '90.00', '1'),
(352, 0, '3PCS. D. CLIP #11', '', '150.00', '1'),
(352, 0, '3PCS. METAL SCREW', '', '60.00', '1'),
(352, 0, '1LTR COOLANT', '', '300.00', '1'),
(353, 0, 'CHARGE INVOICE # 2258', '', '969.00', '1'),
(354, 185, '', '', '900.00', '1'),
(354, 486, '', '', '500.00', '1'),
(354, 0, '8PCS. SHOCK BUSHING', '', '400.00', '1'),
(355, 129, '', '', '250.00', '1'),
(355, 467, '', '', '200.00', '1'),
(356, 487, '', '', '2800.00', '1'),
(357, 0, 'CHARGE INVOICE # 2218', '', '1880.00', '1'),
(358, 488, '', '', '8000.00', '1'),
(359, 489, '', '', '1000.00', '1'),
(359, 0, 'FREIGHT', '', '2523.85', '1'),
(360, 490, '', '', '800.00', '1'),
(360, 491, '', '', '600.00', '1'),
(360, 306, '', '', '50.00', '1'),
(360, 493, '', '', '800.00', '1'),
(360, 494, '', '', '1800.00', '1'),
(360, 0, '1SET REPAIR KIT', '', '1580.00', '1'),
(360, 0, '1PC. CAM SHAFT OIL SEAL', '', '380.00', '1'),
(360, 0, '2PCS. CAM SHAFT BUSHING', '', '1100.00', '1'),
(360, 0, '1PC. DRIVE SHAFT RECROME', '', '1200.00', '1'),
(360, 0, '1PC. OVERFLOW VALVE', '', '700.00', '1'),
(360, 0, '4PCS. NOZZLE TIP RECONDITIONING', '', '1000.00', '1'),
(360, 0, '1CYL. HEAD GASKET ', '', '1800.00', '1'),
(360, 0, '1 PC GLOW PLUG', '', '310.00', '1'),
(360, 0, '2PCS. HOSE', '', '91.00', '1'),
(360, 492, '', '', '50.00', '1'),
(361, 495, '', '', '6300.00', '1'),
(362, 496, '', '', '350.00', '1'),
(362, 497, '', '', '350.00', '1'),
(362, 0, '1PC. HEADLIGHT & CLEARNCE LAMP COMBINATION', '', '8950.00', '1'),
(363, 62, '', '', '3300.00', '1'),
(364, 0, 'EXCESS', '', '1070.00', '1'),
(365, 0, 'EXCESS OF TIRE', '', '310.00', '1'),
(366, 0, 'CHARGE INVOICE # 2270', '', '20764.00', '1'),
(367, 0, 'CHARGE INVOICE # 2268', '', '12700.00', '1'),
(368, 62, '', '', '10800.00', '1'),
(369, 498, '', '', '350.00', '1'),
(370, 214, '', '', '580.00', '1'),
(370, 499, '', '', '350.00', '1'),
(370, 0, 'RADIATOR HOSE', '', '455.00', '1'),
(370, 0, 'BYPASS HOSE W/ CLIP', '', '230.00', '1'),
(370, 0, 'COOLANT', '', '600.00', '1'),
(370, 0, 'HOSE CLIP', '', '35.00', '1'),
(371, 500, '', '', '8000.00', '1'),
(371, 0, 'FREIGHT', '', '285.60', '1'),
(371, 0, 'STARTER', '', '450.00', '1'),
(372, 501, '', '', '550.00', '1'),
(372, 502, '', '', '14000.00', '1'),
(372, 504, '', '', '350.00', '1'),
(372, 503, '', '', '650.00', '1'),
(372, 0, '2PCS. MOTOR POWER WINDOW', '', '5900.00', '1'),
(372, 0, '3PCS. REPAIR DOOR MECHANISM', '', '1650.00', '1'),
(373, 505, '', '', '300.00', '1'),
(373, 0, '1PC. HUB BEARING', '', '2800.00', '1'),
(374, 506, '', '', '500.00', '1'),
(375, 507, '', '', '100.00', '1'),
(376, 62, '', '', '52204.00', '1'),
(377, 0, 'PARTICIPATION ', '', '3000.00', '1'),
(378, 509, '', '', '250.00', '1'),
(378, 510, '', '', '450.00', '1'),
(378, 511, '', '', '50.00', '1'),
(378, 258, '', '', '50.00', '1'),
(378, 0, '8PCS. SPARK PLUG @120', '', '960.00', '1'),
(378, 0, '1PC. FUEL FILTER', '', '845.00', '1'),
(378, 0, '1PC. AIR CLEANER', '', '364.00', '1'),
(378, 0, '2PCS. WEDGE BULB 12V MNB', '', '208.00', '1'),
(379, 512, '', '', '550.00', '1'),
(380, 513, '', '', '3000.00', '1'),
(381, 297, '', '', '150.00', '1'),
(381, 0, '1PC. AIR FILTER', '', '364.00', '1'),
(381, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(382, 514, '', '', '800.00', '1'),
(382, 515, '', '', '50.00', '1'),
(382, 516, '', '', '450.00', '1'),
(382, 517, '', '', '300.00', '1'),
(382, 0, 'FUEL FLOAT GAUGE', '', '1800.00', '1'),
(382, 0, 'STEERING BOX REPAIR KIT', '', '2200.00', '1'),
(382, 0, '1LTR. ATF', '', '260.00', '1'),
(382, 0, '2PCS. REAR SHOCKS ABSORBER KYV', '', '3500.00', '1'),
(383, 518, '', '', '8000.00', '1'),
(383, 119, '', '', '1500.00', '1'),
(383, 519, '', '', '550.00', '1'),
(383, 0, '1 SET OVERHAULING GASKET', '', '6240.00', '1'),
(383, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(383, 0, '1PC. OIL FILTER', '', '130.00', '1'),
(383, 0, 'CLEANING SOLVENT', '', '260.00', '1'),
(383, 0, '1KL. RUG', '', '50.00', '1'),
(383, 0, 'COOLANT 1.5 LITERS', '', '450.00', '1'),
(383, 0, 'ATF 4 LITERS', '', '1040.00', '1'),
(383, 0, '2PCS. BOLT 12X100X1.75', '', '60.00', '1'),
(383, 0, '4 PCS. SPARK PLUG', '', '480.00', '1'),
(383, 0, 'CLEANING SOLVENT', '', '200.00', '1'),
(383, 0, '1PC. WATER PUMP', '', '2340.00', '1'),
(383, 0, '1PC. TIMING BELT', '', '3380.00', '1'),
(383, 0, '1PC. TIE WRAP', '', '10.00', '1'),
(383, 0, '1PC. IDLER BEARING', '', '1430.00', '1'),
(383, 0, '1PC. THERMOSTAT ASSY', '', '1560.00', '1'),
(383, 0, '1PC. TENSIONER BEARING', '', '2860.00', '1'),
(383, 0, '1PC. DRIVE BELT', '', '1235.00', '1'),
(383, 0, '1PC. RELAY W/ SOCKET', '', '150.00', '1'),
(384, 191, '', '', '100.00', '1'),
(385, 77, '', '', '700.00', '1'),
(385, 129, '', '', '250.00', '1'),
(385, 468, '', '', '250.00', '1'),
(385, 474, '', '', '200.00', '1'),
(385, 474, '', '', '200.00', '1'),
(386, 520, '', '', '200.00', '1'),
(387, 62, '', '', '21884.00', '1'),
(388, 116, '', '', '150.00', '1'),
(388, 0, '1 LTR. SYNTHIUM @315', '', '2205.00', '1'),
(388, 0, '1PC. OIL FILTER', '', '450.00', '1');
INSERT INTO `jodetails` (`jo_id`, `labor`, `partmaterial`, `details`, `amnt`, `status`) VALUES
(388, 0, '1PC. AIR FILTER', '', '1400.00', '1'),
(388, 0, '1PC. FUEL FILTER', '', '850.00', '1'),
(388, 0, 'ADDITIONAL CASH PAID', '', '800.00', '1'),
(389, 297, '', '', '150.00', '1'),
(389, 49, '', '', '350.00', '1'),
(389, 521, '', '', '350.00', '1'),
(389, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(389, 0, '1 OZ. OIL FILTER', '', '290.00', '1'),
(390, 116, '', '', '150.00', '1'),
(390, 49, '', '', '250.00', '1'),
(390, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(390, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(390, 0, '1PC. OIL FILTER', '', '714.00', '1'),
(390, 0, '4PCS. SPARK PLUG', '', '936.00', '1'),
(390, 0, '1 QRT. COOLANT', '', '350.00', '1'),
(391, 127, '', '', '2100.00', '1'),
(391, 0, '1PC. CLUTCH COVER', '', '3400.00', '1'),
(391, 0, '1PC. CLUTCH DISC', '', '2300.00', '1'),
(391, 0, '1PC. RELEASE BEARING', '', '1200.00', '1'),
(392, 127, '', '', '2500.00', '1'),
(392, 0, '1PC. CLUTCH COVER', '', '3400.00', '1'),
(392, 0, '1PC. CLUTCH DISC', '', '2300.00', '1'),
(392, 0, '1PC. RELEASE BEARING', '', '1200.00', '1'),
(392, 0, '1LTR. GEAR OIL', '', '230.00', '1'),
(392, 0, 'CASH', '', '20.00', '1'),
(393, 0, '2PCS. TIRES', '', '1000.00', '1'),
(394, 62, '', '', '5300.00', '1'),
(395, 62, '', '', '2000.00', '1'),
(396, 523, '', '', '800.00', '1'),
(396, 0, 'CLEANING SOLVENTE', '', '50.00', '1'),
(397, 83, '', '', '800.00', '1'),
(397, 524, '', '', '1800.00', '1'),
(397, 0, '1PC. FUEL FILTER', '', '500.00', '1'),
(397, 0, '1PC. FUEL PUMP', '', '3500.00', '1'),
(398, 163, '', '', '500.00', '1'),
(398, 0, '1PC ALTERNATOR ASSY', '', '10500.00', '1'),
(398, 0, 'FREIGHT', '', '300.00', '1'),
(398, 0, '1PC. ALTERNATOR ASSY', '', '10500.00', '1'),
(398, 0, 'FREIGHT', '', '300.00', '1'),
(399, 0, '1PC. ALTERNATOR ASSY', '', '6700.00', '1'),
(399, 0, 'FREIGHT', '', '300.00', '1'),
(399, 0, 'CASH', '', '3800.00', '1'),
(400, 0, '1PC. FAN BELT', '', '300.00', '1'),
(401, 62, '', '', '12564.00', '1'),
(402, 525, '', '', '900.00', '1'),
(403, 62, '', '', '17700.00', '1'),
(404, 527, '', '', '50.00', '1'),
(404, 526, '', '', '50.00', '1'),
(404, 0, '1PC. HOSE CLAMP', '', '35.00', '1'),
(405, 528, '', '', '1000.00', '1'),
(406, 71, '', '', '150.00', '1'),
(406, 529, '', '', '150.00', '1'),
(406, 72, '', '', '150.00', '1'),
(406, 0, '5 LTRS. ENGINE OIL', '', '1150.00', '1'),
(406, 0, '5LTRS. ATF', '', '1300.00', '1'),
(406, 0, '1PC. OIL FILTER', '', '230.00', '1'),
(407, 116, '', '', '150.00', '1'),
(407, 0, '1PC. OIL FILTER', '', '850.00', '1'),
(407, 0, '8LTRS. ENGINE OIL', '', '2520.00', '1'),
(408, 43, '', '', '350.00', '1'),
(409, 530, '', '', '500.00', '1'),
(409, 0, 'PREVIOS PAYABLE TO SIR. JOHN', '', '1650.00', '1'),
(410, 396, '', '', '200.00', '1'),
(410, 395, '', '', '250.00', '1'),
(411, 116, '', '', '150.00', '1'),
(411, 531, '', '', '500.00', '1'),
(411, 199, '', '', '150.00', '1'),
(411, 0, '1PC. OIL FILTER', '', '650.00', '1'),
(411, 0, 'COOLANT', '', '300.00', '1'),
(411, 0, '7LTRS. ENGINE OIL', '', '1610.00', '1'),
(411, 0, '1PC. FAN BELT', '', '325.00', '1'),
(412, 62, '', '', '6060.00', '1'),
(413, 214, '', '', '900.00', '1'),
(413, 59, '', '', '500.00', '1'),
(413, 0, '1LTR. COOLANT', '', '300.00', '1'),
(414, 533, '', '', '500.00', '1'),
(414, 534, '', '', '180.00', '1'),
(414, 532, '', '', '800.00', '1'),
(414, 0, 'CLEANING SOLVENT ', '', '100.00', '1'),
(415, 535, '', '', '50.00', '1'),
(416, 536, '', '', '150.00', '1'),
(417, 537, '', '', '350.00', '1'),
(417, 538, '', '', '150.00', '1'),
(417, 539, '', '', '150.00', '1'),
(417, 0, '1PC. TRUNK CABLE', '', '450.00', '1'),
(418, 116, '', '', '150.00', '1'),
(418, 0, '1PC. OIL FILTER', '', '235.00', '1'),
(418, 0, 'CASH', '', '115.00', '1'),
(419, 0, 'CHARGE INVOICE # 2244', '', '6250.00', '1'),
(420, 0, 'CHARGE INVOICE # 2246', '', '5500.00', '1'),
(421, 0, 'CHARGE INVOICE # 2279', '', '30000.00', '1'),
(422, 0, 'CHARGE INVOICE # 2279', '', '31500.00', '1'),
(423, 0, 'CHARGE INVOICE # 2239', '', '1480.00', '1'),
(424, 62, '', '', '6830.00', '1'),
(425, 532, '', '', '350.00', '1'),
(426, 540, '', '', '150.00', '1'),
(427, 541, '', '', '700.00', '1'),
(427, 0, '2PCS. BUSHING @ 380', '', '760.00', '1'),
(428, 542, '', '', '150.00', '1'),
(428, 543, '', '', '1500.00', '1'),
(428, 544, '', '', '14500.00', '1'),
(428, 0, '3LTRS.ATF', '', '780.00', '1'),
(429, 0, 'CHARGE INVOICE # 2247', '', '3425.00', '1'),
(430, 0, 'CHARGE INVOICE # 2304-2305', '', '7170.00', '1'),
(431, 0, 'CHARGE INVOICE # 2217', '', '9170.00', '1'),
(432, 0, 'CHARGE INVOICE # 2245', '', '4850.00', '1'),
(433, 0, 'CHARGE INVOICE # 2229', '', '9600.00', '1'),
(434, 0, 'CHARGE INVOICE # 2228', '', '15470.00', '1'),
(435, 0, 'CHARGE INVOICE # 2302', '', '3611.00', '1'),
(436, 0, 'CHARGE INVOICE # 2212', '', '17670.00', '1'),
(437, 0, 'CHARGE INVOICE # 2237', '', '8661.00', '1'),
(438, 0, 'CHARGE INVOICE # 2232', '', '15470.00', '1'),
(439, 0, 'CHARGE INVOICE # 2264', '', '15470.00', '1'),
(440, 534, '', '', '250.00', '1'),
(441, 62, '', '', '900.00', '1'),
(441, 0, '1PC. BATTERY CLAMP', '', '315.00', '1'),
(441, 0, '1PC. SLAVE KIT', '', '210.00', '1'),
(441, 0, '1PC. CLUTCH MASTER REPAIR KIT', '', '60.00', '1'),
(441, 0, 'BRAKE FLUID', '', '160.00', '1'),
(442, 0, 'CHECK PAID', '', '6000.54', '1'),
(443, 0, 'CHARGE INVOICE # 2224', '', '15470.00', '1'),
(444, 49, '', '', '250.00', '1'),
(445, 546, '', '', '600.00', '1'),
(445, 0, '2MTRS. AUTO WIRE #14', '', '70.00', '1'),
(445, 0, '2MTRS. AUTO WIRE # 16', '', '60.00', '1'),
(445, 0, '1PC. STARTER BUTTON', '', '160.00', '1'),
(445, 0, '1PC. HEADLIGHT BULB', '', '260.00', '1'),
(446, 547, '', '', '350.00', '1'),
(446, 158, '', '', '150.00', '1'),
(447, 548, '', '', '350.00', '1'),
(447, 549, '', '', '400.00', '1'),
(447, 174, '', '', '350.00', '1'),
(447, 550, '', '', '150.00', '1'),
(447, 146, '', '', '50.00', '1'),
(447, 551, '', '', '50.00', '1'),
(447, 0, '1SET CARBORATOR KIT', '', '400.00', '1'),
(448, 406, '', '', '150.00', '1'),
(448, 0, 'ACCELERATOR CABLE', '', '1200.00', '1'),
(449, 552, '', '', '150.00', '1'),
(450, 553, '', '', '1500.00', '1'),
(451, 0, 'CHARGE INVOICE # 2309', '', '15470.00', '1'),
(452, 0, 'CHARGE INVOICE # 2306', '', '3295.00', '1'),
(453, 554, '', '', '350.00', '1'),
(453, 133, '', '', '800.00', '1'),
(453, 0, '1PC. IGNITION SWITCH', '', '2500.00', '1'),
(454, 0, 'CHARGE INVOICE # 2307', '', '3300.00', '1'),
(455, 555, '', '', '250.00', '1'),
(456, 556, '', '', '450.00', '1'),
(456, 0, '1PC. AXLE BOOTS', '', '200.00', '1'),
(457, 0, 'CHARGE INVOICE # 2281', '', '7200.00', '1'),
(458, 0, 'PARTIAL PAYMENT FOR REPAINTING OF RIMS INCLUDING CENTER CAP', '', '1700.00', '1'),
(459, 0, 'FULL PAYMENTFOR THE REPAINT OF 4PCS. RIMS INCLUDING CENTER CAP', '', '1500.00', '1'),
(460, 62, '', '', '7095.00', '1'),
(461, 0, 'CHARGE INVOICE # 2310-2311', '', '11985.00', '1'),
(462, 301, '', '', '150.00', '1'),
(463, 62, '', '', '3577.00', '1'),
(463, 0, '1PC. BRAKE MASTER', '', '3800.00', '1'),
(463, 0, 'BRAKE FLUID ', '', '160.00', '1'),
(464, 542, '', '', '150.00', '1'),
(464, 199, '', '', '150.00', '1'),
(464, 0, '1PC. FAN BELT ', '', '630.00', '1'),
(464, 0, '1PC FAN BELT', '', '540.00', '1'),
(464, 0, '1 GAL. ENGINE OIL', '', '950.00', '1'),
(464, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(465, 558, '', '', '250.00', '1'),
(466, 214, '', '', '950.00', '1'),
(466, 559, '', '', '350.00', '1'),
(466, 0, '2PCS. COOLANT', '', '300.00', '1'),
(467, 560, '', '', '250.00', '1'),
(467, 0, '1PC. TEMP. SENDER', '', '325.00', '1'),
(467, 0, '1PC. HOSE CLIP', '', '80.00', '1'),
(468, 561, '', '', '550.00', '1'),
(469, 62, '', '', '4800.00', '1'),
(469, 563, '', '', '1950.00', '1'),
(469, 0, '1PC. AUX FAN MOTOR', '', '250.00', '1'),
(470, 62, '', '', '4800.00', '1'),
(471, 116, '', '', '150.00', '1'),
(472, 564, '', '', '350.00', '1'),
(473, 565, '', '', '350.00', '1'),
(474, 566, '', '', '150.00', '1'),
(474, 561, '', '', '250.00', '1'),
(474, 567, '', '', '250.00', '1'),
(474, 0, '1PC. OIL SENDER', '', '200.00', '1'),
(474, 0, '1LTRS. COOLANT', '', '300.00', '1'),
(474, 0, '1LTR. OIL/ ENGINE', '', '230.00', '1'),
(475, 0, 'CHARGE INVOICE # 2316', '', '6944.00', '1'),
(476, 131, '', '', '1500.00', '1'),
(476, 568, '', '', '250.00', '1'),
(476, 569, '', '', '150.00', '1'),
(476, 0, '1PC. CLUTCH LINING', '', '1500.00', '1'),
(476, 0, '1PC. CLUTCH PRESSURE', '', '2700.00', '1'),
(476, 0, '1PC. CLUTCH SLAVE REPAIR KIT', '', '60.00', '1'),
(476, 0, '3LTRS. GEAR OIL', '', '690.00', '1'),
(477, 116, '', '', '150.00', '1'),
(477, 570, '', '', '250.00', '1'),
(477, 0, '1PC. OIL FILTER', '', '250.00', '1'),
(478, 0, 'CHARGE INVOICE # 2323', '', '3335.00', '1'),
(479, 0, 'CHARGE INVOICE # 2325', '', '3276.00', '1'),
(480, 0, 'CHARGE INVOICE # 2312', '', '3900.00', '1'),
(481, 174, '', '', '350.00', '1'),
(481, 411, '', '', '450.00', '1'),
(481, 490, '', '', '300.00', '1'),
(481, 0, '1PC. HUB BEARING', '', '1600.00', '1'),
(482, 0, 'CHARGE INVOICE # 2324', '', '8340.00', '1'),
(483, 571, '', '', '900.00', '1'),
(483, 572, '', '', '500.00', '1'),
(483, 0, 'REPLACE HAND BRAKE & BRAKE SHOE', '', '450.00', '1'),
(484, 0, 'REPLACE BED LINER', '', '9500.00', '1'),
(485, 0, 'CHARGE INVOICE #2313-2314', '', '10000.00', '1'),
(486, 0, 'CHARGE INVOICE # 2328', '', '6760.00', '1'),
(487, 0, 'CHARGE INVOICE # 2320', '', '5000.00', '1'),
(488, 0, 'CHARGE INVOICE # 2248', '', '15470.00', '1'),
(489, 0, 'TIGHTEN BOLT', '', '600.00', '1'),
(489, 0, 'BOLT', '', '100.00', '1'),
(490, 0, 'CHARGE INVOICE # 2250', '', '11100.00', '1'),
(491, 0, 'CHARGE INVOICE # 2326-2327', '', '6385.00', '1'),
(492, 0, 'CHARGE INVOICE # 2315', '', '12000.00', '1'),
(493, 146, '', '', '5600.00', '1'),
(494, 0, 'REPAIR & CLEAN THERMOSTAT', '', '350.00', '1'),
(495, 385, '', '', '100.00', '1'),
(496, 62, '', '', '4290.00', '1'),
(497, 62, '', '', '250.00', '1'),
(498, 62, '', '', '1450.00', '1'),
(499, 62, '', '', '900.00', '1'),
(500, 62, '', '', '8800.00', '1'),
(501, 62, '', '', '17000.00', '1'),
(502, 62, '', '', '700.00', '1'),
(503, 62, '', '', '4300.00', '1'),
(504, 116, '', '', '150.00', '1'),
(505, 62, '', '', '350.00', '1'),
(506, 0, 'CHARGE INVOICE # 2249', '', '6115.00', '1'),
(507, 0, 'CHARGE INVOICE # 2321', '', '3350.00', '1'),
(508, 0, 'CHARGE INVOICE # 2322', '', '1750.00', '1'),
(509, 0, 'CHARGE INVOICE # 2336', '', '2565.00', '1'),
(510, 191, '', '', '100.00', '1'),
(511, 62, '', '', '1000.00', '1'),
(512, 62, '', '', '350.00', '1'),
(513, 62, '', '', '250.00', '1'),
(514, 25, '', '', '150.00', '1'),
(514, 0, '1PC. FUEL FILTER', '', '450.00', '1'),
(515, 116, '', '', '150.00', '1'),
(515, 254, '', '', '350.00', '1'),
(516, 62, '', '', '550.00', '1'),
(517, 0, 'CHARGE INVOICE # 2335', '', '3895.00', '1'),
(518, 0, 'CHARGE INVOICE # 2317-2318', '', '7140.00', '1'),
(519, 73, '', '', '1500.00', '1'),
(520, 0, 'CHARGE INVOICE # 2330-2331', '', '48830.00', '1'),
(521, 0, 'CHARGE INVOICE # 2332', '', '9898.00', '1'),
(522, 0, 'CHARGE INVOICE # 2319', '', '3380.00', '1'),
(523, 0, 'CHARGE INVOICE # 2339', '', '5100.00', '1'),
(524, 0, 'CHARGE INVOICE # 2338', '', '3780.00', '1'),
(525, 62, '', '', '7600.00', '1'),
(526, 62, '', '', '3070.00', '1'),
(527, 116, '', '', '150.00', '1'),
(527, 0, '4 LTRS. ENGINE OIL', '', '950.00', '1'),
(527, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(528, 75, '', '', '350.00', '1'),
(529, 0, 'CHARGE INVOICE # 2344', '', '69042.50', '1'),
(530, 62, '', '', '6300.00', '1'),
(531, 62, '', '', '1800.00', '1'),
(532, 62, '', '', '5400.00', '1'),
(533, 158, '', '', '250.00', '1'),
(534, 0, 'ADJUST CABLE', '', '350.00', '1'),
(535, 0, 'CHARGE INVOICE # 2343', '', '8000.00', '1'),
(536, 62, '', '', '150.00', '1'),
(537, 62, '', '', '350.00', '1'),
(538, 131, '', '', '1200.00', '1'),
(538, 0, '4PCS. GEAR OIL', '', '920.00', '1'),
(538, 0, '1PC RELEASE BEARING', '', '950.00', '1'),
(539, 0, '1LTR. COOLANT', '', '300.00', '1'),
(540, 62, '', '', '1400.00', '1'),
(541, 0, 'CHARGE INVOICE # 2218', '', '1880.00', '1'),
(542, 116, '', '', '150.00', '1'),
(542, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(542, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(543, 62, '', '', '3000.00', '1'),
(544, 25, '', '', '350.00', '1'),
(544, 0, '1PC. FUEL FILTER', '', '980.00', '1'),
(545, 62, '', '', '7340.00', '1'),
(546, 62, '', '', '7650.00', '1'),
(547, 116, '', '', '150.00', '1'),
(547, 385, '', '', '100.00', '1'),
(547, 0, '4PCS. SPARK PLUG', '', '600.00', '1'),
(547, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(547, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(548, 62, '', '', '32720.00', '1'),
(549, 0, 'EXCESS FROM LOA', '', '442.00', '1'),
(549, 116, '', '', '150.00', '1'),
(549, 49, '', '', '250.00', '1'),
(549, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(549, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(549, 0, '1PC. AIR FILTER', '', '714.00', '1'),
(549, 0, '4PCS. SPARK PLUG', '', '936.00', '1'),
(549, 0, '1QRT. COOLANT', '', '350.00', '1'),
(550, 0, 'EXCESS FROM LOA', '', '442.00', '1'),
(551, 62, '', '', '250.00', '1'),
(552, 0, 'CHARGE INVOICE # 2345', '', '62340.00', '1'),
(553, 0, 'CHARGE INVOICE # 2292', '', '7910.00', '1'),
(554, 62, '', '', '1100.00', '1'),
(555, 62, '', '', '800.00', '1'),
(556, 62, '', '', '3160.00', '1'),
(557, 62, '', '', '200.00', '1'),
(558, 62, '', '', '12000.00', '1'),
(559, 62, '', '', '950.00', '1'),
(559, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(559, 0, '1PC.OIL FILTER', '', '290.00', '1'),
(560, 185, '', '', '250.00', '1'),
(561, 289, '', '', '900.00', '1'),
(561, 0, '1SET BRAKE SHOE', '', '2300.00', '1'),
(562, 0, '1PC. FENDER LINER', '', '1800.00', '1'),
(562, 0, '11 PCS. CLIPS', '', '400.00', '1'),
(563, 62, '', '', '1210.00', '1'),
(564, 62, '', '', '2500.00', '1'),
(565, 62, '', '', '1100.00', '1'),
(566, 0, 'ADJUST', '', '150.00', '1'),
(567, 0, 'CHARGE INVOICE # 2346', '', '21942.25', '1'),
(568, 0, 'CHARGE INVOICE # 2349', '', '4200.00', '1'),
(569, 0, 'CHARGE INVOICE # 2341', '', '9009.00', '1'),
(570, 0, 'CHARGE INVOICE # 2342', '', '59158.40', '1'),
(571, 25, '', '', '250.00', '1'),
(571, 0, '1PC. FUEL FILTER', '', '550.00', '1'),
(572, 62, '', '', '3500.00', '1'),
(573, 62, '', '', '5100.00', '1'),
(574, 62, '', '', '5000.00', '1'),
(575, 62, '', '', '4200.00', '1'),
(576, 62, '', '', '2330.00', '1'),
(577, 62, '', '', '6200.00', '1'),
(578, 116, '', '', '150.00', '1'),
(578, 49, '', '', '250.00', '1'),
(578, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(578, 0, '1PC. OIL FILTER', '', '290.00', '1'),
(578, 0, '4 PCS. SPARK PLUG', '', '800.00', '1'),
(578, 0, '1 PC AIR FILTER', '', '695.00', '1'),
(579, 62, '', '', '5400.00', '1'),
(580, 62, '', '', '5100.00', '1'),
(581, 62, '', '', '61975.00', '1'),
(582, 0, 'CHARGE INVOICE # 2282', '', '1420.00', '1'),
(583, 62, '', '', '4500.00', '1'),
(584, 0, 'CHARGE INVOICE # 2283', '', '4380.00', '1'),
(585, 88, '', '', '2500.00', '1'),
(586, 62, '', '', '17030.00', '1'),
(587, 535, '', '', '50.00', '1'),
(588, 62, '', '', '16000.00', '1'),
(589, 62, '', '', '16150.00', '1'),
(590, 62, '', '', '150.00', '1'),
(591, 62, '', '', '7800.00', '1'),
(593, 62, '', '', '5530.00', '1'),
(594, 62, '', '', '4900.00', '1'),
(595, 385, '', '', '500.00', '1'),
(595, 0, '6PCS. SPARK PLUG', '', '700.00', '1'),
(596, 116, '', '', '150.00', '1'),
(596, 385, '', '', '100.00', '1'),
(596, 0, '4PCS. SPARK PLUG', '', '1000.00', '1'),
(596, 0, '4LTRS. ENGINE OIL', '', '920.00', '1'),
(596, 0, '1PC. OIL FILTER', '', '280.00', '1'),
(597, 62, '', '', '350.00', '1'),
(598, 62, '', '', '250.00', '1'),
(599, 62, '', '', '7250.00', '1'),
(600, 0, 'CHARGE INVOICE # 2288', '', '6850.00', '1'),
(601, 0, 'CHARGE INVOICE # 2287', '', '5250.00', '1'),
(602, 0, 'CHARGE INVOICE # 2284', '', '6760.00', '1'),
(603, 0, 'CHARGE INVOICE # 2294', '', '8925.00', '1'),
(604, 0, 'CHARGE INVOICE # 2238', '', '4130.00', '1'),
(605, 0, 'CHARGE INVOICE # 2295', '', '5250.00', '1'),
(606, 0, 'CHARGE INVOICE # 2291', '', '3640.00', '1'),
(607, 0, 'CHARGE INVOICE # 2333', '', '9200.00', '1'),
(608, 0, 'CHARGE INVOICE # 2340', '', '12000.00', '1'),
(609, 62, '', '', '4500.00', '1'),
(610, 254, '', '', '350.00', '1'),
(611, 62, '', '', '600.00', '1'),
(612, 0, 'CHARGE INVOICE # 2289', '', '5400.00', '1'),
(613, 0, 'CHARGE INVOICE # 2221', '', '4350.00', '1'),
(614, 0, 'CHARGE INVOICE # 2290', '', '25020.00', '1'),
(615, 0, 'CHARGE INVOICE # 1837', '', '6800.00', '1'),
(616, 62, '', '', '2000.00', '1'),
(617, 62, '', '', '600.00', '1'),
(618, 62, '', '', '5700.00', '1'),
(619, 0, 'CHARGE INVOICE # 2243', '', '6100.00', '1'),
(620, 62, '', '', '250.00', '1'),
(621, 62, '', '', '1790.00', '1'),
(622, 62, '', '', '250.00', '1'),
(623, 385, '', '', '150.00', '1'),
(623, 0, '4PCS. SPARK PLUG', '', '450.00', '1'),
(624, 62, '', '', '8400.00', '1'),
(625, 62, '', '', '11335.73', '1'),
(626, 62, '', '', '600.00', '1'),
(627, 62, '', '', '14480.00', '1'),
(628, 62, '', '', '900.00', '1'),
(629, 62, '', '', '8500.00', '1'),
(630, 0, 'CHARGE INVOICE # 2286', '', '3990.00', '1'),
(631, 0, 'CHARGE INVOICE # 201301', '', '4600.00', '1'),
(632, 415, '', '', '700.00', '1'),
(632, 0, '2PCS. BALLJOINT', '', '1400.00', '1'),
(633, 140, '', '', '600.00', '1'),
(633, 116, '', '', '150.00', '1'),
(633, 0, '1GAL. ENGINE OIL', '', '950.00', '1'),
(634, 62, '', '', '1400.00', '1'),
(635, 62, '', '', '9900.00', '1'),
(636, 62, '', '', '2640.00', '1');

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=573 ;

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
(572, 'REPLACE FRONT BRAKE PADS', 1, '1');

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=92 ;

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
(91, 'nanettee', '1', '2013-06-21 01:06:08');

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
) ENGINE=MEMORY DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=207 ;

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
(206, 'SPORTAGE', '1');

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=636 ;

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
(67, 'KEL-935', 31, 72, '', 92, '1'),
(68, 'zlt-784', 10, 52, '', 93, '1'),
(69, 'NQL-699', 33, 59, '', 58, '1'),
(70, 'XJC-760', 37, 37, '', 95, '1'),
(71, 'ZCG-528', 40, 77, '', 96, '1'),
(72, 'KCG-656', 33, 40, '', 97, '1'),
(73, 'VEZ-620', 31, 78, '', 98, '1'),
(74, 'NO PLATE', 32, 79, '', 99, '1'),
(75, 'ZJW-965', 10, 80, '', 101, '1'),
(76, 'NO PLATE', 1, 81, '', 102, '1'),
(77, 'ZJW-965', 10, 80, '', 101, '1'),
(78, 'MFN 122', 31, 82, '', 27, '1'),
(79, 'NO PLATE', 1, 28, '', 105, '1'),
(80, 'KEG-189', 1, 83, '', 106, '1'),
(81, 'GTB-254', 33, 84, '', 107, '1'),
(82, 'KBU-537', 1, 85, '', 108, '1'),
(83, 'KBU-537', 1, 85, '', 108, '1'),
(84, 'TPS 526', 1, 86, '', 110, '1'),
(85, 'ZGP662', 1, 87, '', 111, '1'),
(86, 'ZGP662', 1, 87, '', 111, '1'),
(87, 'KDM-249', 36, 52, '', 49, '1'),
(88, 'PBO-950', 10, 52, '', 114, '1'),
(89, 'KCH-342', 22, 40, '', 115, '1'),
(90, 'ZTR 740', 1, 88, '', 116, '1'),
(91, 'ZPE-142', 10, 89, '', 117, '1'),
(92, 'ZPE-142', 10, 89, '', 117, '1'),
(93, 'KFY-684', 22, 90, '', 119, '1'),
(94, 'KFN-437', 10, 91, '', 120, '1'),
(95, 'NDL-541', 10, 52, '', 121, '1'),
(96, 'ZTR-990', 10, 42, '', 122, '1'),
(97, 'ZKP-410', 41, 92, '', 123, '1'),
(98, 'ZKP-410', 10, 93, '', 124, '1'),
(99, 'ZRW-466', 2, 88, '', 125, '1'),
(100, 'PMB-177', 10, 94, '', 126, '1'),
(101, 'KGJ-185', 31, 95, '', 127, '1'),
(102, 'KDP-703', 10, 70, '', 128, '1'),
(103, 'NO PLATE', 31, 33, '', 129, '1'),
(104, 'NO PLATE', 32, 73, '', 44, '1'),
(105, 'KDU-175', 1, 96, '', 131, '1'),
(106, 'ZYX-222', 22, 91, '', 132, '1'),
(107, 'GHR-257', 1, 69, '', 132, '1'),
(108, 'KCF-884', 1, 39, '', 132, '1'),
(109, 'KCF-648', 22, 66, '', 135, '1'),
(110, 'GJR-238', 2, 43, '', 136, '1'),
(111, 'SHJ-477', 22, 97, '', 137, '1'),
(112, 'XMR-211', 2, 98, '', 138, '1'),
(113, 'THG-207', 10, 94, '', 139, '1'),
(114, 'ZMH 389', 36, 88, '', 141, '1'),
(115, 'KFZ-679', 22, 99, '', 142, '1'),
(116, 'NO PLATE', 32, 73, '', 143, '1'),
(117, 'NO PLATE', 10, 94, '', 126, '1'),
(118, 'KBP-657', 1, 100, '', 45, '1'),
(119, 'XGJ-146', 22, 40, '', 146, '1'),
(120, 'KDE-850', 10, 43, '', 147, '1'),
(121, 'ZGP-662', 1, 101, '', 148, '1'),
(122, 'NO PLATE', 41, 89, '', 149, '1'),
(123, 'ZRM-270', 10, 52, '', 149, '1'),
(124, 'UKD 396', 33, 69, '', 89, '1'),
(125, 'ZCG-528', 1, 59, '', 96, '1'),
(126, 'TGD-371', 10, 102, '', 153, '1'),
(127, 'NOE 844', 36, 103, '', 157, '1'),
(128, 'URB-361', 22, 78, '', 158, '1'),
(129, 'PKI-588', 10, 52, '', 159, '1'),
(130, 'WHV-610', 42, 78, '', 58, '1'),
(131, 'UBS-806', 37, 79, '', 161, '1'),
(132, 'ZPU-213', 1, 63, '', 162, '1'),
(133, 'PIX-852', 10, 52, '', 163, '1'),
(134, 'RCA-655', 2, 104, '', 164, '1'),
(135, 'KEZ-926', 43, 105, '', 165, '1'),
(136, 'KEZ-926', 44, 105, '', 165, '1'),
(137, 'KBJ-555', 45, 106, '', 167, '1'),
(138, 'XGS-555', 43, 107, '', 168, '1'),
(139, 'GJY 555', 31, 37, '', 70, '1'),
(140, 'YDF-296', 22, 108, '', 70, '1'),
(141, 'NO PLATE', 2, 78, '', 171, '1'),
(142, 'WTG-939', 36, 40, '', 172, '1'),
(143, 'NO PLATE', 36, 109, '', 173, '1'),
(144, 'KDP-466', 10, 110, '', 174, '1'),
(145, 'XJC-760', 10, 114, '', 175, '1'),
(146, 'TDS-280', 1, 94, '', 176, '1'),
(147, 'AIG-207', 10, 47, '', 177, '1'),
(148, 'GEV-975', 10, 115, '', 178, '1'),
(149, 'THG-207`', 10, 116, '', 177, '1'),
(150, 'STJ-483', 44, 118, '', 180, '1'),
(151, 'KDF-860', 10, 97, '', 181, '1'),
(152, 'GGV-946', 39, 78, '', 182, '1'),
(153, 'UTV-141', 1, 39, '', 183, '1'),
(154, 'KDV-819', 10, 44, '', 184, '1'),
(155, 'XMR-211', 2, 33, '', 171, '1'),
(156, 'GHJ-358', 31, 78, '', 186, '1'),
(157, 'ZHM-389', 1, 88, '', 187, '1'),
(158, 'PUD-750', 22, 54, '', 83, '1'),
(159, 'KVU-924', 10, 52, '', 83, '1'),
(160, 'ZRM-710', 10, 52, '', 190, '1'),
(161, 'KBP-657', 1, 121, '', 191, '1'),
(162, 'XHX-944', 3, 37, '', 192, '1'),
(163, 'GHH-333', 31, 53, '', 193, '1'),
(164, 'ZDK-482', 10, 93, '', 194, '1'),
(165, 'ZPU-213', 1, 63, '', 162, '1'),
(166, 'ZPU-213', 1, 63, '', 162, '1'),
(167, 'ZPU-213', 1, 63, '', 162, '1'),
(168, 'ZPU-213', 1, 63, '', 162, '1'),
(169, 'KDM-249', 32, 122, '', 199, '1'),
(170, 'KDM-249', 36, 52, '', 49, '1'),
(171, 'MEZ-141', 22, 36, '', 27, '1'),
(172, 'MFN 122', 31, 123, '', 27, '1'),
(173, 'KEZ-926', 2, 78, '', 165, '1'),
(174, 'MBR-615', 2, 124, '', 205, '1'),
(175, 'NO PLATE', 32, 73, '', 206, '1'),
(176, 'TJD-176', 2, 51, '', 62, '1'),
(177, 'GDL-522', 2, 125, '', 208, '1'),
(178, 'GDL-522`', 2, 125, '', 208, '1'),
(179, 'KGB-589', 10, 126, '', 210, '1'),
(180, 'CSL-577', 31, 127, '', 211, '1'),
(181, 'GEV-975', 10, 128, '', 212, '1'),
(182, 'KEF-875', 31, 43, '', 213, '1'),
(183, 'ZMH-389', 1, 52, '', 141, '1'),
(184, 'ZNG-361', 32, 43, '', 215, '1'),
(185, 'ZDX-543', 24, 129, '', 216, '1'),
(186, 'KEY-684', 22, 90, '', 217, '1'),
(187, 'YCJ-718', 37, 130, '', 218, '1'),
(188, 'KCZ-588', 3, 76, '', 219, '1'),
(189, 'KCN-367', 36, 40, '', 220, '1'),
(190, 'GJY-555', 31, 37, '', 70, '1'),
(191, 'ZTR-517', 10, 65, '', 71, '1'),
(192, 'NIY 431', 2, 65, '', 223, '1'),
(193, 'ZKP-420', 10, 93, '', 124, '1'),
(194, 'KVU-924', 25, 54, '', 83, '1'),
(195, 'ZTL-451', 10, 65, '', 226, '1'),
(196, 'NKO-749', 1, 65, '', 227, '1'),
(197, 'ZSS-343', 10, 88, '', 228, '1'),
(198, 'PYI-919', 46, 52, '', 229, '1'),
(199, 'KCG-196', 1, 78, '', 230, '1'),
(200, 'WLP-276', 1, 132, '', 231, '1'),
(201, 'UGN-620', 31, 53, '', 232, '1'),
(202, 'TZL-389', 22, 67, '', 58, '1'),
(203, 'KDL-558', 32, 133, '', 234, '1'),
(204, 'ZRW-466', 32, 74, '', 235, '1'),
(205, 'ZRW-466', 2, 88, '', 236, '1'),
(206, 'NO PLATE', 32, 73, '', 237, '1'),
(207, 'PHO-378', 22, 134, '', 237, '1'),
(208, 'ZNG-361', 10, 76, '', 215, '1'),
(209, 'GKZ-601', 10, 78, '', 240, '1'),
(210, 'KBY- 402', 1, 135, '', 241, '1'),
(211, 'XBN-266', 31, 78, '', 27, '1'),
(212, 'GST-813', 2, 78, '', 243, '1'),
(213, 'TJD-176', 2, 78, '', 62, '1'),
(214, 'NO PLATE', 32, 73, '', 76, '1'),
(215, 'GHR-257', 1, 69, '', 132, '1'),
(216, 'III-209', 2, 136, '', 247, '1'),
(217, 'TRV-304', 31, 127, '', 248, '1'),
(218, 'NKO-755', 2, 65, '', 249, '1'),
(219, 'TLL-389', 22, 67, '', 58, '1'),
(220, 'WLP-276', 3, 132, '', 231, '1'),
(221, 'KFE-435', 2, 52, '', 252, '1'),
(222, 'KCF-884', 1, 78, '', 132, '1'),
(223, 'ZHL-789', 10, 81, '', 254, '1'),
(224, 'ZHT-951', 10, 81, '', 255, '1'),
(225, 'SHJ-477', 22, 97, '', 62, '1'),
(226, 'UQD-136', 1, 61, '', 257, '1'),
(227, 'GKZ-601', 37, 78, '', 258, '1'),
(228, 'ZYX-222', 22, 91, '', 132, '1'),
(229, 'UQD-136', 1, 61, '', 257, '1'),
(230, 'TJD-176', 2, 78, '', 62, '1'),
(231, 'ZRW-466', 2, 88, '', 236, '1'),
(232, 'NDO-841', 22, 137, '', 263, '1'),
(233, 'USR-727', 3, 138, '', 264, '1'),
(234, 'ZMH-389', 1, 52, '', 141, '1'),
(235, 'KCT-107', 10, 40, '', 31, '1'),
(236, 'ZRC-290', 10, 89, '', 267, '1'),
(237, 'NOE-521', 1, 52, '\r\n', 269, '1'),
(238, 'ZPA-807', 2, 43, '', 270, '1'),
(239, 'UGI-829', 10, 52, '', 254, '1'),
(240, 'NO PLATE', 32, 73, '', 272, '1'),
(241, 'CSL-577', 47, 28, '', 211, '1'),
(242, 'KFD-269', 22, 139, '', 274, '1'),
(243, 'GJT-362', 36, 66, '', 275, '1'),
(244, 'ZRD-124', 10, 61, '', 276, '1'),
(245, 'ZRD-124', 10, 141, '', 276, '1'),
(246, 'SEH-870', 3, 142, '', 278, '1'),
(247, 'KCS-703', 10, 37, '', 279, '1'),
(248, 'NO PLATE', 36, 62, '', 280, '1'),
(249, 'NO PLATE', 10, 37, '', 281, '1'),
(250, 'NO PLATE', 32, 127, '', 282, '1'),
(251, 'GEV-426', 37, 128, '', 212, '1'),
(252, 'NO PLATE', 10, 143, '', 284, '1'),
(253, 'NO PLATE', 32, 73, '', 285, '1'),
(254, 'PVI-747', 32, 144, '', 286, '1'),
(255, 'KDG-948', 22, 107, '', 287, '1'),
(256, 'ZMH-389', 36, 52, '', 141, '1'),
(257, 'JDF-946', 37, 82, '', 289, '1'),
(258, 'WDY-595', 2, 145, '', 290, '1'),
(259, 'AJM-818', 25, 67, '', 291, '1'),
(260, 'KGF-629', 3, 58, '', 292, '1'),
(261, 'ZNT-582', 1, 52, '', 293, '1'),
(262, 'KDS-796', 33, 59, '', 157, '1'),
(263, 'MAE-280', 2, 135, '\r\n', 295, '1'),
(264, 'GSI-813', 2, 67, '', 243, '1'),
(265, 'ZTR-170', 32, 144, '', 297, '1'),
(266, 'NO PLATE', 32, 73, '', 298, '1'),
(267, 'GTB-254', 33, 127, '', 299, '1'),
(268, 'KDX-177', 10, 95, '', 300, '1'),
(269, 'ZNY-414', 2, 55, '', 301, '1'),
(270, 'LDD-210', 10, 35, '', 302, '1'),
(271, 'KDF-839', 22, 97, '', 303, '1'),
(272, 'YFB-755', 31, 146, '', 304, '1'),
(273, 'PRI-747', 10, 52, '', 285, '1'),
(274, 'XKU-437', 31, 43, '', 306, '1'),
(275, 'LMS-880', 1, 95, '', 307, '1'),
(276, 'XAB-537', 3, 108, '', 308, '1'),
(277, 'WDY-595', 2, 145, '', 290, '1'),
(278, 'KDN-427', 10, 147, '', 310, '1'),
(279, 'NO PLATE', 36, 62, '', 311, '1'),
(280, 'ZMR-406', 37, 89, '', 312, '1'),
(281, 'LNG-327', 2, 149, '', 313, '1'),
(282, 'ZKP-420', 10, 93, '', 124, '1'),
(283, 'ZKP-420', 10, 93, '', 124, '1'),
(284, 'NO PLATE', 10, 37, '', 281, '1'),
(285, 'KCK-301', 3, 119, '', 317, '1'),
(286, 'KEP-900', 22, 150, '', 318, '1'),
(287, 'KDY-177', 10, 151, '', 300, '1'),
(288, 'TJV-567', 3, 153, '', 320, '1'),
(289, 'KFL-939', 22, 154, '', 321, '1'),
(290, 'ZTR-170', 32, 52, '', 297, '1'),
(291, 'XHV-831', 10, 37, '', 323, '1'),
(292, 'KEY-282', 1, 151, '', 324, '1'),
(293, 'GGV-946', 33, 78, '', 325, '1'),
(294, 'ZNT-582', 32, 52, '', 293, '1'),
(295, 'ZRW-466', 2, 88, '', 236, '1'),
(296, 'ZKP-420', 10, 93, '', 124, '1'),
(297, 'ZRN-459', 32, 74, '', 329, '1'),
(298, 'NKO-749', 1, 65, '', 330, '1'),
(299, 'NKO-749', 1, 65, '', 330, '1'),
(300, 'ZTR-669', 10, 52, '', 332, '1'),
(301, 'ZTR-669', 10, 52, '', 333, '1'),
(302, 'ZLN-861', 1, 93, '', 334, '1'),
(303, 'ZLN-861', 1, 93, '', 334, '1'),
(304, 'ZNT-582', 1, 88, '', 293, '1'),
(305, 'ZNT-582', 32, 52, '', 337, '1'),
(306, 'NO PLATE', 32, 73, '', 338, '1'),
(307, 'TIP-991', 32, 155, '', 339, '1'),
(308, 'NOK-251', 22, 79, '', 83, '1'),
(309, 'KEL-874', 22, 156, '', 341, '1'),
(310, 'PVI-539', 10, 42, '', 342, '1'),
(311, 'KDX-177', 10, 151, '', 300, '1'),
(312, 'KDC-286', 2, 147, '', 344, '1'),
(313, 'PVI-747', 10, 52, '', 285, '1'),
(314, 'KVU- 621', 22, 157, '', 83, '1'),
(315, 'ZLJ--949', 32, 89, '', 42, '1'),
(316, 'PHO-378', 32, 134, '', 237, '1'),
(317, 'ZRC-290', 10, 89, '', 349, '1'),
(318, 'KEL-874', 22, 156, '', 341, '1'),
(319, 'LCL-832', 48, 66, '', 351, '1'),
(320, 'XLV-984', 2, 97, '', 352, '1'),
(321, 'WDY-595', 32, 145, '', 290, '1'),
(322, 'KBP-657', 1, 121, '', 45, '1'),
(323, 'ZPU-212', 1, 63, '', 355, '1'),
(324, 'XTF-691', 32, 73, '', 356, '1'),
(325, 'NO PLATE', 32, 73, '', 76, '1'),
(326, 'LNG-327', 2, 67, '', 313, '1'),
(327, 'NOQ-707', 10, 91, '', 359, '1'),
(328, 'XTF-691', 32, 73, '', 360, '1'),
(329, 'XTF-961', 1, 42, '', 361, '1'),
(330, 'GDW-136', 32, 158, '', 362, '1'),
(331, 'YJK-675', 49, 159, '', 364, '1'),
(332, 'LCL-832', 48, 66, '', 351, '1'),
(333, 'KBP-657', 1, 121, '', 45, '1'),
(334, 'YFB-755', 31, 160, '', 304, '1'),
(335, 'ZLN-861', 32, 93, '', 334, '1'),
(336, 'ZLN-861', 32, 93, '', 334, '1'),
(337, 'ZLN-861', 32, 93, '', 334, '1'),
(338, 'KCD-519', 2, 57, '', 371, '1'),
(339, 'GKZ-601', 37, 78, '', 372, '1'),
(340, 'WBG-922', 22, 161, '', 373, '1'),
(341, 'KDN-353', 10, 37, '', 374, '1'),
(342, 'NO PLATE', 22, 39, '', 375, '1'),
(343, 'KGC-200', 25, 162, '', 376, '1'),
(344, 'HID-175', 1, 163, '', 377, '1'),
(345, 'NO PLATE', 2, 67, '', 313, '1'),
(346, 'WJU-947', 10, 164, '', 379, '1'),
(347, 'WEM-368', 3, 57, '', 381, '1'),
(348, 'KDZ-156', 32, 151, '', 382, '1'),
(349, 'ZPC-471', 10, 52, '', 382, '1'),
(350, 'OEV-356', 22, 134, '', 76, '1'),
(351, 'KBY-537', 36, 62, '', 311, '1'),
(352, 'KCG-917', 22, 165, '', 386, '1'),
(353, 'NOE-521', 1, 42, '', 269, '1'),
(354, 'KDD-971', 10, 126, '', 32, '1'),
(355, 'KDR-243', 32, 134, '', 389, '1'),
(356, 'XBN-266', 31, 166, '', 27, '1'),
(357, 'UFT-620', 50, 167, '', 391, '1'),
(358, 'RDM-798', 32, 168, '', 392, '1'),
(359, 'WMD-562', 32, 145, '', 393, '1'),
(360, 'KCG-608', 1, 169, '', 394, '1'),
(361, 'NO PLATE', 32, 73, '', 298, '1'),
(362, 'NO PLATE', 32, 73, '', 330, '1'),
(363, 'ZNT-572', 2, 88, '', 397, '1'),
(364, 'ZNT-572', 2, 88, '', 397, '1'),
(365, 'KDY-259', 31, 156, '', 399, '1'),
(366, 'GHX-665', 2, 78, '', 400, '1'),
(367, 'GGM-661', 22, 149, '', 132, '1'),
(368, 'WMD-562', 31, 145, '', 402, '1'),
(369, 'KCS-463', 51, 66, '', 161, '1'),
(370, 'XBO-900', 52, 43, '', 404, '1'),
(371, 'KCZ- 517', 36, 127, '', 405, '1'),
(372, 'KCV-231', 22, 172, '', 243, '1'),
(373, 'KDP-374', 1, 173, '', 407, '1'),
(374, 'KCT-444', 10, 51, '', 281, '1'),
(375, 'NO PLATE', 32, 73, '', 355, '1'),
(376, 'KCG-588', 2, 76, '', 410, '1'),
(377, 'KCG-588', 3, 43, '', 410, '1'),
(378, 'KCZ-172', 10, 43, '', 412, '1'),
(379, 'XMR-211', 32, 33, '', 171, '1'),
(380, 'KCS-463', 3, 66, '', 161, '1'),
(381, 'KDM-194', 37, 174, '', 415, '1'),
(382, 'TLQ-940', 10, 52, '', 416, '1'),
(383, 'UKD-412', 3, 53, '', 417, '1'),
(384, 'UKD-412', 3, 51, '', 417, '1'),
(385, 'GHR-704', 2, 175, '', 419, '1'),
(386, 'KCU-764', 10, 176, '', 161, '1'),
(387, 'KCS-463', 3, 66, '', 161, '1'),
(388, 'KDJ-539', 22, 78, '', 422, '1'),
(389, 'TIJ-622', 10, 155, '', 102, '1'),
(390, 'ZGN-690', 1, 81, '', 102, '1'),
(391, 'KDM-249', 36, 81, '', 49, '1'),
(392, 'NO PLATE', 32, 73, '', 426, '1'),
(393, 'WMD-562', 32, 103, '', 402, '1'),
(394, 'WCG-849', 31, 177, '', 428, '1'),
(395, 'AJM-818', 25, 67, '', 429, '1'),
(396, 'YBV-419', 48, 130, '', 430, '1'),
(397, 'KDM-194', 37, 178, '', 431, '1'),
(398, 'NO PLATE', 32, 73, '', 430, '1'),
(399, 'NO PLATE', 2, 149, '', 433, '1'),
(400, 'GDW-136', 37, 39, '', 362, '1'),
(401, 'LCL-832', 48, 66, '', 351, '1'),
(402, 'YJK-675', 32, 159, '', 436, '1'),
(403, 'GJG-536', 2, 78, '', 437, '1'),
(404, 'NO PLATE', 32, 154, '', 438, '1'),
(405, 'KDY-864', 10, 179, '', 439, '1'),
(406, 'NO PLATE', 1, 78, '', 440, '1'),
(407, 'NO PLATE', 2, 153, '', 441, '1'),
(408, 'KDJ-188', 36, 43, '', 443, '1'),
(409, 'KOV-297', 2, 56, '', 444, '1'),
(410, 'FRT-808', 22, 107, '', 445, '1'),
(411, 'NO PLATE', 10, 37, '', 281, '1'),
(412, 'KCB-241', 3, 165, '', 447, '1'),
(413, 'NO PLATE', 32, 73, '', 448, '1'),
(414, 'NO PLATE', 2, 180, '', 449, '1'),
(415, 'KTU-553', 25, 28, '', 450, '1'),
(416, 'KCF-884', 1, 33, '', 132, '1'),
(417, 'WJU-947', 10, 164, '', 379, '1'),
(418, 'ZPC-471', 10, 52, '', 382, '1'),
(419, 'NO PLATE', 32, 73, '', 454, '1'),
(420, 'NO PLATE', 32, 73, '', 454, '1'),
(421, 'OEV-356', 22, 134, '', 76, '1'),
(422, 'NO PLATE', 1, 181, '', 457, '1'),
(423, 'NO PLATE', 32, 73, '', 458, '1'),
(424, 'YFB-755', 31, 174, '', 304, '1'),
(425, 'MFV-573', 22, 90, '', 460, '1'),
(426, 'RDW-648', 39, 119, '', 461, '1'),
(427, 'ZHT-951', 10, 93, '', 462, '1'),
(428, 'TIG-509', 2, 52, '', 463, '1'),
(429, 'ZKP-420', 10, 93, '', 124, '1'),
(430, 'ZLN-871', 32, 89, '', 465, '1'),
(431, 'PVI-539', 32, 144, '', 466, '1'),
(432, 'PVI-539', 32, 144, '', 466, '1'),
(433, 'PVI-539', 32, 42, '', 466, '1'),
(434, 'ZRW-466', 2, 88, '', 236, '1'),
(435, 'NAO-606', 10, 65, '', 470, '1'),
(436, 'ZLJ--949', 10, 74, '', 471, '1'),
(437, 'NKO-755', 2, 52, '', 249, '1'),
(438, 'JCT-394', 3, 182, '', 473, '1'),
(439, 'KCM-313', 22, 183, '\r\n', 474, '1'),
(440, 'NO PLATE', 32, 73, '', 122, '1'),
(441, 'ZRC-290', 10, 89, '', 349, '1'),
(442, 'NO PLATE', 32, 73, '', 477, '1'),
(443, 'KCB-241', 3, 165, '', 447, '1'),
(444, 'KCD- 382', 10, 116, '', 479, '1'),
(445, 'KCM-985', 22, 184, '', 205, '1'),
(446, 'AJM-818', 25, 39, '', 429, '1'),
(447, 'NKO-755', 2, 52, '', 249, '1'),
(448, 'NO PLATE', 10, 185, '', 483, '1'),
(449, 'TIG-509', 2, 52, '', 463, '1'),
(450, 'UIL-949', 10, 163, '', 51, '1'),
(451, 'XRD-841', 2, 153, '', 486, '1'),
(452, 'KVU-921', 25, 186, '', 83, '1'),
(453, 'NO PLATE', 32, 73, '', 445, '1'),
(454, 'ZFU-359', 3, 63, '', 489, '1'),
(455, 'ZLJ--949', 10, 74, '', 490, '1'),
(456, 'WKO-676', 22, 71, '', 471, '1'),
(457, 'NKO-676', 22, 71, '', 491, '1'),
(458, 'UEC-129', 22, 187, '', 493, '1'),
(459, 'NKO-755', 2, 65, '', 249, '1'),
(460, 'GHZ-724', 32, 62, '', 496, '1'),
(461, 'KCZ-588', 3, 76, '', 410, '1'),
(462, 'NO PLATE', 2, 94, '', 498, '1'),
(463, 'NO PLATE', 36, 62, '', 311, '1'),
(464, 'GTB-254', 32, 125, '', 107, '1'),
(465, 'PMB-177', 10, 3, '', 126, '1'),
(466, 'GMH-300', 22, 78, '', 502, '1'),
(467, 'XMV-471', 31, 43, '', 503, '1'),
(468, 'GNW-680', 3, 43, '', 504, '1'),
(469, 'KCD- 382', 10, 188, '', 505, '1'),
(470, 'KCB-241', 3, 165, '', 506, '1'),
(471, 'NO PLATE', 31, 107, '', 493, '1'),
(472, 'ZNK-416', 10, 89, '', 298, '1'),
(473, 'YEP-253', 3, 189, '', 509, '1'),
(474, 'ZNG-327', 2, 67, '', 313, '1'),
(475, 'ZPU-213', 1, 63, '', 162, '1'),
(476, 'ZJK-716', 31, 129, '', 512, '1'),
(477, 'TIR-586', 2, 190, '', 513, '1'),
(478, 'NO PLATE', 32, 73, '', 304, '1'),
(479, 'PQM-689', 1, 65, '', 515, '1'),
(480, 'NO PLATE', 22, 186, '', 516, '1'),
(481, 'NO PLATE', 22, 186, '', 516, '1'),
(482, 'NO PLATE', 31, 134, '', 517, '1'),
(483, 'ZTR-170', 2, 42, '', 297, '1'),
(484, 'TBQ-160', 2, 52, '', 519, '1'),
(485, 'PKQ-767', 32, 42, '', 520, '1'),
(486, 'ZKP-420', 10, 93, '', 124, '1'),
(487, 'ZEJ--821', 2, 78, '', 522, '1'),
(488, 'XRU-889', 32, 66, '', 523, '1'),
(489, 'ZNT-269', 10, 89, '', 524, '1'),
(490, 'NVO-264', 10, 52, '', 525, '1'),
(491, 'NO PLATE', 32, 73, '', 526, '1'),
(492, 'XMV-417', 31, 43, '', 503, '1'),
(493, 'NO PLATE', 2, 52, '', 528, '1'),
(494, 'GGV-946', 33, 78, '', 325, '1'),
(495, 'KBP-657', 1, 121, '', 45, '1'),
(496, 'NO PLATE', 32, 73, '', 531, '1'),
(497, 'GTS-813', 2, 67, '', 243, '1'),
(498, 'ZJP-470', 25, 63, '', 533, '1'),
(499, 'GTS-798', 25, 36, '', 534, '1'),
(500, 'KEC-213', 10, 63, '', 535, '1'),
(501, 'NO PLATE', 32, 184, '', 536, '1'),
(502, 'JCL-656', 1, 151, '', 537, '1'),
(503, 'GEV-976', 37, 128, '', 212, '1'),
(504, 'YRM-889', 22, 66, '', 523, '1'),
(505, 'ZKP-420', 10, 93, '', 124, '1'),
(506, 'ZKP-420', 10, 93, '', 540, '1'),
(507, 'ZKP-920', 32, 192, '', 78, '1'),
(508, 'NO PLATE', 2, 193, '', 449, '1'),
(509, 'NO PLATE', 32, 73, '', 544, '1'),
(510, 'NO PLATE', 31, 134, '', 545, '1'),
(511, 'FRT-808', 22, 107, '', 445, '1'),
(512, 'SHJ-237', 10, 59, '', 547, '1'),
(513, 'KDN-181', 10, 91, '', 548, '1'),
(514, 'UGN-620', 31, 78, '', 549, '1'),
(515, 'ZKP--920', 10, 76, '', 78, '1'),
(516, 'YAA-663', 37, 147, '', 551, '1'),
(517, 'KDE-266', 10, 59, '', 397, '1'),
(518, 'NO PLATE', 32, 73, '', 553, '1'),
(519, 'NO PLATE', 32, 73, '', 553, '1'),
(520, 'EOV-356', 22, 134, '', 76, '1'),
(521, 'PQO-122', 32, 194, '', 556, '1'),
(522, 'NKO-749', 1, 65, '', 330, '1'),
(523, 'TQG-966', 32, 163, '', 558, '1'),
(524, 'NO PLATE', 2, 78, '', 559, '1'),
(525, 'NO PLATE', 10, 73, '', 498, '1'),
(526, 'NO PLATE', 10, 151, '', 561, '1'),
(527, 'NO PLATE', 32, 73, '', 562, '1'),
(528, 'UIJ-175', 32, 52, '', 563, '1'),
(529, 'KDE-266', 10, 59, '', 564, '1'),
(530, 'TQG-966', 32, 52, '', 558, '1'),
(531, 'TQG-966', 32, 52, '', 558, '1'),
(532, 'GGV-946', 33, 78, '', 325, '1'),
(533, 'NO PLATE', 32, 73, '', 567, '1'),
(534, 'PDQ-660', 32, 190, '', 562, '1'),
(535, 'ZNT-572', 2, 52, '', 397, '1'),
(536, 'NO PLATE', 32, 119, '', 570, '1'),
(537, 'ZFU-359', 3, 63, '', 489, '1'),
(538, 'NO PLATE', 31, 43, '', 503, '1'),
(539, 'GTB-254', 39, 127, '', 107, '1'),
(540, 'NO PLATE', 2, 149, '', 574, '1'),
(541, 'NO PLATE', 32, 73, '', 32, '1'),
(542, 'NO PLATE', 32, 52, '', 576, '1'),
(543, 'NO PLATE', 37, 56, '', 577, '1'),
(544, 'KDJ-589', 10, 196, '', 578, '1'),
(545, 'NO PLATE', 32, 145, '', 290, '1'),
(546, 'NO PLATE', 32, 159, '', 580, '1'),
(547, 'NO PLATE', 32, 43, '', 581, '1'),
(548, 'TJK-332', 37, 39, '', 582, '1'),
(549, 'NO PLATE', 32, 52, '', 86, '1'),
(550, 'TJV-569', 3, 153, '', 320, '1'),
(551, 'TFO-924', 35, 54, '', 83, '1'),
(552, 'PIX-852', 32, 194, '', 163, '1'),
(553, 'NO PLATE', 22, 186, '', 516, '1'),
(554, 'NO PLATE', 31, 197, '', 588, '1'),
(555, 'NO PLATE', 32, 73, '', 589, '1'),
(556, 'NO PLATE', 32, 193, '', 449, '1'),
(557, 'XFU-516', 3, 107, '', 591, '1'),
(558, 'PRJ-223', 10, 94, '', 523, '1'),
(559, 'NO PLATE', 10, 39, '', 593, '1'),
(560, 'NGO-544', 22, 64, '', 594, '1'),
(561, 'ZMF-287', 31, 78, '', 531, '1'),
(562, 'NO PLATE', 32, 73, '', 528, '1'),
(563, 'NO PLATE', 2, 78, '', 313, '1'),
(564, 'NO PLATE', 22, 78, '', 158, '1'),
(565, 'NO PLATE', 2, 94, '', 498, '1'),
(566, 'NO PLATE', 32, 73, '', 600, '1'),
(567, 'KBX-946', 22, 119, '', 551, '1'),
(568, 'TQG-966', 32, 163, '', 602, '1'),
(569, 'TQG-966', 32, 163, '', 602, '1'),
(570, 'NO PLATE', 33, 78, '', 604, '1'),
(571, 'WTM-699', 2, 33, '', 605, '1'),
(572, 'NO PLATE', 10, 94, '', 126, '1'),
(573, 'NO PLATE', 10, 151, '', 607, '1'),
(574, 'UGN-811', 10, 69, '', 608, '1'),
(575, 'NO PLATE', 32, 184, '', 609, '1'),
(576, 'NO PLATE', 1, 63, '', 610, '1'),
(577, 'NOL-541', 10, 52, '', 51, '1'),
(578, 'NO PLATE', 3, 43, '', 612, '1'),
(579, 'YHR- 804', 10, 198, '', 613, '1'),
(580, 'UAW-453', 22, 149, '', 614, '1'),
(581, 'YDF-296', 22, 108, '', 70, '1'),
(582, 'KCZ-897', 10, 52, '', 616, '1'),
(583, 'GGC-849', 1, 199, '', 70, '1'),
(584, 'NO PLATE', 32, 200, '', 397, '1'),
(585, 'KCD-749', 36, 57, '', 619, '1'),
(586, 'NO PLATE', 32, 36, '', 448, '1'),
(587, 'KCM-313', 32, 56, '', 577, '1'),
(588, 'YEY-812', 31, 107, '', 622, '1'),
(589, 'JBS-789', 2, 67, '', 623, '1'),
(590, 'KDD-568', 10, 43, '', 624, '1'),
(591, 'NO PLATE', 2, 78, '', 625, '1'),
(592, 'UME-778', 37, 78, '', 626, '1'),
(593, 'NO PLATE', 3, 145, '', 402, '1'),
(594, 'MFB-115', 31, 178, '', 628, '1'),
(595, 'MFB-115', 31, 178, '', 628, '1'),
(596, 'NO PLATE', 1, 67, '', 629, '1'),
(597, 'NO PLATE', 42, 33, '', 630, '1'),
(598, 'NO PLATE', 10, 201, '', 631, '1'),
(599, 'NQV-326', 32, 54, '', 83, '1'),
(600, 'NVO-797', 1, 93, '', 633, '1'),
(601, 'NOI-292', 1, 93, '', 634, '1'),
(602, 'ZNT-269', 10, 88, '', 524, '1'),
(603, 'NAO-606', 10, 65, '', 470, '1'),
(604, 'ZNE-322', 1, 52, '', 637, '1'),
(605, 'ZLJ-949', 10, 89, '', 42, '1'),
(606, 'PVI-747', 10, 42, '', 345, '1'),
(607, 'ZTR-170', 32, 144, '', 297, '1'),
(608, 'KCM-313', 10, 56, '', 577, '1'),
(609, 'NO PLATE', 32, 107, '', 642, '1'),
(610, 'NO PLATE', 3, 67, '', 574, '1'),
(611, 'ZRW-459', 2, 88, '', 329, '1'),
(612, 'OEV-356', 22, 134, '', 245, '1'),
(613, 'YHR- 804', 32, 202, '', 613, '1'),
(614, 'NO PLATE', 32, 73, '', 647, '1'),
(615, 'KCL-456', 22, 78, '', 648, '1'),
(616, 'NO PLATE', 32, 73, '', 321, '1'),
(617, 'NO PLATE', 3, 78, '', 650, '1'),
(618, 'PIX-852', 10, 190, '', 163, '1'),
(619, 'NO PLATE', 10, 43, '', 147, '1'),
(620, 'KCP-212', 10, 168, '', 653, '1'),
(621, 'KEN-524', 22, 36, '', 448, '1'),
(622, 'NO PLATE', 33, 78, '', 604, '1'),
(623, 'NO PLATE', 22, 94, '', 656, '1'),
(624, 'NO PLATE', 32, 73, '', 657, '1'),
(625, 'WMD--562', 31, 145, '', 402, '1'),
(626, 'NO PLATE', 10, 69, '', 659, '1'),
(627, 'NO PLATE', 32, 73, '', 660, '1'),
(628, 'NO PLATE', 37, 203, '', 582, '1'),
(629, 'KDV-590', 22, 204, '', 662, '1'),
(630, 'TKO-820', 32, 155, '', 663, '1'),
(631, 'NO PLATE', 32, 205, '', 206, '1'),
(632, 'NO PLATE', 32, 206, '', 665, '1'),
(633, 'NO PLATE', 3, 66, '', 666, '1'),
(634, 'NO PLATE', 10, 43, '', 667, '1'),
(635, 'NO PLATE', 10, 43, '', 667, '1');

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=632 ;

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
(68, 92, 67, '2013-01-29', '1', 12),
(69, 93, 68, '2013-01-31', '1', 12),
(70, 58, 35, '2013-02-01', '1', 12),
(71, 95, 70, '2013-02-02', '1', 12),
(72, 96, 71, '2013-02-02', '1', 12),
(73, 97, 72, '2013-02-02', '1', 12),
(74, 98, 73, '2013-02-02', '1', 12),
(75, 99, 74, '2013-02-04', '1', 12),
(76, 101, 75, '2013-02-04', '1', 12),
(77, 102, 76, '2013-02-04', '1', 12),
(78, 101, 75, '2013-02-04', '1', 12),
(79, 27, 78, '2013-02-05', '1', 12),
(80, 105, 79, '2013-02-05', '1', 12),
(81, 106, 80, '2013-02-05', '1', 12),
(82, 107, 81, '2013-02-05', '1', 12),
(83, 108, 82, '2013-02-06', '1', 12),
(84, 108, 82, '2013-02-05', '1', 12),
(85, 110, 84, '2013-02-06', '1', 12),
(86, 111, 85, '2013-02-06', '1', 12),
(87, 111, 85, '2013-02-06', '1', 12),
(88, 49, 26, '2013-02-07', '1', 12),
(89, 114, 88, '2013-02-07', '1', 12),
(90, 115, 89, '2013-02-07', '1', 12),
(91, 116, 90, '2013-02-07', '1', 12),
(92, 117, 91, '2013-02-07', '1', 12),
(93, 117, 91, '2013-02-07', '1', 12),
(94, 119, 93, '2013-02-08', '1', 12),
(95, 120, 94, '2013-02-08', '1', 12),
(96, 121, 95, '2013-02-08', '1', 12),
(97, 122, 96, '2013-02-08', '1', 12),
(98, 123, 97, '2013-02-08', '1', 12),
(99, 124, 98, '2013-02-08', '1', 12),
(100, 125, 99, '2013-02-08', '1', 12),
(101, 126, 100, '2013-02-09', '1', 12),
(102, 127, 101, '2013-02-09', '1', 12),
(103, 128, 102, '2013-02-09', '1', 12),
(104, 129, 103, '2013-02-11', '1', 12),
(105, 44, 104, '2013-02-11', '1', 12),
(106, 131, 105, '2013-02-11', '1', 12),
(107, 132, 106, '2013-02-12', '1', 12),
(108, 132, 107, '2013-02-12', '1', 12),
(109, 132, 108, '2013-02-12', '1', 12),
(110, 135, 109, '2013-02-12', '1', 12),
(111, 136, 110, '2013-02-12', '1', 12),
(112, 137, 111, '2013-02-12', '1', 12),
(113, 138, 112, '2013-02-13', '1', 12),
(114, 139, 113, '2013-02-13', '1', 12),
(115, 141, 114, '2013-02-13', '1', 12),
(116, 142, 115, '2013-02-13', '1', 12),
(117, 143, 116, '2013-02-13', '1', 12),
(118, 126, 117, '2013-02-14', '1', 12),
(119, 45, 118, '2013-02-15', '1', 12),
(120, 88, 63, '2013-02-15', '1', 12),
(121, 147, 120, '2013-02-15', '1', 12),
(122, 148, 121, '2013-02-15', '1', 12),
(123, 149, 122, '2013-02-15', '1', 12),
(124, 149, 123, '2013-02-15', '1', 12),
(125, 89, 64, '2013-02-16', '1', 12),
(126, 96, 125, '2013-02-16', '1', 12),
(127, 153, 126, '2013-02-16', '1', 12),
(128, 157, 127, '2013-02-18', '1', 12),
(129, 158, 128, '2013-02-18', '1', 12),
(130, 159, 129, '2013-02-19', '1', 12),
(131, 58, 130, '2013-02-19', '1', 12),
(132, 161, 131, '2013-02-19', '1', 12),
(133, 162, 132, '2013-02-19', '1', 12),
(134, 163, 133, '2013-02-19', '1', 12),
(135, 164, 134, '2013-02-20', '1', 12),
(136, 165, 135, '2013-02-20', '1', 12),
(137, 165, 135, '2013-02-20', '1', 12),
(138, 167, 137, '2013-02-20', '1', 12),
(139, 168, 138, '2013-02-20', '1', 12),
(140, 70, 139, '2013-02-20', '1', 12),
(141, 70, 140, '2013-02-20', '1', 12),
(142, 171, 141, '2013-02-20', '1', 12),
(143, 172, 142, '2013-02-21', '1', 12),
(144, 173, 143, '2013-02-21', '1', 12),
(145, 174, 144, '2013-02-21', '1', 12),
(146, 175, 145, '2013-02-21', '1', 12),
(147, 176, 146, '2013-02-20', '1', 12),
(148, 177, 147, '2013-02-22', '1', 12),
(149, 178, 148, '2013-02-23', '1', 12),
(150, 177, 149, '2013-02-23', '1', 12),
(151, 180, 150, '2013-02-23', '1', 12),
(152, 181, 151, '2013-02-23', '1', 12),
(153, 182, 152, '2013-02-23', '1', 12),
(154, 183, 153, '2013-02-23', '1', 12),
(155, 184, 154, '2013-02-25', '1', 12),
(156, 171, 155, '2013-02-25', '1', 12),
(157, 186, 156, '2013-02-26', '1', 12),
(158, 83, 158, '2013-02-26', '1', 12),
(159, 83, 159, '2013-02-26', '1', 12),
(160, 190, 160, '2013-02-27', '1', 12),
(161, 191, 161, '2013-02-27', '1', 12),
(162, 192, 162, '2013-02-27', '1', 12),
(163, 193, 163, '2013-02-27', '1', 12),
(164, 194, 164, '2013-02-27', '1', 12),
(165, 162, 165, '2013-02-27', '1', 12),
(166, 162, 132, '2013-02-27', '1', 12),
(167, 162, 132, '2013-02-27', '1', 12),
(168, 162, 132, '2013-02-27', '1', 12),
(169, 199, 169, '2013-02-27', '1', 12),
(170, 27, 171, '2013-02-28', '1', 12),
(171, 27, 172, '2013-02-28', '1', 12),
(172, 205, 174, '2013-02-28', '1', 12),
(173, 206, 175, '2013-03-01', '1', 12),
(174, 62, 176, '2013-03-01', '1', 12),
(175, 208, 177, '2013-03-01', '1', 12),
(176, 208, 177, '2013-03-01', '1', 12),
(177, 210, 179, '2013-03-02', '1', 12),
(178, 211, 180, '2013-03-02', '1', 12),
(179, 212, 181, '2013-03-02', '1', 12),
(180, 213, 182, '2013-03-04', '1', 12),
(181, 141, 183, '2013-03-05', '1', 12),
(182, 215, 184, '2013-03-05', '1', 12),
(183, 216, 185, '2013-03-05', '1', 12),
(184, 217, 186, '2013-03-09', '1', 12),
(185, 218, 187, '2013-03-09', '1', 12),
(186, 219, 188, '2013-03-22', '1', 12),
(187, 220, 189, '2013-03-13', '1', 12),
(188, 70, 190, '2013-03-13', '1', 12),
(189, 223, 192, '2013-03-14', '1', 12),
(190, 124, 193, '2013-03-14', '1', 12),
(191, 83, 194, '2013-03-14', '1', 12),
(192, 226, 195, '2013-03-14', '1', 12),
(193, 227, 196, '2013-03-14', '1', 12),
(194, 228, 197, '2013-03-14', '1', 12),
(195, 229, 198, '2013-03-19', '1', 12),
(196, 230, 199, '2013-03-15', '1', 12),
(197, 231, 200, '2013-03-15', '1', 12),
(198, 232, 201, '2013-03-15', '1', 12),
(199, 58, 202, '2013-03-15', '1', 12),
(200, 234, 203, '2013-03-15', '1', 12),
(201, 235, 204, '2013-03-15', '1', 12),
(202, 236, 205, '2013-03-14', '1', 12),
(203, 237, 206, '2013-03-14', '1', 12),
(204, 237, 207, '2013-03-14', '1', 12),
(205, 215, 208, '2013-03-15', '1', 12),
(206, 240, 209, '2013-03-16', '1', 12),
(207, 241, 210, '2013-03-16', '1', 12),
(208, 27, 211, '2013-03-16', '1', 12),
(209, 243, 212, '2013-03-16', '1', 12),
(210, 62, 213, '2013-03-16', '1', 12),
(211, 76, 214, '2013-03-16', '1', 12),
(212, 76, 214, '2013-03-16', '1', 12),
(213, 132, 107, '2013-03-18', '1', 12),
(214, 247, 216, '2013-03-18', '1', 12),
(215, 248, 217, '2013-03-19', '1', 12),
(216, 249, 218, '2013-03-19', '1', 12),
(217, 58, 219, '2013-03-19', '1', 12),
(218, 231, 200, '2013-03-19', '1', 12),
(219, 252, 221, '2013-03-19', '1', 12),
(220, 132, 222, '2013-03-19', '1', 12),
(221, 254, 223, '2013-03-20', '1', 12),
(222, 255, 224, '2013-03-20', '1', 12),
(223, 62, 225, '2013-03-20', '1', 12),
(224, 257, 226, '2013-03-20', '1', 12),
(225, 258, 227, '2013-03-21', '1', 12),
(226, 132, 106, '2013-03-21', '1', 12),
(227, 62, 230, '2013-03-21', '1', 12),
(228, 236, 205, '2013-03-22', '1', 12),
(229, 263, 232, '2013-03-22', '1', 12),
(230, 264, 233, '2013-03-25', '1', 12),
(231, 141, 183, '2013-03-26', '1', 12),
(232, 31, 12, '2013-03-26', '1', 12),
(233, 267, 236, '2013-03-26', '1', 12),
(234, 269, 237, '2013-03-26', '1', 12),
(235, 270, 238, '2013-03-27', '1', 12),
(236, 254, 239, '2013-03-30', '1', 12),
(237, 272, 240, '2013-03-09', '1', 12),
(238, 211, 241, '2013-03-08', '1', 12),
(239, 274, 242, '2013-03-09', '1', 12),
(240, 275, 243, '2013-03-09', '1', 12),
(241, 276, 244, '2013-03-11', '1', 12),
(242, 276, 245, '2013-03-11', '1', 12),
(243, 278, 246, '2013-03-11', '1', 12),
(244, 279, 247, '2013-03-11', '1', 12),
(245, 280, 248, '2013-03-12', '1', 12),
(246, 281, 249, '2013-03-12', '1', 12),
(247, 282, 250, '2013-03-12', '1', 12),
(248, 212, 251, '2013-03-13', '1', 12),
(249, 284, 252, '2013-03-14', '1', 12),
(250, 285, 253, '2013-03-16', '1', 12),
(251, 286, 254, '2013-03-16', '1', 12),
(252, 287, 255, '2013-03-16', '1', 12),
(253, 141, 256, '2013-03-16', '1', 12),
(254, 289, 257, '2013-03-18', '1', 12),
(255, 290, 258, '2013-03-18', '1', 12),
(256, 291, 259, '2013-03-18', '1', 12),
(257, 292, 260, '2013-03-18', '1', 12),
(258, 293, 261, '2013-03-19', '1', 12),
(259, 157, 262, '2013-03-19', '1', 12),
(260, 295, 263, '2013-03-21', '1', 12),
(261, 243, 264, '2013-03-20', '1', 12),
(262, 297, 265, '2013-03-20', '1', 12),
(263, 298, 266, '2013-03-20', '1', 12),
(264, 299, 267, '2013-03-21', '1', 12),
(265, 300, 268, '2013-03-21', '1', 12),
(266, 301, 269, '2013-03-21', '1', 12),
(267, 302, 270, '2013-03-21', '1', 12),
(268, 303, 271, '2013-03-22', '1', 12),
(269, 304, 272, '2013-03-22', '1', 12),
(270, 285, 273, '2013-03-22', '1', 12),
(271, 306, 274, '2013-03-23', '1', 12),
(272, 307, 275, '2013-03-23', '1', 12),
(273, 308, 276, '2013-03-25', '1', 12),
(274, 290, 258, '2013-03-25', '1', 12),
(275, 310, 278, '2013-03-26', '1', 12),
(276, 311, 279, '2013-03-26', '1', 12),
(277, 312, 280, '2013-03-26', '1', 12),
(278, 313, 281, '2013-03-30', '1', 12),
(279, 124, 193, '2013-04-01', '1', 12),
(280, 124, 193, '2013-04-01', '1', 12),
(281, 281, 249, '2013-04-01', '1', 12),
(282, 317, 285, '2013-04-02', '1', 12),
(283, 318, 286, '2013-04-02', '1', 12),
(284, 300, 287, '2013-04-02', '1', 12),
(285, 320, 288, '2013-04-03', '1', 12),
(286, 321, 289, '2013-04-05', '1', 12),
(287, 297, 290, '2013-04-05', '1', 12),
(288, 323, 291, '2013-04-06', '1', 12),
(289, 324, 292, '2013-04-08', '1', 12),
(290, 325, 293, '2013-04-09', '1', 12),
(291, 293, 261, '2013-04-09', '1', 12),
(292, 236, 205, '2013-04-09', '1', 12),
(293, 124, 98, '2013-04-09', '1', 12),
(294, 329, 297, '2013-04-09', '1', 12),
(295, 330, 298, '2013-04-09', '1', 12),
(296, 330, 298, '2013-04-09', '1', 12),
(297, 332, 300, '2013-04-09', '1', 12),
(298, 333, 301, '2013-04-09', '1', 12),
(299, 334, 302, '2013-04-09', '1', 12),
(300, 334, 302, '2013-04-09', '1', 12),
(301, 293, 304, '2013-04-09', '1', 12),
(302, 337, 305, '2013-04-09', '1', 12),
(303, 338, 306, '2013-04-10', '1', 12),
(304, 339, 307, '2013-04-09', '1', 12),
(305, 83, 308, '2013-04-09', '1', 12),
(306, 341, 309, '2013-04-10', '1', 12),
(307, 342, 310, '2013-04-11', '1', 12),
(308, 300, 311, '2013-04-11', '1', 12),
(309, 344, 312, '2013-04-11', '1', 12),
(310, 285, 273, '2013-04-12', '1', 12),
(311, 83, 314, '2013-04-12', '1', 12),
(312, 42, 19, '2013-04-15', '1', 12),
(313, 42, 19, '2013-04-15', '1', 12),
(314, 237, 207, '2013-04-13', '1', 12),
(315, 349, 317, '2013-04-13', '1', 12),
(316, 341, 309, '2013-04-13', '1', 12),
(317, 351, 319, '2013-04-15', '1', 12),
(318, 352, 320, '2013-04-15', '1', 12),
(319, 290, 258, '2013-04-15', '1', 12),
(320, 45, 322, '2013-04-15', '1', 12),
(321, 45, 322, '2013-04-15', '1', 12),
(322, 355, 323, '2013-04-15', '1', 12),
(323, 356, 324, '2013-04-15', '1', 12),
(324, 76, 214, '2013-04-16', '1', 12),
(325, 313, 326, '2013-04-16', '1', 12),
(326, 359, 327, '2013-04-16', '1', 12),
(327, 360, 328, '2013-04-18', '1', 12),
(328, 361, 329, '2013-04-17', '1', 12),
(329, 362, 330, '2013-04-17', '1', 12),
(330, 364, 331, '2013-04-18', '1', 12),
(331, 351, 319, '2013-04-17', '1', 12),
(332, 45, 333, '2013-04-19', '1', 12),
(333, 304, 334, '2013-04-20', '1', 12),
(334, 334, 302, '2013-04-20', '1', 12),
(335, 334, 302, '2013-04-20', '1', 12),
(336, 334, 302, '2013-04-20', '1', 12),
(337, 371, 338, '2013-04-22', '1', 12),
(338, 372, 339, '2013-04-22', '1', 12),
(339, 373, 340, '2013-04-23', '1', 12),
(340, 374, 341, '2013-04-24', '1', 12),
(341, 375, 342, '2013-04-24', '1', 12),
(342, 376, 343, '2013-04-25', '1', 12),
(343, 377, 344, '2013-04-25', '1', 12),
(344, 313, 345, '2013-04-26', '1', 12),
(345, 379, 346, '2013-04-27', '1', 12),
(346, 381, 347, '2013-04-27', '1', 12),
(347, 382, 348, '2013-04-29', '1', 12),
(348, 382, 349, '2013-04-29', '1', 12),
(349, 311, 351, '2013-04-30', '1', 12),
(350, 386, 352, '2013-04-30', '1', 12),
(351, 269, 353, '2013-04-02', '1', 12),
(352, 32, 354, '2013-04-02', '1', 12),
(353, 389, 355, '2013-04-03', '1', 12),
(354, 389, 355, '2013-04-03', '1', 12),
(355, 27, 356, '2013-04-04', '1', 12),
(356, 391, 357, '2013-04-05', '1', 12),
(357, 392, 358, '2013-04-05', '1', 12),
(358, 393, 359, '2013-04-05', '1', 12),
(359, 394, 360, '2013-04-06', '1', 12),
(360, 298, 361, '2013-04-06', '1', 12),
(361, 330, 362, '2013-04-08', '1', 12),
(362, 397, 363, '2013-04-09', '1', 12),
(363, 397, 363, '2013-04-10', '1', 12),
(364, 399, 365, '2013-04-09', '1', 12),
(365, 400, 366, '2013-04-09', '1', 12),
(366, 132, 367, '2013-04-10', '1', 12),
(367, 402, 368, '2013-04-10', '1', 12),
(368, 161, 369, '2013-04-11', '1', 12),
(369, 404, 370, '2013-04-11', '1', 12),
(370, 405, 371, '2013-04-15', '1', 12),
(371, 243, 372, '2013-04-12', '1', 12),
(372, 407, 373, '2013-04-15', '1', 12),
(373, 281, 374, '2013-03-12', '1', 12),
(374, 355, 375, '2013-04-13', '1', 12),
(375, 410, 376, '2013-04-11', '1', 12),
(376, 410, 377, '2013-04-24', '1', 12),
(377, 412, 378, '2013-04-15', '1', 12),
(378, 415, 381, '2013-04-18', '1', 12),
(379, 416, 382, '2013-04-18', '1', 12),
(380, 417, 383, '2013-04-18', '1', 12),
(381, 419, 385, '2013-04-19', '1', 12),
(382, 161, 386, '2013-04-19', '1', 12),
(383, 161, 369, '2013-04-19', '1', 12),
(384, 422, 388, '2013-04-30', '1', 12),
(385, 102, 389, '2013-04-22', '1', 12),
(386, 102, 390, '2013-04-22', '1', 12),
(387, 49, 391, '2013-04-23', '1', 12),
(388, 426, 392, '2013-04-24', '1', 12),
(389, 402, 393, '2013-04-25', '1', 12),
(390, 428, 394, '2013-04-27', '1', 12),
(391, 429, 395, '2013-04-29', '1', 12),
(392, 430, 396, '2013-04-30', '1', 12),
(393, 431, 397, '2013-04-30', '1', 12),
(394, 430, 398, '2013-05-01', '1', 12),
(395, 433, 399, '2013-05-01', '1', 12),
(396, 362, 400, '2013-05-01', '1', 12),
(397, 351, 319, '2013-05-02', '1', 12),
(398, 436, 402, '2013-05-02', '1', 12),
(399, 437, 403, '2013-05-02', '1', 12),
(400, 438, 404, '2013-05-02', '1', 12),
(401, 439, 405, '2013-05-02', '1', 12),
(402, 440, 406, '2013-05-03', '1', 12),
(403, 441, 407, '2013-05-03', '1', 12),
(404, 443, 408, '2013-05-03', '1', 12),
(405, 444, 409, '2013-05-04', '1', 12),
(406, 445, 410, '2013-05-04', '1', 12),
(407, 281, 249, '2013-05-04', '1', 12),
(408, 447, 412, '2013-05-04', '1', 12),
(409, 448, 413, '2013-05-04', '1', 12),
(410, 449, 414, '2013-05-04', '1', 12),
(411, 450, 415, '2013-05-06', '1', 12),
(412, 132, 416, '2013-05-06', '1', 12),
(413, 379, 346, '2013-05-07', '1', 12),
(414, 382, 349, '2013-05-07', '1', 12),
(415, 454, 419, '2013-05-30', '1', 12),
(416, 454, 419, '2013-05-04', '1', 12),
(417, 76, 421, '2013-05-07', '1', 12),
(418, 457, 422, '2013-05-07', '1', 12),
(419, 458, 423, '2013-05-07', '1', 12),
(420, 304, 424, '2013-05-07', '1', 12),
(421, 460, 425, '2013-05-07', '1', 12),
(422, 461, 426, '2013-05-08', '1', 12),
(423, 462, 427, '2013-05-08', '1', 12),
(424, 463, 428, '2013-05-08', '1', 12),
(425, 124, 193, '2013-05-08', '1', 12),
(426, 465, 430, '2013-05-08', '1', 12),
(427, 466, 431, '2013-05-08', '1', 12),
(428, 466, 431, '2013-05-08', '1', 12),
(429, 466, 433, '2013-05-08', '1', 12),
(430, 236, 205, '2013-05-08', '1', 12),
(431, 470, 435, '2013-05-08', '1', 12),
(432, 471, 436, '2013-05-08', '1', 12),
(433, 249, 437, '2013-05-08', '1', 12),
(434, 473, 438, '2013-05-08', '1', 12),
(435, 474, 439, '2013-05-09', '1', 12),
(436, 122, 440, '2013-05-09', '1', 12),
(437, 349, 317, '2013-05-09', '1', 12),
(438, 477, 442, '2013-05-09', '1', 12),
(439, 447, 412, '2013-05-10', '1', 12),
(440, 479, 444, '2013-05-10', '1', 12),
(441, 205, 445, '2013-05-11', '1', 12),
(442, 429, 446, '2013-05-11', '1', 12),
(443, 249, 447, '2013-05-11', '1', 12),
(444, 483, 448, '2013-05-11', '1', 12),
(445, 463, 428, '2013-05-11', '1', 12),
(446, 51, 450, '2013-05-11', '1', 12),
(447, 486, 451, '2013-05-11', '1', 12),
(448, 83, 452, '2013-05-14', '1', 12),
(449, 445, 453, '2013-05-14', '1', 12),
(450, 489, 454, '2013-05-15', '1', 12),
(451, 471, 436, '2013-05-15', '1', 12),
(452, 471, 456, '2013-05-15', '1', 12),
(453, 491, 457, '2013-05-16', '1', 12),
(454, 493, 458, '2013-05-15', '1', 12),
(455, 249, 459, '2013-05-15', '1', 12),
(456, 496, 460, '2013-05-15', '1', 12),
(457, 410, 461, '2013-05-15', '1', 12),
(458, 498, 462, '2013-05-15', '1', 12),
(459, 311, 279, '2013-05-15', '1', 12),
(460, 107, 464, '2013-05-15', '1', 12),
(461, 126, 465, '2013-05-16', '1', 12),
(462, 502, 466, '2013-05-16', '1', 12),
(463, 503, 467, '2013-05-17', '1', 12),
(464, 504, 468, '2013-05-17', '1', 12),
(465, 505, 469, '2013-05-17', '1', 12),
(466, 447, 412, '2013-05-17', '1', 12),
(467, 493, 471, '2013-05-18', '1', 12),
(468, 298, 472, '2013-05-18', '1', 12),
(469, 509, 473, '2013-05-18', '1', 12),
(470, 313, 474, '2013-05-18', '1', 12),
(471, 162, 132, '2013-05-20', '1', 12),
(472, 512, 476, '2013-05-20', '1', 12),
(473, 513, 477, '2013-05-20', '1', 12),
(474, 304, 478, '2013-05-20', '1', 12),
(475, 515, 479, '2013-05-20', '1', 12),
(476, 516, 480, '2013-05-20', '1', 12),
(477, 516, 480, '2013-05-20', '1', 12),
(478, 517, 482, '2013-05-20', '1', 12),
(479, 297, 483, '2013-05-25', '1', 12),
(480, 519, 484, '2013-05-25', '1', 12),
(481, 520, 485, '2013-05-25', '1', 12),
(482, 124, 486, '2013-05-25', '1', 12),
(483, 522, 487, '2013-05-25', '1', 12),
(484, 523, 488, '2013-05-20', '1', 12),
(485, 524, 489, '2013-05-25', '1', 12),
(486, 525, 490, '2013-05-25', '1', 12),
(487, 526, 491, '2013-05-20', '1', 12),
(488, 503, 492, '2013-05-20', '1', 12),
(489, 528, 493, '2013-05-21', '1', 12),
(490, 325, 494, '2013-05-21', '1', 12),
(491, 45, 495, '2013-05-21', '1', 12),
(492, 531, 496, '2013-05-21', '1', 12),
(493, 243, 497, '2013-05-21', '1', 12),
(494, 533, 498, '2013-05-22', '1', 12),
(495, 534, 499, '2013-05-22', '1', 12),
(496, 535, 500, '2013-05-23', '1', 12),
(497, 536, 501, '2013-05-24', '1', 12),
(498, 537, 502, '2013-05-24', '1', 12),
(499, 212, 503, '2013-05-24', '1', 12),
(500, 523, 504, '2013-05-24', '1', 12),
(501, 124, 505, '2013-05-25', '1', 12),
(502, 540, 506, '2013-05-25', '1', 12),
(503, 78, 507, '2013-05-25', '1', 12),
(504, 449, 508, '2013-05-25', '1', 12),
(505, 544, 509, '2013-05-25', '1', 12),
(506, 545, 510, '2013-05-25', '1', 12),
(507, 445, 511, '2013-05-25', '1', 12),
(508, 547, 512, '2013-05-27', '1', 12),
(509, 548, 513, '2013-05-27', '1', 12),
(510, 549, 514, '2013-05-28', '1', 12),
(511, 78, 515, '2013-05-28', '1', 12),
(512, 551, 516, '2013-05-28', '1', 12),
(513, 397, 517, '2013-05-28', '1', 12),
(514, 553, 518, '2013-05-25', '1', 12),
(515, 553, 519, '2013-05-28', '1', 12),
(516, 76, 520, '2013-05-28', '1', 12),
(517, 556, 521, '2013-05-28', '1', 12),
(518, 330, 522, '2013-05-28', '1', 12),
(519, 558, 523, '2013-05-29', '1', 12),
(520, 559, 524, '2013-05-29', '1', 12),
(521, 498, 525, '2013-05-25', '1', 12),
(522, 561, 526, '2013-05-29', '1', 12),
(523, 562, 527, '2013-05-30', '1', 12),
(524, 563, 528, '2013-05-27', '1', 12),
(525, 564, 529, '2013-05-30', '1', 12),
(526, 558, 531, '2013-05-30', '1', 12),
(527, 325, 532, '2013-05-30', '1', 12),
(528, 567, 533, '2013-05-30', '1', 12),
(529, 562, 527, '2013-05-30', '1', 12),
(530, 562, 534, '2013-05-30', '1', 12),
(531, 397, 535, '2013-05-30', '1', 12),
(532, 570, 536, '2013-05-31', '1', 12),
(533, 489, 537, '2013-05-31', '1', 12),
(534, 503, 538, '2013-05-31', '1', 12),
(535, 107, 539, '2013-05-31', '1', 12),
(536, 574, 540, '2013-05-31', '1', 12),
(537, 32, 541, '2013-04-02', '1', 12),
(538, 576, 542, '2013-06-01', '1', 12),
(539, 577, 543, '2013-06-01', '1', 12),
(540, 578, 544, '2013-06-01', '1', 12),
(541, 290, 545, '2013-06-01', '1', 12),
(542, 580, 546, '2013-06-01', '1', 12),
(543, 581, 547, '2013-06-01', '1', 12),
(544, 582, 548, '2013-06-01', '1', 12),
(545, 86, 549, '2013-06-01', '1', 12),
(546, 320, 550, '2013-06-03', '1', 12),
(547, 83, 551, '2013-06-03', '1', 12),
(548, 163, 552, '2013-06-03', '1', 12),
(549, 516, 553, '2013-06-03', '1', 12),
(550, 588, 554, '2013-06-04', '1', 12),
(551, 589, 555, '2013-06-05', '1', 12),
(552, 449, 556, '2013-06-04', '1', 12),
(553, 591, 557, '2013-06-04', '1', 12),
(554, 523, 558, '2013-06-04', '1', 12),
(555, 593, 559, '2013-06-04', '1', 12),
(556, 594, 560, '2013-06-04', '1', 12),
(557, 531, 561, '2013-06-04', '1', 12),
(558, 528, 562, '2013-06-05', '1', 12),
(559, 313, 563, '2013-06-05', '1', 12),
(560, 158, 564, '2013-06-05', '1', 12),
(561, 498, 565, '2013-06-05', '1', 12),
(562, 600, 566, '2013-06-06', '1', 12),
(563, 551, 567, '2013-06-06', '1', 12),
(564, 602, 568, '2013-06-06', '1', 12),
(565, 602, 569, '2013-06-06', '1', 12),
(566, 604, 570, '2013-06-06', '1', 12),
(567, 605, 571, '2013-06-06', '1', 12),
(568, 126, 572, '2013-06-06', '1', 12),
(569, 607, 573, '2013-06-06', '1', 12),
(570, 608, 574, '2013-06-06', '1', 12),
(571, 609, 575, '2013-06-01', '1', 12),
(572, 610, 576, '2013-06-07', '1', 12),
(573, 51, 577, '2013-06-07', '1', 12),
(574, 612, 578, '2013-06-07', '1', 12),
(575, 613, 579, '2013-06-07', '1', 12),
(576, 614, 580, '2013-06-08', '1', 12),
(577, 70, 581, '2013-06-08', '1', 12),
(578, 616, 582, '2013-06-08', '1', 12),
(579, 70, 583, '2013-06-08', '1', 12),
(580, 397, 584, '2013-06-08', '1', 12),
(581, 619, 585, '2013-06-08', '1', 12),
(582, 448, 586, '2013-06-08', '1', 12),
(583, 577, 587, '2013-06-08', '1', 12),
(584, 622, 588, '2013-06-10', '1', 12),
(585, 623, 589, '2013-06-10', '1', 12),
(586, 624, 590, '2013-06-10', '1', 12),
(587, 625, 591, '2013-06-11', '1', 12),
(588, 626, 592, '2013-06-11', '1', 12),
(589, 402, 593, '2013-06-11', '1', 12),
(590, 628, 594, '2013-06-11', '1', 12),
(591, 628, 595, '2013-06-11', '1', 12),
(592, 629, 596, '2013-06-12', '1', 12),
(593, 630, 597, '2013-06-12', '1', 12),
(594, 631, 598, '2013-06-13', '1', 12),
(595, 83, 599, '2013-06-14', '1', 12),
(596, 633, 600, '2013-06-14', '1', 12),
(597, 634, 601, '2013-06-14', '1', 12),
(598, 524, 602, '2013-06-14', '1', 12),
(599, 470, 603, '2013-06-14', '1', 12),
(600, 637, 604, '2013-06-14', '1', 12),
(601, 42, 605, '2013-06-14', '1', 12),
(602, 345, 606, '2013-06-14', '1', 12),
(603, 297, 607, '2013-06-14', '1', 12),
(604, 577, 608, '2013-06-14', '1', 12),
(605, 642, 609, '2013-06-14', '1', 12),
(606, 574, 610, '2013-06-14', '1', 12),
(607, 329, 611, '2013-06-14', '1', 12),
(608, 76, 520, '2013-06-14', '1', 12),
(609, 613, 613, '2013-06-14', '1', 12),
(610, 647, 614, '2013-06-15', '1', 12),
(611, 648, 615, '2013-06-15', '1', 12),
(612, 321, 616, '2013-06-15', '1', 12),
(613, 650, 617, '2013-06-17', '1', 12),
(614, 163, 618, '2013-06-17', '1', 12),
(615, 147, 619, '2013-06-17', '1', 12),
(616, 653, 620, '2013-06-17', '1', 12),
(617, 448, 621, '2013-06-18', '1', 12),
(618, 604, 622, '2013-06-18', '1', 12),
(619, 656, 623, '2013-06-18', '1', 12),
(620, 657, 624, '2013-06-18', '1', 12),
(621, 402, 625, '2013-06-19', '1', 12),
(622, 659, 626, '2013-06-19', '1', 12),
(623, 660, 627, '2013-06-19', '1', 12),
(624, 582, 628, '2013-06-19', '1', 12),
(625, 662, 629, '2013-06-19', '1', 12),
(626, 663, 630, '2013-06-20', '1', 12),
(627, 206, 631, '2013-06-20', '1', 12),
(628, 665, 632, '2013-06-20', '1', 12),
(629, 666, 633, '2013-06-20', '1', 12),
(630, 667, 634, '2013-06-20', '1', 12),
(631, 667, 634, '2013-06-20', '1', 12);

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
