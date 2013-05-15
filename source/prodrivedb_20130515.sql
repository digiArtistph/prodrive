-- phpMyAdmin SQL Dump
-- version 3.3.9
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 15, 2013 at 12:06 PM
-- Server version: 5.1.53
-- PHP Version: 5.3.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `prodrivedb`
--

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

--
-- Dumping data for table `cashfloat`
--


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

--
-- Dumping data for table `cashlift`
--


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
(5, 'Break System', 3),
(6, 'Cool/Heat System', 0);

-- --------------------------------------------------------

--
-- Table structure for table `color`
--

CREATE TABLE IF NOT EXISTS `color` (
  `clr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`clr_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=25 ;

--
-- Dumping data for table `color`
--

INSERT INTO `color` (`clr_id`, `name`) VALUES
(1, 'red'),
(2, 'blue'),
(3, 'green'),
(6, 'skyblue'),
(10, 'dark black'),
(24, 'brown'),
(23, 'dsf'),
(13, 'dark red'),
(22, 'white');

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
  PRIMARY KEY (`custid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=16 ;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`custid`, `fname`, `mname`, `lname`, `addr`, `phone`, `status`) VALUES
(3, 'Emelie', 'Cepe', 'Nagales', 'Valencia Bukidnun', '09353738295', ''),
(5, 'Norberto', 'Mab', 'Libago Sr', 'Poblacion', '09352689566', '1'),
(9, 'Kenneth', 'Palmero', 'Vallejos', 'Cugman Cagayan De Oro', '09167958734', '1'),
(13, 'romualdo', 'peidad', 'xavier justine', NULL, NULL, '1'),
(12, 'limbago', 'Quirta', 'john paul', NULL, NULL, '1'),
(14, 'libago', 'great', 'tongbens', NULL, NULL, '1'),
(15, 'tongbens', 'boski', 'james', NULL, NULL, '1');

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `dcr`
--


-- --------------------------------------------------------

--
-- Table structure for table `dcrdetails`
--

CREATE TABLE IF NOT EXISTS `dcrdetails` (
  `dcr_id` int(11) NOT NULL DEFAULT '0',
  `particulars` mediumtext,
  `refno` varchar(15) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `tender` tinyint(4) DEFAULT '0',
  KEY `FK_dcrdetails_1` (`dcr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dcrdetails`
--


-- --------------------------------------------------------

--
-- Table structure for table `joborder`
--

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
(119, 3, 9, 'hhh-0999', 1, '09352689566', 'cugman', '2013-05-12'),
(120, 3, 3, '12', 1, '21', '12', '2013-05-12'),
(121, 1, 3, '12', 1, '12', '21', '2013-05-12'),
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
(120, 18, '', '12', '21.00', '0.00', '1'),
(121, 18, '', '21', '12.00', '0.00', '1'),
(122, 18, '', '21', '21.00', '0.00', '1'),
(123, 18, '', '21', '21.00', '0.00', '1'),
(124, 18, '', '21', '12.00', '0.00', '1'),
(127, 19, '', '21', '21.00', '0.00', '1'),
(128, 20, '', '21', '21.00', '0.00', '1'),
(129, 14, '', 'tongbens the great', '12.00', '0.00', '1'),
(130, 0, '12', '12', '0.00', '12.00', '1');

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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=21 ;

--
-- Dumping data for table `labortype`
--

INSERT INTO `labortype` (`laborid`, `name`, `category`, `status`) VALUES
(1, 'Car Wash', 1, '1'),
(2, 'painting', 3, '1'),
(4, 'breaking', 5, '1'),
(7, 'change oil', 0, '1'),
(10, 'change tire', 0, '1'),
(14, 'preventive maintenance', 0, '1'),
(20, '12', 0, '1');

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `tendertype`
--


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
(4, 'Kenneth', 'Palmero', 'Vallejos', 'kenn', '81dc9bdb52d04dc20036dbd8313ed055', 'Cugman Cagayan de Oro City', '1', 1),
(5, 'tongbens', 'bent', 'bentong', 'tongbens', '81dc9bdb52d04dc20036dbd8313ed055', 'alga catarman camiguin', '', 1),
(7, 'marc', 'monte', 'piedad', 'marc', '81dc9bdb52d04dc20036dbd8313ed055', 'macanhan', '1', 1),
(8, 'Nnrberto', 'Quisil', 'Libago', 'juntals3', '202cb962ac59075b964b07152d234b70', 'pob', '1', 1);

-- --------------------------------------------------------

--
-- Table structure for table `usertype`
--

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

CREATE TABLE IF NOT EXISTS `vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `make` varchar(150) DEFAULT NULL,
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`v_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=22 ;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`v_id`, `make`, `status`) VALUES
(1, 'porsche', '1'),
(3, 'lamborgini', '1'),
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
