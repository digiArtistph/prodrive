-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 23, 2013 at 03:05 AM
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
DROP PROCEDURE IF EXISTS `sp_addDCRDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addDCRDetails`(IN pParticular VARCHAR(255), IN pTender INT, IN pRefno VARCHAR(75), IN pAmnt DECIMAL(8,2), IN pID INT, IN pStatus INT)
BEGIN

  IF pStatus = 1 THEN
    INSERT INTO tmptblDCRDetails
      SET particular = pParticular,
          tender = pTender,
          refno = pRefno,
          amnt = pAmnt,
          id = pID;
  END IF;

END$$

DROP PROCEDURE IF EXISTS `sp_dropTmpTblDCRDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_dropTmpTblDCRDetails`(OUT pSuccess INT)
BEGIN
  /* drops the tmptblDCRDetails temporary table */
  DROP TEMPORARY TABLE tmptblDCRDetails;
  SET pSuccess = 0;
END$$

DROP PROCEDURE IF EXISTS `sp_editjoborder`$$
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

DROP PROCEDURE IF EXISTS `sp_editjoborderdet`$$
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

DROP PROCEDURE IF EXISTS `sp_end_editjoborder`$$
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

DROP PROCEDURE IF EXISTS `sp_end_joborder`$$
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

DROP PROCEDURE IF EXISTS `sp_joborderdet`$$
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

DROP PROCEDURE IF EXISTS `sp_newdcr`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_newdcr`(IN m_trnx_date DATE, IN m_beg_bal DECIMAL(8,2), IN m_cashier INT, IN m_status CHAR(1), OUT m_dcr_id BIGINT)
BEGIN
INSERT INTO dcr SET trnxdate = m_trnx_date, begbal = m_beg_bal, cashier = m_cashier, `status` = m_status;
  SET m_dcr_id = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_start_editjoborder`$$
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

DROP PROCEDURE IF EXISTS `sp_start_joborder`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_start_joborder`(
OUT 	flag	INT
)
BEGIN

START TRANSACTION;
set flag=0;

END$$

DROP PROCEDURE IF EXISTS `sp_tmptblDCRDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tmptblDCRDetails`(OUT pSuccess INT)
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

  END$$

DROP PROCEDURE IF EXISTS `sp_updateDCRDetails`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateDCRDetails`(IN pExistTmpTable INT, IN pID INT)
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cashfloat`
--

DROP TABLE IF EXISTS `cashfloat`;
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

DROP TABLE IF EXISTS `cashlift`;
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

DROP TABLE IF EXISTS `categories`;
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
(5, 'Break System', 3),
(6, 'Cool/Heat System', 0);

-- --------------------------------------------------------

--
-- Table structure for table `color`
--

DROP TABLE IF EXISTS `color`;
CREATE TABLE IF NOT EXISTS `color` (
  `clr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`clr_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=26 ;

--
-- Dumping data for table `color`
--

INSERT INTO `color` (`clr_id`, `name`) VALUES
(1, 'red'),
(2, 'blue'),
(3, 'green'),
(6, 'skyblue'),
(25, 'yellow'),
(10, 'dark black'),
(24, 'brown'),
(23, 'dsf'),
(13, 'dark red'),
(22, 'white');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE IF NOT EXISTS `customer` (
  `custid` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(255) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `addr` mediumtext,
  `phone` varchar(255) DEFAULT NULL,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`custid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=25 ;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`custid`, `fname`, `mname`, `lname`, `addr`, `phone`, `status`) VALUES
(3, 'Emelie', 'Cepe', 'Nagales', 'Valencia Bukidnun', '09353738295', ''),
(5, 'Norberto', 'Mab', 'Libago Sr', 'Poblacion', '09352689566', '1'),
(9, 'Kenneth', 'Palmero', 'Vallejos', 'Cugman Cagayan De Oro', '09167958734', '1'),
(13, 'romualdo', 'peidad', 'xavier justine', NULL, NULL, '1'),
(12, 'limbago', 'Quirta', 'john paul', NULL, NULL, '1'),
(18, 'libago jr', 'Q', 'norberto', NULL, NULL, '1'),
(19, 'Kenn', 'palmero', 'valejos', NULL, NULL, '1'),
(20, 'jun', 'quisil', 'Tongbes', NULL, NULL, '1');

-- --------------------------------------------------------

--
-- Table structure for table `dcr`
--

DROP TABLE IF EXISTS `dcr`;
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
(2, '2013-05-17', '1500.00', 4, '1'),
(3, '2013-05-18', '1250.00', 4, '1');

-- --------------------------------------------------------

--
-- Table structure for table `dcrdetails`
--

DROP TABLE IF EXISTS `dcrdetails`;
CREATE TABLE IF NOT EXISTS `dcrdetails` (
  `dcr_id` int(11) NOT NULL DEFAULT '0',
  `particulars` mediumtext,
  `refno` varchar(15) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `tender` tinyint(4) DEFAULT '0',
  KEY `FK_dcrdetails_1` (`dcr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `joborder`
--

DROP TABLE IF EXISTS `joborder`;
CREATE TABLE IF NOT EXISTS `joborder` (
  `jo_id` int(11) NOT NULL AUTO_INCREMENT,
  `v_id` int(11) DEFAULT NULL,
  `customer` int(11) DEFAULT '0',
  `plate` varchar(50) DEFAULT NULL,
  `color` int(11) DEFAULT '0',
  `contactnumber` varchar(75) DEFAULT NULL,
  `address` mediumtext,
  `trnxdate` date DEFAULT NULL,
  PRIMARY KEY (`jo_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity' AUTO_INCREMENT=131 ;

--
-- Dumping data for table `joborder`
--

INSERT INTO `joborder` (`jo_id`, `v_id`, `customer`, `plate`, `color`, `contactnumber`, `address`, `trnxdate`) VALUES
(120, 28, 3, '12', 1, '21', '12', '2013-05-12'),
(121, 23, 16, '12', 25, '12', '21', '2013-05-12'),
(122, 1, 3, '21', 2, '21', '21', '2013-05-12'),
(123, 1, 3, '21', 2, '21', '21', '2013-05-12'),
(124, 1, 3, '21', 1, '12', '12', '2013-05-12'),
(127, 3, 3, '21', 1, '21', '21', '2013-05-12'),
(128, 1, 3, 'hss', 1, '23', '12', '2013-05-12'),
(129, 20, 3, '821912', 3, '09352689566', 'pib', '2013-05-15'),
(130, 21, 14, '928', 24, '092689566', 'mambajao', '2013-05-15');

-- --------------------------------------------------------

--
-- Table structure for table `jodetails`
--

DROP TABLE IF EXISTS `jodetails`;
CREATE TABLE IF NOT EXISTS `jodetails` (
  `jo_id` int(11) NOT NULL DEFAULT '0',
  `labor` int(11) DEFAULT '0',
  `partmaterial` varchar(50) DEFAULT '0',
  `details` mediumtext,
  `laboramnt` decimal(8,2) DEFAULT '0.00',
  `partmaterialamnt` decimal(8,2) DEFAULT '0.00',
  `status` enum('0','1','2','3') DEFAULT '0' COMMENT '0:deactivated, 1:active, 2:reserved, 3:reserved',
  KEY `FK_jodetails_1` (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jodetails`
--

INSERT INTO `jodetails` (`jo_id`, `labor`, `partmaterial`, `details`, `laboramnt`, `partmaterialamnt`, `status`) VALUES
(122, 18, '', '21', '21.00', '0.00', '1'),
(123, 18, '', '21', '21.00', '0.00', '1'),
(124, 18, '', '21', '12.00', '0.00', '1'),
(127, 19, '', '21', '21.00', '0.00', '1'),
(128, 20, '', '21', '21.00', '0.00', '1'),
(129, 14, '', 'tongbens the great', '12.00', '0.00', '1'),
(130, 0, '12', '12', '0.00', '12.00', '1'),
(121, 22, '', '21', '12.00', '0.00', '1'),
(121, 21, '', 'the greate', '12.00', '0.00', '1'),
(121, 0, 'r', '12', '0.00', '12.00', '1'),
(120, 22, '', '12', '61.00', '0.00', '1'),
(120, 1, '', '', '75.00', '0.00', '1'),
(120, 7, '', '', '1500.00', '0.00', '1');

-- --------------------------------------------------------

--
-- Table structure for table `labortype`
--

DROP TABLE IF EXISTS `labortype`;
CREATE TABLE IF NOT EXISTS `labortype` (
  `laborid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `category` int(11) DEFAULT '0',
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`laborid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

--
-- Dumping data for table `labortype`
--

INSERT INTO `labortype` (`laborid`, `name`, `category`, `status`) VALUES
(1, 'Car Wash', 1, '1'),
(2, 'painting', 3, '1'),
(4, 'breaking', 5, '1'),
(22, 'change mirror', 0, '1'),
(7, 'change oil', 0, '1'),
(10, 'change tire', 0, '1'),
(14, 'preventive maintenance', 0, '1'),
(21, 'tongbens', 0, '1'),
(20, '12', 0, '1');

-- --------------------------------------------------------

--
-- Table structure for table `option`
--

DROP TABLE IF EXISTS `option`;
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

DROP TABLE IF EXISTS `tendertype`;
CREATE TABLE IF NOT EXISTS `tendertype` (
  `tdr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`tdr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(50) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `username` varchar(35) DEFAULT NULL,
  `pword` varchar(32) DEFAULT NULL,
  `addr` mediumtext,
  `status` enum('0','1') DEFAULT NULL,
  `ut_id` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`u_id`),
  KEY `users_ibfk_1` (`ut_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`u_id`, `fname`, `mname`, `lname`, `username`, `pword`, `addr`, `status`, `ut_id`) VALUES
(3, 'Norberto', 'Quisil', 'Libago Jr', 'juntals', '81dc9bdb52d04dc20036dbd8313ed055', 'Poblacion Catarman Camiguin', '1', 1),
(4, 'Kenneth', 'Palmero', 'Vallejos', 'kenn', '2b45dd79684b41a595b5543904f1574a', 'Cugman Cagayan de Oro City', '1', 1),
(5, 'tongbens', 'bent', 'bentong', 'tongbens', '81dc9bdb52d04dc20036dbd8313ed055', 'alga catarman camiguin', '', 1),
(7, 'marc', 'monte', 'piedad', 'marc', '81dc9bdb52d04dc20036dbd8313ed055', 'macanhan', '1', 1),
(8, 'Nnrberto', 'Quisil', 'Libago', 'juntals3', '202cb962ac59075b964b07152d234b70', 'pob', '1', 1);

-- --------------------------------------------------------

--
-- Table structure for table `usertype`
--

DROP TABLE IF EXISTS `usertype`;
CREATE TABLE IF NOT EXISTS `usertype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `access` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `usertype`
--

INSERT INTO `usertype` (`id`, `type`, `access`) VALUES
(1, 'admin', 3),
(2, 'assistant', 5);

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

DROP TABLE IF EXISTS `vehicle`;
CREATE TABLE IF NOT EXISTS `vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `make` varchar(150) DEFAULT NULL,
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`v_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=30 ;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`v_id`, `make`, `status`) VALUES
(1, 'porsche', '1'),
(3, 'lamborgini', '1'),
(28, 'mitsubishi', '1'),
(23, 'ford', '1'),
(22, 'porschew', '1'),
(21, 'raider', '1'),
(20, 'highland', '1'),
(13, 'toyota revo', '1');

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
  ADD CONSTRAINT `FK_jodetails_1` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`ut_id`) REFERENCES `usertype` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
