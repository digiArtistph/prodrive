<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_cutoff extends CI_Model {
	
	public function cashFloatCutOff() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("UPDATE cashfloat SET `status`='0' WHERE trnxdate='%s' AND cashier=%d AND `status`='1'", $curdate, $almd_userid);
		
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;
	}
	
	public function cashLiftCutOff() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("UPDATE cashlift SET `status`='0' WHERE trnxdate='%s' AND cashier=%d AND `status`='1'", $curdate, $almd_userid);
		
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;
	}
	
	public function cashierCutOff() {
		global $almd_userid;
		$curDate = curdate();
		
		$strQry = sprintf("UPDATE dcr SET `status`= '0'  WHERE trnxdate='%s' AND cashier=%d", $curDate, $almd_userid);
		
		if(! $this->db->query($strQry))
			return FALSE;
			
		return TRUE;			
	}
	
}