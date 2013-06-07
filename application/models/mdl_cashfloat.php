<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Mdl_cashfloat extends CI_Model {
	
	public function hasActiveShift() {
		global $almd_userid;
		$curdate = curdate();
		
		$strQry = sprintf("SELECT d.dcr_id, d.trnxdate, d.begbal, d.cashier, d.`status`, u.username FROM dcr d LEFT JOIN users u ON d.cashier=u.u_id WHERE (d.trnxdate='%s' AND d.cashier=%d AND d.`status`='1')", $curdate, $almd_userid);

		if($this->db->query($strQry)->num_rows < 1)
			return FALSE;
		
		return TRUE;
	}
}