-- MySQL dump 10.13  Distrib 5.5.8, for Win32 (x86)
--
-- Host: localhost    Database: newcastledb
-- ------------------------------------------------------
-- Server version	5.5.8-log
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'newcastledb'
--
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `func_list_id`(itemnumber VARCHAR(255)) RETURNS int(11)
    DETERMINISTIC
BEGIN



  DECLARE listID INT DEFAULT 0;



  SET listID = TRIM(SUBSTRING_INDEX(itemnumber, '-', 1));



  RETURN listID;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_add_listing`(IN p_title VARCHAR(255), IN p_subcategory MEDIUMTEXT, IN p_images MEDIUMTEXT, IN p_advr INT, IN p_description MEDIUMTEXT, IN p_address VARCHAR(255), IN p_suburb VARCHAR(75), IN p_postcode VARCHAR(10), IN p_state INT, IN p_country INT, IN p_cname VARCHAR(255), IN p_phone VARCHAR(50), IN p_phone2 VARCHAR(50), IN p_email VARCHAR(255), IN p_url MEDIUMTEXT, IN p_package CHAR(1), IN p_recurrent VARCHAR(75), IN p_paypal VARCHAR(255), IN p_status CHAR(1))
BEGIN

DECLARE success INT DEFAULT 0;

DECLARE id INT DEFAULT 0;

DECLARE today TIMESTAMP DEFAULT CURRENT_TIMESTAMP;



DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;



START TRANSACTION;

  DROP TEMPORARY TABLE IF EXISTS `tmplast_id`;

  CREATE TEMPORARY TABLE `tmplast_id`(

    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,

    lstid INT NULL

    ) ENGINE=Memory COMMENT 'stores temporary LAST_ID INSERTED';





  
  INSERT INTO listing(title, subcategory, images, advr, description, address, suburb, postcode, state, country, cname, phone, phone2, email, url, package, recurrent, paypal, status) VALUES(p_title, p_subcategory, p_images, p_advr, p_description, p_address, p_suburb, p_postcode, p_state, p_country, p_cname, p_phone, p_phone2, p_email, p_url, p_package, p_recurrent, p_paypal, p_status);



  
  SET id = LAST_INSERT_ID();



  
  INSERT INTO `tmplast_id`(lstid) VALUE(id);



  
  INSERT INTO advertiser_listing(ad_id, lst_id, posted) VALUES(p_advr, id, today);



COMMIT;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_admin_listing`()
    SQL SECURITY INVOKER
BEGIN



   DECLARE eof INT DEFAULT 0;

   DECLARE mLst_id INT(11) DEFAULT 0;

   DECLARE mTitle VARCHAR(255) DEFAULT '';

   DECLARE mSubcategory VARCHAR(255) DEFAULT '';

   DECLARE mFullname VARCHAR(255) DEFAULT '';

   DECLARE mXpired CHAR(1) DEFAULT '0';

   DECLARE mCategoryFullName VARCHAR(255) DEFAULT '';

   DECLARE mTmpCateg VARCHAR(255) DEFAULT '';



   DECLARE cur_admin_listing CURSOR FOR SELECT l.lst_id, l.title, l.subcategory, CONCAT(a.fname, " ", a.lname) AS fullname, l.expired FROM listing l LEFT JOIN advertiser a ON l.advr=a.ad_id;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof = 1;



   DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

   DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;



   START TRANSACTION;



     DROP TEMPORARY TABLE IF EXISTS `tmpadminlistingtbl`;

     CREATE TEMPORARY TABLE `tmpadminlistingtbl`(

       id INT NOT NULL AUTO_INCREMENT,

       lst_id INT NOT NULL,

       title VARCHAR(255) NULL,

       advr VARCHAR(255) NULL,

       categories VARCHAR(255) NULL,

       expired CHAR(1) NULL,

       PRIMARY KEY (id)) ENGINE=Memory COMMENT = 'this table is for web admin monitoring purposes';



     OPEN cur_admin_listing;



     listing_loop: LOOP

       FETCH cur_admin_listing INTO mLst_id, mTitle, mSubcategory, mFullname, mXpired;



         IF eof THEN

           LEAVE listing_loop;

         END IF;

         SET @strCateg = mSubcategory;



         
         loop_split_lbl:

           WHILE @strCateg !='' DO

             
             SET @strSought = SUBSTRING_INDEX(@strCateg, ',', 1);

             SET @strCateg = SUBSTRING(@strCateg, LENGTH(@strSought)+2);



             
             SELECT sub_category INTO mTmpCateg FROM subcategories WHERE scat_id=@strSought;



             IF(ASCII(mCategoryFullName) <> 0) THEN

               SET mCategoryFullName = CONCAT(mCategoryFullName, ", ", mTmpCateg);

             ELSE

               SET mCategoryFullName = CONCAT(mCategoryFullName, mTmpCateg);

             END IF;



           END WHILE;



         INSERT INTO `tmpadminlistingtbl` SET lst_id=mLst_id, title=mTitle, advr=mFullname, categories=mCategoryFullName, expired=mXpired;

         SET mCategoryFullName = '';



     END LOOP listing_loop;



   COMMIT;

 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_advertiser_deactivate`(IN pFlag CHAR(1), IN pAdvr INT, OUT pSuccess INT)
    SQL SECURITY INVOKER
BEGIN



 DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

 DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;



 START TRANSACTION;

   UPDATE advertiser SET `status`=pFlag WHERE ad_id=pAdvr;

   SET pSuccess = 1;

 COMMIT;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_categories_count`()
BEGIN



 
 DECLARE record_not_found INT DEFAULT 0;

 DECLARE cntr INT DEFAULT 0;

 DECLARE subcateg VARCHAR(255) DEFAULT '';

 DECLARE output VARCHAR(255) DEFAULT '';

 DECLARE id  INT DEFAULT 0;



 
 DECLARE cursor_listing CURSOR FOR SELECT subcategory, lst_id FROM listing WHERE status='1' AND expired='0';



 DECLARE CONTINUE HANDLER FOR NOT FOUND SET record_not_found = 1;



 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

 DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;



 START TRANSACTION;



 
 DROP TEMPORARY TABLE IF EXISTS `tmpcateg_count`;

 CREATE TEMPORARY TABLE tmpcateg_count(

   `pos` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,

   `subcategories` VARCHAR(255) NULL,

   `listid` INT

 ) ENGINE=Memory COMMENT = 'Counts the categories';



   
   open cursor_listing;



   loop_listing_lbl: LOOP

     FETCH cursor_listing INTO subcateg, id;



     
     IF record_not_found THEN

       LEAVE loop_listing_lbl;

     END IF;



     
     SET @strCateg = subcateg;



     
     loop_split_lbl:

     WHILE @strCateg !='' DO

       
       SET @strSought = SUBSTRING_INDEX(@strCateg, ',', 1);

       SET @strCateg = SUBSTRING(@strCateg, LENGTH(@strSought)+2);



       
       INSERT INTO tmpcateg_count SET subcategories = @strSought, listid = id;



     END WHILE;

         
     


     




   END LOOP loop_listing_lbl;



   
   close cursor_listing;





 COMMIT;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_filtered_categories_count`()
    SQL SECURITY INVOKER
BEGIN



DECLARE record_not_found TINYINT DEFAULT 0;

DECLARE mListId INT DEFAULT 0;

DECLARE mMcat INT DEFAULT 0;

DECLARE mCategDesc VARCHAR(255) DEFAULT '';



DECLARE cur_categ_count CURSOR FOR SELECT t.listid, m.mcat_id, m.category AS `maincategory` FROM ((tmpcateg_count t LEFT JOIN subcategories s ON t.subcategories=s.scat_id) LEFT JOIN maincategories m ON s.mcat_id=m.mcat_id) GROUP BY t.listid, m.category;



DECLARE CONTINUE HANDLER FOR NOT FOUND SET record_not_found = 1;



DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;





START TRANSACTION;




CALL sp_categories_count();




DROP TEMPORARY TABLE IF EXISTS `tmp_filtered_categ_count`;

CREATE TEMPORARY TABLE tmp_filtered_categ_count(

`listid` INT NOT NULL,

`mcat_id` INT NOT NULL,

`maincategory` VARCHAR(255) NULL

)ENGINE=Memory COMMENT 'creates another temporary table to filter further maincategories count';




OPEN cur_categ_count;




main_loop:LOOP



  
  FETCH cur_categ_count INTO mListId, mMcat, mCategDesc;



  
  IF record_not_found THEN

    LEAVE main_loop;

  END IF;



  
     INSERT INTO tmp_filtered_categ_count SET listid = mListId, mcat_id = mMcat, maincategory = mCategDesc;



END LOOP main_loop;



COMMIT;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_inccount`(IN p_link VARCHAR(15), IN p_lst_id INT)
BEGIN

 
 
 
 
 DECLARE cntr INT DEFAULT 0;

 DECLARE pv INT DEFAULT 0;

 DECLARE pc INT DEFAULT 0;

 DECLARE uc INT DEFAULT 0;

 DECLARE en INT DEFAULT 0;

 DECLARE cur_listing CURSOR FOR SELECT pgviews, pclicks, uclicks, enq FROM listing WHERE lst_id = p_lst_id;



 
 
 


 DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

 DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;





 START TRANSACTION;





   
   OPEN cur_listing;

   FETCH cur_listing INTO pv, pc, uc, en;



   
   IF NOT STRCMP(p_link, 'pageview') THEN

     
     
     SET pv = pv + 1;





     UPDATE listing SET pgviews=pv WHERE lst_id=p_lst_id;

   END IF;



   
   IF NOT STRCMP(p_link, 'phone') THEN

     
     


     SET pc = pc+ 1;

     UPDATE listing SET pclicks=pc WHERE lst_id=p_lst_id;

   END IF;



   
   IF NOT STRCMP(p_link, 'email') THEN

     
     


     SET en = en + 1;

     UPDATE listing SET enq=en WHERE lst_id=p_lst_id;

   END IF;



   
   IF NOT STRCMP(p_link, 'url') THEN

     
     


     SET uc = uc + 1;

     UPDATE listing SET uclicks=uc WHERE lst_id=p_lst_id;

   END IF;



COMMIT;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_orders`(IN arg_itemnumber VARCHAR(50), IN arg_email VARCHAR(255), IN arg_amount DECIMAL(8,2), IN arg_status VARCHAR(50), IN arg_state MEDIUMTEXT, IN arg_zip VARCHAR(25), IN arg_address MEDIUMTEXT, IN arg_country VARCHAR(255), IN arg_paypal_trxnid VARCHAR(255), IN arg_created VARCHAR(255), OUT arg_success TINYINT)
BEGIN



   DECLARE m_lstid INT DEFAULT 0;

   DECLARE m_advr INT DEFAULT 0;



   DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

   DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;



   SET arg_success = 0;



   START TRANSACTION;



   -- gets the lst_id and advertiser

    SET m_lstid = SUBSTRING_INDEX(arg_itemnumber, '-', 1);

    SET m_advr = SUBSTRING_INDEX(arg_itemnumber, '-', -1);



     -- inserts order into the orders table

     INSERT INTO orders SET itemnumber = arg_itemnumber, email = arg_email, amount = arg_amount, `status` = arg_status, state = arg_state, zip_code = arg_zip, address = arg_address, country = arg_country, paypal_trans_id = arg_paypal_trxnid, created_at = arg_created;



     -- updates the listing table

     UPDATE listing SET expired = '0', `status` = '1';



     -- sets the output parameter to true

     SET arg_success = 1;



   COMMIT;



 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_payment_history`()
    SQL SECURITY INVOKER
BEGIN

   DECLARE int_record_not_found INT DEFAULT 0;

   DECLARE `mId` INT DEFAULT 0;

   DECLARE mItemNumber VARCHAR(255) DEFAULT '';

   DECLARE mEmail VARCHAR(255) DEFAULT '';

   DECLARE mAmount DECIMAL(8,2) DEFAULT 0.0;

   DECLARE mStatus VARCHAR(255) DEFAULT '';

   DECLARE mPaypal_trans_id VARCHAR(255) DEFAULT '';

   DECLARE mCreated_at DATETIME DEFAULT '0000-00-00 00:00:00';



   DECLARE cur_orders CURSOR FOR SELECT id, itemnumber, email, amount, `status`, paypaL_trans_id, created_at FROM orders;



   DECLARE CONTINUE HANDLER FOR NOT FOUND SET int_record_not_found = 1;





   DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

   DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;



   START TRANSACTION;



   DROP TEMPORARY TABLE IF EXISTS `tmp_payment_history_tbl`;

   CREATE TEMPORARY TABLE `tmp_payment_history_tbl`(

     id INT NOT NULL,

     itemnumber VARCHAR(50) DEFAULT '',

     lst_id INT DEFAULT 0,

     advr INT DEFAULT 0,

     email VARCHAR(150) NULL,

     amount DECIMAL(8,2) DEFAULT 0.00,

     `status` VARCHAR(50) NULL,

     paypal_trans_id VARCHAR(32) NULL,

     created_at DATETIME,

     INDEX (advr)

   )ENGINE = Memory COMMENT = 'creates temp table for payment history';



   
   OPEN cur_orders;



   SET @lstid = 0;

   SET @advr = 0;



   loop_orders: LOOP

     
     FETCH cur_orders INTO `mId`, mItemNumber, mEmail, mAmount, mStatus, mPaypal_trans_id, mCreated_at;



     
     IF int_record_not_found THEN

       LEAVE loop_orders;

     END IF;



     
     SET @lstid = SUBSTRING_INDEX(mItemNumber, '-', 1);

     SET @advr = SUBSTRING_INDEX(mItemNumber, '-', -1);



     INSERT INTO `tmp_payment_history_tbl` SET id=`mId`, itemnumber=mItemNumber, lst_id=@lstid, advr=@advr, email=mEmail, amount=mAmount, `status`=mStatus, paypal_trans_id=mPaypal_trans_id, created_at=mCreated_at;



   END LOOP loop_orders;



   
   CLOSE cur_orders;



   COMMIT;



 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_search`(IN niddle VARCHAR(255))
BEGIN

 SELECT lst_id as id, title, description, address, phone FROM listing WHERE MATCH(title, description) AGAINST(niddle) ORDER BY title DESC;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_test`(IN argFlag INT)
BEGIN







  -- creates a session variable

  IF argFlag = 1 THEN

    SET  @insertorderstatus = 1;

  ELSE

    SET @insertorderstatus = 0;

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-12-31 11:47:49
