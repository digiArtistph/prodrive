-- MySQL dump 10.13  Distrib 5.5.24, for Win32 (x86)
--
-- Host: localhost    Database: prodrivedb
-- ------------------------------------------------------
-- Server version	5.5.24-log

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
-- Table structure for table `cashfloat`
--

DROP TABLE IF EXISTS `cashfloat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashfloat` (
  `cf_id` int(11) NOT NULL AUTO_INCREMENT,
  `refno` varchar(150) DEFAULT NULL,
  `particulars` mediumtext,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `trnxdate` date DEFAULT NULL,
  `cashier` tinyint(4) DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`cf_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashfloat`
--

LOCK TABLES `cashfloat` WRITE;
/*!40000 ALTER TABLE `cashfloat` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashfloat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashlift`
--

DROP TABLE IF EXISTS `cashlift`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashlift` (
  `cl_id` int(11) NOT NULL AUTO_INCREMENT,
  `refno` varchar(150) DEFAULT NULL,
  `particulars` mediumtext,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `trnxdate` date DEFAULT NULL,
  `cashier` tinyint(4) DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`cl_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashlift`
--

LOCK TABLES `cashlift` WRITE;
/*!40000 ALTER TABLE `cashlift` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashlift` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `categ_id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(150) DEFAULT NULL,
  `parent` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`categ_id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Preventive Maintenance Services',6),(3,'Change Oil',3),(4,'Exhaust System',0),(5,'Braking',3),(6,'Cool/Heat System',0);
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `color`
--

DROP TABLE IF EXISTS `color`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `color` (
  `clr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`clr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `color`
--

LOCK TABLES `color` WRITE;
/*!40000 ALTER TABLE `color` DISABLE KEYS */;
INSERT INTO `color` VALUES (1,'Red'),(2,'Blue'),(3,'Green'),(6,'Sky Blue'),(25,'Yellow'),(10,'Silver'),(24,'Brown'),(23,'Black Forest'),(13,'Dark Red'),(22,'White'),(26,'Aqua Marine'),(27,'Fuschia'),(31,'BLACK');
/*!40000 ALTER TABLE `color` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `custid` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(255) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `addr` mediumtext,
  `phone` varchar(255) DEFAULT NULL,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`custid`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (28,'LEONARDO','','KHU','','09177170759','1'),(27,'MARK','','ILOGON','','09177170759','1'),(26,'ARNEL','','SANCHEZ','CAGAYAN','+63','1'),(25,'Mike','M','Padero','Cag. de Oro','09177170108','1'),(29,'GERRY','','GALVEZ','','09177170759','1'),(30,'ROMY','','JUMALON','','09177170759','1'),(31,'PEGGY ANN','','SEBASTIAN','','09177170759','1'),(32,'PATRICK','','ABSIN','','09','1');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dcr`
--

DROP TABLE IF EXISTS `dcr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dcr` (
  `dcr_id` int(11) NOT NULL AUTO_INCREMENT,
  `trnxdate` date DEFAULT NULL,
  `begbal` decimal(8,2) DEFAULT NULL,
  `cashier` tinyint(4) DEFAULT NULL,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`dcr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcr`
--

LOCK TABLES `dcr` WRITE;
/*!40000 ALTER TABLE `dcr` DISABLE KEYS */;
/*!40000 ALTER TABLE `dcr` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dcrdetails`
--

DROP TABLE IF EXISTS `dcrdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dcrdetails` (
  `dcr_id` int(11) NOT NULL DEFAULT '0',
  `dcrdtl_id` int(11) NOT NULL AUTO_INCREMENT,
  `particulars` mediumtext,
  `refno` varchar(15) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `tender` tinyint(4) DEFAULT '0',
  UNIQUE KEY `dcrdtl_id` (`dcrdtl_id`),
  KEY `FK_dcrdetails_1` (`dcr_id`),
  CONSTRAINT `FK_dcrdetails_1` FOREIGN KEY (`dcr_id`) REFERENCES `dcr` (`dcr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcrdetails`
--

LOCK TABLES `dcrdetails` WRITE;
/*!40000 ALTER TABLE `dcrdetails` DISABLE KEYS */;
/*!40000 ALTER TABLE `dcrdetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `joborder`
--

DROP TABLE IF EXISTS `joborder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `joborder` (
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joborder`
--

LOCK TABLES `joborder` WRITE;
/*!40000 ALTER TABLE `joborder` DISABLE KEYS */;
INSERT INTO `joborder` VALUES (6,'000006',7,27,' MFN 122 -- MULTICAB',0,NULL,NULL,'2013-01-04',0.00,0.00,'1'),(7,'000007',8,28,' KHU-111 -- HONDA CR-V',0,NULL,NULL,'2013-01-04',0.00,0.00,'1'),(8,'000008',9,29,' MFB-115 -- CHEVROLET SPARK',0,NULL,NULL,'2013-01-04',0.00,0.00,'1'),(9,'000009',10,26,' UAR-731 -- HONDA CIVIC ESI',0,NULL,NULL,'2013-01-04',0.00,0.00,'1'),(10,'000010',11,30,' 0000 -- NO MAKE',0,NULL,NULL,'2013-01-03',0.00,0.00,'1'),(11,'000011',12,31,' KCT-107 -- TOYOTA REVO',0,NULL,NULL,'2013-01-03',0.00,0.00,'1'),(12,'000012',12,31,' KCT-107 -- TOYOTA REVO',0,NULL,NULL,'2013-01-03',0.00,0.00,'1');
/*!40000 ALTER TABLE `joborder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jodetails`
--

DROP TABLE IF EXISTS `jodetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jodetails` (
  `jo_id` int(11) NOT NULL DEFAULT '0',
  `labor` int(11) DEFAULT '0',
  `partmaterial` varchar(255) DEFAULT '0',
  `details` mediumtext,
  `amnt` decimal(8,2) DEFAULT '0.00',
  `status` enum('0','1','2','3') DEFAULT '0' COMMENT '0:deactivated, 1:active, 2:reserved, 3:reserved',
  KEY `FK_jodetails_1` (`jo_id`),
  CONSTRAINT `jodetails_ibfk_1` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`),
  CONSTRAINT `jodetails_ibfk_2` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jodetails`
--

LOCK TABLES `jodetails` WRITE;
/*!40000 ALTER TABLE `jodetails` DISABLE KEYS */;
INSERT INTO `jodetails` VALUES (6,0,'1 SET BRAKE MASTER KIT','',325.00,'1'),(6,0,'BRAKE FLUID','',100.00,'1'),(6,0,'BRAKE FLUID','',100.00,'1'),(6,33,'','',450.00,'1'),(7,0,'1 PC. OIL FILTER','',290.00,'1'),(7,0,'4 L SYNTHETIC','',3200.00,'1'),(7,0,'1 PC. HOOD CABLE','',980.00,'1'),(7,7,'','',150.00,'1'),(7,30,'','',350.00,'1'),(8,31,'','',450.00,'1'),(8,0,'4 PCS. SCREW','',10.00,'1'),(9,24,'','',550.00,'1'),(10,34,'','',200.00,'1'),(11,35,'','',550.00,'1'),(12,35,'','',550.00,'1'),(12,36,'','',100.00,'1'),(12,7,'','',150.00,'1'),(12,0,'1 PC. OIL FILTER','',300.00,'1'),(12,0,'1 GAL. ENGINE OIL','',950.00,'1');
/*!40000 ALTER TABLE `jodetails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `labortype`
--

DROP TABLE IF EXISTS `labortype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `labortype` (
  `laborid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `category` int(11) DEFAULT '0',
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`laborid`)
) ENGINE=MyISAM AUTO_INCREMENT=37 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `labortype`
--

LOCK TABLES `labortype` WRITE;
/*!40000 ALTER TABLE `labortype` DISABLE KEYS */;
INSERT INTO `labortype` VALUES (1,'Car Wash',1,'1'),(2,'Painting',1,'1'),(4,'Braking',5,'1'),(22,'Change Mirror',1,'1'),(7,'Change Oil',1,'1'),(10,'Change Tire',1,'1'),(23,'Overhaul',1,'1'),(24,'CHECK DISTRIBUTOR',1,'1'),(25,'REPLACE FUEL FILTER',1,'1'),(26,'REPLACE MAP SENSOR',1,'1'),(27,'OVERHAUL DISTRIBUTOR',1,'1'),(28,'BATTERY CHARGING',1,'1'),(29,'REMOVAL & REINSTALL DISTRIBUTOR',1,'1'),(30,'REPLACE HOOD CABLE',1,'1'),(31,'INSTALL TACOMETER',1,'1'),(32,'BRAKE MASTER KIT LEAKING',1,'1'),(33,'REPLACE MASTER KIT LEAKING',1,'1'),(34,'WELDING TANK',1,'1'),(35,'REPAIR STARTER',1,'1'),(36,'check V-belt loose tension/tighten',1,'1');
/*!40000 ALTER TABLE `labortype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logintrace`
--

DROP TABLE IF EXISTS `logintrace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logintrace` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(35) DEFAULT NULL,
  `succeeded` enum('0','1') DEFAULT '0',
  `tracetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=63 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logintrace`
--

LOCK TABLES `logintrace` WRITE;
/*!40000 ALTER TABLE `logintrace` DISABLE KEYS */;
INSERT INTO `logintrace` VALUES (1,'juntals','1','2013-05-28 16:44:07'),(2,'juntals','1','2013-05-28 16:55:26'),(3,'juntals01','0','2013-05-28 16:56:06'),(4,'juntals','1','2013-05-28 16:57:03'),(5,'juntals','1','2013-05-29 07:18:22'),(6,'juntals','1','2013-05-29 10:05:58'),(7,'juntals','1','2013-05-29 14:12:50'),(8,'juntals','1','2013-05-29 23:52:24'),(9,'juntals','1','2013-05-30 00:32:29'),(10,'kenn','1','2013-05-30 06:46:08'),(11,'kenn','1','2013-05-30 14:14:46'),(12,'kenn','1','2013-05-30 22:39:41'),(13,'kenn','1','2013-05-31 04:19:19'),(14,'kenn','0','2013-05-31 04:19:44'),(15,'kenn','1','2013-05-31 04:19:51'),(16,'kenn','1','2013-06-02 07:11:17'),(17,'kenn','1','2013-06-03 07:51:42'),(18,'kenn','1','2013-06-03 19:03:47'),(19,'kenn','1','2013-06-04 02:03:11'),(20,'kenn','1','2013-06-04 23:20:57'),(21,'kenn','1','2013-06-05 01:48:00'),(22,'kenn','1','2013-06-05 15:27:53'),(23,'kenn','1','2013-06-05 18:59:57'),(24,'digiartist','0','2013-06-05 22:54:00'),(25,'kenn','0','2013-06-05 22:54:06'),(26,'kenn','0','2013-06-05 22:54:17'),(27,'kenn','1','2013-06-05 22:54:30'),(28,'kenn','1','2013-06-06 06:29:59'),(29,'kenn','1','2013-06-06 15:11:03'),(30,'kenn','0','2013-06-06 18:07:33'),(31,'kenn','1','2013-06-06 18:07:39'),(32,'kenn','1','2013-06-07 18:09:18'),(33,'kenn','1','2013-06-07 06:36:08'),(34,'kenn','1','2013-06-08 06:45:25'),(35,'kenn','1','2013-06-09 06:45:58'),(36,'kenn','1','2013-06-07 06:50:12'),(37,'marc','1','2013-06-07 07:28:23'),(38,'kenn','1','2013-06-07 07:30:08'),(39,'kenn','1','2013-06-07 09:30:37'),(40,'kenn','1','2013-06-07 11:24:21'),(41,'kenn','1','2013-06-07 17:41:40'),(42,'kenn','1','2013-06-07 17:49:54'),(43,'emz','0','2013-06-07 17:55:25'),(44,'emz','0','2013-06-07 17:55:32'),(45,'emz','0','2013-06-07 17:56:02'),(46,'emz','0','2013-06-07 17:56:28'),(47,'kenn','1','2013-06-07 17:59:52'),(48,'emz','1','2013-06-07 18:00:59'),(49,'kenn','1','2013-06-07 18:10:15'),(50,'emz','1','2013-06-07 18:12:47'),(51,'kenn','1','2013-06-07 18:18:18'),(52,'kenn','1','2013-06-08 01:19:20'),(53,'ken','0','2013-05-29 10:31:36'),(54,'kenn','1','2013-05-29 10:31:40'),(55,'kenn','1','2013-06-08 10:32:13'),(56,'admin','1','2013-06-08 11:19:57'),(57,'admin','1','2013-06-08 11:20:46'),(58,'nanettee','1','2013-06-08 11:24:28'),(59,'NANETTEE','1','2013-06-08 11:58:08'),(60,'nanettee','1','2013-06-08 23:50:14'),(61,'NANETTEE','1','2013-06-09 04:18:03'),(62,'NANETTEE','1','2013-06-09 04:42:03');
/*!40000 ALTER TABLE `logintrace` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `option`
--

DROP TABLE IF EXISTS `option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `option_name` mediumtext,
  `option_value` longtext,
  `autoload` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=27 DEFAULT CHARSET=latin1 COMMENT='IMBA JUNTALS';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `option`
--

LOCK TABLES `option` WRITE;
/*!40000 ALTER TABLE `option` DISABLE KEYS */;
INSERT INTO `option` VALUES (1,'section_metahead','{\"0\":\"funcmeta\"}','1'),(2,'section_metastyle','{\"0\":\"funcmetastyle\"}','1'),(3,'section_metascript','{\"0\":\"funcmetasript\"}','1'),(4,'section_masthead','{\"0\":\"funcone\"}','1'),(5,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1'),(6,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1'),(7,'section_toolbars','{\"0\":\"functoolbar\"}','1'),(8,'section_footer','{\"0\":\"footerfunc\"}','1'),(9,'section_metahead','{\"0\":\"funcmeta\"}','1'),(10,'section_metastyle','{\"0\":\"funcmetastyle\"}','1'),(11,'section_metascript','{\"0\":\"funcmetasript\"}','1'),(12,'section_masthead','{\"0\":\"funcone\"}','1'),(13,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1'),(14,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1'),(15,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1'),(16,'section_toolbars','{\"0\":\"functoolbar\"}','1'),(17,'section_footer','{\"0\":\"footerfunc\"}','1'),(18,'section_metahead','{\"0\":\"funcmeta\"}','1'),(19,'section_metastyle','{\"0\":\"funcmetastyle\"}','1'),(20,'section_metascript','{\"0\":\"funcmetasript\"}','1'),(21,'section_masthead','{\"0\":\"funcone\"}','1'),(22,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1'),(23,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1'),(24,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1'),(25,'section_toolbars','{\"0\":\"functoolbar\"}','1'),(26,'section_footer','{\"0\":\"footerfunc\"}','1');
/*!40000 ALTER TABLE `option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tendertype`
--

DROP TABLE IF EXISTS `tendertype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tendertype` (
  `tdr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`tdr_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tendertype`
--

LOCK TABLES `tendertype` WRITE;
/*!40000 ALTER TABLE `tendertype` DISABLE KEYS */;
INSERT INTO `tendertype` VALUES (1,'Cash'),(2,'Check');
/*!40000 ALTER TABLE `tendertype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tmp_jo_details_cache`
--

DROP TABLE IF EXISTS `tmp_jo_details_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tmp_jo_details_cache` (
  `trace_id` int(11) NOT NULL AUTO_INCREMENT,
  `labor` int(11) NOT NULL DEFAULT '0',
  `partmaterial` varchar(255) DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `amnt` decimal(8,2) DEFAULT NULL,
  UNIQUE KEY `trace_id` (`trace_id`)
) ENGINE=MEMORY AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tmp_jo_details_cache`
--

LOCK TABLES `tmp_jo_details_cache` WRITE;
/*!40000 ALTER TABLE `tmp_jo_details_cache` DISABLE KEYS */;
INSERT INTO `tmp_jo_details_cache` VALUES (1,35,'','',550.00),(2,36,'','',100.00),(3,7,'','',150.00),(4,0,'1 PC. OIL FILTER','',300.00),(5,0,'1 GAL. ENGINE OIL','',950.00);
/*!40000 ALTER TABLE `tmp_jo_details_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `username`
--

DROP TABLE IF EXISTS `username`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `username` (
  `laborid` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(50) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `addr` mediumtext,
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`laborid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `username`
--

LOCK TABLES `username` WRITE;
/*!40000 ALTER TABLE `username` DISABLE KEYS */;
/*!40000 ALTER TABLE `username` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
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
  KEY `users_ibfk_1` (`ut_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`ut_id`) REFERENCES `usertype` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (11,'Administrator','Administrator','Administrator','admin','21232f297a57a5a743894a0e4a801fc3','Cag. de Oro','1',1),(12,'Nanettee','B','Pabalolot','nanettee','45614288deebcc7c6b1b3db530c48a3a','Cag. de Oro','1',2);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usertype`
--

DROP TABLE IF EXISTS `usertype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usertype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `access` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usertype`
--

LOCK TABLES `usertype` WRITE;
/*!40000 ALTER TABLE `usertype` DISABLE KEYS */;
INSERT INTO `usertype` VALUES (1,'admin',5),(2,'cashier',1),(3,'super cashier',3);
/*!40000 ALTER TABLE `usertype` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle`
--

DROP TABLE IF EXISTS `vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle` (
  `v_id` int(11) NOT NULL AUTO_INCREMENT,
  `make` varchar(150) DEFAULT NULL,
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`v_id`),
  KEY `Index_2` (`make`)
) ENGINE=MyISAM AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
INSERT INTO `vehicle` VALUES (3,'Toyota','1'),(28,' Mitsubishi  ','1'),(34,'Ford','1'),(33,'Honda','1'),(35,'NISSAN SENTRA 97','1'),(36,'MULTICAB','1'),(37,'HONDA CR-V','1'),(38,'CHEVROLET SPARK','1'),(39,'HONDA CIVIC ESI','1'),(40,'TOYOTA REVO','1'),(41,'TOYOTA REVO -2001','1'),(42,'TOYOTA VIOS -2010','1'),(43,'HONDA CITY','1'),(44,'TOYOTA HI-ACE GRANDIA','1'),(45,'HONDA CIVIC FD-10','1'),(46,'HONDA CIVIC \'96','1'),(47,'TOYOTA CAMRY 2000','1'),(48,'CHARADE','1'),(49,'ISUZU','1'),(50,'MITSUBISHI ECLAPSE','1'),(51,'HONDA CITY VTEC','1'),(52,'TOYOTA VIOS','1'),(53,'HONDA CIVIC VTI','1'),(54,'MITSUBISHI L300','1'),(55,'NISSAN URBAN \'09','1'),(56,'MITSUBISHI STRADA','1'),(57,'ISUZU HI-LANDER','1'),(58,'MATIZ','1'),(59,'TOYOTA INNOVA','1'),(61,'KIA PICANTO','1'),(62,'TAMARAW FX','1'),(63,'HYUNDAI GETZ','1'),(64,'ISUZU ELF','1'),(65,'TOYOTA VIOS 2009','1'),(66,'ISUZU FUEGO','1'),(67,'HONDA HATCHBACK','1'),(68,'TOYOTA HI-LUX \'95','1'),(69,'HONDA ACCORD','1'),(70,'MITSUBISHI STRADA 2004','1'),(71,'FORD RANGER PICK-UP','1'),(72,'ISUZU DMAX 2010','1'),(73,'NO MAKE','1');
/*!40000 ALTER TABLE `vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_owner`
--

DROP TABLE IF EXISTS `vehicle_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_owner` (
  `vo_id` int(11) NOT NULL AUTO_INCREMENT,
  `plateno` varchar(15) DEFAULT NULL,
  `color` int(11) NOT NULL DEFAULT '0',
  `make` int(11) NOT NULL DEFAULT '0',
  `description` varchar(255) DEFAULT NULL,
  `owner` int(11) NOT NULL DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`vo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_owner`
--

LOCK TABLES `vehicle_owner` WRITE;
/*!40000 ALTER TABLE `vehicle_owner` DISABLE KEYS */;
INSERT INTO `vehicle_owner` VALUES (7,'MFN 122',23,36,'',27,'1'),(8,'KHU-111',23,37,'',28,'1'),(9,'MFB-115',23,38,'',29,'1'),(10,'UAR-731',22,39,'',26,'1'),(11,'0000',23,73,'',30,'1'),(12,'KCT-107',10,40,'',31,'1');
/*!40000 ALTER TABLE `vehicle_owner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_receive`
--

DROP TABLE IF EXISTS `vehicle_receive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_receive` (
  `vr_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer` int(11) NOT NULL DEFAULT '0',
  `vehicle` int(11) NOT NULL DEFAULT '0',
  `recdate` date DEFAULT '0000-00-00',
  `status` enum('0','1') DEFAULT '1',
  `recby` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vr_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_receive`
--

LOCK TABLES `vehicle_receive` WRITE;
/*!40000 ALTER TABLE `vehicle_receive` DISABLE KEYS */;
INSERT INTO `vehicle_receive` VALUES (7,27,7,'2013-01-04','1',12),(8,28,8,'2013-01-04','1',12),(9,29,9,'2013-01-04','1',12),(10,26,10,'2013-01-04','1',12),(11,30,11,'2013-01-03','1',12),(12,31,12,'2013-01-03','1',12);
/*!40000 ALTER TABLE `vehicle_receive` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-06-09 13:21:03
