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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashfloat`
--

LOCK TABLES `cashfloat` WRITE;
/*!40000 ALTER TABLE `cashfloat` DISABLE KEYS */;
INSERT INTO `cashfloat` VALUES (1,'abc123','From sir Mike',750.00,'2013-05-31',4,'1'),(2,'abc124','From Ma\'am Zen',200.00,'2013-05-31',4,'1');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashlift`
--

LOCK TABLES `cashlift` WRITE;
/*!40000 ALTER TABLE `cashlift` DISABLE KEYS */;
INSERT INTO `cashlift` VALUES (1,'bca321','For snacks as per Ma\'am Zen\'s instruction',150.00,'2013-05-31',4,'1');
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
INSERT INTO `customer` VALUES (3,'Emelie','Cepe','Nagales','Valencia Bukidnun','09353738295',''),(5,'Norberto','Mab','Libago Sr','Poblacion','09352689566','1'),(9,'Kenneth','Palmero','Vallejos','Cugman Cagayan De Oro','09167958734','1');
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcr`
--

LOCK TABLES `dcr` WRITE;
/*!40000 ALTER TABLE `dcr` DISABLE KEYS */;
INSERT INTO `dcr` VALUES (2,'2013-05-17',1500.00,4,'1'),(3,'2013-05-18',1250.00,4,'1'),(4,'2013-05-24',1500.00,4,'1'),(5,'2013-05-25',1500.00,4,'1'),(6,'2013-05-26',1500.00,4,'1'),(7,'2013-05-27',1500.00,4,'1'),(8,'2013-05-27',1500.00,0,'1'),(9,'2013-05-30',500.00,4,'1'),(10,'2013-05-31',500.00,4,'1');
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
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcrdetails`
--

LOCK TABLES `dcrdetails` WRITE;
/*!40000 ALTER TABLE `dcrdetails` DISABLE KEYS */;
INSERT INTO `dcrdetails` VALUES (7,56,'Car Wash','ref1',150.00,1),(7,57,'Change Oil','ref1',1750.00,1),(9,58,'Change Oil','ref1',1500.00,1),(10,59,'Change Tire','ref1',225.00,1),(10,60,'Change Oil','ref1',2250.00,2),(10,61,'Car Wash','',250.00,1);
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
  PRIMARY KEY (`jo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joborder`
--

LOCK TABLES `joborder` WRITE;
/*!40000 ALTER TABLE `joborder` DISABLE KEYS */;
INSERT INTO `joborder` VALUES (120,'tongbens',28,3,'12',1,'21','12','2013-05-12'),(131,'45',1,3,'3',1,'3','3','2013-05-17'),(132,'13',3,3,'12',2,'12','12','2013-05-17'),(134,'pot',3,3,'re',6,'12','re','2013-05-17'),(135,'122',1,5,'12',1,'12','12','2013-05-29'),(140,'12345',1,3,'KPV563',1,'+639277745663','Cugman','2013-05-30'),(141,'12345',1,3,'KPV563',1,'+639277745663','Baloy','2013-05-30'),(142,'12345',1,3,'NQL654',1,'+639277745663','Baloy','2013-05-30'),(143,'12345',1,3,'NQL654',1,'+639277745663','Baloy','2013-05-30');
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
  KEY `FK_jodetails_1` (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jodetails`
--

LOCK TABLES `jodetails` WRITE;
/*!40000 ALTER TABLE `jodetails` DISABLE KEYS */;
INSERT INTO `jodetails` VALUES (135,20,'','12',12.00,'1'),(140,0,'','Testing insert',500.25,'0'),(140,0,'','Testing insert',500.25,'0'),(140,0,'','Testing insert',500.25,'0'),(140,0,'','Testing insert',500.25,'0'),(140,0,'','Testing insert',500.25,'0'),(140,0,'','Testing insert',500.25,'0'),(141,1,'','Testing insert',500.25,'0'),(141,1,'','Testing insert',500.25,'0'),(141,1,'','Testing insert',500.25,'0'),(141,1,'','Testing insert',500.25,'0'),(141,1,'','Testing insert',500.25,'0'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(142,1,'','Testing insert',500.25,'1'),(143,1,'','Testing insert',500.25,'1'),(143,1,'','Testing insert',500.25,'1'),(143,1,'','Testing insert',500.25,'1'),(143,1,'','Testing insert',500.25,'1'),(143,1,'','Testing insert',500.25,'1');
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
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `labortype`
--

LOCK TABLES `labortype` WRITE;
/*!40000 ALTER TABLE `labortype` DISABLE KEYS */;
INSERT INTO `labortype` VALUES (1,'Car Wash',1,'1'),(2,'Painting',1,'1'),(4,'Breaking',5,'1'),(22,'Change Mirror',1,'1'),(7,'change oil',0,'1'),(10,'change tire',0,'1');
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
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logintrace`
--

LOCK TABLES `logintrace` WRITE;
/*!40000 ALTER TABLE `logintrace` DISABLE KEYS */;
INSERT INTO `logintrace` VALUES (1,'juntals','1','2013-05-28 16:44:07'),(2,'juntals','1','2013-05-28 16:55:26'),(3,'juntals01','0','2013-05-28 16:56:06'),(4,'juntals','1','2013-05-28 16:57:03'),(5,'juntals','1','2013-05-29 07:18:22'),(6,'juntals','1','2013-05-29 10:05:58'),(7,'juntals','1','2013-05-29 14:12:50'),(8,'juntals','1','2013-05-29 23:52:24'),(9,'juntals','1','2013-05-30 00:32:29'),(10,'kenn','1','2013-05-30 06:46:08'),(11,'kenn','1','2013-05-30 14:14:46'),(12,'kenn','1','2013-05-30 22:39:41'),(13,'kenn','1','2013-05-31 04:19:19'),(14,'kenn','0','2013-05-31 04:19:44'),(15,'kenn','1','2013-05-31 04:19:51');
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
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tmp_jo_details_cache`
--

LOCK TABLES `tmp_jo_details_cache` WRITE;
/*!40000 ALTER TABLE `tmp_jo_details_cache` DISABLE KEYS */;
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
  `status` enum('0','1') DEFAULT NULL,
  `ut_id` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`u_id`),
  KEY `users_ibfk_1` (`ut_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`ut_id`) REFERENCES `usertype` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (3,'Norberto','Quisil','Libago Jr','juntals','81dc9bdb52d04dc20036dbd8313ed055','Poblacion Catarman Camiguin','1',1),(4,'Kenneth','Palmero','Vallejos','kenn','2b45dd79684b41a595b5543904f1574a','Cugman Cagayan de Oro City','1',1),(5,'tongbens','bent','bentong','tongbens','81dc9bdb52d04dc20036dbd8313ed055','alga catarman camiguin','',1),(7,'marc','monte','piedad','marc','81dc9bdb52d04dc20036dbd8313ed055','macanhan','1',1),(8,'Nnrberto','Quisil','Libago','juntals3','202cb962ac59075b964b07152d234b70','pob','1',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usertype`
--

LOCK TABLES `usertype` WRITE;
/*!40000 ALTER TABLE `usertype` DISABLE KEYS */;
INSERT INTO `usertype` VALUES (1,'admin',3),(2,'assistant',5);
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
  PRIMARY KEY (`v_id`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
INSERT INTO `vehicle` VALUES (1,' Porsche  ','1'),(3,'Toyota','1'),(28,' Mitsubishi  ','1'),(23,'ford','1'),(22,'porschew','1'),(21,'raider','1'),(20,'highland','1'),(13,'toyota revo','1');
/*!40000 ALTER TABLE `vehicle` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-05-31 13:38:25
