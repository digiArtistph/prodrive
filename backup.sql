-- MySQL dump 10.13  Distrib 5.1.53, for Win64 (unknown)
--
-- Host: localhost    Database: prodrivedb
-- ------------------------------------------------------
-- Server version	5.1.53-community-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tongbens_customer`
--

DROP TABLE IF EXISTS `tongbens_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_customer` (
  `c_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(50) NOT NULL,
  `m_name` varchar(50) NOT NULL,
  `l_name` varchar(50) NOT NULL,
  `addr` mediumtext NOT NULL,
  `phone` varchar(50) NOT NULL,
  `status` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`c_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_customer`
--

LOCK TABLES `tongbens_customer` WRITE;
/*!40000 ALTER TABLE `tongbens_customer` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tongbens_joborder`
--

DROP TABLE IF EXISTS `tongbens_joborder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_joborder` (
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
  KEY `or_id` (`or_id`),
  CONSTRAINT `tongbens_joborder_ibfk_1` FOREIGN KEY (`u_id`) REFERENCES `tongbens_users` (`u_id`),
  CONSTRAINT `tongbens_joborder_ibfk_2` FOREIGN KEY (`v_id`) REFERENCES `tongbens_vehicle` (`v_id`),
  CONSTRAINT `tongbens_joborder_ibfk_3` FOREIGN KEY (`c_id`) REFERENCES `tongbens_customer` (`c_id`),
  CONSTRAINT `tongbens_joborder_ibfk_4` FOREIGN KEY (`or_id`) REFERENCES `tongbens_orderdetails` (`or_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_joborder`
--

LOCK TABLES `tongbens_joborder` WRITE;
/*!40000 ALTER TABLE `tongbens_joborder` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_joborder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tongbens_labortype`
--

DROP TABLE IF EXISTS `tongbens_labortype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_labortype` (
  `lt_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `status` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`lt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_labortype`
--

LOCK TABLES `tongbens_labortype` WRITE;
/*!40000 ALTER TABLE `tongbens_labortype` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_labortype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tongbens_option`
--

DROP TABLE IF EXISTS `tongbens_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `option_name` mediumtext,
  `option_value` longtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='IMBA JUNTALS';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_option`
--

LOCK TABLES `tongbens_option` WRITE;
/*!40000 ALTER TABLE `tongbens_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tongbens_orderdetails`
--

DROP TABLE IF EXISTS `tongbens_orderdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_orderdetails` (
  `or_id` int(11) NOT NULL AUTO_INCREMENT,
  `jo_id` int(11) NOT NULL,
  `lt_id` int(11) NOT NULL,
  `l_amnt` decimal(8,2) NOT NULL,
  `parts` mediumtext NOT NULL,
  `p_amnt` decimal(8,2) NOT NULL,
  PRIMARY KEY (`or_id`),
  KEY `lt_id` (`lt_id`),
  CONSTRAINT `tongbens_orderdetails_ibfk_1` FOREIGN KEY (`lt_id`) REFERENCES `tongbens_labortype` (`lt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_orderdetails`
--

LOCK TABLES `tongbens_orderdetails` WRITE;
/*!40000 ALTER TABLE `tongbens_orderdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_orderdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tongbens_users`
--

DROP TABLE IF EXISTS `tongbens_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_users` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(50) NOT NULL,
  `m_name` varchar(50) NOT NULL,
  `l_name` varchar(50) NOT NULL,
  `status` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`u_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_users`
--

LOCK TABLES `tongbens_users` WRITE;
/*!40000 ALTER TABLE `tongbens_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tongbens_vehicle`
--

DROP TABLE IF EXISTS `tongbens_vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tongbens_vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  PRIMARY KEY (`v_id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tongbens_vehicle`
--

LOCK TABLES `tongbens_vehicle` WRITE;
/*!40000 ALTER TABLE `tongbens_vehicle` DISABLE KEYS */;
/*!40000 ALTER TABLE `tongbens_vehicle` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-04-19 12:51:34
