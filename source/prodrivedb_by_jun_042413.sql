-- phpMyAdmin SQL Dump
-- version 3.3.9
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 24, 2013 at 05:23 AM
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
-- Table structure for table `option`
--

CREATE TABLE IF NOT EXISTS `option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `option_name` mediumtext,
  `option_value` longtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COMMENT='IMBA JUNTALS' AUTO_INCREMENT=9 ;

--
-- Dumping data for table `option`
--

INSERT INTO `option` (`id`, `option_name`, `option_value`) VALUES
(1, 'section_metahead', '{"0":"funcmeta"}'),
(2, 'section_metastyle', '{"0":"funcmetastyle"}'),
(3, 'section_metascript', '{"0":"funcmetasript"}'),
(4, 'section_masthead', '{"0":"funcone"}'),
(5, 'section_panels', '{"0":"functpaste","1":"dbconfig"}'),
(6, 'section_pasteboard', '{"0":"funcpasteboard"}'),
(7, 'section_toolbars', '{"0":"functoolbar"}'),
(8, 'section_footer', '{"0":"footerfunc"}');

-- --------------------------------------------------------

--
-- Table structure for table `tongbens_customer`
--

CREATE TABLE IF NOT EXISTS `tongbens_customer` (
  `c_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(50) NOT NULL,
  `m_name` varchar(50) NOT NULL,
  `l_name` varchar(50) NOT NULL,
  `addr` mediumtext NOT NULL,
  `phone` varchar(50) NOT NULL,
  `status` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`c_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `tongbens_customer`
--

INSERT INTO `tongbens_customer` (`c_id`, `f_name`, `m_name`, `l_name`, `addr`, `phone`, `status`) VALUES
(2, 'sdf', 'sdf', 'sdf', 'sdf', 'sfd', '1');

-- --------------------------------------------------------

--
-- Table structure for table `tongbens_joborder`
--

CREATE TABLE IF NOT EXISTS `tongbens_joborder` (
  `jo_id` int(11) NOT NULL AUTO_INCREMENT,
  `u_id` int(11) NOT NULL,
  `v_id` int(11) NOT NULL,
  `c_id` int(11) NOT NULL,
  `or_id` int(11) NOT NULL,
  `plate` varchar(50) NOT NULL,
  `color` varchar(20) NOT NULL,
  PRIMARY KEY (`jo_id`),
  KEY `u_id` (`u_id`),
  KEY `v_id` (`v_id`),
  KEY `c_id` (`c_id`),
  KEY `or_id` (`or_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `tongbens_joborder`
--


-- --------------------------------------------------------

--
-- Table structure for table `tongbens_labortype`
--

CREATE TABLE IF NOT EXISTS `tongbens_labortype` (
  `lt_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `status` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`lt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `tongbens_labortype`
--


-- --------------------------------------------------------

--
-- Table structure for table `tongbens_option`
--

CREATE TABLE IF NOT EXISTS `tongbens_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `option_name` mediumtext,
  `option_value` longtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COMMENT='IMBA JUNTALS' AUTO_INCREMENT=5 ;

--
-- Dumping data for table `tongbens_option`
--


-- --------------------------------------------------------

--
-- Table structure for table `tongbens_orderdetails`
--

CREATE TABLE IF NOT EXISTS `tongbens_orderdetails` (
  `or_id` int(11) NOT NULL AUTO_INCREMENT,
  `jo_id` int(11) NOT NULL,
  `lt_id` int(11) NOT NULL,
  `l_amnt` decimal(8,2) NOT NULL,
  `parts` mediumtext NOT NULL,
  `p_amnt` decimal(8,2) NOT NULL,
  PRIMARY KEY (`or_id`),
  KEY `lt_id` (`lt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `tongbens_orderdetails`
--


-- --------------------------------------------------------

--
-- Table structure for table `tongbens_users`
--

CREATE TABLE IF NOT EXISTS `tongbens_users` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(50) NOT NULL,
  `m_name` varchar(50) NOT NULL,
  `l_name` varchar(50) NOT NULL,
  `status` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`u_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `tongbens_users`
--


-- --------------------------------------------------------

--
-- Table structure for table `tongbens_vehicle`
--

CREATE TABLE IF NOT EXISTS `tongbens_vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  PRIMARY KEY (`v_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `tongbens_vehicle`
--


--
-- Constraints for dumped tables
--

--
-- Constraints for table `tongbens_joborder`
--
ALTER TABLE `tongbens_joborder`
  ADD CONSTRAINT `tongbens_joborder_ibfk_1` FOREIGN KEY (`u_id`) REFERENCES `tongbens_users` (`u_id`),
  ADD CONSTRAINT `tongbens_joborder_ibfk_2` FOREIGN KEY (`v_id`) REFERENCES `tongbens_vehicle` (`v_id`),
  ADD CONSTRAINT `tongbens_joborder_ibfk_3` FOREIGN KEY (`c_id`) REFERENCES `tongbens_customer` (`c_id`),
  ADD CONSTRAINT `tongbens_joborder_ibfk_4` FOREIGN KEY (`or_id`) REFERENCES `tongbens_orderdetails` (`or_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tongbens_orderdetails`
--
ALTER TABLE `tongbens_orderdetails`
  ADD CONSTRAINT `tongbens_orderdetails_ibfk_1` FOREIGN KEY (`lt_id`) REFERENCES `tongbens_labortype` (`lt_id`);
