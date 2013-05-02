-- phpMyAdmin SQL Dump
-- version 3.3.9
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 02, 2013 at 05:36 AM
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `color`
--


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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`custid`, `fname`, `mname`, `lname`, `addr`, `phone`, `status`) VALUES
(3, 'Emelie', 'Cepe', 'Nagales', 'Valencia Bukidnun', '09353738295', ''),
(5, 'Norberto', 'Mab', 'Libago Sr', 'Poblacion', '09352689566', '1'),
(9, 'Kenneth', 'Palmero', 'Vallejos', 'Cugman Cagayan De Oro', '09167958734', '1');

-- --------------------------------------------------------

--
-- Table structure for table `dcr`
--

CREATE TABLE IF NOT EXISTS `dcr` (
  `dcr_id` int(11) NOT NULL AUTO_INCREMENT,
  `particulars` mediumtext,
  `cash` decimal(8,2) DEFAULT '0.00',
  `check` decimal(8,2) DEFAULT '0.00',
  `total` decimal(8,2) DEFAULT '0.00',
  `user` tinyint(4) DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  `trnxdate` date DEFAULT '0000-00-00',
  PRIMARY KEY (`dcr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `dcr`
--


-- --------------------------------------------------------

--
-- Table structure for table `joborder`
--

CREATE TABLE IF NOT EXISTS `joborder` (
  `jo_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer` int(11) DEFAULT '0',
  `plate` varchar(50) DEFAULT NULL,
  `color` int(11) DEFAULT '0',
  `contactnumber` varchar(75) DEFAULT NULL,
  `address` mediumtext,
  `trnxdate` date DEFAULT NULL,
  PRIMARY KEY (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity' AUTO_INCREMENT=1 ;

--
-- Dumping data for table `joborder`
--


-- --------------------------------------------------------

--
-- Table structure for table `jodetails`
--

CREATE TABLE IF NOT EXISTS `jodetails` (
  `jo_id` int(11) NOT NULL DEFAULT '0',
  `labor` int(11) DEFAULT '0',
  `partmaterial` int(11) DEFAULT '0',
  `details` mediumtext,
  `laboramnt` decimal(8,2) DEFAULT '0.00',
  `partmaterialamnt` decimal(8,2) DEFAULT '0.00',
  `status` enum('0','1','2','3') DEFAULT NULL COMMENT '0:deactivated, 1:active, 2:reserved, 3:reserved',
  KEY `FK_jodetails_1` (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jodetails`
--


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
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `labortype`
--

INSERT INTO `labortype` (`laborid`, `name`, `category`, `status`) VALUES
(1, 'Car Wash', 1, '1'),
(2, 'painting', 3, '1'),
(4, 'breaking', 5, '1');

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`u_id`, `fname`, `mname`, `lname`, `username`, `pword`, `addr`, `status`, `ut_id`) VALUES
(3, 'Norberto', 'Quisil', 'Libago Jr', 'juntals', '81dc9bdb52d04dc20036dbd8313ed055', 'Poblacion Catarman Camiguin', '1', 1),
(4, 'Kenneth', 'Palmero', 'Vallejos', 'kenn', '1234', 'Cugman Cagayan de Oro City', '1', 1),
(5, 'tongbens', 'bent', 'bentong', 'tongbens', '81dc9bdb52d04dc20036dbd8313ed055', 'alga catarman camiguin', '', 1),
(7, 'marc', 'monte', 'piedad', 'marc', '81dc9bdb52d04dc20036dbd8313ed055', 'macanhan', '1', 1),
(8, 'Norberto', 'Quisil', 'Libago', 'juntals3', '202cb962ac59075b964b07152d234b70', 'pob', '1', 1);

-- --------------------------------------------------------

--
-- Table structure for table `usertype`
--

CREATE TABLE IF NOT EXISTS `usertype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `usertype`
--

INSERT INTO `usertype` (`id`, `type`) VALUES
(1, 'admin'),
(2, 'assistant');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE IF NOT EXISTS `vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `make` varchar(150) DEFAULT NULL,
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`v_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`v_id`, `make`, `status`) VALUES
(1, ' porche  ', '1'),
(3, 'lamborgini', '1');

--
-- Constraints for dumped tables
--

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
