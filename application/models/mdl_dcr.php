<?php
class mdl_dcr extends CI_Model{
	
	function hasCurrentDCR(&$dcrNo = null) {
		global $almd_db;
		$curdate = curdate();
		$params = array('uname', 'islog', 'fullname', 'uid', 'uaccess');
		$this->sessionbrowser->getInfo($params);
		$user = $this->sessionbrowser->mData;
		$currentUser = $user['uid'];
		$strQry = sprintf("SELECT * FROM %s WHERE trnxdate='%s' AND cashier=%d", $almd_db->dcr, $curdate, $currentUser);
		
		$record = $this->db->query($strQry);
		if($record->num_rows < 1)
			return FALSE;
		
		$dcrNo = $record->result();
		
		return TRUE;
	}
	
	public function newDCR(&$dcrNo = null) {
		global $almd_db;
		$params = array('uname', 'islog', 'fullname', 'uid', 'uaccess');
		$this->sessionbrowser->getInfo($params);
		$user = $this->sessionbrowser->mData;
		$currentUser = $user['uid'];
		
		$strQry = sprintf("INSERT INTO %s SET trnxdate='%s', cashier=%d, `status`=1", $almd_db->dcr, curdate(), $currentUser );
		
		on_watch($strQry);
	}

}