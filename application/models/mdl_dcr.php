<?php
class mdl_dcr extends CI_Model{
	
	function hasCurrentDCR(&$dcrNo = null) {
		global $almd_db;
		global $almd_userid;
		global $almd_username;
		$curdate = curdate();

		$currentUser = $almd_userid;
		$strQry = sprintf("SELECT * FROM %s WHERE trnxdate='%s' AND cashier=%d", $almd_db->dcr, $curdate, $currentUser);
		
		$record = $this->db->query($strQry);
		if($record->num_rows < 1)
			return FALSE;
		
		$dcrNo = $record->result();
		
		return TRUE;
	}
	
	public function newDCR(&$dcrNo = null) {
		global $almd_db;
		global $almd_userid;
		$currentUser = $almd_userid;
		
		$strQry = sprintf("INSERT INTO %s SET trnxdate='%s', cashier=%d, `status`=1", $almd_db->dcr, curdate(), $currentUser );
		
		$this->db->query($strQry);
		$tmp = array('dcr_id' => '', 'trnxdate' => curdate(), 'begbal' => '', 'cashier' => '', 'status ' => 1);
		
		$tmp = array((Object)$tmp);
		call_debug($data['dcr_id'], FALSE);
		call_debug($tmp);
		
		on_watch($strQry);
	}

}