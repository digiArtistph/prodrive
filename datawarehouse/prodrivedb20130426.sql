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
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `categ_id` int(11) NOT NULL,
  `category` varchar(150) DEFAULT NULL,
  `parent` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`categ_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `color`
--

LOCK TABLES `color` WRITE;
/*!40000 ALTER TABLE `color` DISABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
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
  `particulars` mediumtext,
  `cash` decimal(8,2) DEFAULT '0.00',
  `check` decimal(8,2) DEFAULT '0.00',
  `total` decimal(8,2) DEFAULT '0.00',
  `user` tinyint(4) DEFAULT '0',
  `status` enum('0','1') DEFAULT '1',
  `trnxdate` date DEFAULT '0000-00-00',
  PRIMARY KEY (`dcr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dcr`
--

LOCK TABLES `dcr` WRITE;
/*!40000 ALTER TABLE `dcr` DISABLE KEYS */;
/*!40000 ALTER TABLE `dcr` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `joborder`
--

DROP TABLE IF EXISTS `joborder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `joborder` (
  `jo_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer` int(11) DEFAULT '0',
  `plate` varchar(50) DEFAULT NULL,
  `color` int(11) DEFAULT '0',
  `contactnumber` varchar(75) DEFAULT NULL,
  `address` mediumtext,
  `trnxdate` date DEFAULT NULL,
  PRIMARY KEY (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='enforces referential integrity';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joborder`
--

LOCK TABLES `joborder` WRITE;
/*!40000 ALTER TABLE `joborder` DISABLE KEYS */;
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
  `partmaterial` int(11) DEFAULT '0',
  `details` mediumtext,
  `laboramnt` decimal(8,2) DEFAULT '0.00',
  `partmaterialamnt` decimal(8,2) DEFAULT '0.00',
  `status` enum('0','1','2','3') DEFAULT NULL COMMENT '0:deactivated, 1:active, 2:reserved, 3:reserved',
  KEY `FK_jodetails_1` (`jo_id`),
  CONSTRAINT `FK_jodetails_1` FOREIGN KEY (`jo_id`) REFERENCES `joborder` (`jo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jodetails`
--

LOCK TABLES `jodetails` WRITE;
/*!40000 ALTER TABLE `jodetails` DISABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `labortype`
--

LOCK TABLES `labortype` WRITE;
/*!40000 ALTER TABLE `labortype` DISABLE KEYS */;
/*!40000 ALTER TABLE `labortype` ENABLE KEYS */;
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
) ENGINE=MyISAM AUTO_INCREMENT=459 DEFAULT CHARSET=latin1 COMMENT='IMBA JUNTALS';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `option`
--

LOCK TABLES `option` WRITE;
/*!40000 ALTER TABLE `option` DISABLE KEYS */;
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (1,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (2,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (3,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (4,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (5,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (6,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (7,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (8,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (9,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (10,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (11,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (12,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (13,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (14,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (15,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (16,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (17,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (18,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (19,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (20,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (21,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (22,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (23,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (24,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (25,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (26,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (27,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (28,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (29,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (30,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (31,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (32,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (33,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (34,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (35,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (36,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (37,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (38,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (39,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (40,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (41,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (42,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (43,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (44,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (45,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (46,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (47,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (48,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (49,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (50,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (51,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (52,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (53,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (54,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (55,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (56,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (57,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (58,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (59,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (60,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (61,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (62,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (63,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (64,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (65,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (66,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (67,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (68,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (69,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (70,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (71,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (72,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (73,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (74,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (75,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (76,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (77,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (78,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (79,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (80,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (81,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (82,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (83,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (84,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (85,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (86,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (87,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (88,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (89,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (90,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (91,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (92,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (93,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (94,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (95,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (96,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (97,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (98,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (99,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (100,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (101,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (102,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (103,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (104,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (105,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (106,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (107,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (108,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (109,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (110,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (111,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (112,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (113,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (114,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (115,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (116,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (117,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (118,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (119,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (120,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (121,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (122,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (123,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (124,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (125,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (126,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (127,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (128,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (129,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (130,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (131,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (132,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (133,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (134,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (135,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (136,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (137,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (138,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (139,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (140,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (141,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (142,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (143,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (144,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (145,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (146,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (147,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (148,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (149,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (150,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (151,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (152,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (153,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (154,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (155,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (156,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (157,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (158,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (159,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (160,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (161,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (162,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (163,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (164,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (165,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (166,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (167,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (168,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (169,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (170,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (171,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (172,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (173,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (174,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (175,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (176,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (177,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (178,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (179,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (180,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (181,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (182,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (183,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (184,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (185,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (186,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (187,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (188,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (189,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (190,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (191,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (192,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (193,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (194,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (195,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (196,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (197,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (198,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (199,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (200,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (201,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (202,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (203,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (204,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (205,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (206,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (207,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (208,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (209,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (210,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (211,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (212,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (213,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (214,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (215,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (216,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (217,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (218,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (219,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (220,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (221,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (222,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (223,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (224,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (225,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (226,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (227,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (228,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (229,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (230,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (231,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (232,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (233,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (234,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (235,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (236,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (237,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (238,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (239,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (240,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (241,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (242,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (243,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (244,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (245,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (246,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (247,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (248,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (249,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (250,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (251,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (252,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (253,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (254,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (255,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (256,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (257,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (258,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (259,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (260,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (261,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (262,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (263,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (264,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (265,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (266,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (267,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (268,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (269,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (270,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (271,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (272,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (273,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (274,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (275,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (276,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (277,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (278,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (279,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (280,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (281,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (282,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (283,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (284,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (285,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (286,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (287,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (288,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (289,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (290,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (291,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (292,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (293,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (294,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (295,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (296,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (297,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (298,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (299,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (300,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (301,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (302,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (303,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (304,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (305,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (306,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (307,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (308,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (309,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (310,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (311,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (312,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (313,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (314,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (315,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (316,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (317,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (318,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (319,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (320,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (321,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (322,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (323,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (324,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (325,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (326,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (327,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (328,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (329,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (330,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (331,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (332,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (333,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (334,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (335,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (336,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (337,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (338,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (339,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (340,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (341,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (342,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (343,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (344,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (345,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (346,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (347,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (348,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (349,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (350,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (351,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (352,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (353,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (354,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (355,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (356,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (357,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (358,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (359,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (360,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (361,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (362,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (363,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (364,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (365,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (366,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (367,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (368,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (369,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (370,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (371,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (372,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (373,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (374,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (375,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (376,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (377,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (378,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (379,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (380,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (381,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (382,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (383,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (384,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (385,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (386,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (387,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (388,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (389,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (390,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (391,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (392,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (393,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (394,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (395,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (396,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (397,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (398,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (399,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (400,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (401,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (402,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (403,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (404,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (405,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (406,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (407,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (408,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (409,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (410,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (411,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (412,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (413,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (414,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (415,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (416,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (417,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (418,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (419,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (420,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (421,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (422,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (423,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (424,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (425,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (426,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (427,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (428,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (429,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (430,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (431,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (432,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (433,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (434,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (435,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (436,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (437,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (438,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (439,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (440,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (441,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (442,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (443,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (444,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (445,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (446,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (447,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (448,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (449,'section_footer','{\"0\":\"footerfunc\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (450,'section_metahead','{\"0\":\"funcmeta\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (451,'section_metastyle','{\"0\":\"funcmetastyle\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (452,'section_metascript','{\"0\":\"funcmetasript\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (453,'section_masthead','{\"0\":\"funcone\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (454,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (455,'section_panels','{\"0\":\"dbconfig\",\"1\":\"functpaste\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (456,'section_pasteboard','{\"0\":\"funcpasteboard\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (457,'section_toolbars','{\"0\":\"functoolbar\"}','1');
INSERT INTO `option` (`id`, `option_name`, `option_value`, `autoload`) VALUES (458,'section_footer','{\"0\":\"footerfunc\"}','1');
/*!40000 ALTER TABLE `option` ENABLE KEYS */;
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
-- Table structure for table `usertype`
--

DROP TABLE IF EXISTS `usertype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usertype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usertype`
--

LOCK TABLES `usertype` WRITE;
/*!40000 ALTER TABLE `usertype` DISABLE KEYS */;
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle`
--

LOCK TABLES `vehicle` WRITE;
/*!40000 ALTER TABLE `vehicle` DISABLE KEYS */;
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

-- Dump completed on 2013-04-26 10:09:28
