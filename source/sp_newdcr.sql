DELIMITER $$

DROP PROCEDURE IF EXISTS `prodrivedb`.`sp_newdcr` $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_newdcr`(IN m_trnx_date DATE, IN m_beg_bal DECIMAL(8,2), IN m_cashier INT, IN m_status INT, OUT m_dcr_id BIGINT)
BEGIN
INSERT INTO dcr SET trnxdate = m_trnx_date, begbal = m_beg_bal, cashier = m_cashier, `status` = m_status;
  SET m_dcr_id = LAST_INSERT_ID();
END $$

DELIMITER ;