-- MySQL dump 10.13  Distrib 5.5.24, for Win64 (x86)
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
INSERT INTO `categories` VALUES (1,'Preventive Maintenance Services',6),(3,'Change Oil',3),(4,'Exhaust System',0),(5,'Break System',3),(6,'Cool/Heat System',0);
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
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `color`
--

LOCK TABLES `color` WRITE;
/*!40000 ALTER TABLE `color` DISABLE KEYS */;
INSERT INTO `color` VALUES (1,'Red'),(2,'Blue'),(3,'Green'),(6,'Sky Blue'),(25,'Yellow'),(10,'Silver'),(24,'Brown'),(23,'Black Forest'),(13,'Dark Red'),(22,'White'),(26,'Aqua Marine'),(27,'Fuschia');
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
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (3,'Emelie','Cepe','Nagales','Valencia Bukidnun','09353738295','1'),(5,'Norberto','Mab','Libago Sr','Poblacion','09352689566','1'),(9,'Kenneth','Palmero','Vallejos','Cugman Cagayan De Oro','09167958734','1');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcr`
--

LOCK TABLES `dcr` WRITE;
/*!40000 ALTER TABLE `dcr` DISABLE KEYS */;
INSERT INTO `dcr` VALUES (1,'2013-06-07',500.00,4,'1'),(2,'2013-06-08',450.00,4,'1');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcrdetails`
--

LOCK TABLES `dcrdetails` WRITE;
/*!40000 ALTER TABLE `dcrdetails` DISABLE KEYS */;
INSERT INTO `dcrdetails` VALUES (1,6,'Overhaul || 1000.00','2',750.00,1),(1,7,'Yokohama Tire || 5000.00','1',10.00,1),(2,8,'Nagales, Emelie','1',150.00,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joborder`
--

LOCK TABLES `joborder` WRITE;
/*!40000 ALTER TABLE `joborder` DISABLE KEYS */;
INSERT INTO `joborder` VALUES (1,'000001',4,3,' KVM012 --  Mitsubishi  ',0,NULL,NULL,'2013-06-07',0.00,0.00,'1'),(2,'000002',3,5,' KVP867 -- Toyota',0,NULL,NULL,'2013-06-07',0.00,0.00,'1');
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
  CONSTRAINT `jodetails_ibfk_2` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `jodetails_ibfk_1` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jodetails`
--

LOCK TABLES `jodetails` WRITE;
/*!40000 ALTER TABLE `jodetails` DISABLE KEYS */;
INSERT INTO `jodetails` VALUES (1,10,'','',75.00,'1'),(1,0,'Yokohama Tire','Yokohama tire bought from other supplier',5000.00,'1'),(2,23,'','',1000.00,'1');
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
) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `labortype`
--

LOCK TABLES `labortype` WRITE;
/*!40000 ALTER TABLE `labortype` DISABLE KEYS */;
INSERT INTO `labortype` VALUES (1,'Car Wash',1,'1'),(2,'Painting',1,'1'),(4,'Breaking',5,'1'),(22,'Change Mirror',1,'1'),(7,'Change Oil',1,'1'),(10,'Change Tire',1,'1'),(23,'Overhaul',1,'1');
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
) ENGINE=MyISAM AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logintrace`
--

LOCK TABLES `logintrace` WRITE;
/*!40000 ALTER TABLE `logintrace` DISABLE KEYS */;
INSERT INTO `logintrace` VALUES (1,'juntals','1','2013-05-28 16:44:07'),(2,'juntals','1','2013-05-28 16:55:26'),(3,'juntals01','0','2013-05-28 16:56:06'),(4,'juntals','1','2013-05-28 16:57:03'),(5,'juntals','1','2013-05-29 07:18:22'),(6,'juntals','1','2013-05-29 10:05:58'),(7,'juntals','1','2013-05-29 14:12:50'),(8,'juntals','1','2013-05-29 23:52:24'),(9,'juntals','1','2013-05-30 00:32:29'),(10,'kenn','1','2013-05-30 06:46:08'),(11,'kenn','1','2013-05-30 14:14:46'),(12,'kenn','1','2013-05-30 22:39:41'),(13,'kenn','1','2013-05-31 04:19:19'),(14,'kenn','0','2013-05-31 04:19:44'),(15,'kenn','1','2013-05-31 04:19:51'),(16,'kenn','1','2013-06-02 07:11:17'),(17,'kenn','1','2013-06-03 07:51:42'),(18,'kenn','1','2013-06-03 19:03:47'),(19,'kenn','1','2013-06-04 02:03:11'),(20,'kenn','1','2013-06-04 23:20:57'),(21,'kenn','1','2013-06-05 01:48:00'),(22,'kenn','1','2013-06-05 15:27:53'),(23,'kenn','1','2013-06-05 18:59:57'),(24,'digiartist','0','2013-06-05 22:54:00'),(25,'kenn','0','2013-06-05 22:54:06'),(26,'kenn','0','2013-06-05 22:54:17'),(27,'kenn','1','2013-06-05 22:54:30'),(28,'kenn','1','2013-06-06 06:29:59'),(29,'kenn','1','2013-06-06 15:11:03'),(30,'kenn','0','2013-06-06 18:07:33'),(31,'kenn','1','2013-06-06 18:07:39'),(32,'kenn','1','2013-06-07 18:09:18'),(33,'kenn','1','2013-06-07 06:36:08'),(34,'kenn','1','2013-06-08 06:45:25'),(35,'kenn','1','2013-06-09 06:45:58'),(36,'kenn','1','2013-06-07 06:50:12'),(37,'marc','1','2013-06-07 07:28:23'),(38,'kenn','1','2013-06-07 07:30:08'),(39,'kenn','1','2013-06-07 09:30:37'),(40,'kenn','1','2013-06-07 11:24:21'),(41,'kenn','1','2013-06-07 17:41:40'),(42,'kenn','1','2013-06-07 17:49:54'),(43,'emz','0','2013-06-07 17:55:25'),(44,'emz','0','2013-06-07 17:55:32'),(45,'emz','0','2013-06-07 17:56:02'),(46,'emz','0','2013-06-07 17:56:28'),(47,'kenn','1','2013-06-07 17:59:52'),(48,'emz','1','2013-06-07 18:00:59'),(49,'kenn','1','2013-06-07 18:10:15'),(50,'emz','1','2013-06-07 18:12:47'),(51,'kenn','1','2013-06-07 18:18:18');
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
) ENGINE=MEMORY AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tmp_jo_details_cache`
--

LOCK TABLES `tmp_jo_details_cache` WRITE;
/*!40000 ALTER TABLE `tmp_jo_details_cache` DISABLE KEYS */;
INSERT INTO `tmp_jo_details_cache` VALUES (1,23,'','',1000.00);
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (3,'Norberto','Quisil','Libago Jr','juntals','81dc9bdb52d04dc20036dbd8313ed055','Poblacion Catarman Camiguin','1',1),(4,'Kenneth','Palmero','Vallejos','kenn','2b45dd79684b41a595b5543904f1574a','Cugman Cagayan de Oro City','1',1),(10,'Emelie Agnes','Q.','Nagales','emz','827ccb0eea8a706c4c34a16891f84e7b','Valencia','1',2);
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
) ENGINE=MyISAM AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
INSERT INTO `vehicle` VALUES (3,'Toyota','1'),(28,' Mitsubishi  ','1'),(34,'Ford','1'),(33,'Honda','1');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_owner`
--

LOCK TABLES `vehicle_owner` WRITE;
/*!40000 ALTER TABLE `vehicle_owner` DISABLE KEYS */;
INSERT INTO `vehicle_owner` VALUES (1,'RBR649',13,28,'This is a test description',3,'1'),(2,'KRP456',22,34,'Company Car',9,'1'),(3,'KVP867',22,3,'Taxi Cab',5,'1'),(4,'KVM012',1,28,'Lancer',3,'1');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_receive`
--

LOCK TABLES `vehicle_receive` WRITE;
/*!40000 ALTER TABLE `vehicle_receive` DISABLE KEYS */;
INSERT INTO `vehicle_receive` VALUES (2,5,3,'2013-06-05','1',4),(3,3,4,'2013-06-05','1',4),(4,9,2,'2013-06-05','1',4);
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

-- Dump completed on 2013-06-08  2:31:37
